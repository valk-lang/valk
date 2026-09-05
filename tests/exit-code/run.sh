#!/bin/bash

set -u

VALK="${VALK:-./valk}"
DIR="./tests/exit-code"
EXE_SUFFIX=""
case "$(uname -s)" in
    MINGW*|MSYS*) EXE_SUFFIX=".exe" ;;
esac
failed=0
count=0

echo ""
echo "# Test main() exit codes"

if [ ! -x "$VALK" ] && [ ! -f "$VALK" ]; then
    echo "Error: compiler not found: $VALK"
    exit 1
fi

workdir=$(mktemp -d)
if [ -n "$EXE_SUFFIX" ]; then
    workdir=$(cygpath -m "$workdir")
fi
trap 'rm -rf "$workdir"' EXIT

# fixture:expected exit status
cases="return-3:3 return-0:0 void-main:0 return-int:7 return-non-integer:0 fixed-array-bounds:1 unbound-bounds:1 named-unbound-bounds:1 fixed-array-write-bounds:1 fixed-array-range-bounds:1 unbound-range-bounds:1 named-unbound-range-bounds:1 named-unbound-write-bounds:1 array-set-expand-overflow:1 gc-alloc-overflow:1"

cases="$cases unhandled-error:1 array-bounds:1 array-write-bounds:1 slice-bounds:1 slice-write-bounds:1 ref-slice-bounds:1 ref-slice-range-bounds:1"

for case in $cases; do
    name="${case%%:*}"
    want="${case##*:}"
    input="$DIR/$name.valk"

    if [ ! -f "$input" ]; then
        echo "# Missing fixture: $input"
        failed=1
        continue
    fi

    count=$((count + 1))
    exe="$workdir/$name$EXE_SUFFIX"
    echo "> Run: $VALK build $input -o $exe (expect exit $want)"

    set +e
    out=$("$VALK" build "$input" --no-warn -o "$exe" 2>&1)
    status=$?
    set -e

    if [ "$status" -ne 0 ]; then
        echo "# Build failed"
        echo "- File: $input"
        echo "- Exit code: $status"
        echo "- Output:"
        echo "$out"
        failed=1
        continue
    fi

    set +e
    output=$("$exe" 2>&1)
    got=$?
    set -e

    if [ "$name" = "unhandled-error" ] && [[ "$output" != *"unhandled-error.valk:8"* ]]; then
        echo "# Missing unhandled error source location: $output"
        failed=1
    fi

    if [ "$got" -ne "$want" ]; then
        echo "# Wrong exit status"
        echo "- File: $input"
        echo "- Expected: $want"
        echo "- Actual: $got"
        failed=1
        continue
    fi
done

count=$((count + 1))
input="$DIR/stdin-read.valk"
exe="$workdir/stdin-read$EXE_SUFFIX"
echo "> Run: pipe input through io.read"
set +e
out=$("$VALK" build "$input" --no-warn -o "$exe" 2>&1)
status=$?
set -e
if [ "$status" -ne 0 ]; then
    echo "# Build failed"
    echo "- File: $input"
    echo "- Exit code: $status"
    echo "- Output:"
    echo "$out"
    failed=1
else
    set +e
    printf 'pingpong' | "$exe" >/dev/null 2>&1
    got=$?
    set -e
    if [ "$got" -ne 0 ]; then
        echo "# io.read failed to read piped standard input"
        echo "- File: $input"
        echo "- Exit code: $got"
        failed=1
    fi
fi

if [ "$count" -eq 0 ]; then
    echo "# No exit-code fixtures found in $DIR"
    exit 1
fi

echo ""
if [ "$failed" -ne 0 ]; then
    echo "# Exit code tests failed"
    exit 1
fi

echo "# All exit code tests passed"
echo "# Test count: $count"
echo ""
