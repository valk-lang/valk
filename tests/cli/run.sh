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

debug_out=$(build --debug)
status=$?
if [ "$status" -eq 0 ] || [[ "$debug_out" != *"Unknown build argument: --debug"* ]]; then
    echo "# Expected --debug to be rejected"
    echo "$debug_out"
    exit 1
fi

debug_short_out=$(build -d)
status=$?
if [ "$status" -eq 0 ] || [[ "$debug_short_out" != *"Unknown build argument: -d"* ]]; then
    echo "# Expected -d to be rejected"
    echo "$debug_short_out"
    exit 1
fi

backend_out=$(build --valkir)
status=$?
if [ "$status" -eq 0 ] || [[ "$backend_out" != *"Unknown build argument: --valkir"* ]]; then
    echo "# Expected the removed valkir backend to be rejected"
    echo "$backend_out"
    exit 1
fi

unsafe_input="$DIR/../compile-errors/ce-unsafe-void-pointer-call.valk"
unsafe_out=$("$VALK" build "$unsafe_input" --ignore-unsafe --no-warn -c -o "$output" 2>&1) || {
    echo "# --ignore-unsafe did not allow an unsafe source"
    echo "$unsafe_out"
    exit 1
}

help_out=$("$VALK" build --help 2>&1) || {
    echo "# Build help failed"
    echo "$help_out"
    exit 1
}
if [[ "$help_out" != *"--ignore-unsafe"* ]]; then
    echo "# Build help does not list --ignore-unsafe"
    echo "$help_out"
    exit 1
fi
if [[ "$help_out" != *"--lint"* ]]; then
    echo "# Build help does not list --lint"
    echo "$help_out"
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

lint_input="$DIR/lint-no-main.valk"
lint_out=$("$VALK" build "$lint_input" --lint -v 2>&1) || {
    echo "# --lint did not accept a source without main"
    echo "$lint_out"
    exit 1
}
if [[ "$lint_out" != *"Unnecessary '@unsafe'"* ]] || [[ "$lint_out" != *"Lint passed"* ]]; then
    echo "# --lint did not report lint warnings and success"
    echo "$lint_out"
    exit 1
fi
if [[ "$lint_out" == *"Cache directory:"* ]] || [[ "$lint_out" == *"Compiled in"* ]]; then
    echo "# --lint generated build output"
    echo "$lint_out"
    exit 1
fi

lint_package_out=$("$VALK" build "$DIR/lint-package" --lint 2>&1) || {
    echo "# --lint did not accept a package without main"
    echo "$lint_package_out"
    exit 1
}
if [[ "$lint_package_out" != *"lint-package"* ]] || [[ "$lint_package_out" != *"hidden"* ]] || [[ "$lint_package_out" != *"check.valk"* ]] || [[ "$lint_package_out" != *"Unnecessary '@unsafe'"* ]]; then
    echo "# --lint did not check every package namespace"
    echo "$lint_package_out"
    exit 1
fi

lint_output_out=$("$VALK" build "$lint_input" --lint -o "$output" 2>&1)
status=$?
if [ "$status" -eq 0 ] || [[ "$lint_output_out" != *"'--lint' cannot produce, run, or watch an output"* ]]; then
    echo "# --lint accepted an output path"
    echo "$lint_output_out"
    exit 1
fi

for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    lint_target_out=$("$VALK" build "$lint_input" --lint --target "$target" 2>&1) || {
        echo "# --lint failed for $target"
        echo "$lint_target_out"
        exit 1
    }
    if [[ "$lint_target_out" != *"Unnecessary '@unsafe'"* ]] || [[ "$lint_target_out" != *"Lint passed"* ]]; then
        echo "# --lint did not analyze $target"
        echo "$lint_target_out"
        exit 1
    fi
done

conditional_unsafe_input="$DIR/lint-conditional-unsafe.valk"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    conditional_unsafe_out=$("$VALK" build "$conditional_unsafe_input" --lint --target "$target" 2>&1) || {
        echo "# --lint failed for a target-specific unsafe scope on $target"
        echo "$conditional_unsafe_out"
        exit 1
    }
    if [[ "$conditional_unsafe_out" == *"Unnecessary '@unsafe'"* ]] || [[ "$conditional_unsafe_out" != *"Lint passed"* ]]; then
        echo "# --lint mishandled a target-specific unsafe scope on $target"
        echo "$conditional_unsafe_out"
        exit 1
    fi
done

def_out=$("$VALK" build "$DIR/def-override" --def "OVERRIDE=cli" --no-warn -c -o "$output" 2>&1) || {
    echo "$def_out"
    exit 1
}

echo "# CLI tests passed"
echo "# Test count: 17"
