#!/bin/bash

# Every place in the fixture that makes an object carries the verdict it must get in a comment

VALK="${VALK:-./valk}"
fixture="./tests/regions/fixture.valk"
out_dir="./debug/regions"
mkdir -p "$out_dir"

echo ""
echo "# Test --region-report"

out=$("$VALK" build "$fixture" --region-report -o "$out_dir/fixture" 2>&1)
status=$?
if [ "$status" -ne 0 ]; then
    echo "$out"
    exit 1
fi

failed=0
count=0
line_nr=0
while IFS= read -r line; do
    line_nr=$((line_nr + 1))
    case "$line" in
        *" // region of "* | *" // frame of "* | *" // heap: "*) ;;
        *) continue ;;
    esac
    expected="${line##* // }"
    count=$((count + 1))
    report=$(printf '%s\n' "$out" | grep -F "fixture.valk:$line_nr  ")
    if [ -z "$report" ]; then
        echo "# Line $line_nr is not in the report: $line"
        failed=1
    elif [ -n "$(printf '%s\n' "$report" | grep -vF "  $expected")" ]; then
        echo "# Line $line_nr, expected '$expected': $report"
        failed=1
    fi
done < "$fixture"

# The program gives the same answer with and without regions
with=$("$out_dir/fixture")
"$VALK" build "$fixture" --no-regions -o "$out_dir/fixture-heap" > /dev/null 2>&1 || { echo "# --no-regions failed to build"; exit 1; }
without=$("$out_dir/fixture-heap")
if [ "$with" != "$without" ] || [ -z "$with" ]; then
    echo "# Output differs: '$with' with regions, '$without' without"
    failed=1
fi
plain=$("$VALK" build "$fixture" --no-regions --region-report -o "$out_dir/fixture-heap" 2>&1)
if [[ "$plain" == *"  region of "* ]]; then
    echo "# --no-regions still reports regions"
    failed=1
fi

if [ "$failed" -ne 0 ]; then
    exit 1
fi
echo "> $count verdicts"
