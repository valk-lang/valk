#!/bin/bash

set -u

VALK="${VALK:-./valk}"
DIR="$(cd "$(dirname "$0")" && pwd)"
EXE_SUFFIX=""
case "$(uname -s)" in
    MINGW*|MSYS*) EXE_SUFFIX=".exe" ;;
esac

if command -v timeout >/dev/null 2>&1; then
    TIMEOUT="timeout 120"
elif command -v gtimeout >/dev/null 2>&1; then
    TIMEOUT="gtimeout 120"
else
    TIMEOUT=""
fi

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

check_stat() {
    local text="$1" label="$2" suffix="$3" line value
    local pattern="^[0-9]+\.[0-9]{2}${suffix}$"
    local found=0
    while IFS= read -r line; do
        if [[ "$line" != *"$label"* ]]; then continue; fi
        found=1
        value=${line#*"$label"}
        value=${value%$'\r'}
        if [[ ! "$value" =~ $pattern ]]; then
            echo "# Expected exactly two decimals: $line"
            exit 1
        fi
    done <<< "$text"
    if [ "$found" -eq 0 ]; then
        echo "# Missing statistic: $label"
        echo "$text"
        exit 1
    fi
}

check_stats() {
    local file_loc parse_loc
    file_loc=$(loc_value "$1" File)
    parse_loc=$(loc_value "$1" Parse)
    if [[ ! "$file_loc" =~ ^[0-9]+$ || ! "$parse_loc" =~ ^[0-9]+$ ]] \
        || [ "$file_loc" -eq 0 ] || [ "$parse_loc" -lt "$file_loc" ]; then
        echo "# Invalid File LOC / Parse LOC statistics"
        echo "$1"
        exit 1
    fi
    check_stat "$1" "Function AST + IR: " "s"
    check_stat "$1" "Object generation: " "s"
    check_stat "$1" "Linking: " "s"
    check_stat "$1" "Compiler memory usage: " " mb"
}

loc_value() {
    printf '%s\n' "$1" | sed -n "s/^.*$2 LOC: \([0-9][0-9]*\).*$/\1/p"
}

echo ""
echo "# Test build optimization flags"

default_out=$(build) || { echo "$default_out"; exit 1; }
opt_out=$(build --opt) || { echo "$opt_out"; exit 1; }
release_out=$(build --release) || { echo "$release_out"; exit 1; }

for stats_out in "$default_out" "$opt_out" "$release_out"; do
    check_stats "$stats_out"
    check_stat "$stats_out" "Compiled in " "s"
done

object_out=$("$VALK" build "$input" --no-warn -vvv --clean -o "$output" 2>&1) || {
    echo "$object_out"
    exit 1
}
check_stats "$object_out"
check_stat "$object_out" "Object task: " "ms: .+"
check_stat "$object_out" "Compiled in " "s"

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

echo "> Reopening the object-cache lock preserves its contents"
lock_file="$default_cache/cache.lock"
if [ ! -f "$lock_file" ]; then
    echo "# Build did not create its cache lock"
    exit 1
fi
printf '%s' 'preserve-cache-lock' > "$lock_file"
lock_out=$(build) || { echo "$lock_out"; exit 1; }
if [ "$(cat "$lock_file")" != 'preserve-cache-lock' ]; then
    echo "# Reopening the cache lock truncated its contents"
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
if [ "$status" -ne 0 ]; then
    echo "# Expected --debug to build"
    echo "$debug_out"
    exit 1
fi

debug_short_out=$(build -d)
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Expected -d to build"
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
check_stats "$lint_out"
if [[ "$lint_out" != *"Object generation: 0.00s"* ]] || [[ "$lint_out" != *"Linking: 0.00s"* ]]; then
    echo "# Zero-duration statistics must retain two decimals"
    echo "$lint_out"
    exit 1
fi
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

for filter in clone other; do
    clone_out=$("$VALK" build "$DIR/clone-summary.valk" --test --filter "$filter" --no-warn -o "$output" 2>&1) || {
        echo "# Clone freshness changed with test selection: $filter"
        echo "$clone_out"
        exit 1
    }
    "$output" || exit 1
done

first_offset=$(grep -bo 'return fn' "$DIR/closure-layouts/first.valk")
other_offset=$(grep -bo 'return fn' "$DIR/closure-layouts/other.valk")
if [[ -z "$first_offset" || "$first_offset" != "$other_offset" ]]; then
    echo "# Closure layout regression must use matching source offsets"
    exit 1
fi
for mode in debug release; do
    flags=()
    if [ "$mode" = release ]; then flags+=(--release); fi
    closure_out=$("$VALK" build "$DIR"/closure-layouts/*.valk ${flags[@]+"${flags[@]}"} --def GC_DEBUG=1 --no-warn -o "$output" 2>&1) || {
        echo "# Failed to build closures with colliding source offsets: $mode"
        echo "$closure_out"
        exit 1
    }
    closure_out=$("$output" 2>&1) || {
        echo "# Closure capture layouts were not independent: $mode"
        echo "$closure_out"
        exit 1
    }
    if [[ "$closure_out" != *"closure layouts OK"* ]]; then
        echo "# Closure layout regression did not finish: $mode"
        echo "$closure_out"
        exit 1
    fi
done

for mode in debug release; do
    flags=()
    if [ "$mode" = release ]; then flags+=(--release); fi
    flags_out=$("$VALK" build "$DIR/optimization-flags.valk" ${flags[@]+"${flags[@]}"} --def GC_DEBUG=1 --no-warn -o "$output" 2>&1) || {
        echo "# Failed to build optimization flags: $mode"
        echo "$flags_out"
        exit 1
    }
    flags_out=$("$output" 2>&1) || {
        echo "# Optimization flags did not preserve behavior: $mode"
        echo "$flags_out"
        exit 1
    }
    if [[ "$flags_out" != *"optimization flags OK"* ]]; then
        echo "# Optimization flag regression did not finish: $mode"
        echo "$flags_out"
        exit 1
    fi
done

echo "> Nonreturning operands stop compound expression evaluation"
for mode in default release; do
    termination_flags=()
    if [ "$mode" = release ]; then termination_flags+=(--release); fi
    termination_exe="$workdir/nonreturning-expressions$EXE_SUFFIX"
    if ! "$VALK" build "$DIR/nonreturning-expressions.valk" --no-warn ${termination_flags[@]+"${termination_flags[@]}"} -o "$termination_exe"; then
        exit 1
    fi
    for case in argument conditional-argument closure-argument fnptr-argument binary-left binary-right unary cast field inline array slice if while property index store receiver inline-receiver interface-receiver interface-wrap bound-method multi partial-multi discarded-multi closure fnptr fnptr-wrap isset match match-condition error co co-body await vscope void-argument void-closure-argument void-fnptr-argument void-let void-assign void-return void-vscope void-error-fallback fnptr-callee-argument co-callee-argument; do
        termination_out=$("$termination_exe" "$case" 2>&1)
        termination_status=$?
        if [ "$termination_status" -ne 1 ] || [[ "$termination_out" != *"Nonreturning operand reached"* || "$termination_out" == *"Later operand ran"* ]]; then
            echo "# Nonreturning operand failed: $mode $case (exit $termination_status)"
            echo "$termination_out"
            exit 1
        fi
        case "$case" in
            co-body)
                if [[ "$termination_out" != *"caller continued"* ]]; then
                    echo "# Coroutine body exit suppressed its caller: $mode"
                    echo "$termination_out"
                    exit 1
                fi
                ;;
            argument|conditional-argument|closure-argument|fnptr-argument|binary-right|inline|array|multi|partial-multi|discarded-multi|co|void-argument|void-closure-argument|void-fnptr-argument)
                if [ "$(grep -c '^before operand' <<< "$termination_out")" -ne 1 ]; then
                    echo "# Earlier operand did not run exactly once: $mode $case"
                    echo "$termination_out"
                    exit 1
                fi
                ;;
        esac
    done
done

echo "> Reject cleared callback and inline slots through every read API"
for mode in default release; do
    cleared_flags=()
    if [ "$mode" = release ]; then cleared_flags+=(--release); fi
    cleared_exe="$workdir/cleared-views$EXE_SUFFIX"
    if ! "$VALK" build "$DIR/cleared-views.valk" --no-warn ${cleared_flags[@]+"${cleared_flags[@]}"} -o "$cleared_exe"; then
        exit 1
    fi
    for case in callback callback-get callback-each pointer inline inline-get inline-each nested mode fixed union interface borrow slice string borrowed-field borrowed-method borrowed-bound borrowed-nested borrowed-callback borrowed-interface borrowed-fixed borrowed-union partial-struct partial-nested-field partial-fixed enum enum-get enum-each enum-borrowed; do
        cleared_out=$("$cleared_exe" "$case" 2>&1)
        cleared_status=$?
        if [ "$cleared_status" -ne 1 ] || [[ "$cleared_out" != *"Empty element: the storage holds no value"* ]]; then
            echo "# Cleared view read failed: $mode $case (exit $cleared_status)"
            echo "$cleared_out"
            exit 1
        fi
    done
done

echo "> Reject invalid values in exhaustive enum matches"
for mode in default release; do
    enum_flags=()
    if [ "$mode" = release ]; then enum_flags+=(--release); fi
    enum_exe="$workdir/enum-matches$EXE_SUFFIX"
    if ! "$VALK" build "$DIR/enum-matches.valk" --no-warn ${enum_flags[@]+"${enum_flags[@]}"} -o "$enum_exe"; then
        exit 1
    fi
    for case in statement value; do
        enum_out=$("$enum_exe" "$case" 2>&1)
        enum_status=$?
        if [ "$enum_status" -ne 1 ] || [[ "$enum_out" != *"Invalid enum value in exhaustive match"* || "$enum_out" == *"invalid arm ran"* ]]; then
            echo "# Invalid enum match failed: $mode $case (exit $enum_status)"
            echo "$enum_out"
            exit 1
        fi
    done
done

echo "> Report a missing or invalid main before lowering the entry template"
no_main_out=$("$VALK" build "$lint_input" --no-warn -o "$output" 2>&1)
if [ $? -eq 0 ] || [[ "$no_main_out" != *"No 'main' function found in: "*"lint-no-main.valk"* ]] || [[ "$no_main_out" == *"templates"* ]]; then
    echo "# Missing main was not reported on the input"
    echo "$no_main_out"
    exit 1
fi
printf 'class main {}\n' > "$workdir/class-main.valk"
class_main_out=$("$VALK" build "$workdir/class-main.valk" --no-warn -o "$output" 2>&1)
if [ $? -eq 0 ] || [[ "$class_main_out" != *"'main' must be a function"* ]]; then
    echo "# A non-function main was not reported"
    echo "$class_main_out"
    exit 1
fi

echo "> Options that take a value reject a missing value"
for option in -o --target --filter -L --def; do
    missing_out=$("$VALK" build "$input" --no-warn "$option" 2>&1)
    if [ $? -eq 0 ] || [[ "$missing_out" != *"Option '$option' expects a value"* ]]; then
        echo "# Missing value for $option was accepted"
        echo "$missing_out"
        exit 1
    fi
done
missing_out=$("$VALK" build "$input" --no-warn -o --run 2>&1)
if [ $? -eq 0 ] || [[ "$missing_out" != *"Option '-o' expects a value"* ]]; then
    echo "# A flag was taken as the value of -o"
    echo "$missing_out"
    exit 1
fi

echo "> A repeated option keeps its last value"
out=$("$VALK" build "$input" --no-warn -o "$workdir/first$EXE_SUFFIX" -o "$workdir/last$EXE_SUFFIX" 2>&1)
if [ ! -f "$workdir/last$EXE_SUFFIX" ] || [ -f "$workdir/first$EXE_SUFFIX" ]; then
    echo "# The last -o should win"
    echo "$out"
    exit 1
fi

echo "> -o creates missing directories"
out=$("$VALK" build "$input" --no-warn -o "$workdir/new/sub/app$EXE_SUFFIX" 2>&1)
if [ ! -f "$workdir/new/sub/app$EXE_SUFFIX" ]; then
    echo "# The output directory was not created"
    echo "$out"
    exit 1
fi

echo "> A panic writes to stderr"
"$VALK" build "$DIR/../exit-code/panic-line.valk" --no-warn -o "$workdir/panic-line$EXE_SUFFIX" >/dev/null 2>&1
panic_stdout=$("$workdir/panic-line$EXE_SUFFIX" 2>/dev/null)
panic_stderr=$("$workdir/panic-line$EXE_SUFFIX" 2>&1 >/dev/null)
if [ -n "$panic_stdout" ] || [[ "$panic_stderr" != *"Explicit panic at"* ]]; then
    echo "# The panic message belongs on stderr: stdout '$panic_stdout', stderr '$panic_stderr'"
    exit 1
fi

echo "> Compile errors write to stderr"
error_stdout=$("$VALK" build "$DIR/../compile-errors/ce-default-uses-param.valk" --no-warn 2>/dev/null)
error_stderr=$("$VALK" build "$DIR/../compile-errors/ce-default-uses-param.valk" --no-warn 2>&1 >/dev/null)
if [ -n "$error_stdout" ] || [[ "$error_stderr" != *"# Error: "* ]]; then
    echo "# The compile error belongs on stderr: stdout '$error_stdout', stderr '$error_stderr'"
    exit 1
fi

echo "> ansi.supported needs a terminal unless forced, and respects NO_COLOR"
"$VALK" build "$DIR/no-color.valk" --no-warn -o "$workdir/no-color$EXE_SUFFIX" >/dev/null 2>&1
piped=$(TERM=xterm NO_COLOR= FORCE_COLOR= CLICOLOR_FORCE= "$workdir/no-color$EXE_SUFFIX" 2>&1 | tr -d '\r')
forced=$(TERM=xterm NO_COLOR= FORCE_COLOR=1 "$workdir/no-color$EXE_SUFFIX" 2>&1 | tr -d '\r')
plain=$(TERM=xterm NO_COLOR=1 FORCE_COLOR=1 "$workdir/no-color$EXE_SUFFIX" 2>&1 | tr -d '\r')
if [ "$piped" != "false" ] || [ "$forced" != "true" ] || [ "$plain" != "false" ]; then
    echo "# Color detection is wrong: piped '$piped', forced '$forced', NO_COLOR '$plain'"
    exit 1
fi

echo "> The target list in --help matches the invalid target message"
help_targets=$("$VALK" build --help | grep -A1 -- '--target' | tail -n 1 | sed 's/^ *//')
invalid_targets=$("$VALK" build "$input" --target nope 2>&1 | sed -n 's/^Supported: //p')
if [ -z "$help_targets" ] || [ "$help_targets" != "$invalid_targets" ]; then
    echo "# Target lists differ: help '$help_targets' vs error '$invalid_targets'"
    exit 1
fi

echo "> valk completion prints a script for bash, zsh and fish"
for shell in bash zsh fish; do
    script=$("$VALK" completion $shell) || { echo "# valk completion $shell failed"; exit 1; }
    if [[ "$script" != *"make ls doc fmt"* ]] || [[ "$script" != *"ls --names"* ]]; then
        echo "# valk completion $shell must complete the commands and the make names"
        exit 1
    fi
done
if command -v bash >/dev/null && ! "$VALK" completion bash | bash -n; then
    echo "# The bash completion script has a syntax error"
    exit 1
fi
# Every option of 'valk build -h' is completed
build_script=$("$VALK" completion bash)
for option in $("$VALK" build --help | grep -oE '^  (-[a-zA-Z-]+( -[a-zA-Z-]+)*)' ); do
    if [[ " $build_script " != *" $option "* ]] && [[ "$build_script" != *" $option\""* ]]; then
        echo "# The completion scripts miss the build option $option"
        exit 1
    fi
done
if "$VALK" completion nope >/dev/null 2>&1; then
    echo "# valk completion with an unknown shell must fail"
    exit 1
fi

echo "> valk fmt formats files in place"
printf 'fn main() {\n  let  x = 1\n}\n' > "$workdir/fmt.valk"
fmt_out=$("$VALK" fmt "$workdir/fmt.valk" 2>&1) || {
    echo "# valk fmt failed"
    echo "$fmt_out"
    exit 1
}
if ! grep -q '^    let x = 1$' "$workdir/fmt.valk"; then
    echo "# valk fmt did not format the file"
    cat "$workdir/fmt.valk"
    exit 1
fi
if [[ "$fmt_out" != *"fmt.valk"* ]] || [[ "$fmt_out" != *"Formatted 1 file"* ]] || [[ "$fmt_out" == *"Compiled in"* ]]; then
    echo "# valk fmt should list the changed file"
    echo "$fmt_out"
    exit 1
fi
fmt_again=$("$VALK" fmt "$workdir/fmt.valk" 2>&1)
if [[ "$fmt_again" != *"Already formatted"* ]]; then
    echo "# A formatted file should be reported as such"
    echo "$fmt_again"
    exit 1
fi

echo "> A --filter that matches no test fails"
filter_out=$("$VALK" build "$DIR/../diagnostics/assert.valk" --test --filter nomatch -o "$workdir/nomatch$EXE_SUFFIX" 2>&1)
filter_code=$?
if [ "$filter_code" -eq 0 ] || [[ "$filter_out" != *"No test name contains 'nomatch'"* ]]; then
    echo "# --filter without a match must fail"
    echo "$filter_out"
    exit 1
fi

echo "> valk run hints at -- for program arguments"
run_out=$("$VALK" run "$input" alice 2>&1)
if [[ "$run_out" != *"Arguments for the program go after '--'"* ]]; then
    echo "# valk run with a stray argument should point at '--'"
    echo "$run_out"
    exit 1
fi

echo "> valk fmt --check lists unformatted files and writes nothing"
printf 'fn main() {\n  let  y = 2\n}\n' > "$workdir/check.valk"
cp "$workdir/check.valk" "$workdir/check.orig"
check_out=$("$VALK" fmt "$workdir/check.valk" --check 2>&1)
check_code=$?
if [ "$check_code" -ne 1 ] || [[ "$check_out" != *"check.valk"* ]] || ! cmp -s "$workdir/check.valk" "$workdir/check.orig"; then
    echo "# valk fmt --check must fail without writing (exit $check_code)"
    echo "$check_out"
    exit 1
fi
"$VALK" fmt "$workdir/check.valk" >/dev/null 2>&1
if ! "$VALK" fmt "$workdir/check.valk" --check >/dev/null 2>&1; then
    echo "# valk fmt --check must pass on a formatted file"
    exit 1
fi

echo "> valk --version"
if [[ "$("$VALK" --version 2>&1)" != "valk-"* ]]; then
    echo "# valk --version must print the version"
    exit 1
fi

echo "> Command help and unknown commands"
if [[ "$("$VALK" fmt -h 2>&1)" != *"Usage: valk fmt"* ]] || [[ "$("$VALK" make -h 2>&1)" != *"Usage: valk make"* ]]; then
    echo "# valk fmt -h and valk make -h need their own help"
    exit 1
fi
unknown_out=$("$VALK" nope 2>&1)
unknown_code=$?
if [ "$unknown_code" -ne 1 ] || [[ "$unknown_out" != *"Unknown command 'nope'"* ]] || [[ "$("$VALK" -h)" != *"valk lsp"* ]]; then
    echo "# An unknown command must say so"
    echo "$unknown_out"
    exit 1
fi

echo "> Concurrent builds never fail on the IR cache"
concurrent_pids=()
for i in 1 2 3 4 5 6; do
    printf 'fn main() {\n    println("build %s")\n}\n' "$i" > "$workdir/concurrent-$i.valk"
    "$VALK" build "$workdir/concurrent-$i.valk" --no-warn -c -o "$workdir/concurrent-$i$EXE_SUFFIX" > "$workdir/concurrent-$i.log" 2>&1 &
    concurrent_pids+=($!)
done
concurrent_failed=0
for pid in "${concurrent_pids[@]}"; do
    wait "$pid" || concurrent_failed=1
done
if [ "$concurrent_failed" -ne 0 ]; then
    echo "# A concurrent build failed"
    cat "$workdir"/concurrent-*.log
    exit 1
fi
for i in 1 2 3 4 5 6; do
    if [ "$("$workdir/concurrent-$i$EXE_SUFFIX")" != "build $i" ]; then
        echo "# Concurrent build produced a wrong program: $i"
        exit 1
    fi
done

echo "> Compile generated deep and long inputs"
repeat() { printf "%.0s$1" $(seq 1 "$2"); }
deep_src="$workdir/deep.valk"
deep_exe="$workdir/deep$EXE_SUFFIX"
build_deep() {
    local expected="$1"
    if ! $TIMEOUT "$VALK" build "$deep_src" --no-warn -o "$deep_exe"; then
        echo "# Generated input failed to compile: $deep_src"
        exit 1
    fi
    deep_out=$("$deep_exe" 2>&1)
    if [ "$deep_out" != "$expected" ]; then
        echo "# Generated input printed '$deep_out', expected '$expected'"
        exit 1
    fi
}
echo "fn main() { let a = 1$(repeat ' + 1' 5000) println(a) }" > "$deep_src"
build_deep 5001
echo "fn main() { let a = 1$(repeat ' + 2 * 3 - 4 / 2' 2000) println(a) }" > "$deep_src"
build_deep 8001
echo "fn main() { let a = \"x\"$(repeat ' + "y"' 5000) println(a.length) }" > "$deep_src"
build_deep 5001
echo "fn main() { let a = $(repeat '(' 500)1$(repeat ')' 500) println(a) }" > "$deep_src"
build_deep 1
echo "fn main() { $(repeat '{ ' 500)println(1)$(repeat ' }' 500) }" > "$deep_src"
build_deep 1
echo "struct Big { data: [u8 x 100000] } fn main() { let b = Big{} let a: [u8 x 100000] = { 7... } println(b.data[5] + a[99999]) }" > "$deep_src"
build_deep 7
cat > "$deep_src" <<'EOF'
class FlagTest {
    value: int (0)
}
fn flag_inline(value: int) int $inline { return value + 1 }
fn flag_plain(value: int) int { return value + 2 }
fn main() {
    let item = FlagTest { value: 12 }
    println(flag_inline(flag_plain(item.value)))
}
EOF
build_deep 15
for form in paren block call index ternary; do
    case "$form" in
        paren) echo "fn main() { let a = $(repeat '(' 3000)1$(repeat ')' 3000) println(a) }" > "$deep_src" ;;
        block) echo "fn main() { $(repeat '{ ' 3000)println(1)$(repeat ' }' 3000) }" > "$deep_src" ;;
        call) echo "fn f(x: int) int { return x } fn main() { let a = $(repeat 'f(' 3000)1$(repeat ')' 3000) println(a) }" > "$deep_src" ;;
        index) echo "fn main() { let s = [int x 2]{ 0, 1 } let a = $(repeat 's[' 3000)0$(repeat ']' 3000) println(a) }" > "$deep_src" ;;
        ternary) echo "fn main() { let a = $(repeat 'true ? 1 : ' 3000)2 println(a) }" > "$deep_src" ;;
    esac
    deep_out=$($TIMEOUT "$VALK" build "$deep_src" --no-warn -o "$deep_exe" 2>&1)
    deep_status=$?
    if [ "$deep_status" -ne 1 ] || [[ "$deep_out" != *"nesting too deep"* ]]; then
        echo "# Deep $form input did not report its nesting (exit $deep_status)"
        echo "$deep_out" | cut -c1-200
        exit 1
    fi
done

echo "> File LOC and Parse LOC count generic instances and function reparses"
loc_dir="$workdir/loc"
mkdir -p "$loc_dir"
loc_base=$("$VALK" build "$DIR/loc-generics.valk" --lint --no-warn -v 2>&1) || { echo "$loc_base"; exit 1; }
check_stats "$loc_base"
for ending in crlf no-final-newline; do
    case "$ending" in
        crlf) awk '{ printf "%s\r\n", $0 }' "$DIR/loc-generics.valk" > "$loc_dir/$ending.valk" ;;
        no-final-newline) printf '%s' "$(cat "$DIR/loc-generics.valk")" > "$loc_dir/$ending.valk" ;;
    esac
    loc_out=$("$VALK" build "$loc_dir/$ending.valk" --lint --no-warn -v 2>&1) || { echo "$loc_out"; exit 1; }
    check_stats "$loc_out"
    if [ "$(loc_value "$loc_out" File)" -ne "$(loc_value "$loc_base" File)" ] \
        || [ "$(loc_value "$loc_out" Parse)" -ne "$(loc_value "$loc_base" Parse)" ]; then
        echo "# Line endings changed LOC counts: $ending"
        echo "$loc_base"
        echo "$loc_out"
        exit 1
    fi
done
for kind in class function ordinary; do
    case "$kind" in
        class) pattern='    value: T'; extra=3 ;;
        function) pattern='    return value'; extra=3 ;;
        ordinary) pattern='    let a'; extra=1 ;;
    esac
    awk -v pattern="$pattern" 'index($0, pattern) == 1 { print "" } { print }' "$DIR/loc-generics.valk" > "$loc_dir/$kind.valk"
    loc_out=$("$VALK" build "$loc_dir/$kind.valk" --lint --no-warn -v 2>&1) || { echo "$loc_out"; exit 1; }
    check_stats "$loc_out"
    if [ "$(loc_value "$loc_out" File)" -ne "$(( $(loc_value "$loc_base" File) + 1 ))" ] \
        || [ "$(loc_value "$loc_out" Parse)" -ne "$(( $(loc_value "$loc_base" Parse) + extra ))" ]; then
        echo "# Incorrect LOC delta for $kind"
        echo "$loc_base"
        echo "$loc_out"
        exit 1
    fi
done

loc_base=$("$VALK" build "$DIR/loc-reparse.valk" --no-warn -v -o "$loc_dir/reparse$EXE_SUFFIX" 2>&1) || { echo "$loc_base"; exit 1; }
awk '/^    return Item/ { print "" } { print }' "$DIR/loc-reparse.valk" > "$loc_dir/reparse.valk"
loc_out=$("$VALK" build "$loc_dir/reparse.valk" --no-warn -v -o "$loc_dir/reparse$EXE_SUFFIX" 2>&1) || { echo "$loc_out"; exit 1; }
check_stats "$loc_base"
check_stats "$loc_out"
if [ "$(loc_value "$loc_out" File)" -ne "$(( $(loc_value "$loc_base" File) + 1 ))" ] \
    || [ "$(loc_value "$loc_out" Parse)" -ne "$(( $(loc_value "$loc_base" Parse) + 2 ))" ]; then
    echo "# Function reparses must add their declaration LOC again"
    echo "$loc_base"
    echo "$loc_out"
    exit 1
fi

deprecated_out=$("$VALK" build "$DIR/deprecated.valk" --lint 2>&1) || {
    echo "# --lint rejected a call to a deprecated function"
    echo "$deprecated_out"
    exit 1
}
if [[ "$deprecated_out" != *"'equal_bytes' is deprecated: old name of \`equals_bytes\`, kept because 0.7.0 shipped it."* ]] \
    || [[ "$deprecated_out" == *"'stale' is deprecated"* ]]; then
    echo "# A deprecated function must warn from another package and stay quiet in its own"
    echo "$deprecated_out"
    exit 1
fi

quiet_deprecated_out=$("$VALK" build "$DIR/deprecated.valk" --lint --no-warn-deprecated 2>&1) || {
    echo "# --no-warn-deprecated rejected the build"
    echo "$quiet_deprecated_out"
    exit 1
}
if [[ "$quiet_deprecated_out" == *"is deprecated"* ]] || [[ "$quiet_deprecated_out" != *"Variable 'unused' was declared but never used"* ]] || [[ "$quiet_deprecated_out" != *"Lint passed"* ]]; then
    echo "# --no-warn-deprecated must drop only the deprecation warnings"
    echo "$quiet_deprecated_out"
    exit 1
fi

# An unreachable break or continue is reported, and must not change the divergence analysis
divergence_out=$("$VALK" build "$DIR/divergence.valk" -o "$output" --run 2>&1) || {
    echo "# The divergence program failed to build or run"
    echo "$divergence_out"
    exit 1
}
if [ "$(printf '%s' "$divergence_out" | grep -c "Unreachable code")" -ne 2 ] || [[ "$divergence_out" != *"divergence ok"* ]]; then
    echo "# Expected two unreachable-code warnings and a successful run"
    echo "$divergence_out"
    exit 1
fi

echo ""
echo "# Test the make commands a project declares"

# The project is built from another directory, so the compiler needs its full path
VALK_BIN="$VALK"
if [ -e "$VALK" ]; then
    VALK_BIN="$(cd "$(dirname "$VALK")" && pwd)/$(basename "$VALK")"
fi

host_os=linux
other_os=macos
case "$(uname -s)" in
    Darwin) host_os=macos; other_os=linux ;;
    MINGW*|MSYS*|CYGWIN*) host_os=win; other_os=linux ;;
esac

project="$workdir/declared"
mkdir -p "$project/src"
cat > "$project/valk.json" <<'JSON'
{
    "make": {
        "hello": { "dir": "src", "global": true },
        "dev": { "dir": "src", "args": "--def \"DEV=1\"" },
        "greet": "echo greeting",
        "broken": ["echo first", "exit 3", "echo never"]
    }
}
JSON
cat > "$project/src/main.valk" <<'VALK'
fn main(args: Array[String]) {
    #if is_defined(DEV)
    print("dev: ")
    #end
    println("hello " + (args.get(1) !? "world"))
}
VALK

ls_out=$(cd "$project" && TERM=xterm "$VALK_BIN" ls 2>&1)
if [[ "$ls_out" == *$'\e'* ]]; then
    echo "# 'valk ls' must not write colors into a pipe"
    exit 1
fi
if [[ "$ls_out" != *"Make commands:"* ]] || [[ "$ls_out" != *"global"* ]] || [[ "$ls_out" != *"default"* ]] \
    || [[ "$ls_out" != *"greet"* ]] || [[ "$ls_out" != *"build src"* ]]; then
    echo "# 'valk ls' must list the make commands, and mark the global and default ones"
    echo "$ls_out"
    exit 1
fi

# One make command shows what it does
one_out=$(cd "$project" && "$VALK_BIN" ls dev 2>&1)
if [[ "$one_out" != *"valk build src"* ]] || [[ "$one_out" != *'--def "DEV=1"'* ]]; then
    echo "# 'valk ls {name}' must show what the make command does"
    echo "$one_out"
    exit 1
fi
names_out=$(cd "$project" && "$VALK_BIN" ls --names 2>&1 | tr -d '\r' | tr '\n' ' ')
if [[ "$names_out" != *"dev greet broken"* ]]; then
    echo "# 'valk ls --names' must print one make command per line, for shell completion"
    echo "$names_out"
    exit 1
fi
unknown_ls=$(cd "$project" && "$VALK_BIN" ls nope 2>&1)
if [[ "$unknown_ls" != *"no make command named 'nope'"* ]]; then
    echo "# 'valk ls {name}' must report a name that is not there"
    echo "$unknown_ls"
    exit 1
fi

# A target with a directory is built, with its own arguments
named_out=$(cd "$project" && "$VALK_BIN" make dev --run -- Ada 2>&1)
if [[ "$named_out" != *"dev: hello Ada"* ]]; then
    echo "# 'valk make dev --run -- Ada' must build with the declared arguments and pass Ada on"
    echo "$named_out"
    exit 1
fi

# Without a name the first make command is run
default_out=$(cd "$project" && "$VALK_BIN" make --run 2>&1)
if [[ "$default_out" != *"hello world"* ]] || [[ "$default_out" == *"dev: "* ]]; then
    echo "# 'valk make' must run the first make command"
    echo "$default_out"
    exit 1
fi

# A make command that is a line is run, with what follows '--' appended as one argument.
# `echo` keeps the quotes on Windows and drops them in a shell, so both spellings pass.
command_out=$(cd "$project" && "$VALK_BIN" make greet -- "two words" 2>&1)
if [[ "$command_out" != *"greeting two words"* ]] && [[ "$command_out" != *'greeting "two words"'* ]]; then
    echo "# 'valk make greet -- \"two words\"' must run the command with its argument"
    echo "$command_out"
    exit 1
fi

# A failing line stops the command and is named
broken_out=$(cd "$project" && "$VALK_BIN" make broken 2>&1)
broken_code=$?
if [ "$broken_code" -ne 3 ] || [[ "$broken_out" == *"never"* ]] || { [ "$host_os" != "win" ] && [[ "$broken_out" != *"failed with exit code 3 at: exit 3"* ]]; }; then
    echo "# A failing make line must stop the command and be reported (exit $broken_code)"
    echo "$broken_out"
    exit 1
fi

# build and run take paths, and point at make for a target
target_build_out=$(cd "$project" && "$VALK_BIN" build greet 2>&1)
if [[ "$target_build_out" != *"is a make command of this project, run it with: valk make greet"* ]]; then
    echo "# Building a make command must point at 'valk make'"
    echo "$target_build_out"
    exit 1
fi
path_run_out=$(cd "$project" && "$VALK_BIN" run ./src -- Ada 2>&1)
if [[ "$path_run_out" != *"hello Ada"* ]]; then
    echo "# 'valk run ./src' must still build and run a path"
    echo "$path_run_out"
    exit 1
fi

# An unknown make command says what to look at
unknown_out=$(cd "$project" && "$VALK_BIN" make nope 2>&1)
if [[ "$unknown_out" != *"no make command named 'nope'"* ]]; then
    echo "# An unknown make command must be reported"
    echo "$unknown_out"
    exit 1
fi

# What `define` says is filled in, and the rest is left for the shell
cat > "$project/valk.json" <<'JSON'
{
    "define": { "VERSION": "1.2.3" },
    "make": {
        "show": "echo version=$VERSION braced=${VERSION} missing=[$NOPE] shell=$(echo sub)",
        "app": { "dir": "src", "args": "-o ./app-$VERSION" }
    }
}
JSON
defines_out=$(cd "$project" && "$VALK_BIN" make show 2>&1)
if [[ "$defines_out" != *"version=1.2.3 braced=1.2.3"* ]]; then
    echo "# A make command must use what 'define' says"
    echo "$defines_out"
    exit 1
fi
# What the project does not declare is left for the shell, which only expands it where
# there is one: cmd prints \$NOPE and \$(echo sub) as they are written
if [ "$host_os" != win ] && [[ "$defines_out" != *"missing=[] shell=sub"* ]]; then
    echo "# A make command must leave what it does not declare to the shell"
    echo "$defines_out"
    exit 1
fi
build_defines_out=$(cd "$project" && "$VALK_BIN" make app 2>&1 && ls "$project")
if [[ "$build_defines_out" != *"app-1.2.3"* ]]; then
    echo "# The arguments of a build must use what 'define' says"
    echo "$build_defines_out"
    exit 1
fi

# Vars, lists, needs and lines that run in order
cat > "$project/valk.json" <<'JSON'
{
    "define": { "VERSION": "1.2.3" },
    "vars": {
        "FLAGS": "-o ./app-$VERSION",
        "TARGETS": ["one", "two"]
    },
    "make": {
        "steps": ["echo first", "echo second"],
        "app": { "dir": "src", "args": "$FLAGS" },
        "list": "echo items $TARGETS",
        "all": { "needs": ["steps", "app"], "cmd": "echo done" },
        "loop": { "needs": ["loop"], "cmd": "echo never" }
    }
}
JSON
steps_out=$(cd "$project" && "$VALK_BIN" make steps 2>&1)
if [[ "$steps_out" != *"first"* ]] || [[ "$steps_out" != *"second"* ]]; then
    echo "# The lines of a make command must run in order"
    echo "$steps_out"
    exit 1
fi
list_out=$(cd "$project" && "$VALK_BIN" make list 2>&1)
if [[ "$list_out" != *"items one two"* ]]; then
    echo "# A list var must join with spaces"
    echo "$list_out"
    exit 1
fi
needs_out=$(cd "$project" && "$VALK_BIN" make all 2>&1 && ls "$project")
if [[ "$needs_out" != *"first"* ]] || [[ "$needs_out" != *"done"* ]] || [[ "$needs_out" != *"app-1.2.3"* ]]; then
    echo "# A make command must run what it needs first"
    echo "$needs_out"
    exit 1
fi
loop_out=$(cd "$project" && "$VALK_BIN" make loop 2>&1)
if [[ "$loop_out" != *"needs itself"* ]]; then
    echo "# A make command that needs itself must be reported"
    echo "$loop_out"
    exit 1
fi

# A package inside a project is its own project, so its config is where the make commands come from
mkdir -p "$project/inner"
cat > "$project/inner/valk.json" <<'JSON'
{
    "define": { "INNER": "yes" }
}
JSON
inner_out=$(cd "$project/inner" && "$VALK_BIN" make steps 2>&1)
if [[ "$inner_out" != *"declares no make commands"* ]]; then
    echo "# A package with a config of its own must not run the make commands of a parent"
    echo "$inner_out"
    exit 1
fi

# A line may be written per platform
cat > "$project/valk.json" <<JSON
{
    "make": {
        "platform": [
            { "$host_os": "echo for this system", "default": "echo for another" },
            { "$other_os": "echo never" },
            "echo always"
        ]
    }
}
JSON
platform_out=$(cd "$project" && "$VALK_BIN" make platform 2>&1)
if [[ "$platform_out" != *"for this system"* ]] || [[ "$platform_out" == *"for another"* ]] \
    || [[ "$platform_out" != *"always"* ]]; then
    echo "# A line written per platform must pick the one for this system"
    echo "$platform_out"
    exit 1
fi

# A platform that is not known is a mistake worth reporting
cat > "$project/valk.json" <<'JSON'
{
    "make": { "x": { "cmd": [{ "windows": "echo hi" }] } }
}
JSON
platform_bad=$(cd "$project" && "$VALK_BIN" ls 2>&1)
if [[ "$platform_bad" != *"no platform 'windows'"* ]]; then
    echo "# An unknown platform must be reported"
    echo "$platform_bad"
    exit 1
fi

# A make command is built or run, not both, and never neither
cat > "$project/valk.json" <<'JSON'
{
    "make": { "both": { "dir": "src", "cmd": "echo greeting" } }
}
JSON
both_out=$(cd "$project" && "$VALK_BIN" ls 2>&1)
if [[ "$both_out" != *"it is built or run, not both"* ]]; then
    echo "# A make command with a dir and a cmd must be rejected"
    echo "$both_out"
    exit 1
fi
cat > "$project/valk.json" <<'JSON'
{
    "make": { "empty": { "global": true } }
}
JSON
neither_out=$(cd "$project" && "$VALK_BIN" ls 2>&1)
if [[ "$neither_out" != *"has neither a 'dir' to build nor a 'cmd' to run"* ]]; then
    echo "# A make command with neither must be rejected"
    echo "$neither_out"
    exit 1
fi

echo ""
echo "# Test require.valk.min: a warning, also shown with an error"
min_project="$workdir/valk-min"
mkdir -p "$min_project/src" "$min_project/dep/src"
cat > "$min_project/valk.json" <<'JSON'
{
    "dependencies": { "dep": { "src": "./dep" } }
}
JSON
cat > "$min_project/dep/valk.json" <<'JSON'
{
    "name": "dep",
    "require": { "valk": { "min": "99.0.0" } }
}
JSON
printf '+ fn hello() String { return "hi" }\n' > "$min_project/dep/src/dep.valk"
printf 'use dep\nfn main() { println(dep.hello()) }\n' > "$min_project/src/main.valk"
min_out=$("$VALK" build "$min_project/src" -o "$workdir/valk-min-app$EXE_SUFFIX" 2>&1)
if [ $? -ne 0 ] || [[ "$min_out" != *"Package 'dep' requires valk 99.0.0 or newer"* ]]; then
    echo "# A package that needs a newer valk must build with a warning"
    echo "$min_out"
    exit 1
fi
printf 'use dep\nfn main() { println(dep.hello_new()) }\n' > "$min_project/src/main.valk"
min_out=$("$VALK" build "$min_project/src" --no-warn -o "$workdir/valk-min-app$EXE_SUFFIX" 2>&1)
if [ $? -eq 0 ] || [[ "$min_out" != *"requires valk 99.0.0 or newer"* ]] || [[ "$min_out" != *"hello_new"* ]]; then
    echo "# A failed build must show the valk requirement next to the error"
    echo "$min_out"
    exit 1
fi
printf 'use dep\nfn main() { println(dep.hello()) }\n' > "$min_project/src/main.valk"
sed -i.bak 's/"99.0.0"/"0.1.0"/' "$min_project/dep/valk.json"
min_out=$("$VALK" build "$min_project/src" -o "$workdir/valk-min-app$EXE_SUFFIX" 2>&1)
if [ $? -ne 0 ] || [[ "$min_out" == *"requires valk"* ]]; then
    echo "# A requirement that is met must stay quiet"
    echo "$min_out"
    exit 1
fi

echo ""
echo "# Test --debug: stack traces and debug info"
trace_out=$($TIMEOUT "$VALK" build "$DIR/debug-trace.valk" --no-warn -d -o "$workdir/debug-trace$EXE_SUFFIX" 2>&1 && $TIMEOUT "$workdir/debug-trace$EXE_SUFFIX" 2>&1)
trace_code=$?
# Paths are shown relative to where the build ran
trace_out=$(printf '%s' "$trace_out" | tr -d '\r' | sed 's#[^ (]*/debug-trace\.valk#debug-trace.valk#g')
expected_trace="Unhandled error 'LookupError.missing' at debug-trace.valk:5
Stack trace:
  at Box.pick (debug-trace.valk:5)
  at closure in main.deeper[int] (debug-trace.valk:12)
  at main.deeper[int] (debug-trace.valk:14)
  at main.main (debug-trace.valk:20)"
if [ "$trace_code" -ne 1 ] || [[ "$trace_out" != *"$expected_trace"* ]]; then
    echo "# A panic in a --debug build must print the stack trace (exit code $trace_code)"
    echo "$trace_out"
    exit 1
fi
plain_out=$($TIMEOUT "$VALK" build "$DIR/debug-trace.valk" --no-warn -o "$workdir/plain-trace$EXE_SUFFIX" 2>&1 && $TIMEOUT "$workdir/plain-trace$EXE_SUFFIX" 2>&1)
plain_out=$(printf '%s' "$plain_out" | tr -d '\r' | sed 's#[^ (]*/debug-trace\.valk#debug-trace.valk#g')
if [[ "$plain_out" == *"Stack trace"* ]] || [[ "$plain_out" != *"Unhandled error 'LookupError.missing' at debug-trace.valk:5"* ]]; then
    echo "# Without --debug a panic prints no stack trace"
    echo "$plain_out"
    exit 1
fi
debug_ir=$("$VALK" build "$DIR/debug-trace.valk" --no-warn -d --ir -o "$workdir/debug-trace.ir" 2>&1 && cat "$workdir/debug-trace.ir")
for needle in "!DICompileUnit(" "name: \"Box.pick\"" "!DILocalVariable(name: \"box\", arg: 1" "!DILocation(line: 12"; do
    if [[ "$debug_ir" != *"$needle"* ]]; then
        echo "# The --debug IR is missing: $needle"
        exit 1
    fi
done
if [ -z "$EXE_SUFFIX" ]; then
    fault_out=$($TIMEOUT "$VALK" build "$DIR/debug-fault.valk" --no-warn -d -o "$workdir/debug-fault" 2>&1 && $TIMEOUT "$workdir/debug-fault" 2>&1)
    fault_out=$(printf '%s' "$fault_out" | sed 's#[^ (]*/debug-fault\.valk#debug-fault.valk#g')
    expected_fault="Segmentation fault
Stack trace:
  at main.poke (debug-fault.valk:4)
  at main.main (debug-fault.valk:9)"
    if [[ "$fault_out" != *"$expected_fault"* ]]; then
        echo "# A crash in a --debug build must print the stack trace"
        echo "$fault_out"
        exit 1
    fi
fi

echo "# CLI tests passed"
echo "# Test count: 71"
