
# Documentation

Namespaces: [ansi](#ansi) | [compress](#compress) | [core](#core) | [coro](#coro) | [crypto](#crypto) | [ext](#ext) | [fs](#fs) | [gc](#gc) | [html](#html) | [http](#http) | [io](#io) | [json](#json) | [markdown](#markdown) | [math](#math) | [mem](#mem) | [net](#net) | [regex](#regex) | [signal](#signal) | [sync](#sync) | [template](#template) | [thread](#thread) | [time](#time) | [url](#url) | [validate](#validate)

---

# ansi

## Functions for 'ansi'

```js
// Returns whether the terminal likely understands ANSI escape codes, judged from `TERM`.
+ fn supported() bool
// Returns whether the console output expects UTF-8.
+ fn utf8_supported() bool
```

# compress

## Aliases for 'compress'

```js
// The compression level used when none is given, a balance of speed and size.
+ value COMPRESS_DEFAULT_LEVEL (6)
```

## Functions for 'compress'

```js
// Returns the Adler-32 checksum (as in zlib) of `data`.
+ fn adler32(data: local &[u8], adler: u32 (1)) u32
// Returns `data` compressed into `format` at `level` (0 stores, 1 is fastest, 9 is smallest).
+ fn compress(data: local &[u8], format: Format, level: uint (COMPRESS_DEFAULT_LEVEL)) String
// Returns the CRC-32 (IEEE 802.3, as in gzip, zip and PNG) of `data`.
+ fn crc32(data: local &[u8], crc: u32 (0)) u32
// Returns the decompressed contents of `data`, which must be in `format`.
+ fn decompress(data: &[u8], format: Format, max_size: uint (0)) String !CompressError
// Returns `data` compressed as raw DEFLATE; see `compress`.
+ fn deflate(data: local &[u8], level: uint (COMPRESS_DEFAULT_LEVEL)) String
// Returns the decompressed contents of gzip `data`.
+ fn gunzip(data: &[u8], max_size: uint (0)) String !CompressError
// Returns `data` compressed in the gzip format; see `compress`.
+ fn gzip(data: local &[u8], level: uint (COMPRESS_DEFAULT_LEVEL)) String
// Returns the decompressed contents of raw DEFLATE `data`.
+ fn inflate(data: &[u8], max_size: uint (0)) String !CompressError
// Returns the decompressed contents of zlib `data`.
+ fn unzlib(data: &[u8], max_size: uint (0)) String !CompressError
// Returns `data` compressed in the zlib format; see `compress`.
+ fn zlib(data: local &[u8], level: uint (COMPRESS_DEFAULT_LEVEL)) String
```

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

# core

## Aliases for 'core'

```js
// The exit code `exec` returns when it cannot run the shell or collect its status.
+ value EXEC_FAILED (-1)
```

## Functions for 'core'

```js
// Writes `Warning: msg @ file:line` to stderr without allocating.
+ fn cleanup_warning(msg: String, file: String, line: uint) void
// Returns a deep copy of `value`, the same copy `$clone(value)` makes.
+ fn clone_value(value: $T) T
// Runs `cmd` through the shell and returns its exit code and captured output.
+ fn exec(cmd: String, print_output: bool (false), capture_stderr: bool (true)) (i32, String)
// Ends the process with exit code `code`.
+ fn exit(code: i32) void
// Returns the value of the environment variable `var`.
+ fn getenv(var: String) String !LookupError
// Prints `msg` to stdout and ends the process with exit code 1.
+ fn panic(msg: String, location: String ("")) void
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
    // Appends every element of `items` in order; with `unique`, each one is skipped when an equal item is already present.
    + fn append_many(items: Array[T], unique: bool (false)) void
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
    // Returns a new array of the elements that also occur in `with`, in this array's order and without duplicates.
    + fn intersect(with: Array[T]) Array[T]
    // Returns a raw pointer to the first element.
    + fn items() *[T]
    // Converts each element to a `String` and joins them with `divider` between each pair.
    + fn join(divider: String) String
    // Returns a new array holding `func` applied to each element, in order.
    + fn map[R](func: fn(T)(R)) Array[R]
    // Returns a new array with the elements of this array followed by those of `items`.
    + fn merge(items: Array[T]) Array[T]
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
    // Puts the elements in random order in place (Fisher-Yates, using the OS secure entropy source).
    + fn shuffle() void
    // Returns a copy with the elements in random order; see `shuffle`.
    + fn shuffled() Array[T]
    // Sorts the elements in place with `func`, which returns true when `a` belongs after `b`.
    + fn sort(func: fn(T, T)(bool)) void
    // Returns a copy sorted with `func`; see `sort`.
    + fn sorted(func: fn(T, T)(bool)) Array[T]
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
    // Creates an empty map whose bucket table fits `capacity` entries without rehashing.
    + static fn new(capacity: uint (0)) HashMap[K, T]
    // Removes the entry for `key`; does nothing when it is absent.
    + fn remove(key: K) void
    // Stores `value` under `key`, replacing the value of an existing entry in place.
    + fn set(key: K, value: T) void
    // Adds a new entry for `key`.
    + fn set_unique(key: K, value: T) void !LookupError
    // Returns a new array of the values, in entry order.
    + fn values() Array[T]
}
```

```js
+ extend HashMap[String, T] {
    // Builds a map from a JSON object, converting each member with `to_type`.
    + static fn from_json_value_auto[X](value: X) HashMap[String, T] !LookupError
    // Reorders the entries so iteration, `keys` and `values` follow ascending key order.
    + fn sort_keys() void
}
```

```js
+ extend HashMap[u32, H2Stream] {
    // Reorders the entries so iteration, `keys` and `values` follow ascending key order.
    + fn sort_keys() void
}
```

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
    // Returns a new set with the values in this set or in `other`; backs `a + b` (`$add`).
    + fn union(other: HashSet[T]) HashSet[T]
}
```

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

```js
// Mutable shared data. The value can only be reached inside a `lock` block, which holds the mutex for the length of the block:
+ class Lock[T] {
    // Creates a lock holding `value`.
    + static fn new(value: T) Lock[T] !InitError
}
```

```js
// A `HashMap` with `String` keys, compatible with `HashMap[String, T]` in both directions.
+ mode Map[T] for HashMap[String, T] {
    // Returns a deep copy as a `Map`: every key and value is cloned with `$clone`.
    + fn clone() Map[T]
    // Creates an empty map.
    + static fn new() Map[T]
}
```

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
    // Releases the mutex and wakes waiters.
    + fn unlock() void
}
```

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

```js
// A child process started with `Process.run`.
+ class Process {
    // Gives up control of the child, which keeps running on its own.
    + fn detach() void !io:IoError
    // Returns true when the child has exited, without waiting.
    + fn did_exit() bool !io:IoError
    // Waits for the child to exit and returns its exit code.
    + fn exit_code() i32 !io:IoError
    // Starts `exe` with `args` and returns without waiting for it.
    + static fn run(exe: String, args: ?Array[String] (null), print_output: bool (false)) Process !io:IoError
    // Kills the child and waits for it to exit.
    + fn stop() void !io:IoError
}
```

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
    // Removes repeated copies of `part` from the start of the string.
    + fn ltrim(part: String, limit: uint (0)) String
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
    // Removes repeated copies of `part` from the end of the string.
    + fn rtrim(part: String, limit: uint (0)) String
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
    // Removes repeated copies of `part` from both ends of the string.
    + fn trim(part: String, limit: uint (0)) String
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

```js
// An iterator over the UTF-8 characters of a string, returned by `str.utf8.chars()`.
+ struct StringChars {
}
```

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

```js
// A boolean value, `true` or `false`, stored in one byte.
+ class bool {
    // Returns `"true"` or `"false"`.
    + fn to_string() String
}
```

```js
// A character: a `u8` that renders as the character instead of its decimal code.
+ mode char for u8 {
    // Returns a one-byte `String` holding this character.
    + fn to_string() String
}
```

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
    // Returns the shortest decimal text that parses back to the same value.
    + fn to_shortest_string() String
    // Writes the value like `to_shortest_string` to `buf` and returns the byte count.
    + fn to_shortest_string_in_ptr(buf: ptr, force_exponent: bool (false)) uint
    // Returns the value with exactly `decimals` digits after the dot, e.g. `1.50`.
    + fn to_string(decimals: uint (2), trim_zeros: bool (false)) String
    // Writes the value like `to_string` to `buf` and returns the byte count.
    + fn to_string_in_ptr(buf: ptr, decimals: uint (2), trim_zeros: bool (false)) uint
}
```

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
    // Returns the shortest decimal text that parses back to the same value.
    + fn to_shortest_string() String
    // Writes the value like `to_shortest_string` to `buf` and returns the byte count.
    + fn to_shortest_string_in_ptr(buf: ptr, force_exponent: bool (false)) uint
    // Returns the value with exactly `decimals` digits after the dot, e.g. `1.50`.
    + fn to_string(decimals: uint (2), trim_zeros: bool (false)) String
    // Writes the value like `to_string` to `buf` and returns the byte count.
    + fn to_string_in_ptr(buf: ptr, decimals: uint (2), trim_zeros: bool (false)) uint
}
```

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
    // Returns the shortest decimal text that parses back to the same value.
    + fn to_shortest_string() String
    // Writes the value like `to_shortest_string` to `buf` and returns the byte count.
    + fn to_shortest_string_in_ptr(buf: ptr, force_exponent: bool (false)) uint
    // Returns the value with exactly `decimals` digits after the dot, e.g. `1.50`.
    + fn to_string(decimals: uint (2), trim_zeros: bool (false)) String
    // Writes the value like `to_string` to `buf` and returns the byte count.
    + fn to_string_in_ptr(buf: ptr, decimals: uint (2), trim_zeros: bool (false)) uint
}
```

```js
// A 16-bit signed integer.
+ class i16 {
    // Returns the absolute value. Unsigned values are returned unchanged.
    + fn abs() i16
    // Returns how many bytes `to_base_to_ptr` writes for this value in `base`, sign included.
    + fn character_length(base: i16) uint
    // Returns the value limited to the range `minimum` to `maximum`, both inclusive.
    + fn clamp(minimum: i16, maximum: i16) i16
    // Returns true when `str` parses as an integer equal to this value.
    + fn equals_string(str: String) bool
    // Returns the larger of `this` and `other`.
    + fn max(other: i16) i16
    // Returns the smaller of `this` and `other`.
    + fn min(other: i16) i16
    // Writes the value as text in `base` to stdout, without a newline.
    + fn print(base: i16) void
    // Returns a random value from the operating system's secure entropy source.
    + static fn random() i16
    // Reads a value from `size_of(SELF)` bytes at `from`, most significant first.
    + static fn read_big_endian(from: *[u8 x 2]) i16
    // Reads a value from `size_of(SELF)` bytes at `from`, least significant first.
    + static fn read_little_endian(from: *[u8 x 2]) i16
    // Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_down(modulo: i16) i16
    // Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_up(modulo: i16) i16
    // Returns the value as text in `base` (2 to 16), with a leading `-` when negative.
    + fn to_base(base: i16) String
    // Writes the value as text in `base` to `result` and returns the byte count.
    + fn to_base_to_ptr(base: i16, result: ptr, lowercase: bool (false)) uint
    // Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.
    + fn to_hex() String
    // Returns the value in decimal, with a leading `-` when negative.
    + fn to_string() String
    // Writes `v` to `to` as `size_of(SELF)` bytes, most significant first.
    + static fn write_big_endian(v: i16, to: *[u8 x 2]) void
    // Writes `v` to `to` as `size_of(SELF)` bytes, least significant first.
    + static fn write_little_endian(v: i16, to: *[u8 x 2]) void
}
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
    // Returns true when `str` parses as an integer equal to this value.
    + fn equals_string(str: String) bool
    // Returns the larger of `this` and `other`.
    + fn max(other: i32) i32
    // Returns the smaller of `this` and `other`.
    + fn min(other: i32) i32
    // Writes the value as text in `base` to stdout, without a newline.
    + fn print(base: i32) void
    // Returns a random value from the operating system's secure entropy source.
    + static fn random() i32
    // Reads a value from `size_of(SELF)` bytes at `from`, most significant first.
    + static fn read_big_endian(from: *[u8 x 4]) i32
    // Reads a value from `size_of(SELF)` bytes at `from`, least significant first.
    + static fn read_little_endian(from: *[u8 x 4]) i32
    // Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_down(modulo: i32) i32
    // Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_up(modulo: i32) i32
    // Returns the value as text in `base` (2 to 16), with a leading `-` when negative.
    + fn to_base(base: i32) String
    // Writes the value as text in `base` to `result` and returns the byte count.
    + fn to_base_to_ptr(base: i32, result: ptr, lowercase: bool (false)) uint
    // Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.
    + fn to_hex() String
    // Returns the value in decimal, with a leading `-` when negative.
    + fn to_string() String
    // Writes `v` to `to` as `size_of(SELF)` bytes, most significant first.
    + static fn write_big_endian(v: i32, to: *[u8 x 4]) void
    // Writes `v` to `to` as `size_of(SELF)` bytes, least significant first.
    + static fn write_little_endian(v: i32, to: *[u8 x 4]) void
}
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
    // Returns true when `str` parses as an integer equal to this value.
    + fn equals_string(str: String) bool
    // Returns the larger of `this` and `other`.
    + fn max(other: i64) i64
    // Returns the smaller of `this` and `other`.
    + fn min(other: i64) i64
    // Writes the value as text in `base` to stdout, without a newline.
    + fn print(base: i64) void
    // Returns a random value from the operating system's secure entropy source.
    + static fn random() i64
    // Reads a value from `size_of(SELF)` bytes at `from`, most significant first.
    + static fn read_big_endian(from: *[u8 x 8]) i64
    // Reads a value from `size_of(SELF)` bytes at `from`, least significant first.
    + static fn read_little_endian(from: *[u8 x 8]) i64
    // Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_down(modulo: i64) i64
    // Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_up(modulo: i64) i64
    // Returns the value as text in `base` (2 to 16), with a leading `-` when negative.
    + fn to_base(base: i64) String
    // Writes the value as text in `base` to `result` and returns the byte count.
    + fn to_base_to_ptr(base: i64, result: ptr, lowercase: bool (false)) uint
    // Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.
    + fn to_hex() String
    // Returns the value in decimal, with a leading `-` when negative.
    + fn to_string() String
    // Writes `v` to `to` as `size_of(SELF)` bytes, most significant first.
    + static fn write_big_endian(v: i64, to: *[u8 x 8]) void
    // Writes `v` to `to` as `size_of(SELF)` bytes, least significant first.
    + static fn write_little_endian(v: i64, to: *[u8 x 8]) void
}
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
    // Returns true when `str` parses as an integer equal to this value.
    + fn equals_string(str: String) bool
    // Returns the larger of `this` and `other`.
    + fn max(other: i8) i8
    // Returns the smaller of `this` and `other`.
    + fn min(other: i8) i8
    // Writes the value as text in `base` to stdout, without a newline.
    + fn print(base: i8) void
    // Returns a random value from the operating system's secure entropy source.
    + static fn random() i8
    // Reads a value from `size_of(SELF)` bytes at `from`, most significant first.
    + static fn read_big_endian(from: *u8) i8
    // Reads a value from `size_of(SELF)` bytes at `from`, least significant first.
    + static fn read_little_endian(from: *u8) i8
    // Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_down(modulo: i8) i8
    // Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_up(modulo: i8) i8
    // Returns the value as text in `base` (2 to 16), with a leading `-` when negative.
    + fn to_base(base: i8) String
    // Writes the value as text in `base` to `result` and returns the byte count.
    + fn to_base_to_ptr(base: i8, result: ptr, lowercase: bool (false)) uint
    // Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.
    + fn to_hex() String
    // Returns the value in decimal, with a leading `-` when negative.
    + fn to_string() String
    // Writes `v` to `to` as `size_of(SELF)` bytes, most significant first.
    + static fn write_big_endian(v: i8, to: *u8) void
    // Writes `v` to `to` as `size_of(SELF)` bytes, least significant first.
    + static fn write_little_endian(v: i8, to: *u8) void
}
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
    // Returns true when `str` parses as an integer equal to this value.
    + fn equals_string(str: String) bool
    // Returns the larger of `this` and `other`.
    + fn max(other: int) int
    // Returns the smaller of `this` and `other`.
    + fn min(other: int) int
    // Writes the value as text in `base` to stdout, without a newline.
    + fn print(base: int) void
    // Returns a random value from the operating system's secure entropy source.
    + static fn random() int
    // Reads a value from `size_of(SELF)` bytes at `from`, most significant first.
    + static fn read_big_endian(from: *[u8 x 8]) int
    // Reads a value from `size_of(SELF)` bytes at `from`, least significant first.
    + static fn read_little_endian(from: *[u8 x 8]) int
    // Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_down(modulo: int) int
    // Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_up(modulo: int) int
    // Returns the value as text in `base` (2 to 16), with a leading `-` when negative.
    + fn to_base(base: int) String
    // Writes the value as text in `base` to `result` and returns the byte count.
    + fn to_base_to_ptr(base: int, result: ptr, lowercase: bool (false)) uint
    // Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.
    + fn to_hex() String
    // Returns the value in decimal, with a leading `-` when negative.
    + fn to_string() String
    // Writes `v` to `to` as `size_of(SELF)` bytes, most significant first.
    + static fn write_big_endian(v: int, to: *[u8 x 8]) void
    // Writes `v` to `to` as `size_of(SELF)` bytes, least significant first.
    + static fn write_little_endian(v: int, to: *[u8 x 8]) void
}
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

```js
// A 16-bit unsigned integer.
+ class u16 {
    // Returns the absolute value. Unsigned values are returned unchanged.
    + fn abs() u16
    // Returns how many bytes `to_base_to_ptr` writes for this value in `base`, sign included.
    + fn character_length(base: u16) uint
    // Returns the value limited to the range `minimum` to `maximum`, both inclusive.
    + fn clamp(minimum: u16, maximum: u16) u16
    // Returns true when `str` parses as an integer equal to this value.
    + fn equals_string(str: String) bool
    // Returns the larger of `this` and `other`.
    + fn max(other: u16) u16
    // Returns the smaller of `this` and `other`.
    + fn min(other: u16) u16
    // Writes the value as text in `base` to stdout, without a newline.
    + fn print(base: u16) void
    // Returns a random value from the operating system's secure entropy source.
    + static fn random() u16
    // Reads a value from `size_of(SELF)` bytes at `from`, most significant first.
    + static fn read_big_endian(from: *[u8 x 2]) u16
    // Reads a value from `size_of(SELF)` bytes at `from`, least significant first.
    + static fn read_little_endian(from: *[u8 x 2]) u16
    // Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_down(modulo: u16) u16
    // Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_up(modulo: u16) u16
    // Returns the value as text in `base` (2 to 16), with a leading `-` when negative.
    + fn to_base(base: u16) String
    // Writes the value as text in `base` to `result` and returns the byte count.
    + fn to_base_to_ptr(base: u16, result: ptr, lowercase: bool (false)) uint
    // Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.
    + fn to_hex() String
    // Returns the value in decimal, with a leading `-` when negative.
    + fn to_string() String
    // Writes `v` to `to` as `size_of(SELF)` bytes, most significant first.
    + static fn write_big_endian(v: u16, to: *[u8 x 2]) void
    // Writes `v` to `to` as `size_of(SELF)` bytes, least significant first.
    + static fn write_little_endian(v: u16, to: *[u8 x 2]) void
}
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
    // Returns true when `str` parses as an integer equal to this value.
    + fn equals_string(str: String) bool
    // Returns the larger of `this` and `other`.
    + fn max(other: u32) u32
    // Returns the smaller of `this` and `other`.
    + fn min(other: u32) u32
    // Writes the value as text in `base` to stdout, without a newline.
    + fn print(base: u32) void
    // Returns a random value from the operating system's secure entropy source.
    + static fn random() u32
    // Reads a value from `size_of(SELF)` bytes at `from`, most significant first.
    + static fn read_big_endian(from: *[u8 x 4]) u32
    // Reads a value from `size_of(SELF)` bytes at `from`, least significant first.
    + static fn read_little_endian(from: *[u8 x 4]) u32
    // Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_down(modulo: u32) u32
    // Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_up(modulo: u32) u32
    // Returns the value as text in `base` (2 to 16), with a leading `-` when negative.
    + fn to_base(base: u32) String
    // Writes the value as text in `base` to `result` and returns the byte count.
    + fn to_base_to_ptr(base: u32, result: ptr, lowercase: bool (false)) uint
    // Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.
    + fn to_hex() String
    // Returns the value in decimal, with a leading `-` when negative.
    + fn to_string() String
    // Writes `v` to `to` as `size_of(SELF)` bytes, most significant first.
    + static fn write_big_endian(v: u32, to: *[u8 x 4]) void
    // Writes `v` to `to` as `size_of(SELF)` bytes, least significant first.
    + static fn write_little_endian(v: u32, to: *[u8 x 4]) void
}
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
    // Returns true when `str` parses as an integer equal to this value.
    + fn equals_string(str: String) bool
    // Returns the larger of `this` and `other`.
    + fn max(other: u64) u64
    // Returns the smaller of `this` and `other`.
    + fn min(other: u64) u64
    // Writes the value as text in `base` to stdout, without a newline.
    + fn print(base: u64) void
    // Returns a random value from the operating system's secure entropy source.
    + static fn random() u64
    // Reads a value from `size_of(SELF)` bytes at `from`, most significant first.
    + static fn read_big_endian(from: *[u8 x 8]) u64
    // Reads a value from `size_of(SELF)` bytes at `from`, least significant first.
    + static fn read_little_endian(from: *[u8 x 8]) u64
    // Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_down(modulo: u64) u64
    // Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_up(modulo: u64) u64
    // Returns the value as text in `base` (2 to 16), with a leading `-` when negative.
    + fn to_base(base: u64) String
    // Writes the value as text in `base` to `result` and returns the byte count.
    + fn to_base_to_ptr(base: u64, result: ptr, lowercase: bool (false)) uint
    // Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.
    + fn to_hex() String
    // Returns the value in decimal, with a leading `-` when negative.
    + fn to_string() String
    // Writes `v` to `to` as `size_of(SELF)` bytes, most significant first.
    + static fn write_big_endian(v: u64, to: *[u8 x 8]) void
    // Writes `v` to `to` as `size_of(SELF)` bytes, least significant first.
    + static fn write_little_endian(v: u64, to: *[u8 x 8]) void
}
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
    // Returns the larger of `this` and `other`.
    + fn max(other: u8) u8
    // Returns the smaller of `this` and `other`.
    + fn min(other: u8) u8
    // Writes the value as text in `base` to stdout, without a newline.
    + fn print(base: u8) void
    // Returns a random value from the operating system's secure entropy source.
    + static fn random() u8
    // Reads a value from `size_of(SELF)` bytes at `from`, most significant first.
    + static fn read_big_endian(from: *u8) u8
    // Reads a value from `size_of(SELF)` bytes at `from`, least significant first.
    + static fn read_little_endian(from: *u8) u8
    // Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_down(modulo: u8) u8
    // Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_up(modulo: u8) u8
    // Returns a one-byte `String` holding this byte.
    + fn to_ascii_string() String
    // Returns the value as text in `base` (2 to 16), with a leading `-` when negative.
    + fn to_base(base: u8) String
    // Writes the value as text in `base` to `result` and returns the byte count.
    + fn to_base_to_ptr(base: u8, result: ptr, lowercase: bool (false)) uint
    // Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.
    + fn to_hex() String
    // Returns the value in decimal, with a leading `-` when negative.
    + fn to_string() String
    // Returns the byte an escape letter stands for, e.g. `n` gives `\n`.
    + fn unescape() u8
    // Writes `v` to `to` as `size_of(SELF)` bytes, most significant first.
    + static fn write_big_endian(v: u8, to: *u8) void
    // Writes `v` to `to` as `size_of(SELF)` bytes, least significant first.
    + static fn write_little_endian(v: u8, to: *u8) void
}
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
    // Returns true when `str` parses as an integer equal to this value.
    + fn equals_string(str: String) bool
    // Returns the larger of `this` and `other`.
    + fn max(other: uint) uint
    // Returns the smaller of `this` and `other`.
    + fn min(other: uint) uint
    // Writes the value as text in `base` to stdout, without a newline.
    + fn print(base: uint) void
    // Returns a random value from the operating system's secure entropy source.
    + static fn random() uint
    // Reads a value from `size_of(SELF)` bytes at `from`, most significant first.
    + static fn read_big_endian(from: *[u8 x 8]) uint
    // Reads a value from `size_of(SELF)` bytes at `from`, least significant first.
    + static fn read_little_endian(from: *[u8 x 8]) uint
    // Rounds down, toward negative infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_down(modulo: uint) uint
    // Rounds up, toward positive infinity, to a multiple of `modulo`; multiples are returned unchanged.
    + fn round_up(modulo: uint) uint
    // Returns the value as text in `base` (2 to 16), with a leading `-` when negative.
    + fn to_base(base: uint) String
    // Writes the value as text in `base` to `result` and returns the byte count.
    + fn to_base_to_ptr(base: uint, result: ptr, lowercase: bool (false)) uint
    // Returns the value in uppercase hexadecimal without a `0x` prefix, e.g. `FF` or `-FF`.
    + fn to_hex() String
    // Returns the value in decimal, with a leading `-` when negative.
    + fn to_string() String
    // Writes `v` to `to` as `size_of(SELF)` bytes, most significant first.
    + static fn write_big_endian(v: uint, to: *[u8 x 8]) void
    // Writes `v` to `to` as `size_of(SELF)` bytes, least significant first.
    + static fn write_little_endian(v: uint, to: *[u8 x 8]) void
}
```

## Globals for 'core'

```js
// The number of `lock` blocks held on this thread, by any of its coroutines.
~+ global held_locks : uint
```

# coro

## Aliases for 'coro'

```js
// The stack size in bytes of the program's main coroutine: 8 MiB, like a native main thread.
+ value MAIN_STACK_SIZE (8 * 1024 * 1024)
```

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

## Globals for 'coro'

```js
// The stack size in bytes for the next coroutine created on this thread; 0 uses the default.
+ global next_stack_size : uint
```

# crypto

## Functions for 'crypto'

```js
// Decodes standard base64 (`+` and `/`) into the raw bytes it represents.
+ fn base64_decode(data: local &[u8]) String !CryptoError
// Decodes standard base64 into `out` and returns the bytes written.
+ fn base64_decode_into(data: local &[u8], out: Writer) uint !CryptoError
// Returns `data` encoded as standard base64 (`+` and `/`), `=` padded, without line breaks.
+ fn base64_encode(data: local &[u8]) String
// Writes `data` encoded as standard padded base64 to `out` and returns the bytes written.
+ fn base64_encode_into(data: local &[u8], out: Writer) uint !io:IoError
// Computes the bcrypt hash of `password` with the given `cost` and `salt` into `output`.
+ fn bcrypt(cost: uint, salt: local &[u8], password: local &[u8], output: ByteBuffer) void !CryptoError
// Hashes `password` with bcrypt and a fresh random salt, for storing credentials.
+ fn bcrypt_hash(password: local &[u8], cost: uint (12)) String !CryptoError
// Returns whether `password` matches the bcrypt `hash` string.
+ fn bcrypt_verify(password: local &[u8], hash: local &[u8]) bool
// Returns whether `a` and `b` hold the same bytes, in time that depends only on their length.
+ fn constant_time_equals(a: local &[u8], b: local &[u8]) bool
// Returns the digest size in bytes of `algorithm`.
+ fn digest_size(algorithm: HashAlgorithm) uint
// Returns the raw digest of `data` as binary bytes (not text).
+ fn hash(algorithm: HashAlgorithm, data: local &[u8]) String
// Returns the digest of `data` as lowercase hex.
+ fn hash_hex(algorithm: HashAlgorithm, data: local &[u8]) String
// Writes the digest of `data` as lowercase hex to `out` and returns the bytes written.
+ fn hash_hex_into(algorithm: HashAlgorithm, data: local &[u8], out: Writer) uint !io:IoError
// Writes the raw digest of `data` to `out` and returns the bytes written.
+ fn hash_into(algorithm: HashAlgorithm, data: local &[u8], out: Writer) uint !io:IoError
// Returns a fresh `Hasher` for `algorithm`.
+ fn hasher(algorithm: HashAlgorithm) Hasher
// Decodes hex text (either case) into the raw bytes it represents.
+ fn hex_decode(text: local &[u8]) String !CryptoError
// Decodes hex text (either case) into `out` and returns the bytes written.
+ fn hex_decode_into(text: local &[u8], out: Writer) uint !CryptoError
// Returns `data` encoded as lowercase hex, two characters per byte.
+ fn hex_encode(data: local &[u8]) String
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
// Writes the MD5 digest of `data` as lowercase hex to `out`; returns the bytes written.
+ fn md5_hex_into(data: local &[u8], out: Writer) uint !io:IoError
// Derives `length` bytes from `password` and `salt` with PBKDF2-HMAC (RFC 8018).
+ fn pbkdf2(algorithm: HashAlgorithm, password: local &[u8], salt: local &[u8], iterations: uint, length: uint) String !CryptoError
// Returns a string of `length` cryptographically secure random bytes.
+ fn random_bytes(length: uint) String
// Writes `length` cryptographically secure random bytes to `out`; returns the bytes written.
+ fn random_bytes_into(length: uint, out: Writer) uint !io:IoError
// Returns the SHA-1 digest of `data` as lowercase hex.
+ fn sha1_hex(data: local &[u8]) String
// Writes the SHA-1 digest of `data` as lowercase hex to `out`; returns the bytes written.
+ fn sha1_hex_into(data: local &[u8], out: Writer) uint !io:IoError
// Returns the SHA-256 digest of `data` as lowercase hex.
+ fn sha256_hex(data: local &[u8]) String
// Writes the SHA-256 digest of `data` as lowercase hex to `out`; returns the bytes written.
+ fn sha256_hex_into(data: local &[u8], out: Writer) uint !io:IoError
// Returns the SHA-384 digest of `data` as lowercase hex.
+ fn sha384_hex(data: local &[u8]) String
// Writes the SHA-384 digest of `data` as lowercase hex to `out`; returns the bytes written.
+ fn sha384_hex_into(data: local &[u8], out: Writer) uint !io:IoError
// Returns the SHA-512 digest of `data` as lowercase hex.
+ fn sha512_hex(data: local &[u8]) String
// Writes the SHA-512 digest of `data` as lowercase hex to `out`; returns the bytes written.
+ fn sha512_hex_into(data: local &[u8], out: Writer) uint !io:IoError
```

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

```js
// Mirrors glibc `__sigset_t` (1024 signal bits); the saved mask in `libc_gen___jmp_buf_tag`.
+ struct libc_gen_anon_struct_2 {
    // Signal bits, one per signal number.
    + __val: [uint x 16]
}
```

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

```js
// Mirrors the generic `struct sockaddr` on linux-x64; aliased as `libc_sockaddr`.
+ struct libc_gen_sockaddr {
    // Family-specific address bytes.
    + sa_data: [i8 x 14]
    // Address family (`AF_*`).
    + sa_family: u16
}
```

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

```js
// Mirrors `struct timespec` on linux-x64; aliased as `libc_timespec`.
+ struct libc_gen_timespec {
    // Nanoseconds, 0 to 999,999,999.
    + tv_nsec: int
    // Whole seconds.
    + tv_sec: int
}
```

```js
// Mirrors `struct timeval` on linux-x64; aliased as `libc_timeval`.
+ struct libc_gen_timeval {
    // Whole seconds.
    + tv_sec: int
    // Microseconds, 0 to 999,999.
    + tv_usec: int
}
```

```js
// Mirrors `struct timezone` for `gettimeofday` (obsolete; normally all zero).
+ struct libc_gen_timezone {
    // Type of DST correction; nonzero if DST is ever in effect.
    + tz_dsttime: i32
    // Minutes west of Greenwich.
    + tz_minuteswest: i32
}
```

```js
// Opaque storage for glibc `pthread_attr_t` (64 bytes, C needs 56); `gc` fills it with `pthread_getattr_np` to find a thread's stack.
+ struct pthread_attr_t {
    // Opaque attribute bytes, zero by default.
    + data: [uint x 8]
}
```

```js
// Opaque storage for a `pthread_cond_t`; initialize with `pthread_cond_init`.
+ struct pthread_cond_t {
    // Opaque condition variable bytes, zero by default.
    + data: [uint x 12]
}
```

```js
// Mirrors glibc `pthread_condattr_t` on Linux; `thread` uses it to make timed waits use `CLOCK_MONOTONIC`.
+ struct pthread_condattr_t {
    // Opaque attribute bits.
    + data: i32
}
```

```js
// Opaque storage for a `pthread_mutex_t`; initialize with `pthread_mutex_init`.
+ struct pthread_mutex_t {
    // Opaque mutex bytes, zero by default.
    + data: [uint x 10]
}
```

```js
// Holds a `pthread_t` thread handle, filled by `pthread_create`; used by `thread` and `core`.
+ struct pthread_t {
    // The handle (an integer on Linux, a pointer on macOS).
    + data: uint
}
```

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
// Returns the home directory of the current user: `$HOME`, or `%USERPROFILE%` on Windows.
+ fn home_dir() String !LookupError
// Returns whether `path` is a directory; a symlink to one counts.
+ fn is_dir(path: String) bool
// Returns whether `path` is a regular file; a symlink to one counts.
+ fn is_file(path: String) bool
// Returns whether `path` is a symbolic link, without following it.
+ fn is_symlink(path: String) bool
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
// Returns the absolute path of `path` with symlinks resolved.
+ fn realpath(path: String) String !io:IoError
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
// Resizes the file at `path` to `length` bytes, cutting it off or padding it with zeros.
+ fn truncate(path: String, length: uint) void !io:IoError
// Writes `content` to the file at `path`, creating the file when it is missing.
+ fn write(path: String, content: local &[u8], append: bool (false)) void !io:IoError
```

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
}
```

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
}
```

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

# gc

## Aliases for 'gc'

```js
type EnvCloneFn (fnptr(ptr)(ptr))
// Runs a garbage collection of the calling thread's memory now.
+ value collect (ext.valk_gc_collect)
// Runs a collection of shared memory, stopping every thread's GC while it marks.
+ value collect_shared (ext.valk_gc_collect_shared)
```

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

# html

## Functions for 'html'

```js
// Returns `code` with the HTML special characters `<`, `>`, `"`, `'` and `&` as entities.
+ fn escape(code: String, options: ?EscapeOptions (null)) String
// Writes `code` escaped as `escape` does to `out` and returns the bytes written.
+ fn escape_into(code: String, out: Writer, options: ?EscapeOptions (null)) uint !io:IoError
// Returns `code` with the value of every URL attribute whose scheme is not allowed emptied.
+ fn sanitize_url_attributes(code: String, allowed_schemes: Array[String] (.{ "http", "https", "mailto" })) String
// Returns whether a URL taken from an HTML attribute uses a scheme in `allowed_schemes`.
+ fn url_is_allowed(target: String, allowed_schemes: Array[String] (.{ "http", "https", "mailto" })) bool
```

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

# http

## Functions for 'http'

```js
// Connects and prepares a request without sending it; drive it with `progress`.
+ fn create_request(method: String, url: String, options: ?Options (null)) ClientRequest !HttpError
// Sends a request and writes the response body to the file at `to_path`.
+ fn download(url: String, to_path: String, method: String ("GET"), options: ?Options (null)) void !HttpError
// Parses one HTTP/1.x request or response from `input` into `context`, incrementally.
+ fn parse_http(input: ByteBuffer, context: Context, is_response: bool, max_header_size: uint (8192), max_body_size: uint (0)) void !HttpParseError
// Sends a request and returns the final response, following redirects.
+ fn request(method: String, url: String, options: ?Options (null)) ClientResponse !HttpError
// Creates a `Server` with default settings for `handler` and runs it; see `Server.start`.
+ fn serve(host: String, port: u16, handler: shared fn(Request)(Response), worker_count: uint (0)) void !HttpError
// Like `serve`, with a fast handler that writes straight to a `ResponseWriter`.
+ fn serve_fast(host: String, port: u16, handler: shared fn(Context, ResponseWriter)(), worker_count: uint (0)) void !HttpError
```

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
    + static fn create(method: String, url: String, options: ?Options (null), deadline_ms: uint (0)) ClientRequest !HttpError
    // Writes or reads the next chunk; returns `true` while there is more to do.
    + fn progress() bool !HttpError
    // Returns the response once `progress` has returned `false`.
    + fn response() ClientResponse !HttpError
}
```

```js
// The final response to a client request.
+ class ClientResponse {
    // The response body; empty when it was written to `Options.output` instead.
    + body: String
    // The response headers; names are stored lowercased.
    + headers: Headers
    // The HTTP status code, such as `200` or `404`.
    + status: u16
}
```

```js
// One accepted client connection of a `Server`, served on its own coroutine.
+ class Connection {
    // The socket's file descriptor.
    ~+ fd: i32
    // The underlying socket connection.
    ~+ netcon: TcpConnection
    // The server worker that accepted the connection.
    ~+ worker: Worker

    // Closes the socket; a failure to close only prints a warning.
    + fn close() void
}
```

```js
// The parse state of one HTTP/1.x message; `fast` handlers receive it as the request.
+ class Context {
    // The request method as sent, such as `GET`.
    ~+ method: &[u8]
    // The path of the request target without the query string, not percent-decoded.
    ~+ path: &[u8]
    // The query string without the leading `?`, not decoded; empty when absent.
    ~+ query_string: &[u8]
    // The status code of a parsed response; 0 for a request.
    ~+ status: u16

    // The message body, with chunked encoding removed; empty until the message is complete.
    + get body: String
    // Returns the form fields of the request body.
    + fn data() Map[String]
    // Returns the request body as JSON.
    + fn data_json() Value
    // Returns the uploaded files of a `multipart/form-data` body, by field name.
    + fn files() Map[InMemoryFile]
    // Returns the request headers, with names lowercased.
    + fn headers() Headers
    // Whether the client expects the connection to stay open after the response.
    + get keep_alive: bool
    // Returns the query string parameters.
    + fn params() Map[String]
    // Returns every value of each query string parameter, in order.
    + fn params_grouped() Map[Array[String]]
}
```

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
    + verify_ssl_cert: bool
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

```js
// A request passed to a server handler.
+ class Request {
    // The request method as sent, such as `GET`.
    + method: String
    // The path of the request target without the query string, not percent-decoded.
    + path: String
    // The query string without the leading `?`, not decoded; empty when absent.
    + query_string: String

    // The request body; empty when there is none.
    + get body: String
    // Returns the form fields of the request body.
    + fn data() Map[String]
    // Returns the request body as JSON.
    + fn data_json() Value
    // Returns the uploaded files of a `multipart/form-data` body, by field name.
    + fn files() Map[InMemoryFile]
    // Returns the request headers, with names lowercased.
    + fn headers() Headers
    // Returns the query string parameters.
    + fn params() Map[String]
    // Returns every value of each query string parameter, in order.
    + fn params_grouped() Map[Array[String]]
}
```

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
    // Creates a response with an empty body; also backs default construction.
    + static fn empty(code: u16 (200), headers: ?Headers (null)) Response
    // Creates a response that sends the file at `path`.
    + static fn file(path: String, filename: ?String (null)) Response
    // The extra response headers, created empty on first access.
    + get headers: Headers
    // Creates a `text/html` response.
    + static fn html(body: String, code: u16 (200), headers: ?Headers (null)) Response
    // Creates an `application/json` response; `body` must already be encoded JSON.
    + static fn json(body: String, code: u16 (200), headers: ?Headers (null)) Response
    // Creates a redirect to `location` with an empty body.
    + static fn redirect(location: String, code: u16 (302), headers: ?Headers (null)) Response
    // Sets the header `name` to `value`, replacing earlier values for that name.
    + fn set_header(name: String, value: String) void
    // Creates a response whose body is streamed from `reader`.
    + static fn stream(reader: Reader, size: uint, content_type: String ("application/octet-stream"), filename: ?String (null)) Response
    // Creates a response with the given `content_type`, `text/plain` by default.
    + static fn text(body: String, code: u16 (200), content_type: String ("text/plain"), headers: ?Headers (null)) Response
}
```

```js
// Writes the HTTP/1.1 response for one request; passed to `fast` handlers.
+ class ResponseWriter {
    // Whether a response has been written for the current request.
    ~ responded: bool

    // Returns the reason phrase for `code`, such as `Bad Request`.
    + static fn code_name(code: u16) String
    // Responds with status `code`, `content_type` and `body`.
    + fn respond(body: String, code: u16 (200), content_type: String ("text/plain"), headers: ?Headers (null)) void
    // Responds with status `code` and the file at `path`; responds 404 when it cannot be opened.
    + fn send_file(path: String, filename: ?String (null), headers: ?Headers (null), code: u16 (200)) void
    // Responds with `status_code` and an empty `text/plain` body.
    + fn send_status(status_code: u16) void
    // Responds with status `code` and a body streamed from `reader`.
    + fn send_stream(reader: Reader, size: uint, content_type: String ("application/octet-stream"), filename: ?String (null), headers: ?Headers (null), code: u16 (200)) void
}
```

```js
// A route found by `Router.find`: the handler plus the positions of its `@name` parts.
+ class Route[T] {
    // The value registered with `Router.add`.
    + handler: T

    // Returns the values of the route's `@name` parts, taken from `path`.
    + fn params(path: String) Map[String]
}
```

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

```js
// A multi-threaded HTTP/1.1 server, with optional TLS and experimental HTTP/2.
+ class Server {
    // How long each read of a request body may take, in milliseconds.
    + body_timeout_ms: uint
    // A handler that replaces the regular one, see `fast`.
    + fast_handler: ?shared fn(Context, ResponseWriter)()
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
    // Whether the server prints startup, connection and error messages.
    + show_info: bool
    // How long each socket write may take, in milliseconds.
    + write_timeout_ms: uint

    // Serves files from the directory `path` before a request reaches the handler.
    + fn add_static_dir(path: String) void !LookupError
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
}
```

# io

## Aliases for 'io'

```js
alias Fd for i32
```

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

## Classes for 'io'

```js
// A resource that is released with `close`.
+ interface Closer {
    // Releases the resource.
    + fn close() void !IoError
}
```

```js
// Reads a `Reader` line by line, buffering its input.
+ class LineReader {
    // Returns every remaining line, split as `read_line` does.
    + fn lines() Array[String] !IoError
    // Creates a line reader over `reader` that reads `chunk_size` bytes at a time.
    + static fn new(reader: Reader, chunk_size: uint (65536)) LineReader
    // Returns the next line without its `\n` or `\r\n`, or `null` once the input is exhausted.
    + fn read_line() ?String !IoError
    // Returns the bytes up to, not including, the next `delimiter`, or `null` at the end.
    + fn read_until(delimiter: u8) ?String !IoError
}
```

```js
// A source of bytes that is read one buffer at a time.
+ interface Reader {
    // Reads up to `buf.length` bytes into `buf` and returns the count; 0 means the end of input.
    + fn read(buf: local mut &[u8]) uint !IoError
}
```

```js
// A stream with a movable position.
+ interface Seeker {
    // Moves the position to `offset` bytes from `from` and returns the new position.
    + fn seek(offset: int, from: SeekFrom) uint !IoError
}
```

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

```js
// A destination for bytes.
+ interface Writer {
    // Writes bytes from `data` and returns the count, which may be less than `data.length`.
    + fn write(data: local &[u8]) uint !IoError
}
```

# json

## Functions for 'json'

```js
// Parses JSON text into a `Value`.
+ fn decode(json: String | ByteBuffer, max_depth: uint (JSON_MAX_DEPTH), max_bytes: uint (JSON_MAX_BYTES), max_entries: uint (JSON_MAX_ENTRIES)) Value !ParseError
// Parses JSON text directly into `T`, without building an intermediate `Value`.
+ fn decode_to[T](json: String | ByteBuffer, max_depth: uint (JSON_MAX_DEPTH), max_bytes: uint (JSON_MAX_BYTES), max_entries: uint (JSON_MAX_ENTRIES)) T !DecodeError
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

## Classes for 'json'

```js
// A JSON array: an ordered list of `Value` items.
+ class ArrayValue {
    // The items, in order. Changes to this array change the JSON array.
    + values: Array[Value]

    // Appends `value` to the end.
    + fn append(value: Value) void
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

```js
// A JSON object: `Value` members keyed by string, kept in insertion order.
+ class ObjectValue {
    // The members. Changes to this map change the JSON object.
    + values: Map[Value]

    // Returns the member named `key`.
    + fn get(key: String) Value !LookupError
    // Returns whether a member named `key` exists.
    + fn has(key: String) bool
    // Returns the number of members.
    + get length: uint
    // Removes the member `key`; does nothing when it does not exist.
    + fn remove(key: String) void
    // Sets the member `key` to `value`; an existing member keeps its position.
    + fn set(key: String, value: Value) void
}
```

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
    // Returns the integer at `key`.
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
    // Returns the integer held.
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

# markdown

## Functions for 'markdown'

```js
// Converts the markdown text `md` to an HTML fragment.
+ fn to_html(md: String, options: ?ToHtmlOptions (null)) String
// Writes `to_html(md)` to `out` and returns the bytes written.
+ fn to_html_into(md: String, out: Writer, options: ?ToHtmlOptions (null)) uint !io:IoError
```

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
+ fn equal_bytes(a: ptr, b: ptr, length: uint) bool
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

# net

## Functions for 'net'

```js
// Receives once from the socket `fd` into `buf` and returns the number of bytes read.
+ fn recv(fd: i32, buf: local mut &[u8], timeout_ms: uint (5000)) uint !io:IoError
// Connects to a TCP server; the same as `TcpConnection.new`.
+ fn tcp_client(host: String, port: u16, timeout_ms: uint (5000), local_port: u16 (0), local_host: String ("")) TcpConnection !NetError
// Opens a listening TCP socket; the same as `TcpServer.new`.
+ fn tcp_server(host: String, port: u16, timeout_ms: uint (5000)) shared TcpServer !NetError
// Opens a UDP socket that talks to one server; the same as `UdpClient.new`.
+ fn udp_client(host: String, port: u16, timeout_ms: uint (5000), local_port: u16 (0), local_host: String ("")) UdpClient !NetError
// Binds a UDP socket to your own address; the same as `UdpServer.new`.
+ fn udp_server(host: String, port: u16, timeout_ms: uint (5000), reuse_address: bool (false)) UdpServer !NetError
// Sends once from `data` on the socket `fd` and returns the number of bytes sent.
+ fn write(fd: i32, data: local &[u8], timeout_ms: uint (5000)) uint !io:IoError
```

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

```js
// An IPv4 or IPv6 address with a port: the peer of a datagram, or a bound endpoint.
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
    // Returns the IPv4 address `a.b.c.d` with `port`.
    + static fn ipv4(a: u8, b: u8, c: u8, d: u8, port: u16 (0)) SocketAddress
    // Parses a numeric host such as `"127.0.0.1"`, `"::1"` or `"[::1]"`; never does a DNS lookup.
    + static fn parse(host: String, port: u16 (0)) SocketAddress !NetError
    // Resolves a host name or numeric host to one address, preferring IPv4 when both exist.
    + static fn resolve(host: String, port: u16, timeout_ms: uint (5000)) SocketAddress !NetError
    // Returns the address with its port, as `"127.0.0.1:80"` or `"[::1]:80"`.
    + fn to_string() String
}
```

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

```js
// Server-side TLS settings (certificate, key, versions, ciphers) shared by all connections.
+ class SslServerContext {
    // The OpenSSL `SSL_CTX` handle.
    ~ ctx: SSL_CTX

    // Returns a new server session using `context`, for one connection.
    + static fn connection(context: shared SslServerContext) Ssl
    // Loads the PEM `certificate_file` and `private_key_file` and checks that they match.
    + static fn new(certificate_file: String, private_key_file: String, min_version: TlsVersion (TlsVersion.tls_1_2), cipher_list: ?String (null), cipher_suites: ?String (null)) SslServerContext !NetError
}
```

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
    + static fn new(host: String, port: u16, timeout_ms: uint (5000)) shared TcpServer !NetError
}
```

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

# regex

## Functions for 'regex'

```js
// Returns `text` with every regex metacharacter escaped, so the result matches `text` literally.
+ fn escape(text: String) String
// Returns whether `pattern` matches anywhere in `text`, compiling the pattern on every call.
+ fn is_match(pattern: String, text: String) bool !RegexError
```

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

# signal

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

# sync

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

```js
// A first-in first-out queue of values between coroutines, on one thread or across threads.
+ class Channel[T] {
    // Closes the channel and wakes every waiting sender and receiver; a second call does nothing.
    + fn close() void
    // Returns true once `close` was called.
    + fn is_closed() bool
    // The number of values currently queued.
    + get length: uint
    // Returns an empty channel holding at most `capacity` values; 0 is unbounded.
    + static fn new(capacity: uint (0)) Channel[T] !SyncError
    // Returns the next value, waiting for one.
    + fn recv(timeout_ms: uint (0), cancel: ?shared CancelToken (null)) T !SyncError
    // Queues `value`, waiting while the channel is full.
    + fn send(value: T, timeout_ms: uint (0), cancel: ?shared CancelToken (null)) void !SyncError
    // Returns the next value without waiting; throws `empty` when none is queued.
    + fn try_recv() T !SyncError
    // Queues `value` without waiting.
    + fn try_send(value: T) void !SyncError
}
```

```js
// A wakeup for the coroutine or thread that waits on it; `wake` may be called from any thread.
+ class Waker {
    // Returns a new waker; throws `init` when its pipe cannot be created (Linux and macOS).
    + static fn new() Waker !SyncError
    // Waits for a wake; returns false when `timeout_ms` (0 = forever) ran out first.
    + fn wait(timeout_ms: uint (0)) bool
    // Wakes the waiter; safe from any thread, and kept for the next `wait` when nobody waits.
    + fn wake() void
}
```

# template

## Functions for 'template'

```js
// Renders the registered template `name` with `data` and returns the output.
+ fn render(name: String, data: $T, options: ?RenderOptions (null)) String !ParseError
// Renders the template text `content` with `data` and returns the output.
+ fn render_content(content: String, data: $T, options: ?RenderOptions (null)) String !ParseError
// Writes `render_content(content, data, options)` to `out` and returns the bytes written.
+ fn render_content_into(content: String, data: $T, out: Writer, options: ?RenderOptions (null)) uint !ParseError
// Writes `render(name, data, options)` to `out` and returns the bytes written.
+ fn render_into(name: String, data: $T, out: Writer, options: ?RenderOptions (null)) uint !ParseError
// Registers `content` as the template named `name`, replacing any earlier one.
+ fn set_content(name: String, content: String) void
// Registers every entry of `content` as a template, keyed by name; see `set_content`.
+ fn set_content_many(content: Map[String]) void
```

## Classes for 'template'

```js
// Options for `render` and `render_content`.
+ class RenderOptions {
    // Function applied to every `{{ }}` output; HTML escaping by default, `null` for none.
    + escape: ?fn(String)(String)
    // Maximum nesting of `@include`/`@extend` templates.
    + max_depth: uint
}
```

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

## Classes for 'thread'

```js
// A handler queued with `task`.
+ class Task {
    // Waits until the task's handler has returned; returns at once when it already has.
    + fn await() void
}
```

```js
// An OS thread running one handler that returns a `T`.
+ class Thread[T] {
    // Waits until the handler has returned and returns its result.
    + fn await() T
    // Starts an OS thread that runs `func` inside a coroutine, and returns its handle.
    + static fn start(func: shared fn()(T)) Thread[T] !InitError
}
```

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

# time

## Functions for 'time'

```js
// Returns a monotonic clock reading in milliseconds, for measuring durations.
+ fn mono_ms() uint
// Returns a monotonic clock reading in nanoseconds, for measuring durations.
+ fn mono_ns() uint
// Returns a monotonic clock reading in microseconds, for measuring durations.
+ fn mono_us() uint
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
```

## Classes for 'time'

```js
// A UTC date and time with microsecond precision, for the years 1 to 9999.
+ class DateTime {
    // Returns a copy moved by `amount` days of exactly 24 hours, which may be negative.
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
    // Writes `format(pattern)` to `out` and returns the bytes written.
    + fn format_into(pattern: String, out: Writer) uint !io:IoError
    // Parses `value` laid out by `pattern`, using the tokens of `format`.
    + static fn from_format(pattern: String, value: String) DateTime !SyntaxError
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
    // Returns whether the year is a leap year in the Gregorian calendar.
    + fn is_leap_year() bool
    // Returns whether this value is earlier than `other`; backs the `<` operator (`$lt`).
    + fn less_than(other: DateTime) bool
    // Returns the microseconds within the second, 0 to 999999.
    + fn microsecond() uint
    // Returns the minute, 0 to 59.
    + fn minute() uint
    // Moves this value by `amount` days of 24 hours in place.
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
    // Returns the current UTC date and time.
    + static fn now() DateTime
    // Returns the second, 0 to 59.
    + fn second() uint
    // Returns the value as ISO 8601 text in UTC, such as `2024-03-05T14:07:09Z`.
    + fn to_iso8601() String
    // Writes `to_iso8601()` to `out` and returns the bytes written.
    + fn to_iso8601_into(out: Writer) uint !io:IoError
    // Returns `to_iso8601()`; `$auto` lets a `DateTime` convert to `String` implicitly.
    + fn to_string() String
    // Returns the whole seconds since the Unix epoch, rounded down (towards the past).
    + fn unix_seconds() int
    // Returns the microseconds since the Unix epoch.
    + fn unix_us() int
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
}
```

# url

## Functions for 'url'

```js
// Decodes `%XX` escapes and turns every `+` into a space.
+ fn decode(str: String) String
// Writes `str` decoded as `decode` does to `out` and returns the bytes written.
+ fn decode_into(str: String, out: Writer) uint !io:IoError
// Percent-encodes `str` for use in the given URL `component`.
+ fn encode(str: String, component: Component (Component.unreserved)) String
// Writes `str` percent-encoded as `encode` does to `out` and returns the bytes written.
+ fn encode_into(str: String, out: Writer, component: Component (Component.unreserved)) uint !io:IoError
// Splits `str` into a `Url`; it never fails.
+ fn parse(str: String) Url
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

# validate

## Functions for 'validate'

```js
// Returns whether `email` looks like a valid email address, by a simple ASCII syntax check.
+ fn email(email: String) bool
```

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

## Globals for 'validate'

```js
// The English messages `translate_errors` uses by default, keyed by error code.
+ global default_translations : Map[String]
```
