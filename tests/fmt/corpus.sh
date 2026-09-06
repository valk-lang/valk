#!/bin/bash

# Formats every source file of the compiler and the standard library in a
# temporary copy. Each file has to format without error and a second pass has
# to leave it unchanged. The formatter itself refuses output whose tokens
# differ from the input, so a pass here means the corpus survives intact.

set -u

VALK="${VALK:-./valk}"
failed=0
count=0

echo ""
echo "# Test --fmt corpus"

if [ ! -x "$VALK" ] && [ ! -f "$VALK" ]; then
    echo "Error: compiler not found: $VALK"
    exit 1
fi

workdir=$(mktemp -d)
case "$(uname -s)" in
    MINGW*|MSYS*) workdir=$(cygpath -m "$workdir") ;;
esac
trap 'rm -rf "$workdir"' EXIT

mkdir -p "$workdir/first" "$workdir/second"
cp -r src "$workdir/first/src"
mkdir -p "$workdir/first/lib"
cp -r lib/src "$workdir/first/lib/src"

while IFS= read -r file; do
    count=$((count + 1))
    set +e
    out=$("$VALK" build "$file" --fmt --no-warn 2>&1)
    status=$?
    set -e
    if [ "$status" -ne 0 ]; then
        echo "# --fmt failed"
        echo "- File: ${file#$workdir/first/}"
        echo "$out"
        failed=1
    fi
done < <(find "$workdir/first" -name '*.valk' | sort)

cp -r "$workdir/first/." "$workdir/second/"

while IFS= read -r file; do
    "$VALK" build "$file" --fmt --no-warn >/dev/null 2>&1 || true
done < <(find "$workdir/second" -name '*.valk' | sort)

if ! diff -ru "$workdir/first" "$workdir/second"; then
    echo "# Formatter is not idempotent on the corpus"
    failed=1
fi

echo ""
if [ "$failed" -ne 0 ]; then
    echo "# Fmt corpus test failed"
    exit 1
fi

echo "# Fmt corpus test passed"
echo "# File count: $count"
echo ""
