#!/usr/bin/env bash
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo"
VALK="${VALK:-./valk}"

for source in examples/*.valk examples/bench/*.valk examples/bench/*/main.valk; do
    echo "> Check $source"
    "$VALK" build "$source" --lint --no-warn
done
