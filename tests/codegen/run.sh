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

if [[ "$int_body" != *"{ i64, ptr, [8 x i8] }"* ]] \
    || [[ "$i32_body" != *"{ i64, ptr, [4 x i8] }"* ]] \
    || [[ "$u8_body" != *"{ i64, ptr, [1 x i8] }"* ]] \
    || [[ "$bool_body" != *"{ i64, ptr, [1 x i8] }"* ]] \
    || [[ "$f32_body" != *"{ i64, ptr, [4 x i8] }"* ]] \
    || [[ "$f64_body" != *"{ i64, ptr, [8 x i8] }"* ]] \
    || [[ "$scalar_only_body" != *"{ i64, [8 x i8] }"* ]] \
    || [[ "$gc_only_body" != *"{ i64, ptr }"* ]]; then
    echo "# Tagged-union aggregate layout did not match tag / GC / raw payload fields"
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

echo "# All generated-code optimization tests passed"
echo "# Test count: 2"
echo ""
