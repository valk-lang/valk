#!/bin/bash

set -u

VALK="${VALK:-./valk}"
DIR="./tests/exit-code"
EXE_SUFFIX=""
case "$(uname -s)" in
    MINGW*|MSYS*) EXE_SUFFIX=".exe" ;;
esac
failed=0
count=0

echo ""
echo "# Test main() exit codes"

if [ ! -x "$VALK" ] && [ ! -f "$VALK" ]; then
    echo "Error: compiler not found: $VALK"
    exit 1
fi

workdir=$(mktemp -d)
if [ -n "$EXE_SUFFIX" ]; then
    workdir=$(cygpath -m "$workdir")
fi
trap 'rm -rf "$workdir"' EXIT

# fixture:expected exit status[:expected output substring]
cases="return-3:3 return-0:0 void-main:0 return-int:7 unbound-bounds:1 named-unbound-bounds:1 fixed-array-write-bounds:1 fixed-array-range-bounds:1 unbound-range-bounds:1 named-unbound-range-bounds:1 named-unbound-write-bounds:1 array-set-expand-overflow:1 gc-alloc-overflow:1"

cases="$cases unhandled-error:1 array-bounds:1 array-write-bounds:1 slice-bounds:1 slice-write-bounds:1 ref-slice-bounds:1 ref-slice-range-bounds:1 slice-empty-element:1 each-empty-element:1 view-cleared-element:1"
cases="$cases coalesce-panic:1 ternary-panic-first:1 ternary-panic-second:1 ternary-panic-both:1"
cases="$cases logical-panic-left:1 logical-panic-right:1 ternary-panic-condition:1"
cases="$cases ternary-panic-return:1 ternary-panic-vscope:1"
cases="$cases coalesce-panic-typed:1"
cases="$cases slice-header-overflow:1 string-header-overflow:1"
cases="$cases enum-view-bounds:1"
cases="$cases slice-replaced-read:1 slice-replaced-write:1 slice-replaced-borrow:1 slice-replaced-range:1 slice-replaced-local:1"
cases="$cases fixed-element-borrow-bounds:1"
cases="$cases fixed-range-copy-bounds:1"
cases="$cases matrix-borrow-row-bounds:1 matrix-borrow-column-bounds:1"
cases="$cases division-by-zero:1 division-overflow:1 remainder-by-zero:1 shift-count-overflow:1 shift-count-negative:1 division-literal-minus-one:1"
cases="$cases panic-in-thread:1"
cases="$cases global-init-print:0 global-init-abort:1 global-init-error:1"
cases="$cases division-by-zero-line:1:division-by-zero-line.valk:4 shift-count-line:1:shift-count-line.valk:3"
# Panic locations are relative to the package root, or the working directory
# for loose files; a dependency names its package
cases="$cases panic-line:1:tests/exit-code/panic-line.valk:2 fixed-array-bounds:1:tests/exit-code/fixed-array-bounds.valk:4"
cases="$cases panic-in-library:1:ByteBuffer.valk:85"
# Windows delivers the overflow exception only when it can still push a frame
if [ -z "$EXE_SUFFIX" ]; then
    cases="$cases stack-overflow:1 stack-overflow-coroutine:1 stack-overflow-thread:1"
fi

# Each case builds and runs on its own, so the cases run in parallel and
# report in list order. A case writes "<index>.out" and "<index>.fail".
export VALK DIR workdir EXE_SUFFIX
run_case() {
    local index="$1" name="$2" want="$3" text="${4:-}"
    local input="$DIR/$name.valk" exe="$workdir/$name$EXE_SUFFIX" out status output got
    local log="$workdir/$index.out" fail="$workdir/$index.fail"

    if [ ! -f "$input" ]; then
        echo "# Missing fixture: $input" > "$log"
        : > "$fail"
        return
    fi

    echo "> Run: $VALK build $input -o $exe (expect exit $want)" > "$log"
    out=$("$VALK" build "$input" --no-warn -o "$exe" 2>&1)
    status=$?
    if [ "$status" -ne 0 ]; then
        {
            echo "# Build failed"
            echo "- File: $input"
            echo "- Exit code: $status"
            echo "- Output:"
            echo "$out"
        } >> "$log"
        : > "$fail"
        return
    fi

    output=$("$exe" 2>&1)
    got=$?

    if [[ "$name" == *-panic* ]] && [[ "$output" != *"Conditional panic reached"* ]]; then
        echo "# Missing conditional panic message: $output" >> "$log"
        : > "$fail"
    fi

    if [ "$name" = "unhandled-error" ] && [[ "$output" != *"Unhandled error 'Failure.failed' at tests/exit-code/unhandled-error.valk:8"* ]]; then
        echo "# Missing unhandled error name or source location: $output" >> "$log"
        : > "$fail"
    fi

    if [ "$name" = "panic-line" ] && [[ "$output" != *"Explicit panic at tests/exit-code/panic-line.valk:2"* ]]; then
        echo "# Missing panic message or source location: $output" >> "$log"
        : > "$fail"
    fi

    if [ "$name" = "panic-in-library" ] && [[ "$output" != *"Index out of bounds at src/core/ByteBuffer.valk:85 in package valk"* ]]; then
        echo "# Missing library panic location or package name: $output" >> "$log"
        : > "$fail"
    fi

    if [[ "$name" == *-header-overflow ]] && [[ "$output" != *"Slice length is too large"* ]]; then
        echo "# Missing sequence allocation overflow message: $output" >> "$log"
        : > "$fail"
    fi

    if [ -n "$text" ] && [[ "$output" != *"$text"* ]]; then
        echo "# Missing expected output '$text': $output" >> "$log"
        : > "$fail"
    fi

    if [ "$got" -ne "$want" ]; then
        {
            echo "# Wrong exit status"
            echo "- File: $input"
            echo "- Expected: $want"
            echo "- Actual: $got"
        } >> "$log"
        : > "$fail"
    fi
}
export -f run_case

for case in $cases; do
    job="$workdir/job-$count.sh"
    name="${case%%:*}"
    rest="${case#*:}"
    want="${rest%%:*}"
    text=""
    if [ "$rest" != "$want" ]; then text="${rest#*:}"; fi
    printf "run_case '%s' '%s' '%s' '%s'\n" "$count" "$name" "$want" "$text" > "$job"
    count=$((count + 1))
done

# Every build spawns a worker per core, and each worker has an io_uring ring
# that counts against the locked-memory limit of the whole user
cores=$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)
jobs=$((40 / (cores + 1)))
if [ "$jobs" -lt 1 ]; then jobs=1; fi
set +e
ls "$workdir"/job-*.sh | xargs -n 1 -P "$jobs" bash
set -e

index=0
while [ "$index" -lt "$count" ]; do
    cat "$workdir/$index.out"
    if [ -f "$workdir/$index.fail" ]; then
        failed=1
    fi
    index=$((index + 1))
done

count=$((count + 1))
input="$DIR/stdin-read.valk"
exe="$workdir/stdin-read$EXE_SUFFIX"
echo "> Run: pipe input through io.read"
set +e
out=$("$VALK" build "$input" --no-warn -o "$exe" 2>&1)
status=$?
set -e
if [ "$status" -ne 0 ]; then
    echo "# Build failed"
    echo "- File: $input"
    echo "- Exit code: $status"
    echo "- Output:"
    echo "$out"
    failed=1
else
    set +e
    printf 'pingpong' | "$exe" >/dev/null 2>&1
    got=$?
    set -e
    if [ "$got" -ne 0 ]; then
        echo "# io.read failed to read piped standard input"
        echo "- File: $input"
        echo "- Exit code: $got"
        failed=1
    fi
fi

if [ "$count" -eq 0 ]; then
    echo "# No exit-code fixtures found in $DIR"
    exit 1
fi

echo ""
if [ "$failed" -ne 0 ]; then
    echo "# Exit code tests failed"
    exit 1
fi

echo "# All exit code tests passed"
echo "# Test count: $count"
echo ""
