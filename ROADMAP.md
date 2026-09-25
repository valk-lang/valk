
# Roadmap

`+` = Done | `~` = Works but needs to be improved | `-` = Todo

```
- Release 0.7.8
+ Template expressions compute: `{{ count + 1 }}`, `* / %`, a leading `-` and parentheses; `+` with text joins it, and dividing by zero is a render error
+ `time.Duration`: `of_days` to `of_us`, whole-unit getters, `+`, `-`, comparisons and text like `1h30m`. `later - earlier` on two `DateTime` values gives one (`since`), `DateTime.add` and `subtract` take one, and `time.sleep(duration)` waits one
+ `DateTime.format` and `from_format` know PHP's other `date()` tokens: `y`, `n`, `M`, `F`, `j`, `D`, `l`, `N`, `G`, `h`, `g`, `A`, `a`, `O`, `P`, `T` and `U` (names in English, parsed without regard to case). Those letters were copied as is before; escape one with `\` to keep it literal (`"\\T"` in a string). `from_iso8601` takes a date alone (midnight UTC) and a lowercase `t` and `z`
+ fs: `create_dir_all` (`mkdir -p`), `temp_dir`, `create_temp_dir` and `create_temp_file` (unique names, private permissions), `glob` (`*`, `?`, `[a-z]`, `**`) and `relative(path, base)`
+ New `valk.random`: `between(min, max)`, `below(n)`, `fraction()`, `chance(p)` and `seed` on a fast per-thread generator (xoshiro256**), and `random.Rng.new(seed)` for repeatable sequences. `Array.shuffle` uses it (unbiased, no system call per element) and takes an optional `Rng`
+ `core.cpu_thread_count()` and `core.cpu_core_count()` are public and work on macOS and Windows too; new `core.process_id()`, `core.hostname()` and `core.env_vars()`. An HTTP server without a `worker_count` now starts one worker per logical CPU on macOS and Windows as well (it used 8 there)
+ `remove_where` and `retain` on `Map`, `HashMap`, `FlatMap` and `HashSet`: remove or keep the entries a function picks, in order, also inside `each` over the map
+ `PublicKey.verify` with `rsa_pss_*` accepts any salt length (like Go), so signatures made with the largest salt (Python's `PSS.MAX_LENGTH`, the `openssl` command) verify; `sign` still uses a salt as long as the hash, as JWT and TLS require
+ HTTP static directories serve `index.html` for a directory path (`/` gives `public/index.html`) and redirect `/docs` to `/docs/` first, like Go, nginx and Caddy; `add_static_dir(path, index: "")` turns it off
+ The HTTP client keeps the trailing slash of a redirect's `Location` (and leaves its query alone), so a `/docs` -> `/docs/` redirect no longer loops until `too_many_redirects`
+ `ansi.supported()` is false when standard output is a pipe or a file, so `./app > out.txt` gets no escape codes; `FORCE_COLOR` or `CLICOLOR_FORCE` (not `0`) turns colors on anyway, for CI logs. Piped test output uses the plain `OK`/`FAIL` rows
+ `sync.Channel.new(0)` makes a rendezvous channel: `send` returns once a receiver took the value (as in Go, Rust's `sync_channel(0)` and crossbeam's `bounded(0)`). `new()` stays unbounded; before, `0` meant unbounded too
+ HTTP `req.parse_json()` throws `json.ParseError` for a body that is not JSON, so a handler can answer 400; `json()` stays lenient and gives an empty object
+ `json` integer readers (`.int`, `int_value`, `get_int`, `to_type`, `decode_to`) accept a whole float such as `3.0`; `3.5` still is not an integer
+ `json` writes a whole float as `2.0` instead of `2`, so it reads back as a float (as Python and serde_json do)
+ A float's `to_string()` (and `_in`, `_into`) without `decimals` gives the shortest text that reads back, like interpolation; it gave 2 decimals, so `(0.0001).to_string()` was `0.00`. Pass `to_string(2)` for the old output
+ `fs.extension` gives no extension for a hidden file such as `.bashrc` (it gave `bashrc`); `.config.json` still gives `json`
+ `ByteReader.parse_int`, `parse_uint` and `parse_float` throw `syntax` without advancing when there is no number, where `read_int` and friends return 0
+ `url.decode_path` (and `_into`) decode a path or route parameter and keep `+` (`url.decode` turns it into a space); the HTTP and WebSocket clients reject a port that is not a number with `invalid_url`
+ `http.download` throws `status` when the final answer is not 2xx, and removes the file on any failure, so an error page is never saved as the download
+ `json.decode` reads an integer beyond the `int` range as the nearest float (like JavaScript) instead of failing; `decode_to` into a `u64` field still reads it exactly
+ `Mutex`, `Lock`, `Channel`, `CancelToken` and `Waker` no longer hold a pipe each: a free lock is one atomic operation, waiters are parked and woken directly (from another thread through one wake handle per thread), and creating them never runs out of file descriptors; a cross-thread channel moved 200k values in 11 ms instead of 1.2 s
+ Removing entries of a `Map`, `HashMap`, `HashSet`, `FlatMap` or JSON object inside `each` over it is safe: every other entry is still visited once, and the index stays 0, 1, 2, ... (it used to skip entries silently)
+ `valk fmt --check` lists files that need formatting and exits 1 without writing; `valk --version` prints the version
+ A dependency whose `src` is neither relative nor on GitHub gets that error instead of "No package named ... found"
+ A `use` of a namespace that does not exist is reported at the `use` (with "did you mean 'use valk.fs'"), and an unknown identifier suggests a close name (`printn` -> `println`)
+ An object compares with `==` to an interface it implements; interpolating a value whose `$to` String hook is not `$auto` says how to fix it
+ A private hook (`$eq`, `$offset`, `$to`, ...) used by an operator elsewhere, such as inside `Array`, is reported at the hook with "mark it public", and the use as a note
+ A `match` on an enum, union, error code or bool that misses cases lists them
+ A `match` used as a value without its type, or a `{ ... }` case in a value `match`, gets an error that shows the right form
+ `let v = f() ! { ... }` with a block that carries on explains that the handler gives no value, instead of "A void expression does not produce a value"
+ A call that can throw in a function without an error type names the error and the ways to handle it (`!`, `!?`, `!!` or adding `!Error` to the signature)
+ LSP: empty hover, definition and completion replies are `null`; completion no longer offers compiler-made names (`&`, main's implicit `cli_args`)
+ `valk ls` colors its output only on a terminal and not when `NO_COLOR` is set
+ Test failures print paths relative to the package root like panics; a `--filter` that matches no test is an error; `valk make` names the line that failed
+ `valk run src alice` points at `valk run src -- alice` when `alice` is not a path
+ `valk fmt` lists the files it changed (and leaves unchanged files untouched); `valk fmt -h` and `valk make -h` have their own help; an unknown command says so; `valk -h` lists `valk lsp`
+ The compiler writes errors and warnings to stderr
+ A panic (and its `--debug` stack trace) is written to stderr, so `./app > out.json` no longer swallows the crash
+ `-o` creates the missing directories of the output path
+ A repeated compiler option (`-o`, `--target`, `--filter`, ...) keeps its last value instead of stopping with an internal panic, so arguments after `valk make name` override the declared ones
+ `crypto.base64_decode` and its variants skip line breaks, so wrapped PEM and MIME bodies decode
+ HTTP: `parse_date` reads the RFC 850 and asctime forms too; an oversized request head gets 431 instead of 413; `code_name` knows every RFC 9110 status
+ HTTP `Response.text`, `Response.html` and the plain-text defaults send `charset=utf-8`
+ HTTP `query()` keeps a key without `=` (`?flag`) with the value `""` instead of dropping it
+ HTTP static directories percent-decode the request path, so `/my%20file.txt` serves `my file.txt` (HTTP/1 and HTTP/2)
+ `ansi.supported` is false when `NO_COLOR` is set (no-color.org); the compiler follows from the next release
+ `to_base` and its variants accept bases up to 36 (digits past 9 are letters); 17 to 36 used to give base 16
+ `String.escape` writes other control characters as `\xHH` and a zero byte as `\0`; `unescape` reads `\xHH` and keeps the backslash of an unknown escape, so the two round trip
+ `fs.copy` gives the copy the permission bits of the source on Linux and macOS, like `cp`
+ `log`: a record field replaces a context field from `with` that has the same key, instead of writing the key twice
+ `json` object members keep their order when one is removed
+ `valk doc` labels an extension that only some key or element types get by its pattern, such as `HashMap[String, T]` and `HashMap[u32, T]`, instead of one concrete instantiation
+ `Array.unique`, `remove_duplicates`, `intersect` and `append_many(.., true)` use a set for integers and `$hash` types (such as `String`) from 128 items: O(n) instead of O(n²)
+ HTTPS on Windows verifies servers with the certificates of the system store; no `cacert.pem` needed
+ HTTP ignores chunk extensions (`5;name=value`) in requests and responses, as RFC 9112 asks
+ `utf8.length` and `utf8.chars()` end an invalid sequence at a byte that cannot continue it, instead of swallowing the next character
+ Markdown: `---` after a blank line and `* * *` are rules, a heading's closing `##` is dropped, link and image titles become a `title` attribute, and backslash escapes work
+ A `value` number constant that does not fit the other operand widens like its literal (`small_u8 + BIG`), and a misfit is reported at the use instead of the declaration
+ JSON writes a `DateTime` as ISO 8601 text and reads it back, a `HashSet` or `Deque` as an array, and a `HashMap` with integer keys as an object (they wrote their internal fields)
+ Tuples as values of `Map`, `HashMap` and `Deque`; one name over an array of tuples holds each element whole (generic `each items as item` got the first member only, and `json.encode` of an array of tuples wrote invalid JSON)
+ A panic in a test names the test and its location and still prints the summary of the tests that finished
+ A TCP connect to a name tries its other addresses when the first refuses: `localhost` reaches a server on `::1` only
+ A bool is not a number in operators: `n + flag`, `flag == 1` and `0 < x < 3` are errors (use `.to(int)`); `&`, `|` and `^` of two bools give a bool (was `u8`)
+ `to_string(decimals)` and `to_scientific_string` round an exact half to the even digit, like C, Python, Go and Rust (`(1.5).to_string(0)` was "1")
+ A statement `match` case with a one-line body may be followed by a `.member` case; the next line no longer continues the body as a method chain
+ One ordering hook (`$lt`, `$gt`, `$lte` or `$gte`) answers all four comparisons; `>=` with only `$lt` no longer gives a wrong answer for equal values, and objects without a hook can no longer be ordered (or sorted) by address
+ TCP connections send small writes right away (`TCP_NODELAY`); file and stream responses no longer wait ~40 ms. `TcpConnection.set_no_delay(false)` turns it off

+ Release 0.7.7
+ Structs by value to and from C: extern and export functions follow the target's C calling convention
+ Struct sizes round up to their own alignment, like C
+ The `x n` of a fill goes on the value's line, so a field named `x` can start a line in a literal
+ `@ref(x)` is typed `*T` for `x` of type `T` (was `ptr`), from the declared type: `*?T` after `isset` too
+ Extern pointer parameters take `&value` or a borrow such as `this`
+ `&fixed[start .. length]` is a view into a fixed array, as it is for arrays and slices
+ Integer `read/write_big/little_endian` take byte slices (`&buf`, `&bytes[i .. 4]`) and panic when too short
+ A package whose `require.valk.min` is newer than the compiler gives a warning, shown with the error when the build fails
+ `x[i] += v` (and the other compound assignments) on Array, HashMap, ByteBuffer and other `$offset` types
+ An import used only in `test` blocks is no longer reported as unused
+ A literal in a ternary takes the type of the other side (`cond ? 0 : n`), or the closest type holding both (`cond ? 300 : small_u8` is u16); `value` number constants type like their literal
+ A variable declared from a number that does not fit where it is used gets a fix: 'let bar: i32 = 360'
+ Tuple members by position: `pair[0]`, `pair[1]`
+ `each 0 .. 4 { ... }` / `each items : stmt` without names
+ `String.trim()`, `ltrim()`, `rtrim()` without an argument remove whitespace
+ `&[$T]` infers `T` from an Array, fixed array, String or ByteBuffer argument

+ Release 0.7.6
+ Faster small HashMaps (linear scan up to 8 entries)
+ Faster JSON encoding and float decoding
+ Integer bit counts and the wide product: `leading_zeros`, `trailing_zeros`, `count_ones`, `mul_wide`
+ Faster MD5/SHA updates on large inputs
+ GC: longer steps between collections when most allocations die young
+ HashMap buckets in groups of 8 (faster misses, inserts and large maps)
+ Faster float to text, and Eisel-Lemire float parsing
+ Faster JSON number scanning
+ Fix a struct literal inside a loop growing the stack until it overflows
+ Regex: a lazy DFA finds matches (5 to 20x faster); the VM only fills in capture groups
+ Fix regex matches that could start inside a multi-byte character
+ Fix an HTTP/2 connection closing without its GOAWAY during a shutdown

+ Release 0.7.5
+ `dim()` in the ansi group of String
+ GC optimizations
+ Time zones in DateTime (bundled time zone database on Windows)
+ `log` namespace
+ Ciphers (AES-GCM, ChaCha20-Poly1305), keys and signatures (RSA, ECDSA, Ed25519) in the crypto namespace
+ base64url encoding
+ TLS client certificates: `Ssl.set_certificate`
+ Fix `ssl_connect` replacing a name set with `Ssl.set_host`
+ Fix `??` staying nullable with an isset-checked local on the right
+ `--debug`: debug info for gdb/lldb/Visual Studio, and stack traces on panics and crashes
+ `each start .. count as i`
+ Servers can require client certificates (`SslServerContext.set_client_ca`, `http.Server.tls_client_ca`), and the HTTP client can send one
+ Arrays convert to `&[T]` views where one is expected
+ Fix a runtime NaN printing as `-nan`

+ Release 0.7.4
+ Make commands in valk.json: `valk make {name}` and `valk ls`
+ Cookies in the http namespace
+ `each`/`lock` take a literal without parentheses

+ Release 0.7.3
+ Method chains over several lines
+ Enum members and clearer errors for `.name` typehints
+ Fix conditions that carry an error handler
+ Close file descriptors properly
+ Use Process for `--run`

+ Release 0.7.2
+ Fix compiler analysis bug
+ Handle HTTP 100 continue request

+ Release 0.7.1
+ Api change guard
+ Enum/error output in `valk doc`
+ fmt correction
+ Selective parsing options
+ Doc generate improvements
+ Websockets
+ Deprecation flagging
+ Reuse address option
+ HTTP server shutdown signal
+ Improve template api (breaking change: RenderOptions.escape is now fn(local &[u8], io.Writer)(uint !io.IoError))
+ Json null value to string is now empty string instead of `"null"`
+ Deprecate flag on unsafe raw pointer functions

+ Release 0.7.0
+ Audit API & language syntax
+ Bug fixes standard library
+ Documentation feature using `///`

+ Release 0.6.4
+ Fix isset on union containing null
+ HTTP/1.0 support
+ HTTP/2.0 optimizations
```

## Maybe

```
- Complete libc integration
- on exit thread/process { ... }
- WASM support
- Allow @undefined for entire struct. E.g. let user = User { @undefined }
- @stack(StructName) -> stackalloc StructName { ... }
-- This is the same as `let x : <StructName> = { ... }`
-- but stackalloc can be used as a value, e.g. in function arguments
```

## Done

```
+ Release 0.6.3
+ Optimize GC (transfer refs)
+ Remove void pointers from the escape analysis

+ Release 0.6.2
+ Language audit + fixes

+ Release 0.6.1
+ Fix enum type bug
+ Fix missing gc roots for embedded files
+ Compiler optimizations
+ GC stack & scan rewrite
+ Data race solution
+ Improve slice syntax

+ Release 0.6.0
+ math namespace
+ more valk lib functions
+ integer .$max/.$min
+ redesign borrows & slices

+ Release 0.5.0
+ Big api overhaul
+ Full security audit
+ Replace unsafe code with safe code
+ Update docs

+ Release 0.4.4
+ Full design doc
+ Stablize the language
+ Benchmarks
+ uslice (cstring) / slice (String)
+ Coroutine growing stack

+ Release 0.4.3
+ Recompile for windows

+ Release 0.4.2
+ Restore embedded LLVM and remove the valkir dependency

+ Release 0.4.0/1
+ Rework Type logic + syntax
+ LSP improvements

+ Release 0.3.5
+ Upgrade valkir version

+ Release 0.3.4
+ Bug fixes (parsing / stdlib / $clone)

+ Release 0.3.3
+ Fix code gen bug
+ Optimize compile speed

+ Release 0.3.2
+ Fix alignment
+ Multi thread IR compiling
+ Upgrade valkir version
+ Remove --no-opt / Add --opt

+ Release 0.3.1
+ Remove llvm-lib dependency
~ Data race solution (Threads done via shared type, MutexValue not done)
+ Remove union gc slot
~ uslice (cstring) / slice (String)

+ Release 0.3.0
+ Cache directory hash fix + race lock
+ Date/time classes
+ Remove LLVM (valkir is the default backend, `--clang` compiles the IR instead)
+ 'export' functions + build library instead of executable
+ Fix access types in extend

+ Release 0.2.6
+ Adjust package directory lookup
+ Improve error payload parsing
+ Fix Array prepend many
+ Implement `--valkir` flag

+ Release 0.2.5
+ Bugfixing

+ Release 0.2.4
+ load "define" from config (alternative for --def)
+ valk command output & usage improvements

+ Release 0.2.3
+ Json improvements
+ Http lowercase header keys
+ Extend access types `~+ -+ -~ -~+`
+ IR & type improvements
+ [start-index .. length] -> calls the $range function (start_index: uint, length: uint)

+ Release 0.2.2
+ Tagged unions
+ Class interfaces
+ Lib bug fixes

+ Release 0.2.1
+ `$default` type value hook
+ LSP improvements
+ Defer statements

+ Release 0.2.0
+ Rewrite entire compiler
+ valk code formatter


+ Release 0.1.14
+ Improve watch command
+ Validator functions
+ Template improvements
+ Package platform (vpkg.dev)
+ Http fixes
+ Rename `--no-default-libs` to `--no-system-libs`
+ Json changes `.get` -> `.get_or`
+ Allow using `main` namespace from another package

+ Release 0.1.13
+ Process class to start a process async

+ Release 0.1.12
+ Fix errors missing payload, e.g. println(E.message) -> crash, because no message was set in the throw code
+ SSL allow to disable ca-cert host verification
+ ByteReader + Rewrite ByteBuffer functions
+ Move 'type' namespace to 'core'
+ Only allow references on local variable
+ each ... skip ... as ... {}

+ Release 0.1.11
+ Rework namespaces
+ Nullable int
+ fnptr -> fn without allocation
+ use error pass handler by default
+ 1 object per file instead of namespace

+ Release 0.1.10
+ options: --no-default-libs --link-arg {arg} --sysroot {path}

+ Release 0.1.9
+ Rework errors

+ Release 0.1.8
+ Multi assign
+ Directory as package src
+ Crypto: base64/sha1/sha256

+ Release 0.1.7
+ --release option
+ json optimizations
+ slice type + array optimizations
+ rework value scope parsing

+ Release 0.1.1 - 0.1.6
+ Optimizations & rewrites

+ Release 0.1.0

+ A `--watch` build argument
+ A `--ir` build argument (output is a single IR file)
+ Improve link command
+ Release 0.0.17

+ Markdown parser
+ Embed file into code `#embed({path})`
+ Rename `#STR` to `#string`
+ A `extern` keyword to define things in .valk files instead .valk.h
+ Remove all header logic - no more `.valk.h` files
+ Release 0.0.16

+ LSP improvements
+ rename `fnRef` -> `fnptr`
+ Release 0.0.15

+ Fix function type type-checking
+ Improve docs
+ Make sure the LSP works on windows
+ Check `TODO` in the code base
+ Release 0.0.14

+ Global cross-thread race lock & .$is_shared builtin
+ Rework stack allocation arrays & structs + init values
+ Update docs
+ Release 0.0.13

+ Syntax clean up
+ Release 0.0.12

+ Re-enable multi threaded compiling
+ Fix closure data binding order
+ Fix cast ptr -> u32/u16/u8
+ Rework async IO
+ Rework stack & coroutines
+ Socket API change
+ Remove `utils` namespace / move ByteBuffer to `type` namespace
+ Rework AST parse flow
+ Async mutexes
+ Release 0.0.11

+ Fix shared gc bug
+ Release 0.0.10

+ template engine improvements
+ Rework arrays from `@array[...]{...}` to `{1, 2, 3}`
+ Basic crypto functions
+ Improve enums
+ Release 0.0.9

+ valk lsp
+ vscode extension
+ Release 0.0.8

+ fn encode[T](value: T) -> fn encode(value: $T)
+ valk doc
+ use "x" as X { a, b as B, c }
+ Allocate stack/heap arrays : @array[u8 x 3]{ 'a', 'b', 'c' }
+ Copy on assign if not pointer or number
~ template engine
+ Release 0.0.7

+ Update HTTP client options
+ Release 0.0.6

+ Allow identifiers for numbers in types, e.g. *[u8 x fs:PATH_MAX_LEN] or global list : [uint x MAX_ITEMS]
+ Add more standard library functions
+ Update docs
+ Release 0.0.5

+ Rework GC to remove reconnect list
+ Http option follow redirects (default: true)
+ Use fs:resolve on all paths in the compiler
+ Warn unused variables / namespaces. And --no-warn/-nw option
+ Type modes (mode Path for String) (extends type but no new properties allowed)
+ Dont use hashes to compare IR. Just compare file content (= faster & more correct)
+ Release 0.0.4

+ Use $lazy properties in compiler
+ Path class for creating correct win/macos/linux paths
+ Release 0.0.3

+ Finish all GC related todos
+ Add more basic features
+ Release 0.0.2

+ Release 0.0.1
```
