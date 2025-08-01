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
    # Remove any trailing whitespace from var2
    msg=$(echo "$msg" | xargs)

    if [[ "$file" == "#"* ]]; then
        continue  # Skips to next iteration
    fi

    count=$((count+1))
    cmd="./valk build ./tests/compile-errors/$file.valk"
    echo "> Run: $cmd"
    output=$($cmd)
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
        echo "- Missing mesage: $msg"
        exit 1
    fi

done < "$FILEPATH"

echo "# All build commands have failed succesfully"
echo "# Test count: $count"

echo ""
echo "# Test type compatibility"
./valk ./tests/compile-errors/type-checks.valk

echo ""
echo "# Done"
