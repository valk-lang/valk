#!/bin/bash

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
    output=$($cmd)

    # Check if build command failed
    if [[ $? -ne 1 ]]; then
        echo "# Build command should have failed, but didnt."
        echo "- File: $file"
        echo "- Cmd: $cmd"
        echo "- Output: $output"
        exit 1
    fi

    # Check if error message is found in the output
    if [[ "$output" != *"$msg"* ]]; then
        echo "# Build command did return the correct error message."
        echo "- File: $file"
        echo "- Cmd: $cmd"
        echo "- Output: $output"
        echo "- Missing mesage: $msg"
        exit 1
    fi

done < "$FILEPATH"

echo "# All build commands have failed succesfully"
echo "# Test count: $count"
