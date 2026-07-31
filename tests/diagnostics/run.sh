#!/bin/bash
# Regression tests for user-facing source locations. Compiler diagnostics use
# 1-based line/column numbers; LSP ranges are covered separately in tests/lsp.

set -u

VALK="${VALK:-./valk}"
DIR="$(cd "$(dirname "$0")" && pwd)"
workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

failed=0
count=0

echo ""
echo "# Test diagnostic source locations"

check_build_error() {
    local name="$1"
    local file="$2"
    local location="$3"
    local message="$4"
    count=$((count + 1))
    echo "> $name"

    local out status
    out=$("$VALK" build "$DIR/$file.valk" --no-warn -o "$workdir/$file" 2>&1)
    status=$?
    if [ "$status" -eq 0 ] || [[ "$out" != *"# File: $DIR/$file.valk"* ]] || \
       [[ "$out" != *"# Line: $location"* ]] || [[ "$out" != *"$message"* ]]; then
        echo "# Wrong build diagnostic"
        echo "- Case: $name"
        echo "- Expected location: $DIR/$file.valk:$location"
        echo "- Expected message: $message"
        echo "- Exit code: $status"
        echo "$out"
        failed=1
    fi
}

check_build_error "parser error" parser "4 | Col: 1" "Unexpected token in value expression: '}'"
check_build_error "type error" type "3 | Col: 13" "Incompatible types"
check_build_error "interpolated expression error" interpolation "3 | Col: 26" "Unknown identifier: missing_name"
check_build_error "compile macro error" macro "3 | Col: 5" "Unexpected '#else'"

count=$((count + 1))
echo "> warning location"
warn_out=$("$VALK" build "$DIR/warning.valk" -o "$workdir/warning" 2>&1)
warn_status=$?
if [ "$warn_status" -ne 0 ] || [[ "$warn_out" != *"unused_value' was declared but never used @ $DIR/warning.valk:3:5"* ]]; then
    echo "# Wrong warning location"
    echo "- Expected: $DIR/warning.valk:3:5"
    echo "- Exit code: $warn_status"
    echo "$warn_out"
    failed=1
fi

count=$((count + 1))
echo "> failed assertion location"
assert_bin="$workdir/assert-test"
assert_build=$("$VALK" build "$DIR/assert.valk" --test --no-warn -o "$assert_bin" 2>&1)
assert_build_status=$?
if [ "$assert_build_status" -ne 0 ]; then
    echo "# Failed to build assertion fixture"
    echo "$assert_build"
    failed=1
else
    assert_out=$("$assert_bin" 2>&1)
    assert_status=$?
    if [ "$assert_status" -eq 0 ] || [[ "$assert_out" != *"assert(actual == expected)"* ]] || \
       [[ "$assert_out" != *"[file] $DIR/assert.valk:4"* ]]; then
        echo "# Wrong failed-assertion location"
        echo "- Expected: $DIR/assert.valk:4"
        echo "- Exit code: $assert_status"
        echo "$assert_out"
        failed=1
    fi
fi

if [ "$failed" -ne 0 ]; then
    echo "# Diagnostic source-location tests failed"
    exit 1
fi

echo "# All diagnostic source-location tests passed"
echo "# Test count: $count"
echo ""
