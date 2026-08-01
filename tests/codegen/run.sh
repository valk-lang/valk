#!/bin/bash
# Generated-code regressions that are observable only in LLVM IR.

set -u

VALK="${VALK:-./valk}"
DIR="$(cd "$(dirname "$0")" && pwd)"
case "$(uname -s)" in
    MINGW*|MSYS*) DIR="$(cd "$(dirname "$0")" && pwd -W)" ;;
esac

workdir=$(mktemp -d)
case "$(uname -s)" in
    MINGW*|MSYS*) workdir=$(cygpath -m "$workdir") ;;
esac
trap 'rm -rf "$workdir"' EXIT

echo ""
echo "# Test generated-code optimizations"
echo "> Coalesce temporary GC roots across statements"

ir="$workdir/buffer-roots.ll"
out=$("$VALK" build "$DIR/buffer-roots.valk" --ir --no-warn -o "$ir" 2>&1)
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Failed to build IR fixture"
    echo "$out"
    exit 1
fi

body=$(sed -n '/^define .*__coalesced_roots__/,/^}/p' "$ir")
if [ -z "$body" ]; then
    echo "# Missing coalesced_roots in generated IR"
    exit 1
fi
if [[ "$body" != *"store i64 2, ptr %valk.gc.stack.count"* ]]; then
    echo "# Expected two temporary root slots"
    echo "$body"
    exit 1
fi

echo "# All generated-code optimization tests passed"
echo "# Test count: 1"
echo ""
