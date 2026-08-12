#!/bin/bash

set -u

VALK="${VALK:-./valk}"
DIR="$(cd "$(dirname "$0")" && pwd)"
EXE_SUFFIX=""
case "$(uname -s)" in
    MINGW*|MSYS*) EXE_SUFFIX=".exe" ;;
esac

workdir=$(mktemp -d)
case "$(uname -s)" in
    MINGW*|MSYS*) workdir=$(cygpath -m "$workdir") ;;
esac
trap 'rm -rf "$workdir"' EXIT

input="$DIR/../exit-code/void-main.valk"
output="$workdir/cli-test$EXE_SUFFIX"

cache_dir() {
    printf "%s\n" "$1" | sed -n 's/^.*Cache directory: //p' | tail -n 1
}

build() {
    "$VALK" build "$input" --no-warn -v -c -o "$output" "$@" 2>&1
}

echo ""
echo "# Test build optimization flags"

default_out=$(build) || { echo "$default_out"; exit 1; }
opt_out=$(build --opt) || { echo "$opt_out"; exit 1; }
release_out=$(build --release) || { echo "$release_out"; exit 1; }

default_cache=$(cache_dir "$default_out")
opt_cache=$(cache_dir "$opt_out")
release_cache=$(cache_dir "$release_out")
if [ -z "$default_cache" ] || [ -z "$opt_cache" ] || [ -z "$release_cache" ]; then
    echo "# Missing cache directory output"
    exit 1
fi
if [ "$default_cache" = "$opt_cache" ]; then
    echo "# Default builds unexpectedly enable optimization"
    exit 1
fi
if [ "$opt_cache" != "$release_cache" ]; then
    echo "# --release did not enable optimization"
    exit 1
fi

no_opt_out=$(build --no-opt)
status=$?
if [ "$status" -eq 0 ] || [[ "$no_opt_out" != *"Unknown build argument: --no-opt"* ]]; then
    echo "# Expected --no-opt to be rejected"
    echo "$no_opt_out"
    exit 1
fi

validate_out=$("$VALK" build "$input" --no-warn -v -c 2>&1) || {
    echo "$validate_out"
    exit 1
}
if [[ "$validate_out" == *"Cache directory:"* ]]; then
    echo "# A build without an output path generated an object or executable"
    echo "$validate_out"
    exit 1
fi

echo "# CLI tests passed"
echo "# Test count: 5"
