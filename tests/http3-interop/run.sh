#!/usr/bin/env bash
set -euo pipefail

VALK=${VALK:-./valk}
fixture_dir=$(cd "$(dirname "$0")" && pwd)
assets_dir=$(cd "$fixture_dir/../assets" && pwd)
port=19443
base="https://127.0.0.1:$port"

if ! command -v curl >/dev/null 2>&1 || ! curl --version | grep -q 'HTTP3'; then
    echo "SKIP: HTTP/3-enabled curl is not available"
    exit 0
fi

workdir=$(mktemp -d)
server_pid=
cleanup() {
    if [[ -n "$server_pid" ]]; then
        kill "$server_pid" 2>/dev/null || true
        wait "$server_pid" 2>/dev/null || true
    fi
    rm -rf "$workdir"
}
trap cleanup EXIT

"$VALK" build "$fixture_dir/server.valk" --no-warn -o "$workdir/server"
"$workdir/server" >"$workdir/server.log" 2>&1 &
server_pid=$!

ready=0
for _ in $(seq 1 100); do
    if curl -ksS --http3-only --max-time 1 "$base/ready" >"$workdir/ready" 2>/dev/null; then
        ready=1
        break
    fi
    sleep 0.05
done
if [[ "$ready" != 1 ]]; then
    echo "Server failed to become ready over HTTP/3"
    cat "$workdir/server.log"
    exit 1
fi

# 1. GET with query string and custom headers over HTTP/3
ver=$(curl -ksS --http3-only --max-time 10 -H "X-Custom: valk-h3" -D "$workdir/h3_hdrs" -o "$workdir/h3_body" -w '%{http_version}' "$base/hello?foo=bar")
[[ "$ver" == "3" ]]
[[ "$(cat "$workdir/h3_body")" == "hello:foo=bar" ]]
grep -qi '^x-echo-header: valk-h3' "$workdir/h3_hdrs"
if grep -qi '^alt-svc:' "$workdir/h3_hdrs"; then
    echo "Unexpected Alt-Svc header on HTTP/3 response"
    cat "$workdir/h3_hdrs"
    exit 1
fi

# 2. POST with small, large (128 KiB), and Expect: 100-continue bodies over HTTP/3
ver=$(curl -ksS --http3-only --max-time 10 -X POST --data "hello-post-body" -o "$workdir/post_small" -w '%{http_version}' "$base/echo")
[[ "$ver" == "3" ]]
[[ "$(cat "$workdir/post_small")" == "POST:hello-post-body" ]]

head -c 131072 /dev/zero | tr '\0' 'A' > "$workdir/post_in"
ver=$(curl -ksS --http3-only --max-time 10 -X POST --data-binary "@$workdir/post_in" -o "$workdir/post_out" -w '%{http_version}' "$base/echo")
[[ "$ver" == "3" ]]
printf 'POST:' > "$workdir/post_expected"
cat "$workdir/post_in" >> "$workdir/post_expected"
cmp "$workdir/post_expected" "$workdir/post_out"

ver=$(curl -ksS --http3-only --max-time 5 -H "Expect: 100-continue" -X POST --data "expect-ok" -D "$workdir/expect_hdrs" -o "$workdir/expect_out" -w '%{http_version}' "$base/echo")
[[ "$ver" == "3" ]]
[[ "$(cat "$workdir/expect_out")" == "POST:expect-ok" ]]
grep -q '^HTTP/3 100' "$workdir/expect_hdrs"

# 3. HEAD and large (>100 KiB) GET response over HTTP/3
ver=$(curl -ksS --http3-only --max-time 10 -I -D "$workdir/head_hdrs" -o /dev/null -w '%{http_version}' "$base/large")
[[ "$ver" == "3" ]]
grep -qi '^content-length: 262144' "$workdir/head_hdrs"

ver=$(curl -ksS --http3-only --max-time 10 -o "$workdir/large" -w '%{http_version}' "$base/large")
[[ "$ver" == "3" ]]
[[ "$(wc -c < "$workdir/large")" == "262144" ]]

# 4. gzip and zstd compression over HTTP/3
ver=$(curl -ksS --http3-only --max-time 10 -H "Accept-Encoding: gzip" -D "$workdir/gz_hdrs" -o "$workdir/gz_body" -w '%{http_version}' "$base/compress")
[[ "$ver" == "3" ]]
grep -qi '^content-encoding: gzip' "$workdir/gz_hdrs"
[[ "$(gzip -dc "$workdir/gz_body" | wc -c)" == "4096" ]]

if curl --version | grep -qi 'zstd'; then
    ver=$(curl -ksS --http3-only --max-time 10 --compressed -H "Accept-Encoding: zstd" -D "$workdir/zstd_hdrs" -o "$workdir/zstd_body" -w '%{http_version}' "$base/compress")
    [[ "$ver" == "3" ]]
    grep -qi '^content-encoding: zstd' "$workdir/zstd_hdrs"
    [[ "$(wc -c < "$workdir/zstd_body")" == "4096" ]]
fi

# 5. Streaming response over HTTP/3 (64 * 1024 = 65536 bytes)
ver=$(curl -ksS --http3-only --max-time 10 -o "$workdir/stream" -w '%{http_version}' "$base/stream")
[[ "$ver" == "3" ]]
[[ "$(wc -c < "$workdir/stream")" == "65536" ]]

# 6. Trailing HEADERS frame over HTTP/3
ver=$(curl -ksS --http3-only --max-time 10 -D "$workdir/trailer_hdrs" -o "$workdir/trailer_body" -w '%{http_version}' "$base/trailers")
[[ "$ver" == "3" ]]
[[ "$(cat "$workdir/trailer_body")" == "trailers-body" ]]
grep -qi '^x-checksum: deadbeef' "$workdir/trailer_hdrs"
grep -qi '^x-status: ok' "$workdir/trailer_hdrs"

# 7. Static files, ETag/304, and Range/206 over HTTP/3
ver=$(curl -ksS --http3-only --max-time 10 -D "$workdir/static_hdrs" -o "$workdir/parse.json" -w '%{http_version}' "$base/static/parse.json")
[[ "$ver" == "3" ]]
cmp "$assets_dir/parse.json" "$workdir/parse.json"

etag=$(awk 'tolower($1)=="etag:" { gsub(/\r/, "", $2); print $2; exit }' "$workdir/static_hdrs")
[[ -n "$etag" ]]
code=$(curl -ksS --http3-only --max-time 10 -H "If-None-Match: $etag" -o /dev/null -w '%{http_code}' "$base/static/parse.json")
[[ "$code" == "304" ]]

code=$(curl -ksS --http3-only --max-time 10 -H "Range: bytes=0-99" -o "$workdir/range" -w '%{http_code}' "$base/static/large.png")
[[ "$code" == "206" ]]
[[ "$(wc -c < "$workdir/range")" == "100" ]]
head -c 100 "$assets_dir/large.png" > "$workdir/range_expected"
cmp "$workdir/range_expected" "$workdir/range"

# 8. Automatic Alt-Svc advertised over HTTP/2 and HTTP/1.1 + curl --alt-svc upgrade to H3
ver=$(curl -ksS --http2 --max-time 10 -D "$workdir/h2_hdrs" -o "$workdir/h2_body" -w '%{http_version}' "$base/hello?p=h2")
[[ "$ver" == "2" ]]
[[ "$(cat "$workdir/h2_body")" == "hello:p=h2" ]]
grep -qi "^alt-svc: h3=\":$port\"; ma=86400" "$workdir/h2_hdrs"

ver=$(curl -ksS --http1.1 --max-time 10 -D "$workdir/h1_hdrs" -o "$workdir/h1_body" -w '%{http_version}' "$base/hello?p=h1")
[[ "$ver" == "1.1" ]]
[[ "$(cat "$workdir/h1_body")" == "hello:p=h1" ]]
grep -qi "^alt-svc: h3=\":$port\"; ma=86400" "$workdir/h1_hdrs"

v1=$(curl -ksS --alt-svc "$workdir/alt-svc.txt" --max-time 10 -o /dev/null -w '%{http_version}' "$base/hello?alt=1")
[[ "$v1" == "2" ]]
v2=$(curl -ksS --alt-svc "$workdir/alt-svc.txt" --max-time 10 -o /dev/null -w '%{http_version}' "$base/hello?alt=2")
[[ "$v2" == "3" ]]

# 9. Concurrent multiplexed HTTP/3 streams with curl --parallel
par_ok=$(curl -ksS --http3-only --parallel --parallel-immediate --parallel-max 25 --max-time 15 -w '%{http_version}:%{http_code}\n' -o /dev/null "$base/hello?n=[1-50]" | grep -c '^3:200$')
[[ "$par_ok" == "50" ]]

# 10. Concurrent multiplexed requests with h2load (H2, plus H3 when h2load is built with nghttp3)
if command -v h2load >/dev/null 2>&1; then
    h2load -n 200 -c 4 -m 10 "$base/hello?load=h2" > "$workdir/h2load_h2.log" 2>&1
    grep -q '200 succeeded, 0 failed' "$workdir/h2load_h2.log"

    if command -v ldd >/dev/null 2>&1 && ldd "$(command -v h2load)" 2>/dev/null | grep -q 'libnghttp3'; then
        h2load --h3 -n 200 -c 4 -m 10 "$base/hello?load=h3" > "$workdir/h2load_h3.log" 2>&1
        grep -q '200 succeeded, 0 failed' "$workdir/h2load_h3.log"
    fi
fi

# 11. Graceful shutdown
curl -ksS --http3-only --max-time 10 "$base/stop" >/dev/null
wait "$server_pid"
server_pid=

echo "HTTP/3 curl & h2load interoperability passed"
