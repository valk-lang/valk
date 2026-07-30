#!/bin/bash

echo ""
echo "# Test compile errors"

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
    cmd="./valk build ./tests/compile-errors/$file.valk --no-warn"
    echo "> Run: $cmd"
    # The rewrite compiler may write diagnostics to stderr (and its runtime
    # can terminate with a non-zero status after reporting them). Capture both
    # streams so the expected diagnostic is still checked reliably.
    output=$($cmd 2>&1)
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
./valk ./tests/compile-errors/type-checks.valk
if [[ $? != 0 ]]; then
    exit 1
fi

echo ""
echo "# Done"
