#!/bin/bash
# D-15, the differential oracle: builds a deterministic program with Valk's collector and with
# Grove (--def GC_ORACLE=1), runs both, and compares the allocation serial numbers of the
# objects each build still holds at every gc.oracle_checkpoint().
#
#   misc/gc-oracle.sh program.valk [program arguments]

set -u
VALK="${VALK:-./valk}"
src="$1"
shift
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
[ -n "${ORACLE_KEEP:-}" ] && trap - EXIT && echo "# work: $work"

for gc in valk grove; do
    if ! "$VALK" build "$src" --def GC_ORACLE=1 --def GC_DEBUG=1 --gc "$gc" --no-warn -o "$work/$gc" > "$work/$gc.log" 2>&1; then
        echo "# Failed to build $src with --gc $gc"
        cat "$work/$gc.log"
        exit 1
    fi
    VALK_GC_ORACLE="$work/$gc.txt" "$work/$gc" "$@" > "$work/$gc.out" 2>&1
    status=$?
    if [ "$status" -ne 0 ]; then
        echo "# The --gc $gc build of $src exited with $status"
        cat "$work/$gc.out"
        exit 1
    fi
done

if ! cmp -s "$work/valk.out" "$work/grove.out"; then
    echo "# The two builds print different output"
    diff "$work/valk.out" "$work/grove.out" | head -20
    exit 1
fi

# Checkpoint headers ("checkpoint <n> <allocations> <live>"), then each serial as "<n> <serial>"
normalize() {
    awk '$1 == "checkpoint" { n = $2; print "h " $2 " " $3; next } { print "s " n " " $1 }' "$1" | sort -k1,1 -k2,2n -k3,3n
}
normalize "$work/valk.txt" > "$work/valk.norm"
normalize "$work/grove.txt" > "$work/grove.norm"

checkpoints=$(grep -c "^checkpoint" "$work/valk.txt")
if [ "$checkpoints" -eq 0 ]; then
    echo "# $src reached no gc.oracle_checkpoint()"
    exit 1
fi
if ! diff <(grep "^h" "$work/valk.norm") <(grep "^h" "$work/grove.norm") > "$work/headers.diff"; then
    echo "# The allocation sequences differ (checkpoint, allocations): Valk <, Grove >"
    cat "$work/headers.diff"
    exit 1
fi
if ! diff "$work/valk.norm" "$work/grove.norm" > "$work/live.diff"; then
    echo "# Live objects differ (checkpoint, serial): only Valk's < (Grove freed it), only Grove's > (Valk freed it)"
    head -40 "$work/live.diff"
    exit 1
fi
echo "# Oracle: $checkpoints checkpoints, the same live objects in both builds"
