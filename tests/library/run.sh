#!/bin/bash

set -u

VALK="${VALK:-./valk}"
DIR="$(cd "$(dirname "$0")" && pwd)"
case "$(uname -s)" in
    MINGW*|MSYS*) DIR="$(cd "$(dirname "$0")" && pwd -W)" ;;
esac

archive_ext=".a"
exe_ext=""
case "$(uname -s)" in
    MINGW*|MSYS*) archive_ext=".lib"; exe_ext=".exe" ;;
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

archive="$workdir/libanswer$archive_ext"
plain_archive="$workdir/libplain$archive_ext"
exe="$workdir/consumer$exe_ext"

echo ""
echo "# Test static library builds"
echo "> Build library without main"

out=$("$VALK" build "$DIR/library.valk" --lib --no-warn -o "$archive" 2>&1)
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Failed to build static library"
    echo "$out"
    exit 1
fi
if [ ! -f "$archive" ]; then
    echo "# Static library was not created: $archive"
    exit 1
fi

echo "> Build library without an FFI export"
out=$("$VALK" build "$DIR/no-export.valk" --lib --no-warn -o "$plain_archive" 2>&1)
status=$?
if [ "$status" -ne 0 ] || [ ! -f "$plain_archive" ]; then
    echo "# Failed to build ordinary static library"
    echo "$out"
    exit 1
fi
if [ "$archive_ext" = ".a" ] && [ -z "$(ar t "$plain_archive")" ]; then
    echo "# Ordinary static library has no object files"
    exit 1
fi

echo "> Link exported function from C"
cc="${CC:-cc}"
out=$("$cc" "$DIR/consumer.c" "$archive" -o "$exe" 2>&1)
status=$?
if [ "$status" -ne 0 ]; then
    echo "# C linker could not resolve the exported Valk symbol"
    echo "$out"
    exit 1
fi

"$exe"
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Linked C consumer returned: $status"
    exit 1
fi

echo "# Static library tests passed"
echo "# Test count: 3"
