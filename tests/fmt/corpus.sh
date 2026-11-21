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

# Bounded batches avoid process startup per file and Windows command-line limits.
run_batch() {
    local tree="$1" out
    shift
    if ! out=$("$VALK" build "$@" --fmt --no-warn 2>&1); then
        echo "# --fmt failed in $tree"
        echo "$out"
        failed=1
    fi
}

format_tree() {
    local tree="$1" file
    local batch=()
    while IFS= read -r file; do
        batch+=("$file")
        if [ "${#batch[@]}" -eq 16 ]; then
            run_batch "$tree" "${batch[@]}"
            batch=()
        fi
    done < <(find "$tree" -name '*.valk' | sort)
    if [ "${#batch[@]}" -gt 0 ]; then
        run_batch "$tree" "${batch[@]}"
    fi
}

count=$(( $(find "$workdir/first" -name '*.valk' | wc -l) ))
format_tree "$workdir/first"

cp -r "$workdir/first/." "$workdir/second/"

format_tree "$workdir/second"

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
