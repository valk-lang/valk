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

# `timeout` is GNU coreutils; macOS ships neither it nor gtimeout by default.
# The guard below only exists to stop a hung server from wedging CI, so running
# without one is an acceptable fallback — the CI job has its own time limit.
# Windows also has a command named timeout, but it is an interactive console
# delay rather than the GNU process limiter used here.
if command -v timeout >/dev/null 2>&1 && timeout --version 2>/dev/null | grep -q 'GNU coreutils'; then
    TIMEOUT="timeout 60"
elif command -v gtimeout >/dev/null 2>&1; then
    TIMEOUT="gtimeout 60"
else
    TIMEOUT=""
fi
DIR="$(cd "$(dirname "$0")" && pwd)"
case "$(uname -s)" in
    MINGW*|MSYS*) DIR="$(cd "$(dirname "$0")" && pwd -W)" ;;
esac
failed=0
count=0

normalize_paths() {
    tr '\\' '/'
}

echo ""
echo "# Test LSP"

# Scratch dir for the cases that need a file of their own: copies to format, and
# output paths for the builds that check the CLI half of a diagnostic.
workdir=$(mktemp -d)
case "$(uname -s)" in
    MINGW*|MSYS*) workdir=$(cygpath -m "$workdir") ;;
esac
trap 'rm -rf "$workdir"' EXIT

if [ ! -x "$VALK" ] && [ ! -f "$VALK" ]; then
    echo "Error: compiler not found: $VALK"
    exit 1
fi

# Content-Length is a byte count, not a character count. Bash string length uses
# characters in a UTF-8 locale, so force byte semantics for messages containing
# non-ASCII editor buffers.
frame() {
    local LC_ALL=C
    printf 'Content-Length: %d\r\n\r\n%s' "${#1}" "$1"
}

init='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}'
init_live='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"initializationOptions":{"diagnosticsMode":"change"}}}'

# request <method> <file> <line> <character>   (line/character are 0-based)
request() {
    printf '{"jsonrpc":"2.0","id":2,"method":"%s","params":{"textDocument":{"uri":"file://%s"},"position":{"line":%s,"character":%s}}}' \
        "$1" "$DIR/$2" "$3" "$4"
}

notify_save() {
    printf '{"jsonrpc":"2.0","method":"textDocument/didSave","params":{"textDocument":{"uri":"file://%s"}}}' "$DIR/$1"
}

# notify_change <file> <JSON contentChanges array>
notify_change() {
    printf '{"jsonrpc":"2.0","method":"textDocument/didChange","params":{"textDocument":{"uri":"file://%s"},"contentChanges":%s}}' \
        "$DIR/$1" "$2"
}

notify_config() {
    printf '{"jsonrpc":"2.0","method":"workspace/didChangeConfiguration","params":{"settings":{"valk":{"diagnosticsMode":"%s"}}}}' "$1"
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

# check_with_init <name> <expected-substring> <initialize-body> <request-body>...
check_with_init() {
    local name="$1"; shift
    local want="$1"; shift
    local initialize="$1"; shift
    count=$((count + 1))
    echo "> $name"

    local stream
    stream=$(frame "$initialize")
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


# check <name> <expected-substring> <request-body>...
check() {
    local name="$1"; shift
    local want="$1"; shift
    check_with_init "$name" "$want" "$init" "$@"
}


# check_absent_with_init <name> <unexpected-substring> <initialize-body> <body>...
check_absent_with_init() {
    local name="$1"; shift
    local unwanted="$1"; shift
    local initialize="$1"; shift
    count=$((count + 1))
    echo "> $name"

    local stream
    stream=$(frame "$initialize")
    local body
    for body in "$@"; do
        stream="$stream$(frame "$body")"
    done

    local out
    out=$(printf '%s' "$stream" | "$VALK" lsp run 2>&1)
    case "$out" in
        *"$unwanted"*)
            echo "# Unexpected LSP reply"
            echo "- Case: $name"
            echo "- Should not contain: $unwanted"
            echo "- Actual output:"
            echo "$out"
            failed=1
            ;;
    esac
}

check_absent() {
    local name="$1"; shift
    local unwanted="$1"; shift
    check_absent_with_init "$name" "$unwanted" "$init" "$@"
}

# Capabilities are what tells an editor which requests to send at all.
check "initialize advertises providers" '"definitionProvider":true'
check "initialize advertises the outline" '"documentSymbolProvider":true'
check "initialize advertises incremental text sync" '"change":2'
check "initialize advertises save notifications" '"save":true'

# An identifier that does not exist is reported on the line and columns it spans
check "diagnostics on save" '"message":"Unknown identifier: nope_xyz"' \
    "$(notify_save diag.valk)"

# Ranged changes are applied in order, and a burst publishes diagnostics once for
# its final buffer without requiring a save. The second range is relative to the
# result of the first (`nope_xyz` -> `buffer_xyz` -> `buffer_only_xyz`).
check_with_init "initialization options enable live diagnostics" '"message":"Unknown identifier: buffer_only_xyz"' "$init_live" \
    "$(notify_change diag.valk '[{"range":{"start":{"line":2,"character":12},"end":{"line":2,"character":16}},"text":"buffer"},{"range":{"start":{"line":2,"character":19},"end":{"line":2,"character":22}},"text":"only_xyz"}]')"

# The standard configuration notification can enable the same behavior while
# the server is already running.
check "workspace configuration enables live diagnostics" '"message":"Unknown identifier: configured_xyz"' \
    "$(notify_config change)" \
    "$(notify_change diag.valk '[{"range":{"start":{"line":2,"character":12},"end":{"line":2,"character":20}},"text":"configured_xyz"}]')"

# Save-only is the default, and a runtime setting can return an opted-in server
# to it. didChange still updates the buffer; it simply does not run the compiler.
check_absent "live diagnostics are disabled by default" '"message":"Unknown identifier: default_xyz"' \
    "$(notify_change diag.valk '[{"range":{"start":{"line":2,"character":12},"end":{"line":2,"character":20}},"text":"default_xyz"}]')"
check_absent_with_init "workspace configuration can restore save-only diagnostics" '"message":"Unknown identifier: saved_xyz"' "$init_live" \
    "$(notify_config save)" \
    "$(notify_change diag.valk '[{"range":{"start":{"line":2,"character":12},"end":{"line":2,"character":20}},"text":"saved_xyz"}]')"

# LSP columns are UTF-16 code units, not UTF-8 bytes. A chicken is four UTF-8
# bytes but two UTF-16 units, so the unknown identifier begins at character 19.
check "diagnostic ranges use UTF-16 columns" '"start":{"line":2,"character":19}' \
    "$(notify_open diag.valk 's/println(nope_xyz)/println("🐔" + nope_xyz)/')"

# `helper` on line 8 is declared on line 1 (0-based line 0)
check "definition of a function" '"line":0' \
    "$(request textDocument/definition nav.valk 7 14)"

# `total` on line 8 is declared by the `let` on line 6 (0-based line 5, col 4)
check "definition of a local" '"line":5,"character":4' \
    "$(request textDocument/definition nav.valk 7 21)"

# Test bodies are omitted from ordinary builds, but an LSP front-end build must
# still resolve symbols inside the requested file's tests.
check "definition inside a test body" '"line":0' \
    "$(request textDocument/definition test-body.valk 6 17)"

# A method reference inside a test body exercises both the test-body loading
# path and ordinary class-member definition resolution.
check "definition of a method inside a test body" '"line":225' \
    "$(request textDocument/definition ../../tests/src/validate.valk 183 20)"

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

# Warnings are diagnostics too. A file that compiles cleanly still gets reported
# on, and severity 2 is what makes the editor show them as warnings instead of
# errors.
check "warns about an unused variable" "\"severity\":2,\"message\":\"Variable 'leftover' was declared but never used\"" \
    "$(notify_save warn.valk)"
check "warns about an unused import" "\"severity\":2,\"message\":\"Namespace 'valk:mem' is imported but never used\"" \
    "$(notify_save warn.valk)"

# The range has to be the declaration and nothing else. Looking for a continuation
# of a value expression consumes the comments that follow it, so the parser ends
# up lines past the statement; a span taken from there covered all of it, and the
# editor underlined the comments too. warn.valk:22 is `    let leftover = 40`,
# which is 21 characters.
check "a warning's range ends on its own statement" '"range":{"start":{"line":21,"character":4},"end":{"line":21,"character":21}}' \
    "$(notify_save warn.valk)"

# The CLI half of the same split, here for the same reason as the one-error case
# above: the two outputs come from one list of Messages and have to stay apart.
#
# The count is exact on purpose. warn.valk uses everything else it declares, so
# over-reporting fails here, and one of the three warnings sits in a generic body
# that is resolved once per specialization — reporting it twice fails too.
count=$((count + 1))
echo "> CLI prints the warnings, and --no-warn suppresses them"
# Matched on the message rather than the ⚠️ prefix, which helper:msg drops when
# the terminal has no ansi support.
warn_out=$("$VALK" build "$DIR/warn.valk" -o "$workdir/warn" 2>&1)
warn_out=$(printf '%s' "$warn_out" | normalize_paths)
warn_count=$(printf '%s\n' "$warn_out" | grep -c 'never used')
if [ "$warn_count" -ne 3 ]; then
    echo "# CLI should report 3 warnings, got $warn_count"
    echo "$warn_out"
    failed=1
fi
# One line each, with a path:line:col a terminal can turn into a link
case "$warn_out" in
    *"never used @ $DIR/warn.valk:22:5"*) ;;
    *)
        echo "# A warning should report its location on the same line"
        echo "$warn_out"
        failed=1
        ;;
esac
nowarn_out=$("$VALK" build "$DIR/warn.valk" --no-warn -o "$workdir/warn-nw" 2>&1)
case "$nowarn_out" in
    *"never used"*)
        echo "# --no-warn should suppress every warning"
        echo "$nowarn_out"
        failed=1
        ;;
esac

# A store nothing ever reads, and a statement nothing can reach. Both are true of
# code that compiles, and both are reported on the declaration or statement itself.
check "warns about a write-only variable" "\"severity\":2,\"message\":\"Variable 'dead' is assigned but never read\"" \
    "$(notify_save warn-flow.valk)"
check "warns about unreachable code" '"severity":2,"message":"Unreachable code: this statement can never run"' \
    "$(notify_save warn-flow.valk)"

# Exact again, and for the same reason: warn-flow.valk collects the cases that
# must stay quiet — a compound assignment, `++`, a single returning branch, a loop
# whose body continues — next to the two that must not.
count=$((count + 1))
echo "> flow warnings do not fire on the cases that read their variable"
flow_out=$("$VALK" build "$DIR/warn-flow.valk" -o "$workdir/warn-flow" 2>&1)
flow_count=$(printf '%s\n' "$flow_out" | grep -cE 'never read|Unreachable|never used')
if [ "$flow_count" -ne 2 ]; then
    echo "# warn-flow.valk should report 2 warnings, got $flow_count"
    echo "$flow_out"
    failed=1
fi

# Building for one platform must not report what another one needs. Both the
# import and the local in this fixture are referenced only from a `#if` branch,
# so on the target that compiles the branch out they look unused and are not.
count=$((count + 1))
echo "> conditionally compiled code is not reported as unused"
cond_out=$("$VALK" build "$DIR/warn-conditional.valk" -o "$workdir/warn-cond" 2>&1)
case "$cond_out" in
    *"never used"*)
        echo "# A reference inside a compiled-out branch still counts as a reference"
        echo "$cond_out"
        failed=1
        ;;
esac
# Same reasoning for reachability: which branch returns depends on the target
case "$cond_out" in
    *"Unreachable"*)
        echo "# Reachability must not be reported for a statement list holding a #if"
        echo "$cond_out"
        failed=1
        ;;
esac

# Hover reports what the compiler resolved, including inferred types
check "hover on a function" '"value":"```valk\nfn helper(count: uint, label: String) String\n```"' \
    "$(request textDocument/hover nav.valk 7 14)"
check "hover on an inferred local" '"value":"```valk\nString\n```"' \
    "$(request textDocument/hover nav.valk 7 28)"

# `name` follows a non-ASCII character on this line. Both locating the request
# and reporting the hover range must use protocol columns rather than bytes.
check "hover ranges use UTF-16 columns" '"start":{"line":3,"character":20}' \
    "$(request textDocument/hover unicode.valk 3 21)"

# Formatting returns edits and must never touch the file on disk.
#
# Each case formats its own fresh copy. Sharing one file would make these
# order-dependent: a regression that rewrote the file in place would leave it
# already formatted for whatever ran next, and the check below would see no
# change and pass.
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

# Replies carry file content verbatim, so the JSON encoder has to be right about
# bytes it does not recognise. A byte >= 0x80 was being sent as a backslash
# followed by whatever the escape table happened to read past its end, which made
# the whole reply unparseable and had the client shut the server down.
unicode_copy="$workdir/unicode.valk"
cp "$DIR/unicode.valk" "$unicode_copy"
check "formatting keeps non-ASCII bytes intact" 'em dash — is three bytes' \
    "$(request_path textDocument/formatting "$unicode_copy")"
# Control characters have no short escape and must not go out raw either
check "formatting escapes a control character" 'vertical tab \u000b has no' \
    "$(request_path textDocument/formatting "$unicode_copy")"

# The outline. Every fixture in this directory belongs to one namespace and is
# loaded together, so a reply that is not filtered to the requested file would
# carry the whole directory's declarations.
check "document symbols list a function with its signature" '"name":"sym_helper","detail":"fn(count: uint) String","kind":12' \
    "$(request_doc textDocument/documentSymbol symbols.valk)"
check "document symbols nest members under their class" '"name":"describe","detail":"fn() String","kind":6' \
    "$(request_doc textDocument/documentSymbol symbols.valk)"
# Declaration kinds the compiler models separately: global, enum, error, trait, struct
check "document symbols cover every declaration kind" '"name":"SymPoint","kind":23' \
    "$(request_doc textDocument/documentSymbol symbols.valk)"
# Source order, so the outline reads like the file rather than like a hash map
check "document symbols come back in source order" '"result":[{"name":"sym_count"' \
    "$(request_doc textDocument/documentSymbol symbols.valk)"

# `$global` declarations (Array, String, Map, …) bind on the build scope rather
# than on a namespace, so the standard library's own symbols reach the same
# collection pass and are kept out by source path alone.
count=$((count + 1))
echo "> document symbols are limited to the requested file"
stream="$(frame "$init")$(frame "$(request_doc textDocument/documentSymbol symbols.valk)")"
out=$(printf '%s' "$stream" | "$VALK" lsp run 2>&1)
case "$out" in
    *'"name":"Array"'*|*'"name":"to_string"'*)
        echo "# The standard library's declarations were reported for symbols.valk"
        echo "$out" | head -c 2000
        failed=1
        ;;
esac

# An outline is most useful while the file is broken, and declarations exist long
# before any body is resolved, so this must not be gated on a clean build.
check "document symbols work on a file with errors" '"name":"three"' \
    "$(request_doc textDocument/documentSymbol multi-error.valk)"

# The server reads stdin 1024 bytes at a time, so a didOpen carrying a real file
# is split across reads and has to be resumed. Answering an earlier message in
# between must not disturb that: the parser's half-read state is the only record
# of where the message left off, and losing it made the server look for headers in
# the middle of the body — dropping the message and every one after it.
#
# The didSave first is what makes this bite: it queues diagnostics, which are
# flushed while the didOpen behind it is still half-read. warn-flow.valk is over
# 1024 bytes, so the split is guaranteed.
count=$((count + 1))
echo "> a message split across reads survives an answer in between"
stream="$(frame "$init")$(frame "$(notify_save diag.valk)")$(frame "$(notify_open warn-flow.valk)")"
# Timed: the same desync leaves bytes that can never parse, and the read loop
# used to spin on them forever rather than stop at end of input.
out=$(printf '%s' "$stream" | $TIMEOUT "$VALK" lsp run 2>&1)
case "$out" in
    *"Variable 'dead' is assigned but never read"*) ;;
    *)
        echo "# The second message was dropped: no diagnostics for warn-flow.valk"
        echo "$out" | head -c 1500
        failed=1
        ;;
esac

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
