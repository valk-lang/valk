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

echo "> The target list in --help matches the invalid target message"
help_targets=$("$VALK" build --help | grep -A1 -- '--target' | tail -n 1 | sed 's/^ *//')
invalid_targets=$("$VALK" build "$input" --target nope 2>&1 | sed -n 's/^Supported: //p')
if [ -z "$help_targets" ] || [ "$help_targets" != "$invalid_targets" ]; then
    echo "# Target lists differ: help '$help_targets' vs error '$invalid_targets'"
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

echo "# CLI tests passed"
echo "# Test count: 33"
