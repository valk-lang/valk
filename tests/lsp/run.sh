#!/bin/bash
# Drive the language server over stdio and check its replies.
#
# The fixtures are read from disk rather than sent as editor buffers, which keeps
# the JSON-RPC framing in this script free of escaped source text. That is also
# the path a real editor takes for files it has not opened.
#
# The server exits non-zero when stdin closes ("No more input"), so each case
# ignores the exit status and asserts on the reply instead.
#
# Usage (from repo root): ./tests/lsp/run.sh
# Optional: VALK=./valk-new ./tests/lsp/run.sh

set -u

VALK="${VALK:-./valk}"
DIR="$(cd "$(dirname "$0")" && pwd)"
failed=0
count=0

echo ""
echo "# Test LSP"

if [ ! -x "$VALK" ] && [ ! -f "$VALK" ]; then
    echo "Error: compiler not found: $VALK"
    exit 1
fi

# Content-Length framing. The bodies below are ASCII, so character count is byte
# count.
frame() {
    printf 'Content-Length: %d\r\n\r\n%s' "${#1}" "$1"
}

init='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}'

# request <method> <file> <line> <character>   (line/character are 0-based)
request() {
    printf '{"jsonrpc":"2.0","id":2,"method":"%s","params":{"textDocument":{"uri":"file://%s"},"position":{"line":%s,"character":%s}}}' \
        "$1" "$DIR/$2" "$3" "$4"
}

notify_save() {
    printf '{"jsonrpc":"2.0","method":"textDocument/didSave","params":{"textDocument":{"uri":"file://%s"}}}' "$DIR/$1"
}

# request_doc <method> <file>   — a whole-document request, no position
request_doc() {
    printf '{"jsonrpc":"2.0","id":2,"method":"%s","params":{"textDocument":{"uri":"file://%s"}}}' \
        "$1" "$DIR/$2"
}

# Escape stdin as a JSON string body (backslash, quote, tab, CR, then newlines).
# Needed only for didOpen, which carries the editor's buffer.
json_escape() {
    sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/\\t/g' -e 's/\r//g' | awk '{printf "%s\\n", $0}'
}

# notify_open <file> [sed-expr]  — didOpen carrying the file's text, optionally
# transformed, so a buffer that differs from disk can be exercised.
notify_open() {
    local text
    if [ -n "${2:-}" ]; then
        text=$(sed "$2" "$DIR/$1" | json_escape)
    else
        text=$(json_escape < "$DIR/$1")
    fi
    printf '{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file://%s","text":"%s"}}}' \
        "$DIR/$1" "$text"
}

# check <name> <expected-substring> <request-body>...
check() {
    local name="$1"; shift
    local want="$1"; shift
    count=$((count + 1))
    echo "> $name"

    local stream
    stream=$(frame "$init")
    local body
    for body in "$@"; do
        stream="$stream$(frame "$body")"
    done

    local out
    out=$(printf '%s' "$stream" | "$VALK" lsp run 2>&1)

    case "$out" in
        *"$want"*) ;;
        *)
            echo "# Wrong LSP reply"
            echo "- Case: $name"
            echo "- Expected to contain: $want"
            echo "- Actual output:"
            echo "$out"
            failed=1
            ;;
    esac
}

# Capabilities are what tells an editor which requests to send at all.
check "initialize advertises providers" '"definitionProvider":true'

# An identifier that does not exist is reported on the line and columns it spans
check "diagnostics on save" '"message":"Unknown identifier: nope_xyz"' \
    "$(notify_save diag.valk)"

# `helper` on line 8 is declared on line 1 (0-based line 0)
check "definition of a function" '"line":0' \
    "$(request textDocument/definition nav.valk 7 14)"

# `total` on line 8 is declared by the `let` on line 6 (0-based line 5, col 4)
check "definition of a local" '"line":5,"character":4' \
    "$(request textDocument/definition nav.valk 7 21)"

# Cursor inside helper's argument list: the second argument is active
check "signature help" '"label":"fn(count: uint, label: String) String"' \
    "$(request textDocument/signatureHelp nav.valk 7 28)"
check "signature help active parameter" '"activeParameter":1' \
    "$(request textDocument/signatureHelp nav.valk 7 28)"

# `t.` is not valid syntax; completion is expected to answer anyway
check "member completion after a dot" '"label":"describe"' \
    "$(request textDocument/completion member.valk 9 6)"
check "member completion includes properties" '"label":"name"' \
    "$(request textDocument/completion member.valk 9 6)"

# `fs:` likewise, and private members of another package must not be offered
check "namespace completion" '"label":"cwd"' \
    "$(request textDocument/completion namespace.valk 3 7)"

count=$((count + 1))
echo "> namespace completion hides private members"
stream="$(frame "$init")$(frame "$(request textDocument/completion namespace.valk 3 7)")"
out=$(printf '%s' "$stream" | "$VALK" lsp run 2>&1)
case "$out" in
    *'"label":"stat"'*)
        echo "# Private function 'fs:stat' was offered by completion"
        echo "$out"
        failed=1
        ;;
esac

# Scope completion on a resolvable identifier: locals, functions and namespaces
check "scope completion" '"label":"total"' \
    "$(request textDocument/completion nav.valk 7 15)"

# Every broken function is reported, not just the first. The CLI deliberately
# prints only one error; that half of the split is checked below.
check "diagnostics report every broken function (1/3)" '"message":"Unknown identifier: bad_one_xyz"' \
    "$(notify_save multi-error.valk)"
check "diagnostics report every broken function (2/3)" '"message":"Unknown identifier: bad_two_xyz"' \
    "$(notify_save multi-error.valk)"
check "diagnostics report every broken function (3/3)" "Expected 'uint', got 'String'" \
    "$(notify_save multi-error.valk)"

# The CLI half of the same split: collecting many errors must not make the
# command line print more than one.
count=$((count + 1))
echo "> CLI prints exactly one error for the same file"
cli_out=$("$VALK" build "$DIR/multi-error.valk" --no-warn 2>&1)
cli_errors=$(printf '%s\n' "$cli_out" | grep -c '^# Error')
if [ "$cli_errors" -ne 1 ]; then
    echo "# CLI should report exactly one error, got $cli_errors"
    echo "$cli_out"
    failed=1
fi

# Hover reports what the compiler resolved, including inferred types
check "hover on a function" '"value":"```valk\nfn helper(count: uint, label: String) String\n```"' \
    "$(request textDocument/hover nav.valk 7 14)"
check "hover on an inferred local" '"value":"```valk\nString\n```"' \
    "$(request textDocument/hover nav.valk 7 28)"

# Formatting returns edits and must never touch the file on disk.
#
# Each case formats its own fresh copy. Sharing one file would make these
# order-dependent: a regression that rewrote the file in place would leave it
# already formatted for whatever ran next, and the check below would see no
# change and pass.
workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

# request_path <method> <abs-file>
request_path() {
    printf '{"jsonrpc":"2.0","id":2,"method":"%s","params":{"textDocument":{"uri":"file://%s"}}}' "$1" "$2"
}

fmt_copy="$workdir/messy-edit.valk"
cp "$DIR/messy.valk" "$fmt_copy"
check "formatting returns an edit" '"newText":"fn add(a: uint, b: uint) uint {\n    return a + b\n}' \
    "$(request_path textDocument/formatting "$fmt_copy")"

count=$((count + 1))
echo "> formatting leaves the file on disk untouched"
untouched="$workdir/messy-untouched.valk"
cp "$DIR/messy.valk" "$untouched"
printf '%s' "$(frame "$init")$(frame "$(request_path textDocument/formatting "$untouched")")" \
    | "$VALK" lsp run >/dev/null 2>&1
if ! diff -q "$DIR/messy.valk" "$untouched" >/dev/null; then
    echo "# textDocument/formatting rewrote the file; it must only return edits"
    diff -u "$DIR/messy.valk" "$untouched"
    failed=1
fi

# An already-formatted document reports no edits, so the buffer is not made dirty
clean_copy="$workdir/clean.valk"
cp "$DIR/nav.valk" "$clean_copy"
check "formatting a clean file returns no edits" '"result":[]' \
    "$(request_path textDocument/formatting "$clean_copy")"

# didOpen alone publishes diagnostics, and the editor's buffer wins over disk
check "didOpen publishes diagnostics from the buffer" '"message":"Unknown identifier: buffer_only_xyz"' \
    "$(notify_open diag.valk 's/nope_xyz/buffer_only_xyz/')"

# Every request must be answered, or the client waits for its timeout
check "unsupported request gets an error reply" '"code":-32601' \
    '{"jsonrpc":"2.0","id":2,"method":"textDocument/codeAction","params":{}}'
# Request ids may be strings; they are echoed back rather than coerced
check "request id is echoed verbatim" '"id":"req-abc"' \
    '{"jsonrpc":"2.0","id":"req-abc","method":"textDocument/codeAction","params":{}}'

# `$/` messages are optional protocol traffic and must be ignored silently,
# otherwise every cancelled keystroke shows up in the user's output panel.
count=$((count + 1))
echo "> \$/cancelRequest is ignored silently"
stream="$(frame "$init")$(frame '{"jsonrpc":"2.0","method":"$/cancelRequest","params":{"id":1}}')"
out=$(printf '%s' "$stream" | "$VALK" lsp run 2>&1)
case "$out" in
    *Unsupported*)
        echo "# \$/cancelRequest should not be reported as unsupported"
        echo "$out"
        failed=1
        ;;
esac

echo ""
if [ "$failed" -ne 0 ]; then
    echo "# LSP tests failed"
    exit 1
fi

echo "# All LSP tests passed"
echo "# Test count: $count"
echo ""
