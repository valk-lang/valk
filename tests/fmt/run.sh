#!/bin/bash

set -u

VALK="${VALK:-./valk}"
DIR="./tests/fmt"
EXPECT_DIR="$DIR/expected"
failed=0
count=0

echo ""
echo "# Test --fmt"

if [ ! -x "$VALK" ] && [ ! -f "$VALK" ]; then
    echo "Error: compiler not found: $VALK"
    exit 1
fi

if [ ! -d "$EXPECT_DIR" ]; then
    echo "Error: expected directory not found: $EXPECT_DIR"
    exit 1
fi

workdir=$(mktemp -d)
case "$(uname -s)" in
    MINGW*|MSYS*) workdir=$(cygpath -m "$workdir") ;;
esac
trap 'rm -rf "$workdir"' EXIT

for expected in "$EXPECT_DIR"/*.valk; do
    [ -f "$expected" ] || continue
    name=$(basename "$expected")
    input="$DIR/$name"

    if [ ! -f "$input" ]; then
        echo "# Missing input for snapshot: $input"
        failed=1
        continue
    fi

    count=$((count + 1))
    # Copy so --fmt never rewrites the unformatted fixture
    actual="$workdir/$name"
    cp "$input" "$actual"

    cmd="$VALK build $actual --fmt --no-warn"
    echo "> Run: $cmd"

    set +e
    out=$("$VALK" build "$actual" --fmt --no-warn 2>&1)
    status=$?
    set -e

    if [ "$status" -ne 0 ]; then
        echo "# --fmt build failed"
        echo "- File: $name"
        echo "- Exit code: $status"
        echo "- Output:"
        echo "$out"
        failed=1
        continue
    fi

    if ! diff -u "$expected" "$actual"; then
        echo "# Format output mismatch"
        echo "- Input:    $input"
        echo "- Expected: $expected"
        echo "- Actual:   $actual (temp copy after --fmt)"
        failed=1
        continue
    fi

    once="$workdir/$name.once"
    cp "$actual" "$once"
    set +e
    out=$("$VALK" build "$actual" --fmt --no-warn 2>&1)
    status=$?
    set -e
    if [ "$status" -ne 0 ]; then
        echo "# Second --fmt build failed"
        echo "- File: $name"
        echo "- Exit code: $status"
        echo "- Output:"
        echo "$out"
        failed=1
        continue
    fi
    if ! diff -u "$once" "$actual"; then
        echo "# Formatter is not idempotent"
        echo "- File: $name"
        failed=1
        continue
    fi
done

if [ "$count" -eq 0 ]; then
    echo "# No fmt snapshots found in $EXPECT_DIR"
    exit 1
fi

# Input that does not parse must fail and stay untouched
for input in "$DIR"/invalid/*.valk; do
    [ -f "$input" ] || continue
    name=$(basename "$input")
    count=$((count + 1))
    actual="$workdir/invalid-$name"
    cp "$input" "$actual"

    cmd="$VALK build $actual --fmt --no-warn"
    echo "> Run: $cmd"

    set +e
    out=$("$VALK" build "$actual" --fmt --no-warn 2>&1)
    status=$?
    set -e

    if [ "$status" -eq 0 ]; then
        echo "# --fmt accepted invalid input"
        echo "- File: $name"
        echo "- Output:"
        echo "$out"
        failed=1
        continue
    fi
    if ! diff -u "$input" "$actual"; then
        echo "# --fmt rewrote invalid input"
        echo "- File: $name"
        failed=1
        continue
    fi
done

echo ""
if [ "$failed" -ne 0 ]; then
    echo "# Fmt tests failed"
    exit 1
fi

echo "# All fmt tests passed"
echo "# Test count: $count"
echo ""
