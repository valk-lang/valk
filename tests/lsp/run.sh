#!/bin/bash

set -u

VALK="${VALK:-./valk}"

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

workdir=$(mktemp -d)
case "$(uname -s)" in
    MINGW*|MSYS*) workdir=$(cygpath -m "$workdir") ;;
esac
trap 'rm -rf "$workdir"' EXIT

if [ ! -x "$VALK" ] && [ ! -f "$VALK" ]; then
    echo "Error: compiler not found: $VALK"
    exit 1
fi

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

json_escape() {
    sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/\\t/g' -e 's/\r//g' | awk '{printf "%s\\n", $0}'
}

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

notify_open_path() {
    local text
    text=$(json_escape < "$1")
    printf '{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file://%s","text":"%s"}}}' \
        "$1" "$text"
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

check_absent "compile-time print stays out of LSP stdout" 'LSP_PRINT_MUST_NOT_ESCAPE' \
    "$(notify_save print.valk)"

check_with_init "initialization options enable live diagnostics" '"message":"Unknown identifier: buffer_only_xyz"' "$init_live" \
    "$(notify_change diag.valk '[{"range":{"start":{"line":2,"character":12},"end":{"line":2,"character":16}},"text":"buffer"},{"range":{"start":{"line":2,"character":19},"end":{"line":2,"character":22}},"text":"only_xyz"}]')"

check "workspace configuration enables live diagnostics" '"message":"Unknown identifier: configured_xyz"' \
    "$(notify_config change)" \
    "$(notify_change diag.valk '[{"range":{"start":{"line":2,"character":12},"end":{"line":2,"character":20}},"text":"configured_xyz"}]')"

check_absent "live diagnostics are disabled by default" '"message":"Unknown identifier: default_xyz"' \
    "$(notify_change diag.valk '[{"range":{"start":{"line":2,"character":12},"end":{"line":2,"character":20}},"text":"default_xyz"}]')"
check_absent_with_init "workspace configuration can restore save-only diagnostics" '"message":"Unknown identifier: saved_xyz"' "$init_live" \
    "$(notify_config save)" \
    "$(notify_change diag.valk '[{"range":{"start":{"line":2,"character":12},"end":{"line":2,"character":20}},"text":"saved_xyz"}]')"

check "diagnostic ranges use UTF-16 columns" '"start":{"line":2,"character":19}' \
    "$(notify_open diag.valk 's/println(nope_xyz)/println("🐔" + nope_xyz)/')"

# `helper` on line 8 is declared on line 1 (0-based line 0)
check "definition of a function" '"line":0' \
    "$(request textDocument/definition nav.valk 7 14)"

# `total` on line 8 is declared by the `let` on line 6 (0-based line 5, col 4)
check "definition of a local" '"line":5,"character":4' \
    "$(request textDocument/definition nav.valk 7 21)"

check "definition inside a test body" '"line":0' \
    "$(request textDocument/definition test-body.valk 6 17)"

# `double` on line 10 is declared on line 15 (0-based line 14)
check "definition of a method inside a test body" '"line":14' \
    "$(request textDocument/definition test-body.valk 9 33)"

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

# `fs.` likewise, and private members of another package must not be offered
check "namespace completion" '"label":"cwd"' \
    "$(request textDocument/completion namespace.valk 3 7)"

count=$((count + 1))
echo "> namespace completion hides private members"
stream="$(frame "$init")$(frame "$(request textDocument/completion namespace.valk 3 7)")"
out=$(printf '%s' "$stream" | "$VALK" lsp run 2>&1)
case "$out" in
    *'"label":"stat"'*)
        echo "# Private function 'fs.stat' was offered by completion"
        echo "$out"
        failed=1
        ;;
esac

# Scope completion on a resolvable identifier: locals, functions and namespaces
check "scope completion" '"label":"total"' \
    "$(request textDocument/completion nav.valk 7 15)"

check "diagnostics report every broken function (1/3)" '"message":"Unknown identifier: bad_one_xyz"' \
    "$(notify_save multi-error.valk)"
check "diagnostics report every broken function (2/3)" '"message":"Unknown identifier: bad_two_xyz"' \
    "$(notify_save multi-error.valk)"
check "diagnostics report every broken function (3/3)" "Expected 'uint', got 'String'" \
    "$(notify_save multi-error.valk)"

count=$((count + 1))
echo "> CLI prints exactly one error for the same file"
cli_out=$("$VALK" build "$DIR/multi-error.valk" --no-warn 2>&1)
cli_errors=$(printf '%s\n' "$cli_out" | grep -c '^# Error')
if [ "$cli_errors" -ne 1 ]; then
    echo "# CLI should report exactly one error, got $cli_errors"
    echo "$cli_out"
    failed=1
fi

check "warns about an unused variable" "\"severity\":2,\"message\":\"Variable 'leftover' was declared but never used\"" \
    "$(notify_save warn.valk)"
check "warns about an unused import" "\"severity\":2,\"message\":\"Namespace 'valk.mem' is imported but never used\"" \
    "$(notify_save warn.valk)"

check "a warning's range ends on its own statement" '"range":{"start":{"line":21,"character":4},"end":{"line":21,"character":21}}' \
    "$(notify_save warn.valk)"

count=$((count + 1))
echo "> CLI prints the warnings, and --no-warn suppresses them"
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

check "warns about a write-only variable" "\"severity\":2,\"message\":\"Variable 'dead' is assigned but never read\"" \
    "$(notify_save warn-flow.valk)"
check "warns about unreachable code" '"severity":2,"message":"Unreachable code: this statement can never run"' \
    "$(notify_save warn-flow.valk)"

count=$((count + 1))
echo "> flow warnings do not fire on the cases that read their variable"
flow_out=$("$VALK" build "$DIR/warn-flow.valk" -o "$workdir/warn-flow" 2>&1)
flow_count=$(printf '%s\n' "$flow_out" | grep -cE 'never read|Unreachable|never used')
if [ "$flow_count" -ne 2 ]; then
    echo "# warn-flow.valk should report 2 warnings, got $flow_count"
    echo "$flow_out"
    failed=1
fi

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

check "hover ranges use UTF-16 columns" '"start":{"line":3,"character":20}' \
    "$(request textDocument/hover unicode.valk 3 21)"

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

unicode_copy="$workdir/unicode.valk"
cp "$DIR/unicode.valk" "$unicode_copy"
check "formatting keeps non-ASCII bytes intact" 'em dash — is three bytes' \
    "$(request_path textDocument/formatting "$unicode_copy")"
# Control characters have no short escape and must not go out raw either
check "formatting escapes a control character" 'vertical tab \u000b has no' \
    "$(request_path textDocument/formatting "$unicode_copy")"

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

# range and selectionRange must be distinct objects: the encoder prints a node it already
# wrote as "(recursion)", and the client then refuses the whole reply
check_absent "document symbols encode selectionRange as a real range" '(recursion)' \
    "$(request_doc textDocument/documentSymbol symbols.valk)"
check "document symbols carry a selectionRange" '"selectionRange":{"start":' \
    "$(request_doc textDocument/documentSymbol symbols.valk)"
check "document symbols reply with an array for an unknown file" '"id":2,"result":[]' \
    "$(request_doc textDocument/documentSymbol does-not-exist.valk)"

check "document symbols work on a file with errors" '"name":"three"' \
    "$(request_doc textDocument/documentSymbol multi-error.valk)"

count=$((count + 1))
echo "> document symbols reuse the cached result"
stream="$(frame "$init")$(frame "$(request_doc textDocument/documentSymbol symbols.valk)")$(frame "$(request_doc textDocument/documentSymbol symbols.valk)")"
out=$(printf '%s' "$stream" | "$VALK" lsp run 2>&1)
hits=$(printf '%s' "$out" | grep -o '"name":"sym_helper"' | wc -l | tr -d ' ')
if [ "$hits" != "2" ]; then
    echo "# Expected two document-symbol replies"
    echo "$out" | head -c 2000
    failed=1
fi

check_with_init "an edit invalidates cached document symbols" '"name":"cached_helper"' "$init" \
    "$(request_doc textDocument/documentSymbol symbols.valk)" \
    "$(notify_open symbols.valk 's/sym_helper/cached_helper/')" \
    "$(request_doc textDocument/documentSymbol symbols.valk)"

count=$((count + 1))
echo "> a message split across reads survives an answer in between"
stream="$(frame "$init")$(frame "$(notify_save diag.valk)")$(frame "$(notify_open warn-flow.valk)")"
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

mkdir -p "$workdir/pkg-one/src/check" "$workdir/pkg-two/src/check"
printf '{}\n' > "$workdir/pkg-one/valk.json"
printf '{}\n' > "$workdir/pkg-two/valk.json"
printf 'class PackageValue { value: int (0) }\nfn package_one() {}\nfn inspect_package_value(value: shared PackageValue) int { return value.value }\nfn make_package_value() PackageValue { return PackageValue { value: 1 } }\nfn unopened_bad() { missing_unopened_body }\n' > "$workdir/pkg-one/src/main.valk"
printf 'fn package_two() {}\n' > "$workdir/pkg-two/src/main.valk"
printf 'use main\nfn check_one() {\n    main.package_one()\n    let value = main.PackageValue { value: 1 }\n    let alias = value\n    assert(main.inspect_package_value(value) == 1)\n    assert(alias.value == 1)\n    let made: shared main.PackageValue = main.make_package_value()\n    assert(made.value == 1)\n    missing_from_one\n}\n' > "$workdir/pkg-one/src/check/check.valk"
printf 'use main\nfn check_two() { main.package_two(); missing_from_two }\n' > "$workdir/pkg-two/src/check/check.valk"
count=$((count + 1))
echo "> diagnostics batch open files from multiple packages"
stream="$(frame "$init")$(frame "$(notify_open_path "$workdir/pkg-one/src/check/check.valk")")$(frame "$(notify_open_path "$workdir/pkg-two/src/check/check.valk")")"
out=$(printf '%s' "$stream" | "$VALK" lsp run 2>&1)
case "$out" in
    *'Unknown identifier: missing_from_one'*'Unknown identifier: missing_from_two'*) ;;
    *)
        echo "# Expected diagnostics from both package roots"
        echo "$out" | head -c 2000
        failed=1
        ;;
esac
case "$out" in
    *'Unknown identifier: missing_unopened_body'*)
        echo "# Parsed a function body from an unopened file"
        failed=1
        ;;
esac
case "$out" in
    *'Only a provably unique value graph'*|*'a mutable alias may remain'*)
        echo "# An unavailable uniqueness summary caused a false diagnostic"
        echo "$out" | head -c 2000
        failed=1
        ;;
esac

printf 'fn same_loose_name() { missing_loose_one }\n' > "$workdir/loose-one.valk"
printf 'fn same_loose_name() { missing_loose_two }\n' > "$workdir/loose-two.valk"
count=$((count + 1))
echo "> diagnostics build loose files independently"
stream="$(frame "$init")$(frame "$(notify_open_path "$workdir/loose-one.valk")")$(frame "$(notify_open_path "$workdir/loose-two.valk")")"
out=$(printf '%s' "$stream" | "$VALK" lsp run 2>&1)
case "$out" in
    *'Unknown identifier: missing_loose_one'*'Unknown identifier: missing_loose_two'*) ;;
    *)
        echo "# Expected diagnostics from both loose files"
        echo "$out" | head -c 2000
        failed=1
        ;;
esac
case "$out" in
    *'Name already used: same_loose_name'*)
        echo "# Loose files were incorrectly compiled together"
        failed=1
        ;;
esac

# A buffer whose file was deleted stays open in the editor; it must neither log an error
# nor keep its old diagnostics
printf 'fn gone_fn() { missing_gone_xyz }\n' > "$workdir/gone.valk"
open_gone="$(notify_open_path "$workdir/gone.valk")"
rm "$workdir/gone.valk"
count=$((count + 1))
echo "> diagnostics skip an open buffer whose file was deleted"
stream="$(frame "$init")$(frame "$open_gone")$(frame "$(notify_open_path "$workdir/loose-one.valk")")"
out=$(printf '%s' "$stream" | "$VALK" lsp run 2>&1)
case "$out" in
    *'File/directory not found'*|*'missing_gone_xyz'*)
        echo "# A deleted file was still built"
        echo "$out" | head -c 2000
        failed=1
        ;;
    *"gone.valk\",\"diagnostics\":[]"*) ;;
    *)
        echo "# Expected empty diagnostics for the deleted file"
        echo "$out" | head -c 2000
        failed=1
        ;;
esac

# Every request must be answered, or the client waits for its timeout
check "unsupported request gets an error reply" '"code":-32601' \
    '{"jsonrpc":"2.0","id":2,"method":"textDocument/codeAction","params":{}}'
# Request ids may be strings; they are echoed back rather than coerced
check "request id is echoed verbatim" '"id":"req-abc"' \
    '{"jsonrpc":"2.0","id":"req-abc","method":"textDocument/codeAction","params":{}}'

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
