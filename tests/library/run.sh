#!/bin/bash

set -u

VALK="${VALK:-./valk}"
DIR="$(cd "$(dirname "$0")" && pwd)"
case "$(uname -s)" in
    MINGW*|MSYS*) DIR="$(cd "$(dirname "$0")" && pwd -W)" ;;
esac

archive_ext=".a"
shared_ext=".so"
exe_ext=""
case "$(uname -s)" in
    Darwin*) shared_ext=".dylib" ;;
    MINGW*|MSYS*) archive_ext=".lib"; shared_ext=".dll"; exe_ext=".exe" ;;
esac

if [ ! -x "$VALK" ] && [ ! -f "$VALK" ]; then
    echo "Error: compiler not found: $VALK"
    exit 1
fi

workdir=$(mktemp -d)
case "$(uname -s)" in
    MINGW*|MSYS*) workdir=$(cygpath -m "$workdir") ;;
esac
trap 'rm -rf "$workdir"' EXIT

cc="${CC:-cc}"
shared="$workdir/libanswer$shared_ext"
static_shared="$workdir/libanswer-static$shared_ext"
archive="$workdir/libanswer-static$archive_ext"
static_archive="$workdir/libanswer-static-deps$archive_ext"
plain_archive="$workdir/libplain$archive_ext"

check_build() {
    local out="$1"
    local label="$2"
    if [ "$status" -ne 0 ]; then
        echo "# Failed to build $label"
        echo "$out"
        exit 1
    fi
}

run_dynamic() {
    case "$(uname -s)" in
        Darwin*) DYLD_LIBRARY_PATH="$workdir${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}" "$1" ;;
        *) LD_LIBRARY_PATH="$workdir${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" "$1" ;;
    esac
}

echo ""
echo "# Test library output modes"

echo "> Reject removed --full-static"
out=$("$VALK" build "$DIR/library.valk" --lib --full-static --no-warn -o "$workdir/invalid" 2>&1)
status=$?
if [ "$status" -eq 0 ] || [[ "$out" != *"Unknown build argument: --full-static"* ]]; then
    echo "# Expected --full-static to be rejected"
    echo "$out"
    exit 1
fi

echo "> Reject static archive output without a library"
out=$("$VALK" build "$DIR/library.valk" --static-lib --no-warn -o "$workdir/invalid" 2>&1)
status=$?
if [ "$status" -eq 0 ] || [[ "$out" != *"'--static-lib' requires '--lib'"* ]]; then
    echo "# Expected --static-lib validation error"
    echo "$out"
    exit 1
fi

if [[ "$(uname -s)" == MINGW* || "$(uname -s)" == MSYS* ]]; then
    echo "> Build dynamic library without main"
    out=$("$VALK" build "$DIR/library.valk" --lib --no-warn -o "$shared" 2>&1)
    status=$?
    check_build "$out" "dynamic library"
    if [ ! -f "$shared" ]; then
        echo "# Dynamic library was not created: $shared"
        exit 1
    fi

    echo "> Build dynamic library with static dependencies"
    out=$("$VALK" build "$DIR/library.valk" --lib --static --no-warn -o "$static_shared" 2>&1)
    status=$?
    check_build "$out" "dynamic library with static dependencies"
    [ -f "$static_shared" ] || exit 1

    echo "> Build static library without main"
    out=$("$VALK" build "$DIR/library.valk" --lib --static-lib --no-warn -o "$archive" 2>&1)
    status=$?
    check_build "$out" "static library"
    "$cc" "$DIR/consumer.c" "$archive" -o "$workdir/consumer-static$exe_ext" || exit $?
    "$workdir/consumer-static$exe_ext" || exit $?

    echo "> Build static library with static dependencies"
    out=$("$VALK" build "$DIR/library.valk" --lib --static-lib --static --no-warn -o "$static_archive" 2>&1)
    status=$?
    check_build "$out" "static library with static dependencies"
    "$cc" "$DIR/consumer.c" "$static_archive" -o "$workdir/consumer-static-deps$exe_ext" || exit $?
    "$workdir/consumer-static-deps$exe_ext" || exit $?

    echo "> Build static library without an FFI export"
    out=$("$VALK" build "$DIR/no-export.valk" --lib --static-lib --no-warn -o "$plain_archive" 2>&1)
    status=$?
    check_build "$out" "ordinary static library"
    [ -f "$plain_archive" ] || exit 1

    echo "# Library tests passed"
    echo "# Test count: 7"
    exit 0
fi

dependency_object="$workdir/answerdep.o"
dependency_static="$workdir/libanswerdep.a"
dependency_shared="$workdir/libanswerdep$shared_ext"
"$cc" -fPIC -c "$DIR/dependency.c" -o "$dependency_object" || exit $?
ar rcs "$dependency_static" "$dependency_object" || exit $?
if [[ "$(uname -s)" == Darwin* ]]; then
    "$cc" -dynamiclib "$dependency_object" -o "$dependency_shared" || exit $?
else
    "$cc" -shared "$dependency_object" -o "$dependency_shared" || exit $?
fi

echo "> Build dynamic library with dynamic dependencies"
out=$("$VALK" build "$DIR/dependency.valk" --lib --no-warn -L "$workdir" -o "$shared" 2>&1)
status=$?
check_build "$out" "dynamic library"
[ -f "$shared" ] || exit 1
"$cc" "$DIR/consumer.c" "$shared" -L "$workdir" -lanswerdep -Wl,-rpath,"$workdir" -o "$workdir/consumer-dynamic" || exit $?
run_dynamic "$workdir/consumer-dynamic" || exit $?

echo "> Build dynamic library with static dependencies"
out=$("$VALK" build "$DIR/dependency.valk" --lib --static --no-warn -L "$workdir" -o "$static_shared" 2>&1)
status=$?
check_build "$out" "dynamic library with static dependencies"
[ -f "$static_shared" ] || exit 1
mv "$dependency_shared" "$dependency_shared.hidden" || exit $?
"$cc" "$DIR/consumer.c" "$static_shared" -o "$workdir/consumer-dynamic-static" || exit $?
run_dynamic "$workdir/consumer-dynamic-static" || exit $?
mv "$dependency_shared.hidden" "$dependency_shared" || exit $?

echo "> Build static library with dynamic dependencies"
out=$("$VALK" build "$DIR/dependency.valk" --lib --static-lib --no-warn -L "$workdir" -o "$archive" 2>&1)
status=$?
check_build "$out" "static library"
[ -f "$archive" ] || exit 1
"$cc" "$DIR/consumer.c" "$archive" -L "$workdir" -lanswerdep -Wl,-rpath,"$workdir" -o "$workdir/consumer-static" || exit $?
run_dynamic "$workdir/consumer-static" || exit $?

echo "> Build static library with static dependencies"
out=$("$VALK" build "$DIR/dependency.valk" --lib --static-lib --static --no-warn -L "$workdir" -o "$static_archive" 2>&1)
status=$?
check_build "$out" "static library with static dependencies"
[ -f "$static_archive" ] || exit 1
if [[ "$(uname -s)" == Darwin* ]] && ar t "$static_archive" | grep -q '^__.SYMDEF'; then
    echo "# Static library contains archive metadata members"
    exit 1
fi
"$cc" "$DIR/consumer.c" "$static_archive" -o "$workdir/consumer-static-deps" || exit $?
"$workdir/consumer-static-deps" || exit $?

echo "> Build static library without an FFI export"
out=$("$VALK" build "$DIR/no-export.valk" --lib --static-lib --no-warn -o "$plain_archive" 2>&1)
status=$?
check_build "$out" "ordinary static library"
if [ ! -f "$plain_archive" ]; then
    echo "# Static library was not created: $plain_archive"
    exit 1
fi
if [ "$archive_ext" = ".a" ] && [ -z "$(ar t "$plain_archive")" ]; then
    echo "# Ordinary static library has no object files"
    exit 1
fi

echo "# Library tests passed"
echo "# Test count: 7"
