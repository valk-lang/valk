#!/bin/bash
# Generated-code regressions that are observable only in LLVM IR.

set -u

VALK="${VALK:-./valk}"
DIR="$(cd "$(dirname "$0")" && pwd)"
case "$(uname -s)" in
    MINGW*|MSYS*) DIR="$(cd "$(dirname "$0")" && pwd -W)" ;;
esac

workdir=$(mktemp -d)
case "$(uname -s)" in
    MINGW*|MSYS*) workdir=$(cygpath -m "$workdir") ;;
esac
trap 'rm -rf "$workdir"' EXIT

# Every IR fixture is built up front, in parallel; the checks below read the
# saved output and status of their build.
export VALK DIR workdir
ir_build() {
    local path="$1"
    shift
    "$VALK" build "$@" -o "$path" > "$path.log" 2>&1
    echo "$?" > "$path.status"
}
export -f ir_build
job_count=0
queue_ir() {
    local job="$workdir/job-$job_count.sh" arg
    job_count=$((job_count + 1))
    printf 'ir_build' > "$job"
    for arg in "$@"; do printf " '%s'" "$arg" >> "$job"; done
    echo "" >> "$job"
}
ir_result() {
    cat "$1.log"
    return "$(cat "$1.status")"
}
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/gc-direct-entry-$target.ll" "$DIR/gc-direct-entry.valk" --target "$target" --ir --no-warn; done
queue_ir "$workdir/buffer-roots.ll" "$DIR/buffer-roots.valk" --ir --no-warn
queue_ir "$workdir/native-address.ll" "$DIR/native-address.valk" --ir --no-warn
queue_ir "$workdir/windows-coro-stack.ll" "$DIR/native-address.valk" --target win-x64 --ir --no-warn
queue_ir "$workdir/gc-fast-paths.ll" "$DIR/gc-fast-paths.valk" --release --ir --no-warn
queue_ir "$workdir/atomic-alignment.ll" "$DIR/atomic-alignment.valk" --ir --no-warn
queue_ir "$workdir/pointer-integer-compare.ll" "$DIR/pointer-integer-compare.valk" --target win-x64 --ir --no-warn
queue_ir "$workdir/windows-bool.ll" "$DIR/windows-bool.valk" --target win-x64 --ir --no-warn
queue_ir "$workdir/tagged-union-scalars.ll" "$DIR/tagged-union-scalars.valk" --ir --no-warn
queue_ir "$workdir/export.ll" "$DIR/export.valk" --ir --no-warn
queue_ir "$workdir/shared-pool.ll" "$DIR/shared-pool.valk" --ir --no-warn
queue_ir "$workdir/fixed-array-bounds.ll" "$DIR/fixed-array-bounds.valk" --ir --no-warn
queue_ir "$workdir/fixed-array-fills.ll" "$DIR/fixed-array-fills.valk" --ir --no-warn
queue_ir "$workdir/direct-initializer.ll" "$DIR/direct-initializer.valk" --ir --no-warn
queue_ir "$workdir/interface-values.ll" "$DIR/interface-values.valk" --ir --no-warn
queue_ir "$workdir/interface-values-win.ll" "$DIR/interface-values.valk" --ir --no-warn --target win-x64
queue_ir "$workdir/await-error.ll" "$DIR/await-error.valk" --ir --no-warn --target macos-arm64
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/array-conversions-$target.ll" "$DIR/array-conversions.valk" --ir --no-warn --target "$target"; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/borrow-methods-$target.ll" "$DIR/borrow-methods.valk" --ir --no-warn --target "$target"; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/operator-hooks-$target.ll" "$DIR/operator-hooks.valk" --ir --no-warn --target "$target"; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/clone-borrows-$target.ll" "$DIR/clone-borrows.valk" --ir --no-warn --target "$target"; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/closure-layouts-$target.ll" "$DIR"/../cli/closure-layouts/*.valk --release --ir --no-warn --target "$target"; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/optimization-flags-$target.ll" "$DIR/../cli/optimization-flags.valk" --release --ir --no-warn --target "$target"; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/callable-compatibility-$target.ll" "$DIR/callable-compatibility.valk" --release --ir --no-warn --target "$target"; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/conditional-values-$target.ll" "$DIR/conditional-values.valk" --ir --no-warn --target "$target"; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/nonreturning-expressions-$target.ll" "$DIR/nonreturning-expressions.valk" --ir --no-warn --target "$target"; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/call-evaluation-$target.ll" "$DIR/call-evaluation.valk" --ir --no-warn --target "$target"; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/fnptr-closures-$target.ll" "$DIR/fnptr-closures.valk" --target "$target" --ir --no-warn; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/bound-callables-$target.ll" "$DIR/bound-callables.valk" --target "$target" --ir --no-warn; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/cleared-views-$target.ll" "$DIR/cleared-views.valk" --target "$target" --ir --no-warn; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/array-sorting-$target.ll" "$DIR/array-sorting.valk" --target "$target" --ir --no-warn; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/enum-safety-$target.ll" "$DIR/enum-safety.valk" --target "$target" --ir --no-warn; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/enum-representations-$target.ll" "$DIR/enum-representations.valk" --target "$target" --ir --no-warn; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/enum-storage-$target.ll" "$DIR/enum-storage.valk" --target "$target" --ir --no-warn; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/bound-locals-$target.ll" "$DIR/bound-locals.valk" --target "$target" --ir --no-warn; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/borrow-evaluation-$target.ll" "$DIR/borrow-evaluation.valk" --target "$target" --ir --no-warn; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/index-storage-$target.ll" "$DIR/index-storage.valk" --target "$target" --ir --no-warn; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/owner-stores-$target.ll" "$DIR/owner-stores.valk" --target "$target" --ir --no-warn; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/fixed-element-borrows-$target.ll" "$DIR/fixed-element-borrows.valk" --target "$target" --ir --no-warn; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/fixed-range-evaluation-$target.ll" "$DIR/fixed-range-evaluation.valk" --target "$target" --ir --no-warn; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/matrix-borrows-$target.ll" "$DIR/matrix-borrows.valk" --target "$target" --ir --no-warn; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/pointer-array-copies-$target.ll" "$DIR/pointer-array-copies.valk" --target "$target" --ir --no-warn; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/iterator-contracts-$target.ll" "$DIR/iterator-contracts.valk" --target "$target" --ir --no-warn; done
for target in linux-x64 macos-x64 macos-arm64 win-x64; do queue_ir "$workdir/generic-iterators-$target.ll" "$DIR/generic-iterators.valk" --target "$target" --ir --no-warn; done
jobs=$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)
ls "$workdir"/job-*.sh | xargs -n 1 -P "$jobs" bash


echo ""
echo "# Test generated-code optimizations"
echo "> Call the native GC entry directly on every target"

for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    collect_ir="$workdir/gc-direct-entry-$target.ll"
    out=$(ir_result "$collect_ir")
    if [ "$?" -ne 0 ]; then
        echo "# Failed to build direct GC entry fixture for $target"
        echo "$out"
        exit 1
    fi
    collect_body=$(sed -n '/^define .*__explicit_collect__/,/^}/p' "$collect_ir")
    if [[ "$collect_body" != *'call void @"valk_gc_collect"()'* ]]; then
        echo "# Explicit collection did not call the assembly entry directly on $target"
        echo "$collect_body"
        exit 1
    fi
    shared_collect_body=$(sed -n '/^define .*__explicit_collect_shared__/,/^}/p' "$collect_ir")
    if [[ "$shared_collect_body" != *'call void @"valk_gc_collect_shared"()'* ]]; then
        echo "# Shared collection did not call the assembly entry directly on $target"
        echo "$shared_collect_body"
        exit 1
    fi
    accept_body=$(sed -n '/^define .*__TcpServer__accept__/,/^}/p' "$collect_ir")
    accept_returns=$(grep -c '^  ret ' <<< "$accept_body")
    accept_uses=$(grep -c 'call void asm sideeffect "", "r"(ptr' <<< "$accept_body")
    if [ "$accept_returns" -lt 2 ] || [ "$accept_uses" -lt "$accept_returns" ]; then
        echo "# Accept did not keep its receiver alive on every exit on $target"
        echo "$accept_body"
        exit 1
    fi
done

echo "> Keep managed values on the native stack without shadow frames"

ir="$workdir/buffer-roots.ll"
out=$(ir_result "$ir")
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Failed to build IR fixture"
    echo "$out"
    exit 1
fi

body=$(sed -n '/^define .*__coalesced_roots__/,/^}/p' "$ir")
if [ -z "$body" ]; then
    echo "# Missing coalesced_roots in generated IR"
    exit 1
fi
if grep -q 'valk\.gc\.stack' "$ir" || [[ "$body" == *"alloca { ptr, ptr, ["* ]]; then
    echo "# Generated code still links a GC shadow frame"
    echo "$body"
    exit 1
fi

coro_helper=$(sed -n '/^define internal void @"valk\.coro\./,/^}/p' "$ir")
if [ -z "$coro_helper" ] || [[ "$coro_helper" == *"alloca { ptr, ptr, ["* ]]; then
    echo "# Coroutine helper unexpectedly allocated a GC frame"
    echo "$coro_helper"
    exit 1
fi

echo "> Keep inline nullable and multi-value GC layouts naturally aligned"

layout_body=$(sed -n '/^define .*__inline_layout_roots__/,/^}/p' "$ir")
layout_union=$(sed -n '/^define .*__aligned_layout_union__/,/^}/p' "$ir")

if [[ "$layout_body" != *"[2 x { i1, [7 x i8], [1 x i64] }]"* ]] \
    || [[ "$layout_union" != *"insertvalue { i1, ptr }"* ]] \
    || [[ "$layout_union" != *"store { i1, ptr }"* ]]; then
    echo "# Inline nullable or naturally aligned multi-value storage disagreed with its byte layout"
    exit 1
fi

echo "> Construct fixed inline values in stack storage"

fixed_body=$(sed -n '/^define .*__inline_fixed_value__/,/^}/p' "$ir")
if [[ "$fixed_body" != *"alloca [3 x i8]"* ]] \
    || [[ "$fixed_body" != *"store i8 1"* ]] \
    || [[ "$fixed_body" != *"store i8 2"* ]] \
    || [[ "$fixed_body" != *"store i8 3"* ]] \
    || [[ "$fixed_body" == *"call "* ]]; then
    echo "# Fixed inline value did not use stack storage"
    echo "$fixed_body"
    exit 1
fi

echo "> Keep address-taken locals on native stacks"

address_ir="$workdir/native-address.ll"
out=$(ir_result "$address_ir")
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Failed to build native address IR fixture"
    echo "$out"
    exit 1
fi

native_address_body=$(sed -n '/^define .*__native_address_storage__/,/^}/p' "$address_ir")
suspending_address_body=$(sed -n '/^define .*__suspending_address_storage__/,/^}/p' "$address_ir")
clock_time_body=$(sed -n '/^define .*__clock_ns__/,/^}/p' "$address_ir")
if [[ -z "$clock_time_body" ]]; then
    clock_time_body=$(sed -n '/^define .*__mono_ns__/,/^}/p' "$address_ir")
fi
if [[ "$native_address_body" != *"alloca"* ]] \
    || [[ "$native_address_body" == *"__Pool__get__"* ]]; then
    echo "# Proven non-suspending address storage did not use the native stack"
    echo "$native_address_body"
    exit 1
fi
if [[ "$clock_time_body" != *"alloca"* ]] \
    || [[ "$clock_time_body" == *"__Pool__get__"* ]]; then
    echo "# OS clock helper did not keep its address-taken structure on the native stack"
    echo "$clock_time_body"
    exit 1
fi
if [[ "$suspending_address_body" != *"alloca"* ]] \
    || [[ "$suspending_address_body" == *"__Pool__get__"* ]]; then
    echo "# Transitively suspending address storage did not use its private stack"
    echo "$suspending_address_body"
    exit 1
fi

echo "> Reserve Windows coroutine stacks with a 32 KiB commit"

windows_coro_ir="$workdir/windows-coro-stack.ll"
out=$(ir_result "$windows_coro_ir")
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Failed to build Windows coroutine stack IR fixture"
    echo "$out"
    exit 1
fi

if ! grep -q 'call ptr @"CreateFiberEx"(i64 32768, i64 %' "$windows_coro_ir" \
    || grep -q 'valk_stack_swap' "$windows_coro_ir"; then
    echo "# Windows coroutines did not use the expected native fiber stack"
    grep -E 'CreateFiberEx|valk_stack_swap' "$windows_coro_ir" || true
    exit 1
fi

echo "> Keep property stores and Array append on their GC fast paths"

fast_path_ir="$workdir/gc-fast-paths.ll"
out=$(ir_result "$fast_path_ir")
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Failed to build GC fast-path IR fixture"
    echo "$out"
    exit 1
fi

property_fast_body=$(sed -n '/^define .*__property_update__/,/^}/p' "$fast_path_ir")
if [[ "$property_fast_body" != *"property_update_slow"* ]] \
    || [[ "$property_fast_body" != *"store ptr"* ]]; then
    echo "# Managed property update did not contain its guarded fast path"
    echo "$property_fast_body"
    exit 1
fi

if grep -q 'valk\.gc\.stack' "$fast_path_ir"; then
    echo "# Generated code still links a GC shadow frame"
    exit 1
fi

echo "> Use natural alignment for atomic property accesses"

atomic_ir="$workdir/atomic-alignment.ll"
out=$(ir_result "$atomic_ir")
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Failed to build atomic-alignment IR fixture"
    echo "$out"
    exit 1
fi

atomic_body=$(sed -n '/^define .*__atomic_alignment__/,/^}/p' "$atomic_ir")
if [[ "$atomic_body" != *"load atomic i8"*"align 1"* ]] \
    || [[ "$atomic_body" != *"load atomic i16"*"align 2"* ]] \
    || [[ "$atomic_body" != *"load atomic i32"*"align 4"* ]]; then
    echo "# Atomic property access overstated its alignment"
    echo "$atomic_body"
    exit 1
fi

echo "> Compare pointers with integer sentinels through pointer-sized integers"

pointer_ir="$workdir/pointer-integer-compare.ll"
out=$(ir_result "$pointer_ir")
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Failed to build pointer-integer comparison IR fixture"
    echo "$out"
    exit 1
fi

pointer_left=$(sed -n '/^define .*@"pointer_equal_invalid"/,/^}/p' "$pointer_ir")
pointer_right=$(sed -n '/^define .*@"invalid_equal_pointer"/,/^}/p' "$pointer_ir")
if [[ "$pointer_left" != *"ptrtoint ptr"* ]] \
    || [[ "$pointer_left" != *"icmp eq i64"*", -1"* ]] \
    || [[ "$pointer_right" != *"ptrtoint ptr"* ]] \
    || [[ "$pointer_right" != *"icmp eq i64 -1,"* ]] \
    || grep -Eq 'icmp (eq|ne) ptr [^,]+, -?[0-9]+' "$pointer_ir"; then
    echo "# Pointer/integer comparison was not lowered through pointer-sized integers"
    echo "$pointer_left"
    echo "$pointer_right"
    exit 1
fi

echo "> Use 32-bit Win32 BOOL at FFI boundaries"

windows_bool_ir="$workdir/windows-bool.ll"
out=$(ir_result "$windows_bool_ir")
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Failed to build Win32 BOOL IR fixture"
    echo "$out"
    exit 1
fi

if ! grep -q '^declare i32 @"CloseHandle"(i64)' "$windows_bool_ir" \
    || grep -q '^declare i1 @"CloseHandle"' "$windows_bool_ir"; then
    echo "# CloseHandle did not use the 32-bit Win32 BOOL ABI"
    grep 'CloseHandle' "$windows_bool_ir"
    exit 1
fi

echo "> Lower tagged unions to inline value aggregates"

scalar_ir="$workdir/tagged-union-scalars.ll"
out=$(ir_result "$scalar_ir")
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Failed to build scalar tagged-union IR fixture"
    echo "$out"
    exit 1
fi

for name in box_int box_i32 box_u8 box_bool box_f32 box_f64 box_scalar_only box_gc_only; do
    scalar_body=$(sed -n "/^define .*__${name}__/,/^}/p" "$scalar_ir")
    if [ -z "$scalar_body" ]; then
        echo "# Missing $name in generated IR"
        exit 1
    fi
    if [[ "$scalar_body" == *"__Pool__get__"* ]] || [[ "$scalar_body" == *"__Payload__"* ]]; then
        echo "# $name allocated boxed tagged-union storage"
        echo "$scalar_body"
        exit 1
    fi
done

int_body=$(sed -n '/^define .*__box_int__/,/^}/p' "$scalar_ir")
i32_body=$(sed -n '/^define .*__box_i32__/,/^}/p' "$scalar_ir")
u8_body=$(sed -n '/^define .*__box_u8__/,/^}/p' "$scalar_ir")
bool_body=$(sed -n '/^define .*__box_bool__/,/^}/p' "$scalar_ir")
f32_body=$(sed -n '/^define .*__box_f32__/,/^}/p' "$scalar_ir")
f64_body=$(sed -n '/^define .*__box_f64__/,/^}/p' "$scalar_ir")
scalar_only_body=$(sed -n '/^define .*__box_scalar_only__/,/^}/p' "$scalar_ir")
gc_only_body=$(sed -n '/^define .*__box_gc_only__/,/^}/p' "$scalar_ir")

if [[ "$int_body" != *"{ i8, [3 x i64] }"* ]] \
    || [[ "$i32_body" != *"{ i8, [3 x i64] }"* ]] \
    || [[ "$u8_body" != *"{ i8, [3 x i64] }"* ]] \
    || [[ "$bool_body" != *"{ i8, [3 x i64] }"* ]] \
    || [[ "$f32_body" != *"{ i8, [3 x i64] }"* ]] \
    || [[ "$f64_body" != *"{ i8, [3 x i64] }"* ]] \
    || [[ "$scalar_only_body" != *"{ i8, [1 x i64] }"* ]] \
    || [[ "$gc_only_body" != *"{ i8, [3 x i64] }"* ]]; then
    echo "# Tagged-union aggregate layout did not match tag / shared payload fields"
    exit 1
fi

if [[ "$i32_body" != *"store i32"* ]] \
    || [[ "$u8_body" != *"store i8"* ]] \
    || [[ "$bool_body" != *"store i1"* ]] \
    || [[ "$f32_body" != *"store float"* ]] \
    || [[ "$f64_body" != *"store double"* ]]; then
    echo "# Tagged-union payloads were not stored with their source types"
    exit 1
fi

for name in union_equal_member member_equal_union; do
    compare_body=$(sed -n "/^define .*__${name}__/,/^}/p" "$scalar_ir")
    if [ -z "$compare_body" ] || grep -Eq 'extractvalue \{[^}]+\} [0-9]+,' <<< "$compare_body"; then
        echo "# Tagged-union member comparison did not wrap both operands"
        echo "$compare_body"
        exit 1
    fi
done

string_compare_body=$(sed -n '/^define .*__union_equal_string__/,/^}/p' "$scalar_ir")
if [[ "$string_compare_body" != *"__String__equals__"* ]]; then
    echo "# Tagged-union equality did not use the active member comparison hook"
    echo "$string_compare_body"
    exit 1
fi

echo "> Keep exported symbols unmangled and reachable"

export_ir="$workdir/export.ll"
out=$(ir_result "$export_ir")
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Failed to build exported-symbol IR fixture"
    echo "$out"
    exit 1
fi

if ! grep -q '^define dso_local i64 @"exported_function"' "$export_ir" \
    || ! grep -q '^@"exported_global" = thread_local(initialexec) global i64 ' "$export_ir"; then
    echo "# Exported definitions were not emitted with their raw symbol names"
    exit 1
fi

if ! grep -q '^define dso_local i64 @".*__export_helper__' "$export_ir" \
    || grep -q 'unreachable_function' "$export_ir" \
    || grep -q 'unreachable_global' "$export_ir"; then
    echo "# Export reachability did not retain dependencies and discard unused definitions"
    exit 1
fi

echo "> Reuse one allocator pool for local and shared objects"

pool_ir="$workdir/shared-pool.ll"
out=$(ir_result "$pool_ir")
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Failed to build shared-pool IR fixture"
    echo "$out"
    exit 1
fi

pool_globals=$(grep -c '^@".*__ALC_.*__SharedPoolValue__' "$pool_ir")
pool_loads=$(grep -c '= load ptr, ptr @".*__ALC_.*__SharedPoolValue__' "$pool_ir")
if [ "$pool_globals" -ne 1 ] || [ "$pool_loads" -ne 2 ]; then
    echo "# Expected local and shared SharedPoolValue allocations to use one pool"
    exit 1
fi

echo "> Check variable indices for every known-length sequence"

fills_ir="$workdir/fixed-array-fills.ll"
out=$(ir_result "$fills_ir")
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Failed to build fixed-array fills IR fixture"
    echo "$out"
    exit 1
fi
fills_body=$(sed -n "/^define .*__zero_struct__/,/^}/p" "$fills_ir")
if [[ "$fills_body" != *"llvm.memset.p0.i64(ptr %"*", i8 0, i64 4096"* ]] || [[ "$fills_body" == *"load [4096 x i8]"* ]] || [[ "$fills_body" == *"i64 4095"* ]]; then
    echo "# zero_struct did not zero its array field with a single memset"
    echo "$fills_body"
    exit 1
fi
fills_body=$(sed -n "/^define .*__seven_local__/,/^}/p" "$fills_ir")
if [[ "$fills_body" != *"llvm.memset.p0.i64(ptr %"*", i8 7, i64 4095"* ]] || [[ "$fills_body" == *"i64 4094"* ]]; then
    echo "# seven_local did not fill its array with a single memset"
    echo "$fills_body"
    exit 1
fi
fills_body=$(sed -n "/^define .*__word_fill__/,/^}/p" "$fills_ir")
if [[ "$fills_body" != *"fill.body"* ]] || [[ "$fills_body" == *"i64 511"* ]]; then
    echo "# word_fill did not fill its array with a loop"
    echo "$fills_body"
    exit 1
fi
fills_body=$(sed -n "/^define .*__copy_block__/,/^}/p" "$fills_ir")
if [[ "$fills_body" != *"llvm.memcpy.p0.p0.i64(ptr %"*", i64 4096"* ]] || [[ "$fills_body" == *"load %"*"Block"* ]]; then
    echo "# copy_block did not copy its struct with memcpy"
    echo "$fills_body"
    exit 1
fi

bounds_ir="$workdir/fixed-array-bounds.ll"
out=$(ir_result "$bounds_ir")
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Failed to build fixed-array bounds IR fixture"
    echo "$out"
    exit 1
fi

for name in fixed_read bounded_read named_bounded_read fixed_write; do
    bounds_body=$(sed -n "/^define .*__${name}__/,/^}/p" "$bounds_ir")
    if [[ "$bounds_body" != *"icmp uge"* ]] || [[ "$bounds_body" != *"__panic__"* ]]; then
        echo "# $name did not check its known sequence bound before indexing"
        echo "$bounds_body"
        exit 1
    fi
done

native_each_body=$(sed -n '/^define .*__native_array_each__/,/^}/p' "$bounds_ir")
if [[ "$native_each_body" != *"icmp ult"* ]] || [[ "$native_each_body" == *"_next"* ]]; then
    echo "# Array each did not use native length/data iteration"
    echo "$native_each_body"
    exit 1
fi

echo "> Initialize fixed arrays directly in destination storage"

direct_ir="$workdir/direct-initializer.ll"
out=$(ir_result "$direct_ir")
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Failed to build direct initializer IR fixture"
    echo "$out"
    exit 1
fi

direct_body=$(sed -n '/^define .*__direct_array_initializer__/,/^}/p' "$direct_ir")
direct_slots=$(grep -c 'alloca \[2 x i8\]' <<< "$direct_body")
if [ "$direct_slots" -ne 1 ]; then
    echo "# Expected only the destination slot for fixed-array initialization"
    echo "$direct_body"
    exit 1
fi

echo "> Store interface values as receiver and static vtable pairs"

interface_ir="$workdir/interface-values.ll"
out=$(ir_result "$interface_ir")
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Failed to build interface value IR fixture"
    echo "$out"
    exit 1
fi

interface_body=$(sed -n '/^define .*__interface_fat_value__/,/^}/p' "$interface_ir")
if [[ "$interface_body" != *"insertvalue { ptr, ptr }"* ]] \
    || [[ "$interface_body" == *"__Pool__get__"* ]] \
    || ! grep -q '^@"valk\.interface\.vtable\..*" = linkonce_odr constant \[1 x ptr\]' "$interface_ir"; then
    echo "# Interface conversion did not use a non-allocating fat value and static vtable"
    echo "$interface_body"
    exit 1
fi

echo "> Emit Windows interface vtables in COMDAT sections"

interface_win_ir="$workdir/interface-values-win.ll"
out=$(ir_result "$interface_win_ir")
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Failed to build Windows interface value IR fixture"
    echo "$out"
    exit 1
fi

if ! grep -q '^$"valk\.interface\.vtable\..*" = comdat any$' "$interface_win_ir" \
    || ! grep -q 'comdat($"valk\.interface\.vtable\..*")' "$interface_win_ir"; then
    echo "# Windows interface vtable did not use a COMDAT section"
    grep 'valk.interface.vtable' "$interface_win_ir"
    exit 1
fi

echo "> Failed await skips unpublished result storage"
await_ir="$workdir/await-error.ll"
if ! ir_result "$await_ir"; then
    exit 1
fi
body=$(sed -n '/^define .*__await_failed_result__/,/^}/p' "$await_ir")
error_body=$(sed -n '/^await.error\./,/^await.success\./p' <<< "$body")
success_body=$(sed -n '/^await.success\./,/^await.after\./p' <<< "$body")
if [[ "$error_body" != *"br label %await.after."* ]] \
    || [[ "$error_body" == *"load ptr"* ]] \
    || [[ "$success_body" != *"load ptr"* ]]; then
    echo "# Await must load managed results only on success"
    echo "$body"
    exit 1
fi

echo "> Array conversions read the source layout without heap allocation"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    array_ir="$workdir/array-conversions-$target.ll"
    if ! ir_result "$array_ir"; then
        exit 1
    fi
    widened=$(sed -n '/^define .*__array_widen_elements__/,/^}/p' "$array_ir")
    first_load=$(grep -m 1 '= load \[' <<< "$widened")
    direct=$(sed -n '/^define .*__array_same_layout__/,/^}/p' "$array_ir")
    if [[ "$first_load" != *'load [2 x i64]'* ]] || [[ "$widened" == *'call '* ]]; then
        echo "# Widening must read the source layout without allocating on $target"
        echo "$widened"
        exit 1
    fi
    if [[ "$direct" != *'load [2 x i64]'* ]] || [[ "$direct" == *'insertvalue'* ]] \
        || [[ "$direct" == *'alloca ['* ]] || [[ "$direct" == *'call '* ]]; then
        echo "# Matching array layouts should use a direct copy on $target"
        echo "$direct"
        exit 1
    fi
    presence=$(sed -n '/^define .*__array_add_presence__/,/^}/p' "$array_ir")
    if [[ "$presence" != *'i1 true, 0'* ]] || [[ "$presence" == *'extractvalue [2 x i64]'* ]] \
        || [[ "$presence" == *'call '* ]]; then
        echo "# Adding presence should preserve the existing array on $target"
        echo "$presence"
        exit 1
    fi
done

echo "> Borrowed receivers use their existing storage without heap allocation"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    borrow_ir="$workdir/borrow-methods-$target.ll"
    if ! ir_result "$borrow_ir"; then
        exit 1
    fi
    read_body=$(sed -n '/^define .*__borrow_receiver_read__/,/^}/p' "$borrow_ir")
    write_body=$(sed -n '/^define .*__borrow_receiver_write__/,/^}/p' "$borrow_ir")
    increment_body=$(sed -n '/^define .*__Cell__increment__/,/^}/p' "$borrow_ir")
    if [[ "$read_body" != *'load i64'* ]] || [[ "$write_body" != *'__Cell__increment__'* ]] \
        || [[ "$increment_body" != *'store i64'* ]] \
        || [[ "$read_body$write_body$increment_body" == *'__Pool__get__'* ]]; then
        echo "# Borrowed receiver access must preserve storage without allocating on $target"
        echo "$read_body$write_body$increment_body"
        exit 1
    fi
done

echo "> Shared operator hooks use atomic accesses without heap allocation"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    operator_ir="$workdir/operator-hooks-$target.ll"
    if ! ir_result "$operator_ir"; then
        exit 1
    fi
    caller=$(sed -n '/^define .*__shared_operator_add__/,/^}/p' "$operator_ir")
    hook=$(sed -n '/^define .*__HookCounter__add__shared__/,/^}/p' "$operator_ir")
    if [[ "$caller" != *'__HookCounter__add__shared__'* ]] \
        || [[ "$hook" != *'atomicrmw add'* ]] || [[ "$hook" != *'load atomic i64'* ]] \
        || [[ "$caller$hook" == *'__Pool__get__'* ]]; then
        echo "# Shared operator calls must select atomic access without allocating on $target"
        echo "$caller$hook"
        exit 1
    fi
    group_call=$(sed -n '/^define .*__shared_group_increment__/,/^}/p' "$operator_ir")
    increment=$(sed -n '/^define .*__HookCounter__increment__shared__/,/^}/p' "$operator_ir")
    group_read=$(sed -n '/^define .*__shared_group_read__/,/^}/p' "$operator_ir")
    read=$(sed -n '/^define .*__HookCounter__read__shared__/,/^}/p' "$operator_ir")
    getter=$(sed -n '/^define .*__HookCounter__total__shared__/,/^}/p' "$operator_ir")
    if [[ "$group_call" != *'__HookCounter__increment__shared__'* ]] \
        || [[ "$increment" != *'atomicrmw add'* ]] \
        || [[ "$group_read" != *'__HookCounter__read__shared__'* ]] \
        || [[ "$read" != *'__HookCounter__total__shared__'* ]] \
        || [[ "$getter" != *'load atomic i64'* ]] \
        || [[ "$group_call$increment$group_read$read$getter" == *'__Pool__get__'* ]]; then
        echo "# Shared group methods and getters must preserve atomic access on $target"
        echo "$group_call$increment$group_read$read$getter"
        exit 1
    fi
done

echo "> Borrowed inline clones guard null without heap allocation"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    clone_ir="$workdir/clone-borrows-$target.ll"
    if ! ir_result "$clone_ir"; then
        exit 1
    fi
    direct=$(sed -n '/^define .*__clone_borrow_inline__/,/^}/p' "$clone_ir")
    nullable=$(sed -n '/^define .*__clone_nullable_borrow_inline__/,/^}/p' "$clone_ir")
    payload=$(sed -n '/^define .*__clone_nullable_inline__/,/^}/p' "$clone_ir")
    hooks=$(sed -n '/^define .*__CloneCell__clone__/,/^}/p' "$clone_ir")
    before_guard=$(sed '/^this_or_that.then\./,$d' <<< "$nullable")
    present=$(sed -n '/^this_or_that.then\./,/^this_or_that.else\./p' <<< "$nullable")
    absent=$(sed -n '/^this_or_that.else\./,/^this_or_that.after\./p' <<< "$nullable")
    if [[ "$direct" != *'__CloneCell__clone__'* ]] || [[ "$present" != *'__CloneCell__clone__'* ]] \
        || [[ "$before_guard$absent" == *'__CloneCell__clone__'* ]] \
        || [[ "$before_guard" != *'icmp ne ptr'* ]] \
        || [[ "$payload" != *'getelementptr { i1, [7 x i8], [1 x i64] }'* ]] \
        || [[ "$direct$nullable$payload$hooks" == *'__Pool__get__'* ]]; then
        echo "# Borrowed clone hooks must run only for present values without heap allocation on $target"
        echo "$direct$nullable$payload$hooks"
        exit 1
    fi
done

echo "> Same-offset closures in separate files keep distinct allocators"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    closure_ir="$workdir/closure-layouts-$target.ll"
    if ! ir_result "$closure_ir"; then
        exit 1
    fi
    first=$(sed -n '/^define .*__closure_layout_first__/,/^}/p' "$closure_ir" | grep -o 'ptr @"[^"]*ALC_[^"]*closure_env[^"]*"')
    other=$(sed -n '/^define .*__closure_layout_other__/,/^}/p' "$closure_ir" | grep -o 'ptr @"[^"]*ALC_[^"]*closure_env[^"]*"')
    if [[ -z "$first" || -z "$other" || "$first" == "$other" ]]; then
        echo "# Different capture layouts must not share an allocator on $target"
        echo "$first"
        echo "$other"
        exit 1
    fi
done

echo "> Inlining controls survive specialization and receiver variants"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    flags_ir="$workdir/optimization-flags-$target.ll"
    if ! ir_result "$flags_ir"; then
        exit 1
    fi
    definitions=$(grep -E '^define .*__(noinline_frame|noinline_generic|NoinlineCounter__(increment|clone))__' "$flags_ir")
    count=$(grep -c '^define ' <<< "$definitions")
    inline_definition=$(grep '^define .*__inline_increment__' "$flags_ir")
    if [ "$count" -lt 7 ] || grep -qv ' noinline' <<< "$definitions" \
        || [[ "$inline_definition" != *' alwaysinline'* ]]; then
        echo "# Inlining controls were lost on $target"
        echo "$definitions"
        echo "$inline_definition"
        exit 1
    fi
done

echo "> Compatible callable views do not allocate adapter environments"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    callable_ir="$workdir/callable-compatibility-$target.ll"
    if ! ir_result "$callable_ir"; then
        exit 1
    fi
    for view in argument result pointer; do
        body=$(sed -n "/^define .*__callable_${view}_view__/,/^}/p" "$callable_ir")
        if [[ -z "$body" || "$body" == *'__ALC_'* || "$body" == *'valk.alloc.'* || "$body" == *'call ptr '* ]]; then
            echo "# Compatible callable view allocated an adapter on $target: $view"
            echo "$body"
            exit 1
        fi
    done
done

echo "> Conditional extraction of inline values does not allocate"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    conditional_ir="$workdir/conditional-values-$target.ll"
    if ! ir_result "$conditional_ir"; then
        exit 1
    fi
    for kind in scalar aggregate; do
        body=$(sed -n "/^define .*__conditional_${kind}__/,/^}/p" "$conditional_ir")
        if [[ -z "$body" || "$body" != *'br i1 '* || "$body" != *'__panic__'* \
            || "$body" == *'__ALC_'* || "$body" == *'valk.alloc.'* || "$body" == *'__Pool__get__'* || "$body" == *'call ptr '* ]]; then
            echo "# Conditional inline extraction allocated or lost its guard on $target: $kind"
            echo "$body"
            exit 1
        fi
    done
done

echo "> Nonreturning operands terminate their block without new allocations"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    termination_ir="$workdir/nonreturning-expressions-$target.ll"
    if ! ir_result "$termination_ir"; then
        exit 1
    fi
    for kind in call array; do
        body=$(sed -n "/^define .*__interrupted_${kind}__/,/^}/p" "$termination_ir")
        if [[ -z "$body" || "$body" != *'__exit_number__'* \
            || ( "$kind" == call && "$body" != *'__combine__'* ) \
            || "$body" == *'__ALC_'* || "$body" == *'valk.alloc.'* || "$body" == *'__Pool__get__'* ]]; then
            echo "# Nonreturning operand lost a reachable call or allocated storage on $target: $kind"
            echo "$body"
            exit 1
        fi
        if ! awk '
            /^  unreachable$/ { ended = 1; next }
            /^[^ ;]/ { ended = 0 }
            /^  [^;]/ && ended { exit 1 }
        ' <<< "$body"; then
            echo "# Instructions emitted after unreachable on $target: $kind"
            echo "$body"
            exit 1
        fi
    done
done

echo "> Function pointer calls and coroutines do not allocate closure adapters"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    call_ir="$workdir/call-evaluation-$target.ll"
    if ! ir_result "$call_ir"; then
        exit 1
    fi
    direct=$(sed -n '/^define .*__pointer_call__/,/^}/p' "$call_ir")
    task=$(sed -n '/^define .*__pointer_task__/,/^}/p' "$call_ir")
    if [[ -z "$direct" || "$task" != *'__Coro__new__'* \
        || "$direct$task" == *'__ALC_'* || "$direct$task" == *'valk.alloc.'* \
        || "$direct$task" == *'__Pool__get__'* || "$direct$task" == *'closure_env'* ]]; then
        echo "# Function pointer call added closure storage or lost coroutine creation on $target"
        echo "$direct$task"
        exit 1
    fi
done

echo "> Adapt function pointers without allocating for known targets"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    ir="$workdir/fnptr-closures-$target.ll"
    if ! out=$(ir_result "$ir"); then
        echo "# Failed to build function pointer closure fixture for $target"
        echo "$out"
        exit 1
    fi
    for name in known_pointer_closure known_literal_closure; do
        body=$(sed -n "/^define .*__${name}__/,/^}/p" "$ir")
        if [[ -z "$body" || "$body" != *'ptr null, 1'* \
            || "$body" == *'__ALC_'* || "$body" == *'valk.alloc.'* \
            || "$body" == *'closure_env'* || "$body" == *'<fnptr.closure.'* ]]; then
            echo "# Known function pointer acquired a closure environment on $target"
            echo "$body"
            exit 1
        fi
    done
    invoke=$(sed -n '/^define .*__<fnptr.invoke\./,/^}/p' "$ir")
    if [[ "$invoke" != *'(ptr %closure.data, i64 %arg.0)'* ]] \
        || ! grep -Eq 'call i64 %[^ ]+\(i64 %[^)]+\)' <<< "$invoke"; then
        echo "# Dynamic closure adapter did not forward the raw pointer signature on $target"
        echo "$invoke"
        exit 1
    fi
done

echo "> Keep bound and unbound method adapters distinct"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    ir="$workdir/bound-callables-$target.ll"
    if ! out=$(ir_result "$ir"); then
        echo "# Failed to build method adapter fixture for $target"
        echo "$out"
        exit 1
    fi
    for name in unbound_class unbound_struct bound_class; do
        body=$(sed -n "/^define .*__${name}__/,/^}/p" "$ir")
        if [[ -z "$body" || "$body" == *'call '* || "$body" == *'closure_env'* ]]; then
            echo "# Method reference unexpectedly allocated or called a helper on $target"
            echo "$body"
            exit 1
        fi
        if [[ "$name" == unbound_* && "$body" != *'ptr null, 1'* ]]; then
            echo "# Unbound method retained an environment on $target"
            echo "$body"
            exit 1
        fi
    done
    class_adapter=$(sed -n '/^define internal .*valk.closure.adapter.*Counter__read__.*\.unbound"/,/^}/p' "$ir")
    struct_adapter=$(sed -n '/^define internal .*valk.closure.adapter.*Accumulator__add__.*\.unbound"/,/^}/p' "$ir")
    bound_adapter=$(sed -n '/^define internal .*valk.closure.adapter.*Accumulator__add__[0-9]*"/,/^}/p' "$ir")
    if [[ "$class_adapter" != *'(ptr %closure.data, ptr %arg.0, i64 %arg.1)'* \
        || "$struct_adapter" != *'(ptr %closure.data, { ptr, ptr } %arg.0, i64 %arg.1)'* \
        || "$bound_adapter" != *'(ptr %closure.data, i64 %arg.1)'* ]]; then
        echo "# Bound and unbound receiver signatures disagree on $target"
        echo "$class_adapter$struct_adapter$bound_adapter"
        exit 1
    fi
done

echo "> Check cleared references without allocating or checking plain numbers"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    ir="$workdir/cleared-views-$target.ll"
    if ! out=$(ir_result "$ir"); then
        echo "# Failed to build cleared-view fixture for $target"
        echo "$out"
        exit 1
    fi
    for name in read_number read_callback read_pair read_borrowed_pair read_stable_cell; do
        body=$(sed -n "/^define .*__${name}__/,/^}/p" "$ir")
        if [[ -z "$body" || "$body" == *'__ALC_'* || "$body" == *'__Pool__get__'* || "$body" == *'valk.alloc.'* ]]; then
            echo "# Checked view read acquired an allocation on $target"
            echo "$body"
            exit 1
        fi
        presence_count=$(grep -c 'icmp ne ptr' <<< "$body")
        expected=1
        if [ "$name" = read_number ] || [ "$name" = read_stable_cell ]; then expected=0; fi
        if [ "$name" = read_pair ]; then expected=2; fi
        if [ "$presence_count" -ne "$expected" ]; then
            echo "# Unexpected presence checks for $name on $target: $presence_count"
            echo "$body"
            exit 1
        fi
    done
done

echo "> Sort with default and explicit comparators without allocating"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    ir="$workdir/array-sorting-$target.ll"
    if ! out=$(ir_result "$ir"); then
        echo "# Failed to build array-sorting fixture for $target"
        echo "$out"
        exit 1
    fi
    for name in sort_numbers sort_slices sort sort_with sort_sift_down sort_after; do
        body=$(sed -n "/^define .*__${name}__/,/^}/p" "$ir")
        if [[ -z "$body" || "$body" == *'__ALC_'* || "$body" == *'__Pool__get__'* || "$body" == *'valk.alloc.'* ]]; then
            echo "# Array sorting acquired an allocation on $target: $name"
            echo "$body"
            exit 1
        fi
    done
done

echo "> Check enum storage and exhaustive matches without allocating"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    ir="$workdir/enum-safety-$target.ll"
    if ! out=$(ir_result "$ir"); then
        echo "# Failed to build enum-safety fixture for $target"
        echo "$out"
        exit 1
    fi
    for name in read_enum read_zero_enum choose default_enum arithmetic; do
        body=$(sed -n "/^define .*__${name}__/,/^}/p" "$ir")
        if [[ -z "$body" || "$body" == *'__ALC_'* || "$body" == *'__Pool__get__'* || "$body" == *'valk.alloc.'* ]]; then
            echo "# Enum safety acquired an allocation on $target: $name"
            echo "$body"
            exit 1
        fi
        presence_count=$(grep -c 'icmp ne i64' <<< "$body")
        expected=0
        if [ "$name" = read_enum ] || [ "$name" = arithmetic ]; then expected=1; fi
        if [ "$presence_count" -ne "$expected" ]; then
            echo "# Unexpected enum presence checks for $name on $target: $presence_count"
            echo "$body"
            exit 1
        fi
        if [ "$name" = choose ] && [ "$(grep -c 'icmp eq i64' <<< "$body")" -ne 2 ]; then
            echo "# Exhaustive enum match skipped a case check on $target"
            echo "$body"
            exit 1
        fi
        if [ "$name" = arithmetic ] && [ "$(grep -c 'call .*__index__' <<< "$body")" -ne 1 ]; then
            echo "# Enum arithmetic evaluated its index more than once on $target"
            echo "$body"
            exit 1
        fi
    done
done

echo "> Preserve enum borrows without allocating conversion storage"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    ir="$workdir/enum-representations-$target.ll"
    if ! out=$(ir_result "$ir"); then
        echo "# Failed to build enum representation fixture for $target"
        echo "$out"
        exit 1
    fi
    for name in read_optional replace_row read_row; do
        body=$(sed -n "/^define .*__${name}__/,/^}/p" "$ir")
        if [[ -z "$body" || "$body" == *'__ALC_'* || "$body" == *'__Pool__get__'* || "$body" == *'valk.alloc.'* ]]; then
            echo "# Enum borrow acquired an allocation on $target: $name"
            echo "$body"
            exit 1
        fi
    done
done

echo "> Read enum storage and mutate independent copies without allocating"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    ir="$workdir/enum-storage-$target.ll"
    if ! out=$(ir_result "$ir"); then
        echo "# Failed to build enum storage fixture for $target"
        echo "$out"
        exit 1
    fi
    for name in read_enum read_bound read_generic modify_copy; do
        body=$(sed -n "/^define .*__${name}__/,/^}/p" "$ir")
        if [[ -z "$body" || "$body" == *'__ALC_'* || "$body" == *'__Pool__get__'* || "$body" == *'valk.alloc.'* ]]; then
            echo "# Enum storage access acquired an allocation on $target: $name"
            echo "$body"
            exit 1
        fi
    done
done

echo "> Elide closure environments for local bound-method calls, including loops"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    ir="$workdir/bound-locals-$target.ll"
    if ! out=$(ir_result "$ir"); then
        echo "# Failed to build local bound-method fixture for $target"
        echo "$out"
        exit 1
    fi
    for name in local_binding loop_binding from_factory; do
        body=$(sed -n "/^define .*__${name}__/,/^}/p" "$ir")
        if [[ -z "$body" || "$body" == *'__ALC_'* || "$body" == *'__Pool__get__'* || "$body" == *'valk.alloc.'* || "$body" != *'__Counter__add__'* ]]; then
            echo "# Local binding did not become a direct call on $target: $name"
            echo "$body"
            exit 1
        fi
        if [ "$name" = from_factory ] && [ "$(grep -c 'call .*__Factory__make__' <<< "$body")" -ne 1 ]; then
            echo "# Bound receiver expression did not execute once on $target"
            echo "$body"
            exit 1
        fi
    done
done

echo "> Evaluate temporary array borrows once without allocating helper storage"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    ir="$workdir/borrow-evaluation-$target.ll"
    if ! out=$(ir_result "$ir"); then
        echo "# Failed to build borrow evaluation fixture for $target"
        echo "$out"
        exit 1
    fi
    for name in borrow_temporary borrow_nested; do
        body=$(sed -n "/^define .*__${name}__/,/^}/p" "$ir")
        indexes=1
        if [ "$name" = borrow_nested ]; then indexes=2; fi
        if [[ -z "$body" || "$body" == *'__ALC_'* || "$body" == *'__Pool__get__'* || "$body" == *'valk.alloc.'* ]] \
            || [ "$(grep -c 'call .*__Factory__arrays*__' <<< "$body")" -ne 1 ] \
            || [ "$(grep -c 'call .*__Factory__index__' <<< "$body")" -ne "$indexes" ]; then
            echo "# Borrow source or index was repeated, or helper storage allocated, on $target: $name"
            echo "$body"
            exit 1
        fi
    done
done

echo "> Keep slice access bounds and storage together without allocating"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    ir="$workdir/index-storage-$target.ll"
    if ! out=$(ir_result "$ir"); then
        echo "# Failed to build slice selection fixture for $target"
        echo "$out"
        exit 1
    fi
    for name in read_selected write_selected borrow_selected range_selected; do
        body=$(sed -n "/^define .*__${name}__/,/^}/p" "$ir")
        if [[ -z "$body" || "$body" == *'__ALC_'* || "$body" == *'__Pool__get__'* || "$body" == *'valk.alloc.'* ]] \
            || [ "$(grep -c 'call .*__Holder__shrink__' <<< "$body")" -ne 1 ]; then
            echo "# Slice selection repeated its index or allocated helper storage on $target: $name"
            echo "$body"
            exit 1
        fi
    done
done

echo "> Evaluate managed-store owners once without allocating helper storage"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    ir="$workdir/owner-stores-$target.ll"
    if ! out=$(ir_result "$ir"); then
        echo "# Failed to build managed-store fixture for $target"
        echo "$out"
        exit 1
    fi
    for name in store_inline store_element store_borrowed_part store_borrowed_item; do
        body=$(sed -n "/^define .*__${name}__/,/^}/p" "$ir")
        if [[ -z "$body" || "$body" == *'__ALC_'* || "$body" == *'__Pool__get__'* || "$body" == *'valk.alloc.'* ]] \
            || [ "$(grep -c 'call .*__Factory__' <<< "$body")" -ne 1 ]; then
            echo "# Store repeated its owner or allocated helper storage on $target: $name"
            echo "$body"
            exit 1
        fi
    done
done

echo "> Borrow managed fixed-array slots without copying their values"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    ir="$workdir/fixed-element-borrows-$target.ll"
    if ! out=$(ir_result "$ir"); then
        echo "# Failed to build fixed-element borrow fixture for $target"
        echo "$out"
        exit 1
    fi
    for name in borrow_nullable borrow_required; do
        body=$(sed -n "/^define .*__${name}__/,/^}/p" "$ir")
        if [[ -z "$body" || "$body" == *'__ALC_'* || "$body" == *'__Pool__get__'* || "$body" == *'valk.alloc.'* || "$body" == *'__property_get__'* ]]; then
            echo "# Fixed-element borrow copied its value or allocated on $target: $name"
            echo "$body"
            exit 1
        fi
    done
done

echo "> Evaluate fixed-range sources and bounds once without helper allocation"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    ir="$workdir/fixed-range-evaluation-$target.ll"
    if ! out=$(ir_result "$ir"); then
        echo "# Failed to build fixed-range fixture for $target"
        echo "$out"
        exit 1
    fi
    for name in copy_property copy_borrowed; do
        body=$(sed -n "/^define .*__${name}__/,/^}/p" "$ir")
        if [[ -z "$body" || "$body" == *'__ALC_'* || "$body" == *'__Pool__get__'* || "$body" == *'valk.alloc.'* ]] \
            || [ "$(grep -c 'call .*__Factory__' <<< "$body")" -ne 2 ] \
            || [ "$(grep -c 'call .*__Factory__start__' <<< "$body")" -ne 1 ]; then
            echo "# Fixed range repeated its source or start, or allocated, on $target: $name"
            echo "$body"
            exit 1
        fi
    done
done

echo "> Preserve matrix row strides without allocating borrow adapters"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    ir="$workdir/matrix-borrows-$target.ll"
    if ! out=$(ir_result "$ir"); then
        echo "# Failed to build matrix borrow fixture for $target"
        echo "$out"
        exit 1
    fi
    for name in borrow_rows row_view read_row; do
        body=$(sed -n "/^define .*__${name}__/,/^}/p" "$ir")
        if [[ -z "$body" || "$body" == *'__ALC_'* || "$body" == *'__Pool__get__'* || "$body" == *'valk.alloc.'* ]]; then
            echo "# Matrix borrow or row access allocated on $target: $name"
            echo "$body"
            exit 1
        fi
        if [ "$name" = read_row ] && [[ "$body" != *'getelementptr [2 x i64]'* ]]; then
            echo "# Matrix access lost its row stride on $target"
            echo "$body"
            exit 1
        fi
    done
done

echo "> Copy bounded matrix pointers with the full row layout and no heap adapter"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    ir="$workdir/pointer-array-copies-$target.ll"
    if ! out=$(ir_result "$ir"); then
        echo "# Failed to build pointer array-copy fixture for $target"
        echo "$out"
        exit 1
    fi
    for name in copy_rows widen_rows; do
        body=$(sed -n "/^define .*__${name}__/,/^}/p" "$ir")
        if [[ -z "$body" || "$body" == *'__ALC_'* || "$body" == *'__Pool__get__'* || "$body" == *'valk.alloc.'* || "$body" != *'load [3 x [2 x i64]]'* ]]; then
            echo "# Pointer copy lost its row layout or allocated on $target: $name"
            echo "$body"
            exit 1
        fi
    done
done

echo "> Call custom iterators with defaults and no heap adapter"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    ir="$workdir/iterator-contracts-$target.ll"
    if ! out=$(ir_result "$ir"); then
        echo "# Failed to build iterator contract fixture for $target"
        echo "$out"
        exit 1
    fi
    for name in default_sum infallible_sum; do
        body=$(sed -n "/^define .*__${name}__/,/^}/p" "$ir")
        if [[ -z "$body" || "$body" == *'__ALC_'* || "$body" == *'__Pool__get__'* || "$body" == *'valk.alloc.'* ]]; then
            echo "# Custom iterator allocated helper storage on $target: $name"
            echo "$body"
            exit 1
        fi
        default=73
        if [ "$name" = infallible_sum ]; then default=19; fi
        if ! grep -q "call .*___next__.*i64 $default)" <<< "$body"; then
            echo "# Custom iterator did not pass its default argument on $target: $name"
            echo "$body"
            exit 1
        fi
    done
done

echo "> Infer custom iterator calls without allocating an adapter"
for target in linux-x64 macos-x64 macos-arm64 win-x64; do
    ir="$workdir/generic-iterators-$target.ll"
    if ! out=$(ir_result "$ir"); then
        echo "# Failed to build iterator contract fixture for $target"
        echo "$out"
        exit 1
    fi
    for name in generic_sum generic_tuple_sum; do
        body=$(sed -n "/^define .*__${name}__/,/^}/p" "$ir")
        if [[ -z "$body" || "$body" == *'__ALC_'* || "$body" == *'__Pool__get__'* || "$body" == *'valk.alloc.'* ]]; then
            echo "# Custom iterator allocated helper storage on $target: $name"
            echo "$body"
            exit 1
        fi
        default=73
        if [ "$name" = generic_tuple_sum ]; then default=19; fi
        if ! grep -q "call .*___next__.*i64 $default)" <<< "$body"; then
            echo "# Custom iterator did not pass its default argument on $target: $name"
            echo "$body"
            exit 1
        fi
    done
done

echo "# All generated-code optimization tests passed"
echo "# Test count: 46"
echo ""
