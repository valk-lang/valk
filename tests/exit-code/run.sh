#!/bin/bash
# Build each fixture and check the process exit status it produces.
# `fn main() i32` returns the exit code; a void `fn main()` always exits 0.
# Usage (from repo root): ./tests/exit-code/run.sh
# Optional: VALK=./valk-new ./tests/exit-code/run.sh

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
cases="return-3:3 return-0:0 void-main:0 return-int:7 return-non-integer:0"

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
    "$exe" >/dev/null 2>&1
    got=$?
    set -e

    if [ "$got" -ne "$want" ]; then
        echo "# Wrong exit status"
        echo "- File: $input"
        echo "- Expected: $want"
        echo "- Actual: $got"
        failed=1
        continue
    fi
done

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
