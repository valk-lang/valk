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
if [[ "$stdlib_markdown" != *'+ struct ByteView[T]'* ]] \
    || [[ "$stdlib_markdown" != *'+ static fn new(source: T, offset: uint, length: uint) ByteView[T]'* ]] \
    || [[ "$stdlib_markdown" != *'+ class HashMap[K, T]'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn get(key: K) T !LookupError'* ]] \
    || [[ "$stdlib_markdown" == *'+ class BlowfishContext'* ]] \
    || [[ "$stdlib_markdown" == *'+ global parray'* ]] \
    || [[ "$stdlib_markdown" == *'+ global SIGMA'* ]]; then
    echo "# Standard-library public API surface is incorrect"
    exit 1
fi

echo "> Keep basic documentation examples current"

guide=$(<"$repo/docs/docs.md")
if [[ "$guide" != *'let path : fs.Path = "."'* ]] \
    || [[ "$guide" != *'path = path.resolve() ! panic("Failed to resolve path")'* ]] \
    || [[ "$guide" != *'con.send_string("PING")'* ]] \
    || [[ "$guide" != *'template.render("example.html", data)'* ]] \
    || [[ "$guide" == *'con.send("PING")'* ]] \
    || [[ "$guide" == *'sanitize:'* ]] \
    || [[ "$guide" == *'[valk.type](api.md#core)'* ]] \
    || [[ "$guide" == *'Install a package globally'* ]] \
    || [[ "$guide" == *'configured sanitizer'* ]]; then
    echo "# Basic documentation contains stale API examples"
    exit 1
fi

echo "# 3/3 documentation tests passed"
