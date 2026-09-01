#!/bin/bash

set -u

VALK="${VALK:-./valk}"
DIR="$(cd "$(dirname "$0")" && pwd)"
EXE_SUFFIX=""
case "$(uname -s)" in
    MINGW*|MSYS*)
        DIR="$(cd "$(dirname "$0")" && pwd -W)"
        EXE_SUFFIX=".exe"
        ;;
esac
workdir=$(mktemp -d)
if [ -n "$EXE_SUFFIX" ]; then
    workdir=$(cygpath -m "$workdir")
fi
trap 'rm -rf "$workdir"' EXIT

failed=0
count=0

normalize_paths() {
    tr '\\' '/'
}

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
    out=$(printf '%s' "$out" | normalize_paths)
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
warn_out=$(printf '%s' "$warn_out" | normalize_paths)
if [ "$warn_status" -ne 0 ] || [[ "$warn_out" != *"unused_value' was declared but never used @ $DIR/warning.valk:3:5"* ]]; then
    echo "# Wrong warning location"
    echo "- Expected: $DIR/warning.valk:3:5"
    echo "- Exit code: $warn_status"
    echo "$warn_out"
    failed=1
fi

count=$((count + 1))
echo "> unnecessary unsafe warning"
unsafe_warn_out=$("$VALK" build "$DIR/unsafe-warning.valk" -o "$workdir/unsafe-warning" 2>&1)
unsafe_warn_status=$?
unsafe_warn_out=$(printf '%s' "$unsafe_warn_out" | normalize_paths)
if [ "$unsafe_warn_status" -ne 0 ] || \
   [[ "$unsafe_warn_out" != *"Unnecessary '@unsafe': this scope contains no unsafe operations @ $DIR/unsafe-warning.valk:2:5"* ]]; then
    echo "# Wrong unnecessary unsafe warning"
    echo "- Expected: $DIR/unsafe-warning.valk:2:5"
    echo "- Exit code: $unsafe_warn_status"
    echo "$unsafe_warn_out"
    failed=1
fi

count=$((count + 1))
echo "> unsafe outside skipped conditional warns"
unsafe_conditional_out=$("$VALK" build "$DIR/unsafe-conditional.valk" -o "$workdir/unsafe-conditional" 2>&1)
unsafe_conditional_status=$?
if [ "$unsafe_conditional_status" -ne 0 ] || [[ "$unsafe_conditional_out" != *"Unnecessary '@unsafe'"* ]]; then
    echo "# Unsafe outside a skipped conditional did not warn"
    echo "- Exit code: $unsafe_conditional_status"
    echo "$unsafe_conditional_out"
    failed=1
fi

count=$((count + 1))
echo "> unsafe inside skipped conditional does not warn"
unsafe_conditional_scoped_out=$("$VALK" build "$DIR/unsafe-conditional-scoped.valk" -o "$workdir/unsafe-conditional-scoped" 2>&1)
unsafe_conditional_scoped_status=$?
if [ "$unsafe_conditional_scoped_status" -ne 0 ] || [[ "$unsafe_conditional_scoped_out" == *"Unnecessary '@unsafe'"* ]]; then
    echo "# Unsafe inside a skipped conditional emitted a warning"
    echo "- Exit code: $unsafe_conditional_scoped_status"
    echo "$unsafe_conditional_scoped_out"
    failed=1
fi

count=$((count + 1))
echo "> dependency unsafe does not warn"
unsafe_dependency_out=$("$VALK" build "$DIR/unsafe-dependency" -o "$workdir/unsafe-dependency" 2>&1)
unsafe_dependency_status=$?
if [ "$unsafe_dependency_status" -ne 0 ] || [[ "$unsafe_dependency_out" == *"Unnecessary '@unsafe'"* ]]; then
    echo "# Dependency emitted an unnecessary unsafe warning"
    echo "- Exit code: $unsafe_dependency_status"
    echo "$unsafe_dependency_out"
    failed=1
fi

count=$((count + 1))
echo "> generic unsafe use does not warn"
unsafe_generic_out=$("$VALK" build "$DIR/unsafe-generic-warning.valk" -o "$workdir/unsafe-generic-warning" 2>&1)
unsafe_generic_status=$?
if [ "$unsafe_generic_status" -ne 0 ] || [[ "$unsafe_generic_out" == *"Unnecessary '@unsafe'"* ]]; then
    echo "# Generic unsafe use emitted an unnecessary warning"
    echo "- Exit code: $unsafe_generic_status"
    echo "$unsafe_generic_out"
    failed=1
fi

count=$((count + 1))
echo "> failed assertion location"
assert_bin="$workdir/assert-test$EXE_SUFFIX"
assert_build=$("$VALK" build "$DIR/assert.valk" --test --no-warn -o "$assert_bin" 2>&1)
assert_build_status=$?
if [ "$assert_build_status" -ne 0 ]; then
    echo "# Failed to build assertion fixture"
    echo "$assert_build"
    failed=1
else
    assert_out=$("$assert_bin" 2>&1)
    assert_status=$?
    assert_out=$(printf '%s' "$assert_out" | normalize_paths)
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
