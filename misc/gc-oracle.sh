#!/bin/bash
# D-15, the differential oracle: builds a deterministic program (--def GC_ORACLE=1) in Grove's
# single-threaded mode and in its forced multi-threaded mode (GROVE_MT=1), runs both, and
# compares the allocation serial numbers of the objects each build still holds at every
# gc.oracle_checkpoint(). A reference recorded with Valk's former collector, when the program
# has one (<program>.live and <program>.stdout next to it), must match the single-threaded build.
#
#   misc/gc-oracle.sh program.valk [program arguments]

set -u
VALK="${VALK:-./valk}"
src="$1"
shift
ref="${src%.valk}"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
[ -n "${ORACLE_KEEP:-}" ] && trap - EXIT && echo "# work: $work"

for mode in st mt; do
    flags=()
    [ "$mode" = mt ] && flags=(--def GROVE_MT=1)
    if ! "$VALK" build "$src" --def GC_ORACLE=1 --def GC_DEBUG=1 "${flags[@]}" --no-warn -o "$work/$mode" > "$work/$mode.log" 2>&1; then
        echo "# Failed to build $src ($mode)"
        cat "$work/$mode.log"
        exit 1
    fi
    VALK_GC_ORACLE="$work/$mode.txt" "$work/$mode" "$@" > "$work/$mode.out" 2>&1
    status=$?
    if [ "$status" -ne 0 ]; then
        echo "# The $mode build of $src exited with $status"
        cat "$work/$mode.out"
        exit 1
    fi
done

# Checkpoint headers ("checkpoint <n> <allocations> <live>"), then each serial as "<n> <serial>"
normalize() {
    awk '$1 == "checkpoint" { n = $2; print "h " $2 " " $3; next } { print "s " n " " $1 }' "$1" | sort -k1,1 -k2,2n -k3,3n
}
normalize "$work/st.txt" > "$work/st.norm"
normalize "$work/mt.txt" > "$work/mt.norm"

checkpoints=$(grep -c "^checkpoint" "$work/st.txt")
if [ "$checkpoints" -eq 0 ]; then
    echo "# $src reached no gc.oracle_checkpoint()"
    exit 1
fi

# compare <name a> <file a> <name b> <file b> <output a> <output b>
compare() {
    if ! cmp -s "$5" "$6"; then
        echo "# $1 and $3 print different output"
        diff "$5" "$6" | head -20
        exit 1
    fi
    if ! diff <(grep "^h" "$2") <(grep "^h" "$4") > "$work/headers.diff"; then
        echo "# The allocation sequences differ (checkpoint, allocations): $1 <, $3 >"
        cat "$work/headers.diff"
        exit 1
    fi
    if ! diff "$2" "$4" > "$work/live.diff"; then
        echo "# Live objects differ (checkpoint, serial): only $1's < ($3 freed it), only $3's > ($1 freed it)"
        head -40 "$work/live.diff"
        exit 1
    fi
}

compare ST "$work/st.norm" MT "$work/mt.norm" "$work/st.out" "$work/mt.out"
if [ -f "$ref.live" ]; then
    compare Valk "$ref.live" ST "$work/st.norm" "$ref.stdout" "$work/st.out"
    echo "# Oracle: $checkpoints checkpoints, the same live objects in both modes and in Valk's reference"
else
    echo "# Oracle: $checkpoints checkpoints, the same live objects in both modes"
fi
