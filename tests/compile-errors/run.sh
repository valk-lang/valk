#!/bin/bash

# Every case is an independent compiler run, so the cases run in parallel and
# their results are reported in file order.

echo ""
echo "# Test compile errors"

VALK="${VALK:-./valk}"
export VALK

FILEPATH="./tests/compile-errors/errors.txt"
type_dir="./tests/compile-errors"

if [ ! -f "$FILEPATH" ]; then
    echo "Error: File '$FILEPATH' not found"
    exit 1
fi

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
export workdir

jobs=$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)

# Writes "<index>.out" (the case log) and "<index>.fail" when the case fails.
run_error_case() {
    local index="$1" file="$2" msg="$3"
    local inputs=() source_names source_name cmd output status

    if [[ "$file" == "@"* ]]; then
        inputs+=("./tests/compile-errors/${file#@}")
    else
        IFS=',' read -r -a source_names <<< "$file"
        for source_name in "${source_names[@]}"; do
            inputs+=("./tests/compile-errors/$source_name.valk")
        done
    fi
    cmd="$VALK build ${inputs[*]} --no-warn"
    echo "> Run: $cmd" > "$workdir/$index.out"
    output=$("$VALK" build "${inputs[@]}" --no-warn 2>&1)
    status=$?

    if [[ $status -eq 0 ]]; then
        {
            echo "# Build command should have failed, but didnt."
            echo "- File: $file"
            echo "- Cmd: $cmd"
            echo "- Exit code: $status"
            echo "- Output: $output"
        } > "$workdir/$index.fail"
    elif [[ "$output" != *"$msg"* ]]; then
        {
            echo "# Build command did return the correct error message."
            echo "- File: $file"
            echo "- Cmd: $cmd"
            echo "- Exit code: $status"
            echo "- Output: $output"
            echo "- Missing message: $msg"
        } > "$workdir/$index.fail"
    fi
}
export -f run_error_case

run_type_case() {
    local index="$1" compatible="$2" row="$3"
    local t1 t2 sed_t1 sed_t2 input output status

    t1="${row%% <=> *}"
    t2="${row#* <=> }"
    sed_t1="${t1//&/\\&}"
    sed_t2="${t2//&/\\&}"
    sed_t1="${sed_t1//|/\\|}"
    sed_t2="${sed_t2//|/\\|}"

    if [ "$compatible" -eq 1 ]; then
        echo "> Must be compatible: $row" > "$workdir/$index.out"
    else
        echo "> Must be incompatible: $row" > "$workdir/$index.out"
    fi

    input="$workdir/$index.valk"
    sed -e "s|TYPE1|$sed_t1|g" -e "s|TYPE2|$sed_t2|g" \
        "./tests/compile-errors/type-check-template.valk" > "$input"
    output=$("$VALK" build "$input" --no-warn 2>&1)
    status=$?

    if [ "$compatible" -eq 1 ]; then
        if [ "$status" -ne 0 ] || [[ "$output" != *"Compiled in "* ]]; then
            {
                echo "Types: $row"
                echo "Exit code: $status"
                echo "Output: $output"
                echo "Error: Compatible types were not compatible"
            } > "$workdir/$index.fail"
        fi
    elif [ "$status" -eq 0 ] || [[ "$output" != *"Incompatible types"* ]]; then
        {
            echo "Types: $row"
            echo "Exit code: $status"
            echo "Output: $output"
            echo "Error: Incompatible types were not incompatible"
        } > "$workdir/$index.fail"
    fi
}
export -f run_type_case

# Runs the queued cases (NUL-separated: function, index, two arguments) in
# parallel, then prints their logs in order and stops at the first failure.
run_queue() {
    local queue="$1" count="$2" index

    xargs -0 -n 4 -P "$jobs" bash -c '"$@"' _ < "$queue"

    index=0
    while [ "$index" -lt "$count" ]; do
        cat "$workdir/$index.out"
        if [ -f "$workdir/$index.fail" ]; then
            cat "$workdir/$index.fail"
            return 1
        fi
        index=$((index + 1))
    done
}

queue="$workdir/queue"
: > "$queue"
count=0
while IFS=';' read -r file msg; do
    msg="${msg#"${msg%%[![:space:]]*}"}"
    msg="${msg%"${msg##*[![:space:]]}"}"

    if [[ "$file" == "#"* ]]; then
        continue
    fi

    # An empty expectation matches any output, which would make the case vacuous
    if [[ -z "$msg" ]]; then
        echo "# No expected error message for '$file' in $FILEPATH"
        exit 1
    fi

    printf 'run_error_case\0%s\0%s\0%s\0' "$count" "$file" "$msg" >> "$queue"
    count=$((count + 1))
done < "$FILEPATH"

run_queue "$queue" "$count" || exit 1

echo "# All build commands have failed succesfully"
echo "# Test count: $count"

echo ""
echo "# Test type compatibility"

rm -f "$workdir"/*.out "$workdir"/*.fail
: > "$queue"
count=0
queue_types() {
    local list="$1" compatible="$2" row
    while IFS= read -r row || [ -n "$row" ]; do
        row="${row%$'\r'}"
        [ -n "$row" ] || continue
        printf 'run_type_case\0%s\0%s\0%s\0' "$count" "$compatible" "$row" >> "$queue"
        count=$((count + 1))
    done < "$list"
}
queue_types "$type_dir/types-compatible.txt" 1
queue_types "$type_dir/types-incompatible.txt" 0

run_queue "$queue" "$count" || exit 1

echo ""
echo "# Done"
