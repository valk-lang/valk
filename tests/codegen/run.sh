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
if [[ "$body" != *"store i64 2, ptr %valk.gc.stack.count"* ]]; then
    echo "# Expected two temporary root slots"
    echo "$body"
    exit 1
fi

echo "> Store scalar tagged-union alternatives directly in the box"

scalar_ir="$workdir/tagged-union-scalars.ll"
out=$("$VALK" build "$DIR/tagged-union-scalars.valk" --ir --no-warn -o "$scalar_ir" 2>&1)
status=$?
if [ "$status" -ne 0 ]; then
    echo "# Failed to build scalar tagged-union IR fixture"
    echo "$out"
    exit 1
fi

for name in box_int box_i32 box_u8 box_bool box_f32 box_f64; do
    scalar_body=$(sed -n "/^define .*__${name}__/,/^}/p" "$scalar_ir")
    if [ -z "$scalar_body" ]; then
        echo "# Missing $name in generated IR"
        exit 1
    fi
    if [[ "$scalar_body" != *"__Pool__get__"* ]] || [[ "$scalar_body" == *"__Payload__"* ]]; then
        echo "# $name did not use one-word tagged-union storage"
        echo "$scalar_body"
        exit 1
    fi
done

i32_body=$(sed -n '/^define .*__box_i32__/,/^}/p' "$scalar_ir")
u8_body=$(sed -n '/^define .*__box_u8__/,/^}/p' "$scalar_ir")
bool_body=$(sed -n '/^define .*__box_bool__/,/^}/p' "$scalar_ir")
f32_body=$(sed -n '/^define .*__box_f32__/,/^}/p' "$scalar_ir")
f64_body=$(sed -n '/^define .*__box_f64__/,/^}/p' "$scalar_ir")
if [[ "$i32_body" != *"sext i32"* ]] \
    || [[ "$u8_body" != *"zext i8"* ]] \
    || [[ "$bool_body" != *"zext i1"* ]] \
    || [[ "$f32_body" != *"bitcast float"* ]] \
    || [[ "$f32_body" != *"zext i32"* ]] \
    || [[ "$f64_body" != *"bitcast double"* ]]; then
    echo "# Scalar tagged-union encoding did not preserve the source representation"
    exit 1
fi

echo "# All generated-code optimization tests passed"
echo "# Test count: 2"
echo ""
