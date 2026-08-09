#!/bin/bash

set -u

VALK="${VALK:-./valk}"
DIR="$(cd "$(dirname "$0")" && pwd)"
case "$(uname -s)" in
    MINGW*|MSYS*) DIR="$(cd "$(dirname "$0")" && pwd -W)" ;;
esac

exe_ext=""
case "$(uname -s)" in
    MINGW*|MSYS*) exe_ext=".exe" ;;
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

exe="$workdir/extend-access$exe_ext"

echo ""
echo "# Test extend access modifiers"
echo "> Build public extension member from a dependency package"

out=$("$VALK" build "$DIR" --no-warn -o "$exe" 2>&1)
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Failed to build public extension member fixture"
    echo "$out"
    exit 1
fi

"$exe"
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Extension access fixture returned: $status"
    exit 1
fi

echo "# Extend access tests passed"
echo "# Test count: 1"
