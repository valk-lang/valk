#!/usr/bin/env bash
set -euo pipefail

VALK=${VALK:-./valk}
fixture_dir=$(cd "$(dirname "$0")" && pwd)
workdir=$(mktemp -d)
server_pid=
cleanup() {
    if [[ -n "$server_pid" ]]; then
        kill "$server_pid" 2>/dev/null || true
        wait "$server_pid" 2>/dev/null || true
    fi
    rm -r "$workdir"
}
trap cleanup EXIT
if ! curl --version | grep -q 'HTTP2'; then
    echo 'HTTP/2-enabled curl is required'
    exit 1
fi
"$VALK" build "$fixture_dir/server.valk" --no-warn -o "$workdir/server"
"$workdir/server" >"$workdir/server.log" 2>&1 &
server_pid=$!
ready=0
for attempt in {1..100}; do
    if curl -ksS --http2 --max-time 1 https://127.0.0.1:9095/ready >"$workdir/ready" 2>/dev/null; then
        ready=1
        break
    fi
    sleep 0.05
done
if [[ "$ready" != 1 ]]; then
    cat "$workdir/server.log"
    exit 1
fi
version=$(curl -ksS --http2 --max-time 10 -o "$workdir/large" -w '%{http_version}' https://127.0.0.1:9095/large)
[[ "$version" == 2 ]]
[[ $(wc -c <"$workdir/large") == 100000 ]]
version=$(curl -ksS --http2 --max-time 10 --data-binary "@$workdir/large" -o "$workdir/echo" -w '%{http_version}' https://127.0.0.1:9095/echo)
[[ "$version" == 2 ]]
cmp "$workdir/large" "$workdir/echo"
version=$(curl -ksS --http1.1 --max-time 10 -o "$workdir/fallback" -w '%{http_version}' https://127.0.0.1:9095/fallback)
[[ "$version" == 1.1 ]]
[[ $(cat "$workdir/fallback") == 'h2:/fallback' ]]
curl -ksS --http2 --max-time 10 https://127.0.0.1:9095/stop > /dev/null
wait "$server_pid"
server_pid=
echo 'HTTP/2 curl interoperability passed'
