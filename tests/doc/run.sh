#!/bin/bash

set -u

VALK="${VALK:-./valk}"
DIR="$(cd "$(dirname "$0")" && pwd)"
workdir=$(mktemp -d)
case "$(uname -s)" in
    MINGW*|MSYS*) workdir=$(cygpath -m "$workdir") ;;
esac
trap 'rm -rf "$workdir"' EXIT

echo ""
echo "# Test API documentation"
echo "> Preserve generic parameter names"

out=$("$VALK" doc "$DIR/fixture" -o "$workdir/api.json" 2>&1)
status=$?
if [ "$status" -ne 0 ]; then
    echo "$out"
    exit 1
fi

doc=$(<"$workdir/api.json")
if [[ "$doc" != *'"type": "T"'* ]] \
    || [[ "$doc" != *'"return-type": "T"'* ]] \
    || [[ "$doc" != *'"type": "K"'* ]] \
    || [[ "$doc" != *'"type": "V"'* ]] \
    || [[ "$doc" != *'"return-type": "V"'* ]] \
    || [[ "$doc" == *'"type": "any"'* ]] \
    || [[ "$doc" == *'"return-type": "any"'* ]]; then
    echo "# Generic parameter names were not preserved"
    echo "$doc"
    exit 1
fi

echo "# 1/1 documentation tests passed"
