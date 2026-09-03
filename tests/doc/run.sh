#!/bin/bash

set -u

VALK="${VALK:-./valk}"
DIR="$(cd "$(dirname "$0")" && pwd)"
workdir=$(mktemp -d)
case "$(uname -s)" in
    MINGW*|MSYS*) workdir=$(cygpath -m "$workdir") ;;
esac
trap 'rm -rf "$workdir"' EXIT

echo ""
echo "# Test API documentation"
echo "> Preserve generic parameter names"

out=$("$VALK" doc "$DIR/fixture" -o "$workdir/api.json" 2>&1)
status=$?
if [ "$status" -ne 0 ]; then
    echo "$out"
    exit 1
fi

doc=$(<"$workdir/api.json")
if [[ "$doc" != *'"type": "T"'* ]] \
    || [[ "$doc" != *'"return-type": "T"'* ]] \
    || [[ "$doc" != *'"type": "K"'* ]] \
    || [[ "$doc" != *'"type": "V"'* ]] \
    || [[ "$doc" != *'"return-type": "V"'* ]] \
    || [[ "$doc" == *'"type": "any"'* ]] \
    || [[ "$doc" == *'"return-type": "any"'* ]]; then
    echo "# Generic parameter names were not preserved"
    echo "$doc"
    exit 1
fi

out=$("$VALK" doc "$DIR/fixture" -o "$workdir/api.md" --markdown 2>&1)
status=$?
if [ "$status" -ne 0 ]; then
    echo "$out"
    exit 1
fi

markdown=$(<"$workdir/api.md")
if [[ "$markdown" != *'+ class Box[T]'* ]] \
    || [[ "$markdown" != *'+ get value_type: T'* ]] \
    || [[ "$markdown" != *'+ fn get(value: T) T'* ]] \
    || [[ "$markdown" != *'+ struct Pair[T]'* ]] \
    || [[ "$markdown" != *'+ first: T'* ]] \
    || [[ "$markdown" != *'+ fn left() T'* ]] \
    || [[ "$markdown" != *'+ class Ahead'* ]] \
    || [[ "$markdown" != *'+ fn name() String'* ]]; then
    echo "# Markdown sorting did not preserve class declarations"
    echo "$markdown"
    exit 1
fi

repo=$(cd "$DIR/../.." && pwd)
out=$("$VALK" doc "$repo/lib" -o "$workdir/stdlib-api.md" --markdown --no-private --target linux-x64 2>&1)
status=$?
if [ "$status" -ne 0 ]; then
    echo "$out"
    exit 1
fi
if ! cmp -s "$workdir/stdlib-api.md" "$repo/docs/api.md"; then
    echo "# Committed standard-library API documentation is stale"
    diff -u "$repo/docs/api.md" "$workdir/stdlib-api.md" || true
    exit 1
fi
stdlib_markdown=$(<"$workdir/stdlib-api.md")
if [[ "$stdlib_markdown" != *'+ slice Slice[T] of T'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn view(start_index: uint, length: uint) Slice[u8]'* ]] \
    || [[ "$stdlib_markdown" != *'+ static fn copy_from_ptr(data: ptr, length: uint) String'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn read(fd: i32, buf: Slice[u8], offset: uint) uint !IoError'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn read_sync(fd: i32, buf: Slice[u8], offset: uint) uint !IoError'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn read(buf: Slice[u8]) uint !io:IoError'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn write(fd: i32, data: Slice[u8]) uint !IoError'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn recv(fd: i32, buf: Slice[u8], timeout_ms: uint (5000)) uint !io:IoError'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn write(fd: i32, data: Slice[u8], timeout_ms: uint (5000)) uint !io:IoError'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn read(buf: Slice[u8]) uint !io:IoError'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn write(data: Slice[u8]) uint !io:IoError'* ]] \
    || [[ "$stdlib_markdown" != *'+ class HashMap[K, T]'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn get(key: K) T !LookupError'* ]] \
    || [[ "$stdlib_markdown" == *'+ class BlowfishContext'* ]] \
    || [[ "$stdlib_markdown" == *'+ global parray'* ]] \
    || [[ "$stdlib_markdown" == *'+ global SIGMA'* ]]; then
    echo "# Standard-library public API surface is incorrect"
    exit 1
fi
if [[ "$stdlib_markdown" == *'fn write_string(fd:'* ]] \
    || [[ "$stdlib_markdown" == *'fn write_buffer(fd:'* ]] \
    || [[ "$stdlib_markdown" == *'fn write_string(str: String) void !io:IoError'* ]] \
    || [[ "$stdlib_markdown" == *'fn write_buffer(buffer: ByteBuffer) void !io:IoError'* ]] \
    || [[ "$stdlib_markdown" == *'fn send_string(fd:'* ]] \
    || [[ "$stdlib_markdown" == *'fn send_string(data:'* ]] \
    || [[ "$stdlib_markdown" == *'fn send_buffer(data:'* ]] \
    || [[ "$stdlib_markdown" == *'fn send(fd: i32, data: Slice[u8]'* ]] \
    || [[ "$stdlib_markdown" == *'fn send(data: Slice[u8]'* ]] \
    || [[ "$stdlib_markdown" == *'fn read(fd: i32, buf: ByteBuffer'* ]] \
    || [[ "$stdlib_markdown" == *'fn recv(fd: i32, buf: ByteBuffer'* ]] \
    || [[ "$stdlib_markdown" == *'fn recv(buffer: ByteBuffer'* ]] \
    || [[ "$stdlib_markdown" == *'fn read(bytes: uint'* ]] \
    || [[ "$stdlib_markdown" == *'send_all'* ]]; then
    echo "# Standard-library byte I/O still exposes type-specific adapters"
    exit 1
fi

echo "> Keep basic documentation examples current"

guide=$(<"$repo/docs/docs.md")
readme=$(<"$repo/README.md")
if [[ "$guide" != *'let path : fs.Path = "."'* ]] \
    || [[ "$guide" != *'path = path.resolve() ! panic("Failed to resolve path")'* ]] \
    || [[ "$guide" != *'con.write("PING")'* ]] \
    || [[ "$guide" != *'template.render("example.html", data)'* ]] \
    || [[ "$guide" == *'con.send("PING")'* ]] \
    || [[ "$guide" == *'sanitize:'* ]] \
    || [[ "$guide" == *'[valk.type](api.md#core)'* ]] \
    || [[ "$guide" == *'Install a package globally'* ]] \
    || [[ "$guide" == *'configured sanitizer'* ]]; then
    echo "# Basic documentation contains stale API examples"
    exit 1
fi
if [[ "$readme" != *'curl -sSL https://valk-lang.dev/install.sh | bash'* ]] \
    || [[ "$readme" == *'curl -s https://valk-lang.dev/install.sh | bash'* ]]; then
    echo "# README contains a stale installation command"
    exit 1
fi

echo "# 3/3 documentation tests passed"
