#!/bin/bash

# One build checks most cases: every case becomes a namespace of a generated package that
# is compiled once with `--lint --all-errors`, and each reported error is attributed to its
# case by file path. A case the combined build does not satisfy (an error without a source
# position, one raised only for code reached from `main`, a case in a directory of its own)
# runs as its own compiler process, as every case used to; those run in parallel and their
# results are reported in file order.

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

# The type-check template with the two types filled in, written to `$1`
write_type_case() {
    local input="$1" row="$2"
    local t1 t2 sed_t1 sed_t2

    t1="${row%% <=> *}"
    t2="${row#* <=> }"
    sed_t1="${t1//&/\\&}"
    sed_t2="${t2//&/\\&}"
    sed_t1="${sed_t1//|/\\|}"
    sed_t2="${sed_t2//|/\\|}"
    sed -e "s|TYPE1|$sed_t1|g" -e "s|TYPE2|$sed_t2|g" \
        "./tests/compile-errors/type-check-template.valk" > "$input"
}
export -f write_type_case

run_type_case() {
    local index="$1" compatible="$2" row="$3"
    local input output status

    if [ "$compatible" -eq 1 ]; then
        echo "> Must be compatible: $row" > "$workdir/$index.out"
    else
        echo "> Must be incompatible: $row" > "$workdir/$index.out"
    fi

    input="$workdir/$index.valk"
    write_type_case "$input" "$row"
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
        if [ -f "$workdir/$index.out" ]; then
            cat "$workdir/$index.out"
            if [ -f "$workdir/$index.fail" ]; then
                cat "$workdir/$index.fail"
                return 1
            fi
        fi
        index=$((index + 1))
    done
}

# The generated package: one namespace per case
all="$workdir/all"
mkdir -p "$all/src"
echo '{}' > "$all/valk.json"
echo 'fn main() {}' > "$all/src/main.valk"

case_files=()
case_msgs=()
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

    case_files[count]="$file"
    case_msgs[count]="$msg"
    if [[ "$file" != "@"* ]]; then
        mkdir -p "$all/src/c$count"
        IFS=',' read -r -a source_names <<< "$file"
        for source_name in "${source_names[@]}"; do
            cp "./tests/compile-errors/$source_name.valk" "$all/src/c$count/"
        done
    fi
    count=$((count + 1))
done < "$FILEPATH"

type_rows=()
type_compat=()
type_count=0
queue_types() {
    local list="$1" compatible="$2" row
    while IFS= read -r row || [ -n "$row" ]; do
        row="${row%$'\r'}"
        [ -n "$row" ] || continue
        type_rows[type_count]="$row"
        type_compat[type_count]="$compatible"
        mkdir -p "$all/src/t$type_count"
        write_type_case "$all/src/t$type_count/check.valk" "$row"
        type_count=$((type_count + 1))
    done < "$list"
}
queue_types "$type_dir/types-compatible.txt" 1
queue_types "$type_dir/types-incompatible.txt" 0

# One build; every error line is `path:line:col: error: message`
echo "> Run: $VALK build $all/src --lint --no-warn --all-errors ($count cases, $type_count type rows)"
output=$("$VALK" build "$all/src" --lint --no-warn --all-errors 2>&1)
status=$?
mkdir -p "$workdir/errs"
combined_ok=1
if [ "$status" -ne 1 ]; then
    # Anything but "errors were reported" means the build itself failed: check every case alone
    echo "# The combined build exited with $status; every case runs on its own"
    combined_ok=0
else
    while IFS= read -r line; do
        line="${line//\\//}"
        if [[ "$line" =~ /src/([ct][0-9]+)/[^:]*:[0-9]+:[0-9]+:\ error:\ (.*)$ ]]; then
            echo "${BASH_REMATCH[2]}" >> "$workdir/errs/${BASH_REMATCH[1]}"
        fi
    done <<< "$output"
fi

queue="$workdir/queue"
: > "$queue"
combined=0
index=0
while [ "$index" -lt "$count" ]; do
    file="${case_files[index]}"
    msg="${case_msgs[index]}"
    if [ "$combined_ok" -eq 1 ] && [ -f "$workdir/errs/c$index" ] && grep -qF -- "$msg" "$workdir/errs/c$index"; then
        combined=$((combined + 1))
    else
        printf 'run_error_case\0%s\0%s\0%s\0' "$index" "$file" "$msg" >> "$queue"
    fi
    index=$((index + 1))
done

echo "# $combined cases checked by the combined build, $((count - combined)) on their own"
run_queue "$queue" "$count" || exit 1

echo "# All build commands have failed succesfully"
echo "# Test count: $count"

echo ""
echo "# Test type compatibility"

rm -f "$workdir"/*.out "$workdir"/*.fail
: > "$queue"
# A compatible row passes by having no error, so the rows only count when the build
# demonstrably checked them: some incompatible row must have reported one
types_ok="$combined_ok"
ls "$workdir"/errs/t* > /dev/null 2>&1 || types_ok=0
combined=0
index=0
while [ "$index" -lt "$type_count" ]; do
    row="${type_rows[index]}"
    compatible="${type_compat[index]}"
    satisfied=0
    if [ "$types_ok" -eq 1 ]; then
        if [ "$compatible" -eq 1 ]; then
            [ -f "$workdir/errs/t$index" ] || satisfied=1
        elif [ -f "$workdir/errs/t$index" ] && grep -qF -- "Incompatible types" "$workdir/errs/t$index"; then
            satisfied=1
        fi
    fi
    if [ "$satisfied" -eq 1 ]; then
        combined=$((combined + 1))
    else
        printf 'run_type_case\0%s\0%s\0%s\0' "$index" "$compatible" "$row" >> "$queue"
    fi
    index=$((index + 1))
done

echo "# $combined rows checked by the combined build, $((type_count - combined)) on their own"
run_queue "$queue" "$type_count" || exit 1

echo ""
echo "# Done"
