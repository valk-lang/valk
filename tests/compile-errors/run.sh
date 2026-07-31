#!/bin/bash

echo ""
echo "# Test compile errors"

VALK="${VALK:-./valk}"

# Set the filepath here
FILEPATH="./tests/compile-errors/errors.txt"
count=0

# Check if the file exists
if [ ! -f "$FILEPATH" ]; then
    echo "Error: File '$FILEPATH' not found"
    exit 1
fi

# Read the file line by line
while IFS=';' read -r file msg; do
    # Trim surrounding whitespace. Deliberately not `xargs`, which also parses
    # quotes: an expected message containing an apostrophe ("it's defined as
    # private") made xargs fail and emit only the text before the quote, so those
    # cases silently shrank to matching a single word.
    msg="${msg#"${msg%%[![:space:]]*}"}"
    msg="${msg%"${msg##*[![:space:]]}"}"

    if [[ "$file" == "#"* ]]; then
        continue  # Skips to next iteration
    fi

    # An empty expectation matches any output, which would make the case vacuous
    if [[ -z "$msg" ]]; then
        echo "# No expected error message for '$file' in $FILEPATH"
        exit 1
    fi

    count=$((count+1))
    input="./tests/compile-errors/$file.valk"
    cmd="$VALK build $input --no-warn"
    echo "> Run: $cmd"
    # The rewrite compiler may write diagnostics to stderr (and its runtime
    # can terminate with a non-zero status after reporting them). Capture both
    # streams so the expected diagnostic is still checked reliably.
    output=$("$VALK" build "$input" --no-warn 2>&1)
    status=$?

    # Check if build command failed
    if [[ $status -eq 0 ]]; then
        echo "# Build command should have failed, but didnt."
        echo "- File: $file"
        echo "- Cmd: $cmd"
        echo "- Exit code: $status"
        echo "- Output: $output"
        exit 1
    fi

    # Check if error message is found in the output
    if [[ "$output" != *"$msg"* ]]; then
        echo "# Build command did return the correct error message."
        echo "- File: $file"
        echo "- Cmd: $cmd"
        echo "- Exit code: $status"
        echo "- Output: $output"
        echo "- Missing message: $msg"
        exit 1
    fi

done < "$FILEPATH"

echo "# All build commands have failed succesfully"
echo "# Test count: $count"

echo ""
echo "# Test type compatibility"

type_dir="./tests/compile-errors"
type_workdir=$(mktemp -d)
trap 'rm -rf "$type_workdir"' EXIT
type_input="$type_workdir/type-check.valk"
type_output="$type_workdir/type-check"
case "$(uname -s)" in
    MINGW*|MSYS*) type_output="$type_output.exe" ;;
esac

check_types() {
    local list="$1"
    local compatible="$2"
    local row t1 t2 output status

    while IFS= read -r row || [ -n "$row" ]; do
        row="${row%$'\r'}"
        [ -n "$row" ] || continue
        t1="${row%% <=> *}"
        t2="${row#* <=> }"

        if [ "$compatible" -eq 1 ]; then
            echo "> Must be compatible: $row"
        else
            echo "> Must be incompatible: $row"
        fi

        sed -e "s|TYPE1|$t1|g" -e "s|TYPE2|$t2|g" \
            "$type_dir/type-check-template.valk" > "$type_input"
        output=$("$VALK" build "$type_input" --no-warn -o "$type_output" 2>&1)
        status=$?

        if [ "$compatible" -eq 1 ]; then
            if [ "$status" -ne 0 ] || [[ "$output" != *"Compiled in "* ]]; then
                echo "Types: $row"
                echo "Exit code: $status"
                echo "Output: $output"
                echo "Error: Compatible types were not compatible"
                return 1
            fi
        elif [ "$status" -eq 0 ] || [[ "$output" != *"Incompatible types"* ]]; then
            echo "Types: $row"
            echo "Exit code: $status"
            echo "Output: $output"
            echo "Error: Incompatible types were not incompatible"
            return 1
        fi
    done < "$list"
}

check_types "$type_dir/types-compatible.txt" 1 || exit 1
check_types "$type_dir/types-incompatible.txt" 0 || exit 1

echo ""
echo "# Done"
