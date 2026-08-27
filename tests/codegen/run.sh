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

echo ""
echo "# Test generated-code optimizations"
echo "> Coalesce temporary GC roots across statements"

ir="$workdir/buffer-roots.ll"
out=$("$VALK" build "$DIR/buffer-roots.valk" --ir --no-warn -o "$ir" 2>&1)
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
if [[ "$body" != *"alloca { ptr, ptr, [16 x i8] }"* ]] \
    || [[ "$body" != *"store ptr @\"valk.gc.stack.marker.func."* ]]; then
    echo "# Expected one explicit frame wrapper containing two pointer values"
    echo "$body"
    exit 1
fi

marker_body=$(sed -n '/^define internal void @"valk\.gc\.stack\.marker\.func\..*__coalesced_roots__/,/^}/p' "$ir")
marker_calls=$(grep -c 'call void .*collect_stack_item' <<< "$marker_body")
if [[ "$marker_body" != *"ptr %frame.values, i64 0"* ]] \
    || [[ "$marker_body" != *"ptr %frame.values, i64 8"* ]] \
    || [ "$marker_calls" -ne 2 ]; then
    echo "# Expected the generated frame marker to visit exactly two roots"
    echo "$marker_body"
    exit 1
fi

echo "> Clear managed roots at lexical scope exits"

scope_body=$(sed -n '/^define .*__lexical_scope_roots__/,/^}/p' "$ir")
scope_collect_line=$(grep -n 'call void .*__collect__' <<< "$scope_body" | head -1 | cut -d: -f1)
scope_clear_line=$(grep -n 'llvm.memset.inline.*i8 0, i64 8' <<< "$scope_body" | tail -1 | cut -d: -f1)
if [ -z "$scope_collect_line" ] || [ -z "$scope_clear_line" ] \
    || [ "$scope_clear_line" -ge "$scope_collect_line" ]; then
    echo "# Expected the block-local root to be cleared before collection"
    echo "$scope_body"
    exit 1
fi

coro_helper=$(sed -n '/^define internal void @"valk\.coro\./,/^}/p' "$ir")
if [[ "$coro_helper" != *"alloca { ptr, ptr, [16 x i8] }"* ]] \
    || [[ "$coro_helper" != *"store ptr @\"valk.gc.stack.marker.coro."* ]]; then
    echo "# Expected one explicit coroutine frame wrapper with typed argument and result values"
    echo "$coro_helper"
    exit 1
fi

coro_marker=$(awk '
    /^define internal void @"valk\.gc\.stack\.marker\.coro\./ {
        capture = 1
        body = $0 ORS
        next
    }
    capture {
        body = body $0 ORS
        if ($0 == "}") {
            if (body ~ /\[16 x i8\]/) {
                printf "%s", body
                exit
            }
            capture = 0
            body = ""
        }
    }
' "$ir")
coro_marker_calls=$(grep -c 'call void .*collect_stack_item' <<< "$coro_marker")
if [[ "$coro_marker" != *"ptr %frame.values, i64 0"* ]] \
    || [[ "$coro_marker" != *"ptr %frame.values, i64 8"* ]] \
    || [ "$coro_marker_calls" -ne 2 ]; then
    echo "# Expected the generated coroutine frame marker to visit exactly two roots"
    echo "$coro_marker"
    exit 1
fi

echo "> Keep inline nullable and multi-value GC layouts naturally aligned"

layout_body=$(sed -n '/^define .*__inline_layout_roots__/,/^}/p' "$ir")
layout_marker=$(sed -n '/^define internal void @"valk\.gc\.stack\.marker\.func\..*__inline_layout_roots__/,/^}/p' "$ir")
layout_union=$(sed -n '/^define .*__aligned_layout_union__/,/^}/p' "$ir")
layout_marker_calls=$(grep -c 'call void .*collect_stack_item' <<< "$layout_marker")
layout_eight_offsets=$(grep -c 'getelementptr i8, ptr .*i64 8' <<< "$layout_marker")
layout_one_offsets=$(grep -c 'getelementptr i8, ptr .*i64 1$' <<< "$layout_marker")

if [[ "$layout_body" != *"[2 x { i1, [7 x i8], [8 x i8] }]"* ]] \
    || [[ "$layout_body" != *"alloca { ptr, ptr, [56 x i8] }"* ]] \
    || [[ "$layout_union" != *"insertvalue { i1, ptr }"* ]] \
    || [[ "$layout_union" != *"store { i1, ptr }"* ]]; then
    echo "# Inline nullable or naturally aligned multi-value storage disagreed with its byte layout"
    exit 1
fi

if [[ "$layout_marker" != *"i32 0, i32 2"* ]] \
    || [[ "$layout_marker" != *"ptr %frame.values, i64 32"* ]] \
    || [ "$layout_eight_offsets" -ne 2 ] \
    || [ "$layout_one_offsets" -ne 0 ] \
    || [[ "$layout_marker" != *"load ptr"*"align 8"* ]] \
    || [ "$layout_marker_calls" -ne 3 ]; then
    echo "# Generated frame marker did not follow the aligned inline nullable / multi-value layout"
    echo "$layout_marker"
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
out=$("$VALK" build "$DIR/native-address.valk" --ir --no-warn -o "$address_ir" 2>&1)
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Failed to build native address IR fixture"
    echo "$out"
    exit 1
fi

native_address_body=$(sed -n '/^define .*__native_address_storage__/,/^}/p' "$address_ir")
suspending_address_body=$(sed -n '/^define .*__suspending_address_storage__/,/^}/p' "$address_ir")
microtime_body=$(sed -n '/^define .*__microtime__/,/^}/p' "$address_ir")
if [[ "$native_address_body" != *"alloca"* ]] \
    || [[ "$native_address_body" == *"__Pool__get__"* ]]; then
    echo "# Proven non-suspending address storage did not use the native stack"
    echo "$native_address_body"
    exit 1
fi
if [[ "$microtime_body" != *"alloca"* ]] \
    || [[ "$microtime_body" == *"__Pool__get__"* ]]; then
    echo "# microtime did not keep its address-taken OS structure on the native stack"
    echo "$microtime_body"
    exit 1
fi
if [[ "$suspending_address_body" != *"alloca"* ]] \
    || [[ "$suspending_address_body" == *"__Pool__get__"* ]]; then
    echo "# Transitively suspending address storage did not use its private stack"
    echo "$suspending_address_body"
    exit 1
fi

echo "> Reserve 1 MiB Windows coroutine stacks with a 32 KiB commit"

windows_coro_ir="$workdir/windows-coro-stack.ll"
out=$("$VALK" build "$DIR/native-address.valk" --target win-x64 --ir --no-warn -o "$windows_coro_ir" 2>&1)
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Failed to build Windows coroutine stack IR fixture"
    echo "$out"
    exit 1
fi

if ! grep -q 'call ptr @"CreateFiberEx"(i64 32768, i64 1048576, i32 1,' "$windows_coro_ir" \
    || grep -q 'valk_stack_swap' "$windows_coro_ir"; then
    echo "# Windows coroutines did not use the expected native fiber stack"
    grep -E 'CreateFiberEx|valk_stack_swap' "$windows_coro_ir" || true
    exit 1
fi

echo "> Keep property stores and Array append on their GC fast paths"

fast_path_ir="$workdir/gc-fast-paths.ll"
out=$("$VALK" build "$DIR/gc-fast-paths.valk" --release --ir --no-warn -o "$fast_path_ir" 2>&1)
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

if grep -q 'valk\.gc\.stack\.marker\.func\..*__Array__.*__append__' "$fast_path_ir"; then
    echo "# Array.append installed a GC shadow frame for its non-allocating path"
    exit 1
fi

echo "> Use natural alignment for atomic property accesses"

atomic_ir="$workdir/atomic-alignment.ll"
out=$("$VALK" build "$DIR/atomic-alignment.valk" --ir --no-warn -o "$atomic_ir" 2>&1)
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
out=$("$VALK" build "$DIR/pointer-integer-compare.valk" --target win-x64 --ir --no-warn -o "$pointer_ir" 2>&1)
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
out=$("$VALK" build "$DIR/windows-bool.valk" --target win-x64 --ir --no-warn -o "$windows_bool_ir" 2>&1)
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
out=$("$VALK" build "$DIR/tagged-union-scalars.valk" --ir --no-warn -o "$scalar_ir" 2>&1)
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

if [[ "$int_body" != *"{ i8, [1 x i64] }"* ]] \
    || [[ "$i32_body" != *"{ i8, [1 x i64] }"* ]] \
    || [[ "$u8_body" != *"{ i8, [1 x i64] }"* ]] \
    || [[ "$bool_body" != *"{ i8, [1 x i64] }"* ]] \
    || [[ "$f32_body" != *"{ i8, [1 x i64] }"* ]] \
    || [[ "$f64_body" != *"{ i8, [1 x i64] }"* ]] \
    || [[ "$scalar_only_body" != *"{ i8, [1 x i64] }"* ]] \
    || [[ "$gc_only_body" != *"{ i8, [1 x i64] }"* ]]; then
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
if [[ "$string_compare_body" != *"__String__equal__"* ]]; then
    echo "# Tagged-union equality did not use the active member comparison hook"
    echo "$string_compare_body"
    exit 1
fi

echo "> Keep exported symbols unmangled and reachable"

export_ir="$workdir/export.ll"
out=$("$VALK" build "$DIR/export.valk" --ir --no-warn -o "$export_ir" 2>&1)
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
out=$("$VALK" build "$DIR/shared-pool.valk" --ir --no-warn -o "$pool_ir" 2>&1)
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

bounds_ir="$workdir/fixed-array-bounds.ll"
out=$("$VALK" build "$DIR/fixed-array-bounds.valk" --ir --no-warn -o "$bounds_ir" 2>&1)
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

echo "# All generated-code optimization tests passed"
echo "# Test count: 14"
echo ""
