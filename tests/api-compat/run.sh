#!/usr/bin/env bash
# Checks that the public standard-library API is a superset of the last stable release:
# tests/api-compat/baseline.json holds that release's `valk doc` output (see `make api-baseline`)
# and check.valk reports every removal or signature change as a BREAK.
set -u

VALK="${VALK:-./valk}"
DIR="$(cd "$(dirname "$0")" && pwd)"
repo="$(cd "$DIR/../.." && pwd)"
workdir=$(mktemp -d)
case "$(uname -s)" in
    MINGW*|MSYS*) workdir=$(cygpath -m "$workdir") ;;
esac
trap 'rm -rf "$workdir"' EXIT

echo ""
echo "# Test API compatibility with the stable release"

out=$("$VALK" doc "$repo/lib" -o "$workdir/current.json" --no-private --target linux-x64 2>&1)
if [ $? -ne 0 ]; then
    echo "$out"
    exit 1
fi
out=$("$VALK" build "$DIR/check.valk" -o "$workdir/check" --no-warn 2>&1)
if [ $? -ne 0 ]; then
    echo "$out"
    exit 1
fi
"$workdir/check" "$DIR/baseline.json" "$workdir/current.json" "$DIR/allowed-changes.txt"
