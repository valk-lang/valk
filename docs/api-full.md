
# Documentation

Namespaces: [ansi](#ansi) | [compress](#compress) | [core](#core) | [coro](#coro) | [crypto](#crypto) | [ext](#ext) | [fs](#fs) | [gc](#gc) | [html](#html) | [http](#http) | [io](#io) | [json](#json) | [log](#log) | [markdown](#markdown) | [math](#math) | [mem](#mem) | [net](#net) | [random](#random) | [regex](#regex) | [signal](#signal) | [sync](#sync) | [template](#template) | [thread](#thread) | [time](#time) | [url](#url) | [validate](#validate)

---

# ansi

## Functions for 'ansi'

```js
// Returns whether standard output shows ANSI escape codes as colors.
+ fn supported() bool
// Returns whether the console output expects UTF-8.
+ fn utf8_supported() bool
```

### supported

Returns whether standard output shows ANSI escape codes as colors.

False when `NO_COLOR` is set to a non-empty value. True when `FORCE_COLOR` or
`CLICOLOR_FORCE` is set to anything but `0`, for logs that keep colors such as CI output.
Otherwise standard output must be a terminal, not a pipe or a file, and `TERM` must
contain `xterm`, `vt`, `ansi`, `linux`, `screen` or `tmux`. The answer is cached after
the first call.

### utf8_supported

Returns whether the console output expects UTF-8.

On Windows this checks that the console output code page is 65001; elsewhere it is
always true.

# compress

## Aliases for 'compress'

```js
// The compression level used when none is given, a balance of speed and size.
+ value COMPRESS_DEFAULT_LEVEL (6)
```

### COMPRESS_DEFAULT_LEVEL

The compression level used when none is given, a balance of speed and size.

## Errors for 'compress'

```js
// Thrown when decompressing DEFLATE, zlib or gzip data fails.
error CompressError (invalid_input, checksum, truncated, too_large) extends (io:IoError)
```

### CompressError

Thrown when decompressing DEFLATE, zlib or gzip data fails.

- `invalid_input`: the data is not a valid stream (bad header, block type, Huffman
  code or distance; zlib preset dictionaries are not supported).
- `checksum`: the gzip CRC-32 and length trailer or the zlib Adler-32 trailer does not
  match the output.
- `truncated`: the stream ends early.
- `too_large`: the output would exceed the caller's `max_size`.

Also carries every `io.IoError` code.

## Enums for 'compress'

```js
// A compressed data format; all three carry the same DEFLATE data.
+ enum Format { deflate, zlib, gzip }
```

### Format

A compressed data format; all three carry the same DEFLATE data.

## Functions for 'compress'

```js
// Returns the Adler-32 checksum (as in zlib) of `data`.
+ fn adler32(data: local &[u8], adler: u32 (1)) u32
// Returns `data` compressed into `format` at `level` (0 stores, 1 is fastest, 9 is smallest).
+ fn compress(data: local &[u8], format: Format, level: uint (COMPRESS_DEFAULT_LEVEL)) String
// Writes `data` compressed into `format` at `level` to `out` and returns the bytes written.
+ fn compress_into(data: local &[u8], out: Writer, format: Format, level: uint (COMPRESS_DEFAULT_LEVEL)) uint !io:IoError
// Returns the CRC-32 (IEEE 802.3, as in gzip, zip and PNG) of `data`.
+ fn crc32(data: local &[u8], crc: u32 (0)) u32
// Returns the decompressed contents of `data`, which must be in `format`.
+ fn decompress(data: local &[u8], format: Format, max_size: uint (0)) String !CompressError
// Writes the decompressed contents of `data` to `out` and returns the bytes written.
+ fn decompress_into(data: local &[u8], out: Writer, format: Format, max_size: uint (0)) uint !CompressError
// Returns `data` compressed as raw DEFLATE; see `compress`.
+ fn deflate(data: local &[u8], level: uint (COMPRESS_DEFAULT_LEVEL)) String
// Writes `data` compressed as raw DEFLATE to `out`; see `compress_into`.
+ fn deflate_into(data: local &[u8], out: Writer, level: uint (COMPRESS_DEFAULT_LEVEL)) uint !io:IoError
// Returns the decompressed contents of gzip `data`.
+ fn gunzip(data: local &[u8], max_size: uint (0)) String !CompressError
// Writes the decompressed contents of gzip `data` to `out`; see `decompress_into`.
+ fn gunzip_into(data: local &[u8], out: Writer, max_size: uint (0)) uint !CompressError
// Returns `data` compressed in the gzip format; see `compress`.
+ fn gzip(data: local &[u8], level: uint (COMPRESS_DEFAULT_LEVEL)) String
// Writes `data` compressed in the gzip format to `out`; see `compress_into`.
+ fn gzip_into(data: local &[u8], out: Writer, level: uint (COMPRESS_DEFAULT_LEVEL)) uint !io:IoError
// Returns the decompressed contents of raw DEFLATE `data`.
+ fn inflate(data: local &[u8], max_size: uint (0)) String !CompressError
// Writes the decompressed contents of raw DEFLATE `data` to `out`; see `decompress_into`.
+ fn inflate_into(data: local &[u8], out: Writer, max_size: uint (0)) uint !CompressError
// Returns the decompressed contents of zlib `data`.
+ fn unzlib(data: local &[u8], max_size: uint (0)) String !CompressError
// Writes the decompressed contents of zlib `data` to `out`; see `decompress_into`.
+ fn unzlib_into(data: local &[u8], out: Writer, max_size: uint (0)) uint !CompressError
// Returns `data` compressed in the zlib format; see `compress`.
+ fn zlib(data: local &[u8], level: uint (COMPRESS_DEFAULT_LEVEL)) String
// Writes `data` compressed in the zlib format to `out`; see `compress_into`.
+ fn zlib_into(data: local &[u8], out: Writer, level: uint (COMPRESS_DEFAULT_LEVEL)) uint !io:IoError
```

### adler32

Returns the Adler-32 checksum (as in zlib) of `data`.

To checksum data in pieces, pass the previous result as `adler`; the default 1 starts a
new checksum.

### compress

Returns `data` compressed into `format` at `level` (0 stores, 1 is fastest, 9 is smallest).

Levels above 9 act as 9.

### compress_into

Writes `data` compressed into `format` at `level` to `out` and returns the bytes written.

The compressed bytes reach `out` in pieces as they are produced, so only the 64 KiB
input window and the current block are held in memory. Throws when `out` fails; bytes
written before a failure stay written.

### crc32

Returns the CRC-32 (IEEE 802.3, as in gzip, zip and PNG) of `data`.

To checksum data in pieces, pass the previous result as `crc`:

```valk
let crc = compress.crc32(first)
crc = compress.crc32(second, crc)
```

### decompress

Returns the decompressed contents of `data`, which must be in `format`.

`max_size` limits the output in bytes (0 means unlimited); guard against decompression
bombs with it when `data` is untrusted. Throws `invalid_input` on malformed data,
`checksum` on a trailer mismatch, `truncated` when the data ends early and `too_large`
when the output would exceed `max_size`. Concatenated gzip members decode as one output,
so bytes after a gzip member must form another member. For `deflate` and `zlib`, bytes
after the end of the stream are ignored.

### decompress_into

Writes the decompressed contents of `data` to `out` and returns the bytes written.

Takes the same `max_size` and throws the same errors as `decompress`, plus the writer's
error when `out` fails; output written before a failure stays written.

### deflate

Returns `data` compressed as raw DEFLATE; see `compress`.

### deflate_into

Writes `data` compressed as raw DEFLATE to `out`; see `compress_into`.

### gunzip

Returns the decompressed contents of gzip `data`.

See `decompress` for `max_size` and the errors thrown.

### gunzip_into

Writes the decompressed contents of gzip `data` to `out`; see `decompress_into`.

### gzip

Returns `data` compressed in the gzip format; see `compress`.

### gzip_into

Writes `data` compressed in the gzip format to `out`; see `compress_into`.

### inflate

Returns the decompressed contents of raw DEFLATE `data`.

See `decompress` for `max_size` and the errors thrown.

### inflate_into

Writes the decompressed contents of raw DEFLATE `data` to `out`; see `decompress_into`.

### unzlib

Returns the decompressed contents of zlib `data`.

See `decompress` for `max_size` and the errors thrown.

### unzlib_into

Writes the decompressed contents of zlib `data` to `out`; see `decompress_into`.

### zlib

Returns `data` compressed in the zlib format; see `compress`.

### zlib_into

Writes `data` compressed in the zlib format to `out`; see `compress_into`.

## Classes for 'compress'

```js
// An `io.Writer` that compresses what is written to it and passes the result to `out`.
+ class Compressor is Writer, Closer {
    // Compresses the remaining input and writes the final block and trailer to `out`.
    + fn close() void !io:IoError
    // Returns a compressor writing `format` data to `out` at `level` (0 stores, 9 is smallest).
    + static fn new(out: Writer, format: Format, level: uint (COMPRESS_DEFAULT_LEVEL)) Compressor
    // Compresses `data` and returns its length, the number of input bytes accepted.
    + fn write(data: local &[u8]) uint !io:IoError
}
```

### Compressor

An `io.Writer` that compresses what is written to it and passes the result to `out`.

Input is compressed in 64 KiB pieces, so compressed bytes reach `out` only after that
much input or on `close`. `close` must be called to write the final block and the
format's trailer; it does not close `out`.

#### close

Compresses the remaining input and writes the final block and trailer to `out`.

Calling it again does nothing. Errors from `out` are passed on.

#### new

Returns a compressor writing `format` data to `out` at `level` (0 stores, 9 is smallest).

Levels above 9 act as 9.

#### write

Compresses `data` and returns its length, the number of input bytes accepted.

Throws `closed` after `close`, and passes on errors from `out`; `write` is thrown when
`out` accepts no bytes.

```js
// An `io.Reader` that decompresses a `format` stream read from `source`.
+ class Decompressor is Reader {
    // Returns the number of compressed bytes decoded so far.
    + fn consumed() uint
    // Returns a decompressor reading `format` data from `source`.
    + static fn new(source: Reader, format: Format) Decompressor
    // Fills `buf` with decompressed bytes and returns how many were written; 0 means the end.
    + fn read(buf: local mut &[u8]) uint !io:IoError
}
```

### Decompressor

An `io.Reader` that decompresses a `format` stream read from `source`.

Reading returns 0 at the end of the stream. Concatenated gzip members read as one stream.
A malformed or truncated stream or a checksum mismatch throws `read` (`io.Reader` has no
`truncated` code; use `decompress` to tell them apart). An error from `source` is passed
through with its own code, except that `closed` from `source` counts as the end of its
input. It reads ahead from `source` in blocks of up to 64 KiB.

#### consumed

Returns the number of compressed bytes decoded so far.

Unlike the position of `source`, this excludes bytes read ahead but not yet used, so
after the end of the stream it gives the offset where any following data starts.

#### new

Returns a decompressor reading `format` data from `source`.

#### read

Fills `buf` with decompressed bytes and returns how many were written; 0 means the end.

# core

## Aliases for 'core'

```js
// The exit code `exec` returns when it cannot run the shell or collect its status.
+ value EXEC_FAILED (-1)
// The buffer size the `_in` float formatters require: the longest text any of them writes is 40 bytes, so 64 leaves room to spare.
+ value FLOAT_TEXT_SIZE (64)
// Methods shared by every integer type. The buffer size `to_base_in` requires: a sign plus 64 binary digits.
+ value INT_TEXT_SIZE (65)
```

### EXEC_FAILED

The exit code `exec` returns when it cannot run the shell or collect its status.

### FLOAT_TEXT_SIZE

The buffer size the `_in` float formatters require: the longest text any of them writes
is 40 bytes, so 64 leaves room to spare.

### INT_TEXT_SIZE

Methods shared by every integer type.
The buffer size `to_base_in` requires: a sign plus 64 binary digits.

## Errors for 'core'

```js
// A general-purpose error with the single code `error`.
+ error AnError (error)
// A resource could not be created or set up (`init`).
+ error InitError (init)
// Ends an iteration: an iterator's `_next` method throws `end` when no items are left.
+ error IterError (end)
// A lookup failed: `missing` (no such key or item), `exists` (already present), `range` (index out of range) or `empty` (the container is empty).
+ error LookupError (missing, exists, range, empty)
// Text could not be parsed (`syntax`), as thrown by the number parsers such as `to_int`.
+ error SyntaxError (syntax)
// An operating-system call failed (`failed`) or is not available on this platform (`unsupported`).
+ error SystemError (failed, unsupported)
```

### AnError

A general-purpose error with the single code `error`.

### InitError

A resource could not be created or set up (`init`).

### IterError

Ends an iteration: an iterator's `_next` method throws `end` when no items are left.

### LookupError

A lookup failed: `missing` (no such key or item), `exists` (already present), `range`
(index out of range) or `empty` (the container is empty).

### SyntaxError

Text could not be parsed (`syntax`), as thrown by the number parsers such as `to_int`.

### SystemError

An operating-system call failed (`failed`) or is not available on this platform
(`unsupported`).

## Enums for 'core'

```js
// How `Process.start` connects one standard stream of a child.
+ enum Stdio { inherit, pipe, discard }
```

### Stdio

How `Process.start` connects one standard stream of a child.

## Functions for 'core'

```js
// Writes `Warning: msg @ file:line` to stderr without allocating.
+ fn cleanup_warning(msg: String, file: String, line: uint) void
// Returns a deep copy of `value`, the same copy `$clone(value)` makes.
+ fn clone_value(value: $T) T
// Returns the number of physical CPU cores; at least 1.
+ fn cpu_core_count() uint
// Returns the number of logical CPUs (hardware threads) that are online; at least 1.
+ fn cpu_thread_count() uint
// Returns every environment variable of this process as a new map from name to value.
+ fn env_vars() Map[String]
// Runs `cmd` through the shell and returns its exit code and captured output.
+ fn exec(cmd: String, print_output: bool (false), capture_stderr: bool (true)) (i32, String)
// Ends the process with exit code `code`.
+ fn exit(code: i32) void
// Returns the value of the environment variable `var`.
+ fn getenv(var: String) String !LookupError
// Returns the host name of this machine.
+ fn hostname() String !SystemError
// Prints `msg` to stderr and ends the process with exit code 1.
+ fn panic(msg: String, location: String ("")) void
// Returns the id of this process.
+ fn process_id() uint
// Sends signal `code` to the current process.
+ fn raise(code: i32) void
// Reads a `bytes`-long big-endian unsigned integer from `from`.
+ fn read_big_endian(from: *[u8], bytes: uint) uint
// Reads a `bytes`-long little-endian unsigned integer from `from`.
+ fn read_little_endian(from: *[u8], bytes: uint) uint
// Sets or replaces the environment variable `var` for this process and the children it starts.
+ fn setenv(var: String, value: String) void !SystemError
// Makes the process ignore signal number `sig` (`SIG_IGN`).
+ fn signal_ignore(sig: int) void
// Removes the environment variable `var`; removing a variable that is not set succeeds.
+ fn unsetenv(var: String) void !SystemError
// Writes the low `bytes` bytes of `v` to `to`, most significant byte first.
+ fn write_big_endian(to: *[u8], v: uint, bytes: uint) void
// Writes the low `bytes` bytes of `v` to `to`, least significant byte first.
+ fn write_little_endian(to: *[u8], v: uint, bytes: uint) void
```

### cleanup_warning

Writes `Warning: msg @ file:line` to stderr without allocating.

Meant for failures in `gc_free` and other cleanup code that cannot throw.

### clone_value

Returns a deep copy of `value`, the same copy `$clone(value)` makes.

Classes with a `$clone` hook are copied through that hook; `shared` values are returned as
they are. Values that alias raw memory (raw pointers, borrows) without a `$clone` hook are a
compile error.

### cpu_core_count

Returns the number of physical CPU cores; at least 1.

Cores that run two hardware threads count once, so this is at most `cpu_thread_count()`.

### cpu_thread_count

Returns the number of logical CPUs (hardware threads) that are online; at least 1.

### env_vars

Returns every environment variable of this process as a new map from name to value.

Changes to the map do not change the environment; use `setenv` and `unsetenv` for that.
Names are case-sensitive except on Windows, where the name keeps the case it was set with.

### exec

Runs `cmd` through the shell and returns its exit code and captured output.

A shortcut over `Process`: the shell is `/bin/sh -c` on Linux and macOS and
`cmd.exe /d /s /c` on Windows. The shell reads quotes, spaces and characters such as `;`
in `cmd`, so pass values that come from outside as arguments to `Process.output` instead.
With `capture_stderr` the output includes stderr; with `print_output` it is also written
to stdout as it arrives. Inside a coroutine only the coroutine waits for the command. When
the shell cannot be started, returns `EXEC_FAILED` with an error message in place of the
output. On Linux and macOS a command killed by a signal reports 128 plus the signal number.

On Windows, while the working directory is a UNC path (`\\server\...`), which cmd.exe
cannot use, the command runs in `C:/`.

### exit

Ends the process with exit code `code`.

C exit handlers run, unlike with `panic`; `defer` blocks, other coroutines and other
threads do not get to finish.

### getenv

Returns the value of the environment variable `var`.

Throws `missing` when it is not set.

### hostname

Returns the host name of this machine.

On Windows it is the DNS host name. Throws `failed` when the system does not report one.

### panic

Prints `msg` to stderr and ends the process with exit code 1.

The compiler fills `location` with the panic's source position, relative to the root of
the package it was compiled in, and the output reads `msg at path:line`. A program built
with `--debug` also prints the stack trace. C exit handlers do not run. Marked `$exit`:
the compiler knows a call never returns.

### process_id

Returns the id of this process.

### raise

Sends signal `code` to the current process.

Returns once the signal is ignored or handled; a signal whose action ends the process does
not return.

### read_big_endian

Reads a `bytes`-long big-endian unsigned integer from `from`.

`bytes` must not exceed `size_of(uint)`; no bounds are checked.

### read_little_endian

Reads a `bytes`-long little-endian unsigned integer from `from`.

`bytes` must not exceed `size_of(uint)`; no bounds are checked.

### setenv

Sets or replaces the environment variable `var` for this process and the children it
starts.

Throws `failed` when `var` is empty or contains `=`, or when the OS rejects it. On Windows
an empty `value` removes the variable.

### signal_ignore

Makes the process ignore signal number `sig` (`SIG_IGN`).

### unsetenv

Removes the environment variable `var`; removing a variable that is not set succeeds.

Throws `failed` when `var` is empty or contains `=`, or when the OS rejects it.

### write_big_endian

Writes the low `bytes` bytes of `v` to `to`, most significant byte first.

Higher bytes of `v` are dropped. No bounds are checked.

### write_little_endian

Writes the low `bytes` bytes of `v` to `to`, least significant byte first.

Higher bytes of `v` are dropped. No bounds are checked.

## Classes for 'core'

```js
+ extend &[T] {
    // The address of the first element.
    ~+ data: *[T]
    // The number of elements.
    ~+ length: uint
    // The allocation that keeps the elements alive; null for storage nobody owns, such as a literal or unsafe memory.
    ~+ owner: ?GcPtr

    // Returns the element at `index`.
    + fn get(index: uint) T !LookupError
    // Returns a copy of `length` elements starting at `offset`; backs `s[offset .. length]`.
    + fn range(offset: uint, length: uint) mut &[T]
    // Stores `value` at `index`.
    + fn set(index: uint, value: T) void !LookupError
    // Stores `value` in every element.
    + fn set_all(value: T) void
    // Returns a view of `length` elements from `offset` that shares this slice's storage.
    + fn view(offset: uint, length: uint) mut &[T]
}
```

#### data

The address of the first element.

#### length

The number of elements.

#### owner

The allocation that keeps the elements alive; null for storage nobody owns, such as a literal or unsafe memory.

#### get

Returns the element at `index`.

Throws `LookupError.missing` when `index` is out of range.

#### range

Returns a copy of `length` elements starting at `offset`; backs `s[offset .. length]`.

The range is clamped to the slice, and an `offset` at or past the end returns an empty
slice. The copy has its own storage.

#### set

Stores `value` at `index`.

Throws `LookupError.range` when `index` is out of range.

#### set_all

Stores `value` in every element.

#### view

Returns a view of `length` elements from `offset` that shares this slice's storage.

Backs `&s[offset .. length]`. Writes through either one are visible in the other, and the
view keeps the storage alive. The range is clamped to the slice; an `offset` past the end
gives an empty view.

```js
+ extend &[u8] {
    // Returns whether the bytes are exactly the bytes of `cmp`.
    + fn equals(cmp: String) bool
    // Returns whether the `length` bytes at `offset` are exactly the bytes of `cmp`.
    + fn equals_at(offset: uint, length: uint, cmp: String) bool
    // Returns whether the `length` bytes at `offset` equal `cmp`, ignoring ASCII case.
    + fn equals_at_ignore_ascii_case(offset: uint, length: uint, cmp: String) bool
    // Returns whether the bytes equal `cmp` when ASCII letters are compared case-insensitively.
    + fn equals_ignore_ascii_case(cmp: String) bool
    // Returns whether any byte is an ASCII control character (below 32, or 127 DEL).
    + fn has_ascii_control(allow_tab: bool (false)) bool
    // Returns the index of the first `byte` at or after `start_index`.
    + fn index_of_byte(byte: u8, start_index: uint (0)) uint !LookupError
    // Returns a `ByteReader` that reads these bytes from the start without copying them.
    + fn reader() ByteReader
    // Returns whether the slice begins with the bytes of `cmp`; an empty `cmp` always matches.
    + fn starts_with(cmp: String) bool
    // Returns a new `String` holding a copy of the bytes with `A`-`Z` lowered to `a`-`z`.
    + fn to_ascii_lower_string() String
    // Parses the bytes as a decimal floating-point number, with the rules of `String.to_float`.
    + fn to_float() float !SyntaxError
    // Parses the bytes as a decimal signed integer with an optional `-` or `+` sign.
    + fn to_int() int !SyntaxError
    // Returns a new `String` holding a copy of the bytes.
    + fn to_string() String
    // Parses the bytes as a decimal unsigned integer, with an optional leading `+`.
    + fn to_uint() uint !SyntaxError
}
```

#### &[u8].equals

Returns whether the bytes are exactly the bytes of `cmp`.

#### &[u8].equals_at

Returns whether the `length` bytes at `offset` are exactly the bytes of `cmp`.

Returns false when `length` differs from the byte length of `cmp` or the range runs past
the end of the slice.

#### &[u8].equals_at_ignore_ascii_case

Returns whether the `length` bytes at `offset` equal `cmp`, ignoring ASCII case.

Returns false when `length` differs from the byte length of `cmp` or the range runs past
the end of the slice. Bytes outside ASCII must match exactly.

#### &[u8].equals_ignore_ascii_case

Returns whether the bytes equal `cmp` when ASCII letters are compared case-insensitively.

Bytes outside ASCII must match exactly.

#### &[u8].has_ascii_control

Returns whether any byte is an ASCII control character (below 32, or 127 DEL).

With `allow_tab`, the tab byte `\t` does not count as a control character.

#### &[u8].index_of_byte

Returns the index of the first `byte` at or after `start_index`.

The index counts from the start of the slice. Throws `LookupError` when the byte does not
occur or `start_index` is at or past the end.

#### &[u8].reader

Returns a `ByteReader` that reads these bytes from the start without copying them.

#### &[u8].starts_with

Returns whether the slice begins with the bytes of `cmp`; an empty `cmp` always matches.

#### &[u8].to_ascii_lower_string

Returns a new `String` holding a copy of the bytes with `A`-`Z` lowered to `a`-`z`.

Bytes outside ASCII are copied unchanged.

#### &[u8].to_float

Parses the bytes as a decimal floating-point number, with the rules of `String.to_float`.

Accepts an optional `-` or `+` sign, digits with at most one `.` (at least one digit is
required), and an optional `e`/`E` exponent with its own sign, or `nan`, `inf` and
`infinity` in any letter case after the sign. Throws `SyntaxError` for other bytes, input
without mantissa digits such as `"."` or `"e5"`, more than 768 bytes, an exponent above
400, or a numeric value that overflows to infinity.

#### &[u8].to_int

Parses the bytes as a decimal signed integer with an optional `-` or `+` sign.

Throws `SyntaxError` for an empty slice, any byte that is not a digit after the sign, or
a value outside the `int` range.

#### &[u8].to_string

Returns a new `String` holding a copy of the bytes.

#### &[u8].to_uint

Parses the bytes as a decimal unsigned integer, with an optional leading `+`.

Throws `SyntaxError` for an empty slice, any byte other than the digits `0`-`9` after
the sign, or a value that does not fit.

```js
// A growable array of `T` stored in one contiguous block.
+ array Array[T] {
    // The storage block holding the elements; null until the first element is stored.
    ~ data: ?GcPtr
    // The number of elements.
    ~ length: uint
    // The number of element slots the storage block holds; `length` of them are in use.
    ~ size: uint

    // Returns whether `func` returns true for every element; true when empty.
    + fn all(func: fn(T)(bool)) bool
    // Returns whether `func` returns true for at least one element; false when empty.
    + fn any(func: fn(T)(bool)) bool
    // Appends `item` to the end, growing the storage when it is full.
    + fn append(item: T, unique: bool (false)) void
    // Appends every element of `items` in order; with `unique`, each one is skipped when an equal item is already present (tracked in a set for integers and `$hash` types).
    + fn append_many(items: Array[T], unique: bool (false)) void
    // Searches this array, sorted with `func`, for `value` in O(log n).
    + fn binary_search(value: T, func: fn(T, T)(bool)) (bool, uint)
    // Removes every element.
    + fn clear(reduce_size: bool (false)) void
    // Returns a deep copy: a new array holding a `$clone` of every element.
    + fn clone() Array[T]
    // Returns whether an element equal to `value` is present (a linear scan using `==`).
    + fn contains(value: T) bool
    // Returns a shallow copy: a new array holding the same elements.
    + fn copy() Array[T]
    // Returns whether both arrays have the same length and equal elements at each index.
    + fn equals(array: Array[T]) bool
    // Returns whether both arrays hold the same elements the same number of times, in any order.
    + fn equals_ignore_order(array: Array[T]) bool
    // Removes the elements for which `func` returns true and returns them in their original order.
    + fn extract(func: ?fn(T)(bool) (null)) Array[T]
    // Creates an array holding `count` copies of `value`; backs `Array[T]{ value x count }`.
    + static fn fill(count: uint, value: T) Array[T]
    // Returns a new array of the elements for which `func` returns true; this array is unchanged.
    + fn filter(func: ?fn(T)(bool) (null)) Array[T]
    // Returns the first element for which `func` returns true.
    + fn find(func: fn(T)(bool)) T !LookupError
    // Returns the first element without removing it.
    + fn first() T !LookupError
    // Grows the storage, doubling its size, until `index` is a valid slot; the length does not change.
    + fn fit_index(index: uint) void
    // Builds an array from a JSON array, converting each item with `to_type`.
    + static fn from_json_value_auto[X](value: X) Array[T] !LookupError
    // Returns the element at `index`.
    + fn get(index: uint) T !LookupError
    // Grows the storage to hold at least `new_size` elements; does nothing when it already does. The length does not change.
    + fn increase_size(new_size: uint) void
    // Returns the index of the first element equal to `item` (compared with `==`).
    + fn index_of(item: T) uint !LookupError
    // Inserts `value` at `index`, shifting the elements from there one slot up.
    + fn insert(index: uint, value: T) void !LookupError
    // Returns a new array of the elements that also occur in `with`, in this array's order and without duplicates.
    + fn intersect(with: Array[T]) Array[T]
    // Returns a raw pointer to the first element.
    + fn items() *[T]
    // Converts each element to a `String` and joins them with `divider` between each pair.
    + fn join(divider: String) String
    // Returns the last element without removing it.
    + fn last() T !LookupError
    // Returns a new array holding `func` applied to each element, in order.
    + fn map[R](func: fn(T)(R)) Array[R]
    // Returns the element with the largest key; on a tie, the first of them.
    + fn max_by[K](key: fn(T)(K)) T !LookupError
    // Returns a new array with the elements of this array followed by those of `items`.
    + fn merge(items: Array[T]) Array[T]
    // Returns the element with the smallest key; on a tie, the first of them.
    + fn min_by[K](key: fn(T)(K)) T !LookupError
    // Creates an empty array with room for `start_size` elements before it has to grow.
    + static fn new(start_size: uint (0)) Array[T]
    // Removes and returns the first element, shifting the rest down (O(n)).
    + fn pop_first() T !LookupError
    // Removes and returns the last element.
    + fn pop_last() T !LookupError
    // Inserts `item` at the front, shifting every element one slot up.
    + fn prepend(item: T, unique: bool (false)) void
    // Inserts the elements of `items` at the front, keeping their order.
    + fn prepend_many(items: Array[T], unique: bool (false)) void
    // Returns a new array with a copy of up to `amount` elements starting at `start`.
    + fn range(start: uint, amount: uint) Array[T]
    // Folds the elements left to right into one value, starting from `init`.
    + fn reduce[R](init: R, func: fn(R, T)(R)) R
    // Removes the element at `index` and shifts the following elements down.
    + fn remove(index: uint) void
    // Removes every element equal to an earlier one, keeping first occurrences in order.
    + fn remove_duplicates() void
    // Removes the first element equal to `value`, shifting the rest down; does nothing when it is absent.
    + fn remove_value(value: T) void
    // Removes the elements for which `func` returns true, keeping the order of the rest.
    + fn remove_where(func: ?fn(T)(bool) (null)) void
    // Reverses the order of the elements in place.
    + fn reverse() void
    // Returns a copy with the elements in reverse order.
    + fn reversed() Array[T]
    // Replaces the element at `index` with `value`; an `index` equal to `length` appends.
    + fn set(index: uint, value: T) void !LookupError
    // Replaces every element with `value`; the length does not change.
    + fn set_all(value: T) void
    // Sets the element at `index`, first growing the array to that length with `filler_value` when `index` is past the end.
    + fn set_expand(index: uint, value: T, filler_value: T) void
    // Puts the elements in random order in place, every order equally likely (Fisher-Yates).
    + fn shuffle(rng: ?Rng (null)) void
    // Returns a copy with the elements in random order; see `shuffle`.
    + fn shuffled(rng: ?Rng (null)) Array[T]
    // Sorts the elements in place with `func`, which returns true when `a` belongs after `b`.
    + fn sort(func: fn(T, T)(bool)) void
    // Sorts the elements in place by the value `key` gives for each, ascending.
    + fn sort_by[K](key: fn(T)(K)) void
    // Returns a copy sorted with `func`; see `sort`.
    + fn sorted(func: fn(T, T)(bool)) Array[T]
    // Returns a copy sorted by `key`; see `sort_by`.
    + fn sorted_by[K](key: fn(T)(K)) Array[T]
    // Exchanges the elements at `index_a` and `index_b`; does nothing when either is out of range.
    + fn swap(index_a: uint, index_b: uint) void
    // Removes the element at `index` by moving the last element into its slot.
    + fn swap_remove(index: uint) void
    // Returns a copy without duplicates; see `remove_duplicates`.
    + fn unique() Array[T]
    // Returns a writable view of up to `amount` elements starting at `start`, without copying.
    + fn view(start: uint (0), amount: uint (uint.$max)) mut &[T]
}
```

### Array

A growable array of `T` stored in one contiguous block.

Build one with `Array[T]{ a, b }` (see `append`) or `Array[T]{ value x count }` (see
`fill`), and iterate with `each arr as value, index`.

#### data

The storage block holding the elements; null until the first element is stored.

#### length

The number of elements.

#### size

The number of element slots the storage block holds; `length` of them are in use.

#### all

Returns whether `func` returns true for every element; true when empty.

#### any

Returns whether `func` returns true for at least one element; false when empty.

#### append

Appends `item` to the end, growing the storage when it is full.

With `unique`, nothing is added when an equal item is already present (a linear scan).
Marked `$append`: backs the list literal `Array[T]{ a, b, c }`.

#### append_many

Appends every element of `items` in order; with `unique`, each one is skipped when an
equal item is already present (tracked in a set for integers and `$hash` types).

#### binary_search

Searches this array, sorted with `func`, for `value` in O(log n).

Returns whether it was found, and its position: the first of several equal elements,
or where `value` would go to keep the order, so `insert(position, value)` keeps the
array sorted.

#### clear

Removes every element.

The storage is kept for reuse unless `reduce_size` is set, which replaces it with a
two-slot block.

#### clone

Returns a deep copy: a new array holding a `$clone` of every element.

Marked `$clone`: backs `$clone(arr)`.

#### contains

Returns whether an element equal to `value` is present (a linear scan using `==`).

#### copy

Returns a shallow copy: a new array holding the same elements.

#### equals

Returns whether both arrays have the same length and equal elements at each index.

Marked `$eq`: backs `==`. Elements are compared with `==`, so their own `$eq` applies.

#### equals_ignore_order

Returns whether both arrays hold the same elements the same number of times, in any
order.

Costs O(n²).

#### extract

Removes the elements for which `func` returns true and returns them in their original
order.

Follows the same rules as `remove_where`, including the default without `func`.

#### fill

Creates an array holding `count` copies of `value`; backs `Array[T]{ value x count }`.

For a reference type every slot holds the same object, not a copy.

#### filter

Returns a new array of the elements for which `func` returns true; this array is
unchanged.

Without `func`, empty strings and nulls are dropped; for other element types the
result is a plain copy.

#### find

Returns the first element for which `func` returns true.

Throws `missing` when none matches.

#### first

Returns the first element without removing it.

Throws `empty` when the array is empty.

#### fit_index

Grows the storage, doubling its size, until `index` is a valid slot; the length does
not change.

Panics when the needed size overflows.

#### from_json_value_auto

Builds an array from a JSON array, converting each item with `to_type`.

Throws `.missing` when `value` is not an array or an item cannot be converted to
the item type.

#### get

Returns the element at `index`.

Throws `missing` when `index` is not below `length`.

#### increase_size

Grows the storage to hold at least `new_size` elements; does nothing when it already
does. The length does not change.

Panics when the size in bytes overflows.

#### index_of

Returns the index of the first element equal to `item` (compared with `==`).

Throws `missing` when no element matches.

#### insert

Inserts `value` at `index`, shifting the elements from there one slot up.

An `index` equal to `length` appends. Throws `range` when `index` is greater than
`length`. Costs O(n) for the elements that move.

#### intersect

Returns a new array of the elements that also occur in `with`, in this array's order
and without duplicates.

#### items

Returns a raw pointer to the first element.

It stays valid only until the array grows or replaces its storage, and reads through
it skip the bounds and presence checks of `[]`.

#### join

Converts each element to a `String` and joins them with `divider` between each pair.

Null elements are skipped and get no divider.

#### last

Returns the last element without removing it.

Throws `empty` when the array is empty.

#### map

Returns a new array holding `func` applied to each element, in order.

```valk
let strs = values.map(fn(v) { return v.to(String) }) // Array[String]
```

#### max_by

Returns the element with the largest key; on a tie, the first of them.

`key` runs once per element, and a null key is the smallest. Throws `empty` when the
array is empty.

#### merge

Returns a new array with the elements of this array followed by those of `items`.

Marked `$add`: backs `a + b`. Neither operand changes.

#### min_by

Returns the element with the smallest key; on a tie, the first of them.

`key` runs once per element, and a null key is the smallest. Throws `empty` when the
array is empty.

#### new

Creates an empty array with room for `start_size` elements before it has to grow.

Marked `$default`: it also provides the type's default value.

#### pop_first

Removes and returns the first element, shifting the rest down (O(n)).

Throws `missing` when the array is empty.

#### pop_last

Removes and returns the last element.

Throws `missing` when the array is empty.

#### prepend

Inserts `item` at the front, shifting every element one slot up.

With `unique`, nothing is added when an equal item is already present. Costs O(n);
prefer `append` when order allows.

#### prepend_many

Inserts the elements of `items` at the front, keeping their order.

With `unique`, each one is skipped when an equal item is already present.

#### range

Returns a new array with a copy of up to `amount` elements starting at `start`.

Backs `arr[start .. amount]`. A `start` past the end gives an empty array. The copy is
shallow: reference elements are shared.

#### reduce

Folds the elements left to right into one value, starting from `init`.

#### remove

Removes the element at `index` and shifts the following elements down.

Does nothing when `index` is out of range. Costs O(n); `swap_remove` is O(1) when
order does not matter.

#### remove_duplicates

Removes every element equal to an earlier one, keeping first occurrences in order.

Compares with `==` (so `$eq` applies). From 128 items, integers and types with `$hash`
(such as `String`) are tracked in a set, which costs O(n); otherwise it costs O(n²).

#### remove_value

Removes the first element equal to `value`, shifting the rest down; does nothing when
it is absent.

#### remove_where

Removes the elements for which `func` returns true, keeping the order of the rest.

`func` may append to the array; only elements present when the call started are
tested. Without `func`, empty strings and nulls are removed; for other element types
nothing happens.

#### reverse

Reverses the order of the elements in place.

#### reversed

Returns a copy with the elements in reverse order.

#### set

Replaces the element at `index` with `value`; an `index` equal to `length` appends.

Throws `range` when `index` is greater than `length`.

#### set_all

Replaces every element with `value`; the length does not change.

#### set_expand

Sets the element at `index`, first growing the array to that length with
`filler_value` when `index` is past the end.

#### shuffle

Puts the elements in random order in place, every order equally likely (Fisher-Yates).

Uses this thread's `random` generator, or `rng` for an order that repeats with its seed.

#### shuffled

Returns a copy with the elements in random order; see `shuffle`.

#### sort

Sorts the elements in place with `func`, which returns true when `a` belongs after `b`.

The element type has no natural order, so `func` is required. The sort is stable:
elements that compare equal keep their order.

#### sort_by

Sorts the elements in place by the value `key` gives for each, ascending.

`key` runs once per element. The sort is stable, and a null key comes first. Use `sort`
with a function for another order.

#### sorted

Returns a copy sorted with `func`; see `sort`.

#### sorted_by

Returns a copy sorted by `key`; see `sort_by`.

#### swap

Exchanges the elements at `index_a` and `index_b`; does nothing when either is out of
range.

#### swap_remove

Removes the element at `index` by moving the last element into its slot.

Does not preserve order. Does nothing when `index` is out of range.

#### unique

Returns a copy without duplicates; see `remove_duplicates`.

#### view

Returns a writable view of up to `amount` elements starting at `start`, without copying.

Backs `&arr[start .. amount]`. A `start` past the end gives an empty view. The view
shares the array's storage block and keeps it alive on its own: it sees in-place
writes through the array, including the shifting and zeroed slots left by removals.
Once the array grows (or `clear(true)` replaces its storage) the view keeps covering
the old block, and the two no longer see each other's writes. Marked `$auto`: an array
converts to a view where a `&[T]`, `local &[T]` or `mut &[T]` is expected.

```js
+ extend Array[uint] {
    // Returns the largest element.
    + fn max() uint !LookupError
    // Returns the smallest element.
    + fn min() uint !LookupError
    // Returns the sum of the elements, or 0 when the array is empty.
    + fn sum() uint
}
```

#### Array[uint].max

Returns the largest element.

Throws `empty` when the array is empty. Available on arrays of non-nullable integers
and floats.

#### Array[uint].min

Returns the smallest element.

Throws `empty` when the array is empty. Available on arrays of non-nullable integers
and floats.

#### Array[uint].sum

Returns the sum of the elements, or 0 when the array is empty.

Available on arrays of non-nullable integers and floats.

```js
// A growable byte buffer for building binary or text data in memory.
+ class ByteBuffer is Writer {
    // Pointer to the first byte of `storage`.
    ~ data: ptr
    // Number of bytes written.
    ~ length: uint
    // Capacity in bytes.
    ~ size: uint
    // The `String` whose bytes back the buffer; replaced when the capacity changes.
    ~ storage: String

    // Sets the length to 0; the capacity is kept.
    + fn clear() void
    // Zeroes the `amount` bytes after the contents, reserving room first.
    + fn clear_next_bytes(amount: uint) void
    // Removes `len` bytes starting at `index` and moves the later bytes down.
    + fn clear_range(index: uint, len: uint) void
    // Removes the first `index` bytes and moves the rest to the front.
    + fn clear_until(index: uint) void
    // Returns an independent copy with the same contents and capacity.
    + fn clone() ByteBuffer
    // Grows the capacity to at least `minimum_capacity` bytes.
    + fn ensure_capacity(minimum_capacity: uint) void
    // Returns whether the contents equal the bytes of `str`; backs `buffer == str` (`$eq`).
    + fn equals_string(str: String) bool
    // Appends `amount` copies of the byte `with`.
    + fn fill(with: u8, amount: uint) void
    // Returns the byte at `index`, or 0 when `index` is at or past the length.
    + fn get(index: uint) u8
    // Returns the index of the first `byte` at or after `start_index`.
    + fn index_of(byte: u8, start_index: uint (0)) uint !LookupError
    // Returns the index of the first byte at or after `start_index` that differs from `byte`.
    + fn index_where_byte_is_not(byte: u8, start_index: uint (0)) uint !LookupError
    // Hands the storage over as a `String` without copying, and leaves the buffer consumed.
    + fn into_string() String
    // Removes leading bytes for which `filter` returns true and moves the rest to the front.
    + fn ltrim(filter: fnptr(u8)(bool)) void
    // Creates an empty buffer with room for `start_size` bytes (at least 32).
    + static fn new(start_size: uint (128)) ByteBuffer
    // Returns a copy of `length` bytes starting at `start_index`, clamped to the contents.
    + fn range(start_index: uint, length: uint) String
    // Returns a `ByteReader` over the current contents.
    + fn reader() ByteReader
    // Ensures room for `length` more bytes after the contents, growing the capacity if needed.
    + fn reserve(length: uint) void
    // Sets the length to `length`, growing the capacity when needed.
    + fn resize(length: uint) void
    // Removes trailing bytes for which `filter` returns true.
    + fn rtrim(filter: fnptr(u8)(bool)) void
    // Replaces the byte at `index`; backs `buffer[index] = v` (`$offset_assign`).
    + fn set(index: uint, v: u8) void
    // Reduces the capacity to `size` bytes, but never below the length or 32.
    + fn shrink_capacity(size: uint) void
    // Grows the length by `amount` bytes without writing them.
    + fn skip(amount: uint) void
    // Returns whether the contents at byte `offset` begin with `str`.
    + fn starts_with(str: String, offset: uint (0)) bool
    // Returns a copy of the contents as a new `String`.
    + fn to_string() String
    // Removes the bytes for which `filter` returns true from both ends.
    + fn trim(filter: fnptr(u8)(bool)) void
    // Shortens the contents to `length` bytes; does nothing when they are not longer.
    + fn truncate(length: uint) void
    // Returns a writable view of `length` bytes starting at `offset`, clamped to the contents.
    + fn view(offset: uint (0), length: uint (uint.$max)) mut &[u8]
    // Returns a writable view of up to `amount` bytes of unused capacity after the contents.
    + fn view_spare(amount: uint) mut &[u8]
    // Appends the bytes of `data` and returns how many were written (`data.length`).
    + fn write(data: local &[u8]) uint
    // Appends the low `bytes` bytes of `value`, most significant first.
    + fn write_big_endian(value: uint, bytes: uint) void
    // Appends one byte.
    + fn write_byte(v: u8) void
    // Appends the bytes of the C string `str`, plus its zero terminator when `include_zero_byte`.
    + fn write_cstring(str: cstring, include_zero_byte: bool (true)) void
    // Appends `v` in fixed notation with `decimals` digits after the point.
    + fn write_f64_ascii(v: f64, decimals: uint, trim_zeros: bool (false)) void
    // Appends `v` in exponent form with `decimals` digits after the point, e.g. `1.234567e6`.
    + fn write_f64_ascii_scientific(v: f64, decimals: uint (6), trim_zeros: bool (false)) void
    // Appends `v` with the fewest digits that parse back to the same value.
    + fn write_f64_ascii_shortest(v: f64, force_exponent: bool (false)) void
    // Appends the IEEE 754 bits of `v` as 8 bytes, most significant first.
    + fn write_f64_be(v: f64) void
    // Appends the IEEE 754 bits of `v` as 8 bytes, least significant first.
    + fn write_f64_le(v: f64) void
    // Appends `v` as text in `base`, with a leading `-` when negative.
    + fn write_int_ascii(v: int, base: u8 (10), lowercase: bool (false)) void
    // Appends the low `bytes` bytes of `value`, least significant first.
    + fn write_little_endian(value: uint, bytes: uint) void
    // Appends `v` as 2 bytes, most significant first.
    + fn write_u16_be(v: u16) void
    // Appends `v` as 2 bytes, least significant first.
    + fn write_u16_le(v: u16) void
    // Appends `v` as 4 bytes, most significant first.
    + fn write_u32_be(v: u32) void
    // Appends `v` as 4 bytes, least significant first.
    + fn write_u32_le(v: u32) void
    // Appends `v` as 8 bytes, most significant first.
    + fn write_u64_be(v: u64) void
    // Appends `v` as 8 bytes, least significant first.
    + fn write_u64_le(v: u64) void
    // Appends `v` as text in `base`, using uppercase digits above 9.
    + fn write_uint_ascii(v: uint, base: u8 (10), lowercase: bool (false)) void
}
```

### ByteBuffer

A growable byte buffer for building binary or text data in memory.

Bytes `0 .. length` are the written contents and `size` is the capacity. When the capacity
runs out it doubles and the contents move to new storage. The buffer converts to
`mut &[u8]` and `String` where those are expected (see `view` and `to_string`), and
implements `io.Writer`.

#### data

Pointer to the first byte of `storage`.

#### length

Number of bytes written.

#### size

Capacity in bytes.

#### storage

The `String` whose bytes back the buffer; replaced when the capacity changes.

#### clear

Sets the length to 0; the capacity is kept.

#### clear_next_bytes

Zeroes the `amount` bytes after the contents, reserving room first.

The length does not change; follow with `skip(amount)` to include the zeroed bytes.

#### clear_range

Removes `len` bytes starting at `index` and moves the later bytes down.

`len` is clamped to the end of the contents. Does nothing when `index` is at or past the
length.

#### clear_until

Removes the first `index` bytes and moves the rest to the front.

Clears the whole buffer when `index` is at or past the length.

#### clone

Returns an independent copy with the same contents and capacity.

A consumed buffer (see `into_string`) clones to a new, empty, writable buffer.

#### ensure_capacity

Grows the capacity to at least `minimum_capacity` bytes.

The capacity doubles (starting from at least 32) until it is large enough, and the
contents move to new storage; views taken before keep the old bytes. Panics when the
buffer is consumed (see `into_string`) or the size would overflow.

#### equals_string

Returns whether the contents equal the bytes of `str`; backs `buffer == str` (`$eq`).

#### fill

Appends `amount` copies of the byte `with`.

#### get

Returns the byte at `index`, or 0 when `index` is at or past the length.

Backs the `buffer[index]` read (`$offset`).

#### index_of

Returns the index of the first `byte` at or after `start_index`.

Throws `missing` when there is none or `start_index` is at or past the length.

#### index_where_byte_is_not

Returns the index of the first byte at or after `start_index` that differs from `byte`.

Throws `missing` when every remaining byte equals `byte`, or `start_index` is at or past
the length.

#### into_string

Hands the storage over as a `String` without copying, and leaves the buffer consumed.

A consumed buffer is empty for good: every call that needs room (`write*`, `reserve`,
`ensure_capacity`, `skip`, `fill`, `resize` to a larger length, ...) panics, and `clear`
does not undo it. Calling `into_string` again returns "". Use `clone` or a new buffer
to keep writing. Views taken before the call still point at the bytes now owned by the
returned string.

#### ltrim

Removes leading bytes for which `filter` returns true and moves the rest to the front.

#### new

Creates an empty buffer with room for `start_size` bytes (at least 32).

Marked `$default`, so it also provides `ByteBuffer.$default_value`.

#### range

Returns a copy of `length` bytes starting at `start_index`, clamped to the contents.

Returns "" when `start_index` is at or past the length.

#### reader

Returns a `ByteReader` over the current contents.

The reader keeps a view of the bytes as they are now: bytes appended later are not seen.

#### reserve

Ensures room for `length` more bytes after the contents, growing the capacity if needed.

Panics when the buffer is consumed (see `into_string`) or the size would overflow.

#### resize

Sets the length to `length`, growing the capacity when needed.

Bytes added by growing the length are not cleared.

#### rtrim

Removes trailing bytes for which `filter` returns true.

#### set

Replaces the byte at `index`; backs `buffer[index] = v` (`$offset_assign`).

Panics when `index` is at or past the length: it never grows the buffer.

#### shrink_capacity

Reduces the capacity to `size` bytes, but never below the length or 32.

Does nothing when `size` is not below the current capacity. Otherwise the contents move
to new storage.

#### skip

Grows the length by `amount` bytes without writing them.

The skipped bytes keep whatever the storage held, such as earlier contents. Use it after
filling the region returned by `view_spare`. Panics when the buffer is consumed.

#### starts_with

Returns whether the contents at byte `offset` begin with `str`.

Returns false when `offset` is past the length.

#### to_string

Returns a copy of the contents as a new `String`.

Marked `$auto`: a buffer converts to `String` implicitly where one is expected.

#### trim

Removes the bytes for which `filter` returns true from both ends.

#### truncate

Shortens the contents to `length` bytes; does nothing when they are not longer.

#### view

Returns a writable view of `length` bytes starting at `offset`, clamped to the contents.

An `offset` past the length gives an empty view. Marked `$auto`, so the buffer converts
to a view of its whole contents where a `&[u8]` is expected, and `$view`, which backs
`&buffer[a .. b]`.

The view has a fixed length and shares the current storage. Once the buffer moves to new
storage (growth, `shrink_capacity`) the view still reads the old bytes and no longer sees
writes; `clear_range` and similar calls shift the bytes under it.

#### view_spare

Returns a writable view of up to `amount` bytes of unused capacity after the contents.

For readers that fill the buffer directly: `reserve` the room, write into this view, then
`skip` the number of bytes written. `amount` is clamped to the free capacity, so without
a prior `reserve` the view can be shorter than asked. `view` never covers this region.

#### write

Appends the bytes of `data` and returns how many were written (`data.length`).

Implements `io.Writer`; it never throws.

#### write_big_endian

Appends the low `bytes` bytes of `value`, most significant first.

#### write_byte

Appends one byte.

#### write_cstring

Appends the bytes of the C string `str`, plus its zero terminator when `include_zero_byte`.

#### write_f64_ascii

Appends `v` in fixed notation with `decimals` digits after the point.

`decimals` is clamped to 19. With `trim_zeros`, trailing zeros are dropped, and the point
too when the fraction is zero. NaN, infinities and values beyond the 64-bit integer range
are written as by `write_f64_ascii_shortest`.

#### write_f64_ascii_scientific

Appends `v` in exponent form with `decimals` digits after the point, e.g. `1.234567e6`.

`decimals` is clamped to 19. With `trim_zeros`, trailing zeros are dropped, and the point
too when the fraction is zero. NaN and infinities are written by name; see
`float.to_scientific_string`.

#### write_f64_ascii_shortest

Appends `v` with the fewest digits that parse back to the same value.

Plain decimals for decimal exponents -6 to 20 (`0.001`, `125`), otherwise exponent form
(`1.5e300`). NaN and infinities are written by name. With `force_exponent` the exponent
form is always used, so whole values beyond the 64-bit integer range stay floats.

#### write_f64_be

Appends the IEEE 754 bits of `v` as 8 bytes, most significant first.

#### write_f64_le

Appends the IEEE 754 bits of `v` as 8 bytes, least significant first.

#### write_int_ascii

Appends `v` as text in `base`, with a leading `-` when negative.

Uppercase digits above 9; a `base` above 16 is treated as 16 and one below 2 as 10.

#### write_little_endian

Appends the low `bytes` bytes of `value`, least significant first.

#### write_u16_be

Appends `v` as 2 bytes, most significant first.

#### write_u16_le

Appends `v` as 2 bytes, least significant first.

#### write_u32_be

Appends `v` as 4 bytes, most significant first.

#### write_u32_le

Appends `v` as 4 bytes, least significant first.

#### write_u64_be

Appends `v` as 8 bytes, most significant first.

#### write_u64_le

Appends `v` as 8 bytes, least significant first.

#### write_uint_ascii

Appends `v` as text in `base`, using uppercase digits above 9.

A `base` above 16 is treated as 16 and one below 2 as 10.

```js
// A read cursor over bytes, for parsing binary or text data.
+ class ByteReader is Reader, Seeker {
    // Byte offset of the next read. May be set directly; a position past the end reads as the end.
    + pos: uint
    // The bytes being read.
    + source: &[u8]

    // Returns the current position in bytes.
    + fn get_pos() uint
    // Creates a reader at position 0 over `source`.
    + static fn new(source: &[u8]) ByteReader
    // Parses a decimal float like `read_float` and advances past it.
    + fn parse_float() float !SyntaxError
    // Parses a decimal integer like `read_int` and advances past it.
    + fn parse_int() int !SyntaxError
    // Parses an unsigned decimal integer like `read_uint` and advances past it.
    + fn parse_uint() uint !SyntaxError
    // Copies up to `buf.length` unread bytes into `buf` and advances past them.
    + fn read(buf: local mut &[u8]) uint !io:IoError
    // Reads `bytes` bytes as an unsigned big-endian integer (meant for 1 to 8 bytes).
    + fn read_big_endian(bytes: uint) uint
    // Reads one byte, or returns 0 without advancing at the end.
    + fn read_byte() u8
    // Reads the bytes up to the next zero byte into a `String` and advances past the zero.
    + fn read_cstring() String
    // Parses a decimal float and advances past it.
    + fn read_float() float
    // Parses a hexadecimal integer with an optional `-` or `+` sign and `0x`/`0X` prefix, advancing past it.
    + fn read_hex_int() int
    // Parses an unsigned hexadecimal integer with an optional `+` sign and `0x`/`0X` prefix, advancing past it.
    + fn read_hex_uint() uint
    // Parses a decimal integer with an optional `-` or `+` sign and advances past it.
    + fn read_int() int
    // Reads `bytes` bytes as an unsigned little-endian integer (meant for 1 to 8 bytes).
    + fn read_little_endian(bytes: uint) uint
    // Parses an octal integer with an optional `-` or `+` sign and `0c` prefix and advances past it.
    + fn read_octal_int() int
    // Parses an unsigned octal integer with an optional `+` sign and `0c` prefix and advances past it.
    + fn read_octal_uint() uint
    // Reads all remaining bytes into a new `String`.
    + fn read_remaining_string() String
    // Reads `len` bytes into a new `String`, or all remaining bytes when fewer are left.
    + fn read_string(len: uint) String
    // Reads a big-endian `u16`; returns 0 without advancing when fewer than 2 bytes remain.
    + fn read_u16_be() u16
    // Reads a little-endian `u16`; returns 0 without advancing when fewer than 2 bytes remain.
    + fn read_u16_le() u16
    // Reads a big-endian `u32`; returns 0 without advancing when fewer than 4 bytes remain.
    + fn read_u32_be() u32
    // Reads a little-endian `u32`; returns 0 without advancing when fewer than 4 bytes remain.
    + fn read_u32_le() u32
    // Reads a big-endian `u64`; returns 0 without advancing when fewer than 8 bytes remain.
    + fn read_u64_be() u64
    // Reads a little-endian `u64`; returns 0 without advancing when fewer than 8 bytes remain.
    + fn read_u64_le() u64
    // Parses an unsigned decimal integer with an optional `+` sign and advances past it.
    + fn read_uint() uint
    // Reads a big-endian `uint` of `size_of(uint)` bytes.
    + fn read_uint_be() uint
    // Reads a little-endian `uint` of `size_of(uint)` bytes.
    + fn read_uint_le() uint
    // Returns a view of the bytes that have not been read yet, without advancing.
    + fn remaining() &[u8]
    // Moves the position back to the start.
    + fn reset() void
    // Moves the position back by `amount` bytes, stopping at the start.
    + fn rewind(amount: uint) void
    // Moves the position to `offset` bytes relative to `from` and returns the new position.
    + fn seek(offset: int, from: SeekFrom (io.SeekFrom.start)) uint !io:IoError
    // Sets the position to `index`, clamped to the source length.
    + fn set_pos(index: uint) void
    // Advances the position by `amount` bytes, stopping at the end.
    + fn skip(amount: uint) void
}
```

### ByteReader

A read cursor over bytes, for parsing binary or text data.

`String` and `ByteBuffer` convert to `&[u8]`, so either can be the source. It implements
`io.Reader` and `io.Seeker`, so in-memory bytes can be streamed like a file. The reader
keeps a view, not a copy: bytes appended to a `ByteBuffer` source afterwards are not seen.

Reading past the end never throws: the `read_*` methods return 0 or a short or empty
string and leave the position where it was.

#### pos

Byte offset of the next read. May be set directly; a position past the end reads as the
end.

#### source

The bytes being read.

#### get_pos

Returns the current position in bytes.

#### new

Creates a reader at position 0 over `source`.

#### parse_float

Parses a decimal float like `read_float` and advances past it.

Throws `syntax`, without advancing, when the text at the position is not a valid
number or is out of range.

#### parse_int

Parses a decimal integer like `read_int` and advances past it.

Throws `syntax`, without advancing, when there is no number at the position or it
does not fit in `int`.

#### parse_uint

Parses an unsigned decimal integer like `read_uint` and advances past it.

Throws `syntax`, without advancing, when there is no number at the position or it
does not fit in `uint`.

#### read

Copies up to `buf.length` unread bytes into `buf` and advances past them.

Returns the number of bytes copied, 0 at the end. Never throws.

#### read_big_endian

Reads `bytes` bytes as an unsigned big-endian integer (meant for 1 to 8 bytes).

Returns 0 without advancing when fewer than `bytes` bytes remain.

#### read_byte

Reads one byte, or returns 0 without advancing at the end.

A 0 result is ambiguous when the data can contain zero bytes; check `remaining()` first.

#### read_cstring

Reads the bytes up to the next zero byte into a `String` and advances past the zero.

Returns "" without advancing when no zero byte remains.

#### read_float

Parses a decimal float and advances past it.

Accepts an optional `-` or `+` sign, digits with at most one `.` (at least one digit),
and an optional exponent (`e` or `E`, optional sign, digits). An `e` not followed by
digits is not part of the number, so `2em` reads 2 and leaves `em`. Returns 0 without
advancing when the text is not a valid number or is out of range; `parse_float` throws
instead.

#### read_hex_int

Parses a hexadecimal integer with an optional `-` or `+` sign and `0x`/`0X` prefix,
advancing past it.

Digits may be upper or lower case. Returns 0 without advancing when there is no number,
including a `0x` prefix without digits, or it does not fit in `int`.

#### read_hex_uint

Parses an unsigned hexadecimal integer with an optional `+` sign and `0x`/`0X` prefix,
advancing past it.

Digits may be upper or lower case. Returns 0 without advancing when there is no number,
including a `0x` prefix without digits, or it does not fit in `uint`.

#### read_int

Parses a decimal integer with an optional `-` or `+` sign and advances past it.

Parsing starts at the position (whitespace is not skipped) and stops at the first
non-digit. Returns 0 without advancing when there is no number or it does not fit in
`int`; `parse_int` throws instead.

#### read_little_endian

Reads `bytes` bytes as an unsigned little-endian integer (meant for 1 to 8 bytes).

Returns 0 without advancing when fewer than `bytes` bytes remain.

#### read_octal_int

Parses an octal integer with an optional `-` or `+` sign and `0c` prefix and advances
past it.

Stops at the first non-octal digit. Returns 0 without advancing when there is no number,
including a `0c` prefix without digits, or it does not fit in `int`.

#### read_octal_uint

Parses an unsigned octal integer with an optional `+` sign and `0c` prefix and advances
past it.

Stops at the first non-octal digit. Returns 0 without advancing when there is no number,
including a `0c` prefix without digits, or it does not fit in `uint`.

#### read_remaining_string

Reads all remaining bytes into a new `String`.

#### read_string

Reads `len` bytes into a new `String`, or all remaining bytes when fewer are left.

The bytes are copied as they are; no UTF-8 check is made.

#### read_u16_be

Reads a big-endian `u16`; returns 0 without advancing when fewer than 2 bytes remain.

#### read_u16_le

Reads a little-endian `u16`; returns 0 without advancing when fewer than 2 bytes remain.

#### read_u32_be

Reads a big-endian `u32`; returns 0 without advancing when fewer than 4 bytes remain.

#### read_u32_le

Reads a little-endian `u32`; returns 0 without advancing when fewer than 4 bytes remain.

#### read_u64_be

Reads a big-endian `u64`; returns 0 without advancing when fewer than 8 bytes remain.

#### read_u64_le

Reads a little-endian `u64`; returns 0 without advancing when fewer than 8 bytes remain.

#### read_uint

Parses an unsigned decimal integer with an optional `+` sign and advances past it.

Parsing starts at the position (whitespace is not skipped) and stops at the first
non-digit. Returns 0 without advancing when there is no number or it does not fit in
`uint`; `parse_uint` throws instead.

#### read_uint_be

Reads a big-endian `uint` of `size_of(uint)` bytes.

Returns 0 without advancing when fewer bytes remain.

#### read_uint_le

Reads a little-endian `uint` of `size_of(uint)` bytes.

Returns 0 without advancing when fewer bytes remain.

#### remaining

Returns a view of the bytes that have not been read yet, without advancing.

#### reset

Moves the position back to the start.

#### rewind

Moves the position back by `amount` bytes, stopping at the start.

#### seek

Moves the position to `offset` bytes relative to `from` and returns the new position.

Throws `range`, leaving the position unchanged, when the result would lie before the
start or past the end of the source.

#### set_pos

Sets the position to `index`, clamped to the source length.

#### skip

Advances the position by `amount` bytes, stopping at the end.

```js
// A double-ended queue: pushes and pops at both ends in amortized constant time.
+ class Deque[T] {
    // Removes every item.
    + fn clear() void
    // Returns a deep copy in which every item is cloned as well (`$clone`).
    + fn clone() Deque[T]
    // Returns true when an item equals `value` (compared with `==`), in linear time.
    + fn contains(value: T) bool
    // Returns a shallow copy: a new deque holding the same items.
    + fn copy() Deque[T]
    // Builds a deque from a JSON array, front first, converting each item with `to_type`.
    + static fn from_json_value_auto[X](value: X) Deque[T] !LookupError
    // Returns the item `index` places from the front; backs `deque[index]` (`$offset`).
    + fn get(index: uint) T !LookupError
    // Returns true when the deque holds no items.
    + fn is_empty() bool
    // The number of items.
    + get length: uint
    // Creates an empty deque with room for `capacity` items pushed at the back.
    + static fn new(capacity: uint (0)) Deque[T]
    // Returns the item at the back without removing it.
    + fn peek_back() T !LookupError
    // Returns the item at the front without removing it.
    + fn peek_front() T !LookupError
    // Removes and returns the item at the back.
    + fn pop_back() T !LookupError
    // Removes and returns the item at the front.
    + fn pop_front() T !LookupError
    // Adds `item` at the back.
    + fn push_back(item: T) void
    // Adds `item` at the front.
    + fn push_front(item: T) void
    // Replaces the item `index` places from the front; backs `deque[index] = value` (`$offset_assign`).
    + fn set(index: uint, value: T) void !LookupError
    // Returns a new array with the items from front to back.
    + fn to_array() Array[T]
}
```

### Deque

A double-ended queue: pushes and pops at both ends in amortized constant time.

Items are indexed from the front, and `each` visits them from front to back.

#### clear

Removes every item.

#### clone

Returns a deep copy in which every item is cloned as well (`$clone`).

#### contains

Returns true when an item equals `value` (compared with `==`), in linear time.

#### copy

Returns a shallow copy: a new deque holding the same items.

#### from_json_value_auto

Builds a deque from a JSON array, front first, converting each item with `to_type`.

Throws `.missing` when `value` is not an array or an item cannot be converted to the
item type.

#### get

Returns the item `index` places from the front; backs `deque[index]` (`$offset`).

Throws `missing` when `index` is out of range.

#### is_empty

Returns true when the deque holds no items.

#### length

The number of items.

#### new

Creates an empty deque with room for `capacity` items pushed at the back.

Marked `$default`: it also provides `Deque[T].$default_value`.

#### peek_back

Returns the item at the back without removing it.

Throws `missing` when the deque is empty.

#### peek_front

Returns the item at the front without removing it.

Throws `missing` when the deque is empty.

#### pop_back

Removes and returns the item at the back.

Throws `missing` when the deque is empty.

#### pop_front

Removes and returns the item at the front.

Throws `missing` when the deque is empty.

#### push_back

Adds `item` at the back.

Backs the `Deque[T]{ a, b }` list literal (`$append`), which pushes each item at the back.

#### push_front

Adds `item` at the front.

#### set

Replaces the item `index` places from the front; backs `deque[index] = value`
(`$offset_assign`).

Throws `missing` when `index` is out of range; unlike `Array.set`, it never appends.

#### to_array

Returns a new array with the items from front to back.

```js
// A map that keeps its keys and values in two arrays and finds keys by linear search.
+ class FlatMap[K, T] {
    // Removes every entry.
    + fn clear() void
    // Returns a deep copy: every key and value is cloned with `$clone`.
    + fn clone() FlatMap[K, T]
    // Returns a shallow copy: a new map holding the same keys and values.
    + fn copy() FlatMap[K, T]
    // Returns the value stored under `key`; backs `map[key]`.
    + fn get(key: K) T !LookupError
    // Returns whether an entry for `key` exists.
    + fn has(key: K) bool
    // Returns whether any entry holds a value equal to `value`.
    + fn has_value(value: T) bool
    // Returns a new array of the keys, in entry order.
    + fn keys() Array[K]
    // The number of entries.
    + get length: uint
    // Returns a new map with the entries of this map and of `map`; `map` wins on shared keys.
    + fn merge(map: FlatMap[K, T]) FlatMap[K, T]
    // Copies every entry of `map` into this map; the same as `set_many`.
    + fn merge_in_place(map: FlatMap[K, T]) void
    // Creates an empty map.
    + static fn new() FlatMap[K, T]
    // Removes the entry for `key`, keeping the order of the rest; does nothing when absent.
    + fn remove(key: K) void
    // Removes the entries for which `func` returns true; the rest keep their order.
    + fn remove_where(func: fn(T, K)(bool)) void
    // Keeps only the entries for which `func` returns true; the opposite of `remove_where`.
    + fn retain(func: fn(T, K)(bool)) void
    // Stores `value` under `key`, replacing the value of an existing entry in place.
    + fn set(key: K, value: T) void
    // Copies every entry of `map` into this map, replacing values of keys both maps have.
    + fn set_many(map: FlatMap[K, T]) void
    // Adds a new entry for `key` at the end.
    + fn set_unique(key: K, value: T) void !LookupError
    // Returns a new array of the values, in entry order.
    + fn values() Array[T]
}
```

### FlatMap

A map that keeps its keys and values in two arrays and finds keys by linear search.

Lookups, inserts and removals cost O(n), so it suits small maps. Keys are compared with
`==` and need no hash. Entries stay in insertion order, also after removals. Build one
with `FlatMap[K, T]{ k => v }` and iterate with `each map as value, key`. Removing entries
inside `each` is safe: the loop still visits every entry that was not removed, once.

#### clear

Removes every entry.

#### clone

Returns a deep copy: every key and value is cloned with `$clone`.

Marked `$clone`: backs `$clone(map)`.

#### copy

Returns a shallow copy: a new map holding the same keys and values.

#### get

Returns the value stored under `key`; backs `map[key]`.

Throws `missing` when `key` is absent.

#### has

Returns whether an entry for `key` exists.

#### has_value

Returns whether any entry holds a value equal to `value`.

#### keys

Returns a new array of the keys, in entry order.

#### length

The number of entries.

#### merge

Returns a new map with the entries of this map and of `map`; `map` wins on shared keys.

Marked `$add`: backs `a + b`. Neither operand changes.

#### merge_in_place

Copies every entry of `map` into this map; the same as `set_many`.

#### new

Creates an empty map.

Marked `$default`: it also provides the type's default value.

#### remove

Removes the entry for `key`, keeping the order of the rest; does nothing when absent.

#### remove_where

Removes the entries for which `func` returns true; the rest keep their order.

`func` gets the value and the key, like `each map as value, key`, and must not change
the map. Inside an `each` over this map the loop still visits every kept entry once.

#### retain

Keeps only the entries for which `func` returns true; the opposite of `remove_where`.

#### set

Stores `value` under `key`, replacing the value of an existing entry in place.

Backs `map[key] = value` (`$offset_assign`) and the literal `FlatMap[K, T]{ k => v }`
(`$set_key`). A new key is added at the end.

#### set_many

Copies every entry of `map` into this map, replacing values of keys both maps have.

#### set_unique

Adds a new entry for `key` at the end.

Throws `exists`, leaving the map unchanged, when `key` is already present.

#### values

Returns a new array of the values, in entry order.

```js
// A hash table from keys of type `K` to values of type `T`.
+ class HashMap[K, T] {
    // Removes every entry.
    + fn clear() void
    // Returns a deep copy: every key and value is cloned with `$clone`.
    + fn clone() HashMap[K, T]
    // Returns a shallow copy: a new map holding the same keys and values.
    + fn copy() HashMap[K, T]
    // Returns the value stored under `key`; backs `map[key]`.
    + fn get(key: K) T !LookupError
    // Looks up `key`; when it is absent, removes `remove_key` and stores `replacement` under `key` instead, without probing for `key` twice.
    + fn get_or_replace(key: K, remove_key: K, replacement: T) (T, bool) !LookupError
    // Returns whether an entry for `key` exists.
    + fn has(key: K) bool
    // Returns whether any entry holds a value equal to `value` (a linear scan using `==`).
    + fn has_value(value: T) bool
    // Returns a new array of the keys, in entry order.
    + fn keys() Array[K]
    // The number of entries.
    + get length: uint
    // Returns a new map with the entries of this map and of `map`; `map` wins on shared keys.
    + fn merge(map: HashMap[K, T]) HashMap[K, T]
    // Copies every entry of `map` into this map, replacing values of keys both maps have.
    + fn merge_in_place(map: HashMap[K, T]) void
    // Creates an empty map with room for `capacity` entries, without rehashing.
    + static fn new(capacity: uint (0)) HashMap[K, T]
    // Removes the entry for `key`; does nothing when it is absent.
    + fn remove(key: K) void
    // Removes the entries for which `func` returns true; the rest keep their order.
    + fn remove_where(func: fn(T, K)(bool)) void
    // Keeps only the entries for which `func` returns true; the opposite of `remove_where`.
    + fn retain(func: fn(T, K)(bool)) void
    // Stores `value` under `key`, replacing the value of an existing entry in place.
    + fn set(key: K, value: T) void
    // Adds a new entry for `key`.
    + fn set_unique(key: K, value: T) void !LookupError
    // Returns a new array of the values, in entry order.
    + fn values() Array[T]
}
```

### HashMap

A hash table from keys of type `K` to values of type `T`.

Keys hash with their `$hash` method, otherwise integers by value and pointers by
address; keys are compared with `==`, so equal keys must hash the same. Entries keep
insertion order for `each`, `keys` and `values`, except that removing an entry moves
the last entry into its place. Removing entries inside `each` is safe: the loop still
visits every entry that was not removed, once, and skips the removed ones.
Build one with `HashMap[K, T]{ k => v }` and iterate with `each map as value, key`.

#### clear

Removes every entry.

The bucket table's memory is released, but its size is kept: refilling the map to its
earlier size, or to the capacity passed to `new`, does not rehash.

#### clone

Returns a deep copy: every key and value is cloned with `$clone`.

Marked `$clone`: backs `$clone(map)`.

#### copy

Returns a shallow copy: a new map holding the same keys and values.

#### get

Returns the value stored under `key`; backs `map[key]`.

Throws `missing` when `key` is absent.

#### get_or_replace

Looks up `key`; when it is absent, removes `remove_key` and stores `replacement` under
`key` instead, without probing for `key` twice.

Returns the value and true when `key` was present, or `replacement` and false when it
was inserted. The entry count stays the same, which suits fixed-size caches. Throws
`missing`, leaving the map unchanged, when both `key` and `remove_key` are absent.

#### has

Returns whether an entry for `key` exists.

#### has_value

Returns whether any entry holds a value equal to `value` (a linear scan using `==`).

#### keys

Returns a new array of the keys, in entry order.

#### length

The number of entries.

#### merge

Returns a new map with the entries of this map and of `map`; `map` wins on shared keys.

Marked `$add`: backs `a + b`. Neither operand changes.

#### merge_in_place

Copies every entry of `map` into this map, replacing values of keys both maps have.

#### new

Creates an empty map with room for `capacity` entries, without rehashing.

Panics when `capacity` is too large. Marked `$default`: it also provides the type's
default value.

#### remove

Removes the entry for `key`; does nothing when it is absent.

The last entry moves into the removed entry's position, so iteration order changes.
Inside an `each` over this map nothing moves until the loop ends, so the loop still
visits every other entry once.

#### remove_where

Removes the entries for which `func` returns true; the rest keep their order.

`func` gets the value and the key, like `each map as value, key`, and must not change
the map. Inside an `each` over this map the loop still visits every kept entry once.

#### retain

Keeps only the entries for which `func` returns true; the opposite of `remove_where`.

#### set

Stores `value` under `key`, replacing the value of an existing entry in place.

Backs `map[key] = value` (`$offset_assign`) and the literal `HashMap[K, T]{ k => v }`
(`$set_key`). An existing entry keeps its position and its original key object.

#### set_unique

Adds a new entry for `key`.

Throws `exists`, leaving the map unchanged, when `key` is already present.

#### values

Returns a new array of the values, in entry order.

```js
+ extend HashMap[String, T] {
    // Builds a map from a JSON object, converting each member with `to_type`.
    + static fn from_json_value_auto[X](value: X) HashMap[String, T] !LookupError
    // Reorders the entries so iteration, `keys` and `values` follow ascending key order.
    + fn sort_keys() void
}
```

#### HashMap[String, T].from_json_value_auto

Builds a map from a JSON object, converting each member with `to_type`.

Only available when the key type is `String`. Throws `.missing` when `value` is
not an object or a member cannot be converted to the value type.

#### HashMap[String, T].sort_keys

Reorders the entries so iteration, `keys` and `values` follow ascending key order.

```js
+ extend HashMap[u32, T] {
    // Builds a map from a JSON object whose member names are integers, converting each member with `to_type`.
    + static fn from_json_value_auto[X](value: X) HashMap[u32, T] !LookupError
    // Reorders the entries so iteration, `keys` and `values` follow ascending key order.
    + fn sort_keys() void
}
```

#### HashMap[u32, T].from_json_value_auto

Builds a map from a JSON object whose member names are integers, converting each
member with `to_type`.

Throws `.missing` when `value` is not an object, a name is not an integer of the key
type, or a member cannot be converted to the value type.

#### HashMap[u32, T].sort_keys

Reorders the entries so iteration, `keys` and `values` follow ascending key order.

```js
// A set of unique values, hashed and compared like `HashMap` keys.
+ class HashSet[T] {
    // Adds `value`; adding a value that is already present changes nothing.
    + fn add(value: T) void
    // Adds every value of `values`.
    + fn add_all(values: Array[T]) void
    // Removes every value.
    + fn clear() void
    // Returns a deep copy in which every value is cloned as well (`$clone`).
    + fn clone() HashSet[T]
    // Returns a shallow copy: a new set holding the same values.
    + fn copy() HashSet[T]
    // Returns a new set with the values of this set that are not in `other`; backs `a - b` (`$sub`).
    + fn difference(other: HashSet[T]) HashSet[T]
    // Returns true when both sets hold the same values, in any order; backs `==` (`$eq`).
    + fn equals(other: HashSet[T]) bool
    // Builds a set from a JSON array, converting each item with `to_type`.
    + static fn from_json_value_auto[X](value: X) HashSet[T] !LookupError
    // Returns true when `value` is in the set.
    + fn has(value: T) bool
    // Adds `value` and returns true when it was not present yet.
    + fn insert(value: T) bool
    // Returns a new set with the values that are in both sets.
    + fn intersection(other: HashSet[T]) HashSet[T]
    // Returns true when the two sets share no value.
    + fn is_disjoint(other: HashSet[T]) bool
    // Returns true when every value of this set is also in `other`.
    + fn is_subset_of(other: HashSet[T]) bool
    // Returns the values as a new array, in iteration order.
    + fn items() Array[T]
    // The number of values.
    + get length: uint
    // Creates an empty set with room for `capacity` values.
    + static fn new(capacity: uint (0)) HashSet[T]
    // Removes `value` and returns true when it was present.
    + fn remove(value: T) bool
    // Removes the values for which `func` returns true; the rest keep their order.
    + fn remove_where(func: fn(T)(bool)) void
    // Keeps only the values for which `func` returns true; the opposite of `remove_where`.
    + fn retain(func: fn(T)(bool)) void
    // Returns a new set with the values in this set or in `other`; backs `a + b` (`$add`).
    + fn union(other: HashSet[T]) HashSet[T]
}
```

### HashSet

A set of unique values, hashed and compared like `HashMap` keys.

`each` visits the values in insertion order until a removal, which moves the last value
into the freed slot.

#### add

Adds `value`; adding a value that is already present changes nothing.

Backs the `HashSet[T]{ a, b }` list literal (`$append`).

#### add_all

Adds every value of `values`.

#### clear

Removes every value.

#### clone

Returns a deep copy in which every value is cloned as well (`$clone`).

#### copy

Returns a shallow copy: a new set holding the same values.

#### difference

Returns a new set with the values of this set that are not in `other`; backs `a - b`
(`$sub`).

#### equals

Returns true when both sets hold the same values, in any order; backs `==` (`$eq`).

#### from_json_value_auto

Builds a set from a JSON array, converting each item with `to_type`.

Throws `.missing` when `value` is not an array or an item cannot be converted to the
item type.

#### has

Returns true when `value` is in the set.

#### insert

Adds `value` and returns true when it was not present yet.

#### intersection

Returns a new set with the values that are in both sets.

#### is_disjoint

Returns true when the two sets share no value.

#### is_subset_of

Returns true when every value of this set is also in `other`.

#### items

Returns the values as a new array, in iteration order.

#### length

The number of values.

#### new

Creates an empty set with room for `capacity` values.

Marked `$default`: it also provides `HashSet[T].$default_value`.

#### remove

Removes `value` and returns true when it was present.

The last value in iteration order moves into the position of the removed one.

#### remove_where

Removes the values for which `func` returns true; the rest keep their order.

#### retain

Keeps only the values for which `func` returns true; the opposite of `remove_where`.

#### union

Returns a new set with the values in this set or in `other`; backs `a + b` (`$add`).

```js
// A binary heap: `pop` returns the item that sorts first.
+ class Heap[T] {
    // Removes every item.
    + fn clear() void
    // Returns a shallow copy with the same items and the same order function.
    + fn copy() Heap[T]
    // Removes every item and returns them sorted, first item first.
    + fn drain() Array[T]
    // Returns true when the heap holds no items.
    + fn is_empty() bool
    // The number of items.
    + get length: uint
    // Creates an empty heap ordered by `before`.
    + static fn new(before: fn(T, T)(bool)) Heap[T]
    // Returns the first item without removing it.
    + fn peek() T !LookupError
    // Removes and returns the first item, in O(log n).
    + fn pop() T !LookupError
    // Adds `item` in O(log n); backs the `Heap[T]{ a, b }` list literal (`$append`).
    + fn push(item: T) void
    // Pushes `item` and pops the first item in one step.
    + fn replace(item: T) T !LookupError
    // Returns the items as a new array in heap order, which is not sorted.
    + fn to_array() Array[T]
}
```

### Heap

A binary heap: `pop` returns the item that sorts first.

By default the smallest item (by `<`) comes first; a `before(a, b)` function that returns
true when `a` must come out before `b` chooses another order. Items that compare equal
come out in no particular order, and `each` visits the items in heap order, not sorted.

#### clear

Removes every item.

#### copy

Returns a shallow copy with the same items and the same order function.

#### drain

Removes every item and returns them sorted, first item first.

#### is_empty

Returns true when the heap holds no items.

#### length

The number of items.

#### new

Creates an empty heap ordered by `before`.

This form is used when `T` has no `<`; the `before` function is then required.

#### peek

Returns the first item without removing it.

Throws `empty` when the heap is empty.

#### pop

Removes and returns the first item, in O(log n).

Throws `empty` when the heap is empty.

#### push

Adds `item` in O(log n); backs the `Heap[T]{ a, b }` list literal (`$append`).

#### replace

Pushes `item` and pops the first item in one step.

When `item` comes before the current first item, returns `item` itself and leaves the
heap unchanged. Throws `empty` when the heap is empty, without pushing `item`.

#### to_array

Returns the items as a new array in heap order, which is not sorted.

```js
// Mutable shared data. The value can only be reached inside a `lock` block, which holds the mutex for the length of the block:
+ class Lock[T] {
    // Creates a lock holding `value`.
    + static fn new(value: T) Lock[T] !InitError
}
```

### Lock

Mutable shared data. The value can only be reached inside a `lock` block,
which holds the mutex for the length of the block:

```valk
let state: shared Lock[Stats] = .new(Stats {}) !>
lock state as s {
    s.count++
}
```

`T` must be a class type. Waiting for the lock yields to other coroutines on the thread.
The lock is not reentrant: taking it again inside its own `lock` block deadlocks.

#### new

Creates a lock holding `value`.

Throws `init` when the underlying `Mutex` cannot be created.

```js
// A `HashMap` with `String` keys, compatible with `HashMap[String, T]` in both directions.
+ mode Map[T] for HashMap[String, T] {
    // Returns a deep copy as a `Map`: every key and value is cloned with `$clone`.
    + fn clone() Map[T]
    // Creates an empty map.
    + static fn new() Map[T]
}
```

### Map

A `HashMap` with `String` keys, compatible with `HashMap[String, T]` in both directions.

Build one with `Map[T]{ "k" => v }`; every `HashMap` method applies.

#### clone

Returns a deep copy as a `Map`: every key and value is cloned with `$clone`.

#### new

Creates an empty map.

Marked `$default`: it also provides the type's default value.

```js
// A mutual-exclusion lock whose waiters yield to other coroutines instead of blocking the thread.
+ class Mutex {
    // Waits until the mutex is unlocked, without keeping it locked.
    + fn await_unlock() void
    // Returns this same mutex, so clones of an object that holds it share it (`$clone`).
    + fn clone() Mutex
    // Takes the mutex, waiting while it is locked.
    + fn lock() void
    // Creates an unlocked mutex.
    + static fn new() Mutex !InitError
    // Releases the mutex and wakes the longest waiting waiter.
    + fn unlock() void
}
```

### Mutex

A mutual-exclusion lock whose waiters yield to other coroutines instead of blocking the thread.

Outside a coroutine, waiting blocks the thread. The mutex is not reentrant and has no
owner: any coroutine or thread may `unlock` it. It works across threads. Locking and
unlocking without contention are single atomic operations; `unlock` wakes the longest
waiting waiter, which takes the mutex unless another locker was quicker.

#### await_unlock

Waits until the mutex is unlocked, without keeping it locked.

#### clone

Returns this same mutex, so clones of an object that holds it share it (`$clone`).

#### lock

Takes the mutex, waiting while it is locked.

Inside a coroutine the wait yields to other coroutines on the thread; outside one it
blocks the thread. Locking it again from the same coroutine before `unlock` deadlocks.

#### new

Creates an unlocked mutex.

Never fails since the mutex holds no operating system resource; the error type is kept
for existing callers.

#### unlock

Releases the mutex and wakes the longest waiting waiter.

Does nothing when the mutex is not locked.

```js
// A stack of plain values in one manually allocated block, for recycling items.
+ class Pool[T] {
    // The number of items currently stored.
    ~ count: uint

    // Stores `item`, doubling the storage when it is full.
    + fn add(item: T) void
    // Removes and returns the most recently added item.
    + fn get() T !LookupError
    // Creates an empty pool with room for `start_size` items (at least 2).
    + static fn new(start_size: uint (2)) Pool[T]
}
```

### Pool

A stack of plain values in one manually allocated block, for recycling items.

`get` returns the most recently added item. `T` cannot contain GC references: `add`
fails to compile for such a type.

#### count

The number of items currently stored.

#### add

Stores `item`, doubling the storage when it is full.

Panics when the capacity overflows.

#### get

Removes and returns the most recently added item.

Throws `empty` when the pool is empty.

#### new

Creates an empty pool with room for `start_size` items (at least 2).

Panics when the size in bytes overflows. Marked `$default`: it also provides
`Pool[T].$default_value`.

```js
// A child process started with `Process.start`, `Process.run` or `Process.output`.
+ class Process {
    // The child's stderr when it was started with `stderr: Stdio.pipe`.
    ~ stderr: ProcessPipe
    // The child's stdin when it was started with `stdin: Stdio.pipe`; close it to end the child's input.
    ~ stdin: ProcessPipe
    // The child's stdout when it was started with `stdout: Stdio.pipe`.
    ~ stdout: ProcessPipe

    // Gives up control of the child, which keeps running on its own.
    + fn detach() void !io:IoError
    // Returns true when the child has exited, without waiting.
    + fn did_exit() bool !io:IoError
    // Waits for the child to exit and returns its exit code; `wait` without a timeout.
    + fn exit_code() i32 !io:IoError
    // Returns the child's process id.
    + fn id() uint
    // Runs `exe` with `args` to its end and returns its exit code, stdout and stderr.
    + static fn output(exe: String, args: ?Array[String] (null), input: ?String (null), cwd: ?String (null), env: ?Map[String] (null)) ProcessOutput !io:IoError
    // Starts `exe` with `args` and returns without waiting for it.
    + static fn run(exe: String, args: ?Array[String] (null), print_output: bool (false)) Process !io:IoError
    // Sends `sig` to the child; does nothing once it has exited.
    + fn signal(sig: Signal) void !io:IoError
    // Starts `exe` with `args` and returns without waiting for it.
    + static fn start(exe: String, args: ?Array[String] (null), stdin: Stdio (Stdio.inherit), stdout: Stdio (Stdio.inherit), stderr: Stdio (Stdio.inherit), cwd: ?String (null), env: ?Map[String] (null)) Process !io:IoError
    // Kills the child and waits for it to exit; inside a coroutine only the coroutine waits.
    + fn stop() void !io:IoError
    // Waits for the child to exit and returns its exit code.
    + fn wait(timeout_ms: uint (0)) i32 !io:IoError
}
```

### Process

A child process started with `Process.start`, `Process.run` or `Process.output`.

Dropping a `Process` does not stop its child. On Linux and macOS a background thread
reaps a dropped child once it exits.

#### stderr

The child's stderr when it was started with `stderr: Stdio.pipe`.

#### stdin

The child's stdin when it was started with `stdin: Stdio.pipe`; close it to end the
child's input.

#### stdout

The child's stdout when it was started with `stdout: Stdio.pipe`.

#### detach

Gives up control of the child, which keeps running on its own.

On Linux and macOS a background thread reaps it once it exits. Afterwards `did_exit`,
`exit_code` and `stop` throw `closed`. Does nothing when an earlier `did_exit` or
`exit_code` already saw the child exit. Throws `os` when the reaper cannot take it.

#### did_exit

Returns true when the child has exited, without waiting.

Throws `closed` after `detach`, and `os` when the child's status cannot be read.

#### exit_code

Waits for the child to exit and returns its exit code; `wait` without a timeout.

#### id

Returns the child's process id.

#### output

Runs `exe` with `args` to its end and returns its exit code, stdout and stderr.

Starts it like `start`, without a shell. `input` is written to the child's stdin,
which is empty otherwise. The output is read while the child runs, and only the
current coroutine waits. Throws `os` when the process cannot be started, and `read`
when its output cannot be read.

#### run

Starts `exe` with `args` and returns without waiting for it.

Like `start`, with stdin inherited. Without `print_output` the child's stdout and
stderr are discarded; with it the child shares this process's streams.

#### signal

Sends `sig` to the child; does nothing once it has exited.

Windows has no signals: `terminate` ends the child at once with exit code 143 there, and
every other signal throws `os`. Throws `closed` after `detach`, and `os` when the signal
cannot be sent.

#### start

Starts `exe` with `args` and returns without waiting for it.

No shell is involved: every argument reaches the program as it is, without quoting.
Each standard stream is inherited from this process, a pipe (see `stdin`, `stdout`
and `stderr`) or discarded. `cwd` is the child's working directory. `env` replaces the
child's environment; start from `env_vars()` to extend this process's own.

A bare `exe` name is searched in `PATH`, on Linux and macOS in the `PATH` of `env` when
it is given. On Linux and macOS a program that cannot be executed, or a `cwd` that
cannot be entered, still yields a `Process` whose exit code is 127. On Windows `.exe`
is added to a name without an extension, the directories Windows searches before
`PATH` (the program's own, the current and the system directories) come first, and the
arguments are quoted for the standard command-line parser. On Linux a piped stdin makes
the process ignore `SIGPIPE` from then on, so writing to a child that exited throws
instead of ending this process. Throws `os` when the process or a pipe cannot be
created.

#### stop

Kills the child and waits for it to exit; inside a coroutine only the coroutine waits.

Uses `SIGKILL` on Linux and macOS, and `TerminateProcess` with exit code 137 on Windows.
Does nothing when the child has already exited or was stopped before. Throws `closed`
after `detach`, and `os` when the kill fails.

#### wait

Waits for the child to exit and returns its exit code.

Inside a coroutine only the coroutine waits; the thread keeps running the others. With
a `timeout_ms` above 0 it throws `timeout` when the child still runs after that long,
and the child keeps running. On Linux and macOS a child killed by a signal reports 128
plus the signal number. Throws `closed` after `detach`, and `os` when waiting fails.

```js
// What `Process.output` collected from a child that ran to its end.
+ struct ProcessOutput {
    // The exit code; see `Process.wait`.
    + code: i32
    // Everything the child wrote to stderr.
    + stderr: String
    // Everything the child wrote to stdout.
    + stdout: String
}
```

### ProcessOutput

What `Process.output` collected from a child that ran to its end.

#### code

The exit code; see `Process.wait`.

#### stderr

Everything the child wrote to stderr.

#### stdout

Everything the child wrote to stdout.

```js
// This process's end of a pipe to one standard stream of a child, see `Process.start`.
+ class ProcessPipe is Reader, Writer, Closer {
    // Closes this end; closing `stdin` ends the child's input. Does nothing when closed.
    + fn close() void !io:IoError
    // Reads up to `buf.length` bytes of the child's output into `buf` and returns the count.
    + fn read(buf: local mut &[u8]) uint !io:IoError
    // Reads until the child's end is closed and returns everything read as text.
    + fn read_all() String !io:IoError
    // Writes all of `data` to the child's stdin and returns `data.length`.
    + fn write(data: local &[u8]) uint !io:IoError
}
```

### ProcessPipe

This process's end of a pipe to one standard stream of a child, see `Process.start`.

Reads and writes suspend only the current coroutine while they wait. A stream that was
not started as `Stdio.pipe` is closed.

#### close

Closes this end; closing `stdin` ends the child's input. Does nothing when closed.

Throws `os` when the OS reports a failure.

#### read

Reads up to `buf.length` bytes of the child's output into `buf` and returns the count.

Returns 0 once the child's end is closed, usually because it exited. Throws `closed`
after `close` or when the stream is not a pipe, and `read` when reading fails.

#### read_all

Reads until the child's end is closed and returns everything read as text.

Throws like `read`.

#### write

Writes all of `data` to the child's stdin and returns `data.length`.

Throws `write` when the child closed its end, for example because it exited, and
`closed` after `close` or when the stream is not a pipe.

```js
// An immutable string of bytes, normally UTF-8, always followed by a zero byte in memory.
+ slice String of u8 {
    // The address of the first element.
    ~ data: *[u8]
    // The number of elements.
    ~ length: uint
    // The allocation that keeps the elements alive; null for storage nobody owns, such as a literal or unsafe memory.
    ~ owner: ?GcPtr

    // Returns a new string with the bytes of `add` after this one; backs the `+` operator.
    + fn add(add: String) String
    // Allocates a string of `length` bytes plus the zero terminator, to fill in `@unsafe` code.
    + static fn alloc(length: uint) String
    // Returns the string colored black with ANSI codes, then a reset; `bold` makes it bold.
    + fn ansi.black(bold: bool (false)) String
    // Returns the string colored blue with ANSI codes, then a reset; `bold` makes it bold.
    + fn ansi.blue(bold: bool (false)) String
    // Returns the string colored cyan with ANSI codes, then a reset; `bold` makes it bold.
    + fn ansi.cyan(bold: bool (false)) String
    // Returns the string at reduced intensity, for text that matters less.
    + fn ansi.dim() String
    // Returns the string colored green with ANSI codes, then a reset; `bold` makes it bold.
    + fn ansi.green(bold: bool (false)) String
    // Returns the string colored purple with ANSI codes, then a reset; `bold` makes it bold.
    + fn ansi.purple(bold: bool (false)) String
    // Returns the string colored red with ANSI codes, then a reset; `bold` makes it bold.
    + fn ansi.red(bold: bool (false)) String
    // Returns the string colored white with ANSI codes, then a reset; `bold` makes it bold.
    + fn ansi.white(bold: bool (false)) String
    // Returns the string colored yellow with ANSI codes, then a reset; `bold` makes it bold.
    + fn ansi.yellow(bold: bool (false)) String
    // The number of bytes in the string, not counting the zero terminator.
    + get bytes: uint
    // Returns a copy of the string in new storage; the `$clone` hook.
    + fn clone() String
    // Returns whether `part` occurs at or after byte offset `start_index`.
    + fn contains(part: String, start_index: uint (0)) bool
    // Returns whether `byte` occurs at or after byte offset `start_index`.
    + fn contains_byte(byte: u8, start_index: uint (0)) bool
    // Returns a new string holding a copy of the `length` bytes at `data`.
    + static fn copy_from_ptr(data: ptr, length: uint) String
    // The bytes as a zero-terminated C string, without copying.
    + get data_cstring: cstring
    // Returns whether the string ends with the bytes of `part`; an empty `part` always matches.
    + fn ends_with(part: String) bool
    // Returns whether both strings hold the same bytes; backs `==`.
    + fn equals(cmp: String) bool
    // Returns whether both strings are equal when ASCII letters are compared case-insensitively.
    + fn equals_ignore_ascii_case(other: String) bool
    // Returns a copy with special characters written as backslash escapes, as in a string literal.
    + fn escape() String
    // Returns the byte at byte offset `index`; backs `str[i]`.
    + fn get(index: uint) u8
    // Returns whether the string sorts after `cmp` in byte order; backs `>`.
    + fn gt(cmp: String) bool
    // Returns whether the string equals `cmp` or sorts after it in byte order; backs `>=`.
    + fn gte(cmp: String) bool
    // Returns a hash of the bytes; the `$hash` hook that `HashMap` and `HashSet` keys use.
    + fn hash() uint
    // Parses the string as a hexadecimal signed integer: optional `-` or `+`, optional `0x`, digits.
    + fn hex_to_int() int !SyntaxError
    // Parses the string as a hexadecimal unsigned integer: optional `+`, optional `0x`, digits.
    + fn hex_to_uint() uint !SyntaxError
    // Returns the byte offset of the first occurrence of `part` at or after `start_index`.
    + fn index_of(part: String, start_index: uint (0)) uint !LookupError
    // Returns the byte offset of the first `byte` at or after `start_index`.
    + fn index_of_byte(byte: u8, start_index: uint (0)) uint !LookupError
    // Returns whether every character is a Unicode letter or a byte in `allow_extra_bytes`.
    + fn is_alpha(allow_extra_bytes: String ("")) bool
    // Returns whether every character is a Unicode letter, a number, or a byte in `allow_extra_bytes`.
    + fn is_alpha_numeric(allow_extra_bytes: String ("")) bool
    // Returns whether the string has no bytes.
    + fn is_empty() bool
    // Returns whether the string is non-empty and holds only the digits `0`-`9`.
    + fn is_integer() bool
    // Returns whether no character in the string has a lower-case mapping.
    + fn is_lower() bool
    // Returns whether the string holds only digits `0`-`9` and at most one `.`, with at least one digit.
    + fn is_number() bool
    // Returns whether every byte is allowed by `mask`, or with `mask_is_exclude`, whether none is.
    + fn is_syntax(mask: String, mask_is_exclude: bool (false)) bool
    // Returns whether no character in the string has an upper-case mapping.
    + fn is_upper() bool
    // Returns the string with every character mapped to lower case by the Unicode case mappings.
    + fn lower() String
    // Returns whether the string sorts before `cmp`; backs `<`.
    + fn lt(cmp: String) bool
    // Returns whether the string equals `cmp` or sorts before it in byte order; backs `<=`.
    + fn lte(cmp: String) bool
    // Removes whitespace, or repeated copies of `part`, from the start of the string.
    + fn ltrim(part: ?String (null), limit: uint (0)) String
    // Parses the string as an octal signed integer: optional `-` or `+`, optional `0c`, digits.
    + fn octal_to_int() int !SyntaxError
    // Parses the string as an octal unsigned integer: optional `+`, optional `0c`, digits.
    + fn octal_to_uint() uint !SyntaxError
    // Returns the string prefixed with the byte `char` until it is `length` bytes long.
    + fn pad_left(char: u8, length: uint) String
    // Returns the string followed by the byte `char` until it is `length` bytes long.
    + fn pad_right(char: u8, length: uint) String
    // Returns `len` random bytes, each drawn uniformly from the bytes of `characters`.
    + static fn random(len: uint, characters: String ("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")) String
    // Returns a copy of `length` bytes from `start_index`; backs `str[start .. length]`.
    + fn range(start_index: uint, length: uint) String
    // Returns a `ByteReader` that reads the string's bytes from the start without copying them.
    + fn reader() ByteReader
    // Returns a copy with every occurrence of `part` replaced by `with`.
    + fn replace(part: String, with: String) String
    // Removes whitespace, or repeated copies of `part`, from the end of the string.
    + fn rtrim(part: ?String (null), limit: uint (0)) String
    // Splits the string on every occurrence of `on` and returns the parts, empty ones included.
    + fn split(on: String) Array[String]
    // Returns whether the string begins with the bytes of `part`; an empty `part` always matches.
    + fn starts_with(part: String) bool
    // Parses the string as a decimal floating-point number.
    + fn to_float() f64 !SyntaxError
    // Parses the string as a decimal signed integer with an optional `-` or `+` sign.
    + fn to_int() int !SyntaxError
    // Parses the string as the number type `T`; the compiler lowers `"100".to(u8)` to this method.
    + fn to_number[T]() T !SyntaxError
    // Returns the string itself, without copying.
    + fn to_string() String
    // Parses the string as a decimal unsigned integer, with an optional leading `+`.
    + fn to_uint() uint !SyntaxError
    // Removes whitespace, or repeated copies of `part`, from both ends of the string.
    + fn trim(part: ?String (null), limit: uint (0)) String
    // Returns a copy with backslash escapes turned back into the bytes they stand for.
    + fn unescape() String
    // Returns the string with every character mapped to upper case by the Unicode case mappings.
    + fn upper() String
    // Returns an iterator that yields each UTF-8 character as its own `String`, for `each`.
    + fn utf8.chars() StringChars
    // Returns whether `part` occurs in the string starting on a character boundary.
    + fn utf8.contains(part: String) bool
    // Returns the character at character index `index` as a `String`, or `""` past the end.
    + fn utf8.get(index: uint) String
    // Returns the character index of the first `part` at or after character `start_index`.
    + fn utf8.index_of(part: String, start_index: uint (0)) uint !LookupError
    // The number of UTF-8 characters, counted by walking the string from the start.
    + get utf8.length: uint
    // Returns a copy of `length` characters starting at character index `start_index`.
    + fn utf8.range(start_index: uint, length: uint) String
    // Splits the string on every occurrence of `on` that starts on a character boundary.
    + fn utf8.split(on: String) Array[String]
    // Returns a read-only view of `length` bytes from `start_index`, sharing the storage.
    + fn view(start_index: uint (0), length: uint (uint.$max)) &[u8]
}
```

### String

An immutable string of bytes, normally UTF-8, always followed by a zero byte in memory.

Indexes, lengths and ranges count bytes; the `utf8` group works in characters. The
content is not validated as UTF-8 and may contain zero bytes. `$global` makes the name
available in every namespace, and `$immutable` makes the bytes read-only outside this
class.

#### data

The address of the first element.

#### length

The number of elements.

#### owner

The allocation that keeps the elements alive; null for storage nobody owns, such as a literal or unsafe memory.

#### add

Returns a new string with the bytes of `add` after this one; backs the `+` operator.

Panics when the combined length does not fit in `uint`.

#### alloc

Allocates a string of `length` bytes plus the zero terminator, to fill in `@unsafe` code.

A `length` of 0 returns the shared empty literal, which must not be written. Panics when
`length + 1` overflows.

#### ansi.black

Returns the string colored black with ANSI codes, then a reset; `bold` makes it bold.

#### ansi.blue

Returns the string colored blue with ANSI codes, then a reset; `bold` makes it bold.

#### ansi.cyan

Returns the string colored cyan with ANSI codes, then a reset; `bold` makes it bold.

#### ansi.dim

Returns the string at reduced intensity, for text that matters less.

It keeps the color the terminal writes in, so it reads on light and dark themes
alike, and a terminal that does not know the code shows the text as it is. Only
the intensity is set back afterwards, so a color around it stays on.

#### ansi.green

Returns the string colored green with ANSI codes, then a reset; `bold` makes it bold.

#### ansi.purple

Returns the string colored purple with ANSI codes, then a reset; `bold` makes it bold.

#### ansi.red

Returns the string colored red with ANSI codes, then a reset; `bold` makes it bold.

#### ansi.white

Returns the string colored white with ANSI codes, then a reset; `bold` makes it bold.

#### ansi.yellow

Returns the string colored yellow with ANSI codes, then a reset; `bold` makes it bold.

#### bytes

The number of bytes in the string, not counting the zero terminator.

#### clone

Returns a copy of the string in new storage; the `$clone` hook.

#### contains

Returns whether `part` occurs at or after byte offset `start_index`.

#### contains_byte

Returns whether `byte` occurs at or after byte offset `start_index`.

#### copy_from_ptr

Returns a new string holding a copy of the `length` bytes at `data`.

`data` must point to at least `length` readable bytes; nothing checks this.

#### data_cstring

The bytes as a zero-terminated C string, without copying.

The pointer is only valid while the string is alive. A string that contains a zero byte
looks shorter through it.

#### ends_with

Returns whether the string ends with the bytes of `part`; an empty `part` always matches.

#### equals

Returns whether both strings hold the same bytes; backs `==`.

#### equals_ignore_ascii_case

Returns whether both strings are equal when ASCII letters are compared case-insensitively.

Bytes outside ASCII, including non-ASCII letters, must match exactly.

#### escape

Returns a copy with special characters written as backslash escapes, as in a string literal.

Produces `\n`, `\r`, `\t`, `\f`, `\b`, `\v`, `\a`, `\e` (ESC), `\0`, `\\` and `\"`;
other control characters and DEL become `\xHH`. Bytes from 128 up (UTF-8) are copied
unchanged. `unescape` turns the result back into the original.

#### get

Returns the byte at byte offset `index`; backs `str[i]`.

An index at or past the end returns 0 instead of throwing or panicking.

#### gt

Returns whether the string sorts after `cmp` in byte order; backs `>`.

#### gte

Returns whether the string equals `cmp` or sorts after it in byte order; backs `>=`.

#### hash

Returns a hash of the bytes; the `$hash` hook that `HashMap` and `HashSet` keys use.

Strings shorter than 8 bytes hash every byte. Longer strings hash their length and the
first and last 8 bytes, plus 8 bytes from the middle past 16 bytes, so long keys that
differ only elsewhere share a hash.

#### hex_to_int

Parses the string as a hexadecimal signed integer: optional `-` or `+`, optional `0x`,
digits.

Digits and the `x` of the prefix may be upper or lower case. Throws `SyntaxError` for an
empty string, a lone sign, a prefix without digits (`"0x"`, `"-0x"`), an invalid digit
or a value outside the `int` range.

#### hex_to_uint

Parses the string as a hexadecimal unsigned integer: optional `+`, optional `0x`, digits.

Digits and the `x` of the prefix may be upper or lower case. Throws `SyntaxError` for an
empty string, a bare `0x`, any other byte (`-` included) or on overflow.

#### index_of

Returns the byte offset of the first occurrence of `part` at or after `start_index`.

Throws `LookupError` when there is none. An empty `part` returns `start_index` when it is
at most the byte length.

#### index_of_byte

Returns the byte offset of the first `byte` at or after `start_index`.

Throws `LookupError` when the byte does not occur there.

#### is_alpha

Returns whether every character is a Unicode letter or a byte in `allow_extra_bytes`.

Bytes that are not valid UTF-8 pass only when listed. An empty string returns true.

#### is_alpha_numeric

Returns whether every character is a Unicode letter, a number, or a byte in `allow_extra_bytes`.

Bytes that are not valid UTF-8 pass only when listed. An empty string returns true.

#### is_empty

Returns whether the string has no bytes.

#### is_integer

Returns whether the string is non-empty and holds only the digits `0`-`9`.

A sign is not accepted, and the value is not checked against any integer range.

#### is_lower

Returns whether no character in the string has a lower-case mapping.

A string without upper-case letters returns true, including an empty string and one
without any letters.

#### is_number

Returns whether the string holds only digits `0`-`9` and at most one `.`, with at least
one digit.

Signs and exponents are not accepted, so `"."` and `"-1"` return false.

#### is_syntax

Returns whether every byte is allowed by `mask`, or with `mask_is_exclude`, whether none is.

In `mask`, `a` stands for the letters `a`-`z`, `A` for `A`-`Z` and `0` for the digits
`0`-`9`; any other byte stands for itself. The check is per byte, so a non-ASCII
character only matches when all its bytes are in `mask`. An empty string returns true.

```valk
"user_name1".is_syntax("a0_") // true
"a b".is_syntax(" ", true)    // false
```

#### is_upper

Returns whether no character in the string has an upper-case mapping.

A string without lower-case letters returns true, including an empty string and one
without any letters.

#### lower

Returns the string with every character mapped to lower case by the Unicode case mappings.

Returns the same string, without copying, when nothing changes. The result can differ in
byte length; a capital sigma after a letter and not followed by one becomes the final
form `ς`. Bytes that are not valid UTF-8 are copied unchanged.

#### lt

Returns whether the string sorts before `cmp`; backs `<`.

Strings compare byte by byte as unsigned values, and a proper prefix sorts first. This
is not a locale-aware or Unicode collation.

#### lte

Returns whether the string equals `cmp` or sorts before it in byte order; backs `<=`.

#### ltrim

Removes whitespace, or repeated copies of `part`, from the start of the string.

`limit` caps how many bytes of whitespace or copies of `part` are removed; 0 removes all
of them. Returns the string unchanged when `part` is empty or nothing matches.

#### octal_to_int

Parses the string as an octal signed integer: optional `-` or `+`, optional `0c`, digits.

Throws `SyntaxError` for an empty string, a lone sign, a prefix without digits (`"0c"`,
`"-0c"`), an invalid digit or a value outside the `int` range.

#### octal_to_uint

Parses the string as an octal unsigned integer: optional `+`, optional `0c`, digits.

Throws `SyntaxError` for an empty string, a bare `0c`, a byte outside `0`-`7` after the
prefix (`-` included) or on overflow.

#### pad_left

Returns the string prefixed with the byte `char` until it is `length` bytes long.

A string already at least `length` bytes long is returned unchanged. Lengths count
bytes, not characters.

#### pad_right

Returns the string followed by the byte `char` until it is `length` bytes long.

A string already at least `length` bytes long is returned unchanged. Lengths count
bytes, not characters.

#### random

Returns `len` random bytes, each drawn uniformly from the bytes of `characters`.

Uses the operating system's secure entropy source with rejection sampling, so there is no
modulo bias. `characters` is used byte by byte, so it should contain only ASCII. Returns
an empty string when `characters` is empty. Panics when the operating system cannot
provide random bytes.

#### range

Returns a copy of `length` bytes from `start_index`; backs `str[start .. length]`.

The range is clamped to the string, and a `start_index` past the end returns an empty
string. Offsets count bytes, so the copy can cut a UTF-8 character in half.

#### reader

Returns a `ByteReader` that reads the string's bytes from the start without copying them.

#### replace

Returns a copy with every occurrence of `part` replaced by `with`.

Matches are found left to right and do not overlap. An empty `part` returns the string
unchanged.

#### rtrim

Removes whitespace, or repeated copies of `part`, from the end of the string.

`limit` caps how many bytes of whitespace or copies of `part` are removed; 0 removes all
of them. Returns the string unchanged when `part` is empty or nothing matches.

#### split

Splits the string on every occurrence of `on` and returns the parts, empty ones included.

With a non-empty `on` the result has at least one part. An empty `on` splits into single
bytes, which cuts UTF-8 characters apart (and gives no parts for an empty string);
`utf8.split` keeps characters whole.

#### starts_with

Returns whether the string begins with the bytes of `part`; an empty `part` always matches.

#### to_float

Parses the string as a decimal floating-point number.

Accepts an optional `-` or `+` sign, digits with at most one `.` (at least one digit is
required), and an optional `e`/`E` exponent with its own sign. The special values `nan`,
`inf` and `infinity` are accepted in any letter case, with an optional sign, as C's
`strtod` and Postgres spell them. Throws `SyntaxError` for other bytes, input without
mantissa digits such as `"."` or `"e5"`, more than 768 bytes, an exponent above 400, or
a numeric value that overflows to infinity.

#### to_int

Parses the string as a decimal signed integer with an optional `-` or `+` sign.

Throws `SyntaxError` for an empty string, any byte that is not a digit after the sign, or
a value outside the `int` range.

#### to_number

Parses the string as the number type `T`; the compiler lowers `"100".to(u8)` to this method.

Signed integers go through `to_int`, unsigned ones through `to_uint` and floats through
`to_float`. Throws `SyntaxError` when the text is not a number or an integer value is
outside the range of `T`. A float target is converted from `f64` without a range check.

#### to_string

Returns the string itself, without copying.

#### to_uint

Parses the string as a decimal unsigned integer, with an optional leading `+`.

Throws `SyntaxError` for an empty string, any byte other than the digits `0`-`9`
(whitespace included), or a value that does not fit in `uint`.

#### trim

Removes whitespace, or repeated copies of `part`, from both ends of the string.

Whitespace is what `u8.is_whitespace` says: spaces, tabs and line breaks. `limit` caps
how many bytes of whitespace or copies of `part` are removed from each end; 0 removes
all of them. Returns the string unchanged when `part` is empty or nothing matches.

```valk
"  hello \n".trim()   // "hello"
"--a--".trim("-")     // "a"
```

#### unescape

Returns a copy with backslash escapes turned back into the bytes they stand for.

Recognizes the escapes of a string literal: `\n`, `\r`, `\t`, `\f`, `\b`, `\v`, `\a`,
`\e`, `\0`, `\xHH`, `\\`, `\"`, `\'` and `\%`. Any other escape, `\u{...}` included,
and a trailing lone `\` are kept as they are.

#### upper

Returns the string with every character mapped to upper case by the Unicode case mappings.

Returns the same string, without copying, when nothing changes. The result can differ in
byte length (`ß` becomes `SS`). Bytes that are not valid UTF-8 are copied unchanged.

#### utf8.chars

Returns an iterator that yields each UTF-8 character as its own `String`, for `each`.

#### utf8.contains

Returns whether `part` occurs in the string starting on a character boundary.

#### utf8.get

Returns the character at character index `index` as a `String`, or `""` past the end.

#### utf8.index_of

Returns the character index of the first `part` at or after character `start_index`.

Only matches that start on a character boundary count. Throws `LookupError` when there
is none. The string is walked from the start, so the cost grows with the position.

#### utf8.length

The number of UTF-8 characters, counted by walking the string from the start.

Characters are delimited by their lead byte: a stray continuation byte or an
invalid lead byte counts as one character, and a sequence ends early at a byte that
cannot continue it.

#### utf8.range

Returns a copy of `length` characters starting at character index `start_index`.

The range is clamped to the string, and a start past the end returns an empty string.

#### utf8.split

Splits the string on every occurrence of `on` that starts on a character boundary.

Returns the whole string as the only part when `on` is empty or longer than the string.
Empty parts are included.

#### view

Returns a read-only view of `length` bytes from `start_index`, sharing the storage.

Backs `&str[start .. length]`, and `$auto` lets a `String` pass where a `&[u8]` is
expected. The range is clamped to the string, a `start_index` past the end gives an
empty view, and the view never includes the zero terminator.

```js
// An iterator over the UTF-8 characters of a string, returned by `str.utf8.chars()`.
+ struct StringChars {
}
```

### StringChars

An iterator over the UTF-8 characters of a string, returned by `str.utf8.chars()`.

`each str.utf8.chars() as ch` yields each character as its own `String`. Characters are
delimited by their lead byte; a stray continuation byte or an invalid lead byte is
yielded as a one-byte string, and a sequence ends early at a byte that cannot continue
it, so an invalid sequence never swallows the character after it.

```js
// A mutex backed by an OS mutex (pthread, or a Win32 mutex object on Windows).
+ class SyncMutex {
    // Takes the mutex, blocking the thread until it is free.
    + fn lock() void
    // Creates an unlocked mutex; panics when the OS cannot create one.
    + static fn new() SyncMutex
    // Releases the mutex; panics when the OS rejects the unlock.
    + fn unlock() void
}
```

### SyncMutex

A mutex backed by an OS mutex (pthread, or a Win32 mutex object on Windows).

Waiting blocks the whole thread, including its other coroutines; coroutine code should
use `Mutex` instead. On Windows the owning thread may lock it again (it is reentrant);
elsewhere locking it twice from one thread deadlocks.

#### lock

Takes the mutex, blocking the thread until it is free.

The GC lock is released while waiting, so other threads can collect. Panics when the
wait fails.

#### new

Creates an unlocked mutex; panics when the OS cannot create one.

Marked `$default`: it also provides `SyncMutex.$default_value`.

#### unlock

Releases the mutex; panics when the OS rejects the unlock.

```js
// A boolean value, `true` or `false`, stored in one byte.
+ class bool {
    // Returns `"true"` or `"false"`.
    + fn to_string() String
}
```

### bool

A boolean value, `true` or `false`, stored in one byte.

#### to_string

Returns `"true"` or `"false"`.

Tagged `$auto`, so a `bool` converts to `String` implicitly wherever one is expected.

```js
// A character: a `u8` that renders as the character instead of its decimal code.
+ mode char for u8 {
    // Returns a one-byte `String` holding this character.
    + fn to_string() String
}
```

### char

A character: a `u8` that renders as the character instead of its decimal code.

Same representation as `u8` and compatible with it in both directions, so it fits every byte
position. `"test" + '\n'` appends a newline instead of `10`, and `s.index_of('\n')` finds a
newline instead of the digits `10`. The `u8` methods (`is_hex`, `to_ascii_string`, ...)
remain available through the mode's member lookup fallthrough.

#### to_string

Returns a one-byte `String` holding this character.

Tagged `$auto`, so a `char` converts to `String` implicitly wherever one is expected.

```js
// A pointer to zero-terminated bytes with no stored length, as used by C APIs.
+ class cstring {
    // Returns the byte at `index`, or 0 at or past the zero terminator; backs `s[i]`.
    + fn get(index: uint) u8
    // Returns the index of the first `find` byte before the zero terminator.
    + fn index_of(find: u8) uint !LookupError
    // Returns the number of bytes before the zero terminator.
    + fn length() uint
    // Returns a new `String` holding a copy of the bytes before the zero terminator.
    + fn to_string() String
}
```

### cstring

A pointer to zero-terminated bytes with no stored length, as used by C APIs.

`$global` makes the name available in every namespace without a prefix.

#### get

Returns the byte at `index`, or 0 at or past the zero terminator; backs `s[i]`.

Each call scans from the start for the terminator, so it never reads out of bounds, and
reading index `i` costs O(i).

#### index_of

Returns the index of the first `find` byte before the zero terminator.

Throws `LookupError` when it does not occur; searching for 0 returns the length.

#### length

Returns the number of bytes before the zero terminator.

#### to_string

Returns a new `String` holding a copy of the bytes before the zero terminator.

`$auto` lets a `cstring` convert to `String` implicitly where one is expected.

```js
// A 32-bit IEEE 754 floating-point number.
+ class f32 {
    // Returns the absolute value. `-0.0` becomes `0.0` and NaN stays NaN.
    + fn abs() f32
    // Returns the value limited to the range `minimum` to `maximum`, both inclusive.
    + fn clamp(minimum: f32, maximum: f32) f32
    // Returns true when `str` parses as a float equal to this value.
    + fn equals_string(str: String) bool
    // Returns true when the value is neither infinite nor NaN.
    + fn is_finite() bool
    // Returns true when the value is positive or negative infinity.
    + fn is_infinite() bool
    // Returns true when the value is NaN.
    + fn is_nan() bool
    // Returns the larger of `this` and `other`; when one of them is NaN, returns the other.
    + fn max(other: f32) f32
    // Returns the smaller of `this` and `other`; when one of them is NaN, returns the other.
    + fn min(other: f32) f32
    // Returns the value in exponent form with `decimals` digits after the dot, e.g. `1.234567e6` for `1234567.0` and `1.234e-5` for `0.00001234`.
    + fn to_scientific_string(decimals: uint (6), trim_zeros: bool (false)) String
    // Writes the value like `to_scientific_string` into `buf` and returns the byte count.
    + fn to_scientific_string_in(buf: local mut &[u8], decimals: uint (6), trim_zeros: bool (false)) uint
    // Writes the value like `to_scientific_string` to `out` and returns the bytes written.
    + fn to_scientific_string_into(out: Writer, decimals: uint (6), trim_zeros: bool (false)) uint !io:IoError
    // Returns the shortest decimal text that parses back to the same value.
    + fn to_shortest_string() String
    // Writes the value like `to_shortest_string` into `buf` and returns the byte count.
    + fn to_shortest_string_in(buf: local mut &[u8], force_exponent: bool (false)) uint
    // Writes the value like `to_shortest_string` to `buf` and returns the byte count.
    + fn to_shortest_string_in_ptr(buf: ptr, force_exponent: bool (false)) uint $deprecated
    // Writes the value like `to_shortest_string` to `out` and returns the bytes written.
    + fn to_shortest_string_into(out: Writer, force_exponent: bool (false)) uint !io:IoError
    // Returns the value as text; with `decimals`, with exactly that many digits after the dot.
    + fn to_string(decimals: ?uint (null), trim_zeros: bool (false)) String
    // Writes the value like `to_string` into `buf` and returns the byte count.
    + fn to_string_in(buf: local mut &[u8], decimals: ?uint (null), trim_zeros: bool (false)) uint
    // Writes the value like `to_string` to `buf` and returns the byte count.
    + fn to_string_in_ptr(buf: ptr, decimals: uint (2), trim_zeros: bool (false)) uint $deprecated
    // Writes the value like `to_string` to `out` and returns the bytes written.
    + fn to_string_into(out: Writer, decimals: ?uint (null), trim_zeros: bool (false)) uint !io:IoError
}
```

### f32

A 32-bit IEEE 754 floating-point number.

#### abs

Returns the absolute value. `-0.0` becomes `0.0` and NaN stays NaN.

#### clamp

Returns the value limited to the range `minimum` to `maximum`, both inclusive.

Panics when `minimum` is greater than `maximum` or either bound is NaN. A NaN value is
returned unchanged.

#### equals_string

Returns true when `str` parses as a float equal to this value.

Parses with `String.to_float`; text that does not parse compares unequal, and NaN never
compares equal. Tagged `$eq`, so `1.5 == "1.5"` is true.

#### is_finite

Returns true when the value is neither infinite nor NaN.

#### is_infinite

Returns true when the value is positive or negative infinity.

#### is_nan

Returns true when the value is NaN.

#### max

Returns the larger of `this` and `other`; when one of them is NaN, returns the other.

#### min

Returns the smaller of `this` and `other`; when one of them is NaN, returns the other.

#### to_scientific_string

Returns the value in exponent form with `decimals` digits after the dot, e.g.
`1.234567e6` for `1234567.0` and `1.234e-5` for `0.00001234`.

The mantissa has one digit before the dot; the exponent is written as `to_shortest_string`
writes it, without a sign for positive values or padding. At most 19 decimals are written;
larger values are clamped to 19. With `trim_zeros`, trailing zeros are dropped, and the
dot too when nothing remains after it. Rounding follows `to_string`: an exact half rounds
to the even digit. Special values are `nan`, `inf` and `-inf`; zero is `0.000000e0`.

#### to_scientific_string_in

Writes the value like `to_scientific_string` into `buf` and returns the byte count.

`buf` must hold at least `FLOAT_TEXT_SIZE` (64) bytes; a shorter buffer panics. No
terminating zero is written.

#### to_scientific_string_into

Writes the value like `to_scientific_string` to `out` and returns the bytes written.

The text is built on the stack, so nothing is allocated. Throws when `out` fails.

#### to_shortest_string

Returns the shortest decimal text that parses back to the same value.

Values with a decimal exponent from -6 to 20 are written plainly (`100`, `0.1`,
`0.000001`); others use an exponent (`1e21`, `1.5e-7`). Special values are `nan`, `inf`,
`-inf` and `-0`. Tagged `$auto`, so a float converts to `String` implicitly wherever one
is expected.

#### to_shortest_string_in

Writes the value like `to_shortest_string` into `buf` and returns the byte count.

`buf` must hold at least `FLOAT_TEXT_SIZE` (64) bytes; a shorter buffer panics. With
`force_exponent` the exponent form is always used. No terminating zero is written.

#### to_shortest_string_in_ptr

Writes the value like `to_shortest_string` to `buf` and returns the byte count.

`buf` needs room for 32 bytes, unchecked. Deprecated: use `to_shortest_string_in`, which
takes a bounds-checked slice, or `to_shortest_string_into`. No terminating zero is
written. With `force_exponent` the exponent form is always used.

#### to_shortest_string_into

Writes the value like `to_shortest_string` to `out` and returns the bytes written.

The text is built on the stack, so nothing is allocated. With `force_exponent` the
exponent form is always used. Throws when `out` fails.

#### to_string

Returns the value as text; with `decimals`, with exactly that many digits after the dot.

Without `decimals` it is the shortest text that parses back to the same value, the
same as `to_shortest_string` and string interpolation: `3.14159`, `3`, `0.0001`. With
`decimals`, e.g. `(1.5).to_string(2)` is `1.50`; at most 19 decimals are written,
larger values are clamped to 19. With `trim_zeros`,
trailing zeros are dropped, and the dot too when nothing remains after it. An exact half
rounds to the even digit, as `printf` does in C, Go and Rust: `(2.5).to_string(0)` is
`2`, `(3.5).to_string(0)` is `4`; `math.round` rounds halves away from zero instead. NaN,
infinities and values of magnitude
2^63 or more fall back to `to_shortest_string` formatting. Negative zero keeps its sign.

#### to_string_in

Writes the value like `to_string` into `buf` and returns the byte count.

`buf` must hold at least `FLOAT_TEXT_SIZE` (64) bytes; a shorter buffer panics. Nothing
is allocated, so a stack array works: `let text: [u8 x 64] = @undefined` and
`value.to_string_in(&text, 3)`. No terminating zero is written.

#### to_string_in_ptr

Writes the value like `to_string` to `buf` and returns the byte count.

`buf` needs room for 64 bytes, unchecked. Deprecated: use `to_string_in`, which takes a
bounds-checked slice, or `to_string_into`. No terminating zero is written.

#### to_string_into

Writes the value like `to_string` to `out` and returns the bytes written.

The text is built on the stack, so nothing is allocated. Throws when `out` fails.

```js
// A 64-bit IEEE 754 floating-point number.
+ class f64 {
    // Returns the absolute value. `-0.0` becomes `0.0` and NaN stays NaN.
    + fn abs() f64
    // Returns the value limited to the range `minimum` to `maximum`, both inclusive.
    + fn clamp(minimum: f64, maximum: f64) f64
    // Returns true when `str` parses as a float equal to this value.
    + fn equals_string(str: String) bool
    // Returns true when the value is neither infinite nor NaN.
    + fn is_finite() bool
    // Returns true when the value is positive or negative infinity.
    + fn is_infinite() bool
    // Returns true when the value is NaN.
    + fn is_nan() bool
    // Returns the larger of `this` and `other`; when one of them is NaN, returns the other.
    + fn max(other: f64) f64
    // Returns the smaller of `this` and `other`; when one of them is NaN, returns the other.
    + fn min(other: f64) f64
    // Returns the value in exponent form with `decimals` digits after the dot, e.g. `1.234567e6` for `1234567.0` and `1.234e-5` for `0.00001234`.
    + fn to_scientific_string(decimals: uint (6), trim_zeros: bool (false)) String
    // Writes the value like `to_scientific_string` into `buf` and returns the byte count.
    + fn to_scientific_string_in(buf: local mut &[u8], decimals: uint (6), trim_zeros: bool (false)) uint
    // Writes the value like `to_scientific_string` to `out` and returns the bytes written.
    + fn to_scientific_string_into(out: Writer, decimals: uint (6), trim_zeros: bool (false)) uint !io:IoError
    // Returns the shortest decimal text that parses back to the same value.
    + fn to_shortest_string() String
    // Writes the value like `to_shortest_string` into `buf` and returns the byte count.
    + fn to_shortest_string_in(buf: local mut &[u8], force_exponent: bool (false)) uint
    // Writes the value like `to_shortest_string` to `buf` and returns the byte count.
    + fn to_shortest_string_in_ptr(buf: ptr, force_exponent: bool (false)) uint $deprecated
    // Writes the value like `to_shortest_string` to `out` and returns the bytes written.
    + fn to_shortest_string_into(out: Writer, force_exponent: bool (false)) uint !io:IoError
    // Returns the value as text; with `decimals`, with exactly that many digits after the dot.
    + fn to_string(decimals: ?uint (null), trim_zeros: bool (false)) String
    // Writes the value like `to_string` into `buf` and returns the byte count.
    + fn to_string_in(buf: local mut &[u8], decimals: ?uint (null), trim_zeros: bool (false)) uint
    // Writes the value like `to_string` to `buf` and returns the byte count.
    + fn to_string_in_ptr(buf: ptr, decimals: uint (2), trim_zeros: bool (false)) uint $deprecated
    // Writes the value like `to_string` to `out` and returns the bytes written.
    + fn to_string_into(out: Writer, decimals: ?uint (null), trim_zeros: bool (false)) uint !io:IoError
}
```

### f64

A 64-bit IEEE 754 floating-point number.

#### abs

Returns the absolute value. `-0.0` becomes `0.0` and NaN stays NaN.

#### clamp

Returns the value limited to the range `minimum` to `maximum`, both inclusive.

Panics when `minimum` is greater than `maximum` or either bound is NaN. A NaN value is
returned unchanged.

#### equals_string

Returns true when `str` parses as a float equal to this value.

Parses with `String.to_float`; text that does not parse compares unequal, and NaN never
compares equal. Tagged `$eq`, so `1.5 == "1.5"` is true.

#### is_finite

Returns true when the value is neither infinite nor NaN.

#### is_infinite

Returns true when the value is positive or negative infinity.

#### is_nan

Returns true when the value is NaN.

#### max

Returns the larger of `this` and `other`; when one of them is NaN, returns the other.

#### min

Returns the smaller of `this` and `other`; when one of them is NaN, returns the other.

#### to_scientific_string

Returns the value in exponent form with `decimals` digits after the dot, e.g.
`1.234567e6` for `1234567.0` and `1.234e-5` for `0.00001234`.

The mantissa has one digit before the dot; the exponent is written as `to_shortest_string`
writes it, without a sign for positive values or padding. At most 19 decimals are written;
larger values are clamped to 19. With `trim_zeros`, trailing zeros are dropped, and the
dot too when nothing remains after it. Rounding follows `to_string`: an exact half rounds
to the even digit. Special values are `nan`, `inf` and `-inf`; zero is `0.000000e0`.

#### to_scientific_string_in

Writes the value like `to_scientific_string` into `buf` and returns the byte count.

`buf` must hold at least `FLOAT_TEXT_SIZE` (64) bytes; a shorter buffer panics. No
terminating zero is written.

#### to_scientific_string_into

Writes the value like `to_scientific_string` to `out` and returns the bytes written.

The text is built on the stack, so nothing is allocated. Throws when `out` fails.

#### to_shortest_string

Returns the shortest decimal text that parses back to the same value.

Values with a decimal exponent from -6 to 20 are written plainly (`100`, `0.1`,
`0.000001`); others use an exponent (`1e21`, `1.5e-7`). Special values are `nan`, `inf`,
`-inf` and `-0`. Tagged `$auto`, so a float converts to `String` implicitly wherever one
is expected.

#### to_shortest_string_in

Writes the value like `to_shortest_string` into `buf` and returns the byte count.

`buf` must hold at least `FLOAT_TEXT_SIZE` (64) bytes; a shorter buffer panics. With
`force_exponent` the exponent form is always used. No terminating zero is written.

#### to_shortest_string_in_ptr

Writes the value like `to_shortest_string` to `buf` and returns the byte count.

`buf` needs room for 32 bytes, unchecked. Deprecated: use `to_shortest_string_in`, which
takes a bounds-checked slice, or `to_shortest_string_into`. No terminating zero is
written. With `force_exponent` the exponent form is always used.

#### to_shortest_string_into

Writes the value like `to_shortest_string` to `out` and returns the bytes written.

The text is built on the stack, so nothing is allocated. With `force_exponent` the
exponent form is always used. Throws when `out` fails.

#### to_string

Returns the value as text; with `decimals`, with exactly that many digits after the dot.

Without `decimals` it is the shortest text that parses back to the same value, the
same as `to_shortest_string` and string interpolation: `3.14159`, `3`, `0.0001`. With
`decimals`, e.g. `(1.5).to_string(2)` is `1.50`; at most 19 decimals are written,
larger values are clamped to 19. With `trim_zeros`,
trailing zeros are dropped, and the dot too when nothing remains after it. An exact half
rounds to the even digit, as `printf` does in C, Go and Rust: `(2.5).to_string(0)` is
`2`, `(3.5).to_string(0)` is `4`; `math.round` rounds halves away from zero instead. NaN,
infinities and values of magnitude
2^63 or more fall back to `to_shortest_string` formatting. Negative zero keeps its sign.

#### to_string_in

Writes the value like `to_string` into `buf` and returns the byte count.

`buf` must hold at least `FLOAT_TEXT_SIZE` (64) bytes; a shorter buffer panics. Nothing
is allocated, so a stack array works: `let text: [u8 x 64] = @undefined` and
`value.to_string_in(&text, 3)`. No terminating zero is written.

#### to_string_in_ptr

Writes the value like `to_string` to `buf` and returns the byte count.

`buf` needs room for 64 bytes, unchecked. Deprecated: use `to_string_in`, which takes a
bounds-checked slice, or `to_string_into`. No terminating zero is written.

#### to_string_into

Writes the value like `to_string` to `out` and returns the bytes written.

The text is built on the stack, so nothing is allocated. Throws when `out` fails.

```js
// A float as wide as a pointer: `f64` on 64-bit targets, `f32` on 32-bit ones.
+ class float {
    // Returns the absolute value. `-0.0` becomes `0.0` and NaN stays NaN.
    + fn abs() float
    // Returns the value limited to the range `minimum` to `maximum`, both inclusive.
    + fn clamp(minimum: float, maximum: float) float
    // Returns true when `str` parses as a float equal to this value.
    + fn equals_string(str: String) bool
    // Returns true when the value is neither infinite nor NaN.
    + fn is_finite() bool
    // Returns true when the value is positive or negative infinity.
    + fn is_infinite() bool
    // Returns true when the value is NaN.
    + fn is_nan() bool
    // Returns the larger of `this` and `other`; when one of them is NaN, returns the other.
    + fn max(other: float) float
    // Returns the smaller of `this` and `other`; when one of them is NaN, returns the other.
    + fn min(other: float) float
    // Returns the value in exponent form with `decimals` digits after the dot, e.g. `1.234567e6` for `1234567.0` and `1.234e-5` for `0.00001234`.
    + fn to_scientific_string(decimals: uint (6), trim_zeros: bool (false)) String
    // Writes the value like `to_scientific_string` into `buf` and returns the byte count.
    + fn to_scientific_string_in(buf: local mut &[u8], decimals: uint (6), trim_zeros: bool (false)) uint
    // Writes the value like `to_scientific_string` to `out` and returns the bytes written.
    + fn to_scientific_string_into(out: Writer, decimals: uint (6), trim_zeros: bool (false)) uint !io:IoError
    // Returns the shortest decimal text that parses back to the same value.
    + fn to_shortest_string() String
    // Writes the value like `to_shortest_string` into `buf` and returns the byte count.
    + fn to_shortest_string_in(buf: local mut &[u8], force_exponent: bool (false)) uint
    // Writes the value like `to_shortest_string` to `buf` and returns the byte count.
    + fn to_shortest_string_in_ptr(buf: ptr, force_exponent: bool (false)) uint $deprecated
    // Writes the value like `to_shortest_string` to `out` and returns the bytes written.
    + fn to_shortest_string_into(out: Writer, force_exponent: bool (false)) uint !io:IoError
    // Returns the value as text; with `decimals`, with exactly that many digits after the dot.
    + fn to_string(decimals: ?uint (null), trim_zeros: bool (false)) String
    // Writes the value like `to_string` into `buf` and returns the byte count.
    + fn to_string_in(buf: local mut &[u8], decimals: ?uint (null), trim_zeros: bool (false)) uint
    // Writes the value like `to_string` to `buf` and returns the byte count.
    + fn to_string_in_ptr(buf: ptr, decimals: uint (2), trim_zeros: bool (false)) uint $deprecated
    // Writes the value like `to_string` to `out` and returns the bytes written.
    + fn to_string_into(out: Writer, decimals: ?uint (null), trim_zeros: bool (false)) uint !io:IoError
}
```

### float

A float as wide as a pointer: `f64` on 64-bit targets, `f32` on 32-bit ones.

#### abs

Returns the absolute value. `-0.0` becomes `0.0` and NaN stays NaN.

#### clamp

Returns the value limited to the range `minimum` to `maximum`, both inclusive.

Panics when `minimum` is greater than `maximum` or either bound is NaN. A NaN value is
returned unchanged.

#### equals_string

Returns true when `str` parses as a float equal to this value.

Parses with `String.to_float`; text that does not parse compares unequal, and NaN never
compares equal. Tagged `$eq`, so `1.5 == "1.5"` is true.

#### is_finite

Returns true when the value is neither infinite nor NaN.

#### is_infinite

Returns true when the value is positive or negative infinity.

#### is_nan

Returns true when the value is NaN.

#### max

Returns the larger of `this` and `other`; when one of them is NaN, returns the other.

#### min

Returns the smaller of `this` and `other`; when one of them is NaN, returns the other.

#### to_scientific_string

Returns the value in exponent form with `decimals` digits after the dot, e.g.
`1.234567e6` for `1234567.0` and `1.234e-5` for `0.00001234`.

The mantissa has one digit before the dot; the exponent is written as `to_shortest_string`
writes it, without a sign for positive values or padding. At most 19 decimals are written;
larger values are clamped to 19. With `trim_zeros`, trailing zeros are dropped, and the
dot too when nothing remains after it. Rounding follows `to_string`: an exact half rounds
to the even digit. Special values are `nan`, `inf` and `-inf`; zero is `0.000000e0`.

#### to_scientific_string_in

Writes the value like `to_scientific_string` into `buf` and returns the byte count.

`buf` must hold at least `FLOAT_TEXT_SIZE` (64) bytes; a shorter buffer panics. No
terminating zero is written.

#### to_scientific_string_into

Writes the value like `to_scientific_string` to `out` and returns the bytes written.

The text is built on the stack, so nothing is allocated. Throws when `out` fails.

#### to_shortest_string

Returns the shortest decimal text that parses back to the same value.

Values with a decimal exponent from -6 to 20 are written plainly (`100`, `0.1`,
`0.000001`); others use an exponent (`1e21`, `1.5e-7`). Special values are `nan`, `inf`,
`-inf` and `-0`. Tagged `$auto`, so a float converts to `String` implicitly wherever one
is expected.

#### to_shortest_string_in

Writes the value like `to_shortest_string` into `buf` and returns the byte count.

`buf` must hold at least `FLOAT_TEXT_SIZE` (64) bytes; a shorter buffer panics. With
`force_exponent` the exponent form is always used. No terminating zero is written.

#### to_shortest_string_in_ptr

Writes the value like `to_shortest_string` to `buf` and returns the byte count.

`buf` needs room for 32 bytes, unchecked. Deprecated: use `to_shortest_string_in`, which
takes a bounds-checked slice, or `to_shortest_string_into`. No terminating zero is
written. With `force_exponent` the exponent form is always used.

#### to_shortest_string_into

Writes the value like `to_shortest_string` to `out` and returns the bytes written.

The text is built on the stack, so nothing is allocated. With `force_exponent` the
exponent form is always used. Throws when `out` fails.

#### to_string

Returns the value as text; with `decimals`, with exactly that many digits after the dot.

Without `decimals` it is the shortest text that parses back to the same value, the
same as `to_shortest_string` and string interpolation: `3.14159`, `3`, `0.0001`. With
`decimals`, e.g. `(1.5).to_string(2)` is `1.50`; at most 19 decimals are written,
larger values are clamped to 19. With `trim_zeros`,
trailing zeros are dropped, and the dot too when nothing remains after it. An exact half
rounds to the even digit, as `printf` does in C, Go and Rust: `(2.5).to_string(0)` is
`2`, `(3.5).to_string(0)` is `4`; `math.round` rounds halves away from zero instead. NaN,
infinities and values of magnitude
2^63 or more fall back to `to_shortest_string` formatting. Negative zero keeps its sign.

#### to_string_in

Writes the value like `to_string` into `buf` and returns the byte count.

`buf` must hold at least `FLOAT_TEXT_SIZE` (64) bytes; a shorter buffer panics. Nothing
is allocated, so a stack array works: `let text: [u8 x 64] = @undefined` and
`value.to_string_in(&text, 3)`. No terminating zero is written.

#### to_string_in_ptr

Writes the value like `to_string` to `buf` and returns the byte count.

`buf` needs room for 64 bytes, unchecked. Deprecated: use `to_string_in`, which takes a
bounds-checked slice, or `to_string_into`. No terminating zero is written.

#### to_string_into

Writes the value like `to_string` to `out` and returns the bytes written.

The text is built on the stack, so nothing is allocated. Throws when `out` fails.

```js
// A 16-bit signed integer.
+ class i16 {
    // Returns the absolute value. Unsigned values are returned unchanged.
    + fn abs() i16
    // Returns how many bytes `to_base_to_ptr` writes for this value in `base`, sign included.
    + fn character_length(base: i16) uint
    // Returns the value limited to the range `minimum` to `maximum`, both inclusive.
    + fn clamp(minimum: i16, maximum: i16) i16
    // Returns how many bits are one.
    + fn count_ones() uint
    // Returns true when `str` parses as an integer equal to this value.
    + fn equals_string(str: String) bool
    // Returns how many zero bits come before the highest one bit; the bit width for 0.
    + fn leading_zeros() uint
    // Returns the larger of `this` and `other`.
    + fn max(other: i16) i16
    // Returns the smaller of `this` and `other`.
    + fn min(other: i16) i16
    // Writes the value as text in `base` to stdout, without a newline.
    + fn print(base: i16) void
    // Returns a random value from the operating system's secure entropy source.
    + static fn random() i16
    // Reads a value from the first `size_of(SELF)` bytes of `from`, most significant first. Panics when `from` is shorter.
    + static fn read_big_endian(from: local &[u8]) i16
    // Reads a value from the first `size_of(SELF)` bytes of `from`, least significant first. Panics when `from` is shorter.
    + static fn read_little_endian(from: local &[u8]) i16
    // Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_down(modulo: i16) i16
    // Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_up(modulo: i16) i16
    // Returns the value as text in `base` (2 to 36), with a leading `-` when negative.
    + fn to_base(base: i16) String
    // Writes the value as text in `base` into `buf` and returns the byte count.
    + fn to_base_in(buf: local mut &[u8], base: i16, lowercase: bool (false)) uint
    // Writes the value as text in `base` to `out` and returns the bytes written.
    + fn to_base_into(base: i16, out: Writer, lowercase: bool (false)) uint !io:IoError
    // Writes the value as text in `base` to `result` and returns the byte count.
    + fn to_base_to_ptr(base: i16, result: ptr, lowercase: bool (false)) uint $deprecated
    // Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.
    + fn to_hex() String
    // Returns the value in decimal, with a leading `-` when negative.
    + fn to_string() String
    // Returns how many zero bits come after the lowest one bit; the bit width for 0.
    + fn trailing_zeros() uint
    // Writes `v` to the first `size_of(SELF)` bytes of `to`, most significant first. Panics when `to` is shorter.
    + static fn write_big_endian(v: i16, to: local mut &[u8]) void
    // Writes `v` to the first `size_of(SELF)` bytes of `to`, least significant first. Panics when `to` is shorter.
    + static fn write_little_endian(v: i16, to: local mut &[u8]) void
}
```

### i16

A 16-bit signed integer.

#### abs

Returns the absolute value. Unsigned values are returned unchanged.

Panics for the minimum value of a signed type (e.g. `i8.$min`), whose absolute value
does not fit.

#### character_length

Returns how many bytes `to_base_to_ptr` writes for this value in `base`, sign included.

`base` is clamped the same way as in `to_base_to_ptr`.

#### clamp

Returns the value limited to the range `minimum` to `maximum`, both inclusive.

Panics when `minimum` is greater than `maximum`.

#### count_ones

Returns how many bits are one.

#### equals_string

Returns true when `str` parses as an integer equal to this value.

Parses with `String.to_int` (`String.to_uint` for unsigned types); text that does not
parse compares unequal. Tagged `$eq`, so `5 == "5"` is true.

#### leading_zeros

Returns how many zero bits come before the highest one bit; the bit width for 0.

Compiles to one instruction on current CPUs.

#### max

Returns the larger of `this` and `other`.

#### min

Returns the smaller of `this` and `other`.

#### print

Writes the value as text in `base` to stdout, without a newline.

The write is unbuffered and write errors are ignored. Digits above 9 are uppercase. A
`base` above 36 is treated as 36 and one below 2 as 10.

#### random

Returns a random value from the operating system's secure entropy source.

Every value of the type is equally likely. Panics when the operating system cannot
provide random bytes.

#### read_big_endian

Reads a value from the first `size_of(SELF)` bytes of `from`, most significant first.
Panics when `from` is shorter.

#### read_little_endian

Reads a value from the first `size_of(SELF)` bytes of `from`, least significant first.
Panics when `from` is shorter.

```valk
let bytes = Array[u8]{ 0xFF, 0x04, 0x03, 0x02, 0x01 }
let v = u32.read_little_endian(&bytes[1 .. 4]) // 0x01020304
```

#### round_down

Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned
unchanged.

`(5).round_down(4)` is 4 and `(-5).round_down(4)` is -8. The sign of `modulo` does not
matter. Panics when `modulo` is 0 or the rounded value does not fit in the type, e.g.
`i8.$min.round_down(3)`.

#### round_up

Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned
unchanged.

`(5).round_up(4)` is 8 and `(-5).round_up(4)` is -4. The sign of `modulo` does not
matter. Panics when `modulo` is 0 or the rounded value does not fit in the type, e.g.
`u8.$max.round_up(4)`.

#### to_base

Returns the value as text in `base` (2 to 36), with a leading `-` when negative.

Digits above 9 are uppercase letters. A `base` above 36 is treated as 36 and one below 2
as 10.

#### to_base_in

Writes the value as text in `base` into `buf` and returns the byte count.

`buf` must hold at least `INT_TEXT_SIZE` (65) bytes; a shorter buffer panics. Nothing is
allocated. Digits above 9 are lowercase when `lowercase` is true, uppercase otherwise;
`base` is clamped as in `to_base`. No terminating zero is written.

#### to_base_into

Writes the value as text in `base` to `out` and returns the bytes written.

The text is built on the stack, so nothing is allocated. Digits above 9 are lowercase
when `lowercase` is true, uppercase otherwise; `base` is clamped as in `to_base`.
Throws when `out` fails.

#### to_base_to_ptr

Writes the value as text in `base` to `result` and returns the byte count.

Digits above 9 are lowercase when `lowercase` is true, uppercase otherwise. A `base`
above 36 is treated as 36 and one below 2 as 10. Writes at most 65 bytes (a sign plus 64
binary digits) and no terminating zero. Deprecated: unchecked; use `to_base_in`, which
takes a bounds-checked slice, or `to_base_into`.

#### to_hex

Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.

#### to_string

Returns the value in decimal, with a leading `-` when negative.

Tagged `$auto`, so an integer converts to `String` implicitly wherever one is expected.

#### trailing_zeros

Returns how many zero bits come after the lowest one bit; the bit width for 0.

#### write_big_endian

Writes `v` to the first `size_of(SELF)` bytes of `to`, most significant first.
Panics when `to` is shorter.

#### write_little_endian

Writes `v` to the first `size_of(SELF)` bytes of `to`, least significant first.
Panics when `to` is shorter.

```valk
let buf: [u8 x 4] = @undefined
u32.write_little_endian(0x01020304, &buf)
```

```js
// A 32-bit signed integer.
+ class i32 {
    // Returns the absolute value. Unsigned values are returned unchanged.
    + fn abs() i32
    // Returns how many bytes `to_base_to_ptr` writes for this value in `base`, sign included.
    + fn character_length(base: i32) uint
    // Returns the value limited to the range `minimum` to `maximum`, both inclusive.
    + fn clamp(minimum: i32, maximum: i32) i32
    // Returns how many bits are one.
    + fn count_ones() uint
    // Returns true when `str` parses as an integer equal to this value.
    + fn equals_string(str: String) bool
    // Returns how many zero bits come before the highest one bit; the bit width for 0.
    + fn leading_zeros() uint
    // Returns the larger of `this` and `other`.
    + fn max(other: i32) i32
    // Returns the smaller of `this` and `other`.
    + fn min(other: i32) i32
    // Writes the value as text in `base` to stdout, without a newline.
    + fn print(base: i32) void
    // Returns a random value from the operating system's secure entropy source.
    + static fn random() i32
    // Reads a value from the first `size_of(SELF)` bytes of `from`, most significant first. Panics when `from` is shorter.
    + static fn read_big_endian(from: local &[u8]) i32
    // Reads a value from the first `size_of(SELF)` bytes of `from`, least significant first. Panics when `from` is shorter.
    + static fn read_little_endian(from: local &[u8]) i32
    // Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_down(modulo: i32) i32
    // Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_up(modulo: i32) i32
    // Returns the value as text in `base` (2 to 36), with a leading `-` when negative.
    + fn to_base(base: i32) String
    // Writes the value as text in `base` into `buf` and returns the byte count.
    + fn to_base_in(buf: local mut &[u8], base: i32, lowercase: bool (false)) uint
    // Writes the value as text in `base` to `out` and returns the bytes written.
    + fn to_base_into(base: i32, out: Writer, lowercase: bool (false)) uint !io:IoError
    // Writes the value as text in `base` to `result` and returns the byte count.
    + fn to_base_to_ptr(base: i32, result: ptr, lowercase: bool (false)) uint $deprecated
    // Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.
    + fn to_hex() String
    // Returns the value in decimal, with a leading `-` when negative.
    + fn to_string() String
    // Returns how many zero bits come after the lowest one bit; the bit width for 0.
    + fn trailing_zeros() uint
    // Writes `v` to the first `size_of(SELF)` bytes of `to`, most significant first. Panics when `to` is shorter.
    + static fn write_big_endian(v: i32, to: local mut &[u8]) void
    // Writes `v` to the first `size_of(SELF)` bytes of `to`, least significant first. Panics when `to` is shorter.
    + static fn write_little_endian(v: i32, to: local mut &[u8]) void
}
```

### i32

A 32-bit signed integer.

#### abs

Returns the absolute value. Unsigned values are returned unchanged.

Panics for the minimum value of a signed type (e.g. `i8.$min`), whose absolute value
does not fit.

#### character_length

Returns how many bytes `to_base_to_ptr` writes for this value in `base`, sign included.

`base` is clamped the same way as in `to_base_to_ptr`.

#### clamp

Returns the value limited to the range `minimum` to `maximum`, both inclusive.

Panics when `minimum` is greater than `maximum`.

#### count_ones

Returns how many bits are one.

#### equals_string

Returns true when `str` parses as an integer equal to this value.

Parses with `String.to_int` (`String.to_uint` for unsigned types); text that does not
parse compares unequal. Tagged `$eq`, so `5 == "5"` is true.

#### leading_zeros

Returns how many zero bits come before the highest one bit; the bit width for 0.

Compiles to one instruction on current CPUs.

#### max

Returns the larger of `this` and `other`.

#### min

Returns the smaller of `this` and `other`.

#### print

Writes the value as text in `base` to stdout, without a newline.

The write is unbuffered and write errors are ignored. Digits above 9 are uppercase. A
`base` above 36 is treated as 36 and one below 2 as 10.

#### random

Returns a random value from the operating system's secure entropy source.

Every value of the type is equally likely. Panics when the operating system cannot
provide random bytes.

#### read_big_endian

Reads a value from the first `size_of(SELF)` bytes of `from`, most significant first.
Panics when `from` is shorter.

#### read_little_endian

Reads a value from the first `size_of(SELF)` bytes of `from`, least significant first.
Panics when `from` is shorter.

```valk
let bytes = Array[u8]{ 0xFF, 0x04, 0x03, 0x02, 0x01 }
let v = u32.read_little_endian(&bytes[1 .. 4]) // 0x01020304
```

#### round_down

Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned
unchanged.

`(5).round_down(4)` is 4 and `(-5).round_down(4)` is -8. The sign of `modulo` does not
matter. Panics when `modulo` is 0 or the rounded value does not fit in the type, e.g.
`i8.$min.round_down(3)`.

#### round_up

Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned
unchanged.

`(5).round_up(4)` is 8 and `(-5).round_up(4)` is -4. The sign of `modulo` does not
matter. Panics when `modulo` is 0 or the rounded value does not fit in the type, e.g.
`u8.$max.round_up(4)`.

#### to_base

Returns the value as text in `base` (2 to 36), with a leading `-` when negative.

Digits above 9 are uppercase letters. A `base` above 36 is treated as 36 and one below 2
as 10.

#### to_base_in

Writes the value as text in `base` into `buf` and returns the byte count.

`buf` must hold at least `INT_TEXT_SIZE` (65) bytes; a shorter buffer panics. Nothing is
allocated. Digits above 9 are lowercase when `lowercase` is true, uppercase otherwise;
`base` is clamped as in `to_base`. No terminating zero is written.

#### to_base_into

Writes the value as text in `base` to `out` and returns the bytes written.

The text is built on the stack, so nothing is allocated. Digits above 9 are lowercase
when `lowercase` is true, uppercase otherwise; `base` is clamped as in `to_base`.
Throws when `out` fails.

#### to_base_to_ptr

Writes the value as text in `base` to `result` and returns the byte count.

Digits above 9 are lowercase when `lowercase` is true, uppercase otherwise. A `base`
above 36 is treated as 36 and one below 2 as 10. Writes at most 65 bytes (a sign plus 64
binary digits) and no terminating zero. Deprecated: unchecked; use `to_base_in`, which
takes a bounds-checked slice, or `to_base_into`.

#### to_hex

Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.

#### to_string

Returns the value in decimal, with a leading `-` when negative.

Tagged `$auto`, so an integer converts to `String` implicitly wherever one is expected.

#### trailing_zeros

Returns how many zero bits come after the lowest one bit; the bit width for 0.

#### write_big_endian

Writes `v` to the first `size_of(SELF)` bytes of `to`, most significant first.
Panics when `to` is shorter.

#### write_little_endian

Writes `v` to the first `size_of(SELF)` bytes of `to`, least significant first.
Panics when `to` is shorter.

```valk
let buf: [u8 x 4] = @undefined
u32.write_little_endian(0x01020304, &buf)
```

```js
// A 64-bit signed integer.
+ class i64 {
    // Returns the absolute value. Unsigned values are returned unchanged.
    + fn abs() i64
    // Returns how many bytes `to_base_to_ptr` writes for this value in `base`, sign included.
    + fn character_length(base: i64) uint
    // Returns the value limited to the range `minimum` to `maximum`, both inclusive.
    + fn clamp(minimum: i64, maximum: i64) i64
    // Returns how many bits are one.
    + fn count_ones() uint
    // Returns true when `str` parses as an integer equal to this value.
    + fn equals_string(str: String) bool
    // Returns how many zero bits come before the highest one bit; the bit width for 0.
    + fn leading_zeros() uint
    // Returns the larger of `this` and `other`.
    + fn max(other: i64) i64
    // Returns the smaller of `this` and `other`.
    + fn min(other: i64) i64
    // Writes the value as text in `base` to stdout, without a newline.
    + fn print(base: i64) void
    // Returns a random value from the operating system's secure entropy source.
    + static fn random() i64
    // Reads a value from the first `size_of(SELF)` bytes of `from`, most significant first. Panics when `from` is shorter.
    + static fn read_big_endian(from: local &[u8]) i64
    // Reads a value from the first `size_of(SELF)` bytes of `from`, least significant first. Panics when `from` is shorter.
    + static fn read_little_endian(from: local &[u8]) i64
    // Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_down(modulo: i64) i64
    // Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_up(modulo: i64) i64
    // Returns the value as text in `base` (2 to 36), with a leading `-` when negative.
    + fn to_base(base: i64) String
    // Writes the value as text in `base` into `buf` and returns the byte count.
    + fn to_base_in(buf: local mut &[u8], base: i64, lowercase: bool (false)) uint
    // Writes the value as text in `base` to `out` and returns the bytes written.
    + fn to_base_into(base: i64, out: Writer, lowercase: bool (false)) uint !io:IoError
    // Writes the value as text in `base` to `result` and returns the byte count.
    + fn to_base_to_ptr(base: i64, result: ptr, lowercase: bool (false)) uint $deprecated
    // Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.
    + fn to_hex() String
    // Returns the value in decimal, with a leading `-` when negative.
    + fn to_string() String
    // Returns how many zero bits come after the lowest one bit; the bit width for 0.
    + fn trailing_zeros() uint
    // Writes `v` to the first `size_of(SELF)` bytes of `to`, most significant first. Panics when `to` is shorter.
    + static fn write_big_endian(v: i64, to: local mut &[u8]) void
    // Writes `v` to the first `size_of(SELF)` bytes of `to`, least significant first. Panics when `to` is shorter.
    + static fn write_little_endian(v: i64, to: local mut &[u8]) void
}
```

### i64

A 64-bit signed integer.

#### abs

Returns the absolute value. Unsigned values are returned unchanged.

Panics for the minimum value of a signed type (e.g. `i8.$min`), whose absolute value
does not fit.

#### character_length

Returns how many bytes `to_base_to_ptr` writes for this value in `base`, sign included.

`base` is clamped the same way as in `to_base_to_ptr`.

#### clamp

Returns the value limited to the range `minimum` to `maximum`, both inclusive.

Panics when `minimum` is greater than `maximum`.

#### count_ones

Returns how many bits are one.

#### equals_string

Returns true when `str` parses as an integer equal to this value.

Parses with `String.to_int` (`String.to_uint` for unsigned types); text that does not
parse compares unequal. Tagged `$eq`, so `5 == "5"` is true.

#### leading_zeros

Returns how many zero bits come before the highest one bit; the bit width for 0.

Compiles to one instruction on current CPUs.

#### max

Returns the larger of `this` and `other`.

#### min

Returns the smaller of `this` and `other`.

#### print

Writes the value as text in `base` to stdout, without a newline.

The write is unbuffered and write errors are ignored. Digits above 9 are uppercase. A
`base` above 36 is treated as 36 and one below 2 as 10.

#### random

Returns a random value from the operating system's secure entropy source.

Every value of the type is equally likely. Panics when the operating system cannot
provide random bytes.

#### read_big_endian

Reads a value from the first `size_of(SELF)` bytes of `from`, most significant first.
Panics when `from` is shorter.

#### read_little_endian

Reads a value from the first `size_of(SELF)` bytes of `from`, least significant first.
Panics when `from` is shorter.

```valk
let bytes = Array[u8]{ 0xFF, 0x04, 0x03, 0x02, 0x01 }
let v = u32.read_little_endian(&bytes[1 .. 4]) // 0x01020304
```

#### round_down

Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned
unchanged.

`(5).round_down(4)` is 4 and `(-5).round_down(4)` is -8. The sign of `modulo` does not
matter. Panics when `modulo` is 0 or the rounded value does not fit in the type, e.g.
`i8.$min.round_down(3)`.

#### round_up

Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned
unchanged.

`(5).round_up(4)` is 8 and `(-5).round_up(4)` is -4. The sign of `modulo` does not
matter. Panics when `modulo` is 0 or the rounded value does not fit in the type, e.g.
`u8.$max.round_up(4)`.

#### to_base

Returns the value as text in `base` (2 to 36), with a leading `-` when negative.

Digits above 9 are uppercase letters. A `base` above 36 is treated as 36 and one below 2
as 10.

#### to_base_in

Writes the value as text in `base` into `buf` and returns the byte count.

`buf` must hold at least `INT_TEXT_SIZE` (65) bytes; a shorter buffer panics. Nothing is
allocated. Digits above 9 are lowercase when `lowercase` is true, uppercase otherwise;
`base` is clamped as in `to_base`. No terminating zero is written.

#### to_base_into

Writes the value as text in `base` to `out` and returns the bytes written.

The text is built on the stack, so nothing is allocated. Digits above 9 are lowercase
when `lowercase` is true, uppercase otherwise; `base` is clamped as in `to_base`.
Throws when `out` fails.

#### to_base_to_ptr

Writes the value as text in `base` to `result` and returns the byte count.

Digits above 9 are lowercase when `lowercase` is true, uppercase otherwise. A `base`
above 36 is treated as 36 and one below 2 as 10. Writes at most 65 bytes (a sign plus 64
binary digits) and no terminating zero. Deprecated: unchecked; use `to_base_in`, which
takes a bounds-checked slice, or `to_base_into`.

#### to_hex

Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.

#### to_string

Returns the value in decimal, with a leading `-` when negative.

Tagged `$auto`, so an integer converts to `String` implicitly wherever one is expected.

#### trailing_zeros

Returns how many zero bits come after the lowest one bit; the bit width for 0.

#### write_big_endian

Writes `v` to the first `size_of(SELF)` bytes of `to`, most significant first.
Panics when `to` is shorter.

#### write_little_endian

Writes `v` to the first `size_of(SELF)` bytes of `to`, least significant first.
Panics when `to` is shorter.

```valk
let buf: [u8 x 4] = @undefined
u32.write_little_endian(0x01020304, &buf)
```

```js
// An 8-bit signed integer.
+ class i8 {
    // Returns the absolute value. Unsigned values are returned unchanged.
    + fn abs() i8
    // Returns how many bytes `to_base_to_ptr` writes for this value in `base`, sign included.
    + fn character_length(base: i8) uint
    // Returns the value limited to the range `minimum` to `maximum`, both inclusive.
    + fn clamp(minimum: i8, maximum: i8) i8
    // Returns how many bits are one.
    + fn count_ones() uint
    // Returns true when `str` parses as an integer equal to this value.
    + fn equals_string(str: String) bool
    // Returns how many zero bits come before the highest one bit; the bit width for 0.
    + fn leading_zeros() uint
    // Returns the larger of `this` and `other`.
    + fn max(other: i8) i8
    // Returns the smaller of `this` and `other`.
    + fn min(other: i8) i8
    // Writes the value as text in `base` to stdout, without a newline.
    + fn print(base: i8) void
    // Returns a random value from the operating system's secure entropy source.
    + static fn random() i8
    // Reads a value from the first `size_of(SELF)` bytes of `from`, most significant first. Panics when `from` is shorter.
    + static fn read_big_endian(from: local &[u8]) i8
    // Reads a value from the first `size_of(SELF)` bytes of `from`, least significant first. Panics when `from` is shorter.
    + static fn read_little_endian(from: local &[u8]) i8
    // Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_down(modulo: i8) i8
    // Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_up(modulo: i8) i8
    // Returns the value as text in `base` (2 to 36), with a leading `-` when negative.
    + fn to_base(base: i8) String
    // Writes the value as text in `base` into `buf` and returns the byte count.
    + fn to_base_in(buf: local mut &[u8], base: i8, lowercase: bool (false)) uint
    // Writes the value as text in `base` to `out` and returns the bytes written.
    + fn to_base_into(base: i8, out: Writer, lowercase: bool (false)) uint !io:IoError
    // Writes the value as text in `base` to `result` and returns the byte count.
    + fn to_base_to_ptr(base: i8, result: ptr, lowercase: bool (false)) uint $deprecated
    // Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.
    + fn to_hex() String
    // Returns the value in decimal, with a leading `-` when negative.
    + fn to_string() String
    // Returns how many zero bits come after the lowest one bit; the bit width for 0.
    + fn trailing_zeros() uint
    // Writes `v` to the first `size_of(SELF)` bytes of `to`, most significant first. Panics when `to` is shorter.
    + static fn write_big_endian(v: i8, to: local mut &[u8]) void
    // Writes `v` to the first `size_of(SELF)` bytes of `to`, least significant first. Panics when `to` is shorter.
    + static fn write_little_endian(v: i8, to: local mut &[u8]) void
}
```

### i8

An 8-bit signed integer.

#### abs

Returns the absolute value. Unsigned values are returned unchanged.

Panics for the minimum value of a signed type (e.g. `i8.$min`), whose absolute value
does not fit.

#### character_length

Returns how many bytes `to_base_to_ptr` writes for this value in `base`, sign included.

`base` is clamped the same way as in `to_base_to_ptr`.

#### clamp

Returns the value limited to the range `minimum` to `maximum`, both inclusive.

Panics when `minimum` is greater than `maximum`.

#### count_ones

Returns how many bits are one.

#### equals_string

Returns true when `str` parses as an integer equal to this value.

Parses with `String.to_int` (`String.to_uint` for unsigned types); text that does not
parse compares unequal. Tagged `$eq`, so `5 == "5"` is true.

#### leading_zeros

Returns how many zero bits come before the highest one bit; the bit width for 0.

Compiles to one instruction on current CPUs.

#### max

Returns the larger of `this` and `other`.

#### min

Returns the smaller of `this` and `other`.

#### print

Writes the value as text in `base` to stdout, without a newline.

The write is unbuffered and write errors are ignored. Digits above 9 are uppercase. A
`base` above 36 is treated as 36 and one below 2 as 10.

#### random

Returns a random value from the operating system's secure entropy source.

Every value of the type is equally likely. Panics when the operating system cannot
provide random bytes.

#### read_big_endian

Reads a value from the first `size_of(SELF)` bytes of `from`, most significant first.
Panics when `from` is shorter.

#### read_little_endian

Reads a value from the first `size_of(SELF)` bytes of `from`, least significant first.
Panics when `from` is shorter.

```valk
let bytes = Array[u8]{ 0xFF, 0x04, 0x03, 0x02, 0x01 }
let v = u32.read_little_endian(&bytes[1 .. 4]) // 0x01020304
```

#### round_down

Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned
unchanged.

`(5).round_down(4)` is 4 and `(-5).round_down(4)` is -8. The sign of `modulo` does not
matter. Panics when `modulo` is 0 or the rounded value does not fit in the type, e.g.
`i8.$min.round_down(3)`.

#### round_up

Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned
unchanged.

`(5).round_up(4)` is 8 and `(-5).round_up(4)` is -4. The sign of `modulo` does not
matter. Panics when `modulo` is 0 or the rounded value does not fit in the type, e.g.
`u8.$max.round_up(4)`.

#### to_base

Returns the value as text in `base` (2 to 36), with a leading `-` when negative.

Digits above 9 are uppercase letters. A `base` above 36 is treated as 36 and one below 2
as 10.

#### to_base_in

Writes the value as text in `base` into `buf` and returns the byte count.

`buf` must hold at least `INT_TEXT_SIZE` (65) bytes; a shorter buffer panics. Nothing is
allocated. Digits above 9 are lowercase when `lowercase` is true, uppercase otherwise;
`base` is clamped as in `to_base`. No terminating zero is written.

#### to_base_into

Writes the value as text in `base` to `out` and returns the bytes written.

The text is built on the stack, so nothing is allocated. Digits above 9 are lowercase
when `lowercase` is true, uppercase otherwise; `base` is clamped as in `to_base`.
Throws when `out` fails.

#### to_base_to_ptr

Writes the value as text in `base` to `result` and returns the byte count.

Digits above 9 are lowercase when `lowercase` is true, uppercase otherwise. A `base`
above 36 is treated as 36 and one below 2 as 10. Writes at most 65 bytes (a sign plus 64
binary digits) and no terminating zero. Deprecated: unchecked; use `to_base_in`, which
takes a bounds-checked slice, or `to_base_into`.

#### to_hex

Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.

#### to_string

Returns the value in decimal, with a leading `-` when negative.

Tagged `$auto`, so an integer converts to `String` implicitly wherever one is expected.

#### trailing_zeros

Returns how many zero bits come after the lowest one bit; the bit width for 0.

#### write_big_endian

Writes `v` to the first `size_of(SELF)` bytes of `to`, most significant first.
Panics when `to` is shorter.

#### write_little_endian

Writes `v` to the first `size_of(SELF)` bytes of `to`, least significant first.
Panics when `to` is shorter.

```valk
let buf: [u8 x 4] = @undefined
u32.write_little_endian(0x01020304, &buf)
```

```js
// A signed integer as wide as a pointer: 64 bits on 64-bit targets, 32 on 32-bit ones.
+ class int {
    // Returns the absolute value. Unsigned values are returned unchanged.
    + fn abs() int
    // Returns how many bytes `to_base_to_ptr` writes for this value in `base`, sign included.
    + fn character_length(base: int) uint
    // Returns the value limited to the range `minimum` to `maximum`, both inclusive.
    + fn clamp(minimum: int, maximum: int) int
    // Returns how many bits are one.
    + fn count_ones() uint
    // Returns true when `str` parses as an integer equal to this value.
    + fn equals_string(str: String) bool
    // Returns how many zero bits come before the highest one bit; the bit width for 0.
    + fn leading_zeros() uint
    // Returns the larger of `this` and `other`.
    + fn max(other: int) int
    // Returns the smaller of `this` and `other`.
    + fn min(other: int) int
    // Writes the value as text in `base` to stdout, without a newline.
    + fn print(base: int) void
    // Returns a random value from the operating system's secure entropy source.
    + static fn random() int
    // Reads a value from the first `size_of(SELF)` bytes of `from`, most significant first. Panics when `from` is shorter.
    + static fn read_big_endian(from: local &[u8]) int
    // Reads a value from the first `size_of(SELF)` bytes of `from`, least significant first. Panics when `from` is shorter.
    + static fn read_little_endian(from: local &[u8]) int
    // Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_down(modulo: int) int
    // Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_up(modulo: int) int
    // Returns the value as text in `base` (2 to 36), with a leading `-` when negative.
    + fn to_base(base: int) String
    // Writes the value as text in `base` into `buf` and returns the byte count.
    + fn to_base_in(buf: local mut &[u8], base: int, lowercase: bool (false)) uint
    // Writes the value as text in `base` to `out` and returns the bytes written.
    + fn to_base_into(base: int, out: Writer, lowercase: bool (false)) uint !io:IoError
    // Writes the value as text in `base` to `result` and returns the byte count.
    + fn to_base_to_ptr(base: int, result: ptr, lowercase: bool (false)) uint $deprecated
    // Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.
    + fn to_hex() String
    // Returns the value in decimal, with a leading `-` when negative.
    + fn to_string() String
    // Returns how many zero bits come after the lowest one bit; the bit width for 0.
    + fn trailing_zeros() uint
    // Writes `v` to the first `size_of(SELF)` bytes of `to`, most significant first. Panics when `to` is shorter.
    + static fn write_big_endian(v: int, to: local mut &[u8]) void
    // Writes `v` to the first `size_of(SELF)` bytes of `to`, least significant first. Panics when `to` is shorter.
    + static fn write_little_endian(v: int, to: local mut &[u8]) void
}
```

### int

A signed integer as wide as a pointer: 64 bits on 64-bit targets, 32 on 32-bit ones.

#### abs

Returns the absolute value. Unsigned values are returned unchanged.

Panics for the minimum value of a signed type (e.g. `i8.$min`), whose absolute value
does not fit.

#### character_length

Returns how many bytes `to_base_to_ptr` writes for this value in `base`, sign included.

`base` is clamped the same way as in `to_base_to_ptr`.

#### clamp

Returns the value limited to the range `minimum` to `maximum`, both inclusive.

Panics when `minimum` is greater than `maximum`.

#### count_ones

Returns how many bits are one.

#### equals_string

Returns true when `str` parses as an integer equal to this value.

Parses with `String.to_int` (`String.to_uint` for unsigned types); text that does not
parse compares unequal. Tagged `$eq`, so `5 == "5"` is true.

#### leading_zeros

Returns how many zero bits come before the highest one bit; the bit width for 0.

Compiles to one instruction on current CPUs.

#### max

Returns the larger of `this` and `other`.

#### min

Returns the smaller of `this` and `other`.

#### print

Writes the value as text in `base` to stdout, without a newline.

The write is unbuffered and write errors are ignored. Digits above 9 are uppercase. A
`base` above 36 is treated as 36 and one below 2 as 10.

#### random

Returns a random value from the operating system's secure entropy source.

Every value of the type is equally likely. Panics when the operating system cannot
provide random bytes.

#### read_big_endian

Reads a value from the first `size_of(SELF)` bytes of `from`, most significant first.
Panics when `from` is shorter.

#### read_little_endian

Reads a value from the first `size_of(SELF)` bytes of `from`, least significant first.
Panics when `from` is shorter.

```valk
let bytes = Array[u8]{ 0xFF, 0x04, 0x03, 0x02, 0x01 }
let v = u32.read_little_endian(&bytes[1 .. 4]) // 0x01020304
```

#### round_down

Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned
unchanged.

`(5).round_down(4)` is 4 and `(-5).round_down(4)` is -8. The sign of `modulo` does not
matter. Panics when `modulo` is 0 or the rounded value does not fit in the type, e.g.
`i8.$min.round_down(3)`.

#### round_up

Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned
unchanged.

`(5).round_up(4)` is 8 and `(-5).round_up(4)` is -4. The sign of `modulo` does not
matter. Panics when `modulo` is 0 or the rounded value does not fit in the type, e.g.
`u8.$max.round_up(4)`.

#### to_base

Returns the value as text in `base` (2 to 36), with a leading `-` when negative.

Digits above 9 are uppercase letters. A `base` above 36 is treated as 36 and one below 2
as 10.

#### to_base_in

Writes the value as text in `base` into `buf` and returns the byte count.

`buf` must hold at least `INT_TEXT_SIZE` (65) bytes; a shorter buffer panics. Nothing is
allocated. Digits above 9 are lowercase when `lowercase` is true, uppercase otherwise;
`base` is clamped as in `to_base`. No terminating zero is written.

#### to_base_into

Writes the value as text in `base` to `out` and returns the bytes written.

The text is built on the stack, so nothing is allocated. Digits above 9 are lowercase
when `lowercase` is true, uppercase otherwise; `base` is clamped as in `to_base`.
Throws when `out` fails.

#### to_base_to_ptr

Writes the value as text in `base` to `result` and returns the byte count.

Digits above 9 are lowercase when `lowercase` is true, uppercase otherwise. A `base`
above 36 is treated as 36 and one below 2 as 10. Writes at most 65 bytes (a sign plus 64
binary digits) and no terminating zero. Deprecated: unchecked; use `to_base_in`, which
takes a bounds-checked slice, or `to_base_into`.

#### to_hex

Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.

#### to_string

Returns the value in decimal, with a leading `-` when negative.

Tagged `$auto`, so an integer converts to `String` implicitly wherever one is expected.

#### trailing_zeros

Returns how many zero bits come after the lowest one bit; the bit width for 0.

#### write_big_endian

Writes `v` to the first `size_of(SELF)` bytes of `to`, most significant first.
Panics when `to` is shorter.

#### write_little_endian

Writes `v` to the first `size_of(SELF)` bytes of `to`, least significant first.
Panics when `to` is shorter.

```valk
let buf: [u8 x 4] = @undefined
u32.write_little_endian(0x01020304, &buf)
```

```js
// A raw, untyped memory address. Reading and writing through it is unchecked.
+ class ptr {
    // Sets `amount` bytes starting at this address to zero.
    + fn clear_bytes(amount: uint) void
    // Returns a new `String` holding a copy of the first `length` bytes.
    + fn create_string(length: uint) String
    // Returns the length of the float text at this address, up to `max_bytes`.
    + fn determine_float_length(max_bytes: uint) uint
    // Returns the length of an optional `-` or `+` sign, `0x`/`0X` prefix and hex digits, up to `max_bytes`.
    + fn determine_hex_int_length(max_bytes: uint) uint
    // Returns the length of an optional `+` sign, `0x`/`0X` prefix and hex digits, up to `max_bytes`.
    + fn determine_hex_uint_length(max_bytes: uint) uint
    // Returns the length of an optional `-` or `+` sign and decimal digits, up to `max_bytes`.
    + fn determine_int_length(max_bytes: uint) uint
    // Returns the length of an optional `-` or `+` sign, `0c` prefix and octal digits, up to `max_bytes`.
    + fn determine_octal_int_length(max_bytes: uint) uint
    // Returns the length of an optional `+` sign, `0c` prefix and octal digits, up to `max_bytes`.
    + fn determine_octal_uint_length(max_bytes: uint) uint
    // Returns the length of an optional `+` and decimal digits, up to `max_bytes`.
    + fn determine_uint_length(max_bytes: uint) uint
    // Returns true when the first `len` bytes here equal the first `len` bytes at `data`.
    + fn equals(data: ptr, len: uint) bool
    // Returns true when the bytes at this address start with the bytes of `str`.
    + fn equals_string(str: String) bool
    // Sets `amount` bytes starting at this address to `byte`.
    + fn fill_bytes(byte: u8, amount: uint) void
    // Returns the offset of the first `byte` within the first `memory_size` bytes.
    + fn index_of_byte(byte: u8, memory_size: uint) uint !LookupError
    // Returns the offset of the first `byte`, scanning without any length limit.
    + fn index_of_byte_inf(byte: u8) uint
    // Prints the first `length` bytes to stdout as a comma-separated list like `0x01,0xAB`.
    + fn print_bytes(length: uint, end_with_newline: bool (true)) void
    // Reads a `bytes`-long big-endian unsigned integer from this address.
    + fn read_big_endian(bytes: uint) uint
    // Returns the byte at this address.
    + fn read_byte() u8
    // Returns a copy of the zero-terminated string at this address, without the zero byte.
    + fn read_cstring(memory_size: uint) String
    // Returns a copy of the zero-terminated string at this address, without the zero byte.
    + fn read_cstring_inf() String
    // Parses the first `len` bytes as a decimal floating-point number, e.g. `-12.5e-3`.
    + fn read_float(len: uint) float !SyntaxError
    // Parses a float like `read_float`, stopping at the first byte not part of it.
    + fn read_float_dynamic(max_bytes: uint) (float, uint)
    // Parses the first `len` bytes as a hexadecimal `int`: an optional `-` or `+` sign, an optional `0x` or `0X` prefix, then hex digits.
    + fn read_hex_int(len: uint) int !SyntaxError
    // Parses a hex `int` like `read_hex_int`, stopping at the first byte not part of it.
    + fn read_hex_int_dynamic(max_bytes: uint) (int, uint)
    // Parses the first `len` bytes as a hexadecimal `uint`: an optional `+` sign, an optional `0x` or `0X` prefix, then hex digits.
    + fn read_hex_uint(len: uint) uint !SyntaxError
    // Parses a hex `uint` like `read_hex_uint`, stopping at the first byte not part of it.
    + fn read_hex_uint_dynamic(max_bytes: uint) (uint, uint)
    // Parses the first `len` bytes as a decimal `int` with an optional `-` or `+` sign.
    + fn read_int(len: uint) int !SyntaxError
    // Parses a decimal `int` like `read_int`, stopping at the first byte not part of it.
    + fn read_int_dynamic(max_bytes: uint) (int, uint)
    // Reads a `bytes`-long little-endian unsigned integer from this address.
    + fn read_little_endian(bytes: uint) uint
    // Parses the first `len` bytes as an octal `int`: an optional `-` or `+` sign, an optional `0c` prefix, then octal digits.
    + fn read_octal_int(len: uint) int !SyntaxError
    // Parses an octal `int` like `read_octal_int`, stopping at the first byte not part of it.
    + fn read_octal_int_dynamic(max_bytes: uint) (int, uint)
    // Parses the first `len` bytes as an octal `uint`: an optional `+` sign, an optional `0c` prefix, then octal digits.
    + fn read_octal_uint(len: uint) uint !SyntaxError
    // Parses an octal `uint` like `read_octal_uint`, stopping at the first byte not part of it.
    + fn read_octal_uint_dynamic(max_bytes: uint) (uint, uint)
    // Returns a new `String` holding a copy of the first `len` bytes.
    + fn read_string(len: uint) String
    // Reads a big-endian `u16` from this address.
    + fn read_u16_be() u16
    // Reads a little-endian `u16` from this address.
    + fn read_u16_le() u16
    // Reads a big-endian `u32` from this address.
    + fn read_u32_be() u32
    // Reads a little-endian `u32` from this address.
    + fn read_u32_le() u32
    // Reads a big-endian `u64` from this address.
    + fn read_u64_be() u64
    // Reads a little-endian `u64` from this address.
    + fn read_u64_le() u64
    // Parses the first `len` bytes as a decimal `uint` with an optional `+` sign.
    + fn read_uint(len: uint) uint !SyntaxError
    // Reads a big-endian `uint` (`size_of(uint)` bytes) from this address.
    + fn read_uint_be() uint
    // Parses a decimal `uint` like `read_uint`, stopping at the first byte not part of it.
    + fn read_uint_dynamic(max_bytes: uint) (uint, uint)
    // Reads a little-endian `uint` (`size_of(uint)` bytes) from this address.
    + fn read_uint_le() uint
    // Returns the address as uppercase hexadecimal digits, without a `0x` prefix.
    + fn to_hex() String
    // Copies the bytes of `data` to this address.
    + fn write(data: local &[u8]) void
    // Writes the low `bytes` bytes of `value` to this address, most significant first.
    + fn write_big_endian(value: uint, bytes: uint) void
    // Copies `len` bytes from `from` to this address.
    + fn write_bytes(from: ptr, len: uint) void
    // Copies the bytes of `str` here, plus its zero byte when `include_zero_byte` is true.
    + fn write_cstring(str: cstring, include_zero_byte: bool (true)) void
    // Writes `v` as text in `base` (2 to 16) to this address and returns the byte count.
    + fn write_int_ascii(v: int, base: u8 (10), lowercase: bool (false)) uint
    // Writes the low `bytes` bytes of `value` to this address, least significant first.
    + fn write_little_endian(value: uint, bytes: uint) void
    // Writes `v` as 2 big-endian bytes to this address.
    + fn write_u16_be(v: u16) void
    // Writes `v` as 2 little-endian bytes to this address.
    + fn write_u16_le(v: u16) void
    // Writes `v` as 4 big-endian bytes to this address.
    + fn write_u32_be(v: u32) void
    // Writes `v` as 4 little-endian bytes to this address.
    + fn write_u32_le(v: u32) void
    // Writes `v` as 8 big-endian bytes to this address.
    + fn write_u64_be(v: u64) void
    // Writes `v` as 8 little-endian bytes to this address.
    + fn write_u64_le(v: u64) void
    // Stores the byte `v` at this address.
    + fn write_u8(v: u8) void
    // Writes `v` as text in `base` (2 to 16) to this address and returns the byte count.
    + fn write_uint_ascii(v: uint, base: u8 (10), lowercase: bool (false)) uint
    // Writes `v` as `size_of(uint)` big-endian bytes to this address.
    + fn write_uint_be(v: uint) void
    // Writes `v` as `size_of(uint)` little-endian bytes to this address.
    + fn write_uint_le(v: uint) void
}
```

### ptr

A raw, untyped memory address. Reading and writing through it is unchecked.

Converts implicitly to `uint`. The byte read/write methods come from `PointerRead` and
`PointerWrite`.

#### clear_bytes

Sets `amount` bytes starting at this address to zero.

#### create_string

Returns a new `String` holding a copy of the first `length` bytes.

#### determine_float_length

Returns the length of the float text at this address, up to `max_bytes`.

Covers an optional `-` or `+` sign, digits with at most one `.`, and an `e`/`E` exponent
with an optional sign. The exponent is only included when a mantissa digit precedes it
and a digit follows it, so `2em` gives 1. The span is not validated; `read_float` does
that.

#### determine_hex_int_length

Returns the length of an optional `-` or `+` sign, `0x`/`0X` prefix and hex digits, up
to `max_bytes`.

#### determine_hex_uint_length

Returns the length of an optional `+` sign, `0x`/`0X` prefix and hex digits, up to
`max_bytes`.

#### determine_int_length

Returns the length of an optional `-` or `+` sign and decimal digits, up to `max_bytes`.

#### determine_octal_int_length

Returns the length of an optional `-` or `+` sign, `0c` prefix and octal digits, up to
`max_bytes`.

#### determine_octal_uint_length

Returns the length of an optional `+` sign, `0c` prefix and octal digits, up to
`max_bytes`.

#### determine_uint_length

Returns the length of an optional `+` and decimal digits, up to `max_bytes`.

#### equals

Returns true when the first `len` bytes here equal the first `len` bytes at `data`.

#### equals_string

Returns true when the bytes at this address start with the bytes of `str`.

#### fill_bytes

Sets `amount` bytes starting at this address to `byte`.

#### index_of_byte

Returns the offset of the first `byte` within the first `memory_size` bytes.

Throws `missing` when `byte` does not occur in that range.

#### index_of_byte_inf

Returns the offset of the first `byte`, scanning without any length limit.

Reads past the end of the memory when `byte` never occurs; use `index_of_byte` when the
size is known.

#### print_bytes

Prints the first `length` bytes to stdout as a comma-separated list like `0x01,0xAB`.

Each byte is two uppercase hex digits. A newline follows unless `end_with_newline` is
false.

#### read_big_endian

Reads a `bytes`-long big-endian unsigned integer from this address.

`bytes` must not exceed `size_of(uint)`.

#### read_byte

Returns the byte at this address.

#### read_cstring

Returns a copy of the zero-terminated string at this address, without the zero byte.

Only the first `memory_size` bytes are searched for the terminator; when none is found,
the result holds all `memory_size` bytes.

#### read_cstring_inf

Returns a copy of the zero-terminated string at this address, without the zero byte.

Scans without a length limit, so the memory must contain a zero byte.

#### read_float

Parses the first `len` bytes as a decimal floating-point number, e.g. `-12.5e-3`.

Accepts an optional `-` or `+` sign, digits with at most one `.` (at least one digit is
required), and an optional `e`/`E` exponent with its own sign, or the special values
`nan`, `inf` and `infinity` in any letter case after the sign. The result is the nearest
`float` to the decimal value. Throws `syntax` on any other byte, on input without
mantissa digits (`""`, `"-"`, `"."`, `"e5"`), on an exponent without digits, on an
exponent above 400, on a value that overflows to infinity, and when `len` exceeds 768.

#### read_float_dynamic

Parses a float like `read_float`, stopping at the first byte not part of it.

Returns the value and the number of bytes it used, or `(0, 0)` when the text does not
parse. An `e` without exponent digits is not part of the number, so `2em` reads 2 and
uses 1 byte. Reads at most `max_bytes` bytes.

#### read_hex_int

Parses the first `len` bytes as a hexadecimal `int`: an optional `-` or `+` sign, an
optional `0x` or `0X` prefix, then hex digits.

Digits may be upper- or lowercase. Throws `syntax` when there are no digits (`""`,
`"-"`, `"0x"`, `"-0x"`), on any other byte, and when the value does not fit in an `int`.

#### read_hex_int_dynamic

Parses a hex `int` like `read_hex_int`, stopping at the first byte not part of it.

Returns the value and the number of bytes it used, or `(0, 0)` when the text does not
parse (including overflow and a `0x` prefix without digits). Reads at most `max_bytes`
bytes.

#### read_hex_uint

Parses the first `len` bytes as a hexadecimal `uint`: an optional `+` sign, an optional
`0x` or `0X` prefix, then hex digits.

Digits may be upper- or lowercase. Throws `syntax` when there are no digits (`""`,
`"0x"`), on any other byte (including `-`), and when the value does not fit in a `uint`.

#### read_hex_uint_dynamic

Parses a hex `uint` like `read_hex_uint`, stopping at the first byte not part of it.

Returns the value and the number of bytes it used, or `(0, 0)` when the text does not
parse (including overflow and a `0x` prefix without digits). Reads at most `max_bytes`
bytes.

#### read_int

Parses the first `len` bytes as a decimal `int` with an optional `-` or `+` sign.

Throws `syntax` when there are no digits, on any other byte (a second sign included),
and when the value does not fit in an `int`.

#### read_int_dynamic

Parses a decimal `int` like `read_int`, stopping at the first byte not part of it.

Returns the value and the number of bytes it used, or `(0, 0)` when the text does not
parse (including overflow). Reads at most `max_bytes` bytes.

#### read_little_endian

Reads a `bytes`-long little-endian unsigned integer from this address.

`bytes` must not exceed `size_of(uint)`.

#### read_octal_int

Parses the first `len` bytes as an octal `int`: an optional `-` or `+` sign, an optional
`0c` prefix, then octal digits.

Throws `syntax` when there are no digits (`""`, `"-"`, `"0c"`, `"-0c"`), on any other
byte, and when the value does not fit in an `int`.

#### read_octal_int_dynamic

Parses an octal `int` like `read_octal_int`, stopping at the first byte not part of it.

Returns the value and the number of bytes it used, or `(0, 0)` when the text does not
parse (including overflow and a `0c` prefix without digits). Reads at most `max_bytes`
bytes.

#### read_octal_uint

Parses the first `len` bytes as an octal `uint`: an optional `+` sign, an optional `0c`
prefix, then octal digits.

Throws `syntax` when there are no digits (`""`, `"0c"`), on any other byte (including
`-`), and when the value does not fit in a `uint`.

#### read_octal_uint_dynamic

Parses an octal `uint` like `read_octal_uint`, stopping at the first byte not part of
it.

Returns the value and the number of bytes it used, or `(0, 0)` when the text does not
parse (including overflow and a `0c` prefix without digits). Reads at most `max_bytes`
bytes.

#### read_string

Returns a new `String` holding a copy of the first `len` bytes.

#### read_u16_be

Reads a big-endian `u16` from this address.

#### read_u16_le

Reads a little-endian `u16` from this address.

#### read_u32_be

Reads a big-endian `u32` from this address.

#### read_u32_le

Reads a little-endian `u32` from this address.

#### read_u64_be

Reads a big-endian `u64` from this address.

#### read_u64_le

Reads a little-endian `u64` from this address.

#### read_uint

Parses the first `len` bytes as a decimal `uint` with an optional `+` sign.

Throws `syntax` when there are no digits, on any other byte (including `-` and a second
sign), and when the value does not fit in a `uint`.

#### read_uint_be

Reads a big-endian `uint` (`size_of(uint)` bytes) from this address.

#### read_uint_dynamic

Parses a decimal `uint` like `read_uint`, stopping at the first byte not part of it.

Returns the value and the number of bytes it used, or `(0, 0)` when the text does not
parse (including overflow). Reads at most `max_bytes` bytes.

#### read_uint_le

Reads a little-endian `uint` (`size_of(uint)` bytes) from this address.

#### to_hex

Returns the address as uppercase hexadecimal digits, without a `0x` prefix.

Tagged `$auto`, so a `ptr` converts to `String` implicitly wherever one is expected.

#### write

Copies the bytes of `data` to this address.

#### write_big_endian

Writes the low `bytes` bytes of `value` to this address, most significant first.

#### write_bytes

Copies `len` bytes from `from` to this address.

#### write_cstring

Copies the bytes of `str` here, plus its zero byte when `include_zero_byte` is true.

#### write_int_ascii

Writes `v` as text in `base` (2 to 16) to this address and returns the byte count.

Negative values get a leading `-`. A `base` above 16 is treated as 16 and one below 2 as
10. Writes at most 65 bytes and no terminating zero.

#### write_little_endian

Writes the low `bytes` bytes of `value` to this address, least significant first.

#### write_u16_be

Writes `v` as 2 big-endian bytes to this address.

#### write_u16_le

Writes `v` as 2 little-endian bytes to this address.

#### write_u32_be

Writes `v` as 4 big-endian bytes to this address.

#### write_u32_le

Writes `v` as 4 little-endian bytes to this address.

#### write_u64_be

Writes `v` as 8 big-endian bytes to this address.

#### write_u64_le

Writes `v` as 8 little-endian bytes to this address.

#### write_u8

Stores the byte `v` at this address.

#### write_uint_ascii

Writes `v` as text in `base` (2 to 16) to this address and returns the byte count.

A `base` above 16 is treated as 16 and one below 2 as 10. Writes at most 64 bytes and no
terminating zero.

#### write_uint_be

Writes `v` as `size_of(uint)` big-endian bytes to this address.

#### write_uint_le

Writes `v` as `size_of(uint)` little-endian bytes to this address.

```js
// A 16-bit unsigned integer.
+ class u16 {
    // Returns the absolute value. Unsigned values are returned unchanged.
    + fn abs() u16
    // Returns how many bytes `to_base_to_ptr` writes for this value in `base`, sign included.
    + fn character_length(base: u16) uint
    // Returns the value limited to the range `minimum` to `maximum`, both inclusive.
    + fn clamp(minimum: u16, maximum: u16) u16
    // Returns how many bits are one.
    + fn count_ones() uint
    // Returns true when `str` parses as an integer equal to this value.
    + fn equals_string(str: String) bool
    // Returns how many zero bits come before the highest one bit; the bit width for 0.
    + fn leading_zeros() uint
    // Returns the larger of `this` and `other`.
    + fn max(other: u16) u16
    // Returns the smaller of `this` and `other`.
    + fn min(other: u16) u16
    // Writes the value as text in `base` to stdout, without a newline.
    + fn print(base: u16) void
    // Returns a random value from the operating system's secure entropy source.
    + static fn random() u16
    // Reads a value from the first `size_of(SELF)` bytes of `from`, most significant first. Panics when `from` is shorter.
    + static fn read_big_endian(from: local &[u8]) u16
    // Reads a value from the first `size_of(SELF)` bytes of `from`, least significant first. Panics when `from` is shorter.
    + static fn read_little_endian(from: local &[u8]) u16
    // Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_down(modulo: u16) u16
    // Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_up(modulo: u16) u16
    // Returns the value as text in `base` (2 to 36), with a leading `-` when negative.
    + fn to_base(base: u16) String
    // Writes the value as text in `base` into `buf` and returns the byte count.
    + fn to_base_in(buf: local mut &[u8], base: u16, lowercase: bool (false)) uint
    // Writes the value as text in `base` to `out` and returns the bytes written.
    + fn to_base_into(base: u16, out: Writer, lowercase: bool (false)) uint !io:IoError
    // Writes the value as text in `base` to `result` and returns the byte count.
    + fn to_base_to_ptr(base: u16, result: ptr, lowercase: bool (false)) uint $deprecated
    // Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.
    + fn to_hex() String
    // Returns the value in decimal, with a leading `-` when negative.
    + fn to_string() String
    // Returns how many zero bits come after the lowest one bit; the bit width for 0.
    + fn trailing_zeros() uint
    // Writes `v` to the first `size_of(SELF)` bytes of `to`, most significant first. Panics when `to` is shorter.
    + static fn write_big_endian(v: u16, to: local mut &[u8]) void
    // Writes `v` to the first `size_of(SELF)` bytes of `to`, least significant first. Panics when `to` is shorter.
    + static fn write_little_endian(v: u16, to: local mut &[u8]) void
}
```

### u16

A 16-bit unsigned integer.

#### abs

Returns the absolute value. Unsigned values are returned unchanged.

Panics for the minimum value of a signed type (e.g. `i8.$min`), whose absolute value
does not fit.

#### character_length

Returns how many bytes `to_base_to_ptr` writes for this value in `base`, sign included.

`base` is clamped the same way as in `to_base_to_ptr`.

#### clamp

Returns the value limited to the range `minimum` to `maximum`, both inclusive.

Panics when `minimum` is greater than `maximum`.

#### count_ones

Returns how many bits are one.

#### equals_string

Returns true when `str` parses as an integer equal to this value.

Parses with `String.to_int` (`String.to_uint` for unsigned types); text that does not
parse compares unequal. Tagged `$eq`, so `5 == "5"` is true.

#### leading_zeros

Returns how many zero bits come before the highest one bit; the bit width for 0.

Compiles to one instruction on current CPUs.

#### max

Returns the larger of `this` and `other`.

#### min

Returns the smaller of `this` and `other`.

#### print

Writes the value as text in `base` to stdout, without a newline.

The write is unbuffered and write errors are ignored. Digits above 9 are uppercase. A
`base` above 36 is treated as 36 and one below 2 as 10.

#### random

Returns a random value from the operating system's secure entropy source.

Every value of the type is equally likely. Panics when the operating system cannot
provide random bytes.

#### read_big_endian

Reads a value from the first `size_of(SELF)` bytes of `from`, most significant first.
Panics when `from` is shorter.

#### read_little_endian

Reads a value from the first `size_of(SELF)` bytes of `from`, least significant first.
Panics when `from` is shorter.

```valk
let bytes = Array[u8]{ 0xFF, 0x04, 0x03, 0x02, 0x01 }
let v = u32.read_little_endian(&bytes[1 .. 4]) // 0x01020304
```

#### round_down

Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned
unchanged.

`(5).round_down(4)` is 4 and `(-5).round_down(4)` is -8. The sign of `modulo` does not
matter. Panics when `modulo` is 0 or the rounded value does not fit in the type, e.g.
`i8.$min.round_down(3)`.

#### round_up

Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned
unchanged.

`(5).round_up(4)` is 8 and `(-5).round_up(4)` is -4. The sign of `modulo` does not
matter. Panics when `modulo` is 0 or the rounded value does not fit in the type, e.g.
`u8.$max.round_up(4)`.

#### to_base

Returns the value as text in `base` (2 to 36), with a leading `-` when negative.

Digits above 9 are uppercase letters. A `base` above 36 is treated as 36 and one below 2
as 10.

#### to_base_in

Writes the value as text in `base` into `buf` and returns the byte count.

`buf` must hold at least `INT_TEXT_SIZE` (65) bytes; a shorter buffer panics. Nothing is
allocated. Digits above 9 are lowercase when `lowercase` is true, uppercase otherwise;
`base` is clamped as in `to_base`. No terminating zero is written.

#### to_base_into

Writes the value as text in `base` to `out` and returns the bytes written.

The text is built on the stack, so nothing is allocated. Digits above 9 are lowercase
when `lowercase` is true, uppercase otherwise; `base` is clamped as in `to_base`.
Throws when `out` fails.

#### to_base_to_ptr

Writes the value as text in `base` to `result` and returns the byte count.

Digits above 9 are lowercase when `lowercase` is true, uppercase otherwise. A `base`
above 36 is treated as 36 and one below 2 as 10. Writes at most 65 bytes (a sign plus 64
binary digits) and no terminating zero. Deprecated: unchecked; use `to_base_in`, which
takes a bounds-checked slice, or `to_base_into`.

#### to_hex

Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.

#### to_string

Returns the value in decimal, with a leading `-` when negative.

Tagged `$auto`, so an integer converts to `String` implicitly wherever one is expected.

#### trailing_zeros

Returns how many zero bits come after the lowest one bit; the bit width for 0.

#### write_big_endian

Writes `v` to the first `size_of(SELF)` bytes of `to`, most significant first.
Panics when `to` is shorter.

#### write_little_endian

Writes `v` to the first `size_of(SELF)` bytes of `to`, least significant first.
Panics when `to` is shorter.

```valk
let buf: [u8 x 4] = @undefined
u32.write_little_endian(0x01020304, &buf)
```

```js
// A 32-bit unsigned integer.
+ class u32 {
    // Returns the absolute value. Unsigned values are returned unchanged.
    + fn abs() u32
    // Returns how many bytes `to_base_to_ptr` writes for this value in `base`, sign included.
    + fn character_length(base: u32) uint
    // Returns the value limited to the range `minimum` to `maximum`, both inclusive.
    + fn clamp(minimum: u32, maximum: u32) u32
    // Returns how many bits are one.
    + fn count_ones() uint
    // Returns true when `str` parses as an integer equal to this value.
    + fn equals_string(str: String) bool
    // Returns how many zero bits come before the highest one bit; the bit width for 0.
    + fn leading_zeros() uint
    // Returns the larger of `this` and `other`.
    + fn max(other: u32) u32
    // Returns the smaller of `this` and `other`.
    + fn min(other: u32) u32
    // Writes the value as text in `base` to stdout, without a newline.
    + fn print(base: u32) void
    // Returns a random value from the operating system's secure entropy source.
    + static fn random() u32
    // Reads a value from the first `size_of(SELF)` bytes of `from`, most significant first. Panics when `from` is shorter.
    + static fn read_big_endian(from: local &[u8]) u32
    // Reads a value from the first `size_of(SELF)` bytes of `from`, least significant first. Panics when `from` is shorter.
    + static fn read_little_endian(from: local &[u8]) u32
    // Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_down(modulo: u32) u32
    // Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_up(modulo: u32) u32
    // Returns the value as text in `base` (2 to 36), with a leading `-` when negative.
    + fn to_base(base: u32) String
    // Writes the value as text in `base` into `buf` and returns the byte count.
    + fn to_base_in(buf: local mut &[u8], base: u32, lowercase: bool (false)) uint
    // Writes the value as text in `base` to `out` and returns the bytes written.
    + fn to_base_into(base: u32, out: Writer, lowercase: bool (false)) uint !io:IoError
    // Writes the value as text in `base` to `result` and returns the byte count.
    + fn to_base_to_ptr(base: u32, result: ptr, lowercase: bool (false)) uint $deprecated
    // Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.
    + fn to_hex() String
    // Returns the value in decimal, with a leading `-` when negative.
    + fn to_string() String
    // Returns how many zero bits come after the lowest one bit; the bit width for 0.
    + fn trailing_zeros() uint
    // Writes `v` to the first `size_of(SELF)` bytes of `to`, most significant first. Panics when `to` is shorter.
    + static fn write_big_endian(v: u32, to: local mut &[u8]) void
    // Writes `v` to the first `size_of(SELF)` bytes of `to`, least significant first. Panics when `to` is shorter.
    + static fn write_little_endian(v: u32, to: local mut &[u8]) void
}
```

### u32

A 32-bit unsigned integer.

#### abs

Returns the absolute value. Unsigned values are returned unchanged.

Panics for the minimum value of a signed type (e.g. `i8.$min`), whose absolute value
does not fit.

#### character_length

Returns how many bytes `to_base_to_ptr` writes for this value in `base`, sign included.

`base` is clamped the same way as in `to_base_to_ptr`.

#### clamp

Returns the value limited to the range `minimum` to `maximum`, both inclusive.

Panics when `minimum` is greater than `maximum`.

#### count_ones

Returns how many bits are one.

#### equals_string

Returns true when `str` parses as an integer equal to this value.

Parses with `String.to_int` (`String.to_uint` for unsigned types); text that does not
parse compares unequal. Tagged `$eq`, so `5 == "5"` is true.

#### leading_zeros

Returns how many zero bits come before the highest one bit; the bit width for 0.

Compiles to one instruction on current CPUs.

#### max

Returns the larger of `this` and `other`.

#### min

Returns the smaller of `this` and `other`.

#### print

Writes the value as text in `base` to stdout, without a newline.

The write is unbuffered and write errors are ignored. Digits above 9 are uppercase. A
`base` above 36 is treated as 36 and one below 2 as 10.

#### random

Returns a random value from the operating system's secure entropy source.

Every value of the type is equally likely. Panics when the operating system cannot
provide random bytes.

#### read_big_endian

Reads a value from the first `size_of(SELF)` bytes of `from`, most significant first.
Panics when `from` is shorter.

#### read_little_endian

Reads a value from the first `size_of(SELF)` bytes of `from`, least significant first.
Panics when `from` is shorter.

```valk
let bytes = Array[u8]{ 0xFF, 0x04, 0x03, 0x02, 0x01 }
let v = u32.read_little_endian(&bytes[1 .. 4]) // 0x01020304
```

#### round_down

Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned
unchanged.

`(5).round_down(4)` is 4 and `(-5).round_down(4)` is -8. The sign of `modulo` does not
matter. Panics when `modulo` is 0 or the rounded value does not fit in the type, e.g.
`i8.$min.round_down(3)`.

#### round_up

Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned
unchanged.

`(5).round_up(4)` is 8 and `(-5).round_up(4)` is -4. The sign of `modulo` does not
matter. Panics when `modulo` is 0 or the rounded value does not fit in the type, e.g.
`u8.$max.round_up(4)`.

#### to_base

Returns the value as text in `base` (2 to 36), with a leading `-` when negative.

Digits above 9 are uppercase letters. A `base` above 36 is treated as 36 and one below 2
as 10.

#### to_base_in

Writes the value as text in `base` into `buf` and returns the byte count.

`buf` must hold at least `INT_TEXT_SIZE` (65) bytes; a shorter buffer panics. Nothing is
allocated. Digits above 9 are lowercase when `lowercase` is true, uppercase otherwise;
`base` is clamped as in `to_base`. No terminating zero is written.

#### to_base_into

Writes the value as text in `base` to `out` and returns the bytes written.

The text is built on the stack, so nothing is allocated. Digits above 9 are lowercase
when `lowercase` is true, uppercase otherwise; `base` is clamped as in `to_base`.
Throws when `out` fails.

#### to_base_to_ptr

Writes the value as text in `base` to `result` and returns the byte count.

Digits above 9 are lowercase when `lowercase` is true, uppercase otherwise. A `base`
above 36 is treated as 36 and one below 2 as 10. Writes at most 65 bytes (a sign plus 64
binary digits) and no terminating zero. Deprecated: unchecked; use `to_base_in`, which
takes a bounds-checked slice, or `to_base_into`.

#### to_hex

Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.

#### to_string

Returns the value in decimal, with a leading `-` when negative.

Tagged `$auto`, so an integer converts to `String` implicitly wherever one is expected.

#### trailing_zeros

Returns how many zero bits come after the lowest one bit; the bit width for 0.

#### write_big_endian

Writes `v` to the first `size_of(SELF)` bytes of `to`, most significant first.
Panics when `to` is shorter.

#### write_little_endian

Writes `v` to the first `size_of(SELF)` bytes of `to`, least significant first.
Panics when `to` is shorter.

```valk
let buf: [u8 x 4] = @undefined
u32.write_little_endian(0x01020304, &buf)
```

```js
// A 64-bit unsigned integer.
+ class u64 {
    // Returns the absolute value. Unsigned values are returned unchanged.
    + fn abs() u64
    // Returns how many bytes `to_base_to_ptr` writes for this value in `base`, sign included.
    + fn character_length(base: u64) uint
    // Returns the value limited to the range `minimum` to `maximum`, both inclusive.
    + fn clamp(minimum: u64, maximum: u64) u64
    // Returns how many bits are one.
    + fn count_ones() uint
    // Returns true when `str` parses as an integer equal to this value.
    + fn equals_string(str: String) bool
    // Returns how many zero bits come before the highest one bit; the bit width for 0.
    + fn leading_zeros() uint
    // Returns the larger of `this` and `other`.
    + fn max(other: u64) u64
    // Returns the smaller of `this` and `other`.
    + fn min(other: u64) u64
    // Returns the full 128-bit product of this value and `other` as its high and low halves.
    + fn mul_wide(other: u64) (u64, u64)
    // Writes the value as text in `base` to stdout, without a newline.
    + fn print(base: u64) void
    // Returns a random value from the operating system's secure entropy source.
    + static fn random() u64
    // Reads a value from the first `size_of(SELF)` bytes of `from`, most significant first. Panics when `from` is shorter.
    + static fn read_big_endian(from: local &[u8]) u64
    // Reads a value from the first `size_of(SELF)` bytes of `from`, least significant first. Panics when `from` is shorter.
    + static fn read_little_endian(from: local &[u8]) u64
    // Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_down(modulo: u64) u64
    // Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_up(modulo: u64) u64
    // Returns the value as text in `base` (2 to 36), with a leading `-` when negative.
    + fn to_base(base: u64) String
    // Writes the value as text in `base` into `buf` and returns the byte count.
    + fn to_base_in(buf: local mut &[u8], base: u64, lowercase: bool (false)) uint
    // Writes the value as text in `base` to `out` and returns the bytes written.
    + fn to_base_into(base: u64, out: Writer, lowercase: bool (false)) uint !io:IoError
    // Writes the value as text in `base` to `result` and returns the byte count.
    + fn to_base_to_ptr(base: u64, result: ptr, lowercase: bool (false)) uint $deprecated
    // Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.
    + fn to_hex() String
    // Returns the value in decimal, with a leading `-` when negative.
    + fn to_string() String
    // Returns how many zero bits come after the lowest one bit; the bit width for 0.
    + fn trailing_zeros() uint
    // Writes `v` to the first `size_of(SELF)` bytes of `to`, most significant first. Panics when `to` is shorter.
    + static fn write_big_endian(v: u64, to: local mut &[u8]) void
    // Writes `v` to the first `size_of(SELF)` bytes of `to`, least significant first. Panics when `to` is shorter.
    + static fn write_little_endian(v: u64, to: local mut &[u8]) void
}
```

### u64

A 64-bit unsigned integer.

#### abs

Returns the absolute value. Unsigned values are returned unchanged.

Panics for the minimum value of a signed type (e.g. `i8.$min`), whose absolute value
does not fit.

#### character_length

Returns how many bytes `to_base_to_ptr` writes for this value in `base`, sign included.

`base` is clamped the same way as in `to_base_to_ptr`.

#### clamp

Returns the value limited to the range `minimum` to `maximum`, both inclusive.

Panics when `minimum` is greater than `maximum`.

#### count_ones

Returns how many bits are one.

#### equals_string

Returns true when `str` parses as an integer equal to this value.

Parses with `String.to_int` (`String.to_uint` for unsigned types); text that does not
parse compares unequal. Tagged `$eq`, so `5 == "5"` is true.

#### leading_zeros

Returns how many zero bits come before the highest one bit; the bit width for 0.

Compiles to one instruction on current CPUs.

#### max

Returns the larger of `this` and `other`.

#### min

Returns the smaller of `this` and `other`.

#### mul_wide

Returns the full 128-bit product of this value and `other` as its high and low halves.

Compiles to one multiply on 64-bit CPUs.

#### print

Writes the value as text in `base` to stdout, without a newline.

The write is unbuffered and write errors are ignored. Digits above 9 are uppercase. A
`base` above 36 is treated as 36 and one below 2 as 10.

#### random

Returns a random value from the operating system's secure entropy source.

Every value of the type is equally likely. Panics when the operating system cannot
provide random bytes.

#### read_big_endian

Reads a value from the first `size_of(SELF)` bytes of `from`, most significant first.
Panics when `from` is shorter.

#### read_little_endian

Reads a value from the first `size_of(SELF)` bytes of `from`, least significant first.
Panics when `from` is shorter.

```valk
let bytes = Array[u8]{ 0xFF, 0x04, 0x03, 0x02, 0x01 }
let v = u32.read_little_endian(&bytes[1 .. 4]) // 0x01020304
```

#### round_down

Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned
unchanged.

`(5).round_down(4)` is 4 and `(-5).round_down(4)` is -8. The sign of `modulo` does not
matter. Panics when `modulo` is 0 or the rounded value does not fit in the type, e.g.
`i8.$min.round_down(3)`.

#### round_up

Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned
unchanged.

`(5).round_up(4)` is 8 and `(-5).round_up(4)` is -4. The sign of `modulo` does not
matter. Panics when `modulo` is 0 or the rounded value does not fit in the type, e.g.
`u8.$max.round_up(4)`.

#### to_base

Returns the value as text in `base` (2 to 36), with a leading `-` when negative.

Digits above 9 are uppercase letters. A `base` above 36 is treated as 36 and one below 2
as 10.

#### to_base_in

Writes the value as text in `base` into `buf` and returns the byte count.

`buf` must hold at least `INT_TEXT_SIZE` (65) bytes; a shorter buffer panics. Nothing is
allocated. Digits above 9 are lowercase when `lowercase` is true, uppercase otherwise;
`base` is clamped as in `to_base`. No terminating zero is written.

#### to_base_into

Writes the value as text in `base` to `out` and returns the bytes written.

The text is built on the stack, so nothing is allocated. Digits above 9 are lowercase
when `lowercase` is true, uppercase otherwise; `base` is clamped as in `to_base`.
Throws when `out` fails.

#### to_base_to_ptr

Writes the value as text in `base` to `result` and returns the byte count.

Digits above 9 are lowercase when `lowercase` is true, uppercase otherwise. A `base`
above 36 is treated as 36 and one below 2 as 10. Writes at most 65 bytes (a sign plus 64
binary digits) and no terminating zero. Deprecated: unchecked; use `to_base_in`, which
takes a bounds-checked slice, or `to_base_into`.

#### to_hex

Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.

#### to_string

Returns the value in decimal, with a leading `-` when negative.

Tagged `$auto`, so an integer converts to `String` implicitly wherever one is expected.

#### trailing_zeros

Returns how many zero bits come after the lowest one bit; the bit width for 0.

#### write_big_endian

Writes `v` to the first `size_of(SELF)` bytes of `to`, most significant first.
Panics when `to` is shorter.

#### write_little_endian

Writes `v` to the first `size_of(SELF)` bytes of `to`, least significant first.
Panics when `to` is shorter.

```valk
let buf: [u8 x 4] = @undefined
u32.write_little_endian(0x01020304, &buf)
```

```js
// An 8-bit unsigned integer, also used for bytes.
+ class u8 {
    // Returns the absolute value. Unsigned values are returned unchanged.
    + fn abs() u8
    // Returns how many bytes `to_base_to_ptr` writes for this value in `base`, sign included.
    + fn character_length(base: u8) uint
    // Returns the value limited to the range `minimum` to `maximum`, both inclusive.
    + fn clamp(minimum: u8, maximum: u8) u8
    // Returns how many bits are one.
    + fn count_ones() uint
    // Returns true when `str` parses as an integer equal to this value.
    + fn equals_string(str: String) bool
    // Returns the value (0 to 15) of a hex digit byte like `7`, `a` or `F`.
    + fn hex_byte_to_hex_value() u8
    // Returns true for the ASCII letters `a-z` and `A-Z`.
    + fn is_alpha() bool
    // Returns true for the ASCII letters and digits.
    + fn is_alpha_numeric() bool
    // Returns true for bytes below 128.
    + fn is_ascii() bool
    // Returns true for the ASCII hex digits `0-9`, `a-f` and `A-F`.
    + fn is_hex() bool
    // Returns true for HTML whitespace other than newlines: space, tab and form feed.
    + fn is_html_spacing() bool
    // Returns true for the HTML whitespace bytes: space, `\n`, `\r`, tab and form feed.
    + fn is_html_whitespace() bool
    // Returns true for the ASCII lowercase letters `a-z`.
    + fn is_lower() bool
    // Returns true for `\n` only.
    + fn is_newline() bool
    // Returns true for the ASCII digits `0-9`.
    + fn is_number() bool
    // Returns true for the ASCII octal digits `0-7`.
    + fn is_octal() bool
    // Returns true for a space or a tab.
    + fn is_space_or_tab() bool
    // Returns true for the ASCII uppercase letters `A-Z`.
    + fn is_upper() bool
    // Returns true for space, `\t`, `\n`, `\v`, `\f` and `\r`.
    + fn is_whitespace() bool
    // Returns how many zero bits come before the highest one bit; the bit width for 0.
    + fn leading_zeros() uint
    // Returns the larger of `this` and `other`.
    + fn max(other: u8) u8
    // Returns the smaller of `this` and `other`.
    + fn min(other: u8) u8
    // Writes the value as text in `base` to stdout, without a newline.
    + fn print(base: u8) void
    // Returns a random value from the operating system's secure entropy source.
    + static fn random() u8
    // Reads a value from the first `size_of(SELF)` bytes of `from`, most significant first. Panics when `from` is shorter.
    + static fn read_big_endian(from: local &[u8]) u8
    // Reads a value from the first `size_of(SELF)` bytes of `from`, least significant first. Panics when `from` is shorter.
    + static fn read_little_endian(from: local &[u8]) u8
    // Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_down(modulo: u8) u8
    // Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_up(modulo: u8) u8
    // Returns a one-byte `String` holding this byte.
    + fn to_ascii_string() String
    // Returns the value as text in `base` (2 to 36), with a leading `-` when negative.
    + fn to_base(base: u8) String
    // Writes the value as text in `base` into `buf` and returns the byte count.
    + fn to_base_in(buf: local mut &[u8], base: u8, lowercase: bool (false)) uint
    // Writes the value as text in `base` to `out` and returns the bytes written.
    + fn to_base_into(base: u8, out: Writer, lowercase: bool (false)) uint !io:IoError
    // Writes the value as text in `base` to `result` and returns the byte count.
    + fn to_base_to_ptr(base: u8, result: ptr, lowercase: bool (false)) uint $deprecated
    // Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.
    + fn to_hex() String
    // Returns the value in decimal, with a leading `-` when negative.
    + fn to_string() String
    // Returns how many zero bits come after the lowest one bit; the bit width for 0.
    + fn trailing_zeros() uint
    // Returns the byte an escape letter stands for, e.g. `n` gives `\n`.
    + fn unescape() u8
    // Writes `v` to the first `size_of(SELF)` bytes of `to`, most significant first. Panics when `to` is shorter.
    + static fn write_big_endian(v: u8, to: local mut &[u8]) void
    // Writes `v` to the first `size_of(SELF)` bytes of `to`, least significant first. Panics when `to` is shorter.
    + static fn write_little_endian(v: u8, to: local mut &[u8]) void
}
```

### u8

An 8-bit unsigned integer, also used for bytes.

#### abs

Returns the absolute value. Unsigned values are returned unchanged.

Panics for the minimum value of a signed type (e.g. `i8.$min`), whose absolute value
does not fit.

#### character_length

Returns how many bytes `to_base_to_ptr` writes for this value in `base`, sign included.

`base` is clamped the same way as in `to_base_to_ptr`.

#### clamp

Returns the value limited to the range `minimum` to `maximum`, both inclusive.

Panics when `minimum` is greater than `maximum`.

#### count_ones

Returns how many bits are one.

#### equals_string

Returns true when `str` parses as an integer equal to this value.

Parses with `String.to_int` (`String.to_uint` for unsigned types); text that does not
parse compares unequal. Tagged `$eq`, so `5 == "5"` is true.

#### hex_byte_to_hex_value

Returns the value (0 to 15) of a hex digit byte like `7`, `a` or `F`.

The byte is not validated; a non-hex byte gives a meaningless result.

#### is_alpha

Returns true for the ASCII letters `a-z` and `A-Z`.

#### is_alpha_numeric

Returns true for the ASCII letters and digits.

#### is_ascii

Returns true for bytes below 128.

#### is_hex

Returns true for the ASCII hex digits `0-9`, `a-f` and `A-F`.

#### is_html_spacing

Returns true for HTML whitespace other than newlines: space, tab and form feed.

#### is_html_whitespace

Returns true for the HTML whitespace bytes: space, `\n`, `\r`, tab and form feed.

#### is_lower

Returns true for the ASCII lowercase letters `a-z`.

#### is_newline

Returns true for `\n` only.

#### is_number

Returns true for the ASCII digits `0-9`.

#### is_octal

Returns true for the ASCII octal digits `0-7`.

#### is_space_or_tab

Returns true for a space or a tab.

#### is_upper

Returns true for the ASCII uppercase letters `A-Z`.

#### is_whitespace

Returns true for space, `\t`, `\n`, `\v`, `\f` and `\r`.

#### leading_zeros

Returns how many zero bits come before the highest one bit; the bit width for 0.

Compiles to one instruction on current CPUs.

#### max

Returns the larger of `this` and `other`.

#### min

Returns the smaller of `this` and `other`.

#### print

Writes the value as text in `base` to stdout, without a newline.

The write is unbuffered and write errors are ignored. Digits above 9 are uppercase. A
`base` above 36 is treated as 36 and one below 2 as 10.

#### random

Returns a random value from the operating system's secure entropy source.

Every value of the type is equally likely. Panics when the operating system cannot
provide random bytes.

#### read_big_endian

Reads a value from the first `size_of(SELF)` bytes of `from`, most significant first.
Panics when `from` is shorter.

#### read_little_endian

Reads a value from the first `size_of(SELF)` bytes of `from`, least significant first.
Panics when `from` is shorter.

```valk
let bytes = Array[u8]{ 0xFF, 0x04, 0x03, 0x02, 0x01 }
let v = u32.read_little_endian(&bytes[1 .. 4]) // 0x01020304
```

#### round_down

Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned
unchanged.

`(5).round_down(4)` is 4 and `(-5).round_down(4)` is -8. The sign of `modulo` does not
matter. Panics when `modulo` is 0 or the rounded value does not fit in the type, e.g.
`i8.$min.round_down(3)`.

#### round_up

Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned
unchanged.

`(5).round_up(4)` is 8 and `(-5).round_up(4)` is -4. The sign of `modulo` does not
matter. Panics when `modulo` is 0 or the rounded value does not fit in the type, e.g.
`u8.$max.round_up(4)`.

#### to_ascii_string

Returns a one-byte `String` holding this byte.

The byte is not encoded, so a byte of 128 or more gives a string that is not valid
UTF-8.

#### to_base

Returns the value as text in `base` (2 to 36), with a leading `-` when negative.

Digits above 9 are uppercase letters. A `base` above 36 is treated as 36 and one below 2
as 10.

#### to_base_in

Writes the value as text in `base` into `buf` and returns the byte count.

`buf` must hold at least `INT_TEXT_SIZE` (65) bytes; a shorter buffer panics. Nothing is
allocated. Digits above 9 are lowercase when `lowercase` is true, uppercase otherwise;
`base` is clamped as in `to_base`. No terminating zero is written.

#### to_base_into

Writes the value as text in `base` to `out` and returns the bytes written.

The text is built on the stack, so nothing is allocated. Digits above 9 are lowercase
when `lowercase` is true, uppercase otherwise; `base` is clamped as in `to_base`.
Throws when `out` fails.

#### to_base_to_ptr

Writes the value as text in `base` to `result` and returns the byte count.

Digits above 9 are lowercase when `lowercase` is true, uppercase otherwise. A `base`
above 36 is treated as 36 and one below 2 as 10. Writes at most 65 bytes (a sign plus 64
binary digits) and no terminating zero. Deprecated: unchecked; use `to_base_in`, which
takes a bounds-checked slice, or `to_base_into`.

#### to_hex

Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.

#### to_string

Returns the value in decimal, with a leading `-` when negative.

Tagged `$auto`, so an integer converts to `String` implicitly wherever one is expected.

#### trailing_zeros

Returns how many zero bits come after the lowest one bit; the bit width for 0.

#### unescape

Returns the byte an escape letter stands for, e.g. `n` gives `\n`.

Handles `n`, `r`, `t`, `f`, `b`, `v`, `a`, `e` (27) and `0` (zero byte); any other byte
is returned unchanged.

#### write_big_endian

Writes `v` to the first `size_of(SELF)` bytes of `to`, most significant first.
Panics when `to` is shorter.

#### write_little_endian

Writes `v` to the first `size_of(SELF)` bytes of `to`, least significant first.
Panics when `to` is shorter.

```valk
let buf: [u8 x 4] = @undefined
u32.write_little_endian(0x01020304, &buf)
```

```js
// An unsigned integer as wide as a pointer: 64 bits on 64-bit targets, 32 on 32-bit ones.
+ class uint {
    // Returns the absolute value. Unsigned values are returned unchanged.
    + fn abs() uint
    // Returns how many bytes `to_base_to_ptr` writes for this value in `base`, sign included.
    + fn character_length(base: uint) uint
    // Returns `this + other`, throwing `range` instead of wrapping on overflow.
    + fn checked_add(other: uint) uint !LookupError
    // Returns `this * other`, throwing `range` instead of wrapping on overflow.
    + fn checked_multiply(other: uint) uint !LookupError
    // Returns the value limited to the range `minimum` to `maximum`, both inclusive.
    + fn clamp(minimum: uint, maximum: uint) uint
    // Returns how many bits are one.
    + fn count_ones() uint
    // Returns true when `str` parses as an integer equal to this value.
    + fn equals_string(str: String) bool
    // Returns how many zero bits come before the highest one bit; the bit width for 0.
    + fn leading_zeros() uint
    // Returns the larger of `this` and `other`.
    + fn max(other: uint) uint
    // Returns the smaller of `this` and `other`.
    + fn min(other: uint) uint
    // Returns the full 128-bit product of this value and `other` as its high and low halves.
    + fn mul_wide(other: uint) (u64, u64)
    // Writes the value as text in `base` to stdout, without a newline.
    + fn print(base: uint) void
    // Returns a random value from the operating system's secure entropy source.
    + static fn random() uint
    // Reads a value from the first `size_of(SELF)` bytes of `from`, most significant first. Panics when `from` is shorter.
    + static fn read_big_endian(from: local &[u8]) uint
    // Reads a value from the first `size_of(SELF)` bytes of `from`, least significant first. Panics when `from` is shorter.
    + static fn read_little_endian(from: local &[u8]) uint
    // Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_down(modulo: uint) uint
    // Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_up(modulo: uint) uint
    // Returns the value as text in `base` (2 to 36), with a leading `-` when negative.
    + fn to_base(base: uint) String
    // Writes the value as text in `base` into `buf` and returns the byte count.
    + fn to_base_in(buf: local mut &[u8], base: uint, lowercase: bool (false)) uint
    // Writes the value as text in `base` to `out` and returns the bytes written.
    + fn to_base_into(base: uint, out: Writer, lowercase: bool (false)) uint !io:IoError
    // Writes the value as text in `base` to `result` and returns the byte count.
    + fn to_base_to_ptr(base: uint, result: ptr, lowercase: bool (false)) uint $deprecated
    // Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.
    + fn to_hex() String
    // Returns the value in decimal, with a leading `-` when negative.
    + fn to_string() String
    // Returns how many zero bits come after the lowest one bit; the bit width for 0.
    + fn trailing_zeros() uint
    // Writes `v` to the first `size_of(SELF)` bytes of `to`, most significant first. Panics when `to` is shorter.
    + static fn write_big_endian(v: uint, to: local mut &[u8]) void
    // Writes `v` to the first `size_of(SELF)` bytes of `to`, least significant first. Panics when `to` is shorter.
    + static fn write_little_endian(v: uint, to: local mut &[u8]) void
}
```

### uint

An unsigned integer as wide as a pointer: 64 bits on 64-bit targets, 32 on 32-bit ones.

#### abs

Returns the absolute value. Unsigned values are returned unchanged.

Panics for the minimum value of a signed type (e.g. `i8.$min`), whose absolute value
does not fit.

#### character_length

Returns how many bytes `to_base_to_ptr` writes for this value in `base`, sign included.

`base` is clamped the same way as in `to_base_to_ptr`.

#### checked_add

Returns `this + other`, throwing `range` instead of wrapping on overflow.

#### checked_multiply

Returns `this * other`, throwing `range` instead of wrapping on overflow.

#### clamp

Returns the value limited to the range `minimum` to `maximum`, both inclusive.

Panics when `minimum` is greater than `maximum`.

#### count_ones

Returns how many bits are one.

#### equals_string

Returns true when `str` parses as an integer equal to this value.

Parses with `String.to_int` (`String.to_uint` for unsigned types); text that does not
parse compares unequal. Tagged `$eq`, so `5 == "5"` is true.

#### leading_zeros

Returns how many zero bits come before the highest one bit; the bit width for 0.

Compiles to one instruction on current CPUs.

#### max

Returns the larger of `this` and `other`.

#### min

Returns the smaller of `this` and `other`.

#### mul_wide

Returns the full 128-bit product of this value and `other` as its high and low halves.

Compiles to one multiply on 64-bit CPUs.

#### print

Writes the value as text in `base` to stdout, without a newline.

The write is unbuffered and write errors are ignored. Digits above 9 are uppercase. A
`base` above 36 is treated as 36 and one below 2 as 10.

#### random

Returns a random value from the operating system's secure entropy source.

Every value of the type is equally likely. Panics when the operating system cannot
provide random bytes.

#### read_big_endian

Reads a value from the first `size_of(SELF)` bytes of `from`, most significant first.
Panics when `from` is shorter.

#### read_little_endian

Reads a value from the first `size_of(SELF)` bytes of `from`, least significant first.
Panics when `from` is shorter.

```valk
let bytes = Array[u8]{ 0xFF, 0x04, 0x03, 0x02, 0x01 }
let v = u32.read_little_endian(&bytes[1 .. 4]) // 0x01020304
```

#### round_down

Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned
unchanged.

`(5).round_down(4)` is 4 and `(-5).round_down(4)` is -8. The sign of `modulo` does not
matter. Panics when `modulo` is 0 or the rounded value does not fit in the type, e.g.
`i8.$min.round_down(3)`.

#### round_up

Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned
unchanged.

`(5).round_up(4)` is 8 and `(-5).round_up(4)` is -4. The sign of `modulo` does not
matter. Panics when `modulo` is 0 or the rounded value does not fit in the type, e.g.
`u8.$max.round_up(4)`.

#### to_base

Returns the value as text in `base` (2 to 36), with a leading `-` when negative.

Digits above 9 are uppercase letters. A `base` above 36 is treated as 36 and one below 2
as 10.

#### to_base_in

Writes the value as text in `base` into `buf` and returns the byte count.

`buf` must hold at least `INT_TEXT_SIZE` (65) bytes; a shorter buffer panics. Nothing is
allocated. Digits above 9 are lowercase when `lowercase` is true, uppercase otherwise;
`base` is clamped as in `to_base`. No terminating zero is written.

#### to_base_into

Writes the value as text in `base` to `out` and returns the bytes written.

The text is built on the stack, so nothing is allocated. Digits above 9 are lowercase
when `lowercase` is true, uppercase otherwise; `base` is clamped as in `to_base`.
Throws when `out` fails.

#### to_base_to_ptr

Writes the value as text in `base` to `result` and returns the byte count.

Digits above 9 are lowercase when `lowercase` is true, uppercase otherwise. A `base`
above 36 is treated as 36 and one below 2 as 10. Writes at most 65 bytes (a sign plus 64
binary digits) and no terminating zero. Deprecated: unchecked; use `to_base_in`, which
takes a bounds-checked slice, or `to_base_into`.

#### to_hex

Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.

#### to_string

Returns the value in decimal, with a leading `-` when negative.

Tagged `$auto`, so an integer converts to `String` implicitly wherever one is expected.

#### trailing_zeros

Returns how many zero bits come after the lowest one bit; the bit width for 0.

#### write_big_endian

Writes `v` to the first `size_of(SELF)` bytes of `to`, most significant first.
Panics when `to` is shorter.

#### write_little_endian

Writes `v` to the first `size_of(SELF)` bytes of `to`, least significant first.
Panics when `to` is shorter.

```valk
let buf: [u8 x 4] = @undefined
u32.write_little_endian(0x01020304, &buf)
```

## Globals for 'core'

```js
// The number of `lock` blocks held on this thread, by any of its coroutines.
~+ global held_locks : uint
```

### held_locks

The number of `lock` blocks held on this thread, by any of its coroutines.

A thread whose entry function returns keeps running its coroutines until this drops to 0.

# coro

## Aliases for 'coro'

```js
// The stack size in bytes of the program's main coroutine: 8 MiB, like a native main thread.
+ value MAIN_STACK_SIZE (8 * 1024 * 1024)
```

### MAIN_STACK_SIZE

The stack size in bytes of the program's main coroutine: 8 MiB, like a native main thread.

## Functions for 'coro'

```js
// Waits until `coro` has finished; returns at once when it already has.
+ fn await_coro(coro: Coro) void
// Moves the current coroutine to the back of the run queue and suspends it.
+ fn await_last() void
// Unmaps the coroutine stacks this thread keeps for reuse; called when the thread stops.
+ fn stack_cache_release() void
// Sets up stack-overflow reporting for the calling thread; the runtime calls it at thread start.
+ fn stack_guard_init(is_main: bool, stack_low: uint) void
```

### await_coro

Waits until `coro` has finished; returns at once when it already has.

Inside a coroutine it suspends the caller; outside one it runs the scheduler until
`coro` is done. Panics when a coroutine awaits itself or the awaits form a cycle.

### await_last

Moves the current coroutine to the back of the run queue and suspends it.

Every coroutine scheduled before it runs first. Does nothing outside a coroutine.

### stack_cache_release

Unmaps the coroutine stacks this thread keeps for reuse; called when the thread stops.

### stack_guard_init

Sets up stack-overflow reporting for the calling thread; the runtime calls it at thread start.

With `is_main` it also installs the process-wide handler that prints "Stack overflow"
and exits with status 1. On Linux and macOS it installs an alternate signal stack, and
`stack_low` is the lowest address of the thread's native stack (0 when unknown);
Windows ignores `stack_low` and reserves stack room for the handler instead.

## Globals for 'coro'

```js
// The stack size in bytes for the next coroutine created on this thread; 0 uses the default.
+ global next_stack_size : uint
```

### next_stack_size

The stack size in bytes for the next coroutine created on this thread; 0 uses the default.

The default is 1 MiB. Creating a coroutine resets it to 0.

# crypto

## Aliases for 'crypto'

```js
// The nonce size in bytes of every `Cipher`.
+ value CIPHER_NONCE_SIZE (12)
// The size in bytes of the authentication tag every `Cipher` appends.
+ value CIPHER_TAG_SIZE (16)
type c_long (int)
```

### CIPHER_NONCE_SIZE

The nonce size in bytes of every `Cipher`.

### CIPHER_TAG_SIZE

The size in bytes of the authentication tag every `Cipher` appends.

## Errors for 'crypto'

```js
// Thrown by `encrypt`, `decrypt`, `seal` and `unseal`.
error CipherError (invalid_input, auth, failed)
// Thrown by the decoders, password hashes and key derivation functions of `crypto`.
error CryptoError (invalid_input, write)
// Thrown by `PrivateKey`, `PublicKey` and the ECDSA signature conversions.
error KeyError (invalid_input, key, failed)
```

### CipherError

Thrown by `encrypt`, `decrypt`, `seal` and `unseal`.

- `invalid_input`: a key or nonce of the wrong size for the cipher.
- `auth`: decryption failed its authentication check: the data, its tag or the additional
  data was altered, or the key or nonce is not the one it was encrypted with.
- `failed`: the cryptography library refused the operation.

### CryptoError

Thrown by the decoders, password hashes and key derivation functions of `crypto`.

- `invalid_input`: malformed base64, radix-64 or hex input, or a parameter out of range
  (bcrypt cost or salt length, a zero or too large pbkdf2/hkdf output length, a BLAKE2b
  hash size or key over 64 bytes, an empty blowfish key).
- `write`: the `io.Writer` given to `base64_decode_into` or `hex_decode_into` failed.

### KeyError

Thrown by `PrivateKey`, `PublicKey` and the ECDSA signature conversions.

- `invalid_input`: a parameter out of range, such as an RSA key size, a seed or raw key of
  the wrong length, or a malformed signature to convert.
- `key`: a key that cannot be read (malformed, encrypted with another password, or of an
  unsupported type), or that does not fit the requested signature algorithm.
- `failed`: the cryptography library refused the operation.

## Enums for 'crypto'

```js
// An authenticated encryption algorithm (AEAD) for `encrypt` and `decrypt`.
+ enum Cipher { aes_128_gcm, aes_256_gcm, chacha20_poly1305 }
// An elliptic curve for ECDSA keys: NIST P-256, P-384 or P-521.
+ enum Curve { p256, p384, p521 }
// The hash functions available through `hasher`, `hash` and `Hmac`.
+ enum HashAlgorithm { md5, sha1, sha256, sha384, sha512 }
// The kind of a `PrivateKey` or `PublicKey`.
+ enum KeyType { rsa, ec, ed25519 }
// How `PrivateKey.sign` and `PublicKey.verify` hash and pad.
+ enum SignatureAlgorithm { ed25519, ecdsa_sha256, ecdsa_sha384, ecdsa_sha512, rsa_pkcs1_sha256, rsa_pkcs1_sha384, rsa_pkcs1_sha512, rsa_pss_sha256, rsa_pss_sha384, rsa_pss_sha512 }
```

### Cipher

An authenticated encryption algorithm (AEAD) for `encrypt` and `decrypt`.

Each takes a 12-byte nonce and adds a 16-byte tag that `decrypt` checks, so tampering is
detected. AES-256-GCM and ChaCha20-Poly1305 take a 32-byte key, AES-128-GCM a 16-byte
one.

### Curve

An elliptic curve for ECDSA keys: NIST P-256, P-384 or P-521.

### HashAlgorithm

The hash functions available through `hasher`, `hash` and `Hmac`.

### KeyType

The kind of a `PrivateKey` or `PublicKey`.

### SignatureAlgorithm

How `PrivateKey.sign` and `PublicKey.verify` hash and pad.

Together these cover the JWT algorithms EdDSA (`ed25519`), ES256 to ES512 (`ecdsa_*`, but
see `ecdsa_signature_to_raw`), RS256 to RS512 (`rsa_pkcs1_*`) and PS256 to PS512
(`rsa_pss_*`). PSS signs with a salt as long as the hash, as JWT and TLS require, and
verifies any salt length, so signatures made with the largest salt (Python's
`PSS.MAX_LENGTH`, the `openssl` command) verify too.

## Functions for 'crypto'

```js
// Decodes standard base64 (`+` and `/`) into the raw bytes it represents.
+ fn base64_decode(data: local &[u8]) String !CryptoError
// Decodes standard base64 into `out` and returns the bytes written.
+ fn base64_decode_in(data: local &[u8], out: local mut &[u8]) uint !CryptoError
// Decodes standard base64 into `out` and returns the bytes written.
+ fn base64_decode_into(data: local &[u8], out: Writer) uint !CryptoError
// Returns the most bytes that `length` base64 characters can decode to.
+ fn base64_decoded_size(length: uint) uint
// Returns `data` encoded as standard base64 (`+` and `/`), `=` padded, without line breaks.
+ fn base64_encode(data: local &[u8]) String
// Writes `data` encoded as standard padded base64 into `out` and returns the bytes written.
+ fn base64_encode_in(data: local &[u8], out: local mut &[u8]) uint
// Writes `data` encoded as standard padded base64 to `out` and returns the bytes written.
+ fn base64_encode_into(data: local &[u8], out: Writer) uint !io:IoError
// Returns the number of base64 characters that encode `length` bytes, padding included.
+ fn base64_encoded_size(length: uint) uint
// Decodes URL-safe base64 (`-` and `_`), with or without `=` padding.
+ fn base64url_decode(text: local &[u8]) String !CryptoError
// Returns `data` encoded as URL-safe base64 (`-` and `_`) without `=` padding, the form JWT, JWK and WebAuthn use.
+ fn base64url_encode(data: local &[u8]) String
// Computes the bcrypt hash of `password` with the given `cost` and `salt` into `output`.
+ fn bcrypt(cost: uint, salt: local &[u8], password: local &[u8], output: ByteBuffer) void !CryptoError
// Hashes `password` with bcrypt and a fresh random salt, for storing credentials.
+ fn bcrypt_hash(password: local &[u8], cost: uint (12)) String !CryptoError
// Returns whether `password` matches the bcrypt `hash` string.
+ fn bcrypt_verify(password: local &[u8], hash: local &[u8]) bool
// Returns the key size in bytes that `cipher` takes: 16 for AES-128-GCM, 32 for the others.
+ fn cipher_key_size(cipher: Cipher) uint
// Returns whether `a` and `b` hold the same bytes, in time that depends only on their length.
+ fn constant_time_equals(a: local &[u8], b: local &[u8]) bool
// Decrypts `ciphertext`, as returned by `encrypt`, with the same `key`, `nonce` and `aad`.
+ fn decrypt(cipher: Cipher, key: local &[u8], nonce: local &[u8], ciphertext: local &[u8], aad: local &[u8] ("")) String !CipherError
// Returns the digest size in bytes of `algorithm`.
+ fn digest_size(algorithm: HashAlgorithm) uint
// Converts a fixed-size ECDSA signature (`r` and `s` side by side, as in JWT) into the DER form `verify` takes.
+ fn ecdsa_signature_from_raw(raw: local &[u8]) String !KeyError
// Converts a DER encoded ECDSA signature, as `sign` returns it, into the fixed-size form JWT and WebCrypto use: `r` and `s` side by side, each as long as the curve's size.
+ fn ecdsa_signature_to_raw(der: local &[u8], curve: Curve) String !KeyError
// Encrypts `plaintext` with `key` and the 12-byte `nonce`, and returns the ciphertext with the 16-byte tag appended.
+ fn encrypt(cipher: Cipher, key: local &[u8], nonce: local &[u8], plaintext: local &[u8], aad: local &[u8] ("")) String !CipherError
// Returns the raw digest of `data` as binary bytes (not text).
+ fn hash(algorithm: HashAlgorithm, data: local &[u8]) String
// Returns the digest of `data` as lowercase hex.
+ fn hash_hex(algorithm: HashAlgorithm, data: local &[u8]) String
// Writes the digest of `data` as lowercase hex into `out` and returns the bytes written.
+ fn hash_hex_in(algorithm: HashAlgorithm, data: local &[u8], out: local mut &[u8]) uint
// Writes the digest of `data` as lowercase hex to `out` and returns the bytes written.
+ fn hash_hex_into(algorithm: HashAlgorithm, data: local &[u8], out: Writer) uint !io:IoError
// Writes the raw digest of `data` into `out` and returns the bytes written.
+ fn hash_in(algorithm: HashAlgorithm, data: local &[u8], out: local mut &[u8]) uint
// Writes the raw digest of `data` to `out` and returns the bytes written.
+ fn hash_into(algorithm: HashAlgorithm, data: local &[u8], out: Writer) uint !io:IoError
// Returns a fresh `Hasher` for `algorithm`.
+ fn hasher(algorithm: HashAlgorithm) Hasher
// Decodes hex text (either case) into the raw bytes it represents.
+ fn hex_decode(text: local &[u8]) String !CryptoError
// Decodes hex text (either case) into `out` and returns the bytes written.
+ fn hex_decode_in(text: local &[u8], out: local mut &[u8]) uint !CryptoError
// Decodes hex text (either case) into `out` and returns the bytes written.
+ fn hex_decode_into(text: local &[u8], out: Writer) uint !CryptoError
// Returns `data` encoded as lowercase hex, two characters per byte.
+ fn hex_encode(data: local &[u8]) String
// Writes `data` as lowercase hex into `out` and returns the bytes written.
+ fn hex_encode_in(data: local &[u8], out: local mut &[u8]) uint
// Writes `data` as lowercase hex to `out` and returns the bytes written.
+ fn hex_encode_into(data: local &[u8], out: Writer) uint !io:IoError
// Derives `length` bytes from `ikm` with HKDF (RFC 5869): extract with `salt`, expand with `info`.
+ fn hkdf(algorithm: HashAlgorithm, ikm: local &[u8], salt: local &[u8], info: local &[u8], length: uint) String !CryptoError
// Returns `length` bytes of HKDF-Expand (RFC 5869) output from the pseudorandom key `prk`.
+ fn hkdf_expand(algorithm: HashAlgorithm, prk: local &[u8], info: local &[u8], length: uint) String !CryptoError
// Returns the HKDF-Extract (RFC 5869) pseudorandom key of `ikm` under `salt`.
+ fn hkdf_extract(algorithm: HashAlgorithm, salt: local &[u8], ikm: local &[u8]) String
// Returns the MD5 digest of `data` as lowercase hex.
+ fn md5_hex(data: local &[u8]) String
// Writes the MD5 digest of `data` as hex into `out`; see `hash_hex_in`.
+ fn md5_hex_in(data: local &[u8], out: local mut &[u8]) uint
// Writes the MD5 digest of `data` as lowercase hex to `out`; returns the bytes written.
+ fn md5_hex_into(data: local &[u8], out: Writer) uint !io:IoError
// Derives `length` bytes from `password` and `salt` with PBKDF2-HMAC (RFC 8018).
+ fn pbkdf2(algorithm: HashAlgorithm, password: local &[u8], salt: local &[u8], iterations: uint, length: uint) String !CryptoError
// Returns a string of `length` cryptographically secure random bytes.
+ fn random_bytes(length: uint) String
// Fills all of `out` with cryptographically secure random bytes and returns its length.
+ fn random_bytes_in(out: local mut &[u8]) uint
// Writes `length` cryptographically secure random bytes to `out`; returns the bytes written.
+ fn random_bytes_into(length: uint, out: Writer) uint !io:IoError
// Encrypts `plaintext` with AES-256-GCM under the 32-byte `key` and a random nonce, and returns the nonce, ciphertext and tag together, ready for `unseal`.
+ fn seal(key: local &[u8], plaintext: local &[u8], aad: local &[u8] ("")) String !CipherError
// Returns the SHA-1 digest of `data` as lowercase hex.
+ fn sha1_hex(data: local &[u8]) String
// Writes the SHA-1 digest of `data` as hex into `out`; see `hash_hex_in`.
+ fn sha1_hex_in(data: local &[u8], out: local mut &[u8]) uint
// Writes the SHA-1 digest of `data` as lowercase hex to `out`; returns the bytes written.
+ fn sha1_hex_into(data: local &[u8], out: Writer) uint !io:IoError
// Returns the SHA-256 digest of `data` as lowercase hex.
+ fn sha256_hex(data: local &[u8]) String
// Writes the SHA-256 digest of `data` as hex into `out`; see `hash_hex_in`.
+ fn sha256_hex_in(data: local &[u8], out: local mut &[u8]) uint
// Writes the SHA-256 digest of `data` as lowercase hex to `out`; returns the bytes written.
+ fn sha256_hex_into(data: local &[u8], out: Writer) uint !io:IoError
// Returns the SHA-384 digest of `data` as lowercase hex.
+ fn sha384_hex(data: local &[u8]) String
// Writes the SHA-384 digest of `data` as hex into `out`; see `hash_hex_in`.
+ fn sha384_hex_in(data: local &[u8], out: local mut &[u8]) uint
// Writes the SHA-384 digest of `data` as lowercase hex to `out`; returns the bytes written.
+ fn sha384_hex_into(data: local &[u8], out: Writer) uint !io:IoError
// Returns the SHA-512 digest of `data` as lowercase hex.
+ fn sha512_hex(data: local &[u8]) String
// Writes the SHA-512 digest of `data` as hex into `out`; see `hash_hex_in`.
+ fn sha512_hex_in(data: local &[u8], out: local mut &[u8]) uint
// Writes the SHA-512 digest of `data` as lowercase hex to `out`; returns the bytes written.
+ fn sha512_hex_into(data: local &[u8], out: Writer) uint !io:IoError
// Decrypts what `seal` returned, with the same `key` and `aad`.
+ fn unseal(key: local &[u8], sealed: local &[u8], aad: local &[u8] ("")) String !CipherError
```

### base64_decode

Decodes standard base64 (`+` and `/`) into the raw bytes it represents.

The `=` padding is optional, and line breaks (`\n`, `\r`), as in PEM and MIME bodies,
are skipped. Throws `invalid_input` on any other character (including spaces and the
URL-safe `-` and `_`), on an impossible length, or when the unused bits of the last
character are not zero.

### base64_decode_in

Decodes standard base64 into `out` and returns the bytes written.

`out` must hold at least `base64_decoded_size(data.length)` bytes; a shorter buffer
panics. Accepts the same input as `base64_decode` and throws `invalid_input` the same way.

### base64_decode_into

Decodes standard base64 into `out` and returns the bytes written.

Accepts the same input as `base64_decode`, decoded in blocks of 504 characters. Throws
`invalid_input` on malformed input and `write` when `out` fails; blocks decoded before
the error have already been written.

### base64_decoded_size

Returns the most bytes that `length` base64 characters can decode to.

### base64_encode

Returns `data` encoded as standard base64 (`+` and `/`), `=` padded, without line breaks.

### base64_encode_in

Writes `data` encoded as standard padded base64 into `out` and returns the bytes written.

`out` must hold at least `base64_encoded_size(data.length)` bytes; a shorter buffer panics.

### base64_encode_into

Writes `data` encoded as standard padded base64 to `out` and returns the bytes written.

The input is encoded in blocks of 504 bytes, so memory use does not grow with `data`.

### base64_encoded_size

Returns the number of base64 characters that encode `length` bytes, padding included.

### base64url_decode

Decodes URL-safe base64 (`-` and `_`), with or without `=` padding.

Throws `invalid_input` on the standard alphabet's `+` and `/`, and on anything
`base64_decode` rejects.

### base64url_encode

Returns `data` encoded as URL-safe base64 (`-` and `_`) without `=` padding, the form JWT,
JWK and WebAuthn use.

### bcrypt

Computes the bcrypt hash of `password` with the given `cost` and `salt` into `output`.

`salt` must be exactly 16 raw bytes and `cost` within 4..31, otherwise throws
`invalid_input`. `output` is cleared first and receives the 60-character `$2a$` hash
string. Most callers want `bcrypt_hash`, which generates the salt.

### bcrypt_hash

Hashes `password` with bcrypt and a fresh random salt, for storing credentials.

Returns the 60-character `$2a$` hash string, which embeds the cost and salt; check a
password against it with `bcrypt_verify`. Each step up in `cost` doubles the work.
Only the first 72 bytes of `password` affect the hash. Throws `invalid_input` when
`cost` is outside 4..31.

### bcrypt_verify

Returns whether `password` matches the bcrypt `hash` string.

Accepts `$2a$`, `$2b$` and `$2y$` hashes. A malformed hash, or one with a cost outside
4..31, returns false. The comparison runs in constant time.

### cipher_key_size

Returns the key size in bytes that `cipher` takes: 16 for AES-128-GCM, 32 for the others.

### constant_time_equals

Returns whether `a` and `b` hold the same bytes, in time that depends only on their length.

Use it to compare MACs and tokens without leaking where they differ. Different lengths
return false immediately.

### decrypt

Decrypts `ciphertext`, as returned by `encrypt`, with the same `key`, `nonce` and `aad`.

Throws `auth` when the tag does not match: the ciphertext, the tag or `aad` was altered,
or the key or nonce differs. Nothing is returned in that case. Throws `invalid_input` when
the key or nonce has the wrong size.

### digest_size

Returns the digest size in bytes of `algorithm`.

### ecdsa_signature_from_raw

Converts a fixed-size ECDSA signature (`r` and `s` side by side, as in JWT) into the DER
form `verify` takes.

Throws `invalid_input` when `raw` is empty or has an odd length.

### ecdsa_signature_to_raw

Converts a DER encoded ECDSA signature, as `sign` returns it, into the fixed-size form
JWT and WebCrypto use: `r` and `s` side by side, each as long as the curve's size.

Throws `invalid_input` when `der` is not an ECDSA signature for `curve`.

### encrypt

Encrypts `plaintext` with `key` and the 12-byte `nonce`, and returns the ciphertext with
the 16-byte tag appended.

`aad` is additional data that is authenticated but not encrypted, such as a header; the
same bytes must be given to `decrypt`. A nonce must never be used twice with the same key:
use a counter, or `seal`, which picks a random one. Throws `invalid_input` when the key or
nonce has the wrong size.

### hash

Returns the raw digest of `data` as binary bytes (not text).

### hash_hex

Returns the digest of `data` as lowercase hex.

### hash_hex_in

Writes the digest of `data` as lowercase hex into `out` and returns the bytes written.

`out` must hold at least `2 * digest_size(algorithm)` bytes; a shorter buffer panics.

### hash_hex_into

Writes the digest of `data` as lowercase hex to `out` and returns the bytes written.

### hash_in

Writes the raw digest of `data` into `out` and returns the bytes written.

`out` must hold at least `digest_size(algorithm)` bytes; a shorter buffer panics.

### hash_into

Writes the raw digest of `data` to `out` and returns the bytes written.

### hasher

Returns a fresh `Hasher` for `algorithm`.

### hex_decode

Decodes hex text (either case) into the raw bytes it represents.

Throws `invalid_input` on an odd length or a non-hex character.

### hex_decode_in

Decodes hex text (either case) into `out` and returns the bytes written.

`out` must hold at least `text.length / 2` bytes; a shorter buffer panics. Throws
`invalid_input` on an odd length or a non-hex character.

### hex_decode_into

Decodes hex text (either case) into `out` and returns the bytes written.

Output is buffered in 512-byte chunks. Throws `invalid_input` on an odd length or a
non-hex character, and `write` when `out` fails; chunks decoded before the error have
already been written.

### hex_encode

Returns `data` encoded as lowercase hex, two characters per byte.

### hex_encode_in

Writes `data` as lowercase hex into `out` and returns the bytes written.

`out` must hold at least `2 * data.length` bytes; a shorter buffer panics.

### hex_encode_into

Writes `data` as lowercase hex to `out` and returns the bytes written.

Output is buffered in 512-byte chunks, so memory use does not grow with `data`.

### hkdf

Derives `length` bytes from `ikm` with HKDF (RFC 5869): extract with `salt`, expand with `info`.

Throws `invalid_input` when `length` is zero or more than 255 digests long.

### hkdf_expand

Returns `length` bytes of HKDF-Expand (RFC 5869) output from the pseudorandom key `prk`.

Throws `invalid_input` when `length` is zero or more than 255 digests long.

### hkdf_extract

Returns the HKDF-Extract (RFC 5869) pseudorandom key of `ikm` under `salt`.

An empty `salt` is allowed. The result is raw bytes, one digest long.

### md5_hex

Returns the MD5 digest of `data` as lowercase hex.

### md5_hex_in

Writes the MD5 digest of `data` as hex into `out`; see `hash_hex_in`.

### md5_hex_into

Writes the MD5 digest of `data` as lowercase hex to `out`; returns the bytes written.

### pbkdf2

Derives `length` bytes from `password` and `salt` with PBKDF2-HMAC (RFC 8018).

Throws `invalid_input` when `iterations` or `length` is zero. For storing passwords
prefer `bcrypt_hash`; PBKDF2 is for interoperability and for turning a password into a key.

### random_bytes

Returns a string of `length` cryptographically secure random bytes.

The bytes are raw binary, not valid UTF-8 text; encode them (e.g. with `hex_encode` or
`base64_encode`) before printing.

### random_bytes_in

Fills all of `out` with cryptographically secure random bytes and returns its length.

### random_bytes_into

Writes `length` cryptographically secure random bytes to `out`; returns the bytes written.

The bytes are generated and written in chunks of 512, so memory use does not grow with
`length`. Errors from `out` are passed on.

### seal

Encrypts `plaintext` with AES-256-GCM under the 32-byte `key` and a random nonce, and
returns the nonce, ciphertext and tag together, ready for `unseal`.

Suited to encrypted cookies, tokens and stored secrets. With random nonces one key should
seal no more than a few billion messages. Throws `invalid_input` when the key is not 32
bytes.

### sha1_hex

Returns the SHA-1 digest of `data` as lowercase hex.

### sha1_hex_in

Writes the SHA-1 digest of `data` as hex into `out`; see `hash_hex_in`.

### sha1_hex_into

Writes the SHA-1 digest of `data` as lowercase hex to `out`; returns the bytes written.

### sha256_hex

Returns the SHA-256 digest of `data` as lowercase hex.

### sha256_hex_in

Writes the SHA-256 digest of `data` as hex into `out`; see `hash_hex_in`.

### sha256_hex_into

Writes the SHA-256 digest of `data` as lowercase hex to `out`; returns the bytes written.

### sha384_hex

Returns the SHA-384 digest of `data` as lowercase hex.

### sha384_hex_in

Writes the SHA-384 digest of `data` as hex into `out`; see `hash_hex_in`.

### sha384_hex_into

Writes the SHA-384 digest of `data` as lowercase hex to `out`; returns the bytes written.

### sha512_hex

Returns the SHA-512 digest of `data` as lowercase hex.

### sha512_hex_in

Writes the SHA-512 digest of `data` as hex into `out`; see `hash_hex_in`.

### sha512_hex_into

Writes the SHA-512 digest of `data` as lowercase hex to `out`; returns the bytes written.

### unseal

Decrypts what `seal` returned, with the same `key` and `aad`.

Throws `auth` when the data was altered or sealed with another key, and `invalid_input`
when the key is not 32 bytes.

## Classes for 'crypto'

```js
// A streaming BLAKE2b hash with a digest of 1 to 64 bytes and an optional key.
+ class Blake2b {
    // Writes the `hash_size`-byte digest to the start of `out`.
    + fn finalize(out: local mut &[u8]) void
    // Returns the 64-byte BLAKE2b digest of `input` as 128 hex characters.
    + static fn hash_string(input: local &[u8], key: ?String (null), lowercase: bool (true)) String !CryptoError
    // Returns a BLAKE2b hasher producing `hash_size` bytes, keyed with `key` when given.
    + static fn new(hash_size: uint, key: ?String (null)) Blake2b !CryptoError
    // Feeds more input into the hash.
    + fn update(input: local &[u8]) void
}
```

### Blake2b

A streaming BLAKE2b hash with a digest of 1 to 64 bytes and an optional key.

Create it with `Blake2b.new`, feed input with `update`, then call `finalize` once. It
does not implement `Hasher` and cannot be reset.

#### finalize

Writes the `hash_size`-byte digest to the start of `out`.

Panics when `out` is shorter than `hash_size` bytes. The hasher must not be used after
this call.

#### hash_string

Returns the 64-byte BLAKE2b digest of `input` as 128 hex characters.

`key` switches to keyed (MAC) mode; `lowercase` picks the hex case. Throws
`invalid_input` when `key` is longer than 64 bytes.

#### new

Returns a BLAKE2b hasher producing `hash_size` bytes, keyed with `key` when given.

Throws `invalid_input` when `hash_size` is 0 or above 64, or `key` is over 64 bytes.

#### update

Feeds more input into the hash.

```js
// A streaming hash function: feed input with `update`, then read the digest with `finish`.
+ interface Hasher {
    // Returns the size in bytes of the blocks the hash function processes (64 or 128).
    + fn block_size() uint
    // Returns the digest size in bytes.
    + fn digest_size() uint
    // Writes the digest into `out` and returns its size in bytes.
    + fn finish(out: local mut &[u8]) uint
    // Returns the hasher to its initial state, discarding all input fed so far.
    + fn reset() void
    // Feeds more input into the hash.
    + fn update(data: local &[u8]) void
}
```

### Hasher

A streaming hash function: feed input with `update`, then read the digest with `finish`.

Implemented by `Md5`, `Sha1`, `Sha256`, `Sha512` (also SHA-384) and `Hmac`.

#### block_size

Returns the size in bytes of the blocks the hash function processes (64 or 128).

#### digest_size

Returns the digest size in bytes.

#### finish

Writes the digest into `out` and returns its size in bytes.

`out` must hold at least `digest_size()` bytes. The hasher must be `reset` before it is
used again.

#### reset

Returns the hasher to its initial state, discarding all input fed so far.

#### update

Feeds more input into the hash.

```js
// A streaming HMAC (RFC 2104) over any `HashAlgorithm`, usable wherever a `Hasher` is.
+ class Hmac is Hasher {
    // Returns the block size in bytes of the underlying hash.
    + fn block_size() uint
    // Returns the MAC size in bytes, the digest size of the underlying hash.
    + fn digest_size() uint
    // Writes the MAC into `out` and returns its size in bytes.
    + fn finish(out: local mut &[u8]) uint
    // Returns an HMAC ready for input, keyed with `key`.
    + static fn new(algorithm: HashAlgorithm, key: local &[u8]) Hmac
    // Discards all input and starts a new MAC with the same key.
    + fn reset() void
    // Returns the raw MAC of `data` under `key` as binary bytes (not text).
    + static fn sign(algorithm: HashAlgorithm, key: local &[u8], data: local &[u8]) String
    // Returns the MAC of `data` under `key` as lowercase hex.
    + static fn sign_hex(algorithm: HashAlgorithm, key: local &[u8], data: local &[u8]) String
    // Feeds more input into the MAC.
    + fn update(data: local &[u8]) void
    // Returns whether `mac` is the raw MAC of `data` under `key`, compared in constant time.
    + static fn verify(algorithm: HashAlgorithm, key: local &[u8], data: local &[u8], mac: local &[u8]) bool
}
```

### Hmac

A streaming HMAC (RFC 2104) over any `HashAlgorithm`, usable wherever a `Hasher` is.

#### block_size

Returns the block size in bytes of the underlying hash.

#### digest_size

Returns the MAC size in bytes, the digest size of the underlying hash.

#### finish

Writes the MAC into `out` and returns its size in bytes.

`out` must hold at least `digest_size()` bytes. Call `reset` before computing another MAC
with the same key.

#### new

Returns an HMAC ready for input, keyed with `key`.

A key longer than the hash's block size is hashed first, as the RFC specifies.

#### reset

Discards all input and starts a new MAC with the same key.

#### sign

Returns the raw MAC of `data` under `key` as binary bytes (not text).

#### sign_hex

Returns the MAC of `data` under `key` as lowercase hex.

#### update

Feeds more input into the MAC.

#### verify

Returns whether `mac` is the raw MAC of `data` under `key`, compared in constant time.

`mac` must be raw bytes; decode a hex MAC with `hex_decode` first.

```js
// A streaming MD5 `Hasher`; a literal `Md5 {}` is ready for input.
+ class Md5 is Hasher {
    // Returns 64, the MD5 block size in bytes.
    + fn block_size() uint
    // Returns 16, the MD5 digest size in bytes.
    + fn digest_size() uint
    // Writes the 16-byte digest into `out` and returns 16.
    + fn finish(out: local mut &[u8]) uint
    // Returns the hasher to its initial state, discarding all input fed so far.
    + fn reset() void
    // Feeds more input into the hash.
    + fn update(data: local &[u8]) void
}
```

### Md5

A streaming MD5 `Hasher`; a literal `Md5 {}` is ready for input.

MD5 is broken for collision resistance; use it only for checksums and compatibility.

#### block_size

Returns 64, the MD5 block size in bytes.

#### digest_size

Returns 16, the MD5 digest size in bytes.

#### finish

Writes the 16-byte digest into `out` and returns 16.

`out` must hold at least 16 bytes. Call `reset` before hashing new input.

#### reset

Returns the hasher to its initial state, discarding all input fed so far.

#### update

Feeds more input into the hash.

```js
// A private key for signing: RSA, ECDSA or Ed25519.
+ class PrivateKey {
    // Returns the key size in bits: the modulus for RSA, the curve size for EC, 253 for Ed25519.
    + fn bits() uint
    // Reads a DER private key, PKCS#8 or the older RSA and EC forms.
    + static fn from_der(der: local &[u8]) PrivateKey !KeyError
    // Returns the Ed25519 key whose 32-byte private seed is `seed`.
    + static fn from_ed25519_seed(seed: local &[u8]) PrivateKey !KeyError
    // Reads a PEM private key: PKCS#8 (`BEGIN PRIVATE KEY`, or `ENCRYPTED PRIVATE KEY` with `password`) or the older RSA and EC forms.
    + static fn from_pem(pem: String, password: String ("")) PrivateKey !KeyError
    // Generates an ECDSA key on `curve`.
    + static fn generate_ec(curve: Curve (Curve.p256)) PrivateKey !KeyError
    // Generates an Ed25519 key.
    + static fn generate_ed25519() PrivateKey !KeyError
    // Generates an RSA key of `bits` bits, 2048 to 16384.
    + static fn generate_rsa(bits: uint (2048)) PrivateKey !KeyError
    // Returns the kind of key.
    + fn key_type() KeyType
    // Returns the public half of the key.
    + fn public_key() PublicKey !KeyError
    // Signs `data` with `algorithm` and returns the signature.
    + fn sign(algorithm: SignatureAlgorithm, data: local &[u8]) String !KeyError
    // Returns the key as unencrypted PKCS#8 PEM text (`BEGIN PRIVATE KEY`).
    + fn to_pem() String !KeyError
}
```

### PrivateKey

A private key for signing: RSA, ECDSA or Ed25519.

Create one with `generate_rsa`, `generate_ec` or `generate_ed25519`, or read one with
`from_pem`. A key can be shared between threads.

#### bits

Returns the key size in bits: the modulus for RSA, the curve size for EC, 253 for Ed25519.

#### from_der

Reads a DER private key, PKCS#8 or the older RSA and EC forms.

Throws `key` when `der` holds no readable key of a supported type.

#### from_ed25519_seed

Returns the Ed25519 key whose 32-byte private seed is `seed`.

Throws `invalid_input` when `seed` is not 32 bytes.

#### from_pem

Reads a PEM private key: PKCS#8 (`BEGIN PRIVATE KEY`, or `ENCRYPTED PRIVATE KEY` with
`password`) or the older RSA and EC forms.

Throws `key` when the text holds no readable key, the password is wrong, or the key is
not RSA, EC or Ed25519.

#### generate_ec

Generates an ECDSA key on `curve`.

#### generate_ed25519

Generates an Ed25519 key.

#### generate_rsa

Generates an RSA key of `bits` bits, 2048 to 16384.

Throws `invalid_input` for a size outside that range. Keys of 3072 bits and more take
noticeably longer to generate.

#### key_type

Returns the kind of key.

#### public_key

Returns the public half of the key.

#### sign

Signs `data` with `algorithm` and returns the signature.

ECDSA signatures are DER encoded, as OpenSSL and most other libraries use them;
`ecdsa_signature_to_raw` gives the fixed-size form of JWT and WebCrypto. Throws `key`
when the algorithm does not fit the key, such as an RSA algorithm with an EC key.

#### to_pem

Returns the key as unencrypted PKCS#8 PEM text (`BEGIN PRIVATE KEY`).

```js
// A public key for checking signatures: RSA, ECDSA or Ed25519.
+ class PublicKey {
    // Returns the key size in bits: the modulus for RSA, the curve size for EC, 253 for Ed25519.
    + fn bits() uint
    // Reads a DER public key in the SubjectPublicKeyInfo form.
    + static fn from_der(der: local &[u8]) PublicKey !KeyError
    // Returns the Ed25519 public key with the 32 bytes `raw`.
    + static fn from_ed25519(raw: local &[u8]) PublicKey !KeyError
    // Reads a public key in JSON Web Key form (RFC 7517), as found in the JWKS documents of OAuth and OpenID providers.
    + static fn from_jwk(jwk: String) PublicKey !KeyError
    // Reads a PEM public key (`BEGIN PUBLIC KEY`) or the key of a certificate (`BEGIN CERTIFICATE`).
    + static fn from_pem(pem: String) PublicKey !KeyError
    // Returns the kind of key.
    + fn key_type() KeyType
    // Returns the key as PEM text (`BEGIN PUBLIC KEY`).
    + fn to_pem() String !KeyError
    // Returns whether `signature` is a valid signature of `data` by this key with `algorithm`.
    + fn verify(algorithm: SignatureAlgorithm, data: local &[u8], signature: local &[u8]) bool
}
```

### PublicKey

A public key for checking signatures: RSA, ECDSA or Ed25519.

Read one with `from_pem`, `from_der` or `from_jwk`, or take it from a `PrivateKey`. A key
can be shared between threads.

#### bits

Returns the key size in bits: the modulus for RSA, the curve size for EC, 253 for Ed25519.

#### from_der

Reads a DER public key in the SubjectPublicKeyInfo form.

Throws `key` when `der` holds no readable key of a supported type.

#### from_ed25519

Returns the Ed25519 public key with the 32 bytes `raw`.

Throws `invalid_input` when `raw` is not 32 bytes.

#### from_jwk

Reads a public key in JSON Web Key form (RFC 7517), as found in the JWKS documents of
OAuth and OpenID providers.

Supports `kty` `RSA` (`n`, `e`), `EC` (`crv` P-256, P-384 or P-521, `x`, `y`) and `OKP`
(`crv` Ed25519, `x`). Other members, such as `kid` and `alg`, are left for the caller.
Throws `key` for anything else.

#### from_pem

Reads a PEM public key (`BEGIN PUBLIC KEY`) or the key of a certificate
(`BEGIN CERTIFICATE`).

The certificate itself is not checked. Throws `key` when the text holds no readable key
of a supported type.

#### key_type

Returns the kind of key.

#### to_pem

Returns the key as PEM text (`BEGIN PUBLIC KEY`).

#### verify

Returns whether `signature` is a valid signature of `data` by this key with `algorithm`.

ECDSA signatures must be DER encoded; convert a raw one with
`ecdsa_signature_from_raw` first. RSA-PSS accepts any salt length. An algorithm that
does not fit the key gives false.

```js
// A streaming SHA-1 `Hasher`; a literal `Sha1 {}` is ready for input.
+ class Sha1 is Hasher {
    // Returns 64, the SHA-1 block size in bytes.
    + fn block_size() uint
    // Returns 20, the SHA-1 digest size in bytes.
    + fn digest_size() uint
    // Writes the 20-byte digest into `out` and returns 20.
    + fn finish(out: local mut &[u8]) uint
    // Returns the hasher to its initial state, discarding all input fed so far.
    + fn reset() void
    // Feeds more input into the hash.
    + fn update(data: local &[u8]) void
}
```

### Sha1

A streaming SHA-1 `Hasher`; a literal `Sha1 {}` is ready for input.

SHA-1 is broken for collision resistance; use it only for checksums and compatibility.

#### block_size

Returns 64, the SHA-1 block size in bytes.

#### digest_size

Returns 20, the SHA-1 digest size in bytes.

#### finish

Writes the 20-byte digest into `out` and returns 20.

`out` must hold at least 20 bytes. Call `reset` before hashing new input.

#### reset

Returns the hasher to its initial state, discarding all input fed so far.

#### update

Feeds more input into the hash.

```js
// A streaming SHA-256 `Hasher`; a literal `Sha256 {}` is ready for input.
+ class Sha256 is Hasher {
    // Returns 64, the SHA-256 block size in bytes.
    + fn block_size() uint
    // Returns 32, the SHA-256 digest size in bytes.
    + fn digest_size() uint
    // Writes the 32-byte digest into `out` and returns 32.
    + fn finish(out: local mut &[u8]) uint
    // Returns the hasher to its initial state, discarding all input fed so far.
    + fn reset() void
    // Feeds more input into the hash.
    + fn update(data: local &[u8]) void
}
```

### Sha256

A streaming SHA-256 `Hasher`; a literal `Sha256 {}` is ready for input.

#### block_size

Returns 64, the SHA-256 block size in bytes.

#### digest_size

Returns 32, the SHA-256 digest size in bytes.

#### finish

Writes the 32-byte digest into `out` and returns 32.

`out` must hold at least 32 bytes. Call `reset` before hashing new input.

#### reset

Returns the hasher to its initial state, discarding all input fed so far.

#### update

Feeds more input into the hash.

```js
// A streaming SHA-512 or SHA-384 `Hasher`.
+ class Sha512 is Hasher {
    // Returns 128, the SHA-512 block size in bytes.
    + fn block_size() uint
    // Returns the digest size in bytes: 64 for SHA-512, 48 for SHA-384.
    + fn digest_size() uint
    // Writes the digest into `out` and returns its size in bytes.
    + fn finish(out: local mut &[u8]) uint
    // Returns the hasher to its initial state for its variant, discarding all input fed so far.
    + fn reset() void
    // Returns a hasher that computes SHA-384.
    + static fn sha384() Sha512
    // Feeds more input into the hash.
    + fn update(data: local &[u8]) void
}
```

### Sha512

A streaming SHA-512 or SHA-384 `Hasher`.

A literal `Sha512 {}` computes SHA-512; `Sha512.sha384()` returns one that computes SHA-384.

#### block_size

Returns 128, the SHA-512 block size in bytes.

#### digest_size

Returns the digest size in bytes: 64 for SHA-512, 48 for SHA-384.

#### finish

Writes the digest into `out` and returns its size in bytes.

`out` must hold at least `digest_size()` bytes. Call `reset` before hashing new input.

#### reset

Returns the hasher to its initial state for its variant, discarding all input fed so far.

#### sha384

Returns a hasher that computes SHA-384.

#### update

Feeds more input into the hash.

# ext

## Aliases for 'ext'

```js
alias DIR for ptr
alias FILE for ptr
type libc_addrinfo (libc_gen_addrinfo)
alias libc_addrinfo_fix for libc_gen_addrinfo
type libc_dirent (libc_gen_dirent)
type libc_jmp_buf (libc_gen___jmp_buf_tag)
type libc_pollfd (libc_gen_pollfd)
type libc_sockaddr (libc_gen_sockaddr)
type libc_stat (libc_gen_stat)
type libc_timespec (libc_gen_timespec)
type libc_timeval (libc_gen_timeval)
type libc_timezone (libc_gen_timezone)
alias pid_t for i32
```

## Functions for 'ext'

```js
// Returns the calling thread's C `errno` value.
+ fn get_errno() i32
// Sets the calling thread's C `errno` to `value`.
+ fn set_errno(value: i32) void
```

### get_errno

Returns the calling thread's C `errno` value.

### set_errno

Sets the calling thread's C `errno` to `value`.

## Classes for 'ext'

```js
// Mirrors liburing `struct io_uring`: one ring, set up by `io_uring_queue_init`; used by `io` and `coro` on Linux.
+ struct io_uring {
    // Completion queue.
    + cq: io_uring_cq
    // `IORING_FEAT_*` bits reported by the kernel.
    + features: u32
    // Setup flags (`IORING_SETUP_*`).
    + flags: u32
    // liburing-internal fields (`enter_ring_fd`, `int_flags`) and padding.
    + pad: [u32 x 3]
    // File descriptor of the ring.
    + ring_fd: i32
    // Submission queue.
    + sq: io_uring_sq
}
```

### io_uring

Mirrors liburing `struct io_uring`: one ring, set up by `io_uring_queue_init`; used
by `io` and `coro` on Linux.

#### cq

Completion queue.

#### features

`IORING_FEAT_*` bits reported by the kernel.

#### flags

Setup flags (`IORING_SETUP_*`).

#### pad

liburing-internal fields (`enter_ring_fd`, `int_flags`) and padding.

#### ring_fd

File descriptor of the ring.

#### sq

Submission queue.

```js
// Mirrors liburing `struct io_uring_cq`: the completion ring's mapped pointers.
+ struct io_uring_cq {
    // The completion queue entries.
    + cqes: *io_uring_cqe
    // `IORING_CQ_*` flags.
    + kflags: *u32
    // Head index, advanced by the application as it consumes completions.
    + khead: *u32
    // Number of completions dropped because the ring was full.
    + koverflow: *u32
    // Number of ring entries.
    + kring_entries: *u32
    // Mask that turns an index into a ring slot.
    + kring_mask: *u32
    // Tail index, advanced by the kernel as it posts completions.
    + ktail: *u32
    // Cached ring mask/entry count and padding, used by liburing.
    + pad: [u32 x 4]
    // Start of the mmap'd ring.
    + ring_ptr: ptr
    // Size of the mmap'd ring in bytes.
    + ring_sz: uint
}
```

### io_uring_cq

Mirrors liburing `struct io_uring_cq`: the completion ring's mapped pointers.

#### cqes

The completion queue entries.

#### kflags

`IORING_CQ_*` flags.

#### khead

Head index, advanced by the application as it consumes completions.

#### koverflow

Number of completions dropped because the ring was full.

#### kring_entries

Number of ring entries.

#### kring_mask

Mask that turns an index into a ring slot.

#### ktail

Tail index, advanced by the kernel as it posts completions.

#### pad

Cached ring mask/entry count and padding, used by liburing.

#### ring_ptr

Start of the mmap'd ring.

#### ring_sz

Size of the mmap'd ring in bytes.

```js
// Mirrors the kernel `struct io_uring_cqe`: one completion queue entry.
+ struct io_uring_cqe {
    // `IORING_CQE_F_*` flags.
    + flags: u32
    // Result: the operation's return value, or a negative errno.
    + res: i32
    // The `user_data` of the submission this completes.
    + user_data: u64
}
```

### io_uring_cqe

Mirrors the kernel `struct io_uring_cqe`: one completion queue entry.

#### flags

`IORING_CQE_F_*` flags.

#### res

Result: the operation's return value, or a negative errno.

#### user_data

The `user_data` of the submission this completes.

```js
// Mirrors liburing `struct io_uring_sq`: the submission ring's mapped pointers and local state.
+ struct io_uring_sq {
    // Index array mapping ring slots to entries in `sqes`.
    + array: *u32
    // Number of invalid entries the kernel dropped.
    + kdropped: *u32
    // `IORING_SQ_*` status flags (e.g. `IORING_SQ_NEED_WAKEUP`).
    + kflags: *u32
    // Head index, advanced by the kernel as it consumes entries.
    + khead: *u32
    // Number of ring entries.
    + kring_entries: *u32
    // Mask that turns an index into a ring slot.
    + kring_mask: *u32
    // Tail index, advanced by the application to submit.
    + ktail: *u32
    // Cached ring mask/entry count and padding, used by liburing.
    + pad: [u32 x 4]
    // Start of the mmap'd ring.
    + ring_ptr: ptr
    // Size of the mmap'd ring in bytes.
    + ring_sz: uint
    // Local head: first entry not yet submitted to the kernel.
    + sqe_head: u32
    // Local tail: next entry `io_uring_get_sqe` hands out.
    + sqe_tail: u32
    // The submission queue entries.
    + sqes: *io_uring_sqe
}
```

### io_uring_sq

Mirrors liburing `struct io_uring_sq`: the submission ring's mapped pointers
and local state.

#### array

Index array mapping ring slots to entries in `sqes`.

#### kdropped

Number of invalid entries the kernel dropped.

#### kflags

`IORING_SQ_*` status flags (e.g. `IORING_SQ_NEED_WAKEUP`).

#### khead

Head index, advanced by the kernel as it consumes entries.

#### kring_entries

Number of ring entries.

#### kring_mask

Mask that turns an index into a ring slot.

#### ktail

Tail index, advanced by the application to submit.

#### pad

Cached ring mask/entry count and padding, used by liburing.

#### ring_ptr

Start of the mmap'd ring.

#### ring_sz

Size of the mmap'd ring in bytes.

#### sqe_head

Local head: first entry not yet submitted to the kernel.

#### sqe_tail

Local tail: next entry `io_uring_get_sqe` hands out.

#### sqes

The submission queue entries.

```js
// Mirrors the kernel `struct io_uring_sqe` (64 bytes): one submission queue entry, filled in by `io`.
+ struct io_uring_sqe {
    // Buffer address or pointer argument; aka `splice_off_in`.
    + addr: u64
    // Registered buffer index; aka `buf_group` with buffer selection.
    + buf_index: u16
    // Target file descriptor, or a registered file index with `IOSQE_FIXED_FILE`.
    + fd: i32
    // Direct descriptor slot; aka `splice_fd_in`.
    + file_index: u32
    // `IOSQE_*` flags.
    + flags: u8
    // I/O priority; some operations reuse it for their own flags.
    + ioprio: u16
    // Buffer size in bytes, or number of iovecs.
    + len: u32
    // File offset; aka `addr2`.
    + off: u64
    // Operation (`IORING_OP`).
    + opcode: u8
    // `addr3` and trailing padding.
    + pad2: [u64 x 2]
    // Registered credentials ID, 0 for the current ones.
    + personality: u16
    // Per-operation flags (`rw_flags`, `msg_flags`, `accept_flags`, ...).
    + rw_flags: u32
    // Opaque value copied to the completion's `user_data`.
    + user_data: u64
}
```

### io_uring_sqe

Mirrors the kernel `struct io_uring_sqe` (64 bytes): one submission queue entry,
filled in by `io`.

#### addr

Buffer address or pointer argument; aka `splice_off_in`.

#### buf_index

Registered buffer index; aka `buf_group` with buffer selection.

#### fd

Target file descriptor, or a registered file index with `IOSQE_FIXED_FILE`.

#### file_index

Direct descriptor slot; aka `splice_fd_in`.

#### flags

`IOSQE_*` flags.

#### ioprio

I/O priority; some operations reuse it for their own flags.

#### len

Buffer size in bytes, or number of iovecs.

#### off

File offset; aka `addr2`.

#### opcode

Operation (`IORING_OP`).

#### pad2

`addr3` and trailing padding.

#### personality

Registered credentials ID, 0 for the current ones.

#### rw_flags

Per-operation flags (`rw_flags`, `msg_flags`, `accept_flags`, ...).

#### user_data

Opaque value copied to the completion's `user_data`.

```js
// Mirrors glibc `struct __jmp_buf_tag` (one `jmp_buf`) on linux-x64; aliased as `libc_jmp_buf`.
+ struct libc_gen___jmp_buf_tag {
    // Saved registers.
    + __jmpbuf: [int x 8]
    // Nonzero when `__saved_mask` holds a mask saved by `sigsetjmp`.
    + __mask_was_saved: i32
    // Signal mask saved by `sigsetjmp`.
    + __saved_mask: libc_gen_anon_struct_2
}
```

### libc_gen___jmp_buf_tag

Mirrors glibc `struct __jmp_buf_tag` (one `jmp_buf`) on linux-x64; aliased as
`libc_jmp_buf`.

#### __jmpbuf

Saved registers.

#### __mask_was_saved

Nonzero when `__saved_mask` holds a mask saved by `sigsetjmp`.

#### __saved_mask

Signal mask saved by `sigsetjmp`.

```js
// Mirrors glibc `struct addrinfo` on linux-x64; aliased as `libc_addrinfo` and `libc_addrinfo_fix`, used by `getaddrinfo` in `net`.
+ struct libc_gen_addrinfo {
    // The socket address.
    + ai_addr: *libc_gen_sockaddr
    // Length of `ai_addr` in bytes.
    + ai_addrlen: u32
    // Canonical host name (only with `AI_CANONNAME`), otherwise null.
    + ai_canonname: ?cstring
    // Address family (`AF_*`).
    + ai_family: i32
    // `AI_*` flags.
    + ai_flags: i32
    // Next result in the list, null on the last one.
    + ai_next: ?*libc_gen_addrinfo
    // Protocol (`IPPROTO_*`), 0 for any.
    + ai_protocol: i32
    // Socket type (`SOCK_*`).
    + ai_socktype: i32
}
```

### libc_gen_addrinfo

Mirrors glibc `struct addrinfo` on linux-x64; aliased as `libc_addrinfo` and
`libc_addrinfo_fix`, used by `getaddrinfo` in `net`.

#### ai_addr

The socket address.

#### ai_addrlen

Length of `ai_addr` in bytes.

#### ai_canonname

Canonical host name (only with `AI_CANONNAME`), otherwise null.

#### ai_family

Address family (`AF_*`).

#### ai_flags

`AI_*` flags.

#### ai_next

Next result in the list, null on the last one.

#### ai_protocol

Protocol (`IPPROTO_*`), 0 for any.

#### ai_socktype

Socket type (`SOCK_*`).

```js
// Mirrors glibc `__sigset_t` (1024 signal bits); the saved mask in `libc_gen___jmp_buf_tag`.
+ struct libc_gen_anon_struct_2 {
    // Signal bits, one per signal number.
    + __val: [uint x 16]
}
```

### libc_gen_anon_struct_2

Mirrors glibc `__sigset_t` (1024 signal bits); the saved mask in
`libc_gen___jmp_buf_tag`.

#### __val

Signal bits, one per signal number.

```js
// Mirrors glibc `struct dirent` on linux-x64; aliased as `libc_dirent`, returned by `readdir`.
+ struct libc_gen_dirent {
    // Inode number.
    + d_ino: uint
    // Null-terminated file name.
    + d_name: [i8 x 256]
    // Opaque position of the next entry (a `telldir` value).
    + d_off: int
    // Length of this record in bytes.
    + d_reclen: u16
    // File type (`DT_*`), or `DT_UNKNOWN` when the file system does not say.
    + d_type: u8
}
```

### libc_gen_dirent

Mirrors glibc `struct dirent` on linux-x64; aliased as `libc_dirent`, returned
by `readdir`.

#### d_ino

Inode number.

#### d_name

Null-terminated file name.

#### d_off

Opaque position of the next entry (a `telldir` value).

#### d_reclen

Length of this record in bytes.

#### d_type

File type (`DT_*`), or `DT_UNKNOWN` when the file system does not say.

```js
// Mirrors `struct pollfd` on linux-x64; aliased as `libc_pollfd`, passed to `poll`.
+ struct libc_gen_pollfd {
    // Requested events (`POLLIN`, `POLLOUT`, ...).
    + events: i16
    // File descriptor to watch; negative entries are ignored.
    + fd: i32
    // Events that occurred, filled in by `poll`.
    + revents: i16
}
```

### libc_gen_pollfd

Mirrors `struct pollfd` on linux-x64; aliased as `libc_pollfd`, passed to `poll`.

#### events

Requested events (`POLLIN`, `POLLOUT`, ...).

#### fd

File descriptor to watch; negative entries are ignored.

#### revents

Events that occurred, filled in by `poll`.

```js
// Mirrors the generic `struct sockaddr` on linux-x64; aliased as `libc_sockaddr`.
+ struct libc_gen_sockaddr {
    // Family-specific address bytes.
    + sa_data: [i8 x 14]
    // Address family (`AF_*`).
    + sa_family: u16
}
```

### libc_gen_sockaddr

Mirrors the generic `struct sockaddr` on linux-x64; aliased as `libc_sockaddr`.

#### sa_data

Family-specific address bytes.

#### sa_family

Address family (`AF_*`).

```js
// Mirrors glibc `struct stat` on linux-x64; aliased as `libc_stat`, filled by `stat`/`fstat`/`lstat` in `fs`.
+ struct libc_gen_stat {
    // Reserved.
    + __glibc_reserved: [int x 3]
    // Padding.
    + __pad0: i32
    // Time of last access.
    + st_atim: libc_gen_timespec
    // Preferred block size for file system I/O, in bytes.
    + st_blksize: int
    // Number of 512-byte blocks allocated.
    + st_blocks: int
    // Time of last status change.
    + st_ctim: libc_gen_timespec
    // ID of the device containing the file.
    + st_dev: uint
    // Owner group ID.
    + st_gid: u32
    // Inode number.
    + st_ino: uint
    // File type and permission bits (`S_IF*` and mode bits).
    + st_mode: u32
    // Time of last modification.
    + st_mtim: libc_gen_timespec
    // Number of hard links.
    + st_nlink: uint
    // Device ID, for character and block special files.
    + st_rdev: uint
    // Size in bytes (for a symlink: length of the target path).
    + st_size: int
    // Owner user ID.
    + st_uid: u32
}
```

### libc_gen_stat

Mirrors glibc `struct stat` on linux-x64; aliased as `libc_stat`, filled by
`stat`/`fstat`/`lstat` in `fs`.

#### __glibc_reserved

Reserved.

#### __pad0

Padding.

#### st_atim

Time of last access.

#### st_blksize

Preferred block size for file system I/O, in bytes.

#### st_blocks

Number of 512-byte blocks allocated.

#### st_ctim

Time of last status change.

#### st_dev

ID of the device containing the file.

#### st_gid

Owner group ID.

#### st_ino

Inode number.

#### st_mode

File type and permission bits (`S_IF*` and mode bits).

#### st_mtim

Time of last modification.

#### st_nlink

Number of hard links.

#### st_rdev

Device ID, for character and block special files.

#### st_size

Size in bytes (for a symlink: length of the target path).

#### st_uid

Owner user ID.

```js
// Mirrors `struct timespec` on linux-x64; aliased as `libc_timespec`.
+ struct libc_gen_timespec {
    // Nanoseconds, 0 to 999,999,999.
    + tv_nsec: int
    // Whole seconds.
    + tv_sec: int
}
```

### libc_gen_timespec

Mirrors `struct timespec` on linux-x64; aliased as `libc_timespec`.

#### tv_nsec

Nanoseconds, 0 to 999,999,999.

#### tv_sec

Whole seconds.

```js
// Mirrors `struct timeval` on linux-x64; aliased as `libc_timeval`.
+ struct libc_gen_timeval {
    // Whole seconds.
    + tv_sec: int
    // Microseconds, 0 to 999,999.
    + tv_usec: int
}
```

### libc_gen_timeval

Mirrors `struct timeval` on linux-x64; aliased as `libc_timeval`.

#### tv_sec

Whole seconds.

#### tv_usec

Microseconds, 0 to 999,999.

```js
// Mirrors `struct timezone` for `gettimeofday` (obsolete; normally all zero).
+ struct libc_gen_timezone {
    // Type of DST correction; nonzero if DST is ever in effect.
    + tz_dsttime: i32
    // Minutes west of Greenwich.
    + tz_minuteswest: i32
}
```

### libc_gen_timezone

Mirrors `struct timezone` for `gettimeofday` (obsolete; normally all zero).

#### tz_dsttime

Type of DST correction; nonzero if DST is ever in effect.

#### tz_minuteswest

Minutes west of Greenwich.

```js
// Opaque storage for glibc `pthread_attr_t` (64 bytes, C needs 56); `gc` fills it with `pthread_getattr_np` to find a thread's stack.
+ struct pthread_attr_t {
    // Opaque attribute bytes, zero by default.
    + data: [uint x 8]
}
```

### pthread_attr_t

Opaque storage for glibc `pthread_attr_t` (64 bytes, C needs 56); `gc` fills it
with `pthread_getattr_np` to find a thread's stack.

#### data

Opaque attribute bytes, zero by default.

```js
// Opaque storage for a `pthread_cond_t`; initialize with `pthread_cond_init`.
+ struct pthread_cond_t {
    // Opaque condition variable bytes, zero by default.
    + data: [uint x 12]
}
```

### pthread_cond_t

Opaque storage for a `pthread_cond_t`; initialize with `pthread_cond_init`.

96 bytes, more than the C type needs (48 on Linux and macOS).

#### data

Opaque condition variable bytes, zero by default.

```js
// Mirrors glibc `pthread_condattr_t` on Linux; `thread` uses it to make timed waits use `CLOCK_MONOTONIC`.
+ struct pthread_condattr_t {
    // Opaque attribute bits.
    + data: i32
}
```

### pthread_condattr_t

Mirrors glibc `pthread_condattr_t` on Linux; `thread` uses it to make timed
waits use `CLOCK_MONOTONIC`.

#### data

Opaque attribute bits.

```js
// Opaque storage for a `pthread_mutex_t`; initialize with `pthread_mutex_init`.
+ struct pthread_mutex_t {
    // Opaque mutex bytes, zero by default.
    + data: [uint x 10]
}
```

### pthread_mutex_t

Opaque storage for a `pthread_mutex_t`; initialize with `pthread_mutex_init`.

80 bytes, more than the C type needs (40 on linux-x64, 64 on macOS).

#### data

Opaque mutex bytes, zero by default.

```js
// Holds a `pthread_t` thread handle, filled by `pthread_create`; used by `thread` and `core`.
+ struct pthread_t {
    // The handle (an integer on Linux, a pointer on macOS).
    + data: uint
}
```

### pthread_t

Holds a `pthread_t` thread handle, filled by `pthread_create`; used by `thread` and
`core`.

#### data

The handle (an integer on Linux, a pointer on macOS).

```js
// Mirrors glibc `struct sigaction` on linux-x64; passed to `sigaction` by `coro` (stack overflow handler) and `signal`.
+ struct sigaction_t {
    // `SA_*` flags, e.g. `SA_SIGINFO`, `SA_ONSTACK`.
    + flags: i32
    // Handler (`sa_handler`, or `sa_sigaction` with `SA_SIGINFO`); 0 is `SIG_DFL`, 1 is `SIG_IGN`.
    + handler: ptr
    // Signals blocked while the handler runs (`sa_mask`, a 1024-bit `sigset_t`).
    + mask: [u64 x 16]
    // `sa_restorer`; filled in by libc, leave null.
    + restorer: ?ptr
}
```

### sigaction_t

Mirrors glibc `struct sigaction` on linux-x64; passed to `sigaction` by `coro`
(stack overflow handler) and `signal`.

#### flags

`SA_*` flags, e.g. `SA_SIGINFO`, `SA_ONSTACK`.

#### handler

Handler (`sa_handler`, or `sa_sigaction` with `SA_SIGINFO`); 0 is `SIG_DFL`, 1 is `SIG_IGN`.

#### mask

Signals blocked while the handler runs (`sa_mask`, a 1024-bit `sigset_t`).

#### restorer

`sa_restorer`; filled in by libc, leave null.

```js
// Mirrors glibc `stack_t` on Linux: the alternate signal stack passed to `sigaltstack` by `coro`.
+ struct stack_t {
    // `SS_*` flags (`ss_flags`); 0 enables the stack.
    + flags: i32
    // Size of the stack in bytes (`ss_size`).
    + size: uint
    // Lowest address of the stack memory (`ss_sp`).
    + sp: ptr
}
```

### stack_t

Mirrors glibc `stack_t` on Linux: the alternate signal stack passed to `sigaltstack`
by `coro`.

#### flags

`SS_*` flags (`ss_flags`); 0 enables the stack.

#### size

Size of the stack in bytes (`ss_size`).

#### sp

Lowest address of the stack memory (`ss_sp`).

# fs

## Aliases for 'fs'

```js
// The path separator of the target OS: `\` on Windows, `/` elsewhere.
+ value PATH_DIV ("/")
// `PATH_DIV` followed by `.`.
+ value PATH_DIV_DOT ("/.")
// The other platform's separator: `\` outside Windows, where it is an ordinary name byte.
+ value PATH_DIV_REPLACE ("\\")
// Two path separators, as at the start of a UNC path.
+ value PATH_DIV_TWICE ("//")
// `.` followed by `PATH_DIV`: the relative prefix for the current directory.
+ value PATH_DOT_DIV ("./")
// Buffer length used when asking the OS for a path; longer paths fail with `.os`.
+ value PATH_MAX (4096)
```

### PATH_DIV

The path separator of the target OS: `\` on Windows, `/` elsewhere.

### PATH_DIV_DOT

`PATH_DIV` followed by `.`.

### PATH_DIV_REPLACE

The other platform's separator: `\` outside Windows, where it is an ordinary name byte.

### PATH_DIV_TWICE

Two path separators, as at the start of a UNC path.

### PATH_DOT_DIV

`.` followed by `PATH_DIV`: the relative prefix for the current directory.

### PATH_MAX

Buffer length used when asking the OS for a path; longer paths fail with `.os`.

Counted in bytes, or in UTF-16 units on Windows.

## Enums for 'fs'

```js
// The kind of file system entry reported by `stat`.
+ enum FileKind { file, directory, other }
// How `open` treats the contents of a file it opens for writing.
+ enum WriteMode { preserve, truncate, append }
```

### FileKind

The kind of file system entry reported by `stat`.

### WriteMode

How `open` treats the contents of a file it opens for writing.

## Functions for 'fs'

```js
// Joins `dir` and `fn` with exactly one separator between them.
+ fn add(dir: String, fn: String) String
// Returns the last component of `path`, ignoring trailing separators.
+ fn basename(path: String) String
// Changes the current working directory of the process to `path`.
+ fn chdir(path: String) void !io:IoError
// Sets the permission bits of the file at `path`, such as `0c644`.
+ fn chmod(path: String, permissions: u32) void !io:IoError
// Copies the file or directory at `from_path` to `to_path`.
+ fn copy(from_path: String, to_path: String, recursive: bool (false)) void !io:IoError
// Creates the directory `path`; its parent must already exist.
+ fn create_dir(path: String, permissions: u32 (0c755)) void !io:IoError
// Creates the directory `path` and every missing parent, like `mkdir -p`.
+ fn create_dir_all(path: String, permissions: u32 (0c755)) void !io:IoError
// Creates a new, empty directory with a unique name and returns its path.
+ fn create_temp_dir(prefix: String ("tmp-"), dir: ?String (null)) String !io:IoError
// Creates a new, empty file with a unique name and returns its path.
+ fn create_temp_file(prefix: String ("tmp-"), suffix: String (""), dir: ?String (null)) String !io:IoError
// Returns the current working directory.
+ fn cwd() String !io:IoError
// Deletes `path` and, when it is a directory, everything inside it.
+ fn delete_all(path: String) void !io:IoError
// Deletes the empty directory `path`; `delete_all` also removes a non-empty one.
+ fn delete_dir(path: String) void !io:IoError
// Deletes the file at `path`; directories need `delete_dir` or `delete_all`.
+ fn delete_file(path: String) void !io:IoError
// Returns `path` without its last component.
+ fn dir_of(path: String) String
// Returns the directory that contains the running executable; cached after the first call.
+ fn exe_dir() String !io:IoError
// Returns the absolute path of the running executable.
+ fn exe_path() String !io:IoError
// Returns whether anything exists at `path`.
+ fn exists(path: String) bool
// Returns the extension of the last path component, without the dot unless `with_dot` is set.
+ fn extension(path: String, with_dot: bool (false)) String
// Lists the entries of `dir` as full paths, or as names relative to `dir` when `relative` is set.
+ fn files_in(dir: String, recursive: bool (false), files: bool (true), dirs: bool (true), relative: bool (false)) Array[String] !io:IoError
// Returns the paths that match `pattern`, sorted.
+ fn glob(pattern: String) Array[String]
// Returns the home directory of the current user: `$HOME`, or `%USERPROFILE%` on Windows.
+ fn home_dir() String !LookupError
// Returns whether `path` is a directory; a symlink to one counts.
+ fn is_dir(path: String) bool
// Returns whether `path` is a regular file; a symlink to one counts.
+ fn is_file(path: String) bool
// Returns whether `path` is a symbolic link, without following it.
+ fn is_symlink(path: String) bool
// Takes a lock on the file at `path`, creating the file when it is missing, and returns it; also `FileLock.new`.
+ fn lock(path: String, exclusive: bool (true), timeout_ms: uint (0)) FileLock !io:IoError
// Returns the MIME type for a file extension given without the dot, such as `png`.
+ fn mime_type(ext_without_dot: String) String
// Returns the last modification time of `path` in nanoseconds since the Unix epoch.
+ fn modified_time(path: String) uint !io:IoError
// Moves or renames `from_path` to `to_path`.
+ fn move(from_path: String, to_path: String) void !io:IoError
// Opens the file at `path` and returns its raw descriptor.
+ fn open(path: String, options: ?OpenOptions (null)) i32 !io:IoError
// Returns `path` as a `Path`, for chaining path methods.
+ fn path(path: String) Path
// Reads the whole file at `path` into a string.
+ fn read(path: String) String !io:IoError
// Opens the directory `path` for iterating over its entries.
+ fn read_dir(path: String) DirIterator !io:IoError
// Writes the whole file at `path` to `out` in chunks of `chunk_size` bytes and returns the bytes written; the file is never held in memory as a whole.
+ fn read_into(path: String, out: Writer, chunk_size: uint (65536)) uint !io:IoError
// Returns the absolute path of `path` with symlinks resolved.
+ fn realpath(path: String) String !io:IoError
// Returns `path` as seen from the directory `base`, such as `../b/c` for `/a/b/c` from `/a/d`.
+ fn relative(path: String, base: String) String
// Makes `path` absolute and folds `.`, `..` and repeated separators.
+ fn resolve(path: String) String
// Returns the size in bytes of the entry at `path`, following symlinks.
+ fn size(path: String) uint !io:IoError
// Returns the metadata of the entry at `path`, following symlinks.
+ fn stat(path: String) FileInfo !io:IoError
// Opens the file at `path` as a `FileStream`, read-only by default.
+ fn stream(path: String, options: ?OpenOptions (null)) FileStream !io:IoError
// Creates a symbolic link at `link` that points to `target`.
+ fn symlink(link: String, target: String, is_directory: bool (false)) void !io:IoError
// Asks the OS to flush all file system buffers to disk (`sync(2)`).
+ fn sync_all() void
// Returns the directory for temporary files.
+ fn temp_dir() String
// Resizes the file at `path` to `length` bytes, cutting it off or padding it with zeros.
+ fn truncate(path: String, length: uint) void !io:IoError
// Takes the lock only when it is free right now, else returns `null`; see `lock`.
+ fn try_lock(path: String, exclusive: bool (true)) ?FileLock !io:IoError
// Writes `content` to the file at `path`, creating the file when it is missing.
+ fn write(path: String, content: local &[u8], append: bool (false)) void !io:IoError
// Writes everything `source` yields to the file at `path`, in chunks of `chunk_size` bytes, and returns the bytes written; the file is created when it is missing and replaced unless `append` is set.
+ fn write_from(path: String, source: Reader, append: bool (false), chunk_size: uint (65536)) uint !io:IoError
```

### add

Joins `dir` and `fn` with exactly one separator between them.

Either platform's separator is recognized at the joint; a missing one is added as
`PATH_DIV`. A run of separators at the joint is collapsed to one separator: `PATH_DIV`
when the run holds it, otherwise the run's own last byte, so a run of the other kind
comes through as written. An empty `dir` gives `fn` unchanged, and a `dir` of nothing but
separators is kept whole so a root stays a root (`//` and `C:\` keep every separator
they have).

### basename

Returns the last component of `path`, ignoring trailing separators.

`/etc/nginx/` gives `nginx`, `/` gives `""` and a path without any separator comes back
whole (`nginx.conf` gives `nginx.conf`). Both `/` and `\` count as separators on every OS.

### chdir

Changes the current working directory of the process to `path`.

Throws `.os` on failure.

### chmod

Sets the permission bits of the file at `path`, such as `0c644`.

Throws `.access` on failure. On Windows only the owner-write bit (`0c200`) is honored:
without it the file becomes read-only.

### copy

Copies the file or directory at `from_path` to `to_path`.

A file copy overwrites `to_path`. On Linux and macOS the copy gets the permission bits
(`0c777`) of the source, like `cp`.
For a directory, `to_path` is created when missing (`.open` when it exists and is not a
directory) and the files directly inside are copied; subdirectories are copied only when
`recursive` is set. Symlinks inside a directory are recreated as symlinks with the same
target, replacing a symlink already at the destination (a Windows junction becomes a
directory symlink); copying a symlink itself as `from_path` throws `.access`. Copying a
path onto itself does nothing.

### create_dir

Creates the directory `path`; its parent must already exist.

`permissions` applies before the umask and is ignored on Windows. Throws `.exists` when
something already exists at `path` and `.access` on any other failure.

### create_dir_all

Creates the directory `path` and every missing parent, like `mkdir -p`.

Succeeds when the directory already exists. `permissions` applies to every directory it
creates, before the umask, and is ignored on Windows. Throws `.exists` when a file is in
the way and `.access` on any other failure.

### create_temp_dir

Creates a new, empty directory with a unique name and returns its path.

The name is `prefix` followed by random characters, inside `dir` or else `temp_dir()`. On
Linux and macOS only the current user may enter it (`0c700`). Remove it with `delete_all`
when done. Throws `.access` when it cannot be created.

### create_temp_file

Creates a new, empty file with a unique name and returns its path.

The name is `prefix`, random characters and `suffix` (such as `.json`), inside `dir` or
else `temp_dir()`. On Linux and macOS only the current user may read it (`0c600`). Throws
`.open` when it cannot be created.

### cwd

Returns the current working directory.

Throws `.os` on failure.

### delete_all

Deletes `path` and, when it is a directory, everything inside it.

Symlinks (and junctions on Windows) are removed themselves; their targets are left alone.
Stops at the first failure and leaves the rest in place. Throws `.access` when an entry
cannot be deleted, including when `path` does not exist, and `.open` or `.read` when a
directory cannot be listed.

### delete_dir

Deletes the empty directory `path`; `delete_all` also removes a non-empty one.

Throws `.access` on failure.

### delete_file

Deletes the file at `path`; directories need `delete_dir` or `delete_all`.

Throws `.access` on failure, including when nothing exists at `path`.

### dir_of

Returns `path` without its last component.

A trailing separator is ignored (`/etc/nginx/` gives `/etc`) and `/etc` gives `/`. A run of
separators counts as one, so `a//b` gives `a` and `/a//` gives `/`. A path without a
separator gives `.` (`etc` gives `.`), a path of separators stays itself (`/` gives `/`, and
on Windows `C:\etc`, `C:\` and `C:` give `C:\`, `C:\` and `C:`), and `""` gives `""`.
Both `/` and `\` count as separators on every OS.

### exe_dir

Returns the directory that contains the running executable; cached after the first call.

Throws `.os` when the executable's path cannot be determined.

### exe_path

Returns the absolute path of the running executable.

Symlinks are resolved on Linux and macOS. Throws `.os` when the OS cannot report the path.

### exists

Returns whether anything exists at `path`.

On Linux and macOS symlinks are followed, so a dangling link reports `false`; on Windows it
reports `true`.

### extension

Returns the extension of the last path component, without the dot unless `with_dot` is set.

Returns `""` when there is none. Only the part after the last `.` counts (`a.tar.gz` gives
`gz`). Leading dots of the name do not start an extension, so a hidden file such as
`.bashrc` has none, while `.config.json` gives `json`.

### files_in

Lists the entries of `dir` as full paths, or as names relative to `dir` when `relative` is set.

`files` and `dirs` select which kinds are included. `recursive` also lists the contents of
each subdirectory, after the subdirectory itself, but does not descend into symlinked
directories. Full paths start with `resolve(dir)`. The order is the file system's, not
sorted. Throws `.open` or `.read` when a directory cannot be read.

### glob

Returns the paths that match `pattern`, sorted.

In a pattern `*` matches any run of characters within one name, `?` one character,
`[abc]`, `[a-z]` and `[!a]` one character of a set, and a `**` segment any number of
directories, also none: `src/**/*.valk`. A wildcard does not match the leading `.` of a
hidden name unless the pattern writes the `.`, and `**` does not enter hidden or
symlinked directories. A relative pattern is taken against `cwd()` and gives relative
paths. Directories that cannot be read are skipped, so there is no error; a pattern that
matches nothing gives an empty array. On Windows names match without regard to case and
either separator may be used.

### home_dir

Returns the home directory of the current user: `$HOME`, or `%USERPROFILE%` on Windows.

Throws `.missing` when the variable is not set.

### is_dir

Returns whether `path` is a directory; a symlink to one counts.

### is_file

Returns whether `path` is a regular file; a symlink to one counts.

On Windows anything that exists and is not a directory counts as a file.

### is_symlink

Returns whether `path` is a symbolic link, without following it.

### lock

Takes a lock on the file at `path`, creating the file when it is missing, and
returns it; also `FileLock.new`.

An exclusive lock (the default) excludes every other lock on the file; a shared one
coexists with other shared locks and excludes exclusive ones. Locks are advisory: they
only affect other `lock` / `try_lock` callers (and other programs using the same OS
mechanism, `flock` or `LockFileEx`), never plain reads and writes. Two locks taken in
one process conflict like locks from two processes. `timeout_ms` 0 waits forever.
Throws `open` when the file cannot be opened or created, `timeout` when `timeout_ms`
passes first, and `os` when the system refuses.

### mime_type

Returns the MIME type for a file extension given without the dot, such as `png`.

Unknown extensions give `application/octet-stream`. The lookup ignores case, so `PNG`
gives `image/png`.

### modified_time

Returns the last modification time of `path` in nanoseconds since the Unix epoch.

Follows symlinks. Throws `.open` when `path` cannot be inspected.

### move

Moves or renames `from_path` to `to_path`.

Throws `.access` on failure. On Linux and macOS an existing file at `to_path` is replaced and
moving to another file system fails; on Windows the move fails when `to_path` exists.

### open

Opens the file at `path` and returns its raw descriptor.

Close the descriptor with `io.close`; `stream` wraps it in a `FileStream` that tracks the
position instead. Throws `.open` when the options conflict (neither `read` nor `write`,
`create` without `write`, `exclusive` without `create`) or the OS refuses. On Windows the
handle is opened for overlapped I/O, and other handles may only read the file while it is
open. In `WriteMode.append` every write goes to the end of the file on every OS.

### path

Returns `path` as a `Path`, for chaining path methods.

### read

Reads the whole file at `path` into a string.

Reads until the end of the file, so files that report size 0 (such as those in `/proc`)
and files that grow meanwhile are read completely. Throws `.open` or `.read`.

### read_dir

Opens the directory `path` for iterating over its entries.

Throws `.open` when it cannot be opened. The iterator closes itself at the end or when it
is garbage-collected; call `close` to release it earlier.

### read_into

Writes the whole file at `path` to `out` in chunks of `chunk_size` bytes and returns the
bytes written; the file is never held in memory as a whole.

Throws `.open` when the file cannot be opened, `.read` when reading fails and the
writer's error when `out` fails; bytes written before a failure stay written.

### realpath

Returns the absolute path of `path` with symlinks resolved.

On Linux and macOS a `path` that does not exist comes back unchanged, so the result may be
relative, and a `\` is part of a name there, not a separator. On Windows the path is made
absolute and normalized, but symlinks are not resolved. Throws `.os` on failure.

### relative

Returns `path` as seen from the directory `base`, such as `../b/c` for `/a/b/c` from `/a/d`.

Both are resolved first, without following symlinks. Gives `.` when they are the same, and
the resolved `path` when no relative path leads there (another drive on Windows, where
names compare without regard to case).

### resolve

Makes `path` absolute and folds `.`, `..` and repeated separators.

The file system is not consulted, so symlinks are not followed; `realpath` follows them. A
relative path is taken against `cwd()`, and it panics when that fails. On Windows either
separator is accepted and becomes `\`, and a path whose second byte is `:` is absolute (a
drive); on Linux and macOS only `/` separates and `\` and `:` are ordinary name bytes.
Trailing separators are dropped, except at the root: `..` at the root stays at the root,
and a Windows drive root resolves to `C:\`.

### size

Returns the size in bytes of the entry at `path`, following symlinks.

Throws `.open` when `path` cannot be inspected.

### stat

Returns the metadata of the entry at `path`, following symlinks.

Throws `.open` when `path` cannot be inspected.

### stream

Opens the file at `path` as a `FileStream`, read-only by default.

`options` work as for `open`. Throws `.open` when the file cannot be opened.

### symlink

Creates a symbolic link at `link` that points to `target`.

`target` is stored as given, so a relative target resolves against the link's directory.
`is_directory` only matters on Windows, where directory links are marked as such. Throws
`.access` when not permitted, `.exists` when `link` already exists and `.write` otherwise.

### sync_all

Asks the OS to flush all file system buffers to disk (`sync(2)`).

On Windows it calls `FlushFileBuffers` on each fixed and removable volume, which needs
administrator rights; volumes that cannot be opened are skipped.

### temp_dir

Returns the directory for temporary files.

On Linux and macOS that is `TMPDIR`, or `/tmp` when it is not set; on Windows the user's
temp directory (`TMP`, `TEMP` or the Windows default).

### truncate

Resizes the file at `path` to `length` bytes, cutting it off or padding it with zeros.

Throws `.write` when `length` does not fit an `i64` or resizing fails. On Windows `.open`
means the file could not be opened.

### try_lock

Takes the lock only when it is free right now, else returns `null`; see `lock`.

### write

Writes `content` to the file at `path`, creating the file when it is missing.

Replaces the existing contents, or adds to the end when `append` is set. A new file gets
permissions `0c644`. Throws `.open` or `.write`.

### write_from

Writes everything `source` yields to the file at `path`, in chunks of `chunk_size`
bytes, and returns the bytes written; the file is created when it is missing and
replaced unless `append` is set.

Throws `.open` when the file cannot be opened, `.write` when writing fails and the
reader's error when `source` fails; a partly written file is left in place.

## Classes for 'fs'

```js
// An open directory that yields its entry names one by one; see `read_dir`.
+ class DirIterator is Closer {
    // Whether the handle is closed, by `close` or by reaching the end.
    ~ closed: bool

    // Closes the directory handle; calling it again does nothing.
    + fn close() void !io:IoError
    // Returns the next entry name, or `null` once all entries are read.
    + fn next() ?String !io:IoError
    // Writes the next entry name to `out` and returns the bytes written, or `null` once all entries are read; the names are the ones `next` returns.
    + fn next_into(out: Writer) ?uint !io:IoError
}
```

### DirIterator

An open directory that yields its entry names one by one; see `read_dir`.

#### closed

Whether the handle is closed, by `close` or by reaching the end.

#### close

Closes the directory handle; calling it again does nothing.

Throws `.os` when the OS reports a failure.

#### next

Returns the next entry name, or `null` once all entries are read.

Names are bare, not paths, in file system order; `.` and `..` are skipped. Reaching the end
closes the iterator, and later calls keep returning `null`. Throws `.closed` after an
explicit `close` and `.read` when reading fails.

#### next_into

Writes the next entry name to `out` and returns the bytes written, or `null` once all
entries are read; the names are the ones `next` returns.

On Linux and macOS the name is copied from the OS entry straight to `out` through a
stack buffer; on Windows it is converted from UTF-16 first. Throws as `next` does,
and the writer's error when `out` fails.

```js
// Metadata of a file system entry, as returned by `stat`.
+ struct FileInfo {
    // Whether the entry is a file, a directory or something else.
    + kind: FileKind
    // Last modification time in nanoseconds since the Unix epoch.
    + modified_time: uint
    // Permission bits such as `0c644`.
    + permissions: u32
    // Size in bytes.
    + size: uint
}
```

### FileInfo

Metadata of a file system entry, as returned by `stat`.

#### kind

Whether the entry is a file, a directory or something else.

#### modified_time

Last modification time in nanoseconds since the Unix epoch.

#### permissions

Permission bits such as `0c644`.

On Windows they are derived from the attributes: `0c444` for read-only files, `0c666`
otherwise, plus `0c111` for directories.

#### size

Size in bytes.

```js
// A lock on a file, held from `lock` / `try_lock` until `unlock` or collection.
+ class FileLock is Closer {
    // Whether the lock excludes shared locks as well.
    ~ exclusive: bool
    // The descriptor the lock is held through.
    ~ fd: i32
    // The locked file.
    ~ path: String

    // The same as `unlock`.
    + fn close() void !io:IoError
    // Takes a lock on the file at `path`; see `fs.lock`.
    + static fn new(path: String, exclusive: bool (true), timeout_ms: uint (0)) FileLock !io:IoError
    // Takes the lock only when it is free right now, else returns `null`; see `fs.try_lock`.
    + static fn try_new(path: String, exclusive: bool (true)) ?FileLock !io:IoError
    // Releases the lock and closes its descriptor; does nothing when already released.
    + fn unlock() void !io:IoError
}
```

### FileLock

A lock on a file, held from `lock` / `try_lock` until `unlock` or collection.

#### exclusive

Whether the lock excludes shared locks as well.

#### fd

The descriptor the lock is held through.

#### path

The locked file.

#### close

The same as `unlock`.

#### new

Takes a lock on the file at `path`; see `fs.lock`.

#### try_new

Takes the lock only when it is free right now, else returns `null`; see `fs.try_lock`.

#### unlock

Releases the lock and closes its descriptor; does nothing when already released.

Throws `os` when the system reports a failure.

```js
// An open file that reads and writes at a tracked position.
+ class FileStream is Reader, Writer, Seeker, Closer {
    // Whether the stream is closed, by `close` or by reading a read-only stream to the end.
    ~ closed: bool
    // The path the stream was opened with.
    ~ path: String
    // Byte offset of the next read or write.
    ~ position: uint

    // Closes the stream; calling it again does nothing.
    + fn close() void !io:IoError
    // Reads up to `buf.length` bytes at `position` and advances past them.
    + fn read(buf: local mut &[u8]) uint !io:IoError
    // Moves `position` to `offset` bytes from `from` and returns the new position.
    + fn seek(offset: int, from: SeekFrom (io.SeekFrom.start)) uint !io:IoError
    // Flushes the written data to disk.
    + fn sync(data_only: bool (false)) void !io:IoError
    // Writes all of `data` at `position`, advances past it and returns `data.length`.
    + fn write(data: local &[u8]) uint !io:IoError
}
```

### FileStream

An open file that reads and writes at a tracked position.

The descriptor is closed when the stream is garbage-collected if `close` was not called.

#### closed

Whether the stream is closed, by `close` or by reading a read-only stream to the end.

#### path

The path the stream was opened with.

#### position

Byte offset of the next read or write.

#### close

Closes the stream; calling it again does nothing.

Throws `.os` when the OS reports a failure.

#### read

Reads up to `buf.length` bytes at `position` and advances past them.

Returns 0 at the end of the file. Reaching the end closes a read-only stream to release
its descriptor: later reads return 0, but seeks throw `.closed`. A stream opened for
writing stays open. Throws `.read` when the stream was not opened for reading and
`.closed` after `close`.

#### seek

Moves `position` to `offset` bytes from `from` and returns the new position.

Seeking past the end is allowed. `SeekFrom.end` takes the current size of the open
file. Throws `.range` when the target is before the start or too large, `.os` when the
OS fails, and `.closed` when the stream is closed.

#### sync

Flushes the written data to disk.

`data_only` skips metadata that is not needed to read the data back; only Linux supports
it. Throws `.write` when the stream is not writable or flushing fails.

#### write

Writes all of `data` at `position`, advances past it and returns `data.length`.

In `WriteMode.append` every write goes to the end of the file. Throws `.write` when the
stream was not opened for writing or the OS fails, and `.closed` when it is closed.

```js
// A file held in memory, such as an HTTP upload, with a name and MIME type.
+ class InMemoryFile {
    // The file's bytes.
    ~ data: &[u8]
    // The client's file name for an HTTP upload; empty otherwise.
    ~ filename: String
    // The client's MIME type for an HTTP upload; `application/octet-stream` otherwise.
    ~ mime_type: String

    // Reads the whole file at `path` into memory.
    + static fn from_file(path: String) InMemoryFile !io:IoError
    // Creates a file that holds a private copy of `data`.
    + static fn new(data: local &[u8]) InMemoryFile
    // Returns a `ByteReader` over the bytes, without copying them.
    + fn reader() ByteReader
    // Writes the bytes to `path`, creating the file or replacing its contents.
    + fn save(path: String) void !io:IoError
    // Returns a copy of the bytes as a `String`.
    + fn to_string() String
    // Writes the bytes to `out` and returns the count, without copying them first.
    + fn write_into(out: Writer) uint !io:IoError
}
```

### InMemoryFile

A file held in memory, such as an HTTP upload, with a name and MIME type.

#### data

The file's bytes.

#### filename

The client's file name for an HTTP upload; empty otherwise.

#### mime_type

The client's MIME type for an HTTP upload; `application/octet-stream` otherwise.

#### from_file

Reads the whole file at `path` into memory.

`filename` and `mime_type` keep their defaults. Throws `.open` or `.read`.

#### new

Creates a file that holds a private copy of `data`.

`String` and `ByteBuffer` convert to `&[u8]`, so both can be passed.

#### reader

Returns a `ByteReader` over the bytes, without copying them.

#### save

Writes the bytes to `path`, creating the file or replacing its contents.

Throws `.open` or `.write`.

#### to_string

Returns a copy of the bytes as a `String`.

#### write_into

Writes the bytes to `out` and returns the count, without copying them first.

```js
// Options for `open` and `stream`; the defaults open an existing file read-only.
+ struct OpenOptions {
    // Creates the file when it does not exist; requires `write`.
    + create: bool
    // Fails when the file already exists; requires `create`.
    + exclusive: bool
    // Permission bits of a newly created file, before the umask; ignored on Windows.
    + permissions: u32
    // Opens the file for reading.
    + read: bool
    // Opens the file for writing in the given mode; `null` opens it without write access.
    + write: ?WriteMode
}
```

### OpenOptions

Options for `open` and `stream`; the defaults open an existing file read-only.

#### create

Creates the file when it does not exist; requires `write`.

#### exclusive

Fails when the file already exists; requires `create`.

#### permissions

Permission bits of a newly created file, before the umask; ignored on Windows.

#### read

Opens the file for reading.

#### write

Opens the file for writing in the given mode; `null` opens it without write access.

```js
// A `String` that holds a file system path and offers the path functions as methods.
+ mode Path for String {
    // Returns this path joined with `part`; see `fs.add`.
    + fn add(part: String) Path
    // Returns the parent directory; see `fs.dir_of`.
    + fn dir_of() Path
    // Returns `path` as a `Path`.
    + static fn new(path: String) Path
    // Returns the parent directory; same as `dir_of`.
    + fn pop() Path
    // Returns the absolute, normalized form of this path; see `fs.resolve`.
    + fn resolve() Path
}
```

### Path

A `String` that holds a file system path and offers the path functions as methods.

Converts to and from `String` implicitly.

#### add

Returns this path joined with `part`; see `fs.add`.

#### dir_of

Returns the parent directory; see `fs.dir_of`.

#### new

Returns `path` as a `Path`.

#### pop

Returns the parent directory; same as `dir_of`.

#### resolve

Returns the absolute, normalized form of this path; see `fs.resolve`.

# gc

## Aliases for 'gc'

```js
type EnvCloneFn (fnptr(ptr)(ptr))
// Runs a garbage collection of the calling thread's memory now.
+ value collect (ext.valk_gc_collect)
// Runs a collection of shared memory, stopping every thread's GC while it marks.
+ value collect_shared (ext.valk_gc_collect_shared)
```

### collect

Runs a garbage collection of the calling thread's memory now.

Does nothing while the thread's GC is not enabled yet or is shutting down. Roots are
globals and the words still live on the caller's stack and registers.

### collect_shared

Runs a collection of shared memory, stopping every thread's GC while it marks.

Returns without collecting when another thread completed a shared collection while this
one waited for the shared lock.

## Functions for 'gc'

```js
// Allocates `size` bytes of GC memory whose contents are not scanned for references.
+ fn alloc(size: uint) GcPtr
// Allocates `size` bytes of GC memory whose references are traced through `layout`.
+ fn alloc_typed(size: uint, layout: ?ptr) GcPtr
// Clones a closure environment; used by the compiler when a closure value is copied.
+ fn clone_closure_env(env: ?ptr) ?ptr
// Collects like `collect_if_threshold_reached`, but at three quarters of the way to the trigger.
+ fn collect_if_threshold_almost_reached() void
// Collects the thread's memory when allocation since the last collection reached the trigger.
+ fn collect_if_threshold_reached() void
// Collects shared memory when its usage reached the shared trigger and the GC is idle.
+ fn collect_shared_if_threshold_reached() void
// Takes the calling thread's GC lock again after `unlock`.
+ fn lock() void
// Returns the bytes held by the GC pool blocks of all threads, including free slots.
+ fn mem_usage() uint
// Resets `pause_last_us` and `pause_max_us` of the calling thread to zero.
+ fn reset_pause_durations() void
// Resets `shared_pause_last_us` and `shared_pause_max_us` to zero under the shared lock.
+ fn reset_shared_pause_durations() void
// Moves the references held by `from` into the identically laid out GC allocation `to`.
+ fn transfer_refs(from: ptr, to: ptr) void
// Releases the calling thread's GC lock so other threads can collect for it while it blocks.
+ fn unlock() void
```

### alloc

Allocates `size` bytes of GC memory whose contents are not scanned for references.

A `size` of 0 still returns a valid, distinct allocation (of the smallest size).

### alloc_typed

Allocates `size` bytes of GC memory whose references are traced through `layout`.

`layout` is a compiler-generated reference layout; `null` means nothing is traced.
A `size` of 0 still returns a valid, distinct allocation (of the smallest size).

### clone_closure_env

Clones a closure environment; used by the compiler when a closure value is copied.

An environment allocated for captures is cloned through its pool's hook. A bare receiver
object is shared, not copied, and `null` returns `null`.

### collect_if_threshold_almost_reached

Collects like `collect_if_threshold_reached`, but at three quarters of the way to the trigger.

Useful at idle points such as an event loop iteration, so the collection happens before
an allocation forces it.

### collect_if_threshold_reached

Collects the thread's memory when allocation since the last collection reached the trigger.

After a local collection it also collects shared memory when that has reached its trigger.
Does nothing while a collection is running or the GC is not idle.

### collect_shared_if_threshold_reached

Collects shared memory when its usage reached the shared trigger and the GC is idle.

### lock

Takes the calling thread's GC lock again after `unlock`.

### mem_usage

Returns the bytes held by the GC pool blocks of all threads, including free slots.

### reset_pause_durations

Resets `pause_last_us` and `pause_max_us` of the calling thread to zero.

### reset_shared_pause_durations

Resets `shared_pause_last_us` and `shared_pause_max_us` to zero under the shared lock.

### transfer_refs

Moves the references held by `from` into the identically laid out GC allocation `to`.

The other bytes must already be copied. Used when a growing container moves its
elements to a new block: ownership of the elements moves to `to` without re-marking them,
and `from` keeps its references only as co-owner. Does nothing when `from` has no
reference layout.

### unlock

Releases the calling thread's GC lock so other threads can collect for it while it blocks.

Call it before a blocking operation and `lock` right after. The current stack pointer and
registers are saved for those collections; do not touch GC memory in between.

## Globals for 'gc'

```js
// The collector of the running thread.
~+ global gc : *Gc
// Highest value `mem_usage_shared` has reached since the program started, in bytes.
~+ shared mem_usage_peak : uint
// Bytes currently held by the GC pool blocks of all threads, including free slots.
~+ shared mem_usage_shared : uint
// Duration of this thread's last local collection, in microseconds.
+ global pause_last_us : uint
// Longest local collection on this thread since the last reset, in microseconds.
+ global pause_max_us : uint
// Duration of the last shared-memory collection, in microseconds.
+ shared shared_pause_last_us : uint
// Longest shared-memory collection since the last reset, in microseconds.
+ shared shared_pause_max_us : uint
// Whether each collection runs a leak check over the reachable objects.
+ shared verify : bool
```

### gc

The collector of the running thread.

Collecting shared memory temporarily points it at each thread's gc in turn.

### mem_usage_peak

Highest value `mem_usage_shared` has reached since the program started, in bytes.

### mem_usage_shared

Bytes currently held by the GC pool blocks of all threads, including free slots.

### pause_last_us

Duration of this thread's last local collection, in microseconds.

### pause_max_us

Longest local collection on this thread since the last reset, in microseconds.

### shared_pause_last_us

Duration of the last shared-memory collection, in microseconds.

### shared_pause_max_us

Longest shared-memory collection since the last reset, in microseconds.

### verify

Whether each collection runs a leak check over the reachable objects.

Set at startup: `true` in `GC_DEBUG` builds (such as `make test`), `false` otherwise.

# html

## Functions for 'html'

```js
// Returns `code` with the HTML special characters `<`, `>`, `"`, `'` and `&` as entities.
+ fn escape(code: local &[u8], options: ?EscapeOptions (null)) String
// Writes `code` escaped as `escape` does to `out` and returns the bytes written.
+ fn escape_into(code: local &[u8], out: Writer, options: ?EscapeOptions (null)) uint !io:IoError
// Returns `code` with the value of every URL attribute whose scheme is not allowed emptied.
+ fn sanitize_url_attributes(code: String, allowed_schemes: Array[String] (.{ "http", "https", "mailto" })) String
// Returns whether a URL taken from an HTML attribute uses a scheme in `allowed_schemes`.
+ fn url_is_allowed(target: String, allowed_schemes: Array[String] (.{ "http", "https", "mailto" })) bool
```

### escape

Returns `code` with the HTML special characters `<`, `>`, `"`, `'` and `&` as entities.

The result is safe as element text and inside quoted attribute values. Pass `options` to
leave some of the characters as they are.

### escape_into

Writes `code` escaped as `escape` does to `out` and returns the bytes written.

A `ByteBuffer` is written directly; any other writer receives the escaped text in one
write. Throws when `out` fails.

### sanitize_url_attributes

Returns `code` with the value of every URL attribute whose scheme is not allowed emptied.

URL attributes are `href`, `src`, `action`, `formaction`, `poster`, `cite`,
`background`, `xlink:href`, `data`, `codebase`, `longdesc`, `usemap`, `profile` and
`manifest`; each value is checked with `url_is_allowed`. The attribute itself and its
quotes stay, and a rejected value is emptied: a quoted one keeps its empty quotes, and an
unquoted one gets `""` so the text that followed it cannot become the value.
Nothing else is changed: event handler attributes such as `onclick`,
`<script>` elements, comments and the content of raw text elements pass through as they
are, so this is not a full HTML sanitizer.

### url_is_allowed

Returns whether a URL taken from an HTML attribute uses a scheme in `allowed_schemes`.

The URL is read as a browser would: character references such as `&#106;` and `&colon;`
are decoded, tabs and line breaks are removed and surrounding whitespace is trimmed, so
`java&#x09;script:` is caught. Relative URLs have no scheme and are always allowed.
Schemes compare case-insensitively.

## Classes for 'html'

```js
// Chooses which characters `escape` replaces with HTML entities; all are escaped by default.
+ class EscapeOptions {
    // Replaces `&` with `&amp;`.
    + escape_ampersand: bool
    // Replaces `"` with `&quot;`.
    + escape_double_quote: bool
    // Replaces `>` with `&gt;`.
    + escape_gt: bool
    // Replaces `<` with `&lt;`.
    + escape_lt: bool
    // Replaces `'` with `&#39;`.
    + escape_single_quote: bool
}
```

### EscapeOptions

Chooses which characters `escape` replaces with HTML entities; all are escaped by default.

#### escape_ampersand

Replaces `&` with `&amp;`.

#### escape_double_quote

Replaces `"` with `&quot;`.

#### escape_gt

Replaces `>` with `&gt;`.

#### escape_lt

Replaces `<` with `&lt;`.

#### escape_single_quote

Replaces `'` with `&#39;`.

# http

## Errors for 'http'

```js
// An HTTP/2 framing, HPACK or flow-control violation, found by the HTTP/2 server.
error H2Error (incomplete, protocol, frame_size, flow_control, compression, limit)
// Thrown by the HTTP client and by starting an HTTP server.
error HttpError (invalid_url, invalid_response, in_progress, too_many_redirects, invalid_request, response_too_large, status) extends (net:NetError, HttpParseError)
// Thrown by `parse_http` when HTTP/1.x bytes are not a valid request or response.
error HttpParseError (invalid, http413, http431, incomplete, missing_host_header, not_implemented) extends (io:IoError)
// A router error.
error RouteError (invalid)
// Thrown by `WebSocket` methods.
error WebSocketError (protocol, too_large, handshake, invalid_url, invalid_request) extends (net:NetError)
```

### H2Error

An HTTP/2 framing, HPACK or flow-control violation, found by the HTTP/2 server.

No public function throws it; the server answers with a connection error instead.

- `incomplete`: fewer bytes than a whole frame are buffered.
- `protocol`: a frame breaks RFC 9113 rules (wrong stream id, unexpected frame kind,
  bad padding, invalid SETTINGS value, a zero window increment).
- `frame_size`: a frame is longer than allowed or has the wrong length for its kind.
- `flow_control`: a window would exceed 2^31-1 or received data exceeds the window.
- `compression`: an HPACK header block cannot be decoded.
- `limit`: a header block or header list exceeds the configured size, or a response
  stalls longer than the server's `write_timeout_ms`.

### HttpError

Thrown by the HTTP client and by starting an HTTP server.

- `invalid_url`: the URL is not `http`/`https`, contains credentials, or has an
  unsafe host or an invalid port.
- `invalid_response`: the response could not be parsed, or `ClientRequest.response`
  was called on a request that failed.
- `in_progress`: `ClientRequest.response` was called before the response arrived.
- `too_many_redirects`: a response still redirects after `max_redirects` were followed.
- `invalid_request`: the method, path, query or a header is unsafe to send, or a
  header is one the client sets itself.
- `response_too_large`: the response exceeds `max_response_header_size` or
  `max_response_body_size`.
- `status`: `download` got a final status outside 2xx.

Also carries every `net.NetError` and `HttpParseError` code; the client uses `timeout`,
`read`, `write` and `ssl`; `Server.start` throws `init` when it was started before, when
`http2` is set without TLS or with a fast handler, or when a worker cannot start.

### HttpParseError

Thrown by `parse_http` when HTTP/1.x bytes are not a valid request or response.

- `invalid`: the start line, a header, `Content-Length` or chunked framing is malformed
  or contradictory.
- `http431`: the header section (or the trailers) exceeds `max_header_size`.
- `http413`: the body exceeds `max_body_size`.
- `incomplete`: more input is needed; call again once more bytes arrived.
- `missing_host_header`: an HTTP/1.1 request has no `Host` header.
- `not_implemented`: `Transfer-Encoding` names a coding other than a final `chunked`.

Also carries every `io.IoError` code.

### RouteError

A router error.

- `invalid`: not raised by the standard library.

### WebSocketError

Thrown by `WebSocket` methods.

- `protocol`: the peer sent a frame that breaks RFC 6455 (bad opcode, a fragmented or
  oversized control frame, a text message that is not UTF-8, a missing or unexpected
  mask). The connection is closed with code 1002 or 1007.
- `too_large`: a message exceeds `max_message_size`; closed with code 1009.
- `handshake`: the server did not accept the upgrade, or its answer is not a valid
  WebSocket handshake.
- `invalid_url`: `connect` was given a URL that is not `ws://` or `wss://`.
- `invalid_request`: an extra header given to `connect` is unsafe to send or one the
  client sets itself.

Also carries every `net.NetError` and `io.IoError` code: `closed` once the connection is
closed, from either side, `ssl` for a failed `wss://` handshake, and `timeout`,
`cancelled`, `read` and `write` from the socket.

## Enums for 'http'

```js
// When a browser sends a cookie on a request that another site caused.
+ enum SameSite { lax, strict, none }
// The kind of a WebSocket message.
+ enum WebSocketMessageType { text, binary }
```

### SameSite

When a browser sends a cookie on a request that another site caused.

### WebSocketMessageType

The kind of a WebSocket message.

## Functions for 'http'

```js
// Connects and prepares a request without sending it; drive it with `progress`.
+ fn create_request(method: String, url: String, options: ?Options (null)) ClientRequest !HttpError
// Sends a DELETE request; see `request`.
+ fn delete(url: String, options: ?Options (null)) ClientResponse !HttpError
// Sends a request and writes the response body to the file at `to_path`.
+ fn download(url: String, to_path: String, method: String ("GET"), options: ?Options (null)) void !HttpError
// Returns `date` as an HTTP date: `Sun, 06 Nov 1994 08:49:37 GMT`.
+ fn format_date(date: DateTime) String
// Sends a GET request; see `request`.
+ fn get(url: String, options: ?Options (null)) ClientResponse !HttpError
// Sends a HEAD request; see `request`.
+ fn head(url: String, options: ?Options (null)) ClientResponse !HttpError
// Reads an HTTP date such as `Sun, 06 Nov 1994 08:49:37 GMT`.
+ fn parse_date(text: String) DateTime !SyntaxError
// Sends a PATCH request with `body`; see `post`.
+ fn patch(url: String, body: String, options: ?Options (null)) ClientResponse !HttpError
// Sends a POST request with `body`; see `request`.
+ fn post(url: String, body: String, options: ?Options (null)) ClientResponse !HttpError
// Sends a PUT request with `body`; see `post`.
+ fn put(url: String, body: String, options: ?Options (null)) ClientResponse !HttpError
// Sends a request and returns the final response, following redirects.
+ fn request(method: String, url: String, options: ?Options (null)) ClientResponse !HttpError
// Creates a `Server` with default settings for `handler` and runs it; see `Server.start`.
+ fn serve(host: String, port: u16, handler: shared fn(Request)(Response), worker_count: uint (0)) void !HttpError
// Like `serve`, with a fast handler that writes straight to a `ResponseWriter`.
+ fn serve_fast(host: String, port: u16, handler: shared fn(Context, ResponseWriter)(), worker_count: uint (0)) void !HttpError
```

### create_request

Connects and prepares a request without sending it; drive it with `progress`.

Fails with `invalid_url` for anything but an `http`/`https` URL with a host, a URL
with credentials or an out-of-range port, with `invalid_request` for an invalid
method, path or header, and with the connection/TLS errors of `ClientRequest.create`.
Redirects are not followed.

### delete

Sends a DELETE request; see `request`.

### download

Sends a request and writes the response body to the file at `to_path`.

Redirects are followed as `request` does. The final response must have a 2xx status:
any other status throws `status` (`request` with `Options.output` set to a file gives
the code itself). The file is created or truncated first and removed again when the
download fails, so it only exists after a successful one. The request uses a copy of `options` whose `output` is the file; the
caller's object is not changed. Without `options` the timeout is 30 seconds instead of
the usual 10. Failing to close the file throws `write`.

### format_date

Returns `date` as an HTTP date: `Sun, 06 Nov 1994 08:49:37 GMT`.

The value is read as UTC, which is the only zone HTTP dates are written in.

### get

Sends a GET request; see `request`.

### head

Sends a HEAD request; see `request`.

### parse_date

Reads an HTTP date such as `Sun, 06 Nov 1994 08:49:37 GMT`.

Also accepts the two obsolete forms RFC 9110 asks recipients to read:
`Sunday, 06-Nov-94 08:49:37 GMT` (a two-digit year below 69 is in the 2000s) and
`Sun Nov  6 08:49:37 1994`. Throws `SyntaxError` for anything else.

### patch

Sends a PATCH request with `body`; see `post`.

### post

Sends a POST request with `body`; see `request`.

`body` is stored in `options.body`, so a passed `Options` object is modified.

### put

Sends a PUT request with `body`; see `post`.

### request

Sends a request and returns the final response, following redirects.

Blocks until the response is complete. Any status code is returned as a response;
only transport, protocol, limit and timeout problems throw. Each request uses a new
connection, which is closed afterwards.

```valk
let res = http.request("GET", "https://example.com/") ! panic("request failed")
println(res.status)
```

### serve

Creates a `Server` with default settings for `handler` and runs it; see `Server.start`.

### serve_fast

Like `serve`, with a fast handler that writes straight to a `ResponseWriter`.

It skips building a `Request` and `Response` per call, which mostly matters for
benchmarks.

## Classes for 'http'

```js
// A single HTTP/1.1 request on its own connection, sent and received step by step.
+ class ClientRequest {
    // The number of raw response bytes read so far, head included.
    ~ bytes_received: uint
    // The number of request bytes written so far.
    ~ bytes_sent: uint
    // The size of the complete raw response (head and body) in bytes, like `bytes_received` counts it.
    ~ bytes_to_recv: uint
    // The size of the complete request (head and body) in bytes.
    ~ bytes_to_send: uint
    // The connection the request is sent on; closed once the request has finished.
    ~ con: TcpConnection
    // The buffer that collects the raw response bytes.
    ~ recv_buffer: ByteBuffer
    // The share of the response received so far, from 0 to 100.
    ~ recv_percent: uint
    // Whether the request has been written completely, or the request ended in an error.
    ~ request_sent: bool
    // Whether the request has finished, with a response or with an error.
    ~ response_received: bool
    // The share of the request written so far, from 0 to 100.
    ~ sent_percent: uint

    // Validates the request, connects to the server and builds the request bytes.
    + static fn new(method: String, url: String, options: ?Options (null), deadline_ms: uint (0)) ClientRequest !HttpError
    // Writes or reads the next chunk; returns `true` while there is more to do.
    + fn progress() bool !HttpError
    // Returns the response once `progress` has returned `false`.
    + fn response() ClientResponse !HttpError
}
```

### ClientRequest

A single HTTP/1.1 request on its own connection, sent and received step by step.

`progress` does the work; the progress fields can be read in between, for example
to show a progress bar. Redirects are not followed.

```valk
let req = http.create_request("GET", "http://example.com/") !!
while (req.progress() !!) {
    println("received: %{req.bytes_received}")
}
let res = req.response() !!
```

#### bytes_received

The number of raw response bytes read so far, head included.

#### bytes_sent

The number of request bytes written so far.

#### bytes_to_recv

The size of the complete raw response (head and body) in bytes, like
`bytes_received` counts it.

Known once the head of the final response has arrived and the body length follows
from it (a `Content-Length`, or a response without a body); 0 before that and for
chunked or connection-close delimited bodies. Skipped `1xx` responses are included.

#### bytes_to_send

The size of the complete request (head and body) in bytes.

#### con

The connection the request is sent on; closed once the request has finished.

#### recv_buffer

The buffer that collects the raw response bytes.

#### recv_percent

The share of the response received so far, from 0 to 100.

Compares `bytes_received` with `bytes_to_recv`, so it stays 0 while the size is
unknown; it is set to 100 once the response is complete.

#### request_sent

Whether the request has been written completely, or the request ended in an error.

#### response_received

Whether the request has finished, with a response or with an error.

#### sent_percent

The share of the request written so far, from 0 to 100.

#### new

Validates the request, connects to the server and builds the request bytes.

Nothing is sent yet. `deadline_ms` is an absolute `time.mono_ms()` value for the
whole request; 0 uses `options.timeout_ms` from now. Fails with `invalid_url` for
anything but an `http`/`https` URL with a host, credentials in the URL or a port
outside 1-65535, with `invalid_request` for an invalid method, path or header,
with `ssl` when TLS setup, the handshake or the certificate fingerprint check
fails, and with `timeout` or a connection error when connecting fails.

#### progress

Writes or reads the next chunk; returns `true` while there is more to do.

Blocks on the socket for up to the read or write timeout. Returns `false` once
the final response is complete; `1xx` interim responses are skipped. Errors close
the connection and end the request: `timeout`, `write`, `read` (also for a
connection closed early), `response_too_large` and `invalid_response`.

#### response

Returns the response once `progress` has returned `false`.

Throws `in_progress` while the request is still running and `invalid_response`
when it ended in an error.

```js
// The final response to a client request.
+ class ClientResponse {
    // The response body; empty when it was written to `Options.output` instead.
    + body: String
    // The response headers; names are stored lowercased.
    + headers: Headers
    // The HTTP status code, such as `200` or `404`.
    + status: u16

    // Returns the cookies the server set, in the order it sent them.
    + fn cookies() Array[Cookie]
}
```

### ClientResponse

The final response to a client request.

#### body

The response body; empty when it was written to `Options.output` instead.

#### headers

The response headers; names are stored lowercased.

#### status

The HTTP status code, such as `200` or `404`.

#### cookies

Returns the cookies the server set, in the order it sent them.

A `Set-Cookie` field that does not start with `name=value` is skipped. Nothing is
stored between requests: a client that wants to send these back adds them to the
`Cookie` header of its next request itself.

```js
// The parse state of one HTTP/1.x message; `fast` handlers receive it as the request.
+ class Context {
    // The request method as sent, such as `GET`.
    ~+ method: &[u8]
    // The path of the request target without the query string, not percent-decoded.
    ~+ path: &[u8]
    // The client's address; unset (port 0) for a context that was not accepted by a server.
    ~+ peer_address: SocketAddress
    // The query string without the leading `?`, not decoded; empty when absent.
    ~+ query_string: &[u8]
    // The status code of a parsed response; 0 for a request.
    ~+ status: u16

    // The message body, with chunked encoding removed; empty until the message is complete.
    + get body: String
    // Returns the value of one cookie; throws `LookupError` when the request has no cookie of that name.
    + fn cookie(name: String) String !LookupError
    // Returns the cookies of the request, by name.
    + fn cookies() Map[String]
    // Returns the uploaded files of a `multipart/form-data` body, by field name.
    + fn files() Map[InMemoryFile]
    // Returns the form fields of the request body.
    + fn form() Map[String]
    // Returns the request headers, with names lowercased.
    + fn headers() Headers
    // Returns the request body as JSON.
    + fn json() Value
    // Whether the client expects the connection to stay open after the response.
    + get keep_alive: bool
    // Returns the request body as JSON, like `json()`, but throws when it is not valid JSON.
    + fn parse_json() Value !json:ParseError
    // Returns the query string parameters.
    + fn query() Map[String]
    // Returns every value of each query string parameter, in order.
    + fn query_grouped() Map[Array[String]]
}
```

### Context

The parse state of one HTTP/1.x message; `fast` handlers receive it as the request.

`method`, `path` and `query_string` are views into the connection's input buffer and
are only valid during the handler call; copy them with `to_string()` to keep them.
`headers()`, `query()`, `form()`, `json()` and `files()` parse on first use and
cache the result.

#### method

The request method as sent, such as `GET`.

#### path

The path of the request target without the query string, not percent-decoded.

#### peer_address

The client's address; unset (port 0) for a context that was not accepted by a server.

#### query_string

The query string without the leading `?`, not decoded; empty when absent.

#### status

The status code of a parsed response; 0 for a request.

#### body

The message body, with chunked encoding removed; empty until the message is
complete.

#### cookie

Returns the value of one cookie; throws `LookupError` when the request has no
cookie of that name.

#### cookies

Returns the cookies of the request, by name.

The `Cookie` header is split on `;` only, and a value keeps every `=` after the
first one, so a base64 value arrives whole. Surrounding double quotes are removed.
A browser sends the cookie of the most specific path first, and that is the one
kept when a name is sent more than once.

#### files

Returns the uploaded files of a `multipart/form-data` body, by field name.

A file part without its own `Content-Type` header is skipped.

#### form

Returns the form fields of the request body.

Reads `application/x-www-form-urlencoded` bodies (keys and values decoded),
`multipart/form-data` (file parts go to `files()`) and `application/json` objects.
For JSON, string values are kept, `null` becomes an empty string and every other
value is re-encoded as JSON text. The media type is compared case-insensitively
and without its parameters, so `application/json; charset=utf-8` is read as JSON;
the multipart `boundary` parameter may be quoted. Any other body gives an empty
map.

#### headers

Returns the request headers, with names lowercased.

Leading spaces of values are removed; trailing whitespace is kept.

#### json

Returns the request body as JSON.

Form bodies are turned into an object of string values, see `data()`. Any other
body is decoded as JSON regardless of its content type; a body that is not valid
JSON gives an empty object. `parse_json` throws for such a body instead.

#### keep_alive

Whether the client expects the connection to stay open after the response.

HTTP/1.1 keeps it unless `Connection: close` was sent; HTTP/1.0 only when
`Connection: keep-alive` was sent.

#### parse_json

Returns the request body as JSON, like `json()`, but throws when it is not valid JSON.

Form bodies are turned into an object of string values as `json()` does and never
fail. Any other body must be valid JSON, so an empty body throws too. Throws the
`json.ParseError` of `json.decode`.

```valk
let body = req.parse_json() ! return http.Response.text("Invalid JSON", 400)
```

#### query

Returns the query string parameters.

Keys and values are decoded with `url.decode`. A part without `=`, like `?flag`, has
the value `""`, and for a repeated key the last value wins; see `query_grouped`.

#### query_grouped

Returns every value of each query string parameter, in order.

Decoded like `query`.

```js
// A cookie to send with a response.
+ class Cookie {
    // The hosts the cookie is sent to. Without one it is the host that set it, without its subdomains; with one, that domain and every subdomain of it.
    + domain: ?String
    // The moment the cookie is dropped. A moment in the past deletes it.
    + expires: ?DateTime
    // Keep the cookie away from page scripts (`document.cookie`).
    + http_only: bool
    // How many seconds the cookie lives. `0` deletes it. Browsers prefer this over `expires` when both are given.
    + max_age: ?int
    // The name, which may not be empty or hold a separator.
    + name: String
    // The paths the cookie is sent on; `/` is the whole site.
    + path: String
    // When the cookie is sent on requests another site caused.
    + same_site: SameSite
    // Only send the cookie over HTTPS. Off during plain-HTTP development.
    + secure: bool
    // The value. It is sent as it is, in double quotes when it holds a space or a comma.
    + value: String

    // Whether the cookie can be sent: a name and a value a header can carry.
    + fn is_valid() bool
    // Creates a cookie with `name` and `value`, and the defaults of the class.
    + static fn new(name: String, value: String) Cookie
    // Reads a `Set-Cookie` field value, as a client does.
    + static fn parse(header: String) Cookie !SyntaxError
    // Returns the `Set-Cookie` field value for this cookie.
    + fn to_header() String
}
```

### Cookie

A cookie to send with a response.

`secure`, `http_only` and `SameSite.lax` are on by default: the cookie travels over
HTTPS only, is out of reach of page scripts, and is not sent along by another site.
A cookie that is forgotten about is then the safe one, and a program that wants less
says so.

```valk
let cookie = http.Cookie.new("session", id)
cookie.max_age = 3600
response.set_cookie(cookie)
```

Development over plain HTTP is the one place to turn `secure` off. Browsers make an
exception for `localhost` and keep the cookie there, but on any other plain-HTTP
address, such as a LAN IP or a staging hostname, they drop it without saying so.

#### domain

The hosts the cookie is sent to. Without one it is the host that set it, without
its subdomains; with one, that domain and every subdomain of it.

#### expires

The moment the cookie is dropped. A moment in the past deletes it.

#### http_only

Keep the cookie away from page scripts (`document.cookie`).

#### max_age

How many seconds the cookie lives. `0` deletes it. Browsers prefer this over
`expires` when both are given.

#### name

The name, which may not be empty or hold a separator.

#### path

The paths the cookie is sent on; `/` is the whole site.

#### same_site

When the cookie is sent on requests another site caused.

#### secure

Only send the cookie over HTTPS. Off during plain-HTTP development.

#### value

The value. It is sent as it is, in double quotes when it holds a space or a comma.

#### is_valid

Whether the cookie can be sent: a name and a value a header can carry.

#### new

Creates a cookie with `name` and `value`, and the defaults of the class.

#### parse

Reads a `Set-Cookie` field value, as a client does.

Attributes it does not know are skipped, and so is an `Expires` it cannot read;
`Max-Age` then still says how long the cookie lives. Throws `SyntaxError` when
there is no `name=value` in front.

#### to_header

Returns the `Set-Cookie` field value for this cookie.

Attributes left null are not written. An invalid name or value gives an empty
string, which the server leaves out of the response.

```js
// An ordered list of HTTP header fields with case-insensitive names.
+ class Headers {
    // Adds a field at the end, keeping existing fields with the same name.
    + fn append(name: String, value: String) void
    // Removes every field.
    + fn clear() void
    // Returns an independent copy of the list.
    + fn copy() Headers
    // Returns the value of the first field named `name`; also backs `headers[name]`.
    + fn get(name: String) String !LookupError
    // Returns the values of every field named `name` in order; empty when there is none.
    + fn get_all(name: String) Array[String]
    // Returns whether a field named `name` exists.
    + fn has(name: String) bool
    // The number of fields, repeated names counted separately.
    + get length: uint
    // Creates an empty header list; also backs `Headers{}` and default construction.
    + static fn new() Headers
    // Removes every field named `name`.
    + fn remove(name: String) void
    // Replaces every field named `name` with one field holding `value`.
    + fn set(name: String, value: String) void
}
```

### Headers

An ordered list of HTTP header fields with case-insensitive names.

A name can occur more than once; fields keep the order they were added in and
names keep their original case. `each headers as value, name` visits every field,
repeated ones included. Lookups scan the list, so they are linear in its length.

```valk
let headers = http.Headers{ "Accept" => "application/json" }
headers.append("X-Tag", "first")
let accept = headers["accept"] !? ""
```

#### append

Adds a field at the end, keeping existing fields with the same name.

#### clear

Removes every field.

#### copy

Returns an independent copy of the list.

#### get

Returns the value of the first field named `name`; also backs `headers[name]`.

Throws `missing` when there is none. Repeated fields are never joined; use
`get_all` for those.

#### get_all

Returns the values of every field named `name` in order; empty when there is none.

#### has

Returns whether a field named `name` exists.

#### length

The number of fields, repeated names counted separately.

#### new

Creates an empty header list; also backs `Headers{}` and default construction.

#### remove

Removes every field named `name`.

#### set

Replaces every field named `name` with one field holding `value`.

The new field goes to the end of the list. Also backs `headers[name] = value` and
the `Headers{ name => value }` literal.

```js
// Settings for a client request made with `http.request`, `http.download` or `ClientRequest.create`.
+ class Options {
    // The ALPN protocols offered in the TLS handshake; defaults to `http/1.1`.
    + alpn_protocols: ?Array[String]
    // The request body; sent with a matching `Content-Length`.
    + body: String
    // A CA certificate file to verify the server certificate against.
    + ca_cert_path: ?String
    // The expected SHA-256 fingerprint of the server certificate, in hex.
    + certificate_sha256: ?String
    // A PEM file with the client certificate, sent when the server asks for one (mutual TLS); intermediate certificates may follow it.
    + client_certificate_file: ?String
    // The PEM private key of `client_certificate_file`; `null` reads it from that file.
    + client_key_file: ?String
    // The password of an encrypted client key.
    + client_key_password: String
    // The limit for connecting plus the TLS handshake, in milliseconds.
    + connect_timeout_ms: uint
    // Whether 301, 302, 303, 307 and 308 responses with a `Location` are followed.
    + follow_redirects: bool
    // Extra request headers.
    + headers: ?Headers
    // The number of redirects to follow before failing with `too_many_redirects`.
    + max_redirects: uint
    // The largest accepted response body in bytes, also when it goes to `output`; zero disables the limit.
    + max_response_body_size: uint
    // The largest accepted response head in bytes; zero disables the limit.
    + max_response_header_size: uint
    // The highest TLS version the client offers; `null` leaves it to the TLS library.
    + max_tls_version: ?TlsVersion
    // The lowest TLS version the client accepts.
    + min_tls_version: TlsVersion
    // Receives the response body instead of `ClientResponse.body`.
    + output: ?Writer
    // Parameters appended to the URL's query string, keys and values percent-encoded.
    + query_data: ?Map[String]
    // The limit for each socket read, in milliseconds; `timeout_ms` still applies.
    + read_timeout_ms: uint
    // The limit for the whole request, including redirects, in milliseconds.
    + timeout_ms: uint
    // The OpenSSL cipher list for TLS 1.2 and older.
    + tls_cipher_list: ?String
    // The OpenSSL cipher suites for TLS 1.3.
    + tls_cipher_suites: ?String
    // Whether the server's TLS certificate is verified.
    + verify_tls_cert: bool
    // The limit for each socket write, in milliseconds; `timeout_ms` still applies.
    + write_timeout_ms: uint

    // Removes every header set so far.
    + fn clear_headers() void
    // Returns `headers`, creating an empty set first when it is `null`.
    + fn get_headers() Headers
    // Sets the header `key` to `value`, replacing every existing value for that name.
    + fn set_header(key: String, value: String) void
    // Copies every header in `headers` into this request's headers.
    + fn set_headers(headers: Headers) void
}
```

### Options

Settings for a client request made with `http.request`, `http.download` or
`ClientRequest.create`.

#### alpn_protocols

The ALPN protocols offered in the TLS handshake; defaults to `http/1.1`.

#### body

The request body; sent with a matching `Content-Length`.

#### ca_cert_path

A CA certificate file to verify the server certificate against.

#### certificate_sha256

The expected SHA-256 fingerprint of the server certificate, in hex.

Colons are ignored and case does not matter. A mismatch fails with `ssl`.

#### client_certificate_file

A PEM file with the client certificate, sent when the server asks for one (mutual
TLS); intermediate certificates may follow it.

#### client_key_file

The PEM private key of `client_certificate_file`; `null` reads it from that file.

#### client_key_password

The password of an encrypted client key.

#### connect_timeout_ms

The limit for connecting plus the TLS handshake, in milliseconds.

Zero leaves only `timeout_ms` as the limit.

#### follow_redirects

Whether 301, 302, 303, 307 and 308 responses with a `Location` are followed.

After a 303 (unless the method is `HEAD`), or a 301/302 answering a `POST`, the
request is repeated as `GET` without the body.
`Authorization`, `Proxy-Authorization` and cookie headers are dropped when the
redirect goes to another origin.

#### headers

Extra request headers.

`Host`, `Content-Length` and `Transfer-Encoding` are set by the client; passing
any of them, or a name or value with invalid characters, makes the request fail
with `invalid_request`. A `User-Agent` here replaces the default one.

#### max_redirects

The number of redirects to follow before failing with `too_many_redirects`.

#### max_response_body_size

The largest accepted response body in bytes, also when it goes to `output`;
zero disables the limit.

Exceeding it fails with `response_too_large`.

#### max_response_header_size

The largest accepted response head in bytes; zero disables the limit.

Exceeding it fails with `response_too_large`.

#### max_tls_version

The highest TLS version the client offers; `null` leaves it to the TLS library.

#### min_tls_version

The lowest TLS version the client accepts.

#### output

Receives the response body instead of `ClientResponse.body`.

#### query_data

Parameters appended to the URL's query string, keys and values percent-encoded.

They are added after the URL's own query string, joined with `&`, and are not
carried over to a redirected request.

#### read_timeout_ms

The limit for each socket read, in milliseconds; `timeout_ms` still applies.

#### timeout_ms

The limit for the whole request, including redirects, in milliseconds.

Zero leaves the overall request unlimited; each network operation still has its
own timeout below. Exceeding it fails with `timeout`.

#### tls_cipher_list

The OpenSSL cipher list for TLS 1.2 and older.

#### tls_cipher_suites

The OpenSSL cipher suites for TLS 1.3.

#### verify_tls_cert

Whether the server's TLS certificate is verified.

#### write_timeout_ms

The limit for each socket write, in milliseconds; `timeout_ms` still applies.

#### clear_headers

Removes every header set so far.

#### get_headers

Returns `headers`, creating an empty set first when it is `null`.

#### set_header

Sets the header `key` to `value`, replacing every existing value for that name.

#### set_headers

Copies every header in `headers` into this request's headers.

Each name in `headers` replaces the existing values for that name; repeated names
in `headers` are all kept. Names not in `headers` stay untouched.

```js
// A request passed to a server handler.
+ class Request {
    // The SHA-256 fingerprint of that certificate as 64 lowercase hex characters; empty when the client sent none.
    + client_certificate_sha256: String
    // The subject of the certificate the client sent, such as `CN=alice,O=Example`; empty when it sent none. A server asks for one with `Server.tls_client_ca`.
    + client_subject: String
    // The request method as sent, such as `GET`.
    + method: String
    // The path of the request target without the query string, not percent-decoded (see `url.decode_path`).
    + path: String
    // The client's address.
    + peer_address: SocketAddress
    // The query string without the leading `?`, not decoded; empty when absent.
    + query_string: String

    // The request body; empty when there is none.
    + get body: String
    // Returns the value of one cookie; throws `LookupError` when the request has no cookie of that name.
    + fn cookie(name: String) String !LookupError
    // Returns the cookies of the request, by name.
    + fn cookies() Map[String]
    // Returns the uploaded files of a `multipart/form-data` body, by field name.
    + fn files() Map[InMemoryFile]
    // Returns the form fields of the request body.
    + fn form() Map[String]
    // Returns the request headers, with names lowercased.
    + fn headers() Headers
    // Returns the request body as JSON.
    + fn json() Value
    // Returns the request body as JSON, like `json()`, but throws when it is not valid JSON.
    + fn parse_json() Value !json:ParseError
    // Returns the query string parameters.
    + fn query() Map[String]
    // Returns every value of each query string parameter, in order.
    + fn query_grouped() Map[Array[String]]
}
```

### Request

A request passed to a server handler.

`headers()`, `query()`, `form()`, `json()` and `files()` parse the request on first
use and cache the result.

#### client_certificate_sha256

The SHA-256 fingerprint of that certificate as 64 lowercase hex characters; empty when
the client sent none.

#### client_subject

The subject of the certificate the client sent, such as `CN=alice,O=Example`; empty
when it sent none. A server asks for one with `Server.tls_client_ca`.

#### method

The request method as sent, such as `GET`.

#### path

The path of the request target without the query string, not percent-decoded (see
`url.decode_path`).

#### peer_address

The client's address.

#### query_string

The query string without the leading `?`, not decoded; empty when absent.

#### body

The request body; empty when there is none.

#### cookie

Returns the value of one cookie; throws `LookupError` when the request has no
cookie of that name.

#### cookies

Returns the cookies of the request, by name.

The `Cookie` header is split on `;` only, and a value keeps every `=` after the
first one, so a base64 value arrives whole. Surrounding double quotes are removed.
A browser sends the cookie of the most specific path first, and that is the one
kept when a name is sent more than once.

#### files

Returns the uploaded files of a `multipart/form-data` body, by field name.

A file part without its own `Content-Type` header is skipped.

#### form

Returns the form fields of the request body.

Reads `application/x-www-form-urlencoded` bodies (keys and values decoded),
`multipart/form-data` (file parts go to `files()`) and `application/json` objects.
For JSON, string values are kept, `null` becomes an empty string and every other
value is re-encoded as JSON text. The media type is compared case-insensitively
and without its parameters, so `application/json; charset=utf-8` is read as JSON;
the multipart `boundary` parameter may be quoted. Any other body gives an empty
map.

#### headers

Returns the request headers, with names lowercased.

Leading spaces of values are removed; trailing whitespace is kept.

#### json

Returns the request body as JSON.

Form bodies are turned into an object of string values, see `data()`. Any other
body is decoded as JSON regardless of its content type; a body that is not valid
JSON gives an empty object. `parse_json` throws for such a body instead.

#### parse_json

Returns the request body as JSON, like `json()`, but throws when it is not valid JSON.

Form bodies are turned into an object of string values as `json()` does and never
fail. Any other body must be valid JSON, so an empty body throws too. Throws the
`json.ParseError` of `json.decode`.

```valk
let body = req.parse_json() ! return http.Response.text("Invalid JSON", 400)
```

#### query

Returns the query string parameters.

Keys and values are decoded with `url.decode`. A part without `=`, like `?flag`, has
the value `""`, and for a repeated key the last value wins; see `query_grouped`.

#### query_grouped

Returns every value of each query string parameter, in order.

Decoded like `query`.

```js
// A response returned by a server handler.
+ class Response {
    // The response body.
    + body: String
    // The `Content-Type` header value; a value with control characters is not sent.
    + content_type: String
    // The HTTP status code, also for `file` and `stream` responses.
    + status: u16

    // Adds a header field, keeping earlier fields with the same name.
    + fn add_header(name: String, value: String) void
    // Deletes the cookie `name` at the browser, by sending it expired.
    + fn clear_cookie(name: String, path: String ("/"), domain: ?String (null)) void
    // Creates a response with an empty body; also backs default construction.
    + static fn empty(code: u16 (200), headers: ?Headers (null)) Response
    // Creates a response that sends the file at `path`.
    + static fn file(path: String, filename: ?String (null)) Response
    // The extra response headers, created empty on first access.
    + get headers: Headers
    // Creates a `text/html; charset=utf-8` response.
    + static fn html(body: String, code: u16 (200), headers: ?Headers (null)) Response
    // Creates an `application/json` response; `body` must already be encoded JSON.
    + static fn json(body: String, code: u16 (200), headers: ?Headers (null)) Response
    // Creates an `application/json` response from any value, encoded with `json.encode`.
    + static fn json_of(data: $T, code: u16 (200), headers: ?Headers (null)) Response
    // Creates a response with `body`, `code` and `content_type`; the general form the other constructors are shortcuts for.
    + static fn new(body: String, code: u16 (200), content_type: String ("text/plain; charset=utf-8"), headers: ?Headers (null)) Response
    // Creates a redirect to `location` with an empty body.
    + static fn redirect(location: String, code: u16 (302), headers: ?Headers (null)) Response
    // Sends `cookie` with this response, next to any cookie already set.
    + fn set_cookie(cookie: Cookie) void
    // Sets the header `name` to `value`, replacing earlier values for that name.
    + fn set_header(name: String, value: String) void
    // Creates a response whose body is streamed from `reader`.
    + static fn stream(reader: Reader, size: uint, content_type: String ("application/octet-stream"), filename: ?String (null)) Response
    // Creates a `text/plain; charset=utf-8` response.
    + static fn text(body: String, code: u16 (200), headers: ?Headers (null)) Response
}
```

### Response

A response returned by a server handler.

The server writes `Content-Type` and `Content-Length` itself: a `Content-Type`
header replaces `content_type`, and `Content-Length` and `Transfer-Encoding` headers
are dropped.

#### body

The response body.

It is left out for `1xx`, 204 and 304 responses and for a `HEAD` request, whose
`Content-Length` still gives the size of the body.

#### content_type

The `Content-Type` header value; a value with control characters is not sent.

#### status

The HTTP status code, also for `file` and `stream` responses.

#### add_header

Adds a header field, keeping earlier fields with the same name.

#### clear_cookie

Deletes the cookie `name` at the browser, by sending it expired.

`path` and `domain` must be the ones it was set with, or the browser keeps the
cookie and this one sits next to it.

#### empty

Creates a response with an empty body; also backs default construction.

#### file

Creates a response that sends the file at `path`.

The content type follows from the file extension. With a `filename` the file is
offered as a download under that name (`Content-Disposition: attachment`). A file
that cannot be opened results in an empty 404 response.

#### headers

The extra response headers, created empty on first access.

Fields with invalid names or values are left out when the response is sent.

#### html

Creates a `text/html; charset=utf-8` response.

#### json

Creates an `application/json` response; `body` must already be encoded JSON.

#### json_of

Creates an `application/json` response from any value, encoded with `json.encode`.

#### new

Creates a response with `body`, `code` and `content_type`; the general form the
other constructors are shortcuts for.

#### redirect

Creates a redirect to `location` with an empty body.

Sets `Location` on `headers` when given, so a passed `Headers` object is modified.

#### set_cookie

Sends `cookie` with this response, next to any cookie already set.

A cookie whose name or value cannot go in a header is left out, as an invalid
header field is.

#### set_header

Sets the header `name` to `value`, replacing earlier values for that name.

#### stream

Creates a response whose body is streamed from `reader`.

`size` becomes the `Content-Length` and exactly `size` bytes are read from `reader`;
a reader that ends early fails the response. With a `filename` the body is offered
as a download under that name. The reader is not closed.

#### text

Creates a `text/plain; charset=utf-8` response.

```js
// Writes the HTTP/1.1 response for one request; passed to `fast` handlers.
+ class ResponseWriter {
    // Whether a response has been written for the current request.
    ~ responded: bool

    // Returns the reason phrase for `code`, such as `Bad Request`.
    + static fn code_name(code: u16) String
    // Responds with status `code`, `content_type` and `body`.
    + fn send(body: local &[u8], code: u16 (200), content_type: String ("text/plain; charset=utf-8"), headers: ?Headers (null)) void
    // Responds with status `code` and the file at `path`; responds 404 when it cannot be opened.
    + fn send_file(path: String, filename: ?String (null), headers: ?Headers (null), code: u16 (200)) void
    // Responds with `status_code` and an empty `text/plain` body.
    + fn send_status(status_code: u16) void
    // Responds with status `code` and a body streamed from `reader`.
    + fn send_stream(reader: Reader, size: uint, content_type: String ("application/octet-stream"), filename: ?String (null), headers: ?Headers (null), code: u16 (200)) void
    // Answers with the WebSocket upgrade and runs `handler` on the connection once the response is sent; the fast-handler form of `WebSocket.upgrade`.
    + fn send_websocket(context: Context, handler: fn(WebSocket)()) void
}
```

### ResponseWriter

Writes the HTTP/1.1 response for one request; passed to `fast` handlers.

Only the first `respond`, `send_status`, `send_file` or `send_stream` call per request
has an effect; later calls are ignored. A fast handler that does not respond makes
the server answer 400 and close the connection. Output is buffered and sent by the
server after the handler returns.

#### responded

Whether a response has been written for the current request.

#### code_name

Returns the reason phrase for `code`, such as `Bad Request`.

Covers the codes RFC 9110 defines plus 428, 429 and 431; any other code returns an
empty string, which the status line allows.

#### send

Responds with status `code`, `content_type` and `body`.

A `Content-Type` in `headers` replaces `content_type`; `Content-Length` and
`Transfer-Encoding` in `headers` are dropped, as are fields with invalid names or
values. The body is left out for `1xx`, 204 and 304 responses and for a `HEAD`
request; a `HEAD` response keeps the `Content-Length` of `body`, and 1xx and 204
responses have no `Content-Length`.

#### send_file

Responds with status `code` and the file at `path`; responds 404 when it cannot
be opened.

The content type follows from the file extension, unless `headers` has a
`Content-Type`. With a `filename` the file is offered as a download under that
name. The body is left out like `respond` leaves it out.

#### send_status

Responds with `status_code` and an empty `text/plain` body.

#### send_stream

Responds with status `code` and a body streamed from `reader`.

`size` becomes the `Content-Length` and exactly `size` bytes are copied from the
reader; a reader that ends early fails the response and closes the connection. A
`Content-Type` in `headers` replaces `content_type`. With a `filename` the body is
offered as a download under that name. The body is left out like `respond` leaves
it out, and then the reader is not read.

#### send_websocket

Answers with the WebSocket upgrade and runs `handler` on the connection once the
response is sent; the fast-handler form of `WebSocket.upgrade`.

A request that is not a valid WebSocket upgrade gets a `400` response and the
handler never runs.

```js
// A route found by `Router.find`: the handler plus the positions of its `@name` parts.
+ class Route[T] {
    // The value registered with `Router.add`.
    + handler: T

    // Returns the values of the route's `@name` parts, taken from `path`.
    + fn params(path: String) Map[String]
}
```

### Route

A route found by `Router.find`: the handler plus the positions of its `@name` parts.

#### handler

The value registered with `Router.add`.

#### params

Returns the values of the route's `@name` parts, taken from `path`.

Pass the same path that was given to `Router.find`. Values are not
percent-decoded; `url.decode_path` decodes one and keeps a `+`. Empty parts are ignored like `Router.find` ignores them, so
doubled slashes and a missing leading `/` do not shift the values; missing parts
are left out.

```js
// Maps a method and a URL path to a handler of type `T`.
+ class Router[T] {
    // Registers `handler` for `method` and the path pattern `url`.
    + fn add(method: String, url: String, handler: T) void
    // Returns the route that matches `method` and the path `url`.
    + fn find(method: String, url: String) Route[T] !LookupError
    // Creates an empty router; also backs `Router[T]{}` and default construction.
    + static fn new() Router[T]
}
```

### Router

Maps a method and a URL path to a handler of type `T`.

Patterns are split on `/`. A part `@name` matches any single part and is returned
by `Route.params`; a part `*` matches one or more remaining parts. When several
patterns match, a literal part is preferred over `@name`, and `@name` over `*`.

```valk
let router = http.Router[fn(http.Request)(http.Response)].new()
router.add("GET", "/users/@id", show_user)
let route = router.find(req.method, req.path) ! return http.Response.empty(404)
let id = route.params(req.path).get("id") !? ""
```

#### add

Registers `handler` for `method` and the path pattern `url`.

The method is compared case-sensitively. A leading `/` is optional and empty
parts are ignored. Adding the same pattern again replaces the handler; patterns
that differ only in their `@name` names count as the same. Parts after a `*` are
never reached by `find`.

#### find

Returns the route that matches `method` and the path `url`.

Throws `missing` when no route matches. `url` must not contain the query string.

#### new

Creates an empty router; also backs `Router[T]{}` and default construction.

```js
// A multi-threaded HTTP/1.1 server, with optional TLS and experimental HTTP/2.
+ class Server {
    // How long each read of a request body may take, in milliseconds.
    + body_timeout_ms: uint
    // How long each read of a request head, and the TLS handshake, may take, in milliseconds.
    + header_timeout_ms: uint
    // The address the server listens on.
    ~ host: String
    // Enables experimental HTTP/2, negotiated through ALPN with HTTP/1.1 as fallback.
    + http2: bool
    // How long a connection may wait for the next request, in milliseconds.
    + idle_timeout_ms: uint
    // The number of open connections allowed; 0 means no limit. Defaults to 10000.
    + max_connections: uint
    // The largest accepted request body in bytes; 0 means no limit. Defaults to 32 MiB.
    + max_request_body_size: uint
    // The largest accepted request head (request line and headers) in bytes; 0 means no limit. Defaults to 8 KiB.
    + max_request_header_size: uint
    // The combined size of the request bodies being received at once, over all connections, in bytes; 0 means no limit.
    + max_server_wide_body_size: uint
    // The port the server listens on.
    ~ port: u16
    // Lets several processes listen on the same port at once (`SO_REUSEPORT`; not on Windows). Start the new process, then stop the old one, for a restart without refused connections.
    + reuse_port: bool
    // Whether the server prints startup, connection and error messages.
    + show_info: bool
    // Stops the server when `SIGINT` or `SIGTERM` arrives (and `SIGHUP` where it exists): the listener closes, in-flight requests get `stop_on_signal_timeout_ms` to finish, and `start` returns. Combine with `reuse_port` for restarts without refused connections.
    + stop_on_signal: bool
    // How long in-flight requests may take after a stop signal, in milliseconds.
    + stop_on_signal_timeout_ms: uint
    // How long each socket write may take, in milliseconds.
    + write_timeout_ms: uint

    // Serves files from the directory `path` before a request reaches the handler.
    + fn add_static_dir(path: String, index: String ("index.html")) void !io:IoError
    // Sets a fast handler, which is used instead of the regular one.
    + fn fast(handler: shared fn(Context, ResponseWriter)()) void
    // Sets the handler that answers each request.
    + fn handle(handler: shared fn(Request)(Response)) void
    // Creates a server for `host` and `port`; nothing is opened until `start`.
    + static fn new(host: String, port: u16, handler: shared fn(Request)(Response) (handler_default)) Server
    // Stops accepting connections and gives in-flight requests `timeout_ms` to finish.
    + fn request_shutdown(timeout_ms: uint (5000)) void
    // Calls `request_shutdown` and waits for the workers to finish.
    + fn shutdown(timeout_ms: uint (5000)) bool
    // Serves until `request_shutdown`/`shutdown` and every worker has drained.
    + fn start(worker_count: uint (0)) void !HttpError
    // Serves over TLS with the given PEM certificate and private key files.
    + fn tls(certificate_file: String, private_key_file: String, min_version: TlsVersion (net.TlsVersion.tls_1_2), cipher_list: ?String (null), cipher_suites: ?String (null)) void !HttpError
    // Asks every client for a certificate that leads to a CA in the PEM file `ca_file` (mutual TLS); call it after `tls` and before `start`.
    + fn tls_client_ca(ca_file: String, required: bool (true)) void !HttpError
}
```

### Server

A multi-threaded HTTP/1.1 server, with optional TLS and experimental HTTP/2.

Configure the public fields, then call `start`. A server can be started once.

```valk
let s = http.Server.new("127.0.0.1", 9000, handler)
s.max_request_body_size = 1024 * 1024
s.start() ! { println("Failed to start http server"); return }
```

#### body_timeout_ms

How long each read of a request body may take, in milliseconds.

#### header_timeout_ms

How long each read of a request head, and the TLS handshake, may take, in
milliseconds.

#### host

The address the server listens on.

#### http2

Enables experimental HTTP/2, negotiated through ALPN with HTTP/1.1 as fallback.

Requires `tls` and the regular handler; `start` fails with `init` otherwise.

#### idle_timeout_ms

How long a connection may wait for the next request, in milliseconds.

#### max_connections

The number of open connections allowed; 0 means no limit. Defaults to 10000.

Connections beyond it are answered with 503 and closed.

#### max_request_body_size

The largest accepted request body in bytes; 0 means no limit. Defaults to 32 MiB.

Larger requests are answered with 413 and the connection is closed.

#### max_request_header_size

The largest accepted request head (request line and headers) in bytes; 0 means
no limit. Defaults to 8 KiB.

Larger requests are answered with 431 and the connection is closed.

#### max_server_wide_body_size

The combined size of the request bodies being received at once, over all
connections, in bytes; 0 means no limit.

A request that would exceed it is answered with 503, and while the limit is
reached new connections are answered with 503 as well.

#### port

The port the server listens on.

#### reuse_port

Lets several processes listen on the same port at once (`SO_REUSEPORT`; not on
Windows). Start the new process, then stop the old one, for a restart without
refused connections.

#### show_info

Whether the server prints startup, connection and error messages.

#### stop_on_signal

Stops the server when `SIGINT` or `SIGTERM` arrives (and `SIGHUP` where it exists):
the listener closes, in-flight requests get `stop_on_signal_timeout_ms` to finish,
and `start` returns. Combine with `reuse_port` for restarts without refused
connections.

#### stop_on_signal_timeout_ms

How long in-flight requests may take after a stop signal, in milliseconds.

#### write_timeout_ms

How long each socket write may take, in milliseconds.

#### add_static_dir

Serves files from the directory `path` before a request reaches the handler.

Throws `open` when `path` is not a directory. A request whose path names a file
inside the directory gets that file whatever the method (over HTTP/2: except
`CONNECT`). The path is percent-decoded first (`+` stays `+`); paths containing
`..` are never served. The directory added last is searched first.

A path naming a directory that holds an `index` file gets that file, so `/` serves
`index.html`. Without the trailing slash (`/docs`) the answer is a 301 redirect to
`/docs/` first, so relative links in the page resolve inside the directory. Pass
`index: ""` to let directory paths reach the handler.

#### fast

Sets a fast handler, which is used instead of the regular one.

It receives the parsed `Context` and writes to a `ResponseWriter`, skipping the
`Request`/`Response` objects. A handler that does not respond makes the server
answer 400 and close the connection. Not supported together with `http2`.

#### handle

Sets the handler that answers each request.

#### new

Creates a server for `host` and `port`; nothing is opened until `start`.

The default handler answers every request with "Hello world!".

#### request_shutdown

Stops accepting connections and gives in-flight requests `timeout_ms` to finish.

Returns without waiting and is safe to call from a handler. Idle connections are
closed right away. Before `start` the request is remembered and `start` stops
again as soon as it is running. Repeated calls can shorten the deadline, never
extend it.

#### shutdown

Calls `request_shutdown` and waits for the workers to finish.

Returns `false` when the deadline expired first; handler code can then still be
unwinding, and `start` returns once it did. Before `start` it only records the
request and returns `true`. Do not call this from a handler: it would wait for
itself.

#### start

Serves until `request_shutdown`/`shutdown` and every worker has drained.

Runs `worker_count` workers, one per thread, one of them on the calling thread, so
use `co` to keep working. A count of 0 uses the number of CPU threads; the
count is clamped to 1-128. Throws `init` when the server was started before, when
`http2` is set without `tls` or with a fast handler, or when a worker thread cannot
be started (after the started workers have drained), and a network error when the
port cannot be bound. `SIGPIPE` is ignored process-wide from then on.

#### tls

Serves over TLS with the given PEM certificate and private key files.

`cipher_list` applies to TLS 1.2 and older, `cipher_suites` to TLS 1.3. Throws when
the files or settings cannot be loaded.

#### tls_client_ca

Asks every client for a certificate that leads to a CA in the PEM file `ca_file`
(mutual TLS); call it after `tls` and before `start`.

With `required` a client without a valid certificate cannot connect; without it a
client may send none. A handler finds the certificate in `Request.client_subject` and
`Request.client_certificate_sha256`. Throws `init` before `tls`, and `ssl` when the file
cannot be read.

```js
// A WebSocket connection (RFC 6455), on the server or the client side.
+ class WebSocket {
    // The close code received from the peer, or the one sent when this side closed first; 0 while open, 1006 when the connection dropped without a close frame.
    ~ close_code: u16
    // The close reason that came with `close_code`.
    ~ close_reason: String
    // The largest message accepted, in bytes; a larger one closes the connection with code 1009. Defaults to 16 MB.
    + max_message_size: uint

    // Performs the closing handshake and closes the socket.
    + fn close(code: u16 (1000), reason: String (""), timeout_ms: uint (1000)) void !WebSocketError
    // Connects to a `ws://` or `wss://` server and completes the opening handshake.
    + static fn connect(url: String, options: ?Options (null)) WebSocket !WebSocketError
    // Whether the connection is closed, from either side.
    + get is_closed: bool
    // The address of the peer.
    + fn peer_address() SocketAddress !net:NetError
    // Sends a ping; the peer answers with a pong that `read` consumes.
    + fn ping(data: String ("")) void !WebSocketError
    // Waits for the next text or binary message.
    + fn read() WebSocketMessage !WebSocketError
    // Like `read`, but writes the payload to `out` and returns the message type.
    + fn read_into(out: Writer) WebSocketMessageType !WebSocketError
    // Makes a blocked `read` or `write` fail with `cancelled` when `token` is cancelled.
    + fn set_cancel(token: shared CancelToken) void
    // Sets the socket timeouts in milliseconds; 0 waits forever.
    + fn set_timeouts(read_timeout_ms: uint, write_timeout_ms: uint) void
    // Answers a server request with the WebSocket upgrade, then runs `handler` on the connection.
    + static fn upgrade(req: Request, handler: fn(WebSocket)()) Response
    // Sends `text` as one text message; the bytes must be UTF-8.
    + fn write(text: local &[u8]) void !WebSocketError
    // Sends `data` as one binary message.
    + fn write_binary(data: local &[u8]) void !WebSocketError
}
```

### WebSocket

A WebSocket connection (RFC 6455), on the server or the client side.

A server gets one from `WebSocket.upgrade`, a client from `WebSocket.connect`. `read`
returns whole messages and answers pings by itself; `write` and `write_binary` send
one message each. Reads and writes may run on different coroutines, so one coroutine
can wait for messages while another sends. `close` performs the closing handshake.

```valk
fn handler(req: http.Request) http.Response {
    return http.WebSocket.upgrade(req, fn(ws: http.WebSocket) {
        while true {
            let msg = ws.read() ! break
            ws.write(msg.data) ! break
        }
    })
}
```

#### close_code

The close code received from the peer, or the one sent when this side closed
first; 0 while open, 1006 when the connection dropped without a close frame.

#### close_reason

The close reason that came with `close_code`.

#### max_message_size

The largest message accepted, in bytes; a larger one closes the connection
with code 1009. Defaults to 16 MB.

#### close

Performs the closing handshake and closes the socket.

Sends a close frame with `code` and `reason` (at most 123 bytes), waits up to
`timeout_ms` for the peer's close frame, and closes the socket either way. Does
nothing when the connection is closed already. Throws when sending fails.

#### connect

Connects to a `ws://` or `wss://` server and completes the opening handshake.

`options` supplies extra request headers (for example `Origin` or a cookie), the
TLS settings for `wss://` and the timeouts: `connect_timeout_ms` bounds the
connection, `timeout_ms` the whole handshake, and `read_timeout_ms` /
`write_timeout_ms` become the socket timeouts afterwards. Throws `invalid_url`,
`handshake` when the server answers anything but a matching `101`, and the
socket's `timeout`, `closed`, `read` and `write`.

#### is_closed

Whether the connection is closed, from either side.

#### peer_address

The address of the peer.

#### ping

Sends a ping; the peer answers with a pong that `read` consumes.

`data` is at most 125 bytes.

#### read

Waits for the next text or binary message.

Pings are answered and pongs skipped on the way. Throws `closed` after the
closing handshake (see `close_code`) or when the connection dropped, `timeout`
after the read timeout, `cancelled`, `protocol` and `too_large`.

#### read_into

Like `read`, but writes the payload to `out` and returns the message type.

Throws the writer's error as `write`.

#### set_cancel

Makes a blocked `read` or `write` fail with `cancelled` when `token` is cancelled.

#### set_timeouts

Sets the socket timeouts in milliseconds; 0 waits forever.

A server socket starts with no read timeout and a 5 second write timeout; a client
socket starts with the timeouts of the `Options` it was connected with.

#### upgrade

Answers a server request with the WebSocket upgrade, then runs `handler` on the
connection.

The handler runs on the connection's coroutine after the `101` response is sent;
the connection is closed when it returns. A request that is not a valid WebSocket
upgrade (RFC 6455 §4.2.1) gets a `400` response instead and the handler never
runs. `Server.request_shutdown` interrupts the socket, so a blocked `read` then
fails with `closed`. Not available over HTTP/2.

#### write

Sends `text` as one text message; the bytes must be UTF-8.

#### write_binary

Sends `data` as one binary message.

```js
// One complete message received over a `WebSocket`.
+ class WebSocketMessage {
    // The message payload; valid UTF-8 for a text message.
    + data: String
    // Whether the message is text or binary.
    + type: WebSocketMessageType

    // Whether this is a text message.
    + get is_text: bool
}
```

### WebSocketMessage

One complete message received over a `WebSocket`.

#### data

The message payload; valid UTF-8 for a text message.

#### type

Whether the message is text or binary.

#### is_text

Whether this is a text message.

# io

## Aliases for 'io'

```js
alias Fd for i32
```

## Errors for 'io'

```js
// Thrown by file, stream, process and socket I/O.
error IoError (open, access, read, write, exists, os, closed, timeout, range, cancelled)
```

### IoError

Thrown by file, stream, process and socket I/O.

- `open`: a file or directory cannot be opened or its metadata read (for example it
  does not exist, or the open options allow neither reading nor writing).
- `access`: creating, deleting, moving, copying, linking or changing the permissions of
  a path failed.
- `read`: reading from a file, stream, pipe or socket failed.
- `write`: writing to a file, stream, pipe or socket failed or accepted no bytes.
- `exists`: `symlink` or `create_dir` found that the path already exists.
- `os`: another operating-system call failed (process spawning, path lookup, event
  loop setup).
- `closed`: the stream, connection, directory iterator, socket or compressor is closed,
  the peer closed it, or the process was detached.
- `timeout`: a socket read, write or wait ran past its timeout.
- `range`: a seek target lies before the start, past the end of a `ByteReader`, or
  beyond the largest file offset.
- `cancelled`: the connection's cancellation token fired.

## Enums for 'io'

```js
// Newline translation mode of a descriptor, for `set_mode`.
+ enum Mode { text, binary }
// The reference point of a seek offset.
+ enum SeekFrom { start, current, end }
```

### Mode

Newline translation mode of a descriptor, for `set_mode`.

### SeekFrom

The reference point of a seek offset.

## Functions for 'io'

```js
// Suspends the current coroutine until `fd` is readable (`read`) and/or writable (`write`).
+ fn await_fd(fd: i32, read: bool, write: bool, timeout_ms: uint (0)) PollEvent
// Suspends the current coroutine until the socket `fd` is readable and/or writable.
+ fn await_socket_fd(fd: i32, read: bool, write: bool, timeout_ms: uint (0)) PollEvent
// Closes `fd`; it must not be used afterwards.
+ fn close(fd: i32) void !IoError
// Copies `reader` into `writer` until the reader is exhausted and returns the bytes copied.
+ fn copy(reader: Reader, writer: Writer, chunk_size: uint (65536)) uint !IoError
// Wakes pending socket I/O on `fd` and makes later I/O on it fail, without releasing it.
+ fn interrupt_fd(fd: i32) void
// Writes `msg` to standard output, without a newline.
+ fn print(msg: String) void
// Writes `msg` and a newline to standard output.
+ fn println(msg: String) void
// Reads up to `buf.length` bytes from `fd` into `buf` and returns the number read.
+ fn read(fd: i32, buf: local mut &[u8], offset: uint (uint.$max)) uint !IoError
// Reads `reader` until it is exhausted and returns everything read.
+ fn read_all(reader: Reader, chunk_size: uint (65536)) ByteBuffer !IoError
// Reads like `read`, but always blocks the thread, even inside a coroutine.
+ fn read_sync(fd: i32, buf: local mut &[u8], offset: uint (uint.$max)) uint !IoError
// Moves the position of `fd` to `offset` bytes from `from` and returns the new position.
+ fn seek(fd: i32, offset: int, from: SeekFrom (SeekFrom.start)) uint !IoError
// Marks `fd` close-on-exec, so a program started with `core.Process.run` or `core.exec` does not inherit it. Every descriptor the standard library creates for itself is marked this way; the flag only matters for descriptors handed out by other code. Does nothing on Windows, where children only inherit the handles they are given.
+ fn set_close_on_exec(fd: i32) void !IoError
// Sets the newline translation mode of a C runtime descriptor such as 0, 1 or 2.
+ fn set_mode(fd: i32, mode: Mode) void !IoError
// Turns non-blocking mode of `fd` on or off.
+ fn set_nonblocking(fd: i32, value: bool) void !IoError
// Returns the standard error stream as an `io.Writer`; cached per thread.
+ fn stderr() StdStream
// Returns the standard input stream as an `io.Reader`; cached per thread.
+ fn stdin() StdStream
// Returns the standard output stream as an `io.Writer`; cached per thread.
+ fn stdout() StdStream
// Flushes the data written to `fd` to disk.
+ fn sync(fd: i32, data_only: bool (false)) void !IoError
// Writes up to `data.length` bytes of `data` to `fd` and returns the number written.
+ fn write(fd: i32, data: local &[u8], offset: uint (uint.$max)) uint !IoError
```

### await_fd

Suspends the current coroutine until `fd` is readable (`read`) and/or writable (`write`).

Returns the events that ended the wait; check them with `is_readable`, `is_writable`,
`is_closed` and `is_timeout`. A `timeout_ms` of 0 waits without a limit. Returns 0 when
neither `read` nor `write` is set, and an error event (`is_closed`) when the wait cannot be
set up. Panics outside a coroutine. On Windows use `await_socket_fd` for sockets.

### await_socket_fd

Suspends the current coroutine until the socket `fd` is readable and/or writable.

Same as `await_fd` on Linux and macOS. On Windows it waits with zero-byte socket
operations: a read wait reports `is_closed` when no bytes are pending once it completes
(the peer closed the connection). Panics outside a coroutine.

### close

Closes `fd`; it must not be used afterwards.

Throws `.os` when the OS reports a failure.

### copy

Copies `reader` into `writer` until the reader is exhausted and returns the bytes copied.

Short writes are continued until each chunk is written; a write of 0 bytes throws `.write`.
A `.closed` error from the reader counts as the end of input. Reads `chunk_size` bytes at a
time.

### interrupt_fd

Wakes pending socket I/O on `fd` and makes later I/O on it fail, without releasing it.

Safe to call from another thread. The descriptor must still be closed with `close`.

### print

Writes `msg` to standard output, without a newline.

Available in every namespace without the `io.` prefix. The write blocks the thread, and
errors are ignored.

### println

Writes `msg` and a newline to standard output.

Available in every namespace without the `io.` prefix. The write blocks the thread, and
errors are ignored.

### read

Reads up to `buf.length` bytes from `fd` into `buf` and returns the number read.

Returns 0 at the end of the input. An explicit `offset` reads at that file position without
moving the current position; the default (`uint.$max`) reads at the current position and
advances it, so repeated calls read a file sequentially. Pipes and sockets ignore it. Inside
a coroutine the call lets other coroutines run while it waits (io_uring on Linux, IOCP on
Windows, kqueue for non-blocking descriptors on macOS); outside one it blocks. Throws
`.read`, or `.os` when the request cannot be queued.

### read_all

Reads `reader` until it is exhausted and returns everything read.

Reads `chunk_size` bytes at a time. A `.closed` error from the reader counts as the end of
input.

### read_sync

Reads like `read`, but always blocks the thread, even inside a coroutine.

### seek

Moves the position of `fd` to `offset` bytes from `from` and returns the new position.

Throws `.os` on failure. `read` and `write` with their default offset read and write at this
position and advance it; an explicit offset neither uses nor moves it.

### set_close_on_exec

Marks `fd` close-on-exec, so a program started with `core.Process.run` or `core.exec`
does not inherit it. Every descriptor the standard library creates for itself is
marked this way; the flag only matters for descriptors handed out by other code.
Does nothing on Windows, where children only inherit the handles they are given.

### set_mode

Sets the newline translation mode of a C runtime descriptor such as 0, 1 or 2.

Only has an effect on Windows; elsewhere it does nothing. Throws `.os` on failure.

### set_nonblocking

Turns non-blocking mode of `fd` on or off.

On Windows it only works for sockets. Throws `.os` on failure.

### stderr

Returns the standard error stream as an `io.Writer`; cached per thread.

### stdin

Returns the standard input stream as an `io.Reader`; cached per thread.

Reads block the thread, even inside a coroutine.

### stdout

Returns the standard output stream as an `io.Writer`; cached per thread.

### sync

Flushes the data written to `fd` to disk.

With `data_only`, Linux skips metadata that is not needed to read the data back
(`fdatasync`); other platforms always do a full sync. Throws `.os` on failure.

### write

Writes up to `data.length` bytes of `data` to `fd` and returns the number written.

The count may be less than `data.length`; call again for the rest. An explicit `offset`
writes at that file position without moving the current position; the default
(`uint.$max`) writes at the current position and advances it, or at the end of a file
opened in `fs.WriteMode.append`. Inside a coroutine the call lets other coroutines run
while it waits on Linux and Windows. Throws `.write`, or `.os` when the request cannot be
queued.

## Classes for 'io'

```js
// A resource that is released with `close`.
+ interface Closer {
    // Releases the resource.
    + fn close() void !IoError
}
```

### Closer

A resource that is released with `close`.

#### close

Releases the resource.

```js
// Reads a `Reader` line by line, buffering its input.
+ class LineReader {
    // Returns every remaining line, split as `read_line` does.
    + fn lines() Array[String] !IoError
    // Creates a line reader over `reader` that reads `chunk_size` bytes at a time.
    + static fn new(reader: Reader, chunk_size: uint (65536)) LineReader
    // Returns the next line without its `\n` or `\r\n`, or `null` once the input is exhausted.
    + fn read_line() ?String !IoError
    // Writes the next line to `out` as `read_line` returns it and returns the bytes written, or `null` once the input is exhausted.
    + fn read_line_into(out: Writer) ?uint !IoError
    // Returns the bytes up to, not including, the next `delimiter`, or `null` at the end.
    + fn read_until(delimiter: u8) ?String !IoError
    // Writes the bytes up to, not including, the next `delimiter` to `out` and returns the bytes written, or `null` at the end of the input.
    + fn read_until_into(delimiter: u8, out: Writer) ?uint !IoError
}
```

### LineReader

Reads a `Reader` line by line, buffering its input.

Any reader works: `io.LineReader.new(io.stdin())`, a `fs.FileStream` or a `ByteReader`.

#### lines

Returns every remaining line, split as `read_line` does.

#### new

Creates a line reader over `reader` that reads `chunk_size` bytes at a time.

#### read_line

Returns the next line without its `\n` or `\r\n`, or `null` once the input is exhausted.

A final line without a newline is returned as well; a newline at the very end does not
produce an extra empty line. The `\r` of a `\r\n` is only dropped when the `\n` was
there: without it the line keeps its last byte, as `read_until` promises.

#### read_line_into

Writes the next line to `out` as `read_line` returns it and returns the bytes written,
or `null` once the input is exhausted.

An empty line writes nothing and returns 0. Throws when the reader or `out` fails;
bytes written to `out` before a failure stay written.

#### read_until

Returns the bytes up to, not including, the next `delimiter`, or `null` at the end.

The input's final bytes are returned as-is when no delimiter follows them. A `.closed`
error from the reader counts as the end of input.

#### read_until_into

Writes the bytes up to, not including, the next `delimiter` to `out` and returns the
bytes written, or `null` at the end of the input.

The bytes reach `out` as the reader delivers them, so a long line never sits in memory
as a whole. Throws when the reader or `out` fails.

```js
// A source of bytes that is read one buffer at a time.
+ interface Reader {
    // Reads up to `buf.length` bytes into `buf` and returns the count; 0 means the end of input.
    + fn read(buf: local mut &[u8]) uint !IoError
}
```

### Reader

A source of bytes that is read one buffer at a time.

#### read

Reads up to `buf.length` bytes into `buf` and returns the count; 0 means the end of input.

```js
// A stream with a movable position.
+ interface Seeker {
    // Moves the position to `offset` bytes from `from` and returns the new position.
    + fn seek(offset: int, from: SeekFrom) uint !IoError
}
```

### Seeker

A stream with a movable position.

#### seek

Moves the position to `offset` bytes from `from` and returns the new position.

```js
// One of the process's standard streams; get one from `stdin`, `stdout` or `stderr`.
+ class StdStream is Reader, Writer {
    // Whether `read` is allowed; only for stdin.
    ~ can_read: bool
    // Whether `write` is allowed; only for stdout and stderr.
    ~ can_write: bool
    // The descriptor: 0, 1 or 2.
    ~ fd: i32

    // Reads up to `buf.length` bytes into `buf` and returns the count; 0 at the end of input.
    + fn read(buf: local mut &[u8]) uint !IoError
    // Writes all of `data` and returns its length.
    + fn write(data: local &[u8]) uint !IoError
}
```

### StdStream

One of the process's standard streams; get one from `stdin`, `stdout` or `stderr`.

Reads and writes block the thread and never close the descriptor.

#### can_read

Whether `read` is allowed; only for stdin.

#### can_write

Whether `write` is allowed; only for stdout and stderr.

#### fd

The descriptor: 0, 1 or 2.

#### read

Reads up to `buf.length` bytes into `buf` and returns the count; 0 at the end of input.

Reads sequentially, also when stdin is redirected from a regular file (`< file`). Throws
`.read` on an output stream or when reading fails.

#### write

Writes all of `data` and returns its length.

Throws `.write` on the input stream or when writing fails.

```js
// A destination for bytes.
+ interface Writer {
    // Writes bytes from `data` and returns the count, which may be less than `data.length`.
    + fn write(data: local &[u8]) uint !IoError
}
```

### Writer

A destination for bytes.

#### write

Writes bytes from `data` and returns the count, which may be less than `data.length`.

# json

## Errors for 'json'

```js
// Thrown by typed decoding when the input does not fit the target type.
+ error DecodeError (wrong_type, missing) extends (ParseError)
// Thrown when JSON input cannot be parsed.
+ error ParseError (invalid, too_deep, too_large) payload { at_index: uint, message: String, character: u8 (0) }
```

### DecodeError

Thrown by typed decoding when the input does not fit the target type.

Adds `.wrong_type` (a value has the wrong JSON type or is out of range for the
target number type) and `.missing` (a required field is absent) to the `ParseError`
values, with the same payload.

### ParseError

Thrown when JSON input cannot be parsed.

`.invalid` is a syntax error (including invalid UTF-8 and out-of-range numbers),
`.too_deep` means nesting exceeded `max_depth`, and `.too_large` means the input
exceeded `max_bytes` or `max_entries`. The payload carries a `message`, the byte
offset `at_index` where parsing stopped, and the offending byte in `character`
(`0` when there is none).

## Enums for 'json'

```js
// The type of a JSON value, as reported by `Value.kind`.
+ enum Kind { null, string, bool, int, float, array, object }
```

### Kind

The type of a JSON value, as reported by `Value.kind`.

## Functions for 'json'

```js
// Parses JSON text into a `Value`; `json` is any byte storage: a string, a `ByteBuffer` or a slice.
+ fn decode(json: &[u8], max_depth: uint (JSON_MAX_DEPTH), max_bytes: uint (JSON_MAX_BYTES), max_entries: uint (JSON_MAX_ENTRIES)) Value !ParseError
// Parses JSON text directly into `T`, without building an intermediate `Value`.
+ fn decode_to[T](json: &[u8], max_depth: uint (JSON_MAX_DEPTH), max_bytes: uint (JSON_MAX_BYTES), max_entries: uint (JSON_MAX_ENTRIES)) T !DecodeError
// Returns the empty value of a kind: `null`, `""`, `false`, `0`, `0.0`, `[]` or `{}`.
+ fn default_value(kind: Kind) Value
// Returns `data` encoded as JSON text; `pretty` adds newlines and four-space indentation.
+ fn encode(data: $T, pretty: bool (false)) String
// Writes `data` encoded as JSON to `out` and returns the bytes written; see `encode`.
+ fn encode_into(data: $T, out: Writer, pretty: bool (false)) uint !io:IoError
// Converts `data` to a JSON value.
+ fn from(data: $T) Value
// Returns a JSON array holding `values`, or an empty array when `values` is `null`.
+ fn new_array(values: ?Array[Value] (null)) ArrayValue
// Returns `value` as a JSON boolean.
+ fn new_bool(value: bool) Value
// Returns `value` as a JSON number with a float representation.
+ fn new_float(value: float) Value
// Returns `value` as a JSON number with an integer representation.
+ fn new_int(value: int) Value
// Returns the JSON `null` value.
+ fn new_null() Value
// Returns a JSON object holding `values`, or an empty object when `values` is `null`.
+ fn new_object(values: ?Map[Value] (null)) ObjectValue
// Returns `value` as a JSON string.
+ fn new_string(value: String) Value
```

### decode

Parses JSON text into a `Value`; `json` is any byte storage: a string, a `ByteBuffer` or a slice.

Throws `.invalid` on a syntax error, invalid UTF-8 in a string, trailing non-whitespace
or a number outside the range of `float`; `.too_deep` when containers nest deeper
than `max_depth`; and `.too_large` when the input is longer than `max_bytes` or holds
more than `max_entries` array items and object members in total. A `max_bytes` or
`max_entries` of `0` disables that limit; `max_depth` is capped at 1000. The defaults
are a depth of 128, 64 MiB and 1,000,000 entries.

A number is an integer unless it has a fraction or an exponent, or lies outside the range
of `int`: then it becomes the nearest float, as in JavaScript (`decode_to` into a `u64`
field reads such a number exactly). When an object repeats
a key, the last value wins. An unpaired `\u` surrogate escape decodes to U+FFFD.

### decode_to

Parses JSON text directly into `T`, without building an intermediate `Value`.

Takes the same limits and throws the same errors as `decode`, plus `.wrong_type` when a
value has the wrong JSON type or is out of range for the target number type, and
`.missing` when a required field is absent. The type rules match `Value.to_type`:
integer fields need a JSON integer or a whole float (`3.0` reads as `3`), float fields
accept any JSON number (`3` reads as
`3.0`), nullable fields and fields with an explicit default may be absent or `null`
(and then get their default), and unknown members are skipped.

### default_value

Returns the empty value of a kind: `null`, `""`, `false`, `0`, `0.0`, `[]` or `{}`.

### encode

Returns `data` encoded as JSON text; `pretty` adds newlines and four-space indentation.

Accepts a `Value` or any value `json.from` accepts, and never fails. Strings are escaped
as needed (invalid UTF-8 bytes become `�`), and NaN and infinities are written as
`null`. A container found again inside itself is written as `"(recursion)"` and one
nested 1000 levels deep as `"(too deep)"`. A container that appears several times
without a cycle, such as one array held by two members, is written in full each time.

### encode_into

Writes `data` encoded as JSON to `out` and returns the bytes written; see `encode`.

A `ByteBuffer` is written directly; any other writer receives the document in one
write. Throws when `out` fails.

### from

Converts `data` to a JSON value.

Strings, numbers and bools map to their JSON kinds, `null` to `null`, arrays to
arrays, string-keyed maps to objects, and classes and structs to objects with one
member per field. Types with a `to_json_value` method use it. Any other value becomes
`null`. An object that is reached again inside itself becomes the string
`"(recursion)"`.

The value model holds signed 64-bit integers, so an unsigned 64-bit value above
`int.$max` becomes a float holding the nearest representable number rather than a
negative integer. Narrower unsigned types always fit and stay integers.

### new_array

Returns a JSON array holding `values`, or an empty array when `values` is `null`.

The array keeps a reference to `values`; it is not copied.

### new_bool

Returns `value` as a JSON boolean.

### new_float

Returns `value` as a JSON number with a float representation.

### new_int

Returns `value` as a JSON number with an integer representation.

### new_null

Returns the JSON `null` value.

### new_object

Returns a JSON object holding `values`, or an empty object when `values` is `null`.

The object keeps a reference to `values`; it is not copied.

### new_string

Returns `value` as a JSON string.

## Classes for 'json'

```js
// A JSON array: an ordered list of `Value` items.
+ class ArrayValue {
    // The items, in order. Changes to this array change the JSON array.
    + values: Array[Value]

    // Appends `value` to the end.
    + fn append(value: Value) void
    // Returns the array encoded as JSON text; see `json.encode`.
    + fn encode(pretty: bool (false)) String
    // Writes the array encoded as JSON to `out` and returns the bytes written; see `json.encode_into`.
    + fn encode_into(out: Writer, pretty: bool (false)) uint !io:IoError
    // Returns the item at `index`.
    + fn get(index: uint) Value !LookupError
    // Returns the number of items.
    + get length: uint
    // Inserts `value` at the start, moving the existing items up.
    + fn prepend(value: Value) void
    // Removes the item at `index`, moving later items down; does nothing when out of range.
    + fn remove(index: uint) void
}
```

### ArrayValue

A JSON array: an ordered list of `Value` items.

#### values

The items, in order. Changes to this array change the JSON array.

#### append

Appends `value` to the end.

#### encode

Returns the array encoded as JSON text; see `json.encode`.

#### encode_into

Writes the array encoded as JSON to `out` and returns the bytes written; see
`json.encode_into`.

#### get

Returns the item at `index`.

Throws `.missing` when `index` is out of range.

#### length

Returns the number of items.

#### prepend

Inserts `value` at the start, moving the existing items up.

#### remove

Removes the item at `index`, moving later items down; does nothing when out of range.

```js
// A JSON object: `Value` members keyed by string, kept in insertion order.
+ class ObjectValue {
    // The members. Changes to this map change the JSON object.
    + values: Map[Value]

    // Returns the object encoded as JSON text; see `json.encode`.
    + fn encode(pretty: bool (false)) String
    // Writes the object encoded as JSON to `out` and returns the bytes written; see `json.encode_into`.
    + fn encode_into(out: Writer, pretty: bool (false)) uint !io:IoError
    // Returns the member named `key`.
    + fn get(key: String) Value !LookupError
    // Returns whether a member named `key` exists.
    + fn has(key: String) bool
    // Returns the number of members.
    + get length: uint
    // Removes the member `key`; does nothing when it does not exist. The other members keep their order.
    + fn remove(key: String) void
    // Sets the member `key` to `value`; an existing member keeps its position.
    + fn set(key: String, value: Value) void
}
```

### ObjectValue

A JSON object: `Value` members keyed by string, kept in insertion order.

#### values

The members. Changes to this map change the JSON object.

#### encode

Returns the object encoded as JSON text; see `json.encode`.

#### encode_into

Writes the object encoded as JSON to `out` and returns the bytes written; see
`json.encode_into`.

#### get

Returns the member named `key`.

Throws `.missing` when there is no such member.

#### has

Returns whether a member named `key` exists.

#### length

Returns the number of members.

#### remove

Removes the member `key`; does nothing when it does not exist. The other members keep
their order.

#### set

Sets the member `key` to `value`; an existing member keeps its position.

```js
// A JSON value: `null`, a string, an integer, a float, a bool, an array or an object.
+ union Value : String | bool | float | int | ArrayValue | ObjectValue | null {
    // Appends `value` to the array and returns it.
    + fn append(value: Value) Value
    // Appends a bool; see `append` for what is returned.
    + fn append_bool(value: bool) Value
    // Appends a float; see `append` for what is returned.
    + fn append_float(value: float) Value
    // Appends an integer; see `append` for what is returned.
    + fn append_int(value: int) Value
    // Appends `null`; see `append` for what is returned.
    + fn append_null() Value
    // Appends a string; see `append` for what is returned.
    + fn append_string(value: String) Value
    // Returns the array held, or a new empty array when the value is not an array.
    + get array: ArrayValue
    // Returns the array held.
    + fn array_value() ArrayValue !LookupError
    // Returns the bool held, or `false` when the value is not a bool.
    + get bool: bool
    // Returns the bool held.
    + fn bool_value() bool !LookupError
    // Returns the value encoded as JSON text; see `json.encode`.
    + fn encode(pretty: bool (false)) String
    // Writes the value encoded as JSON to `out` and returns the bytes written; see `json.encode_into`.
    + fn encode_into(out: Writer, pretty: bool (false)) uint !io:IoError
    // Returns the number held as a float, or `0.0` when the value is not a number.
    + get float: float
    // Returns the number held as a float; an integer is converted.
    + fn float_value() float !LookupError
    // Returns the object member named `key` or the array item at index `key`.
    + fn get(key: String | uint) Value
    // Returns the array at `key`.
    + fn get_array(key: String | uint) ArrayValue !LookupError
    // Returns the bool at `key`.
    + fn get_bool(key: String | uint) bool !LookupError
    // Returns the number at `key` as a float; an integer is converted.
    + fn get_float(key: String | uint) float !LookupError
    // Returns the integer at `key`; a whole float counts as its integer.
    + fn get_int(key: String | uint) int !LookupError
    // Returns the object at `key`.
    + fn get_object(key: String | uint) ObjectValue !LookupError
    // Returns the object member named `key` or the array item at index `key`.
    + fn get_required(key: String | uint) Value !LookupError
    // Returns the string at `key`.
    + fn get_string(key: String | uint) String !LookupError
    // Returns whether an object member named `key` or an array item at index `key` exists.
    + fn has(key: String | uint) bool
    // Returns whether the value at `key` exists and is an array.
    + fn has_array(key: String | uint) bool
    // Returns whether the value at `key` exists and is a bool.
    + fn has_bool(key: String | uint) bool
    // Returns whether the value at `key` exists and is a number, i.e. whether `get_float` succeeds; an integer counts.
    + fn has_float(key: String | uint) bool
    // Returns whether the value at `key` exists and is an integer.
    + fn has_int(key: String | uint) bool
    // Returns whether the value at `key` exists and is an object.
    + fn has_object(key: String | uint) bool
    // Returns whether the value at `key` exists and is a string.
    + fn has_string(key: String | uint) bool
    // Returns the integer held, or `0` when the value is not an integer.
    + get int: int
    // Returns the integer held; a whole float counts as its integer (`3.0` gives `3`).
    + fn int_value() int !LookupError
    // Returns whether the value is an array.
    + get is_array: bool
    // Returns whether the value is a bool.
    + get is_bool: bool
    // Returns whether the value is a float.
    + get is_float: bool
    // Returns whether the value is an integer.
    + get is_int: bool
    // Returns whether the value is of kind `kind`.
    + fn is_kind(kind: Kind) bool
    // Returns whether the value is `null`.
    + get is_null: bool
    // Returns whether the value is an integer or a float.
    + get is_number: bool
    // Returns whether the value is an object.
    + get is_object: bool
    // Returns whether the value is a string.
    + get is_string: bool
    // Returns the kind of value held.
    + get kind: Kind
    // Returns the kind as a lowercase name: `"null"`, `"string"`, `"int"`, `"float"`, `"bool"`, `"array"` or `"object"`.
    + fn kind_name() String
    // Returns the number of items or members, the byte length of a string, or `0` otherwise.
    + get length: uint
    // Returns the object held, or a new empty object when the value is not an object.
    + get object: ObjectValue
    // Returns the object held.
    + fn object_value() ObjectValue !LookupError
    // Inserts `value` at the start of the array and returns it.
    + fn prepend(value: Value) Value
    // Removes the object member named `key` or the array item at index `key`, and returns the container.
    + fn remove(key: String | uint) Value
    // Sets the member named `key` or the array item at index `key`, and returns the container.
    + fn set(key: String | uint, value: Value) Value
    // Sets `key` to a bool; see `set` for how the container is chosen and returned.
    + fn set_bool(key: String | uint, value: bool) Value
    // Sets `key` to a float; see `set` for how the container is chosen and returned.
    + fn set_float(key: String | uint, value: float) Value
    // Sets `key` to an integer; see `set` for how the container is chosen and returned.
    + fn set_int(key: String | uint, value: int) Value
    // Sets `key` to `null`; see `set` for how the container is chosen and returned.
    + fn set_null(key: String | uint) Value
    // Sets `key` to a string; see `set` for how the container is chosen and returned.
    + fn set_string(key: String | uint, value: String) Value
    // Returns the value as text; any kind converts.
    + get string: String
    // Returns the string held.
    + fn string_value() String !LookupError
    // Converts the value to `T`.
    + fn to_type[T]() T !LookupError
}
```

### Value

A JSON value: `null`, a string, an integer, a float, a bool, an array or an object.

Arrays and objects are references: copying a `Value` shares the container. `x[key]`
reads a member or item and yields `null` when it is absent. `each value as item, key`
walks array items (the key is the index) or object members (the key is the name);
other kinds yield nothing.

```valk
let doc = json.decode("{\"names\":[\"a\",\"b\"]}") ! panic("invalid JSON")
let first = doc["names"][0].string
```

#### append

Appends `value` to the array and returns it.

When the value is not an array, it is left alone and a new array holding only `value` is
returned, so assign the result.

#### append_bool

Appends a bool; see `append` for what is returned.

#### append_float

Appends a float; see `append` for what is returned.

#### append_int

Appends an integer; see `append` for what is returned.

#### append_null

Appends `null`; see `append` for what is returned.

#### append_string

Appends a string; see `append` for what is returned.

#### array

Returns the array held, or a new empty array when the value is not an array.

The empty array is not attached to anything; changes to it are lost.

#### array_value

Returns the array held.

Throws `.missing` when the value is not an array.

#### bool

Returns the bool held, or `false` when the value is not a bool.

#### bool_value

Returns the bool held.

Throws `.missing` when the value is not a bool.

#### encode

Returns the value encoded as JSON text; see `json.encode`.

#### encode_into

Writes the value encoded as JSON to `out` and returns the bytes written; see
`json.encode_into`.

#### float

Returns the number held as a float, or `0.0` when the value is not a number.

An integer is converted, so a JSON `3` gives `3.0`.

#### float_value

Returns the number held as a float; an integer is converted.

Throws `.missing` when the value is not a number.

#### get

Returns the object member named `key` or the array item at index `key`.

Returns `null` when it is absent, when the key form does not match the kind (a name on
an array, an index on an object) or when the value is not a container, so a missing
member and a member holding `null` look the same. Backs the `x[key]` read.

#### get_array

Returns the array at `key`.

Throws `.missing` when it is absent or not an array.

#### get_bool

Returns the bool at `key`.

Throws `.missing` when it is absent or not a bool.

#### get_float

Returns the number at `key` as a float; an integer is converted.

Throws `.missing` when it is absent or not a number.

#### get_int

Returns the integer at `key`; a whole float counts as its integer.

Throws `.missing` when it is absent or not an integer, including a float that is not
whole.

#### get_object

Returns the object at `key`.

Throws `.missing` when it is absent or not an object.

#### get_required

Returns the object member named `key` or the array item at index `key`.

Throws `.missing` when it is absent, when the key form does not match the kind or when
the value is not a container.

#### get_string

Returns the string at `key`.

Throws `.missing` when it is absent or not a string.

#### has

Returns whether an object member named `key` or an array item at index `key` exists.

A member holding `null` counts as present.

#### has_array

Returns whether the value at `key` exists and is an array.

#### has_bool

Returns whether the value at `key` exists and is a bool.

#### has_float

Returns whether the value at `key` exists and is a number, i.e. whether `get_float`
succeeds; an integer counts.

#### has_int

Returns whether the value at `key` exists and is an integer.

#### has_object

Returns whether the value at `key` exists and is an object.

#### has_string

Returns whether the value at `key` exists and is a string.

#### int

Returns the integer held, or `0` when the value is not an integer.

A whole float counts as its integer (`3.0` gives `3`); `1.5` gives `0`.

#### int_value

Returns the integer held; a whole float counts as its integer (`3.0` gives `3`).

Throws `.missing` when the value is not an integer, including a float that is not whole
or does not fit in `int`.

#### is_array

Returns whether the value is an array.

#### is_bool

Returns whether the value is a bool.

#### is_float

Returns whether the value is a float.

A number parsed from JSON is a float only when it has a fraction or an exponent, so `1`
is an integer and `1.0` is a float.

#### is_int

Returns whether the value is an integer.

#### is_kind

Returns whether the value is of kind `kind`.

#### is_null

Returns whether the value is `null`.

#### is_number

Returns whether the value is an integer or a float.

#### is_object

Returns whether the value is an object.

#### is_string

Returns whether the value is a string.

#### kind

Returns the kind of value held.

#### kind_name

Returns the kind as a lowercase name: `"null"`, `"string"`, `"int"`, `"float"`, `"bool"`,
`"array"` or `"object"`.

#### length

Returns the number of items or members, the byte length of a string, or `0` otherwise.

#### object

Returns the object held, or a new empty object when the value is not an object.

The empty object is not attached to anything; changes to it are lost.

#### object_value

Returns the object held.

Throws `.missing` when the value is not an object.

#### prepend

Inserts `value` at the start of the array and returns it.

When the value is not an array, it is left alone and a new array holding only `value` is
returned, so assign the result.

#### remove

Removes the object member named `key` or the array item at index `key`, and returns the
container.

The container is changed in place and returned, so assign the result; a value of any
other kind is left alone. Does nothing when the key is absent. The other object members
keep their order.

```valk
doc = doc.remove("name")
```

#### set

Sets the member named `key` or the array item at index `key`, and returns the container.

An object or array is changed in place and returned. Any other value (including an
array given a name, or an object given an index) is left alone and a new container
holding only `value` is returned, so assign the result. Setting an index past the end of
an array fills the gap with `null`.

```valk
let doc = json.new_null()
doc = doc.set("name", "Alice")
```

#### set_bool

Sets `key` to a bool; see `set` for how the container is chosen and returned.

#### set_float

Sets `key` to a float; see `set` for how the container is chosen and returned.

#### set_int

Sets `key` to an integer; see `set` for how the container is chosen and returned.

#### set_null

Sets `key` to `null`; see `set` for how the container is chosen and returned.

#### set_string

Sets `key` to a string; see `set` for how the container is chosen and returned.

#### string

Returns the value as text; any kind converts.

A string is returned as is (without quotes), numbers and bools are formatted, `null`
gives an empty string (like a missing member, which `get` also reports as `null`), and
arrays and objects give their compact JSON encoding. Use `string_value` to require a
string.

#### string_value

Returns the string held.

Throws `.missing` when the value is not a string.

#### to_type

Converts the value to `T`.

Throws `.missing` when the value does not fit `T`. A nullable `T` accepts `null`.
Integers must be JSON integers, or whole floats such as `3.0`, within the range of `T`;
a float accepts any JSON
number, so an integer such as `3` converts to `3.0` (a value that overflows `f32` is
rejected). Types with a static `from_json_value` method use it; arrays and
string-keyed maps convert item by item. For a class or struct the value must be an
object: fields that are nullable or declare an explicit default may be absent or
`null` and then get their default, every other field is required, and unknown
members are ignored.

# log

## Enums for 'log'

```js
// How records are written: `text` as one readable line each, `json` as one JSON object per line for log collectors.
+ enum Format { text, json }
// How important a log record is. A logger drops records below its level.
+ enum Level { debug, info, warn, error }
```

### Format

How records are written: `text` as one readable line each, `json` as one JSON object per
line for log collectors.

### Level

How important a log record is. A logger drops records below its level.

## Functions for 'log'

```js
// Writes a debug record with this thread's logger; see `Logger.write`.
+ fn debug(message: String, fields: ?Map[Field] (null)) void
// Returns this thread's logger, which the functions of this namespace write with.
+ fn default() Logger
// Returns whether a record of `level` would be written.
+ fn enabled(level: Level) bool
// Writes an error record with this thread's logger; see `Logger.write`.
+ fn error(message: String, fields: ?Map[Field] (null)) void
// Writes an info record with this thread's logger; see `Logger.write`.
+ fn info(message: String, fields: ?Map[Field] (null)) void
// Returns the lowest level that is written.
+ fn level() Level
// Returns the level named `name`: `debug`, `info`, `warn` (or `warning`) or `error`, in any case, such as from an environment variable.
+ fn parse_level(name: String) Level !LookupError
// Sets the record layout for every thread; `text` at the start.
+ fn set_format(format: Format) void
// Sets the lowest level that is written, for every thread; `info` at the start.
+ fn set_level(level: Level) void
// Makes timestamps use the local time zone instead of UTC, for every thread.
+ fn set_local_time(enabled: bool) void
// Appends records to the file at `path`, created when missing, for every thread.
+ fn to_file(path: String) void !io:IoError
// Writes records to standard error, for every thread; the destination at the start.
+ fn to_stderr() void
// Writes records to standard output, for every thread.
+ fn to_stdout() void
// Writes a warning record with this thread's logger; see `Logger.write`.
+ fn warn(message: String, fields: ?Map[Field] (null)) void
// Returns this thread's logger with `fields` added to every record; see `Logger.with`.
+ fn with(fields: Map[Field]) Logger
```

### debug

Writes a debug record with this thread's logger; see `Logger.write`.

### default

Returns this thread's logger, which the functions of this namespace write with.

### enabled

Returns whether a record of `level` would be written.

### error

Writes an error record with this thread's logger; see `Logger.write`.

### info

Writes an info record with this thread's logger; see `Logger.write`.

### level

Returns the lowest level that is written.

### parse_level

Returns the level named `name`: `debug`, `info`, `warn` (or `warning`) or `error`, in any
case, such as from an environment variable.

Throws `missing` for any other name.

### set_format

Sets the record layout for every thread; `text` at the start.

### set_level

Sets the lowest level that is written, for every thread; `info` at the start.

### set_local_time

Makes timestamps use the local time zone instead of UTC, for every thread.

### to_file

Appends records to the file at `path`, created when missing, for every thread.

All threads write through one handle, a whole record at a time, so records of several
threads never mix; other programs may read the file meanwhile. A file opened earlier is
closed. Throws when the file cannot be opened, and then leaves the destination as it was.

### to_stderr

Writes records to standard error, for every thread; the destination at the start.

Closes the log file that `to_file` opened.

### to_stdout

Writes records to standard output, for every thread.

Closes the log file that `to_file` opened.

### warn

Writes a warning record with this thread's logger; see `Logger.write`.

### with

Returns this thread's logger with `fields` added to every record; see `Logger.with`.

## Classes for 'log'

```js
// The value of a log field: text, a number, a bool or null.
+ union Field : String | bool | float | int | uint | null {
}
```

### Field

The value of a log field: text, a number, a bool or null.

```js
// Writes log records to one `io.Writer`, one write per record.
+ class Logger {
    // The layout of the records.
    + format: Format
    // The lowest level that is written.
    + level: Level
    // Whether timestamps use the local time zone instead of UTC.
    + local_time: bool

    // Writes a debug record.
    + fn debug(message: String, fields: ?Map[Field] (null)) void
    // Returns whether a record of `level` would be written; use it to skip preparing expensive fields.
    + fn enabled(level: Level) bool
    // Writes an error record.
    + fn error(message: String, fields: ?Map[Field] (null)) void
    // Writes an info record.
    + fn info(message: String, fields: ?Map[Field] (null)) void
    // Returns a logger that writes to `out`, standard error when it is null.
    + static fn new(out: ?Writer (null), level: Level (Level.info), format: Format (Format.text)) Logger
    // Writes a warning record.
    + fn warn(message: String, fields: ?Map[Field] (null)) void
    // Returns a logger that writes where this one does and adds `fields` to every record, after the fields this logger already adds.
    + fn with(fields: Map[Field]) Logger
    // Writes a record of `level` with `message` and `fields`, when the level is enabled.
    + fn write(level: Level, message: String, fields: ?Map[Field] (null)) void
}
```

### Logger

Writes log records to one `io.Writer`, one write per record.

`log.info` and the other functions of this namespace use a logger per thread, made from
the process-wide settings of `set_level`, `set_format`, `set_local_time` and `to_stderr`,
`to_stdout` or `to_file`. Create a logger yourself to write elsewhere, such as into a
`ByteBuffer`; like the writer it holds, it belongs to the thread that made it. Write errors
are ignored.

#### format

The layout of the records.

#### level

The lowest level that is written.

#### local_time

Whether timestamps use the local time zone instead of UTC.

#### debug

Writes a debug record.

#### enabled

Returns whether a record of `level` would be written; use it to skip preparing
expensive fields.

#### error

Writes an error record.

#### info

Writes an info record.

#### new

Returns a logger that writes to `out`, standard error when it is null.

#### warn

Writes a warning record.

#### with

Returns a logger that writes where this one does and adds `fields` to every record,
after the fields this logger already adds.

Use it for context that many records share, such as a request id.

#### write

Writes a record of `level` with `message` and `fields`, when the level is enabled.

A field of the record replaces a field of the logger with the same key. A text record reads `2024-03-05T14:07:09.250Z INFO  message key=value`; a JSON record
`{"time":"...","level":"info","msg":"message","key":"value"}`.

# markdown

## Functions for 'markdown'

```js
// Converts the markdown text `md` to an HTML fragment.
+ fn to_html(md: String, options: ?ToHtmlOptions (null)) String
// Writes `to_html(md)` to `out` and returns the bytes written.
+ fn to_html_into(md: String, out: Writer, options: ?ToHtmlOptions (null)) uint !io:IoError
```

### to_html

Converts the markdown text `md` to an HTML fragment.

Supports `#` and underlined headings, paragraphs, `>` quotes, `-`/`+`/`*` and `1.`
lists, fenced code blocks, `---`/`***`/`* * *` rules, inline code, `*` emphasis,
`**`/`__` bold, `~~` strikethrough, links and images with an optional `"title"`, and
backslash escapes of punctuation. Raw HTML is not supported: every `<`, `>`, `"`,
`'` and `&` in the input is escaped, so the output is safe to embed. Lines of one
paragraph are joined with `<br>`, headings get no inline formatting, and an ordered list
must start at `1.`. Quotes and lists nest at most 64 levels deep; deeper markers stay text.

### to_html_into

Writes `to_html(md)` to `out` and returns the bytes written.

A `ByteBuffer` is written directly; any other writer receives the HTML in one write.
Throws when `out` fails.

## Classes for 'markdown'

```js
// Options for `to_html`.
+ class ToHtmlOptions {
    // The URL schemes a link or image may use; case does not matter.
    + allowed_schemes: Array[String]
    // The `class` attribute given to the `<code>` element of every fenced code block.
    + code_class: ?String
    // The `class` attribute given to every `<p>` element.
    + paragraph_class: ?String
}
```

### ToHtmlOptions

Options for `to_html`.

#### allowed_schemes

The URL schemes a link or image may use; case does not matter.

A link to any other scheme (`javascript:`, `data:`, `file:`, ...) loses its anchor and
keeps its text, and such an image is dropped. A URL without a scheme (`/x`, `./x`,
`#anchor`, `?query`, `//host/x`) is relative and always allowed.

#### code_class

The `class` attribute given to the `<code>` element of every fenced code block.

#### paragraph_class

The `class` attribute given to every `<p>` element.

# math

## Aliases for 'math'

```js
// Euler's number, the base of the natural logarithm.
+ value E (2.718281828459045)
// The ratio of a circle's circumference to its diameter.
+ value PI (3.141592653589793)
// Two times `PI`, one full turn in radians.
+ value TAU (6.283185307179586)
```

### E

Euler's number, the base of the natural logarithm.

### PI

The ratio of a circle's circumference to its diameter.

### TAU

Two times `PI`, one full turn in radians.

## Functions for 'math'

```js
// Returns the absolute value of `value`.
+ fn abs(value: float) float
// Returns the arc cosine of `value` in radians, in the range 0 to `PI`.
+ fn acos(value: float) float
// Returns the arc sine of `value` in radians, in the range -`PI`/2 to `PI`/2.
+ fn asin(value: float) float
// Returns the arc tangent of `value` in radians, in the range -`PI`/2 to `PI`/2.
+ fn atan(value: float) float
// Returns the angle in radians of the point (`x`, `y`), in the range -`PI` to `PI`.
+ fn atan2(y: float, x: float) float
// Returns the cube root of `value`; negative inputs give negative results.
+ fn cbrt(value: float) float
// Returns the smallest whole number not less than `value`.
+ fn ceil(value: float) float
// Returns the cosine of `value`, an angle in radians.
+ fn cos(value: float) float
// Returns `E` raised to the power `value`.
+ fn exp(value: float) float
// Returns 2 raised to the power `value`.
+ fn exp2(value: float) float
// Returns the largest whole number not greater than `value`.
+ fn floor(value: float) float
// Returns the length of the hypotenuse, `sqrt(x * x + y * y)`, without intermediate overflow.
+ fn hypot(x: float, y: float) float
// Returns the natural (base `E`) logarithm of `value`.
+ fn log(value: float) float
// Returns the base-10 logarithm of `value`.
+ fn log10(value: float) float
// Returns the base-2 logarithm of `value`.
+ fn log2(value: float) float
// Returns the floating-point remainder of `value / divisor`.
+ fn mod(value: float, divisor: float) float
// Returns `base` raised to the power `exponent`.
+ fn pow(base: float, exponent: float) float
// Returns `value` rounded to the nearest whole number, halfway cases away from zero.
+ fn round(value: float) float
// Returns the sine of `value`, an angle in radians.
+ fn sin(value: float) float
// Returns the square root of `value`; negative values give NaN.
+ fn sqrt(value: float) float
// Returns the tangent of `value`, an angle in radians.
+ fn tan(value: float) float
// Returns `value` with its fractional part removed, rounding toward zero.
+ fn trunc(value: float) float
```

### abs

Returns the absolute value of `value`.

### acos

Returns the arc cosine of `value` in radians, in the range 0 to `PI`.

NaN when `value` is outside -1..1.

### asin

Returns the arc sine of `value` in radians, in the range -`PI`/2 to `PI`/2.

NaN when `value` is outside -1..1.

### atan

Returns the arc tangent of `value` in radians, in the range -`PI`/2 to `PI`/2.

### atan2

Returns the angle in radians of the point (`x`, `y`), in the range -`PI` to `PI`.

Unlike `atan(y / x)` it uses the signs of both arguments to pick the quadrant.

### cbrt

Returns the cube root of `value`; negative inputs give negative results.

### ceil

Returns the smallest whole number not less than `value`.

### cos

Returns the cosine of `value`, an angle in radians.

### exp

Returns `E` raised to the power `value`.

### exp2

Returns 2 raised to the power `value`.

### floor

Returns the largest whole number not greater than `value`.

### hypot

Returns the length of the hypotenuse, `sqrt(x * x + y * y)`, without intermediate overflow.

### log

Returns the natural (base `E`) logarithm of `value`.

Zero gives negative infinity; negative values give NaN.

### log10

Returns the base-10 logarithm of `value`.

### log2

Returns the base-2 logarithm of `value`.

### mod

Returns the floating-point remainder of `value / divisor`.

The result has the sign of `value` (C `fmod`), so `mod(-1.0, 3.0)` is `-1.0`, not `2.0`.

### pow

Returns `base` raised to the power `exponent`.

### round

Returns `value` rounded to the nearest whole number, halfway cases away from zero.

`math.round(2.5)` is `3` and `math.round(-2.5)` is `-3`, as in C, Go and Rust. Formatting
with a fixed number of decimals rounds halves to the even digit instead:
`(2.5).to_string(0)` is `2`.

### sin

Returns the sine of `value`, an angle in radians.

### sqrt

Returns the square root of `value`; negative values give NaN.

### tan

Returns the tangent of `value`, an angle in radians.

### trunc

Returns `value` with its fractional part removed, rounding toward zero.

# mem

## Functions for 'mem'

```js
// Allocates `size` bytes of unmanaged, uninitialized memory with `malloc`.
+ fn alloc(size: uint) ptr
// Returns whether the `len` bytes at `a` and `b` match, ignoring ASCII letter case.
+ fn ascii_bytes_equal_ignore_case(a: ptr, b: ptr, len: uint) bool
// Converts the ASCII letters `A`-`Z` in the `len` bytes at `adr` to lower case, in place.
+ fn ascii_bytes_to_lower(adr: ptr, len: uint) void
// Returns whether `a` and `b` have the same length and bytes, ignoring ASCII letter case.
+ fn ascii_equal_ignore_case(a: local &[u8], b: local &[u8]) bool
// Converts the ASCII letters `A`-`Z` in `view` to lower case, in place.
+ fn ascii_to_lower(view: local mut &[u8]) void
// Parses the `len` bytes at `adr` as a decimal unsigned integer.
+ fn bytes_to_uint(adr: ptr, len: uint, allow_plus: bool (false)) uint !SyntaxError
// Allocates `size` bytes of unmanaged memory set to zero; release it with `free`.
+ fn calloc(size: uint) ptr
// Sets every byte of `view` to zero.
+ fn clear(view: local mut &[u8]) void
// Sets `length` bytes at `adr` to zero.
+ fn clear_bytes(adr: ptr, length: uint) void
// Sets the `T` at `value` to all zero bytes.
+ fn clear_value[T](value: *T) void
// Copies the bytes of `from` to the start of `to` and returns the number copied.
+ fn copy(from: local &[u8], to: local mut &[u8]) uint
// Copies `length` bytes from `from` to `to`; the two ranges must not overlap.
+ fn copy_bytes(from: ptr, to: ptr, length: uint) void
// Copies the `T` at `from` to `to`; the two must not overlap.
+ fn copy_value[T](from: *T, to: *T) void
// Deprecated: old name of `equals_bytes`, kept because 0.7.0 shipped it.
+ fn equal_bytes(a: ptr, b: ptr, length: uint) bool $deprecated
// Returns whether `a` and `b` have the same length and bytes.
+ fn equals(a: local &[u8], b: local &[u8]) bool
// Returns whether the `length` bytes at `a` and `b` are identical.
+ fn equals_bytes(a: ptr, b: ptr, length: uint) bool
// Returns the byte index of the first `ch` in `view`.
+ fn find_char(view: local &[u8], ch: u8) uint !LookupError
// Returns the byte index of the first `ch` in the `length` bytes at `adr`.
+ fn find_char_bytes(adr: ptr, ch: u8, length: uint) uint !LookupError
// Releases memory obtained from `alloc`, `calloc`, `new` or `resize`.
+ fn free(value: ptr) void
// Copies the bytes of `from` to the start of `to` and returns the number copied.
+ fn move(from: local &[u8], to: local mut &[u8]) uint
// Copies `length` bytes from `from` to `to`; the two ranges may overlap.
+ fn move_bytes(from: ptr, to: ptr, length: uint) void
// Copies the `T` at `from` to `to`; the two may overlap.
+ fn move_value[T](from: *T, to: *T) void
// Allocates unmanaged memory for one `T` and stores `initial` in it.
+ fn new[T](initial: T (T.$default_value)) *T
// Moves the memory at `adr` into a new allocation of `new_size` bytes and frees the old one.
+ fn resize(adr: ptr, size: uint, new_size: uint) ptr
// Parses `view` as a decimal unsigned integer.
+ fn to_uint(view: local &[u8], allow_plus: bool (false)) uint !SyntaxError
```

### alloc

Allocates `size` bytes of unmanaged, uninitialized memory with `malloc`.

Panics when the allocation fails; a `size` of 0 may return a null pointer. The memory is
not tracked by the GC; release it with `free`.

### ascii_bytes_equal_ignore_case

Returns whether the `len` bytes at `a` and `b` match, ignoring ASCII letter case.

Only `A`-`Z` are folded; other bytes, including non-ASCII ones, must match exactly.

### ascii_bytes_to_lower

Converts the ASCII letters `A`-`Z` in the `len` bytes at `adr` to lower case, in place.

### ascii_equal_ignore_case

Returns whether `a` and `b` have the same length and bytes, ignoring ASCII letter case.

Only `A`-`Z` are folded; other bytes, including non-ASCII ones, must match exactly.

### ascii_to_lower

Converts the ASCII letters `A`-`Z` in `view` to lower case, in place.

### bytes_to_uint

Parses the `len` bytes at `adr` as a decimal unsigned integer.

Only digits are accepted, plus one leading `+` when `allow_plus` is set; leading zeros are
fine. Throws `SyntaxError` for an empty input, any other byte or a value above the `uint`
maximum.

### calloc

Allocates `size` bytes of unmanaged memory set to zero; release it with `free`.

### clear

Sets every byte of `view` to zero.

### clear_bytes

Sets `length` bytes at `adr` to zero.

### clear_value

Sets the `T` at `value` to all zero bytes.

`T` must be an inline value type without GC references; anything else is a compile error.

### copy

Copies the bytes of `from` to the start of `to` and returns the number copied.

Copies at most `to.length` bytes. The two views must not overlap; use `move` when they may.

### copy_bytes

Copies `length` bytes from `from` to `to`; the two ranges must not overlap.

### copy_value

Copies the `T` at `from` to `to`; the two must not overlap.

`T` must be an inline value type without GC references; anything else is a compile error.

### equal_bytes

Deprecated: old name of `equals_bytes`, kept because 0.7.0 shipped it.

### equals

Returns whether `a` and `b` have the same length and bytes.

### equals_bytes

Returns whether the `length` bytes at `a` and `b` are identical.

### find_char

Returns the byte index of the first `ch` in `view`.

Throws `LookupError` when the byte does not occur.

### find_char_bytes

Returns the byte index of the first `ch` in the `length` bytes at `adr`.

Throws `LookupError` when the byte does not occur.

### free

Releases memory obtained from `alloc`, `calloc`, `new` or `resize`.

Takes a raw pointer, so a call needs `@unsafe`: nothing checks that the memory came from
these functions or is still in use.

### move

Copies the bytes of `from` to the start of `to` and returns the number copied.

Copies at most `to.length` bytes. The two views may overlap.

### move_bytes

Copies `length` bytes from `from` to `to`; the two ranges may overlap.

### move_value

Copies the `T` at `from` to `to`; the two may overlap.

`T` must be an inline value type without GC references; anything else is a compile error.

### new

Allocates unmanaged memory for one `T` and stores `initial` in it.

`T` must be an inline value type (a struct or number) without GC references; anything else
is a compile error. Release the memory with `free`.

### resize

Moves the memory at `adr` into a new allocation of `new_size` bytes and frees the old one.

Copies the first `size` bytes (or fewer when shrinking); bytes past `size` are
uninitialized. Returns `adr` itself when the size does not change. The old pointer is
invalid afterwards.

### to_uint

Parses `view` as a decimal unsigned integer.

Only digits are accepted, plus one leading `+` when `allow_plus` is set; leading zeros are
fine. Throws `SyntaxError` for an empty view, any other byte or a value above the `uint`
maximum.

# net

## Aliases for 'net'

```js
// An IPv4 or IPv6 address with a port: the peer of a datagram, or a bound endpoint. The buffer size `SocketAddress.ip_in` and `to_string_in` require.
+ value ADDRESS_TEXT_SIZE (64)
type c_long (int)
```

### ADDRESS_TEXT_SIZE

An IPv4 or IPv6 address with a port: the peer of a datagram, or a bound endpoint.
The buffer size `SocketAddress.ip_in` and `to_string_in` require.

## Errors for 'net'

```js
// Thrown by address resolution, sockets, connections and TLS.
error NetError (init, connect, disconnected, invalid_host, ssl, port_in_use, max_connections) extends (io:IoError)
```

### NetError

Thrown by address resolution, sockets, connections and TLS.

- `init`: a socket could not be created or configured, `accept` failed, or the
  resolver thread could not start.
- `connect`: connecting to the remote address failed.
- `disconnected`: not raised by the standard library.
- `invalid_host`: the host could not be resolved, is not numeric where a numeric
  address is required, or has an unsupported address family.
- `ssl`: TLS setup failed (certificate, key, CA file, version, ciphers, ALPN, SNI) or
  the TLS handshake failed.
- `port_in_use`: binding or listening failed because the address is already in use;
  other bind failures throw `access` or `os`.
- `max_connections`: `accept` hit the process or system file descriptor limit.

Also carries every `io.IoError` code.

## Enums for 'net'

```js
// A TLS protocol version, for the minimum and maximum version settings.
+ enum TlsVersion : i32 { tls_1_2 (TLS1_2_VERSION), tls_1_3 (TLS1_3_VERSION) }
```

### TlsVersion

A TLS protocol version, for the minimum and maximum version settings.

## Functions for 'net'

```js
// Receives once from the socket `fd` into `buf` and returns the number of bytes read.
+ fn recv(fd: i32, buf: local mut &[u8], timeout_ms: uint (5000)) uint !io:IoError
// Connects to a TCP server; the same as `TcpConnection.new`.
+ fn tcp_client(host: String, port: u16, timeout_ms: uint (5000), local_port: u16 (0), local_host: String ("")) TcpConnection !NetError
// Opens a listening TCP socket; the same as `TcpServer.new`.
+ fn tcp_server(host: String, port: u16, timeout_ms: uint (5000), reuse_port: bool (false)) shared TcpServer !NetError
// Opens a UDP socket that talks to one server; the same as `UdpClient.new`.
+ fn udp_client(host: String, port: u16, timeout_ms: uint (5000), local_port: u16 (0), local_host: String ("")) UdpClient !NetError
// Binds a UDP socket to your own address; the same as `UdpServer.new`.
+ fn udp_server(host: String, port: u16, timeout_ms: uint (5000), reuse_address: bool (false)) UdpServer !NetError
// Sends once from `data` on the socket `fd` and returns the number of bytes sent.
+ fn write(fd: i32, data: local &[u8], timeout_ms: uint (5000)) uint !io:IoError
```

### recv

Receives once from the socket `fd` into `buf` and returns the number of bytes read.

Returns 0 when the peer closed its end. `timeout_ms` 0 waits forever. Throws
`timeout`, `read`, or `closed` on macOS when the descriptor reports hang-up.

### tcp_client

Connects to a TCP server; the same as `TcpConnection.new`.

### tcp_server

Opens a listening TCP socket; the same as `TcpServer.new`.

### udp_client

Opens a UDP socket that talks to one server; the same as `UdpClient.new`.

### udp_server

Binds a UDP socket to your own address; the same as `UdpServer.new`.

### write

Sends once from `data` on the socket `fd` and returns the number of bytes sent.

May send fewer bytes than `data.length`; call again for the rest (`TcpConnection.write`
does). `timeout_ms` 0 waits forever. Throws `timeout`, `write`, or `closed` on macOS.

## Classes for 'net'

```js
// A resolved host: the list `getaddrinfo` returned, with one entry chosen.
+ class AddrInfo {
    // The whole list `getaddrinfo` returned; freed when this object is collected.
    ~ data: *libc_gen_addrinfo
    // The address family of the chosen entry (`AF_INET` or `AF_INET6`).
    ~+ family: i32

    // Returns the size in bytes of the C `sockaddr` behind `sock_addr`.
    + fn addr_len() u32
    // Returns the chosen entry as a `SocketAddress`.
    + fn address() SocketAddress !NetError
    // Returns true when the chosen entry is an IPv6 address.
    + fn is_ipv6() bool
    // Resolves `host` and `port` for a stream socket, or a datagram socket when `datagram` is set.
    + static fn new(host: String, port: u16, timeout_ms: uint (5000), datagram: bool (false), numeric_only: bool (false)) AddrInfo !NetError
    // Returns a pointer to the C `sockaddr` of the chosen entry; valid while this object lives.
    + fn sock_addr() *libc_gen_sockaddr
}
```

### AddrInfo

A resolved host: the list `getaddrinfo` returned, with one entry chosen.

IPv4 and IPv6 are both accepted; when a name resolves to both, the first IPv4 entry is
used, and a TCP connect that fails there tries the other entries. The list is freed when
the object is collected.

#### data

The whole list `getaddrinfo` returned; freed when this object is collected.

#### family

The address family of the chosen entry (`AF_INET` or `AF_INET6`).

#### addr_len

Returns the size in bytes of the C `sockaddr` behind `sock_addr`.

#### address

Returns the chosen entry as a `SocketAddress`.

Throws `invalid_host` when the entry is neither IPv4 nor IPv6.

#### is_ipv6

Returns true when the chosen entry is an IPv6 address.

#### new

Resolves `host` and `port` for a stream socket, or a datagram socket when `datagram` is set.

An IPv6 literal may be written in brackets. Numeric hosts are converted without a
lookup. Names are looked up on a background task so the wait can end after
`timeout_ms` with `timeout`; `timeout_ms` 0 does the lookup on the calling thread,
blocking it until the system answers. `numeric_only` refuses names with
`invalid_host`, so the call never blocks. Throws `invalid_host` when the lookup fails
and `init` when the background task cannot start.

#### sock_addr

Returns a pointer to the C `sockaddr` of the chosen entry; valid while this object lives.

```js
+ struct SocketAddress {
    // True for an IPv6 address, false for IPv4.
    + ipv6: bool
    // The port number, in host byte order.
    + port: u16
    // The IPv6 zone index (`fe80::1%2`); 0 for IPv4 and global addresses.
    + scope_id: u32

    // Returns true when both addresses have the same family, bytes, port and scope id.
    + fn equals(other: SocketAddress) bool
    // Returns the address without the port, as `"127.0.0.1"` or `"::1"`.
    + fn ip() String
    // Writes `ip()` into `buf` and returns the byte count.
    + fn ip_in(buf: local mut &[u8]) uint
    // Returns the IPv4 address `a.b.c.d` with `port`.
    + static fn ipv4(a: u8, b: u8, c: u8, d: u8, port: u16 (0)) SocketAddress
    // Parses a numeric host such as `"127.0.0.1"`, `"::1"` or `"[::1]"`; never does a DNS lookup.
    + static fn parse(host: String, port: u16 (0)) SocketAddress !NetError
    // Resolves a host name or numeric host to one address, preferring IPv4 when both exist.
    + static fn resolve(host: String, port: u16, timeout_ms: uint (5000)) SocketAddress !NetError
    // Returns the address with its port, as `"127.0.0.1:80"` or `"[::1]:80"`.
    + fn to_string() String
    // Writes `to_string()` into `buf` and returns the byte count.
    + fn to_string_in(buf: local mut &[u8]) uint
}
```

#### ipv6

True for an IPv6 address, false for IPv4.

#### port

The port number, in host byte order.

#### scope_id

The IPv6 zone index (`fe80::1%2`); 0 for IPv4 and global addresses.

#### equals

Returns true when both addresses have the same family, bytes, port and scope id.

#### ip

Returns the address without the port, as `"127.0.0.1"` or `"::1"`.

IPv6 is written in the RFC 5952 short form (lowercase hex, the longest run of two or
more zero groups as `::`), followed by `%scope_id` when the scope id is not 0.

#### ip_in

Writes `ip()` into `buf` and returns the byte count.

`buf` must hold at least `ADDRESS_TEXT_SIZE` (64) bytes; a shorter buffer panics.

#### ipv4

Returns the IPv4 address `a.b.c.d` with `port`.

#### parse

Parses a numeric host such as `"127.0.0.1"`, `"::1"` or `"[::1]"`; never does a DNS lookup.

Throws `invalid_host` when `host` is a name or not a valid address.

#### resolve

Resolves a host name or numeric host to one address, preferring IPv4 when both exist.

Throws `invalid_host` when the lookup fails and `timeout` when it takes longer than
`timeout_ms` (0 waits as long as the lookup takes, on the calling thread). A lookup
that timed out keeps running on a background thread until the system returns.

#### to_string

Returns the address with its port, as `"127.0.0.1:80"` or `"[::1]:80"`.

#### to_string_in

Writes `to_string()` into `buf` and returns the byte count.

`buf` must hold at least `ADDRESS_TEXT_SIZE` (64) bytes; a shorter buffer panics.

```js
// One TLS session over one socket, either client or server side.
+ class Ssl {
    // The CA directory last given to `set_ca_cert_dir`; `null` when none is set.
    ~ cert_dir: ?String
    // The CA file last given to `set_ca_cert`; `null` when none is set.
    ~ cert_file: ?String
    // True from a successful handshake until `close`.
    ~ connected: bool
    // The OpenSSL `SSL_CTX` handle.
    ~ ctx: SSL_CTX
    // The OpenSSL error code recorded when a handshake failed; 0 when none was.
    ~ error_code: uint
    // The socket descriptor the handshake ran on.
    ~ fd: i32
    // True once `set_host` named the server; `TcpConnection.ssl_connect` then keeps that name.
    ~ host_set: bool
    // The OpenSSL `SSL` handle.
    ~ ssl: OSSL

    // Runs the server handshake on the socket `fd`.
    + fn accept(fd: i32, timeout_ms: uint (5000)) void !NetError
    // Sends the TLS close notify; does nothing on a second call or before a handshake.
    + fn close(timeout_ms: uint (5000)) void !NetError
    // Runs the client handshake on the socket `fd`.
    + fn connect(fd: i32, timeout_ms: uint (5000)) void !NetError
    // Records `msg` as the error message and throws `ssl`.
    + fn custom_error(msg: String) void !NetError
    // Returns the CA bundle files `new` tries, in order.
    + static fn default_ca_cert_paths() Array[String]
    // Returns the OpenSSL error code of the last failed handshake; 0 when there was none.
    + fn get_error() uint
    // Returns the text of the last recorded error.
    + fn get_error_message() String
    // Returns a client session that verifies the server certificate.
    + static fn new() Ssl
    // Returns the SHA-256 fingerprint of the peer certificate as 64 lowercase hex characters.
    + fn peer_certificate_sha256() String !NetError
    // Returns the subject of the peer certificate in RFC 2253 form, such as `CN=alice,O=Example`.
    + fn peer_certificate_subject() String !NetError
    // Reads up to `buf.length` decrypted bytes into `buf` and returns the count.
    + fn recv(buf: local mut &[u8], timeout_ms: uint (5000)) uint !NetError
    // Returns the ALPN protocol agreed in the handshake, or `""` when none was.
    + fn selected_alpn() String
    // Sets the ALPN protocols to offer (such as `"h2"`, `"http/1.1"`), most preferred first.
    + fn set_alpn(protocols: Array[String]) void !NetError
    // Trusts the CA certificates in the PEM file `path` and stores it as `cert_file`.
    + fn set_ca_cert(path: ?String) void !NetError
    // Trusts the CA directory `dir` (OpenSSL `c_rehash` layout) and stores it as `cert_dir`.
    + fn set_ca_cert_dir(dir: ?String) void !NetError
    // Presents a certificate to the server during the handshake, for servers that ask clients to prove who they are (mutual TLS).
    + fn set_certificate(certificate_file: String, private_key_file: String, password: String ("")) void !NetError
    // Sets the TLS 1.2 and older ciphers as an OpenSSL cipher string.
    + fn set_cipher_list(ciphers: String) void !NetError
    // Sets the TLS 1.3 cipher suites as colon-separated names.
    + fn set_cipher_suites(ciphers: String) void !NetError
    // Sets `host` as the server name (SNI) and as the name the peer certificate must match.
    + fn set_host(host: String) void !NetError
    // Sets the highest TLS version this session accepts; throws `ssl` when OpenSSL rejects it.
    + fn set_max_version(version: TlsVersion) void !NetError
    // Sets the lowest TLS version this session accepts; throws `ssl` when OpenSSL rejects it.
    + fn set_min_version(version: TlsVersion) void !NetError
    // Turns verification of the peer certificate on or off for this session.
    + fn set_verify(enable: bool) void
    // Encrypts and sends all of `data`; returns the number of bytes written.
    + fn write(data: local &[u8], timeout_ms: uint (5000)) uint !NetError
}
```

### Ssl

One TLS session over one socket, either client or server side.

Client sessions come from `new`, server sessions from `SslServerContext.connection`.
Usually driven through `TcpConnection.ssl_connect` / `ssl_accept` and then `TcpConnection`'s
`read` and `write`. OpenSSL resources are freed when the object is collected.

#### cert_dir

The CA directory last given to `set_ca_cert_dir`; `null` when none is set.

#### cert_file

The CA file last given to `set_ca_cert`; `null` when none is set.

#### connected

True from a successful handshake until `close`.

#### ctx

The OpenSSL `SSL_CTX` handle.

#### error_code

The OpenSSL error code recorded when a handshake failed; 0 when none was.

#### fd

The socket descriptor the handshake ran on.

#### host_set

True once `set_host` named the server; `TcpConnection.ssl_connect` then keeps that name.

#### ssl

The OpenSSL `SSL` handle.

#### accept

Runs the server handshake on the socket `fd`.

Makes `fd` non-blocking and, on Linux, makes the process ignore `SIGPIPE`. Throws
`timeout` after `timeout_ms` (0 waits forever) of waiting, `closed` when the peer goes
away, `os`, and `ssl` for a failed handshake (see `get_error_message`).

#### close

Sends the TLS close notify; does nothing on a second call or before a handshake.

Does not wait for the peer's reply and does not close the socket. Throws `timeout`,
`closed` or `ssl`.

#### connect

Runs the client handshake on the socket `fd`.

Makes `fd` non-blocking and, on Linux, makes the process ignore `SIGPIPE`. Throws
`timeout` after `timeout_ms` (0 waits forever) of waiting, `closed` when the peer goes
away, `os`, and `ssl` for a failed handshake (see `get_error_message`).

#### custom_error

Records `msg` as the error message and throws `ssl`.

Tagged `$throw`, so it can be called where a `throw` statement is expected.

#### default_ca_cert_paths

Returns the CA bundle files `new` tries, in order.

OpenSSL's default certificate file first, then the usual system locations of the
platform, then `cacert.pem` in the working directory and next to the executable. The
list is built once per thread; each call returns a new copy of it.

#### get_error

Returns the OpenSSL error code of the last failed handshake; 0 when there was none.

#### get_error_message

Returns the text of the last recorded error.

That is OpenSSL's message for `get_error`, or the message given to `custom_error`.

#### new

Returns a client session that verifies the server certificate.

Loads the first CA bundle from `default_ca_cert_paths` that OpenSSL accepts, or
OpenSSL's default verify paths when none does; on Windows it then also trusts the
certificates of the system store, so no `cacert.pem` is needed. Each session owns its
own OpenSSL context. Tagged `$default`, so it also supplies `Ssl`'s default value.

#### peer_certificate_sha256

Returns the SHA-256 fingerprint of the peer certificate as 64 lowercase hex characters.

Hashes the peer's own certificate: the server's on a client, the client's on a server.
Throws `ssl` when the peer sent no certificate.

#### peer_certificate_subject

Returns the subject of the peer certificate in RFC 2253 form, such as
`CN=alice,O=Example`.

The peer's own certificate: the server's on a client, the client's on a server. Throws
`ssl` when the peer sent no certificate.

#### recv

Reads up to `buf.length` decrypted bytes into `buf` and returns the count.

Returns 0 when the peer closed the TLS session. While a `write` on this session is
blocked, waits for it first (OpenSSL requires that order), polling every millisecond.
`timeout_ms` 0 waits forever. Throws `ssl` before a handshake or on a protocol error,
`timeout` and `closed`.

#### selected_alpn

Returns the ALPN protocol agreed in the handshake, or `""` when none was.

#### set_alpn

Sets the ALPN protocols to offer (such as `"h2"`, `"http/1.1"`), most preferred first.

Throws `ssl` when the list is empty, a name is empty or longer than 255 bytes, or
OpenSSL rejects it.

#### set_ca_cert

Trusts the CA certificates in the PEM file `path` and stores it as `cert_file`.

Certificates are added to those already trusted, and the `cert_dir` set with
`set_ca_cert_dir` is loaded along with the file. `null` clears `cert_file`;
certificates loaded before stay trusted. On Windows a UNC path (`\\server\share`) is
refused. Throws `ssl` when OpenSSL rejects the file or the directory.

#### set_ca_cert_dir

Trusts the CA directory `dir` (OpenSSL `c_rehash` layout) and stores it as `cert_dir`.

The directory is added to what is already trusted, and the `cert_file` set with
`set_ca_cert` is loaded along with it. `null` clears `cert_dir`; what was loaded before
stays trusted. On Windows a UNC path is refused. Throws `ssl` when OpenSSL rejects the
directory or the file.

#### set_certificate

Presents a certificate to the server during the handshake, for servers that ask clients
to prove who they are (mutual TLS).

`certificate_file` is PEM: the client certificate, optionally followed by the
intermediate certificates that lead to a CA the server trusts. `private_key_file` is its
PEM key, and `password` unlocks an encrypted one. Call it before the handshake. Throws
`ssl` when a file cannot be read, the password is wrong, or the key does not belong to
the certificate.

#### set_cipher_list

Sets the TLS 1.2 and older ciphers as an OpenSSL cipher string.

Throws `ssl` when no cipher in it is usable.

#### set_cipher_suites

Sets the TLS 1.3 cipher suites as colon-separated names.

Throws `ssl` when OpenSSL rejects them.

#### set_host

Sets `host` as the server name (SNI) and as the name the peer certificate must match.

A numeric IPv4 or IPv6 address (`"[::1]"` too) is not sent as a server name; the peer
certificate must match it as an IP address instead. Throws `ssl` when OpenSSL rejects
the name or address.

#### set_max_version

Sets the highest TLS version this session accepts; throws `ssl` when OpenSSL rejects it.

#### set_min_version

Sets the lowest TLS version this session accepts; throws `ssl` when OpenSSL rejects it.

#### set_verify

Turns verification of the peer certificate on or off for this session.

#### write

Encrypts and sends all of `data`; returns the number of bytes written.

`timeout_ms` 0 waits forever. Throws `ssl` before a handshake, `timeout`, `closed`
and `write`.

```js
// Server-side TLS settings (certificate, key, versions, ciphers) shared by all connections.
+ class SslServerContext {
    // The OpenSSL `SSL_CTX` handle.
    ~ ctx: SSL_CTX

    // Returns a new server session using `context`, for one connection.
    + static fn connection(context: shared SslServerContext) Ssl
    // Loads the PEM `certificate_file` and `private_key_file` and checks that they match.
    + static fn new(certificate_file: String, private_key_file: String, min_version: TlsVersion (TlsVersion.tls_1_2), cipher_list: ?String (null), cipher_suites: ?String (null)) SslServerContext !NetError
    // Asks every client for a certificate that leads to a CA in the PEM file `ca_file` (mutual TLS), and tells clients which CAs those are.
    + fn set_client_ca(ca_file: String, required: bool (true)) void !NetError
}
```

### SslServerContext

Server-side TLS settings (certificate, key, versions, ciphers) shared by all connections.

Share one context and call `TcpConnection.ssl_accept` with it for each accepted connection.
The OpenSSL context is freed when the object is collected.

#### ctx

The OpenSSL `SSL_CTX` handle.

#### connection

Returns a new server session using `context`, for one connection.

The session keeps `context` alive. `TcpConnection.ssl_accept` calls this for you.

#### new

Loads the PEM `certificate_file` and `private_key_file` and checks that they match.

`cipher_list` (OpenSSL cipher string) applies to TLS 1.2, `cipher_suites` (colon-separated
names) to TLS 1.3; `null` keeps OpenSSL's defaults. Throws `ssl` when a file cannot be
loaded, the key does not match, or a setting is rejected.

#### set_client_ca

Asks every client for a certificate that leads to a CA in the PEM file `ca_file`
(mutual TLS), and tells clients which CAs those are.

With `required` a client without a valid certificate fails the handshake; without it a
client may send none, but one it sends must be valid. On an accepted connection,
`Ssl.peer_certificate_subject` and `Ssl.peer_certificate_sha256` say who the client is.
Call it before the context serves connections. Throws `ssl` when OpenSSL cannot read
the file.

```js
// A connected TCP stream, optionally with TLS, read and written from a coroutine.
+ class TcpConnection is Reader, Writer, Closer {
    // The OS socket descriptor.
    ~ fd: i32
    // The host the connection was made to; empty for accepted connections and `new`.
    ~+ host: String
    // Milliseconds a single `read` may wait for data; 0 waits forever.
    + read_timeout_ms: uint
    // The TLS session, once `ssl_connect` or `ssl_accept` succeeded.
    ~ ssl: ?Ssl
    // True once a TLS handshake succeeded; reads and writes then go through TLS.
    ~ ssl_enabled: bool
    // Milliseconds each send inside `write` may wait; 0 waits forever.
    + write_timeout_ms: uint

    // Closes the connection; does nothing when already closed.
    + fn close() void !io:IoError
    // Returns the address of this end of the connection.
    + fn local_address() SocketAddress !NetError
    // Resolves `host` and connects to it and `port` over TCP; also `net.tcp_client`.
    + static fn new(host: String, port: u16, timeout_ms: uint (5000), local_port: u16 (0), local_host: String ("")) TcpConnection !NetError
    // Returns the address of the peer.
    + fn peer_address() SocketAddress !NetError
    // Reads up to `buf.length` bytes into `buf` and returns the count.
    + fn read(buf: local mut &[u8]) uint !io:IoError
    // Makes pending and later reads and writes throw `cancelled` once `token` is cancelled.
    + fn set_cancel(token: shared CancelToken) void
    // Whether small writes are sent right away. On by default: with it off (Nagle's algorithm) a write that follows another write waits for the peer's acknowledgement, which can add about 40 ms per response.
    + fn set_no_delay(enabled: bool) void !NetError
    // Asks the system for a receive buffer of `bytes`; it may round or cap the size.
    + fn set_receive_buffer(bytes: uint) void !NetError
    // Asks the system for a send buffer of `bytes`; it may round or cap the size.
    + fn set_send_buffer(bytes: uint) void !NetError
    // Sets `read_timeout_ms` and `write_timeout_ms`; 0 waits forever.
    + fn set_timeouts(read_timeout_ms: uint, write_timeout_ms: uint) void
    // Runs the TLS server handshake over this connection with a session from `context`.
    + fn ssl_accept(context: shared SslServerContext, timeout_ms: uint (5000)) void !NetError
    // Runs the TLS client handshake over this connection with `ssl`.
    + fn ssl_connect(ssl: Ssl, timeout_ms: uint (5000)) void !NetError
    // Wraps an already connected socket descriptor and takes ownership of it.
    + static fn wrap(fd: i32) TcpConnection !NetError
    // Sends all of `data` and returns its length.
    + fn write(data: local &[u8]) uint !io:IoError
}
```

### TcpConnection

A connected TCP stream, optionally with TLS, read and written from a coroutine.

The descriptor belongs to the connection: it is closed by `close` or when the object is
collected.

#### fd

The OS socket descriptor.

#### host

The host the connection was made to; empty for accepted connections and `new`.

#### read_timeout_ms

Milliseconds a single `read` may wait for data; 0 waits forever.

#### ssl

The TLS session, once `ssl_connect` or `ssl_accept` succeeded.

#### ssl_enabled

True once a TLS handshake succeeded; reads and writes then go through TLS.

#### write_timeout_ms

Milliseconds each send inside `write` may wait; 0 waits forever.

#### close

Closes the connection; does nothing when already closed.

With TLS a close notify is sent first (bounded by `write_timeout_ms`, failures
ignored). Throws `os` when closing the descriptor fails.

#### local_address

Returns the address of this end of the connection.

Throws `closed` after `close` and `os` when the system cannot report it.

#### new

Resolves `host` and connects to it and `port` over TCP; also `net.tcp_client`.

`timeout_ms` covers the lookup and the connect together; 0 waits without limit. The
connection's `host` is set to `host`, which `ssl_connect` uses as the TLS server
name. `local_port` and `local_host` bind the connection's own end; 0 and `""` (the
defaults) let the system choose. Throws `invalid_host`, `timeout`, `init`,
`port_in_use` or `access` when the local end cannot be bound, and `connect`.

#### peer_address

Returns the address of the peer.

Throws `closed` after `close` and `os` when the system cannot report it.

#### read

Reads up to `buf.length` bytes into `buf` and returns the count.

Never returns 0 for a non-empty `buf`: when the peer closed its end, `closed` is thrown.
Also throws `timeout` after `read_timeout_ms`, `cancelled` and `read`.

#### set_cancel

Makes pending and later reads and writes throw `cancelled` once `token` is cancelled.

The registration replaces any earlier token and lasts until `close`. When `token` is
already cancelled the connection is interrupted right away.

#### set_no_delay

Whether small writes are sent right away. On by default: with it off (Nagle's
algorithm) a write that follows another write waits for the peer's acknowledgement,
which can add about 40 ms per response.

Throws `closed` after `close` and `os` when the system refuses.

#### set_receive_buffer

Asks the system for a receive buffer of `bytes`; it may round or cap the size.

Throws `closed` after `close` and `os` when the system refuses.

#### set_send_buffer

Asks the system for a send buffer of `bytes`; it may round or cap the size.

Throws `closed` after `close` and `os` when the system refuses.

#### set_timeouts

Sets `read_timeout_ms` and `write_timeout_ms`; 0 waits forever.

#### ssl_accept

Runs the TLS server handshake over this connection with a session from `context`.

Does nothing when TLS is already enabled. Throws `ssl`, `timeout`, `closed` or `os`.

#### ssl_connect

Runs the TLS client handshake over this connection with `ssl`.

A non-empty `host` is passed to `Ssl.set_host`: a name is sent as the server name
(SNI) and the certificate must match it; an IP address is not sent, the certificate
must match it as an address. A name given with `ssl.set_host` before the call takes
its place, such as a certificate name that differs from the address connected to. With
an empty `host` (connections from `new` and `accept`) no server name is sent and no
name is checked, unless `ssl.set_host` was called. Does nothing when TLS is already
enabled. Throws `ssl`, `timeout`, `closed` or `os`.

#### wrap

Wraps an already connected socket descriptor and takes ownership of it.

On Linux and macOS the descriptor is made non-blocking; when that fails it is closed
and `os` is thrown.

#### write

Sends all of `data` and returns its length.

`write_timeout_ms` bounds each partial send, not the whole call. Throws `closed`,
`cancelled`, `timeout` or `write`.

```js
// A listening TCP socket, made by `new` or `net.tcp_server`; `accept` hands out connections.
+ class TcpServer is Closer {
    // The OS socket descriptor.
    ~ fd: i32
    // The host name or address the server was created for.
    ~ host: String
    // The port the server was created for.
    ~ port: u16

    // Waits for the next incoming connection and returns it.
    + fn accept(timeout_ms: uint (0)) TcpConnection !NetError
    // Closes the listening socket; connections already accepted stay open. Does nothing when already closed. Throws `os` when closing fails.
    + fn close() void !io:IoError
    // Returns the address the server listens on.
    + fn local_address() SocketAddress !NetError
    // Resolves `host`, binds to it and `port`, and starts listening; also `net.tcp_server`.
    + static fn new(host: String, port: u16, timeout_ms: uint (5000), reuse_port: bool (false)) shared TcpServer !NetError
}
```

### TcpServer

A listening TCP socket, made by `new` or `net.tcp_server`; `accept` hands out connections.

The descriptor is closed by `close` or when the object is collected.

#### fd

The OS socket descriptor.

#### host

The host name or address the server was created for.

#### port

The port the server was created for.

#### accept

Waits for the next incoming connection and returns it.

`timeout_ms` 0 waits forever; otherwise `timeout` is thrown when it runs out. Throws
`closed` after `close`, and `max_connections` when the process is out of file
descriptors (Linux and macOS).

#### close

Closes the listening socket; connections already accepted stay open. Does nothing
when already closed. Throws `os` when closing fails.

#### local_address

Returns the address the server listens on.

Throws `closed` after `close` and `os` when the system cannot report it.

#### new

Resolves `host`, binds to it and `port`, and starts listening; also `net.tcp_server`.

Sets `SO_REUSEADDR`, and `SO_REUSEPORT` when `reuse_port` is set so that several
processes may listen on the same port at once (not on Windows; used for zero-downtime
restarts). An IPv6 host such as `"::"` also accepts IPv4 clients where the
system allows it. Throws `invalid_host` or `timeout` when resolving fails, `init` when
the socket cannot be made, `port_in_use` when the address is already in use, `access`
when the system refuses it (such as a privileged port), and `os` when binding or
listening fails for another reason.

```js
// A UDP socket that talks to one server, made by `new` or `net.udp_client`.
+ class UdpClient is Reader, Writer, Closer {
    // The OS socket descriptor.
    ~ fd: i32
    // Milliseconds `read` may wait for a datagram; 0 waits forever.
    + read_timeout_ms: uint
    // Milliseconds `write` may wait; 0 waits forever.
    + write_timeout_ms: uint

    // Closes the socket; does nothing when already closed. Throws `os` when closing fails.
    + fn close() void !io:IoError
    // Returns the local address the system bound this socket to.
    + fn local_address() SocketAddress !NetError
    // Opens a socket to the server at `host` and `port`; also `net.udp_client`.
    + static fn new(host: String, port: u16, timeout_ms: uint (5000), local_port: u16 (0), local_host: String ("")) UdpClient !NetError
    // Returns the server's address.
    + fn peer_address() SocketAddress !NetError
    // Receives one datagram from the server into `buf` and returns its byte count.
    + fn read(buf: local mut &[u8]) uint !io:IoError
    // Allows sending to a broadcast address such as `255.255.255.255`.
    + fn set_broadcast(enabled: bool) void !NetError
    // Makes pending and later reads and writes throw `cancelled` once `token` is cancelled.
    + fn set_cancel(token: shared CancelToken) void
    // Sends multicast datagrams through the interface with the IPv4 address `interface_ip` (IPv4 sockets) instead of the default route.
    + fn set_multicast_interface_v4(interface_ip: String) void !NetError
    // Sends multicast datagrams through interface `interface_index` (IPv6 sockets); 0 is the default route.
    + fn set_multicast_interface_v6(interface_index: u32) void !NetError
    // Whether multicast datagrams this socket sends are also delivered to receivers on this machine; on by default.
    + fn set_multicast_loopback(enabled: bool) void !NetError
    // Sets the hop limit (TTL) used when the server is a multicast group; 1 (the system default) stays on the local network.
    + fn set_multicast_ttl(hops: u8) void !NetError
    // Asks the system for a receive buffer of `bytes`; it may round or cap the size.
    + fn set_receive_buffer(bytes: uint) void !NetError
    // Asks the system for a send buffer of `bytes`; it may round or cap the size.
    + fn set_send_buffer(bytes: uint) void !NetError
    // Sets the hop limit (TTL) of the datagrams sent.
    + fn set_ttl(hops: u8) void !NetError
    // Sends `data` to the server as one datagram and returns its length.
    + fn write(data: local &[u8]) uint !io:IoError
}
```

### UdpClient

A UDP socket that talks to one server, made by `new` or `net.udp_client`.

`write` sends the server one datagram and `read` receives one from it, so the socket
serves as an `io.Reader` and `io.Writer`. Datagrams from anyone else are dropped. To
receive from many peers use `UdpServer`. The descriptor is closed by `close` or when
the object is collected.

#### fd

The OS socket descriptor.

#### read_timeout_ms

Milliseconds `read` may wait for a datagram; 0 waits forever.

#### write_timeout_ms

Milliseconds `write` may wait; 0 waits forever.

#### close

Closes the socket; does nothing when already closed. Throws `os` when closing fails.

#### local_address

Returns the local address the system bound this socket to.

Throws `closed` after `close` and `os` when the system cannot report it.

#### new

Opens a socket to the server at `host` and `port`; also `net.udp_client`.

`local_port` and `local_host` bind the socket's own end; 0 and `""` (the defaults)
let the system choose (see `local_address`). Nothing is sent yet: the first `write`
shows whether anyone listens, and even that only when the network reports it. Throws
`invalid_host` or `timeout` when resolving fails, `init` when the socket cannot be
made, `port_in_use` or `access` when the local end cannot be bound, `os` when binding
fails for another reason, and `connect` when the system refuses the peer.

#### peer_address

Returns the server's address.

Throws `closed` after `close` and `os` when the system cannot report it.

#### read

Receives one datagram from the server into `buf` and returns its byte count.

A datagram larger than `buf` is cut to `buf.length` and the rest is lost. An empty
datagram returns 0, which stream helpers such as `io.copy` take as the end of input.
Throws `timeout` after `read_timeout_ms`, `closed`, and `read` when the receive fails.

#### set_broadcast

Allows sending to a broadcast address such as `255.255.255.255`.

Throws `closed` after `close` and `os` when the system refuses.

#### set_cancel

Makes pending and later reads and writes throw `cancelled` once `token` is cancelled.

The registration replaces any earlier token and lasts until `close`. When `token` is
already cancelled the socket is interrupted right away.

#### set_multicast_interface_v4

Sends multicast datagrams through the interface with the IPv4 address
`interface_ip` (IPv4 sockets) instead of the default route.

Throws `closed` after `close`, `invalid_host` when the address is not IPv4, and `os`.

#### set_multicast_interface_v6

Sends multicast datagrams through interface `interface_index` (IPv6 sockets); 0 is
the default route.

Throws `closed` after `close` and `os` when the system refuses.

#### set_multicast_loopback

Whether multicast datagrams this socket sends are also delivered to receivers on
this machine; on by default.

Throws `closed` after `close` and `os` when the system refuses.

#### set_multicast_ttl

Sets the hop limit (TTL) used when the server is a multicast group; 1 (the system
default) stays on the local network.

Throws `closed` after `close` and `os` when the system refuses.

#### set_receive_buffer

Asks the system for a receive buffer of `bytes`; it may round or cap the size.

Throws `closed` after `close` and `os` when the system refuses.

#### set_send_buffer

Asks the system for a send buffer of `bytes`; it may round or cap the size.

Throws `closed` after `close` and `os` when the system refuses.

#### set_ttl

Sets the hop limit (TTL) of the datagrams sent.

Throws `closed` after `close` and `os` when the system refuses.

#### write

Sends `data` to the server as one datagram and returns its length.

Throws `write` when the send fails (such as a datagram too large for the network),
`timeout` after `write_timeout_ms`, and `closed`.

```js
// A UDP socket bound to your own address, made by `new` or `net.udp_server`.
+ class UdpServer is Closer {
    // The OS socket descriptor.
    ~ fd: i32
    // Milliseconds `recv_from` may wait for a datagram; 0 waits forever.
    + read_timeout_ms: uint
    // Milliseconds `send_to` may wait; 0 waits forever.
    + write_timeout_ms: uint

    // Closes the socket; does nothing when already closed. Throws `os` when closing fails.
    + fn close() void !io:IoError
    // Starts receiving datagrams sent to the IPv4 multicast `group` (`224.0.0.0/4`) on the interface with address `interface_ip`; `"0.0.0.0"` (the default) lets the system pick.
    + fn join_multicast_v4(group: String, interface_ip: String ("0.0.0.0")) void !NetError
    // Starts receiving datagrams sent to the IPv6 multicast `group` (`ff00::/8`) on interface `interface_index`; 0 (the default) lets the system pick.
    + fn join_multicast_v6(group: String, interface_index: u32 (0)) void !NetError
    // Stops receiving the IPv4 multicast `group` joined on `interface_ip`.
    + fn leave_multicast_v4(group: String, interface_ip: String ("0.0.0.0")) void !NetError
    // Stops receiving the IPv6 multicast `group` joined on `interface_index`.
    + fn leave_multicast_v6(group: String, interface_index: u32 (0)) void !NetError
    // Returns the address this socket is bound to.
    + fn local_address() SocketAddress !NetError
    // Binds a socket to your own `host` and `port`; also `net.udp_server`.
    + static fn new(host: String, port: u16, timeout_ms: uint (5000), reuse_address: bool (false)) UdpServer !NetError
    // Receives one datagram into `buf` and returns its byte count and its sender.
    + fn recv_from(buf: local mut &[u8]) (uint, SocketAddress) !io:IoError
    // Sends `data` as one datagram to `to` and returns the number of bytes sent.
    + fn send_to(data: local &[u8], to: SocketAddress) uint !io:IoError
    // Allows sending to a broadcast address such as `255.255.255.255`.
    + fn set_broadcast(enabled: bool) void !NetError
    // Makes pending and later `recv_from` and `send_to` calls throw `cancelled` once `token` is cancelled.
    + fn set_cancel(token: shared CancelToken) void
    // Sends multicast datagrams through the interface with the IPv4 address `interface_ip` (IPv4 sockets) instead of the default route.
    + fn set_multicast_interface_v4(interface_ip: String) void !NetError
    // Sends multicast datagrams through interface `interface_index` (IPv6 sockets); 0 is the default route.
    + fn set_multicast_interface_v6(interface_index: u32) void !NetError
    // Whether multicast datagrams this socket sends are also delivered to receivers on this machine; on by default.
    + fn set_multicast_loopback(enabled: bool) void !NetError
    // Sets the hop limit (TTL) of datagrams sent to a multicast group; 1 (the system default) stays on the local network.
    + fn set_multicast_ttl(hops: u8) void !NetError
    // Asks the system for a receive buffer of `bytes`; it may round or cap the size.
    + fn set_receive_buffer(bytes: uint) void !NetError
    // Asks the system for a send buffer of `bytes`; it may round or cap the size.
    + fn set_send_buffer(bytes: uint) void !NetError
    // Sets the hop limit (TTL) of datagrams sent to a single address.
    + fn set_ttl(hops: u8) void !NetError
}
```

### UdpServer

A UDP socket bound to your own address, made by `new` or `net.udp_server`.

It has no connections to accept: `recv_from` returns each datagram with its sender,
and `send_to` replies to that sender. To talk to one server use `UdpClient`. Multicast
groups are joined with `join_multicast_v4` / `join_multicast_v6`. The descriptor is
closed by `close` or when the object is collected.

#### fd

The OS socket descriptor.

#### read_timeout_ms

Milliseconds `recv_from` may wait for a datagram; 0 waits forever.

#### write_timeout_ms

Milliseconds `send_to` may wait; 0 waits forever.

#### close

Closes the socket; does nothing when already closed. Throws `os` when closing fails.

#### join_multicast_v4

Starts receiving datagrams sent to the IPv4 multicast `group` (`224.0.0.0/4`) on the
interface with address `interface_ip`; `"0.0.0.0"` (the default) lets the system pick.

Bind the socket to the group's port, usually with `reuse_address`. Throws `closed`
after `close`, `invalid_host` when an address is not IPv4, and `os` when the system
refuses.

#### join_multicast_v6

Starts receiving datagrams sent to the IPv6 multicast `group` (`ff00::/8`) on
interface `interface_index`; 0 (the default) lets the system pick.

Throws `closed` after `close`, `invalid_host` when `group` is not IPv6, and `os`.

#### leave_multicast_v4

Stops receiving the IPv4 multicast `group` joined on `interface_ip`.

Throws `closed` after `close`, `invalid_host` and `os`.

#### leave_multicast_v6

Stops receiving the IPv6 multicast `group` joined on `interface_index`.

Throws `closed` after `close`, `invalid_host` and `os`.

#### local_address

Returns the address this socket is bound to.

Throws `closed` after `close` and `os` when the system cannot report it.

#### new

Binds a socket to your own `host` and `port`; also `net.udp_server`.

Port 0 lets the system pick one (see `local_address`). An IPv6 host such as `"::"`
also receives from IPv4 peers where the system allows it. `reuse_address` lets
several sockets bind the same port, which multicast receivers need. Throws
`invalid_host` or `timeout` when resolving fails, `init` when the socket cannot be
made, `port_in_use` when the address is already in use, `access` when the system
refuses it (such as a privileged port), and `os` when binding fails for another
reason.

#### recv_from

Receives one datagram into `buf` and returns its byte count and its sender.

A datagram larger than `buf` is cut to `buf.length` and the rest is lost. Throws
`timeout` after `read_timeout_ms`, `closed`, and `read` when the receive fails.

#### send_to

Sends `data` as one datagram to `to` and returns the number of bytes sent.

The socket can only send to addresses of its own family (see `local_address`).
Throws `write` when `to` is of the other family or the send fails, `timeout` after
`write_timeout_ms`, and `closed`.

#### set_broadcast

Allows sending to a broadcast address such as `255.255.255.255`.

Throws `closed` after `close` and `os` when the system refuses.

#### set_cancel

Makes pending and later `recv_from` and `send_to` calls throw `cancelled` once
`token` is cancelled.

The registration replaces any earlier token and lasts until `close`. When `token` is
already cancelled the socket is interrupted right away.

#### set_multicast_interface_v4

Sends multicast datagrams through the interface with the IPv4 address
`interface_ip` (IPv4 sockets) instead of the default route.

Throws `closed` after `close`, `invalid_host` when the address is not IPv4, and `os`.

#### set_multicast_interface_v6

Sends multicast datagrams through interface `interface_index` (IPv6 sockets); 0 is
the default route.

Throws `closed` after `close` and `os` when the system refuses.

#### set_multicast_loopback

Whether multicast datagrams this socket sends are also delivered to receivers on
this machine; on by default.

Throws `closed` after `close` and `os` when the system refuses.

#### set_multicast_ttl

Sets the hop limit (TTL) of datagrams sent to a multicast group; 1 (the system
default) stays on the local network.

Throws `closed` after `close` and `os` when the system refuses.

#### set_receive_buffer

Asks the system for a receive buffer of `bytes`; it may round or cap the size.

Throws `closed` after `close` and `os` when the system refuses.

#### set_send_buffer

Asks the system for a send buffer of `bytes`; it may round or cap the size.

Throws `closed` after `close` and `os` when the system refuses.

#### set_ttl

Sets the hop limit (TTL) of datagrams sent to a single address.

Throws `closed` after `close` and `os` when the system refuses.

# random

## Functions for 'random'

```js
// Returns a number from 0 up to but not including `n`, each equally likely; 0 when `n` is 0.
+ fn below(n: uint) uint
// Returns a number from `min` to `max`, both included, each equally likely.
+ fn between(min: int, max: int) int
// Returns true with probability `p`: never for 0 or less, always for 1 or more.
+ fn chance(p: float) bool
// Returns a float from 0 up to but not including 1.
+ fn fraction() float
// Returns the next 64 random bits of this thread's generator.
+ fn next() u64
// Seeds this thread's generator, so the numbers that follow repeat from run to run.
+ fn seed(value: u64) void
```

### below

Returns a number from 0 up to but not including `n`, each equally likely; 0 when `n` is 0.

### between

Returns a number from `min` to `max`, both included, each equally likely.

The bounds may be given in either order: `random.between(1, 6)` rolls a die.

### chance

Returns true with probability `p`: never for 0 or less, always for 1 or more.

### fraction

Returns a float from 0 up to but not including 1.

### next

Returns the next 64 random bits of this thread's generator.

Each thread has a generator seeded from the operating system on first use. The numbers
are fast to make but predictable to someone who sees enough of them: use
`crypto.random_bytes`, `uint.random()` or `String.random` for secrets.

### seed

Seeds this thread's generator, so the numbers that follow repeat from run to run.

## Classes for 'random'

```js
// A fast pseudo-random number generator (xoshiro256**) with its own state.
+ class Rng {
    // Returns a number from 0 up to but not including `n`, each equally likely; 0 when `n` is 0.
    + fn below(n: uint) uint
    // Returns a number from `min` to `max`, both included, each equally likely.
    + fn between(min: int, max: int) int
    // Returns true with probability `p`: never for 0 or less, always for 1 or more.
    + fn chance(p: float) bool
    // Returns a float from 0 up to but not including 1, with 53 random bits.
    + fn fraction() float
    // Creates a generator seeded from the operating system's entropy source.
    + static fn from_entropy() Rng
    // Creates a generator whose numbers follow from `seed` alone.
    + static fn new(seed: u64) Rng
    // Returns the next 64 random bits.
    + fn next() u64
    // Restarts the sequence as if the generator was created with `seed`.
    + fn reseed(seed: u64) void
}
```

### Rng

A fast pseudo-random number generator (xoshiro256**) with its own state.

The same seed gives the same numbers on every platform, which makes tests and
simulations repeatable. Not for secrets: use `crypto.random_bytes`, `uint.random()` or
`String.random` for keys and tokens. A generator is not meant to be shared between
threads; the functions of this namespace use one per thread.

#### below

Returns a number from 0 up to but not including `n`, each equally likely; 0 when `n` is 0.

#### between

Returns a number from `min` to `max`, both included, each equally likely.

The bounds may be given in either order.

#### chance

Returns true with probability `p`: never for 0 or less, always for 1 or more.

#### fraction

Returns a float from 0 up to but not including 1, with 53 random bits.

#### from_entropy

Creates a generator seeded from the operating system's entropy source.

#### new

Creates a generator whose numbers follow from `seed` alone.

#### next

Returns the next 64 random bits.

#### reseed

Restarts the sequence as if the generator was created with `seed`.

# regex

## Errors for 'regex'

```js
// Thrown when a regular expression pattern cannot be compiled.
error RegexError (syntax, unsupported, too_large) payload { message: String, position: uint (0) }
```

### RegexError

Thrown when a regular expression pattern cannot be compiled.

- `syntax`: the pattern is malformed, or a flag is unknown.
- `unsupported`: the pattern uses a feature this engine does not have (lookaround,
  backreferences, `\p` classes).
- `too_large`: the compiled program exceeds the instruction limit.

The payload holds a `message` and the byte `position` in the pattern (0 for an unknown
flag or a too large program).

## Functions for 'regex'

```js
// Returns `text` with every regex metacharacter escaped, so the result matches `text` literally.
+ fn escape(text: String) String
// Returns whether `pattern` matches anywhere in `text`, compiling the pattern on every call.
+ fn is_match(pattern: String, text: String) bool !RegexError
```

### escape

Returns `text` with every regex metacharacter escaped, so the result matches `text` literally.

### is_match

Returns whether `pattern` matches anywhere in `text`, compiling the pattern on every call.

Throws `RegexError` when the pattern does not compile; see `Regex.new`.

## Classes for 'regex'

```js
// One match of a `Regex` in a text; group 0 is the whole match.
+ class Match {
    // The text that was searched, not only the matched part.
    + text: String

    // Returns the number of groups including the whole match.
    + fn count() uint
    // Byte offset in `text` just past the end of the whole match.
    + get end: uint
    // Returns `template` with group references replaced by the group texts of this match.
    + fn expand(template: String) String
    // Returns the text of group `index`.
    + fn get(index: uint) ?String
    // Returns the text of the group called `name`.
    + fn named(name: String) ?String
    // Returns the start and end byte offsets of group `index`.
    + fn range(index: uint) (uint, uint) !LookupError
    // Byte offset in `text` where the whole match starts.
    + get start: uint
    // Returns the text of the whole match.
    + fn str() String
}
```

### Match

One match of a `Regex` in a text; group 0 is the whole match.

#### text

The text that was searched, not only the matched part.

#### count

Returns the number of groups including the whole match.

#### end

Byte offset in `text` just past the end of the whole match.

#### expand

Returns `template` with group references replaced by the group texts of this match.

`$1` or `${1}` insert a group by index, `$name` or `${name}` by name, `$0` the whole
match and `$$` a dollar sign. An unbraced reference takes all following word
characters, so `$1st` looks up a group named `1st`; write `${1}st` instead. Unknown
groups and groups that did not take part insert nothing. A `$` not followed by a
reference is copied as is.

#### get

Returns the text of group `index`.

Returns `null` when the group did not take part in the match or does not exist.

#### named

Returns the text of the group called `name`.

Returns `null` when no group has that name or the group did not take part in the match.

#### range

Returns the start and end byte offsets of group `index`.

Throws `LookupError` when the group does not exist or did not take part in the match.

#### start

Byte offset in `text` where the whole match starts.

#### str

Returns the text of the whole match.

```js
// A compiled regular expression, matched without backtracking.
+ class Regex {
    // The source pattern the regex was compiled from.
    + pattern: String

    // Returns the leftmost match that starts at or after byte offset `start`, or `null`.
    + fn find(text: String, start: uint (0)) ?Match
    // Returns every non-overlapping match from left to right, at most `limit` (0 means all).
    + fn find_all(text: String, limit: uint (0)) Array[Match]
    // Returns the number of capture groups, not counting the whole match.
    + fn group_count() uint
    // Returns the group index of the group called `name`.
    + fn group_index(name: String) uint !LookupError
    // Returns the name of each group by group index, `""` for unnamed groups.
    + fn group_names() Array[String]
    // Returns whether the pattern matches anywhere in `text`.
    + fn is_match(text: String) bool
    // Returns the match that begins exactly at byte offset `start`, or `null`.
    + fn match_at(text: String, start: uint (0)) ?Match
    // Compiles `pattern` with the given `flags`.
    + static fn new(pattern: String, flags: String ("")) Regex !RegexError
    // Returns `text` with the matches replaced by `replacement`, at most `limit` (0 means all).
    + fn replace(text: String, replacement: String, limit: uint (0)) String
    // Returns `text` with each match replaced by what `func` returns for it.
    + fn replace_with(text: String, func: fn(Match)(String), limit: uint (0)) String
    // Splits `text` at the matches into at most `limit` pieces (0 means all).
    + fn split(text: String, limit: uint (0)) Array[String]
}
```

### Regex

A compiled regular expression, matched without backtracking.

The engine builds a DFA as it searches and runs a Pike VM only to fill in capture groups:
matching takes time proportional to the text length times the pattern size, and
backreferences and lookaround are not supported. Offsets are byte offsets into the text. `$` without the `m` flag matches only
at the very end of the text, and `\b`, `\w` and `\d` are ASCII-only. A `Regex` keeps a
matcher cache that every match call reuses, so do not use one object from several
threads at once.

```valk
let re = regex.Regex.new("(?P<user>\\w+)@(?P<host>[\\w.]+)") ! panic("bad pattern")
let m = re.find("mail me@example.com") ?! return
println(m.named("host") ?? "") // example.com
```

#### pattern

The source pattern the regex was compiled from.

#### find

Returns the leftmost match that starts at or after byte offset `start`, or `null`.

The text before `start` still counts for `\b` and multi-line `^`. A pattern that starts
with `^` (without `m`) or `\A` finds nothing when `start` is above 0. Returns `null`
when `start` is past the end of `text`.

#### find_all

Returns every non-overlapping match from left to right, at most `limit` (0 means all).

After an empty match the search continues one character further.

#### group_count

Returns the number of capture groups, not counting the whole match.

#### group_index

Returns the group index of the group called `name`.

Throws `LookupError` when no group has that name.

#### group_names

Returns the name of each group by group index, `""` for unnamed groups.

Index 0 is the whole match and is always `""`; the array is a fresh copy.

#### is_match

Returns whether the pattern matches anywhere in `text`.

#### match_at

Returns the match that begins exactly at byte offset `start`, or `null`.

#### new

Compiles `pattern` with the given `flags`.

Flags: `i` case-insensitive, `m` makes `^`/`$` match at line boundaries, `s` lets `.`
match a newline. Throws `RegexError.syntax` for a malformed pattern or unknown flag,
`unsupported` for backreferences, lookaround and `\p{...}` classes, and `too_large`
when the compiled program exceeds the instruction limit or the capture slots for
its groups would be too many. The payload carries a `message` and byte `position`.

#### replace

Returns `text` with the matches replaced by `replacement`, at most `limit` (0 means all).

The replacement is expanded per match like `Match.expand`: `$1`, `${1}` and `${name}`
insert a group, `$0` the whole match and `$$` a dollar sign.

#### replace_with

Returns `text` with each match replaced by what `func` returns for it.

Replaces at most `limit` matches (0 means all); the rest of the text is copied as is.

#### split

Splits `text` at the matches into at most `limit` pieces (0 means all).

The last piece holds the rest of the text. An empty match splits between two
characters, never at either end of the text or right after the previous split.

# signal

## Errors for 'signal'

```js
// Thrown by the `signal` functions.
error SignalError (unsupported, init)
```

### SignalError

Thrown by the `signal` functions.

- `unsupported`: the signal does not exist on this platform (on Windows, everything
  but `interrupt` and `terminate`).
- `init`: the dispatcher (its pipe, waker or thread) could not be started, or the OS
  handler could not be installed.

## Enums for 'signal'

```js
// A process signal that can be handled, waited for or raised.
+ enum Signal { interrupt, terminate, hangup, quit, user1, user2 }
```

### Signal

A process signal that can be handled, waited for or raised.

`hangup`, `quit`, `user1` and `user2` do not exist on Windows: every function here
throws `unsupported` for them there.

## Functions for 'signal'

```js
// Cancels `token` when `sig` arrives; several tokens may watch one signal.
+ fn cancel_on(sig: Signal, token: shared CancelToken) void !SignalError
// Cancels `token` on `SIGINT` or `SIGTERM`, and `SIGHUP` where it exists.
+ fn cancel_on_shutdown(token: shared CancelToken) void !SignalError
// Makes the process ignore `sig` and drops the tokens, callbacks and waiters registered for it.
+ fn ignore(sig: Signal) void !SignalError
// Returns the OS signal number of `sig`; throws `unsupported` when the platform lacks it.
+ fn number(sig: Signal) i32 !SignalError
// Runs `callback` on the dispatcher thread each time `sig` arrives.
+ fn on(sig: Signal, callback: shared fn()()) void !SignalError
// Sends `sig` to this process through C `raise`; throws `unsupported` when the platform lacks it.
+ fn raise(sig: Signal) void !SignalError
// Restores the default action of `sig` and drops what was registered for it.
+ fn restore(sig: Signal) void !SignalError
// Waits until `sig` arrives; returns false when `timeout_ms` (0 = forever) ran out first.
+ fn wait(sig: Signal, timeout_ms: uint (0)) bool !SignalError
```

### cancel_on

Cancels `token` when `sig` arrives; several tokens may watch one signal.

The first registration for a signal installs its handler, and the first registration
of any kind starts the dispatcher thread. Throws `unsupported`, or `init` when the
handler, pipe or thread cannot be set up.

### cancel_on_shutdown

Cancels `token` on `SIGINT` or `SIGTERM`, and `SIGHUP` where it exists.

These are the signals a service receives when it is asked to stop. Throws `init` when
the handlers cannot be installed.

### ignore

Makes the process ignore `sig` and drops the tokens, callbacks and waiters registered for it.

Pending `wait` calls for `sig` are woken and return false.

### number

Returns the OS signal number of `sig`; throws `unsupported` when the platform lacks it.

### on

Runs `callback` on the dispatcher thread each time `sig` arrives.

Callbacks run after the signal's tokens are cancelled and its waiters woken, in the order
they were registered; a slow callback delays later signals. Throws `unsupported` or
`init`.

### raise

Sends `sig` to this process through C `raise`; throws `unsupported` when the platform lacks it.

### restore

Restores the default action of `sig` and drops what was registered for it.

Pending `wait` calls for `sig` are woken and return false.

### wait

Waits until `sig` arrives; returns false when `timeout_ms` (0 = forever) ran out first.

Parks the current coroutine (or blocks a thread outside one). Also returns false right
away when `ignore` or `restore` is called for `sig` meanwhile. Throws `unsupported` or
`init`.

# sync

## Errors for 'sync'

```js
// Errors of channels, wakers and cancellation tokens.
+ error SyncError (closed, timeout, cancelled, empty, full, init)
```

### SyncError

Errors of channels, wakers and cancellation tokens.

`closed`: the channel is closed (and, for a receive, drained). `timeout`: the wait ran
out. `cancelled`: the cancellation token fired. `empty` / `full`: a `try_recv` /
`try_send` that could not proceed. `init`: an OS resource (pipe, lock) could not be
created.

## Classes for 'sync'

```js
// A cancellation signal shared between coroutines and threads.
+ class CancelToken {
    // Cancels this token and its children; a second call does nothing.
    + fn cancel() void
    // Cancels the token after `ms` milliseconds.
    + fn cancel_after(ms: uint) void
    // Returns a new token that is cancelled when this one is, or right away when it already is.
    + fn child() CancelToken !SyncError
    // Returns true once the token was cancelled.
    + fn is_cancelled() bool
    // Returns a token that is not cancelled; throws `init` when its lock cannot be created.
    + static fn new() CancelToken !SyncError
    // Runs `callback` on the cancelling thread when cancelled; right away when already cancelled.
    + fn on_cancel(callback: shared fn()()) void
    // Waits until the token is cancelled; returns false when `timeout_ms` (0 = forever) ran out.
    + fn wait(timeout_ms: uint (0)) bool
}
```

### CancelToken

A cancellation signal shared between coroutines and threads.

Cancelling a token cancels every child made with `child`, wakes every `wait`, runs the
callbacks registered with `on_cancel`, and interrupts the I/O of connections that
watch it (`net.TcpConnection.set_cancel`). Channel operations take a token so a blocked
send or receive ends with `cancelled`. A token cannot be reset.

#### cancel

Cancels this token and its children; a second call does nothing.

Wakes the waiters, then cancels the children, then runs the callbacks, all on the
calling thread.

#### cancel_after

Cancels the token after `ms` milliseconds.

The timer is a coroutine started on the calling thread, so it only fires while that
thread keeps running its coroutines.

#### child

Returns a new token that is cancelled when this one is, or right away when it already is.

Cancelling the child does not cancel this token. Throws `init`.

#### is_cancelled

Returns true once the token was cancelled.

#### new

Returns a token that is not cancelled; throws `init` when its lock cannot be created.

#### on_cancel

Runs `callback` on the cancelling thread when cancelled; right away when already cancelled.

#### wait

Waits until the token is cancelled; returns false when `timeout_ms` (0 = forever) ran out.

Parks the current coroutine, or blocks a native thread outside one.

```js
// A first-in first-out queue of values between coroutines, on one thread or across threads.
+ class Channel[T] {
    // Closes the channel and wakes every waiting sender and receiver; a second call does nothing.
    + fn close() void
    // Returns true once `close` was called.
    + fn is_closed() bool
    // The number of values currently queued; on a rendezvous channel, those of waiting senders.
    + get length: uint
    // Returns an empty channel holding at most `capacity` values; without one it is unbounded.
    + static fn new(capacity: ?uint (null)) Channel[T] !SyncError
    // Returns the next value, waiting for one.
    + fn recv(timeout_ms: uint (0), cancel: ?shared CancelToken (null)) T !SyncError
    // Queues `value`, waiting while the channel is full; on a rendezvous channel, waiting until a receiver took it.
    + fn send(value: T, timeout_ms: uint (0), cancel: ?shared CancelToken (null)) void !SyncError
    // Returns the next value without waiting; throws `empty` when none is queued.
    + fn try_recv() T !SyncError
    // Queues `value` without waiting.
    + fn try_send(value: T) void !SyncError
}
```

### Channel

A first-in first-out queue of values between coroutines, on one thread or across threads.

With a capacity, `send` waits while the channel is full; without one it never waits.
A capacity of 0 makes a rendezvous channel: `send` waits until a receiver took the value.
Class objects must be `shared` to travel: `Channel[shared Message]`. Closing a channel
fails later sends and ends waiting receivers once the remaining values are drained.
`each channel as value` receives until a receive fails, normally because the channel
was closed.

#### close

Closes the channel and wakes every waiting sender and receiver; a second call does nothing.

Later sends throw `closed`; receives still return the values already queued.

#### is_closed

Returns true once `close` was called.

#### length

The number of values currently queued; on a rendezvous channel, those of waiting senders.

#### new

Returns an empty channel holding at most `capacity` values; without one it is unbounded.

A capacity of 0 holds no values of its own: each `send` waits until a receiver took
its value. Throws `init` when the lock cannot be created.

#### recv

Returns the next value, waiting for one.

`timeout_ms` 0 waits forever. Throws `closed` once the channel is closed and empty,
`timeout`, `cancelled` when `cancel` fires, and `init`.

#### send

Queues `value`, waiting while the channel is full; on a rendezvous channel, waiting until
a receiver took it.

`timeout_ms` 0 waits forever. Throws `closed` (also when the channel closes while
waiting; `value` is then dropped), `timeout`, `cancelled` when `cancel` fires, and
`init`. A value that was not taken yet is withdrawn when the send fails.

#### try_recv

Returns the next value without waiting; throws `empty` when none is queued.

Throws `closed` instead once the channel is closed and empty.

#### try_send

Queues `value` without waiting.

Throws `full` when the channel is full (on a rendezvous channel: when no receiver is
waiting) and `closed` when it is closed.

```js
// A wakeup for the coroutine or thread that waits on it; `wake` may be called from any thread.
+ class Waker {
    // Returns a new waker.
    + static fn new() Waker !SyncError
    // Waits for a wake; returns false when `timeout_ms` (0 = forever) ran out first.
    + fn wait(timeout_ms: uint (0)) bool
    // Wakes the waiter; safe from any thread, and kept for the next `wait` when nobody waits.
    + fn wake() void
}
```

### Waker

A wakeup for the coroutine or thread that waits on it; `wake` may be called from any thread.

`wait` parks the current coroutine (or blocks a native thread) until a wake arrives or
the timeout runs out. Wakes are counted loosely: a wake that nobody waited for is kept
and ends the next `wait` early, and several wakes may end just one, so callers re-check
their condition in a loop. A waker holds no operating system resource.

#### new

Returns a new waker.

Never fails since the waker holds no operating system resource; the error type is kept
for existing callers.

#### wait

Waits for a wake; returns false when `timeout_ms` (0 = forever) ran out first.

Returns true right away when an earlier wake is still pending, consuming it.

#### wake

Wakes the waiter; safe from any thread, and kept for the next `wait` when nobody waits.

# template

## Aliases for 'template'

```js
type Escape (fn(local &[u8], Writer)(uint !IoError))
type Filter (fn(Value, Array[Value])(Value))
```

## Errors for 'template'

```js
// The base error of `template`; functions throw it as `ParseError`.
error Error (template_not_found) payload { template_name: String, message: String }
// Thrown by `render` and `render_content` when a template cannot be rendered.
error ParseError (parse, missing, write) extends (Error) payload { index: uint (0), line: uint (0) }
```

### Error

The base error of `template`; functions throw it as `ParseError`.

- `template_not_found`: `render` was given a name that no template was registered
  under.

The payload holds the `template_name` involved and a `message`.

### ParseError

Thrown by `render` and `render_content` when a template cannot be rendered.

- `parse`: a syntax error, an unknown variable or property, an unknown template in
  `@include`/`@extend`, a cycle or too deep nesting; `message` says what and where.
- `missing`: used inside `@isset`/`@len`; it never leaves `render`.
- `write`: `render_into` / `render_content_into` could not write to the writer.

Also carries `Error.template_not_found`. The payload adds the `line` and byte `index`
in the template where the error was found.

## Functions for 'template'

```js
// HTML escaping as an `Escape`: the default of `Engine.escape` and `RenderOptions.escape`.
+ fn html_escape(input: local &[u8], out: Writer) uint !io:IoError
// Renders a template registered with `set_content`.
+ fn render(name: String, data: $T, options: ?RenderOptions (null)) String !ParseError $deprecated
// Renders the template text `content`; includes resolve against `set_content` templates.
+ fn render_content(content: String, data: $T, options: ?RenderOptions (null)) String !ParseError $deprecated
// Writes `render_content(content, data, options)` to `out`.
+ fn render_content_into(content: String, data: $T, out: Writer, options: ?RenderOptions (null)) uint !ParseError $deprecated
// Writes `render(name, data, options)` to `out`.
+ fn render_into(name: String, data: $T, out: Writer, options: ?RenderOptions (null)) uint !ParseError $deprecated
// Registers `content` as the template named `name` for the free `render` functions.
+ fn set_content(name: String, content: String) void $deprecated
// Registers every entry of `content` as a template for the free `render` functions.
+ fn set_content_many(content: Map[String]) void $deprecated
```

### html_escape

HTML escaping as an `Escape`: the default of `Engine.escape` and `RenderOptions.escape`.

### render

Renders a template registered with `set_content`.

Deprecated: create an `Engine` and call its `render`.

### render_content

Renders the template text `content`; includes resolve against `set_content` templates.

Deprecated: create an `Engine` and call its `render_content`.

### render_content_into

Writes `render_content(content, data, options)` to `out`.

Deprecated: create an `Engine` and call its `render_content_into`.

### render_into

Writes `render(name, data, options)` to `out`.

Deprecated: create an `Engine` and call its `render_into`.

### set_content

Registers `content` as the template named `name` for the free `render` functions.

Deprecated: create an `Engine` and call its `set`; see `Engine` for the per-thread
pattern. The free functions keep one registry for all threads.

### set_content_many

Registers every entry of `content` as a template for the free `render` functions.

Deprecated: create an `Engine` and call its `set_many`.

## Classes for 'template'

```js
// A set of templates and their filters.
+ class Engine {
    // Writes every `{{ }}` output escaped; HTML escaping by default. Set it to `null` for plain text, or to your own `Escape` for another format: templates are not tied to HTML. A `RenderOptions.escape` overrides it for one render.
    + escape: ?fn(local &[u8], Writer)(uint !IoError)

    // Whether a template named `name` is registered.
    + fn has(name: String) bool
    // Creates an empty engine.
    + static fn new() Engine
    // Renders the registered template `name` with `data` and returns the output.
    + fn render(name: String, data: $T, options: ?RenderOptions (null)) String !ParseError
    // Renders the template text `content` with `data` and returns the output.
    + fn render_content(content: String, data: $T, options: ?RenderOptions (null)) String !ParseError
    // Writes `render_content(content, data, options)` to `out` and returns the bytes written.
    + fn render_content_into(content: String, data: $T, out: Writer, options: ?RenderOptions (null)) uint !ParseError
    // Writes `render(name, data, options)` to `out` and returns the bytes written.
    + fn render_into(name: String, data: $T, out: Writer, options: ?RenderOptions (null)) uint !ParseError
    // Registers `content` as the template named `name`, replacing any earlier one.
    + fn set(name: String, content: String) void
    // Registers `filter` for `{{ value | name }}` and `{{ value | name(args) }}`.
    + fn set_filter(name: String, filter: fn(Value, Array[Value])(Value)) void
    // Registers every entry of `content` as a template, keyed by name.
    + fn set_many(content: Map[String]) void
}
```

### Engine

A set of templates and their filters.

An engine is an ordinary object: create one, register templates and filters, render.
Nothing in it is shared between threads. A server that renders on several worker
threads gives each thread its own engine through a `global`, whose initializer runs on
every thread:

```valk
global views: template.Engine (load_views())

fn load_views() template.Engine {
    let engine = template.Engine.new()
    engine.set_many(#embed_dir("views"))
    engine.set_filter("money", fn(v: json.Value, args: Array[json.Value]) json.Value {
        return json.from("$" + v.float.to_string(2))
    })
    return engine
}

fn handler(req: http.Request) http.Response {
    return http.Response.html(views.render("index.html", data) !? "render failed")
}
```

A template is compiled the first time it renders and the compiled form is kept until
it is registered again. Output is HTML-escaped unless `escape` says otherwise, so an
engine can just as well produce plain text, SQL or any other format.

#### escape

Writes every `{{ }}` output escaped; HTML escaping by default. Set it to `null` for
plain text, or to your own `Escape` for another format: templates are not tied to
HTML. A `RenderOptions.escape` overrides it for one render.

```valk
engine.escape = fn(input: local &[u8], out: io.Writer) uint !io.IoError {
    return out.write(input.to_string().replace("'", "''")) !>
}
```

#### has

Whether a template named `name` is registered.

#### new

Creates an empty engine.

#### render

Renders the registered template `name` with `data` and returns the output.

`data` is converted with `json.from`, so template variables are its fields or map
keys. `{{ }}` output goes through the engine's `escape` (HTML by default), or
through `options.escape` when options are given, `{! !}` is written raw, and leading and trailing whitespace is trimmed
from the result. `@include` and `@extend` look templates up in this engine, may not
form a cycle, and may nest at most `options.max_depth` templates deep (64 by
default), not counting `name` itself.

Throws `.template_not_found` when `name` is not registered, `.parse` on a syntax error,
an unknown template in `@include`/`@extend`, a cycle, too deep nesting, an unknown
filter or a variable or property that does not exist (`message` names the line and
template).

#### render_content

Renders the template text `content` with `data` and returns the output.

Works like `render` without looking up a name first; `@include` and `@extend` still
resolve against the registered templates. Throws `.parse` as `render` does.

#### render_content_into

Writes `render_content(content, data, options)` to `out` and returns the bytes written.

Throws `ParseError` as `render_content` does, and `.write` when `out` fails.

#### render_into

Writes `render(name, data, options)` to `out` and returns the bytes written.

Throws `ParseError` as `render` does, and `.write` when `out` fails.

#### set

Registers `content` as the template named `name`, replacing any earlier one.

#### set_filter

Registers `filter` for `{{ value | name }}` and `{{ value | name(args) }}`.

The filter receives the value and the evaluated arguments and returns the value the
output continues with. A custom filter replaces a built-in one of the same name. The
built-in filters are `upper`, `lower`, `capitalize`, `trim`, `length`, `default(x)`,
`join(sep)`, `first`, `last`, `reverse`, `round(decimals)`, `truncate(n, suffix)`,
`replace(from, to)`, `json`, `escape`, `urlencode` and `keys`.

#### set_many

Registers every entry of `content` as a template, keyed by name.

Pairs with `#embed_dir`, which yields a map of relative paths to file contents.

```js
// Options for one `render` or `render_content` call.
+ class RenderOptions {
    // The `Escape` applied to every `{{ }}` output of this render; HTML escaping by default, `null` for none. Options replace the engine's `escape` for the render, so an engine with an escape of its own passes it along: `RenderOptions { escape: engine.escape, max_depth: 2 }`.
    + escape: ?fn(local &[u8], Writer)(uint !IoError)
    // Maximum nesting of `@include`/`@extend` templates.
    + max_depth: uint
}
```

### RenderOptions

Options for one `render` or `render_content` call.

#### escape

The `Escape` applied to every `{{ }}` output of this render; HTML escaping by
default, `null` for none. Options replace the engine's `escape` for the render, so
an engine with an escape of its own passes it along: `RenderOptions { escape:
engine.escape, max_depth: 2 }`.

#### max_depth

Maximum nesting of `@include`/`@extend` templates.

The rendered template itself is not counted, for `render` and `render_content`
alike: `0` allows no includes, `1` allows includes that include nothing further.

# thread

## Functions for 'thread'

```js
// Starts an OS thread that runs `func`; the same as `Thread[void].start`.
+ fn start(func: shared fn()()) Thread[void] !InitError
// Blocks the whole OS thread, with every coroutine on it, for `ms` milliseconds.
+ fn suspend_ms(ms: uint) void
// Blocks the whole OS thread, with every coroutine on it, for `ns` nanoseconds.
+ fn suspend_ns(ns: uint) void
// Runs `handler` on a pool of up to 8 reused task threads; await the returned `Task` for it.
+ fn task(handler: shared fn()()) Task !InitError
```

### start

Starts an OS thread that runs `func`; the same as `Thread[void].start`.

Throws `init` when the thread cannot be created.

### suspend_ms

Blocks the whole OS thread, with every coroutine on it, for `ms` milliseconds.

Sleeps again for the rest after a signal interrupts it. Panics when the system sleep
fails. The thread releases its GC lock while it sleeps, so other threads can collect
for it.

### suspend_ns

Blocks the whole OS thread, with every coroutine on it, for `ns` nanoseconds.

Sleeps again for the rest after a signal interrupts it. Windows rounds up to whole
milliseconds. Panics when the system sleep fails. The thread releases its GC lock while
it sleeps, so other threads can collect for it.

### task

Runs `handler` on a pool of up to 8 reused task threads; await the returned `Task` for it.

A new runner thread is started when none is idle and fewer than 8 exist; otherwise the
task is queued. Queued tasks are started in the order they were queued. Idle runners
exit after 5 seconds. Throws `init` when a needed runner thread cannot be started.

## Classes for 'thread'

```js
// A handler queued with `task`.
+ class Task {
    // Waits until the task's handler has returned; returns at once when it already has.
    + fn await() void
}
```

### Task

A handler queued with `task`.

#### await

Waits until the task's handler has returned; returns at once when it already has.

Parks the current coroutine, or blocks the thread outside one.

```js
// An OS thread running one handler that returns a `T`.
+ class Thread[T] {
    // Waits until the handler has returned and returns its result.
    + fn await() T
    // Starts an OS thread that runs `func` inside a coroutine, and returns its handle.
    + static fn start(func: shared fn()(T)) Thread[T] !InitError
}
```

### Thread

An OS thread running one handler that returns a `T`.

The thread has its own GC heap, scheduler and copy of every non-`shared` global, reset
to its declared default; only `shared` data crosses threads. The OS thread is detached;
`await` waits for the handler's result.

#### await

Waits until the handler has returned and returns its result.

Parks the current coroutine, or blocks the thread outside one. May be called more than
once.

#### start

Starts an OS thread that runs `func` inside a coroutine, and returns its handle.

`func` must be a `shared` closure: what it captures is reachable from two threads.
Throws `init` when the thread cannot be created.

```js
// Runs handlers on threads of their own and collects their results in completion order.
+ class ThreadGroup[T] {
    // Blocks until the next handler finishes and returns its start index and result.
    + fn await_next() (uint, T) !LookupError
    // Returns true while some started handler was not yet returned by `await_next`.
    + fn has_pending() bool
    // Returns an empty group. Tagged `$default`, so it also supplies the group's default value.
    + static fn new() ThreadGroup[T]
    // Starts a new thread that runs `handler` and returns the index of this start (0, 1, ...).
    + fn start(handler: shared fn()(T)) uint !InitError
}
```

### ThreadGroup

Runs handlers on threads of their own and collects their results in completion order.

```valk
let group = thread.ThreadGroup[int].new()
group.start(fn() int { return 1 }) !!
group.start(fn() int { return 2 }) !!
while group.has_pending() {
    let index, result = group.await_next() !!
    println(index.to_string() + ": " + result)
}
```

#### await_next

Blocks until the next handler finishes and returns its start index and result.

Handlers are returned in the order they finish. Blocks the whole OS thread. Throws
`empty` right away when nothing is pending (see `has_pending`).

#### has_pending

Returns true while some started handler was not yet returned by `await_next`.

#### new

Returns an empty group. Tagged `$default`, so it also supplies the group's default value.

#### start

Starts a new thread that runs `handler` and returns the index of this start (0, 1, ...).

Throws `init` when the thread cannot be started.

```js
// A condition variable that blocks OS threads until another thread calls `signal`.
+ class ThreadSuspendGate {
    // Returns a new gate; panics when the OS mutex or condition cannot be created.
    + static fn new() ThreadSuspendGate
    // Wakes one thread blocked in `wait` so it re-checks its condition.
    + fn signal() void
    // Blocks the calling thread while `should_wait` returns true, re-checking after each `signal`.
    + fn wait(should_wait: fn()(bool), timeout_ms: uint (0)) bool
}
```

### ThreadSuspendGate

A condition variable that blocks OS threads until another thread calls `signal`.

Waiting releases the thread's GC lock, so other threads can collect meanwhile.

#### new

Returns a new gate; panics when the OS mutex or condition cannot be created.

Tagged `$default`, so it also supplies the default value of `ThreadSuspendGate` fields.

#### signal

Wakes one thread blocked in `wait` so it re-checks its condition.

Only one waiter is woken per call; others keep waiting. Panics when the OS call fails.

#### wait

Blocks the calling thread while `should_wait` returns true, re-checking after each `signal`.

Returns true once `should_wait` returned false, and false when `timeout_ms` (0 = forever)
ran out first. A `signal` that arrives after the call started but before the thread
sleeps is not lost. Panics when the OS wait fails.

# time

## Aliases for 'time'

```js
// The buffer size `DateTime.to_iso8601_in` requires for a UTC value: `YYYY-MM-DDTHH:MM:SS.uuuuuuZ`.
+ value ISO8601_TEXT_SIZE (27)
// The buffer size `DateTime.to_iso8601_in` requires for a value in a time zone: `YYYY-MM-DDTHH:MM:SS.uuuuuu+hh:mm:ss`.
+ value ISO8601_ZONED_TEXT_SIZE (35)
```

### ISO8601_TEXT_SIZE

The buffer size `DateTime.to_iso8601_in` requires for a UTC value:
`YYYY-MM-DDTHH:MM:SS.uuuuuuZ`.

### ISO8601_ZONED_TEXT_SIZE

The buffer size `DateTime.to_iso8601_in` requires for a value in a time zone:
`YYYY-MM-DDTHH:MM:SS.uuuuuu+hh:mm:ss`.

## Errors for 'time'

```js
// A time zone could not be loaded: `missing` when no zone has that name, `invalid` when its data or rule text is malformed.
+ error ZoneError (missing, invalid)
```

### ZoneError

A time zone could not be loaded: `missing` when no zone has that name, `invalid` when its
data or rule text is malformed.

## Functions for 'time'

```js
// Returns a zone that is always `offset_seconds` east of UTC, without daylight saving time.
+ fn fixed_zone(offset_seconds: int) Zone
// Returns the time zone this program runs in.
+ fn local_zone() Zone
// Returns a monotonic clock reading in milliseconds, for measuring durations.
+ fn mono_ms() uint
// Returns a monotonic clock reading in nanoseconds, for measuring durations.
+ fn mono_ns() uint
// Returns a monotonic clock reading in microseconds, for measuring durations.
+ fn mono_us() uint
// Pauses the caller for at least `duration`; nothing happens for a negative one. See `sleep_ns`.
+ fn sleep(duration: Duration) void
// Pauses the caller for at least `ms` milliseconds; see `sleep_ns`.
+ fn sleep_ms(ms: uint) void
// Pauses the caller for at least `ns` nanoseconds.
+ fn sleep_ns(ns: uint) void
// Returns the wall-clock time in milliseconds since the Unix epoch (UTC).
+ fn unix_ms() uint
// Returns the wall-clock time in nanoseconds since the Unix epoch (UTC).
+ fn unix_ns() uint
// Returns the wall-clock time in microseconds since the Unix epoch (UTC).
+ fn unix_us() uint
// Returns the UTC zone: offset 0, no daylight saving time.
+ fn utc() Zone
// Returns the time zone called `name` in the IANA time zone database, such as `Europe/Amsterdam` or `America/New_York`.
+ fn zone(name: String) Zone !ZoneError
// Returns a zone following the POSIX TZ rule `rule`, such as `CET-1CEST,M3.5.0,M10.5.0/3`, and named after it.
+ fn zone_from_posix(rule: String) Zone !ZoneError
// Returns a zone read from `data`, the contents of a TZif zone file, and named `name`.
+ fn zone_from_tzif(name: String, data: String) Zone !ZoneError
```

### fixed_zone

Returns a zone that is always `offset_seconds` east of UTC, without daylight saving time.

It is named after its offset, such as `+02:00` or `-05:30`. Panics when the offset is 24
hours or more either way.

### local_zone

Returns the time zone this program runs in.

The `TZ` environment variable decides when it is set: a zone name such as
`Europe/Paris`, the path of a zone file, or a POSIX rule such as
`EST5EDT,M3.2.0,M11.1.0`; an empty `TZ` means UTC. Without it, `/etc/localtime` is used,
or the time zone settings on Windows. When none of these gives a zone, the result is UTC.
The zone is looked up once per thread.

### mono_ms

Returns a monotonic clock reading in milliseconds, for measuring durations.

### mono_ns

Returns a monotonic clock reading in nanoseconds, for measuring durations.

The starting point is unspecified; only differences between readings are meaningful.

### mono_us

Returns a monotonic clock reading in microseconds, for measuring durations.

### sleep

Pauses the caller for at least `duration`; nothing happens for a negative one. See `sleep_ns`.

### sleep_ms

Pauses the caller for at least `ms` milliseconds; see `sleep_ns`.

### sleep_ns

Pauses the caller for at least `ns` nanoseconds.

Inside a coroutine only that coroutine is suspended and the thread keeps running other
coroutines; elsewhere the whole thread sleeps. Windows, and a coroutine on macOS, round
the duration up to whole milliseconds.

### unix_ms

Returns the wall-clock time in milliseconds since the Unix epoch (UTC).

### unix_ns

Returns the wall-clock time in nanoseconds since the Unix epoch (UTC).

Follows system clock changes, so it can jump backwards; use `mono_ns` to measure
durations. On Windows the resolution is 100 ns.

### unix_us

Returns the wall-clock time in microseconds since the Unix epoch (UTC).

### utc

Returns the UTC zone: offset 0, no daylight saving time.

### zone

Returns the time zone called `name` in the IANA time zone database, such as
`Europe/Amsterdam` or `America/New_York`.

Zones come from the system's database, `/usr/share/zoneinfo` or the directory in the
`TZDIR` environment variable. Windows has no such database, so there a copy built into
the standard library is used. `UTC` always exists. Loaded zones are kept per thread, so
asking again is cheap. Throws `missing` when no zone has that name and `invalid` when its
data is malformed.

### zone_from_posix

Returns a zone following the POSIX TZ rule `rule`, such as `CET-1CEST,M3.5.0,M10.5.0/3`,
and named after it.

As in the `TZ` environment variable, the offsets count hours west of UTC. Daylight saving
time without dates follows the United States rules. Throws `invalid` when the rule is
malformed.

### zone_from_tzif

Returns a zone read from `data`, the contents of a TZif zone file, and named `name`.

For zone data that does not come from the system, such as a file shipped with a program.
Throws `invalid` when the data is malformed.

## Classes for 'time'

```js
+ class DateTime {
    // Returns a copy moved forward by `duration` (back for a negative one), in the same zone.
    + fn add(duration: Duration) DateTime !LookupError
    // Returns a copy moved by `amount` calendar days, which may be negative.
    + fn add_days(amount: int) DateTime !LookupError
    // Returns a copy moved by `amount` hours, which may be negative.
    + fn add_hours(amount: int) DateTime !LookupError
    // Returns a copy moved by `amount` microseconds, which may be negative.
    + fn add_microseconds(amount: int) DateTime !LookupError
    // Returns a copy moved by `amount` minutes, which may be negative.
    + fn add_minutes(amount: int) DateTime !LookupError
    // Returns a copy moved by `amount` calendar months, which may be negative.
    + fn add_months(amount: int) DateTime !LookupError
    // Returns a copy moved by `amount` seconds, which may be negative.
    + fn add_seconds(amount: int) DateTime !LookupError
    // Returns a copy moved by `amount` years, which may be negative.
    + fn add_years(amount: int) DateTime !LookupError
    // Returns an independent copy of this value.
    + fn copy() DateTime
    // Returns the day of the month, starting at 1.
    + fn day() uint
    // Returns the ISO weekday: Monday is 1 and Sunday is 7.
    + fn day_of_week() uint
    // Returns the day of the year, 1 to 366.
    + fn day_of_year() uint
    // Returns whether both values name the same instant; backs the `==` operator (`$eq`).
    + fn equals(other: DateTime) bool
    // Returns the value as text laid out by `pattern`.
    + fn format(pattern: String) String
    // Writes `format(pattern)` into `buf` and returns the byte count.
    + fn format_in(pattern: String, buf: local mut &[u8]) uint
    // Writes `format(pattern)` to `out` and returns the bytes written.
    + fn format_into(pattern: String, out: Writer) uint !io:IoError
    // Returns the most bytes `format(pattern)` can write for any date.
    + static fn format_size(pattern: String) uint
    // Parses `value` laid out by `pattern`, using the tokens of `format`.
    + static fn from_format(pattern: String, value: String) DateTime !SyntaxError
    // Parses `value` laid out by `pattern` as wall-clock time in `zone`; see `from_format` and, for times around a daylight saving change, `new_in`. An offset in the value wins over `zone`.
    + static fn from_format_in(zone: Zone, pattern: String, value: String) DateTime !SyntaxError
    // Parses ISO 8601 text as written by `to_iso8601`, such as `2024-03-05T14:07:09Z`, `2024-03-05 15:07:09.25+01:00` or `2024-03-05`.
    + static fn from_iso8601(value: String) DateTime !SyntaxError
    // Reads a DateTime from a JSON string in ISO 8601 form (see `from_iso8601`).
    + static fn from_json_value_auto[X](value: X) DateTime !LookupError
    // Creates a date and time from whole seconds since the Unix epoch.
    + static fn from_unix_seconds(timestamp: int) DateTime !LookupError
    // Creates a date and time from microseconds since the Unix epoch.
    + static fn from_unix_us(timestamp: int) DateTime !LookupError
    // Returns whether this value is later than `other`; backs the `>` operator (`$gt`).
    + fn greater_than(other: DateTime) bool
    // Returns a hash of the instant; `$hash` lets `DateTime` be a `HashMap` key.
    + fn hash() uint
    // Returns the hour, 0 to 23.
    + fn hour() uint
    // Returns the same instant shown in UTC.
    + fn in_utc() DateTime !LookupError
    // Returns the same instant shown in `zone`.
    + fn in_zone(zone: Zone) DateTime !LookupError
    // Returns whether daylight saving time is in effect in the zone at this instant.
    + fn is_dst() bool
    // Returns whether the year is a leap year in the Gregorian calendar.
    + fn is_leap_year() bool
    // Returns whether this value is earlier than `other`; backs the `<` operator (`$lt`).
    + fn less_than(other: DateTime) bool
    // Returns the microseconds within the second, 0 to 999999.
    + fn microsecond() uint
    // Returns the minute, 0 to 59.
    + fn minute() uint
    // Moves this value by `amount` calendar days in place; see `add_days`.
    + fn modify_add_days(amount: int) void !LookupError
    // Moves this value by `amount` hours in place.
    + fn modify_add_hours(amount: int) void !LookupError
    // Moves this value by `amount` microseconds in place.
    + fn modify_add_microseconds(amount: int) void !LookupError
    // Moves this value by `amount` minutes in place.
    + fn modify_add_minutes(amount: int) void !LookupError
    // Moves this value by `amount` calendar months in place; see `add_months`.
    + fn modify_add_months(amount: int) void !LookupError
    // Moves this value by `amount` seconds in place.
    + fn modify_add_seconds(amount: int) void !LookupError
    // Moves this value by `amount` years in place; see `add_years`.
    + fn modify_add_years(amount: int) void !LookupError
    // Sets the day of the month to `day` in place.
    + fn modify_day(day: uint) void !LookupError
    // Sets the hour to `hour` in place; throws `LookupError` above 23.
    + fn modify_hour(hour: uint) void !LookupError
    // Sets the microseconds to `microsecond` in place; throws `LookupError` above 999999.
    + fn modify_microsecond(microsecond: uint) void !LookupError
    // Sets the minute to `minute` in place; throws `LookupError` above 59.
    + fn modify_minute(minute: uint) void !LookupError
    // Sets the month to `month` in place, clamping the day to the last day of that month.
    + fn modify_month(month: uint) void !LookupError
    // Sets the second to `second` in place; throws `LookupError` above 59.
    + fn modify_second(second: uint) void !LookupError
    // Sets the year to `year` in place, clamping February 29 to February 28 when needed.
    + fn modify_year(year: int) void !LookupError
    // Returns the month, 1 to 12.
    + fn month() uint
    // Creates a date and time from its components.
    + static fn new(year: ?int (null), month: ?uint (null), day: ?uint (null), hour: ?uint (null), minute: ?uint (null), second: ?uint (null), microsecond: ?uint (null)) DateTime !LookupError
    // Creates a date and time from its components as wall-clock time in `zone`.
    + static fn new_in(zone: Zone, year: ?int (null), month: ?uint (null), day: ?uint (null), hour: ?uint (null), minute: ?uint (null), second: ?uint (null), microsecond: ?uint (null)) DateTime !LookupError
    // Returns the current UTC date and time.
    + static fn now() DateTime
    // Returns the current date and time in `zone`, such as `time.local_zone()`.
    + static fn now_in(zone: Zone) DateTime
    // Returns the second, 0 to 59.
    + fn second() uint
    // Returns the time from `earlier` to this value, negative when `earlier` is later.
    + fn since(earlier: DateTime) Duration
    // Returns a copy moved back by `duration`; see `add`.
    + fn subtract(duration: Duration) DateTime !LookupError
    // Returns the value as ISO 8601 text, such as `2024-03-05T14:07:09Z` in UTC or `2024-03-05T15:07:09+01:00` in a time zone.
    + fn to_iso8601() String
    // Writes `to_iso8601()` into `buf` and returns the byte count.
    + fn to_iso8601_in(buf: local mut &[u8]) uint
    // Writes `to_iso8601()` to `out` and returns the bytes written.
    + fn to_iso8601_into(out: Writer) uint !io:IoError
    // Returns `to_iso8601()`: valk.json writes a DateTime as this text and reads it back with `from_json_value_auto`.
    + fn to_json_string() String
    // Returns `to_iso8601()`; `$auto` lets a `DateTime` convert to `String` implicitly.
    + fn to_string() String
    // Returns the whole seconds since the Unix epoch, rounded down (towards the past).
    + fn unix_seconds() int
    // Returns the microseconds since the Unix epoch.
    + fn unix_us() int
    // Returns the offset from UTC of the zone at this instant, in seconds east of Greenwich.
    + fn utc_offset() int
    // Returns a copy with the day of the month set to `day`.
    + fn with_day(day: uint) DateTime !LookupError
    // Returns a copy with the hour set to `hour`; throws `LookupError` above 23.
    + fn with_hour(hour: uint) DateTime !LookupError
    // Returns a copy with the microseconds set to `microsecond`; throws `LookupError` above 999999.
    + fn with_microsecond(microsecond: uint) DateTime !LookupError
    // Returns a copy with the minute set to `minute`; throws `LookupError` above 59.
    + fn with_minute(minute: uint) DateTime !LookupError
    // Returns a copy with the month set to `month`.
    + fn with_month(month: uint) DateTime !LookupError
    // Returns a copy with the second set to `second`; throws `LookupError` above 59.
    + fn with_second(second: uint) DateTime !LookupError
    // Returns a copy with the year set to `year`.
    + fn with_year(year: int) DateTime !LookupError
    // Returns the year, 1 to 9999.
    + fn year() int
    // Returns the zone this value is shown in; `time.utc()` unless it was made for a zone.
    + fn zone() Zone
    // Returns the zone's abbreviation at this instant, such as `CET`, or `UTC`.
    + fn zone_abbreviation() String
}
```

#### add

Returns a copy moved forward by `duration` (back for a negative one), in the same zone.

Throws `LookupError` when the result falls outside years 1 to 9999.

#### add_days

Returns a copy moved by `amount` calendar days, which may be negative.

The wall-clock time stays the same, so in a zone with daylight saving time a day can
last 23 or 25 hours; in UTC every day is exactly 24 hours.

#### add_hours

Returns a copy moved by `amount` hours, which may be negative.

#### add_microseconds

Returns a copy moved by `amount` microseconds, which may be negative.

#### add_minutes

Returns a copy moved by `amount` minutes, which may be negative.

#### add_months

Returns a copy moved by `amount` calendar months, which may be negative.

The day is clamped to the last day of the resulting month, so January 31 plus one month
is February 28 or 29.

#### add_seconds

Returns a copy moved by `amount` seconds, which may be negative.

#### add_years

Returns a copy moved by `amount` years, which may be negative.

February 29 becomes February 28 in a year that is not a leap year.

#### copy

Returns an independent copy of this value.

#### day

Returns the day of the month, starting at 1.

#### day_of_week

Returns the ISO weekday: Monday is 1 and Sunday is 7.

#### day_of_year

Returns the day of the year, 1 to 366.

#### equals

Returns whether both values name the same instant; backs the `==` operator (`$eq`).

#### format

Returns the value as text laid out by `pattern`.

Tokens, as in PHP's `date()`:

- Year: `Y` four digits, `y` two digits.
- Month: `m` two digits, `n` without a leading zero, `M` `Jan`, `F` `January`.
- Day: `d` two digits, `j` without a leading zero, `D` `Mon`, `l` `Monday`, `N` the
  ISO weekday (1 for Monday to 7 for Sunday).
- Time: `H` hour (24-hour) and `h` hour (12-hour) in two digits, `G` and `g` the same
  without a leading zero, `A` `AM` or `PM`, `a` `am` or `pm`, `i` minute, `s` second,
  `v` milliseconds (3 digits), `u` microseconds (6 digits).
- Zone: `O` offset `+0100`, `P` offset `+01:00`, `T` abbreviation such as `CET`.
- `U` seconds since the Unix epoch.

Names are English. A backslash inserts the next byte literally; every other byte is
copied as is. Panics when the pattern ends with a backslash.

```valk
dt.format("Y-m-d H:i:s")        // 2024-03-05 14:07:09
dt.format("D, j M Y g:i A")     // Tue, 5 Mar 2024 2:07 PM
```

#### format_in

Writes `format(pattern)` into `buf` and returns the byte count.

`buf` must hold at least `format_size(pattern)` bytes; a shorter buffer panics, as does a
pattern ending with a backslash.

#### format_into

Writes `format(pattern)` to `out` and returns the bytes written.

A `ByteBuffer` is written directly; any other writer receives the text in one write.
Throws when `out` fails.

#### format_size

Returns the most bytes `format(pattern)` can write for any date.

Tokens such as names and numbers without leading zeros write fewer bytes for some dates.

#### from_format

Parses `value` laid out by `pattern`, using the tokens of `format`.

Numbers need exactly their digit count (`Y` four, `v` three, `u` six, `y`, `m`, `d`,
`H`, `h`, `i` and `s` two); `n`, `j`, `G` and `g` take one or two digits. `y` reads
69 to 99 as 1969 to 1999 and 00 to 68 as 2000 to 2068. Names are read without regard
to case; a weekday (`D`, `l`, `N`) is checked for its form but not against the date.
`h` and `g` count with `A` or `a` when the pattern has one. `O` and `P` read an offset
(or `Z`) and give a value in `time.fixed_zone` of it; `T` only reads `UTC`, `GMT` or
`Z`. `U` reads a Unix timestamp and allows no other date or time token. Every other
byte must match exactly. A year, month and day are required; missing time fields are 0.
Throws `SyntaxError` on a mismatch, leftover input, a repeated field, or a date or time
that does not exist.

#### from_format_in

Parses `value` laid out by `pattern` as wall-clock time in `zone`; see `from_format`
and, for times around a daylight saving change, `new_in`. An offset in the value wins
over `zone`.

#### from_iso8601

Parses ISO 8601 text as written by `to_iso8601`, such as `2024-03-05T14:07:09Z`,
`2024-03-05 15:07:09.25+01:00` or `2024-03-05`.

A date alone is midnight UTC. The date and time are separated by `T`, `t` or a space;
seconds and a fraction of up to nine digits (kept to the microsecond) are optional. An
offset such as `+01:00`, `+0100` or `+01` gives a value in `time.fixed_zone` of that
offset; `Z` or `z`, or no offset at all, gives a UTC value. Throws `SyntaxError` on
anything else, or a date or time that does not exist.

#### from_json_value_auto

Reads a DateTime from a JSON string in ISO 8601 form (see `from_iso8601`).

Used by valk.json's `to_type` and `decode_to`. Throws `.missing` when `value` is not
a string or not a valid date and time.

#### from_unix_seconds

Creates a date and time from whole seconds since the Unix epoch.

Throws `LookupError` when the result falls outside the years 1 to 9999.

#### from_unix_us

Creates a date and time from microseconds since the Unix epoch.

Throws `LookupError` when the result falls outside the years 1 to 9999.

#### greater_than

Returns whether this value is later than `other`; backs the `>` operator (`$gt`).

#### hash

Returns a hash of the instant; `$hash` lets `DateTime` be a `HashMap` key.

#### hour

Returns the hour, 0 to 23.

#### in_utc

Returns the same instant shown in UTC.

Throws `LookupError` when that falls outside the years 1 to 9999, which only happens
for a zoned value in the first or last hours of the range.

#### in_zone

Returns the same instant shown in `zone`.

Throws `LookupError` when the wall-clock time there falls outside the years 1 to 9999.

#### is_dst

Returns whether daylight saving time is in effect in the zone at this instant.

#### is_leap_year

Returns whether the year is a leap year in the Gregorian calendar.

#### less_than

Returns whether this value is earlier than `other`; backs the `<` operator (`$lt`).

#### microsecond

Returns the microseconds within the second, 0 to 999999.

#### minute

Returns the minute, 0 to 59.

#### modify_add_days

Moves this value by `amount` calendar days in place; see `add_days`.

#### modify_add_hours

Moves this value by `amount` hours in place.

#### modify_add_microseconds

Moves this value by `amount` microseconds in place.

#### modify_add_minutes

Moves this value by `amount` minutes in place.

#### modify_add_months

Moves this value by `amount` calendar months in place; see `add_months`.

#### modify_add_seconds

Moves this value by `amount` seconds in place.

#### modify_add_years

Moves this value by `amount` years in place; see `add_years`.

#### modify_day

Sets the day of the month to `day` in place.

Throws `LookupError` when the month has no such day.

#### modify_hour

Sets the hour to `hour` in place; throws `LookupError` above 23.

#### modify_microsecond

Sets the microseconds to `microsecond` in place; throws `LookupError` above 999999.

#### modify_minute

Sets the minute to `minute` in place; throws `LookupError` above 59.

#### modify_month

Sets the month to `month` in place, clamping the day to the last day of that month.

Throws `LookupError` when `month` is outside 1 to 12.

#### modify_second

Sets the second to `second` in place; throws `LookupError` above 59.

#### modify_year

Sets the year to `year` in place, clamping February 29 to February 28 when needed.

Throws `LookupError` when `year` is outside 1 to 9999.

#### month

Returns the month, 1 to 12.

#### new

Creates a date and time from its components.

Components left `null` before the first given one are taken from the current UTC time;
those after it default to their minimum (month and day 1, the rest 0). So
`DateTime.new(2024, 1, 1)` is midnight, `DateTime.new(null, null, null, 9)` is 09:00:00
today and `DateTime.new()` is now. Throws `LookupError` when a component is out of range
or the day does not exist in that month.

#### new_in

Creates a date and time from its components as wall-clock time in `zone`.

Missing components follow the rules of `new`, taking the current time in `zone`. A
time the clocks skip when daylight saving time starts moves forward by the length of
the gap; a time that happens twice when it ends resolves to its first occurrence.
Throws `LookupError` when a component is out of range or the day does not exist.

#### now

Returns the current UTC date and time.

Panics when the system clock is outside the supported range.

#### now_in

Returns the current date and time in `zone`, such as `time.local_zone()`.

Panics when the system clock is outside the supported range.

#### second

Returns the second, 0 to 59.

#### since

Returns the time from `earlier` to this value, negative when `earlier` is later.

Backs `later - earlier`. Zones do not matter: both are instants.

#### subtract

Returns a copy moved back by `duration`; see `add`.

#### to_iso8601

Returns the value as ISO 8601 text, such as `2024-03-05T14:07:09Z` in UTC or
`2024-03-05T15:07:09+01:00` in a time zone.

A non-zero microsecond part adds six fraction digits: `2024-03-05T14:07:09.250000Z`.
An offset with seconds, as some zones had before 1900, adds them: `+00:19:32`.

#### to_iso8601_in

Writes `to_iso8601()` into `buf` and returns the byte count.

`buf` must hold at least `ISO8601_TEXT_SIZE` (27) bytes for a UTC value and
`ISO8601_ZONED_TEXT_SIZE` (35) for a value in a time zone; a shorter buffer panics.

#### to_iso8601_into

Writes `to_iso8601()` to `out` and returns the bytes written.

A `ByteBuffer` is written directly; any other writer receives the text in one write.
Throws when `out` fails.

#### to_json_string

Returns `to_iso8601()`: valk.json writes a DateTime as this text and reads it back
with `from_json_value_auto`.

#### to_string

Returns `to_iso8601()`; `$auto` lets a `DateTime` convert to `String` implicitly.

#### unix_seconds

Returns the whole seconds since the Unix epoch, rounded down (towards the past).

#### unix_us

Returns the microseconds since the Unix epoch.

#### utc_offset

Returns the offset from UTC of the zone at this instant, in seconds east of Greenwich.

#### with_day

Returns a copy with the day of the month set to `day`.

Throws `LookupError` when the month has no such day.

#### with_hour

Returns a copy with the hour set to `hour`; throws `LookupError` above 23.

#### with_microsecond

Returns a copy with the microseconds set to `microsecond`; throws `LookupError` above 999999.

#### with_minute

Returns a copy with the minute set to `minute`; throws `LookupError` above 59.

#### with_month

Returns a copy with the month set to `month`.

The day is clamped to the last day of the new month (January 31 becomes February 28 or
29). Throws `LookupError` when `month` is outside 1 to 12.

#### with_second

Returns a copy with the second set to `second`; throws `LookupError` above 59.

#### with_year

Returns a copy with the year set to `year`.

A February 29 becomes February 28 when `year` is not a leap year. Throws `LookupError`
when `year` is outside 1 to 9999.

#### year

Returns the year, 1 to 9999.

#### zone

Returns the zone this value is shown in; `time.utc()` unless it was made for a zone.

#### zone_abbreviation

Returns the zone's abbreviation at this instant, such as `CET`, or `UTC`.

```js
// A length of time with microsecond precision, positive or negative.
+ struct Duration {
    + microseconds: int

    // Returns the duration without its sign.
    + fn abs() Duration
    // The whole days.
    + fn days() int
    // Returns the duration divided by `divisor`, rounded toward zero; backs `d / 2`.
    + fn divided_by(divisor: int) Duration
    // Backs `==`.
    + fn equals(other: Duration) bool
    // Backs `>`.
    + fn greater_than(other: Duration) bool
    // Hashes the length, so durations can be map keys.
    + fn hash() uint
    // The whole hours.
    + fn hours() int
    // Returns true when the duration is below zero.
    + fn is_negative() bool
    // Backs `<`.
    + fn less_than(other: Duration) bool
    // Returns this duration minus `other`; backs `a - b`.
    + fn minus(other: Duration) Duration
    // The whole minutes.
    + fn minutes() int
    // The whole milliseconds.
    + fn ms() int
    // A duration of `days` days of 24 hours.
    + static fn of_days(days: int) Duration
    // A duration of `hours` hours.
    + static fn of_hours(hours: int) Duration
    // A duration of `minutes` minutes.
    + static fn of_minutes(minutes: int) Duration
    // A duration of `ms` milliseconds.
    + static fn of_ms(ms: int) Duration
    // A duration of `seconds` seconds.
    + static fn of_seconds(seconds: int) Duration
    // A duration of `us` microseconds.
    + static fn of_us(us: int) Duration
    // Returns the sum of both durations; backs `a + b`.
    + fn plus(other: Duration) Duration
    // The whole seconds.
    + fn seconds() int
    // The seconds with their fraction.
    + fn seconds_float() float
    // Returns the duration `factor` times as long; backs `d * 3`.
    + fn times(factor: int) Duration
    // Returns the duration as text such as `2d3h`, `1h30m`, `4.5s`, `250ms`, `15us` or `0s`.
    + fn to_string() String
}
```

### Duration

A length of time with microsecond precision, positive or negative.

Make one with `Duration.of_seconds(90)` and friends, or subtract two `DateTime` values:
`later - earlier`. Durations add, subtract and compare with the usual operators, and
print like `1h30m` or `-2.5s`. The getters give the whole number of each unit, rounded
toward zero: a duration of 90 minutes has `hours()` 1 and `minutes()` 90.

#### abs

Returns the duration without its sign.

#### days

The whole days.

#### divided_by

Returns the duration divided by `divisor`, rounded toward zero; backs `d / 2`.

Dividing by 0 panics, as it does for integers.

#### equals

Backs `==`.

#### greater_than

Backs `>`.

#### hash

Hashes the length, so durations can be map keys.

#### hours

The whole hours.

#### is_negative

Returns true when the duration is below zero.

#### less_than

Backs `<`.

#### minus

Returns this duration minus `other`; backs `a - b`.

#### minutes

The whole minutes.

#### ms

The whole milliseconds.

#### of_days

A duration of `days` days of 24 hours.

#### of_hours

A duration of `hours` hours.

#### of_minutes

A duration of `minutes` minutes.

#### of_ms

A duration of `ms` milliseconds.

#### of_seconds

A duration of `seconds` seconds.

#### of_us

A duration of `us` microseconds.

#### plus

Returns the sum of both durations; backs `a + b`.

#### seconds

The whole seconds.

#### seconds_float

The seconds with their fraction.

#### times

Returns the duration `factor` times as long; backs `d * 3`.

#### to_string

Returns the duration as text such as `2d3h`, `1h30m`, `4.5s`, `250ms`, `15us` or `0s`.

Units that are zero are left out; seconds carry their fraction.

```js
// A time zone: the UTC offsets, daylight saving time and abbreviations of a region through its history.
+ class Zone {
    // The name, such as `Europe/Amsterdam`, `UTC` or `+02:00`.
    ~ name: String

    // Returns the abbreviation in use at the instant `unix_seconds`, such as `CET` or `CEST`.
    + fn abbreviation_at(unix_seconds: int) String
    // Returns whether daylight saving time is in effect at the instant `unix_seconds`.
    + fn is_dst_at(unix_seconds: int) bool
    // Returns the offset from UTC in seconds at the instant `unix_seconds`, positive east of Greenwich: 3600 for CET, -18000 for EST.
    + fn offset_at(unix_seconds: int) int
}
```

### Zone

A time zone: the UTC offsets, daylight saving time and abbreviations of a region through
its history.

Get one with `time.zone`, `time.local_zone`, `time.utc` or `time.fixed_zone`, and use it
with `DateTime.in_zone`, `DateTime.now_in` and `DateTime.new_in`. A zone never changes
after it is created.

#### name

The name, such as `Europe/Amsterdam`, `UTC` or `+02:00`.

#### abbreviation_at

Returns the abbreviation in use at the instant `unix_seconds`, such as `CET` or `CEST`.

Zones without a customary abbreviation use their offset, such as `+04`.

#### is_dst_at

Returns whether daylight saving time is in effect at the instant `unix_seconds`.

#### offset_at

Returns the offset from UTC in seconds at the instant `unix_seconds`, positive east of
Greenwich: 3600 for CET, -18000 for EST.

# url

## Enums for 'url'

```js
// Selects which characters `url.encode` may leave unescaped, per URL component.
+ enum Component { unreserved, path, query, fragment }
```

### Component

Selects which characters `url.encode` may leave unescaped, per URL component.

`unreserved` escapes everything RFC 3986 does not list as unreserved, so it is the
only choice that cannot change the meaning of a URL; it is the default. The others
additionally keep punctuation that is legal inside that one component.

`%` and `+` are escaped in every component: `%` introduces an escape sequence, so
passing it through would make `decode(encode(x)) != x`, and `decode` reads `+` as a
space.

## Functions for 'url'

```js
// Decodes `%XX` escapes and turns every `+` into a space.
+ fn decode(str: String) String
// Writes `str` decoded as `decode` does to `out` and returns the bytes written.
+ fn decode_into(str: String, out: Writer) uint !io:IoError
// Decodes `%XX` escapes in a URL path; unlike `decode`, a `+` stays a `+`.
+ fn decode_path(str: String) String
// Writes `str` decoded as `decode_path` does to `out` and returns the bytes written.
+ fn decode_path_into(str: String, out: Writer) uint !io:IoError
// Percent-encodes `str` for use in the given URL `component`.
+ fn encode(str: String, component: Component (Component.unreserved)) String
// Writes `str` percent-encoded as `encode` does to `out` and returns the bytes written.
+ fn encode_into(str: String, out: Writer, component: Component (Component.unreserved)) uint !io:IoError
// Splits `str` into a `Url`; it never fails.
+ fn parse(str: String) Url
```

### decode

Decodes `%XX` escapes and turns every `+` into a space.

A `%` that is not followed by two hex digits is kept as is. `+` is decoded as a space
in every position, as in a query string or a form; `decode_path` keeps it. The result is
not checked for valid UTF-8.

### decode_into

Writes `str` decoded as `decode` does to `out` and returns the bytes written.

A `ByteBuffer` is written directly; any other writer receives the text in one write.
Throws when `out` fails.

### decode_path

Decodes `%XX` escapes in a URL path; unlike `decode`, a `+` stays a `+`.

Use it for paths and route parameters, where `+` is a literal plus (`/tags/c++`).
A `%` that is not followed by two hex digits is kept as is. The result is not checked
for valid UTF-8.

### decode_path_into

Writes `str` decoded as `decode_path` does to `out` and returns the bytes written.

A `ByteBuffer` is written directly; any other writer receives the text in one write.
Throws when `out` fails.

### encode

Percent-encodes `str` for use in the given URL `component`.

Works on bytes: every byte that is not a literal for `component` becomes `%XX` with
uppercase hex digits, so multi-byte UTF-8 characters become one escape per byte.

### encode_into

Writes `str` percent-encoded as `encode` does to `out` and returns the bytes written.

A `ByteBuffer` is written directly; any other writer receives the text in one write.
Throws when `out` fails.

### parse

Splits `str` into a `Url`; it never fails.

Parsing is lenient and does not validate or decode anything. The fragment is cut off
at the first `#` before anything else, then the scheme is read if the string starts
with one (RFC 3986 syntax followed by `:`). An authority is only parsed when the rest
starts with `//`; it ends at the first `/`, `?` or `\` — a backslash is not an authority
byte, and a browser treats it as `/`, so `http://evil.com\@allowed.com/` has the host
`evil.com` there as well. Userinfo ends at the last `@` in
the authority. A port that is not all digits stays part of `host`.

```valk
let u = url.parse("https://example.com:8080/a/b?x=1#top")
// u.host == "example.com", u.port == 8080, u.path == "/a/b", u.query == "x=1"
```

## Classes for 'url'

```js
// The components of a URL, as split by `url.parse`.
+ class Url {
    // The fragment without the leading `#`; empty when absent.
    + fragment: String
    // The host without userinfo and port; an IPv6 literal keeps its brackets.
    + host: String
    // The userinfo after the first `:`, as written; empty when there is none.
    + password: String
    // The path, from the end of the authority up to `?`; empty when absent.
    + path: String
    // The port, or `null` when absent or empty; the value is not range-checked.
    + port: ?uint
    // The query string without the leading `?`; empty when absent.
    + query: String
    // The scheme (`http`, `https`, `file`, ...), stored lowercased; empty when absent.
    + scheme: String
    // The userinfo before the first `:`, as written (still percent-encoded).
    + user: String

    // Returns `host` or `host:port`, the form used in a `Host` header.
    + fn host_with_port() String
}
```

### Url

The components of a URL, as split by `url.parse`.

Every component except `scheme` is kept as written, still percent-encoded; use
`url.decode` on the parts that need it.

#### fragment

The fragment without the leading `#`; empty when absent.

#### host

The host without userinfo and port; an IPv6 literal keeps its brackets.

#### password

The userinfo after the first `:`, as written; empty when there is none.

#### path

The path, from the end of the authority up to `?`; empty when absent.

#### port

The port, or `null` when absent or empty; the value is not range-checked.

#### query

The query string without the leading `?`; empty when absent.

#### scheme

The scheme (`http`, `https`, `file`, ...), stored lowercased; empty when absent.

#### user

The userinfo before the first `:`, as written (still percent-encoded).

#### host_with_port

Returns `host` or `host:port`, the form used in a `Host` header.

# validate

## Functions for 'validate'

```js
// Returns whether `email` looks like a valid email address, by a simple ASCII syntax check.
+ fn email(email: String) bool
```

### email

Returns whether `email` looks like a valid email address, by a simple ASCII syntax check.

The part before `@` may hold letters, digits, `-`, `_`, `.` and `+`, and is at most 64
bytes; the part after it holds dot-separated labels of letters, digits and `-`, at most
255 bytes, with a top-level label starting with a letter. Two separators in a row, a
separator at the end, and any non-ASCII byte are rejected.

## Classes for 'validate'

```js
// A validation rule for a JSON value, built by chaining calls on a typed constructor.
+ class Field {
    // Returns a rule that requires an array, checking each item against `of` when it is set.
    + static fn array(of: ?Field) Field
    // Returns a rule that requires a bool.
    + static fn bool() Field
    // Adds a check: `func` must return `true` for the value, otherwise the field gets the error code `error`.
    + fn custom(func: fn(Value)(bool), error: String) Field
    // Sets the value `try_cast` fills in when the field is absent from its parent object.
    + fn default(val: $T) Field
    // Adds a check that the value is a string accepted by `validate.email`.
    + fn email() Field
    // Sets a string the value must equal; `null` removes the check.
    + fn equals_string(str: ?String) Field
    // Returns a rule that requires a number; an integer such as `1` is accepted as a float.
    + static fn float() Field
    // Sets a float maximum for a float rule, checked in addition to `max`.
    + fn fmax(val: float) Field
    // Sets a float minimum for a float rule, checked in addition to `min`.
    + fn fmin(val: float) Field
    // Returns the limits of the rule as a JSON object, for use by client-side form checks.
    + fn get_form_rules() Value
    // Returns a rule that requires an integer.
    + static fn int() Field
    // Adds a check that the string value passes `String.is_syntax(mask, mask_is_exclude)`.
    + fn is_syntax(mask: String, mask_is_exclude: bool (false)) Field
    // Sets whether a string may not contain ASCII uppercase letters.
    + fn lower(val: bool (true)) Field
    // Sets the maximum: the byte length of a string, the item or member count of an array or object, or the value of an int or float.
    + fn max(val: int) Field
    // Sets the minimum: the byte length of a string, the item or member count of an array or object, or the value of an int or float.
    + fn min(val: int) Field
    // Sets whether `null` is accepted; a `null` value then passes every other check.
    + fn nullable(value: bool (true)) Field
    // Returns a rule that requires an object, checking each field in `fields` when it is set.
    + static fn object(fields: ?Map[Field]) Field
    // Sets whether the field may be absent from its parent object.
    + fn optional(value: bool (true)) Field
    // Returns a rule that requires a string.
    + static fn string() Field
    // Replaces each error code in `errors` with its message from `translations`.
    + static fn translate_errors(errors: Map[String], translations: Map[String] (default_translations)) void
    // Returns `data` converted toward the kind of the rule, or unchanged when it cannot be.
    + fn try_cast(data: Value) Value
    // Sets whether a string may not contain ASCII lowercase letters.
    + fn upper(val: bool (true)) Field
    // Adds a check that the value is a string of ASCII letters, plus digits when `numbers` and `_` when `underscore` is set.
    + fn username(numbers: bool, underscore: bool) Field
    // Sets the maximum string length in characters (UTF-8 code points).
    + fn utf8_max(val: int) Field
    // Sets the minimum string length in characters (UTF-8 code points).
    + fn utf8_min(val: int) Field
    // Returns whether `data` passes the rule.
    + fn validate(data: Value, errors: ?Map[String] (null), field_name: ?String (null)) bool
    // Validates `data` like `validate`, then turns the codes in `errors` into messages.
    + fn validate_and_translate(data: Value, errors: Map[String], translations: Map[String] (default_translations)) bool
}
```

### Field

A validation rule for a JSON value, built by chaining calls on a typed constructor.

`validate` checks a value against the rule and records one error code per failing
field; `translate_errors` turns the codes into messages. `try_cast` converts loosely
typed input (such as form fields) to the expected kinds first.

```valk
let data = json.decode("{\"email\":\"a@b.co\"}") ! panic("invalid JSON")
let rule = validate.Field.object(Map[validate.Field]{
    "email" => validate.Field.string().email()
    "age" => validate.Field.int().min(18).optional()
})
let errors = Map[String]{}
let ok = rule.validate_and_translate(data, errors)
```

#### array

Returns a rule that requires an array, checking each item against `of` when it is set.

#### bool

Returns a rule that requires a bool.

#### custom

Adds a check: `func` must return `true` for the value, otherwise the field gets the
error code `error`.

Custom checks run in the order added, before the type and limit checks, and receive
the raw value (only `null` on a `nullable` rule skips them). The first failing one
ends validation of the field.

#### default

Sets the value `try_cast` fills in when the field is absent from its parent object.

`val` is converted with `json.from`. `validate` does not use it.

#### email

Adds a check that the value is a string accepted by `validate.email`.

The error code is `string_email`.

#### equals_string

Sets a string the value must equal; `null` removes the check.

#### float

Returns a rule that requires a number; an integer such as `1` is accepted as a float.

#### fmax

Sets a float maximum for a float rule, checked in addition to `max`.

#### fmin

Sets a float minimum for a float rule, checked in addition to `min`.

#### get_form_rules

Returns the limits of the rule as a JSON object, for use by client-side form checks.

For an object rule, each declared field maps to its own rules. Otherwise the result
holds `min`/`max` (the stricter of the int and float limits for a float rule),
`utf8_min`/`utf8_max` and `lower`/`upper` for a string rule. Array item rules and
custom checks are not included.

#### int

Returns a rule that requires an integer.

A float such as `1.0` is rejected; use `try_cast` to convert first.

#### is_syntax

Adds a check that the string value passes `String.is_syntax(mask, mask_is_exclude)`.

The error code is `string_syntax`.

#### lower

Sets whether a string may not contain ASCII uppercase letters.

`try_cast` lowercases the string when this is set.

#### max

Sets the maximum: the byte length of a string, the item or member count of an array or
object, or the value of an int or float.

#### min

Sets the minimum: the byte length of a string, the item or member count of an array or
object, or the value of an int or float.

#### nullable

Sets whether `null` is accepted; a `null` value then passes every other check.

#### object

Returns a rule that requires an object, checking each field in `fields` when it is set.

Members not named in `fields` are allowed and not checked.

#### optional

Sets whether the field may be absent from its parent object.

An optional field that is absent is not checked; one that is present but `null` still
fails unless the rule is also `nullable`.

#### string

Returns a rule that requires a string.

#### translate_errors

Replaces each error code in `errors` with its message from `translations`.

The code before the first `:` selects the message, and everything after that `:`
(further `:` included) replaces `$1`. Codes with no entry in `translations` are left
unchanged.

#### try_cast

Returns `data` converted toward the kind of the rule, or unchanged when it cannot be.

Strings parse to numbers, `"true"`/`"false"` and `1`/`0` become bools, bools become
`1`/`0`, floats truncate to ints, numbers and bools become strings, and `null` becomes
the empty value of the kind. Array items and object fields are converted recursively.
For an object rule the result is a new object with only the declared fields: absent
fields get their `default`, or the empty value of their kind unless they are
`optional`, so a later `validate` no longer reports them as missing.

#### upper

Sets whether a string may not contain ASCII lowercase letters.

`try_cast` uppercases the string when this is set.

#### username

Adds a check that the value is a string of ASCII letters, plus digits when `numbers`
and `_` when `underscore` is set.

An empty string passes. The error code is `string_username`.

#### utf8_max

Sets the maximum string length in characters (UTF-8 code points).

#### utf8_min

Sets the minimum string length in characters (UTF-8 code points).

#### validate

Returns whether `data` passes the rule.

When `errors` is given, each failing field sets one entry: the key is its path from
`field_name` (default `"field"`), such as `field.address.0`, and the value an error
code such as `string_min:3` (the code, then `:` and the argument). Array items and
object fields are all checked, so several errors can be recorded; within one field
only the first failing check is reported.

#### validate_and_translate

Validates `data` like `validate`, then turns the codes in `errors` into messages.

The root field name is `"field"`, so object members are reported as `field.name`.
Codes with no entry in `translations` are left as they are.

## Globals for 'validate'

```js
// The English messages `translate_errors` uses by default, keyed by error code.
+ global default_translations : Map[String]
```

### default_translations

The English messages `translate_errors` uses by default, keyed by error code.

`$1` in a message is replaced by the error's argument (such as the limit). The map is
a thread-local global, so changes affect only the current thread.
