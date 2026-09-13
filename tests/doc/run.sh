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

out=$("$VALK" doc "$DIR/fixture" -o "$workdir/api.md" --markdown 2>&1)
status=$?
if [ "$status" -ne 0 ]; then
    echo "$out"
    exit 1
fi

for expect in \
    '"description": "A box holding one value of `T`.\n\n```valk\nBox[uint]{ 3 }.get() == 3\n```"' \
    '"description": "The type of the stored value."' \
    '"description": "Two values of the same type."' \
    '"description": "The first half."' \
    '"description": "Returns `first`."' \
    'Generic documentation is kept on every instantiation."' \
    '"description": "Number of boxes alive in tests."' \
    '"description": "Public alias for a private function."' \
    '"description": "Shouts the value."'; do
    if ! grep -Fq "$expect" "$workdir/api.json"; then
        echo "# Documentation comment is missing from the API JSON: $expect"
        cat "$workdir/api.json"
        exit 1
    fi
done
for absent in \
    '"description": "A plain comment' \
    '"description": "A separator line' \
    '"description": "Detached by'; do
    if grep -Fq "$absent" "$workdir/api.json"; then
        echo "# Undocumented declaration reported a description: $absent"
        cat "$workdir/api.json"
        exit 1
    fi
done

markdown=$(<"$workdir/api.md")
if [[ "$markdown" != *'+ class Box[T]'* ]] \
    || [[ "$markdown" != *'+ get value_type: T'* ]] \
    || [[ "$markdown" != *'+ fn get(value: T) T'* ]] \
    || [[ "$markdown" != *'+ struct Pair[T]'* ]] \
    || [[ "$markdown" != *'+ first: T'* ]] \
    || [[ "$markdown" != *'+ fn left() T'* ]] \
    || [[ "$markdown" != *'+ class Ahead'* ]] \
    || [[ "$markdown" != *'+ fn name() String'* ]] \
    || [[ "$markdown" != *'+ extend Box[String] {'* ]] \
    || [[ "$markdown" != *'+ fn shout() String'* ]] \
    || [[ "$markdown" == *'+ extend Box[uint]'* ]]; then
    echo "# Markdown sorting did not preserve class declarations"
    echo "$markdown"
    exit 1
fi

for expect in \
    '// A box holding one value of `T`.' \
    '    // The type of the stored value.' \
    '// Two values of the same type.' \
    '    // The first half.' \
    '    // Returns `first`.' \
    '// Picks `value` for the caller.' \
    '// Number of boxes alive in tests.' \
    '// Public alias for a private function.' \
    '    // Shouts the value.'; do
    if ! grep -Fq "$expect" "$workdir/api.md"; then
        echo "# Markdown is missing a documentation summary: $expect"
        cat "$workdir/api.md"
        exit 1
    fi
done
if grep -Fq '// Generic documentation is kept' "$workdir/api.md" \
    || grep -Eq '^#+ (Box|choose|box_count|value_type|first)$' "$workdir/api.md"; then
    echo "# Full documentation sections and later paragraphs need --full"
    cat "$workdir/api.md"
    exit 1
fi

echo "> Include full documentation with --full"
out=$("$VALK" doc "$DIR/fixture" -o "$workdir/full.md" --markdown --full 2>&1)
if [ "$?" -ne 0 ]; then
    echo "$out"
    exit 1
fi
for expect in \
    '// A box holding one value of `T`.' \
    '### Box' \
    '#### value_type' \
    'The type of the stored value.' \
    '#### first' \
    '### choose' \
    '### box_count' \
    '### documented_alias' \
    'Public alias for a private function.' \
    'Picks `value` for the caller.' \
    'Generic documentation is kept on every instantiation.' \
    '#### Box[String].shout' \
    'Shouts the value.'; do
    if ! grep -Fq "$expect" "$workdir/full.md"; then
        echo "# Markdown is missing full documentation: $expect"
        cat "$workdir/full.md"
        exit 1
    fi
done

echo "> Preserve public value aliases to private functions"
out=$("$VALK" doc "$DIR/fixture" -o "$workdir/public-api.md" --markdown --no-private 2>&1)
if [ "$?" -ne 0 ]; then
    echo "$out"
    exit 1
fi
public_markdown=$(<"$workdir/public-api.md")
if [[ "$public_markdown" != *'+ value public_callable (hidden_target)'* ]] \
    || [[ "$public_markdown" == *'value private_callable'* ]] \
    || [[ "$public_markdown" == *'fn hidden_target'* ]]; then
    echo "# Value alias visibility is incorrect"
    echo "$public_markdown"
    exit 1
fi

repo=$(cd "$DIR/../.." && pwd)
out=$("$VALK" doc "$repo/lib" -o "$workdir/stdlib-api.md" --markdown --no-private --target linux-x64 2>&1)
status=$?
if [ "$status" -ne 0 ]; then
    echo "$out"
    exit 1
fi
if ! cmp -s "$workdir/stdlib-api.md" "$repo/docs/api.md"; then
    echo "# Committed standard-library API documentation is stale"
    diff -u "$repo/docs/api.md" "$workdir/stdlib-api.md" || true
    exit 1
fi
stdlib_markdown=$(<"$workdir/stdlib-api.md")
if [[ "$stdlib_markdown" != *'+ value collect (ext.valk_gc_collect)'* ]] \
    || [[ "$stdlib_markdown" != *'+ value collect_shared (ext.valk_gc_collect_shared)'* ]]; then
    echo "# Public collector aliases are missing"
    exit 1
fi
if [[ "$stdlib_markdown" != *'+ extend &[T] {'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn view(start_index: uint (0), length: uint (uint.$max)) &[u8]'* ]] \
    || [[ "$stdlib_markdown" != *'+ extend &[u8] {'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn has_ascii_control(allow_tab: bool (false)) bool'* ]] \
    || [[ "$stdlib_markdown" != *'+ extend HashMap[String, T] {'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn utf8.chars() StringChars'* ]] \
    || [[ "$stdlib_markdown" != *'+ get utf8.length: uint'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn ansi.red(bold: bool (false)) String'* ]] \
    || [[ "$stdlib_markdown" != *'+ static fn copy_from_ptr(data: ptr, length: uint) String'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn read(fd: i32, buf: local mut &[u8], offset: uint (uint.$max)) uint !IoError'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn read_sync(fd: i32, buf: local mut &[u8], offset: uint (uint.$max)) uint !IoError'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn read(buf: local mut &[u8]) uint !io:IoError'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn write(fd: i32, data: local &[u8], offset: uint (uint.$max)) uint !IoError'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn recv(fd: i32, buf: local mut &[u8], timeout_ms: uint (5000)) uint !io:IoError'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn write(fd: i32, data: local &[u8], timeout_ms: uint (5000)) uint !io:IoError'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn read(buf: local mut &[u8]) uint !io:IoError'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn write(data: local &[u8]) uint !io:IoError'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn create_dir(path: String, permissions: u32 (0c755)) void !io:IoError'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn delete_all(path: String) void !io:IoError'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn delete_dir(path: String) void !io:IoError'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn delete_file(path: String) void !io:IoError'* ]] \
    || [[ "$stdlib_markdown" == *'+ fn delete(path: String) void !io:IoError'* ]] \
    || [[ "$stdlib_markdown" == *'+ fn delete_recursive(path: String) void !io:IoError'* ]] \
    || [[ "$stdlib_markdown" == *'+ fn mkdir(path: String, permissions: u32 (0c755)) void !io:IoError'* ]] \
    || [[ "$stdlib_markdown" == *'+ fn rmdir(path: String) void !io:IoError'* ]] \
    || [[ "$stdlib_markdown" != *'+ class HashMap[K, T]'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn get(key: K) T !LookupError'* ]] \
    || [[ "$stdlib_markdown" == *'+ class BlowfishContext'* ]] \
    || [[ "$stdlib_markdown" == *'+ global parray'* ]] \
    || [[ "$stdlib_markdown" == *'+ global SIGMA'* ]] \
    || [[ "$stdlib_markdown" == *'+ fn to_slice()'* ]] \
    || [[ "$stdlib_markdown" == *'+ fn clear_part('* ]] \
    || [[ "$stdlib_markdown" == *'+ fn advance(amount: uint) void'* ]]; then
    echo "# Standard-library public API surface is incorrect"
    exit 1
fi
if [[ "$stdlib_markdown" == *'fn write_string(fd:'* ]] \
    || [[ "$stdlib_markdown" == *'fn write_buffer(fd:'* ]] \
    || [[ "$stdlib_markdown" == *'fn write_string(str: String) void !io:IoError'* ]] \
    || [[ "$stdlib_markdown" == *'fn write_buffer(buffer: ByteBuffer) void !io:IoError'* ]] \
    || [[ "$stdlib_markdown" == *'fn send_string(fd:'* ]] \
    || [[ "$stdlib_markdown" == *'fn send_string(data:'* ]] \
    || [[ "$stdlib_markdown" == *'fn send_buffer(data:'* ]] \
    || [[ "$stdlib_markdown" == *'fn send(fd: i32, data: mut &[u8]'* ]] \
    || [[ "$stdlib_markdown" == *'fn send(data: mut &[u8]'* ]] \
    || [[ "$stdlib_markdown" == *'fn read(fd: i32, buf: ByteBuffer'* ]] \
    || [[ "$stdlib_markdown" == *'fn recv(fd: i32, buf: ByteBuffer'* ]] \
    || [[ "$stdlib_markdown" == *'fn recv(buffer: ByteBuffer'* ]] \
    || [[ "$stdlib_markdown" == *'fn read(bytes: uint'* ]] \
    || [[ "$stdlib_markdown" == *'send_all'* ]]; then
    echo "# Standard-library byte I/O still exposes type-specific adapters"
    exit 1
fi

echo "> Keep basic documentation examples current"

guide=$(<"$repo/docs/docs.md")
readme=$(<"$repo/README.md")
if [[ "$guide" != *'let path : fs.Path = "."'* ]] \
    || [[ "$guide" != *'path = path.resolve()'* ]] \
    || [[ "$guide" != *'con.write("PING")'* ]] \
    || [[ "$guide" != *'template.render("example.html", data)'* ]] \
    || [[ "$guide" != *'let running = co s.start()'* ]] \
    || [[ "$guide" != *'await running'* ]] \
    || [[ "$guide" != *'s.request_shutdown(5000)'* ]] \
    || [[ "$guide" == *'server.await()'* ]] \
    || [[ "$stdlib_markdown" == *'ServerHandle'* ]] \
    || [[ "$stdlib_markdown" != *'+ fn start(worker_count: uint (0)) void !HttpError'* ]] \
    || [[ "$guide" == *'On Windows the server always runs a single worker'* ]] \
    || [[ "$guide" == *'one completion port, and therefore to one thread'* ]] \
    || [[ "$guide" == *'con.send("PING")'* ]] \
    || [[ "$guide" == *'sanitize:'* ]] \
    || [[ "$guide" == *'[valk.type](api.md#core)'* ]] \
    || [[ "$guide" == *'Install a package globally'* ]] \
    || [[ "$guide" == *'configured sanitizer'* ]]; then
    echo "# Basic documentation contains stale API examples"
    exit 1
fi
if [[ "$readme" != *'curl -sSL https://valk-lang.dev/install.sh | bash'* ]] \
    || [[ "$readme" == *'curl -s https://valk-lang.dev/install.sh | bash'* ]]; then
    echo "# README contains a stale installation command"
    exit 1
fi

echo "# 4/4 documentation tests passed"
