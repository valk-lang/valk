#!/bin/bash

set -u

VALK="${VALK:-./valk}"
DIR="$(cd "$(dirname "$0")" && pwd)"
case "$(uname -s)" in
    MINGW*|MSYS*) DIR="$(cd "$(dirname "$0")" && pwd -W)" ;;
esac

EXE_SUFFIX=""
case "$(uname -s)" in
    MINGW*|MSYS*) EXE_SUFFIX=".exe" ;;
esac

failed=0
count=0

echo ""
echo "# Test GitHub dependency path resolution"

if [ ! -x "$VALK" ] && [ ! -f "$VALK" ]; then
    echo "Error: compiler not found: $VALK"
    exit 1
fi

workdir=$(mktemp -d)
case "$(uname -s)" in
    MINGW*|MSYS*) workdir=$(cygpath -m "$workdir") ;;
esac
trap 'rm -rf "$workdir"' EXIT

# Compiler paths are native (`D:\...`) on Windows; match expectations with `/`.
normalize_paths() {
    tr '\\' '/'
}

check_ok() {
    local name="$1"
    local want="$2"
    local fixture="$DIR/$name"
    local exe="$workdir/$name$EXE_SUFFIX"

    count=$((count + 1))
    echo "> Build ok: $name (expect run output: $want)"

    set +e
    out=$("$VALK" build "$fixture" --no-warn -o "$exe" 2>&1)
    status=$?
    set -e

    if [ "$status" -ne 0 ]; then
        echo "# Build should have succeeded: $name"
        echo "- Exit code: $status"
        echo "- Output:"
        echo "$out"
        failed=1
        return
    fi

    set +e
    run_out=$("$exe" 2>&1)
    run_status=$?
    set -e

    if [ "$run_status" -ne 0 ]; then
        echo "# Fixture ran with non-zero exit: $name"
        echo "- Exit code: $run_status"
        echo "- Output:"
        echo "$run_out"
        failed=1
        return
    fi

    if [ "$run_out" != "$want" ]; then
        echo "# Unexpected program output: $name"
        echo "- Want: $want"
        echo "- Got:  $run_out"
        failed=1
        return
    fi
}

check_fail() {
    local name="$1"
    local want="$2"
    local fixture="$DIR/$name"
    local exe="$workdir/$name$EXE_SUFFIX"

    count=$((count + 1))
    echo "> Build fail: $name (expect message: $want)"

    set +e
    out=$("$VALK" build "$fixture" --no-warn -o "$exe" 2>&1)
    status=$?
    set -e
    out=$(printf '%s' "$out" | normalize_paths)

    if [ "$status" -eq 0 ]; then
        echo "# Build should have failed: $name"
        echo "- Output:"
        echo "$out"
        failed=1
        return
    fi

    if [[ "$out" != *"$want"* ]]; then
        echo "# Missing expected diagnostic: $name"
        echo "- Want substring: $want"
        echo "- Output:"
        echo "$out"
        failed=1
        return
    fi
}

# Prefer `current` over `version` and use vendor/github-{user}-{repo}/{current}.
check_ok "github-current" "current-ok"

# When `current` is absent, fall back to `version`.
check_ok "github-version" "version-ok"

# Fall back to the nested layout: vendor/github.com/{user}/{repo}/{version}.
check_ok "github-nested" "nested-ok"

# Fall back to the '@' layout: vendor/github-{user}@{repo}/{version}.
check_ok "github-at" "at-ok"

# Fall back to the dotted vendor layout: vendor/github.com.{user}.{repo}/{version}.
check_ok "github-dotted" "dotted-ok"

# The dashed assoc dir wins when both layouts exist.
check_ok "github-dotted-prefers-new" "dashed-new"

# Among the fallbacks, nested is tried first.
check_ok "github-fallback-order" "nested-first"

# Missing vendor dir reports the new assoc path (not github.com.user.repo).
check_fail "github-missing" "vendor/github-acme-widget/9.9.9"

current_only="$workdir/github-current-prefers"
mkdir -p "$current_only"
cp -a "$DIR/github-version/." "$current_only/"
# Keep version 1.0.0 on disk; set current to 2.0.0 so resolution must miss.
cat > "$current_only/valk.json" <<'EOF'
{
    "dependencies": {
        "widget": {
            "src": "github.com/acme/widget",
            "version": "1.0.0",
            "current": "2.0.0"
        }
    }
}
EOF
count=$((count + 1))
echo "> Build fail: github-current-prefers (expect vendor/github-acme-widget/2.0.0)"
set +e
out=$("$VALK" build "$current_only" --no-warn -o "$workdir/github-current-prefers$EXE_SUFFIX" 2>&1)
status=$?
set -e
out=$(printf '%s' "$out" | normalize_paths)
if [ "$status" -eq 0 ]; then
    echo "# Build should have failed when only version dir exists and current differs"
    echo "- Output:"
    echo "$out"
    failed=1
elif [[ "$out" != *"vendor/github-acme-widget/2.0.0"* ]]; then
    echo "# Missing expected diagnostic for current preference"
    echo "- Want substring: vendor/github-acme-widget/2.0.0"
    echo "- Output:"
    echo "$out"
    failed=1
fi

if [ "$failed" -ne 0 ]; then
    echo "# GitHub dependency path tests failed"
    exit 1
fi

echo "# All GitHub dependency path tests passed"
echo "# Test count: $count"
echo ""
