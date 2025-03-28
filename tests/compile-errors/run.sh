#!/bin/bash

echo "# Test compile errors"

count=0
for file in ./tests/compile-errors/*.valk; do
    count=$((count+1))
    cmd="./valk build $file -r"
    output=$($cmd)
    if [[ $? -ne 1 ]]; then
        echo "# Build command should have failed, but didnt."
        echo "- File: $file"
        echo "- Cmd: $cmd"
        echo "- Output: $output"
        exit 1
    fi
done

echo "# All build commands have failed succesfully"
echo "# Test count: $count"
