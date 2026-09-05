
# Documentation

Namespaces: [ansi](#ansi) | [core](#core) | [coro](#coro) | [crypto](#crypto) | [ext](#ext) | [fs](#fs) | [gc](#gc) | [html](#html) | [http](#http) | [io](#io) | [json](#json) | [markdown](#markdown) | [math](#math) | [mem](#mem) | [net](#net) | [template](#template) | [thread](#thread) | [time](#time) | [url](#url) | [validate](#validate)

---

# ansi

## Functions for 'ansi'

```js
+ fn supported() bool
+ fn utf8_supported() bool
```

# core

## Functions for 'core'

```js
+ fn cleanup_warning(msg: String, file: String, line: uint) void
+ fn clone_value(value: $T) T
+ fn exec(cmd: String, print_output: bool (false), capture_stderr: bool (true)) (i32, String)
+ fn exit(code: i32) void
+ fn getenv(var: String) String !LookupError
+ fn panic(msg: String) void
+ fn race_lock() void
+ fn race_unlock() void
+ fn raise(code: i32) void
+ fn read_big_endian(from: *[u8], bytes: uint) uint
+ fn read_little_endian(from: *[u8], bytes: uint) uint
+ fn signal_ignore(sig: int) void
+ fn write_big_endian(to: *[u8], v: uint, bytes: uint) void
+ fn write_little_endian(to: *[u8], v: uint, bytes: uint) void
```

## Classes for 'core'

```js
+ array Array[T] {
    ~ data: ?GcPtr
    ~ length: uint
    ~ size: uint

    + fn append(item: T, unique: bool (false)) Array[T]
    + fn append_many(items: Array[T]) Array[T]
    + fn clear(reduce_size: bool (false)) Array[T]
    + fn clone() Array[T]
    + fn contains(value: T) bool
    + fn copy() Array[T]
    + fn equal(array: Array[T]) bool
    + fn equal_ignore_order(array: Array[T]) bool
    + fn filter(func: ?fn(T)(bool) (null)) Array[T]
    + fn filter_self(func: ?fn(T)(bool) (null)) Array[T]
    + fn fit_index(index: uint) void
    + static fn from_json_value_auto[X](value: X) Array[T] !LookupError
    + fn get(index: uint) T !LookupError
    + fn increase_size(new_size: uint) void
    + fn index_of(item: T) uint !LookupError
    + fn intersect(with: Array[T]) Array[T]
    + fn items() *[T]
    + fn iter() Slice[T]
    + fn join(divider: String) String
    + fn merge(items: Array[T]) Array[T]
    + fn merge_in_place(items: Array[T]) Array[T]
    + static fn new(start_size: uint (0)) Array[T]
    + fn part(start: uint, amount: uint) Array[T]
    + fn pop_first() T !LookupError
    + fn pop_last() T !LookupError
    + fn prepend(item: T, unique: bool (false)) Array[T]
    + fn prepend_many(items: Array[T]) Array[T]
    + fn range(start: uint, end: uint, inclusive: bool (true)) Array[T]
    + fn remove(index: uint) Array[T]
    + fn remove_value(value: T) Array[T]
    + fn reverse() Array[T]
    + fn set(index: uint, value: T) void !LookupError
    + fn set_all(value: T) void
    + fn set_expand(index: uint, value: T, filler_value: T) void
    + fn slice(start: uint, amount: uint) Slice[T]
    + fn sort(func: ?fn(T, T)(bool) (null)) Array[T]
    + fn swap(index_a: uint, index_b: uint) void
    + fn swap_remove(index: uint) Array[T]
    + fn unique() Array[T]
    + fn view(start: uint (0), amount: ?uint (null)) Slice[T]
}
```

```js
+ class ByteBuffer is Writer {
    ~ data: ptr
    ~ length: uint
    ~ size: uint
    ~ storage: String

    + fn advance(amount: uint) void
    + fn clear() void
    + fn clear_next_bytes(amount: uint) void
    + fn clear_part(index: uint, len: uint) void
    + fn clear_until(index: uint) void
    + fn clone() ByteBuffer
    + fn ensure_capacity(minimum_capacity: uint) void
    + fn equals_string(str: String) bool
    + fn fill(with: u8, amount: uint) void
    + fn get(index: uint) u8
    + fn index_of(byte: u8, start_index: uint (0)) uint !LookupError
    + fn index_where_byte_is_not(byte: u8, start_index: uint (0)) uint !LookupError
    + fn into_string() String
    + fn ltrim(filter: fnptr(u8)(bool)) void
    + static fn new(start_size: uint (128)) ByteBuffer
    + fn part(start_index: uint, length: uint) String
    + fn reader() ByteReader
    + fn reserve(length: uint) void
    + fn resize(length: uint) void
    + fn rtrim(filter: fnptr(u8)(bool)) void
    + fn set(index: uint, v: u8) void
    + fn shrink_capacity(size: uint) void
    + fn skip(amount: uint) void
    + fn starts_with(str: String, offset: uint (0)) bool
    + fn to_slice() Slice[u8]
    + fn to_string() String
    + fn trim(filter: fnptr(u8)(bool)) void
    + fn truncate(length: uint) void
    + fn view(offset: uint, length: uint) Slice[u8]
    + fn write(data: Slice[u8]) uint
    + fn write_big_endian(value: uint, bytes: uint) void
    + fn write_byte(v: u8) void
    + fn write_cstring(str: cstring, include_zero_byte: bool) void
    + fn write_f64_ascii(v: f64, decimals: uint, trim_zeros: bool (false)) void
    + fn write_f64_ascii_shortest(v: f64) void
    + fn write_f64_be(v: f64) void
    + fn write_f64_le(v: f64) void
    + fn write_int_ascii(v: int, base: u8 (10)) void
    + fn write_little_endian(value: uint, bytes: uint) void
    + fn write_u16_be(v: u16) void
    + fn write_u16_le(v: u16) void
    + fn write_u32_be(v: u32) void
    + fn write_u32_le(v: u32) void
    + fn write_u64_be(v: u64) void
    + fn write_u64_le(v: u64) void
    + fn write_uint_ascii(v: uint, base: u8 (10)) void
}
```

```js
+ class ByteReader is Reader, Seeker {
    + pos: uint
    + source: Slice[u8]

    + fn get_pos() uint
    + static fn new(source: Slice[u8]) ByteReader
    + fn read(buf: Slice[u8]) uint !io:IoError
    + fn read_big_endian(bytes: uint) uint
    + fn read_byte() u8
    + fn read_cstring() String
    + fn read_float() float
    + fn read_hex_int() int
    + fn read_hex_uint() uint
    + fn read_int() int
    + fn read_little_endian(bytes: uint) uint
    + fn read_octal_int() int
    + fn read_octal_uint() uint
    + fn read_remaining_string() String
    + fn read_string(len: uint) String
    + fn read_u16_be() u16
    + fn read_u16_le() u16
    + fn read_u32_be() u32
    + fn read_u32_le() u32
    + fn read_u64_be() u64
    + fn read_u64_le() u64
    + fn read_uint() uint
    + fn read_uint_be() uint
    + fn read_uint_le() uint
    + fn remaining() Slice[u8]
    + fn reset() void
    + fn rewind(amount: uint) void
    + fn seek(offset: int, from: SeekFrom (io.SeekFrom.start)) uint !io:IoError
    + fn set_pos(index: uint) void
    + fn skip(amount: uint) void
}
```

```js
+ class FlatMap[K, T] {
    + fn clear() FlatMap[K, T]
    + fn clone() FlatMap[K, T]
    + fn copy() FlatMap[K, T]
    + fn get(key: K) T !LookupError
    + fn has(key: K) bool
    + fn has_value(value: T) bool
    + fn keys() Array[K]
    + get length: uint
    + fn merge(map: FlatMap[K, T]) FlatMap[K, T]
    + fn merge_in_place(map: FlatMap[K, T]) FlatMap[K, T]
    + static fn new() FlatMap[K, T]
    + fn remove(key: K) FlatMap[K, T]
    + fn set(key: K, value: T) FlatMap[K, T]
    + fn set_many(map: FlatMap[K, T]) FlatMap[K, T]
    + fn set_unique(key: K, value: T) FlatMap[K, T] !LookupError
    + fn sort_keys() FlatMap[K, T]
    + fn values() Array[T]
}
```

```js
+ class HashMap[K, T] {
    + fn clear() HashMap[K, T]
    + fn clone() HashMap[K, T]
    + fn copy() HashMap[K, T]
    + fn get(key: K) T !LookupError
    + fn get_or_replace(key: K, remove_key: K, replacement: T) (T, bool) !LookupError
    + fn has(key: K) bool
    + fn has_value(value: T) bool
    + fn keys() Array[K]
    + get length: uint
    + fn merge(map: HashMap[K, T]) HashMap[K, T]
    + fn merge_in_place(map: HashMap[K, T]) HashMap[K, T]
    + static fn new(capacity: uint (0)) HashMap[K, T]
    + fn remove(key: K) HashMap[K, T]
    + fn set(key: K, value: T) HashMap[K, T]
    + fn set_unique(key: K, value: T) HashMap[K, T] !LookupError
    + fn sort_keys() HashMap[K, T]
    + fn values() Array[T]
}
```

```js
+ extend HashMap[String, T] {
    + static fn from_json_value_auto[X](value: X) HashMap[String, T] !LookupError
}
```

```js
+ mode Map[T] for HashMap[String, T] {
    + fn clone() Map[T]
    + static fn new() Map[T]
}
```

```js
+ class Mutex {
    + fn await_unlock() void
    + fn clone() Mutex
    + fn lock() void
    + static fn new() Mutex !InitError
    + fn unlock() void
}
```

```js
+ class Pool[T] {
    ~ count: uint

    + fn add(item: T) void
    + fn get() T !LookupError
    + static fn new(start_size: uint (2)) Pool[T]
}
```

```js
+ class Process {
    + fn detach() void !io:IoError
    + fn did_exit() bool !io:IoError
    + fn exit_code() i32 !io:IoError
    + static fn run(exe: String, args: ?Array[String], print_output: bool (false)) Process !io:IoError
    + fn stop() void !io:IoError
}
```

```js
+ slice Slice[T] of T {
    ~ data: *[T]
    ~ length: uint
    ~ owner: ?GcPtr

    + fn append(item: T) Slice[T]
    + fn get(index: uint) T !LookupError
    + static fn new(length: uint, value: T) Slice[T]
    + fn set(index: uint, value: T) void !LookupError
    + fn set_all(value: T) void
    + fn view(offset: uint, length: uint) Slice[T]
}
```

```js
+ extend Slice[u8] {
    + fn equal_at_ignore_ascii_case(offset: uint, length: uint, cmp: String) bool
    + fn equal_ignore_ascii_case(cmp: String) bool
    + fn equals(cmp: String) bool
    + fn equals_at(offset: uint, length: uint, cmp: String) bool
    + fn has_ascii_control(allow_tab: bool (false)) bool
    + fn index_of_byte(byte: u8, start_index: uint (0)) uint !LookupError
    + fn reader() ByteReader
    + fn starts_with(cmp: String) bool
    + fn to_ascii_lower_string() String
    + fn to_float() float !SyntaxError
    + fn to_int() int !SyntaxError
    + fn to_string() String
    + fn to_uint() uint !SyntaxError
}
```

```js
+ slice String of u8 {
    ~ data: *[u8]
    ~ length: uint
    ~ owner: ?GcPtr

    + static fn alloc(length: uint) String
    + get bytes: uint
    + fn clone() String
    + fn contains(part: String, start_index: uint (0)) bool
    + fn contains_byte(byte: u8, start_index: uint (0)) bool
    + static fn copy_from_ptr(data: ptr, length: uint) String
    + get data_cstring: cstring
    + fn ends_with(part: String) bool
    + fn equal_ignore_ascii_case(other: String) bool
    + fn escape() String
    + fn get(index: uint) u8
    + fn hash() uint
    + fn hex_to_int() int !SyntaxError
    + fn hex_to_uint() uint !SyntaxError
    + fn index_of(part: String, start_index: uint (0)) uint !LookupError
    + fn index_of_byte(byte: u8, start_index: uint (0)) uint !LookupError
    + fn is_alpha(allow_extra_bytes: String ("")) bool
    + fn is_alpha_numeric(allow_extra_bytes: String ("")) bool
    + fn is_empty() bool
    + fn is_integer() bool
    + fn is_lower() bool
    + fn is_number() bool
    + fn is_syntax(mask: String, mask_is_exclude: bool (false)) bool
    + fn is_upper() bool
    + fn lower() String
    + fn ltrim(part: String, limit: uint (0)) String
    + fn octal_to_int() int !SyntaxError
    + fn octal_to_uint() uint !SyntaxError
    + fn pad_left(char: u8, length: uint) String
    + fn pad_right(char: u8, length: uint) String
    + fn part(start_index: uint, length: uint) String
    + static fn random(len: uint, characters: String ("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")) String
    + fn range(start: uint, end: uint, inclusive: bool (true)) String
    + fn reader() ByteReader
    + fn replace(part: String, with: String) String
    + fn rtrim(part: String, limit: uint (0)) String
    + fn split(on: String) Array[String]
    + fn starts_with(part: String) bool
    ~ fn take_length(length: uint) String
    + fn to_float() f64 !SyntaxError
    + fn to_int() int !SyntaxError
    + fn to_slice() Slice[u8]
    + fn to_string() String
    + fn to_uint() uint !SyntaxError
    + fn trim(part: String, limit: uint (0)) String
    + fn unescape() String
    + fn upper() String
    + fn view(start_index: uint, length: uint) Slice[u8]
}
```

```js
+ class SyncMutex {
    + fn lock() void
    + static fn new() SyncMutex
    + fn unlock() void
}
```

```js
+ class bool {
}
```

```js
+ mode char for u8 {
    + fn to_string() String
}
```

```js
+ class cstring {
    + fn get(index: uint) u8
    + fn index_of(find: u8) uint !LookupError
    + fn length() uint
    + fn to_string() String
}
```

```js
+ class f32 {
    + fn abs() f32
    + fn clamp(minimum: f32, maximum: f32) f32
    + fn is_finite() bool
    + fn is_infinite() bool
    + fn is_nan() bool
    + fn max(other: f32) f32
    + fn min(other: f32) f32
    + fn to_shortest_string() String
    + fn to_shortest_string_in_ptr(buf: ptr) uint
    + fn to_string(decimals: uint (2), trim_zeros: bool (false)) String
    + fn to_string_in_ptr(buf: ptr, decimals: uint (2), trim_zeros: bool (false)) uint
}
```

```js
+ class f64 {
    + fn abs() f64
    + fn clamp(minimum: f64, maximum: f64) f64
    + fn is_finite() bool
    + fn is_infinite() bool
    + fn is_nan() bool
    + fn max(other: f64) f64
    + fn min(other: f64) f64
    + fn to_shortest_string() String
    + fn to_shortest_string_in_ptr(buf: ptr) uint
    + fn to_string(decimals: uint (2), trim_zeros: bool (false)) String
    + fn to_string_in_ptr(buf: ptr, decimals: uint (2), trim_zeros: bool (false)) uint
}
```

```js
+ class float {
    + fn abs() float
    + fn clamp(minimum: float, maximum: float) float
    + fn is_finite() bool
    + fn is_infinite() bool
    + fn is_nan() bool
    + fn max(other: float) float
    + fn min(other: float) float
    + fn to_shortest_string() String
    + fn to_shortest_string_in_ptr(buf: ptr) uint
    + fn to_string(decimals: uint (2), trim_zeros: bool (false)) String
    + fn to_string_in_ptr(buf: ptr, decimals: uint (2), trim_zeros: bool (false)) uint
}
```

```js
+ class i16 {
    + fn abs() i16
    + fn character_length(base: i16) uint
    + fn clamp(minimum: i16, maximum: i16) i16
    + fn equals_string(str: String) bool
    + fn max(other: i16) i16
    + fn min(other: i16) i16
    + fn print(base: i16) void
    + static fn random() i16
    + static fn read_big_endian(from: *[u8 x 2]) i16
    + static fn read_little_endian(from: *[u8 x 2]) i16
    + fn round_down(modulo: i16) i16
    + fn round_up(modulo: i16) i16
    + fn to_base(base: i16) String
    + fn to_base_to_ptr(base: i16, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_string() String
    + static fn write_big_endian(v: i16, to: *[u8 x 2]) void
    + static fn write_little_endian(v: i16, to: *[u8 x 2]) void
}
```

```js
+ class i32 {
    + fn abs() i32
    + fn character_length(base: i32) uint
    + fn clamp(minimum: i32, maximum: i32) i32
    + fn equals_string(str: String) bool
    + fn max(other: i32) i32
    + fn min(other: i32) i32
    + fn print(base: i32) void
    + static fn random() i32
    + static fn read_big_endian(from: *[u8 x 4]) i32
    + static fn read_little_endian(from: *[u8 x 4]) i32
    + fn round_down(modulo: i32) i32
    + fn round_up(modulo: i32) i32
    + fn to_base(base: i32) String
    + fn to_base_to_ptr(base: i32, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_string() String
    + static fn write_big_endian(v: i32, to: *[u8 x 4]) void
    + static fn write_little_endian(v: i32, to: *[u8 x 4]) void
}
```

```js
+ class i64 {
    + fn abs() i64
    + fn character_length(base: i64) uint
    + fn clamp(minimum: i64, maximum: i64) i64
    + fn equals_string(str: String) bool
    + fn max(other: i64) i64
    + fn min(other: i64) i64
    + fn print(base: i64) void
    + static fn random() i64
    + static fn read_big_endian(from: *[u8 x 8]) i64
    + static fn read_little_endian(from: *[u8 x 8]) i64
    + fn round_down(modulo: i64) i64
    + fn round_up(modulo: i64) i64
    + fn to_base(base: i64) String
    + fn to_base_to_ptr(base: i64, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_string() String
    + static fn write_big_endian(v: i64, to: *[u8 x 8]) void
    + static fn write_little_endian(v: i64, to: *[u8 x 8]) void
}
```

```js
+ class i8 {
    + fn abs() i8
    + fn character_length(base: i8) uint
    + fn clamp(minimum: i8, maximum: i8) i8
    + fn equals_string(str: String) bool
    + fn max(other: i8) i8
    + fn min(other: i8) i8
    + fn print(base: i8) void
    + static fn random() i8
    + static fn read_big_endian(from: *u8) i8
    + static fn read_little_endian(from: *u8) i8
    + fn round_down(modulo: i8) i8
    + fn round_up(modulo: i8) i8
    + fn to_base(base: i8) String
    + fn to_base_to_ptr(base: i8, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_string() String
    + static fn write_big_endian(v: i8, to: *u8) void
    + static fn write_little_endian(v: i8, to: *u8) void
}
```

```js
+ class int {
    + fn abs() int
    + fn character_length(base: int) uint
    + fn clamp(minimum: int, maximum: int) int
    + fn equals_string(str: String) bool
    + fn max(other: int) int
    + fn min(other: int) int
    + fn print(base: int) void
    + static fn random() int
    + static fn read_big_endian(from: *[u8 x 8]) int
    + static fn read_little_endian(from: *[u8 x 8]) int
    + fn round_down(modulo: int) int
    + fn round_up(modulo: int) int
    + fn to_base(base: int) String
    + fn to_base_to_ptr(base: int, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_string() String
    + static fn write_big_endian(v: int, to: *[u8 x 8]) void
    + static fn write_little_endian(v: int, to: *[u8 x 8]) void
}
```

```js
+ class ptr {
    + fn clear_bytes(amount: uint) void
    + fn create_string(length: uint) String
    + fn determine_float_length(max_bytes: uint) uint
    + fn determine_hex_int_length(max_bytes: uint) uint
    + fn determine_hex_uint_length(max_bytes: uint) uint
    + fn determine_int_length(max_bytes: uint) uint
    + fn determine_octal_int_length(max_bytes: uint) uint
    + fn determine_octal_uint_length(max_bytes: uint) uint
    + fn determine_uint_length(max_bytes: uint) uint
    + fn equals(data: ptr, len: uint) bool
    + fn equals_string(str: String) bool
    + fn fill_bytes(byte: u8, amount: uint) void
    + fn index_of_byte(byte: u8, memory_size: uint) uint !LookupError
    + fn index_of_byte_inf(byte: u8) uint
    + fn print_bytes(length: uint, end_with_newline: bool (true)) void
    + fn read_big_endian(bytes: uint) uint
    + fn read_byte() u8
    + fn read_cstring(memory_size: uint) String
    + fn read_cstring_inf() String
    + fn read_float(len: uint) float !SyntaxError
    + fn read_float_dynamic(max_bytes: uint) (float, uint)
    + fn read_hex_int(len: uint) int !SyntaxError
    + fn read_hex_int_dynamic(max_bytes: uint) (int, uint)
    + fn read_hex_uint(len: uint) uint !SyntaxError
    + fn read_hex_uint_dynamic(max_bytes: uint) (uint, uint)
    + fn read_int(len: uint) int !SyntaxError
    + fn read_int_dynamic(max_bytes: uint) (int, uint)
    + fn read_little_endian(bytes: uint) uint
    + fn read_octal_int(len: uint) int !SyntaxError
    + fn read_octal_int_dynamic(max_bytes: uint) (int, uint)
    + fn read_octal_uint(len: uint) uint !SyntaxError
    + fn read_octal_uint_dynamic(max_bytes: uint) (uint, uint)
    + fn read_string(len: uint) String
    + fn read_u16_be() u16
    + fn read_u16_le() u16
    + fn read_u32_be() u32
    + fn read_u32_le() u32
    + fn read_u64_be() u64
    + fn read_u64_le() u64
    + fn read_uint(len: uint) uint !SyntaxError
    + fn read_uint_be() uint
    + fn read_uint_dynamic(max_bytes: uint) (uint, uint)
    + fn read_uint_le() uint
    + fn to_hex() String
    + fn write(data: Slice[u8]) void
    + fn write_big_endian(value: uint, bytes: uint) void
    + fn write_bytes(from: ptr, len: uint) void
    + fn write_cstring(str: cstring, include_zero_byte: bool) void
    + fn write_int_ascii(v: int, base: u8 (10), lowercase: bool (false)) uint
    + fn write_little_endian(value: uint, bytes: uint) void
    + fn write_u16_be(v: u16) void
    + fn write_u16_le(v: u16) void
    + fn write_u32_be(v: u32) void
    + fn write_u32_le(v: u32) void
    + fn write_u64_be(v: u64) void
    + fn write_u64_le(v: u64) void
    + fn write_u8(v: u8) void
    + fn write_uint_ascii(v: uint, base: u8 (10), lowercase: bool (false)) uint
    + fn write_uint_be(v: uint) void
    + fn write_uint_le(v: uint) void
}
```

```js
+ class u16 {
    + fn abs() u16
    + fn character_length(base: u16) uint
    + fn clamp(minimum: u16, maximum: u16) u16
    + fn equals_string(str: String) bool
    + fn max(other: u16) u16
    + fn min(other: u16) u16
    + fn print(base: u16) void
    + static fn random() u16
    + static fn read_big_endian(from: *[u8 x 2]) u16
    + static fn read_little_endian(from: *[u8 x 2]) u16
    + fn round_down(modulo: u16) u16
    + fn round_up(modulo: u16) u16
    + fn to_base(base: u16) String
    + fn to_base_to_ptr(base: u16, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_string() String
    + static fn write_big_endian(v: u16, to: *[u8 x 2]) void
    + static fn write_little_endian(v: u16, to: *[u8 x 2]) void
}
```

```js
+ class u32 {
    + fn abs() u32
    + fn character_length(base: u32) uint
    + fn clamp(minimum: u32, maximum: u32) u32
    + fn equals_string(str: String) bool
    + fn max(other: u32) u32
    + fn min(other: u32) u32
    + fn print(base: u32) void
    + static fn random() u32
    + static fn read_big_endian(from: *[u8 x 4]) u32
    + static fn read_little_endian(from: *[u8 x 4]) u32
    + fn round_down(modulo: u32) u32
    + fn round_up(modulo: u32) u32
    + fn to_base(base: u32) String
    + fn to_base_to_ptr(base: u32, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_string() String
    + static fn write_big_endian(v: u32, to: *[u8 x 4]) void
    + static fn write_little_endian(v: u32, to: *[u8 x 4]) void
}
```

```js
+ class u64 {
    + fn abs() u64
    + fn character_length(base: u64) uint
    + fn clamp(minimum: u64, maximum: u64) u64
    + fn equals_string(str: String) bool
    + fn max(other: u64) u64
    + fn min(other: u64) u64
    + fn print(base: u64) void
    + static fn random() u64
    + static fn read_big_endian(from: *[u8 x 8]) u64
    + static fn read_little_endian(from: *[u8 x 8]) u64
    + fn round_down(modulo: u64) u64
    + fn round_up(modulo: u64) u64
    + fn to_base(base: u64) String
    + fn to_base_to_ptr(base: u64, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_string() String
    + static fn write_big_endian(v: u64, to: *[u8 x 8]) void
    + static fn write_little_endian(v: u64, to: *[u8 x 8]) void
}
```

```js
+ class u8 {
    + fn abs() u8
    + fn character_length(base: u8) uint
    + fn clamp(minimum: u8, maximum: u8) u8
    + fn equals_string(str: String) bool
    + fn hex_byte_to_hex_value() u8
    + fn is_alpha() bool
    + fn is_alpha_numeric() bool
    + fn is_ascii() bool
    + fn is_hex() bool
    + fn is_html_spacing() bool
    + fn is_html_whitespace() bool
    + fn is_lower() bool
    + fn is_newline() bool
    + fn is_number() bool
    + fn is_octal() bool
    + fn is_space_or_tab() bool
    + fn is_upper() bool
    + fn is_whitespace() bool
    + fn max(other: u8) u8
    + fn min(other: u8) u8
    + fn print(base: u8) void
    + static fn random() u8
    + static fn read_big_endian(from: *u8) u8
    + static fn read_little_endian(from: *u8) u8
    + fn round_down(modulo: u8) u8
    + fn round_up(modulo: u8) u8
    + fn to_ascii_string() String
    + fn to_base(base: u8) String
    + fn to_base_to_ptr(base: u8, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_string() String
    + fn unescape() u8
    + static fn write_big_endian(v: u8, to: *u8) void
    + static fn write_little_endian(v: u8, to: *u8) void
}
```

```js
+ class uint {
    + fn abs() uint
    + fn character_length(base: uint) uint
    + fn checked_add(other: uint) uint !LookupError
    + fn checked_multiply(other: uint) uint !LookupError
    + fn clamp(minimum: uint, maximum: uint) uint
    + fn equals_string(str: String) bool
    + fn max(other: uint) uint
    + fn min(other: uint) uint
    + fn print(base: uint) void
    + static fn random() uint
    + static fn read_big_endian(from: *[u8 x 8]) uint
    + static fn read_little_endian(from: *[u8 x 8]) uint
    + fn round_down(modulo: uint) uint
    + fn round_up(modulo: uint) uint
    + fn to_base(base: uint) String
    + fn to_base_to_ptr(base: uint, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_string() String
    + static fn write_big_endian(v: uint, to: *[u8 x 8]) void
    + static fn write_little_endian(v: uint, to: *[u8 x 8]) void
}
```

# coro

## Functions for 'coro'

```js
+ fn await_coro(coro: Coro) void
+ fn await_last() void
```

# crypto

## Functions for 'crypto'

```js
+ fn base64_decode(str: String) String !CryptoError
+ fn base64_decode_ptr(data: ptr, len: uint, out: ByteBuffer) void !CryptoError
+ fn base64_encode(str: String) String
+ fn base64_encode_ptr(data: ptr, len: uint, out: ByteBuffer) void
+ fn bcrypt(cost: uint, salt: String, password: String, output: ByteBuffer) void !CryptoError
+ fn bcrypt_hash(password: String, cost: uint (12)) String !CryptoError
+ fn bcrypt_verify(password: String, hash: String) bool
+ fn md5_encode(input: String) String
+ fn random_bytes(length: uint) String
+ fn sha1_encode(str: String) String
+ fn sha256_encode(str: String) String
```

## Classes for 'crypto'

```js
+ class Blake2b {
    + fn finalize(out: *[u8]) void
    + static fn hash_string(input: String, key: ?String (null), lowercase: bool (true)) String !CryptoError
    + static fn new(hash_size: uint, key: ?String (null)) Blake2b !CryptoError
    + fn update(data: *[u8], length: uint) void
}
```

```js
+ class Sha1 {
    + fn add_hash_data(data: *[u8 x 20]) void
    + fn add_raw_data_unsafe(data: *[u8], len: uint) void
    + fn add_string_data(str: String) void
    + fn final() [u8 x 20]
    + fn reset() void
}
```

```js
+ class Sha256 {
    + fn add_hash_data(data: *[u8 x 32]) void
    + fn add_raw_data_unsafe(data: *[u8], len: uint) void
    + fn add_string_data(str: String) void
    + fn final() [u8 x 32]
    + fn reset() void
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
type libc_epoll_event (libc_gen_epoll_event)
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
+ fn get_errno() i32
+ fn set_errno(value: i32) void
```

## Classes for 'ext'

```js
+ struct io_uring {
    + cq: io_uring_cq
    + features: u32
    + flags: u32
    + pad: [u32 x 3]
    + ring_fd: i32
    + sq: io_uring_sq
}
```

```js
+ struct io_uring_cq {
    + cqes: *io_uring_cqe
    + kflags: *u32
    + khead: *u32
    + koverflow: *u32
    + kring_entries: *u32
    + kring_mask: *u32
    + ktail: *u32
    + pad: [u32 x 4]
    + ring_ptr: ptr
    + ring_sz: uint
}
```

```js
+ struct io_uring_cqe {
    + flags: u32
    + res: i32
    + user_data: u64
}
```

```js
+ struct io_uring_sq {
    + array: *u32
    + kdropped: *u32
    + kflags: *u32
    + khead: *u32
    + kring_entries: *u32
    + kring_mask: *u32
    + ktail: *u32
    + pad: [u32 x 4]
    + ring_ptr: ptr
    + ring_sz: uint
    + sqe_head: u32
    + sqe_tail: u32
    + sqes: *io_uring_sqe
}
```

```js
+ struct io_uring_sqe {
    + addr: u64
    + buf_index: u16
    + fd: i32
    + file_index: u32
    + flags: u8
    + ioprio: u16
    + len: u32
    + off: u64
    + opcode: u8
    + pad2: [u64 x 2]
    + personality: u16
    + rw_flags: u32
    + user_data: u64
}
```

```js
+ struct libc_gen___jmp_buf_tag {
    + __jmpbuf: [int x 8]
    + __mask_was_saved: i32
    + __saved_mask: libc_gen_anon_struct_2
}
```

```js
+ struct libc_gen_addrinfo {
    + ai_addr: *libc_gen_sockaddr
    + ai_addrlen: u32
    + ai_canonname: cstring
    + ai_family: i32
    + ai_flags: i32
    + ai_next: *libc_gen_addrinfo
    + ai_protocol: i32
    + ai_socktype: i32
}
```

```js
+ struct libc_gen_anon_struct_2 {
    + __val: [uint x 16]
}
```

```js
+ struct libc_gen_dirent {
    + d_ino: uint
    + d_name: [i8 x 256]
    + d_off: int
    + d_reclen: u16
    + d_type: u8
}
```

```js
+ struct libc_gen_epoll_data {
    + fd: i32
    + ptr: ptr
    + u32: u32
    + u64: uint
}
```

```js
+ struct libc_gen_epoll_event {
    + data: libc_gen_epoll_data
    + events: u32
}
```

```js
+ struct libc_gen_pollfd {
    + events: i16
    + fd: i32
    + revents: i16
}
```

```js
+ struct libc_gen_sockaddr {
    + sa_data: [i8 x 14]
    + sa_family: u16
}
```

```js
+ struct libc_gen_stat {
    + __glibc_reserved: [int x 3]
    + __pad0: i32
    + st_atim: libc_gen_timespec
    + st_blksize: int
    + st_blocks: int
    + st_ctim: libc_gen_timespec
    + st_dev: uint
    + st_gid: u32
    + st_ino: uint
    + st_mode: u32
    + st_mtim: libc_gen_timespec
    + st_nlink: uint
    + st_rdev: uint
    + st_size: int
    + st_uid: u32
}
```

```js
+ struct libc_gen_timespec {
    + tv_nsec: int
    + tv_sec: int
}
```

```js
+ struct libc_gen_timeval {
    + tv_sec: int
    + tv_usec: int
}
```

```js
+ struct libc_gen_timezone {
    + tz_dsttime: i32
    + tz_minuteswest: i32
}
```

```js
+ struct pthread_cond_t {
    + data: [uint x 12]
}
```

```js
+ struct pthread_condattr_t {
    + data: i32
}
```

```js
+ struct pthread_mutex_t {
    + data: [uint x 10]
}
```

```js
+ struct pthread_t {
    + data: uint
}
```

# fs

## Functions for 'fs'

```js
+ fn add(dir: String, fn: String) String
+ fn basename(path: String) String
+ fn chdir(path: String) void !io:IoError
+ fn chmod(path: String, permissions: u32) void !io:IoError
+ fn copy(from_path: String, to_path: String, recursive: bool (false)) void !io:IoError
+ fn cwd() String !io:IoError
+ fn delete(path: String) void !io:IoError
+ fn delete_recursive(path: String) void !io:IoError
+ fn dir_of(path: String) String
+ fn exe_dir() String !io:IoError
+ fn exe_path() String !io:IoError
+ fn exists(path: String) bool
+ fn extension(path: String, with_dot: bool (false)) String
+ fn files_in(dir: String, recursive: bool (false), files: bool (true), dirs: bool (true), relative: bool (false)) Array[String] !io:IoError
+ fn home_dir() String !LookupError
+ fn is_dir(path: String) bool
+ fn is_file(path: String) bool
+ fn is_symlink(path: String) bool
+ fn mime_type(ext_without_dot: String) String
+ fn mkdir(path: String, permissions: u32 (0c755)) void !io:IoError
+ fn modified_time(path: String) uint !io:IoError
+ fn move(from_path: String, to_path: String) void !io:IoError
+ fn open(path: String, options: ?OpenOptions (null)) i32 !io:IoError
+ fn path(path: String) Path
+ fn read(path: String) String !io:IoError
+ fn realpath(path: String) String !io:IoError
+ fn resolve(path: String) String
+ fn rmdir(path: String) void !io:IoError
+ fn size(path: String) uint !io:IoError
+ fn stream(path: String, options: ?OpenOptions (null)) FileStream !io:IoError
+ fn symlink(link: String, target: String, is_directory: bool) void !io:IoError
+ fn sync_all() void
+ fn truncate(path: String, length: uint) void !io:IoError
+ fn write(path: String, content: Slice[u8], append: bool (false)) void !io:IoError
```

## Classes for 'fs'

```js
+ class FileStream is Reader, Writer, Seeker, Closer {
    ~ closed: bool
    ~ path: String
    ~ position: uint

    + fn close() void !io:IoError
    + fn read(buf: Slice[u8]) uint !io:IoError
    + fn seek(offset: int, from: SeekFrom (io.SeekFrom.start)) uint !io:IoError
    + fn sync(data_only: bool (false)) void !io:IoError
    + fn write(data: Slice[u8]) uint !io:IoError
}
```

```js
+ class InMemoryFile {
    ~ data: Slice[u8]
    ~ filename: String
    ~ mime_type: String

    + static fn from_file(path: String) InMemoryFile !io:IoError
    + static fn new(data: Slice[u8]) InMemoryFile
    + fn reader() ByteReader
    + fn save(path: String) void !io:IoError
    + fn to_string() String
}
```

```js
+ struct OpenOptions {
    + append: bool
    + create: bool
    + exclusive: bool
    + permissions: u32
    + read: bool
    + write: bool
}
```

```js
+ mode Path for String {
    + fn add(part: String) Path
    + fn dir_of() Path
    + static fn new(path: String) Path
    + fn pop() Path
    + fn resolve() Path
}
```

# gc

## Aliases for 'gc'

```js
type EnvCloneFn (fnptr(ptr)(ptr))
type PropsFn (fnptr(ptr, *Lifo, fn(ptr, *Lifo)())())
```

## Functions for 'gc'

```js
+ fn alloc(size: uint) GcPtr
~+ fn alloc_typed(size: uint, props: ?fnptr(ptr, *Lifo, fn(ptr, *Lifo)())()) GcPtr
+ fn clone_closure_env(env: ?ptr) ?ptr
+ fn collect() void
+ fn collect_if_threshold_almost_reached() void
+ fn collect_if_threshold_reached() void
+ fn collect_shared() void
+ fn collect_shared_if_threshold_reached() void
+ fn lock() void
+ fn mem_usage() uint
+ fn reset_pause_durations() void
+ fn reset_shared_pause_durations() void
+ fn unlock() void
```

## Globals for 'gc'

```js
~+ global gc : *Gc
~+ shared mem_usage_peak : uint
~+ shared mem_usage_shared : uint
+ global pause_last_us : uint
+ global pause_max_us : uint
+ shared shared_pause_last_us : uint
+ shared shared_pause_max_us : uint
+ shared verify : bool
```

# html

## Functions for 'html'

```js
+ fn escape(code: String, options: ?EscapeOptions (null)) String
+ fn sanitize_url_attributes(code: String, allowed_schemes: Array[String] (.{ "http", "https", "mailto" })) String
+ fn url_is_allowed(target: String, allowed_schemes: Array[String] (.{ "http", "https", "mailto" })) bool
```

## Classes for 'html'

```js
+ class EscapeOptions {
    + escape_ampersand: bool
    + escape_double_quote: bool
    + escape_gt: bool
    + escape_lt: bool
    + escape_single_quote: bool
}
```

# http

## Functions for 'http'

```js
+ fn create_request(method: String, url: String, options: ?Options (null)) ClientRequest !HttpError
+ fn download(url: String, to_path: String, method: String ("GET"), options: ?Options (null)) void !HttpError
+ fn parse_http(input: ByteBuffer, context: Context, is_response: bool, max_header_size: uint (8192), max_body_size: uint (0)) void !HttpParseError
+ fn request(method: String, url: String, options: ?Options (null)) ClientResponse !HttpError
+ fn serve(host: String, port: u16, handler: shared fn(Request)(Response), worker_count: i32 (-1)) void !HttpError
+ fn serve_fast(host: String, port: u16, handler: shared fn(Context, ResponseWriter)(), worker_count: i32 (-1)) void !HttpError
```

## Classes for 'http'

```js
+ class ClientRequest {
    ~ bytes_received: uint
    ~ bytes_sent: uint
    ~ bytes_to_recv: uint
    ~ bytes_to_send: uint
    ~ con: Connection
    ~ recv_buffer: ByteBuffer
    ~ recv_percent: uint
    ~ request_sent: bool
    ~ response_received: bool
    ~ sent_percent: uint

    + static fn create(method: String, url: String, options: ?Options (null), deadline_ms: uint (0)) ClientRequest !HttpError
    + fn progress() bool !HttpError
    + fn response() ClientResponse !HttpError
}
```

```js
+ class ClientResponse {
    + body: String
    + headers: Headers
    + status: uint
}
```

```js
+ class Connection {
    ~+ fd: i32
    ~+ netcon: Connection
    ~+ worker: Worker

    + fn close() void
}
```

```js
+ class Context {
    ~+ method: Slice[u8]
    ~+ path: Slice[u8]
    ~+ query_string: Slice[u8]
    ~+ status: uint

    + get body: String
    + fn data() Map[String]
    + fn data_json() Value
    + fn files() Map[InMemoryFile]
    + fn headers() Headers
    + fn params() Map[String]
    + fn params_grouped() Map[Array[String]]
}
```

```js
+ class Headers {
    + fn append(name: String, value: String) Headers
    + fn clear() Headers
    + fn copy() Headers
    + fn get(name: String) String !LookupError
    + fn get_all(name: String) Array[String]
    + fn has(name: String) bool
    + get length: uint
    + static fn new() Headers
    + fn remove(name: String) Headers
    + fn set(name: String, value: String) Headers
}
```

```js
+ class Options {
    + alpn_protocols: ?Array[String]
    + body: String
    + ca_cert_path: ?String
    + certificate_sha256: ?String
    + connect_timeout_ms: uint
    + follow_redirects: bool
    + headers: ?Headers
    + max_redirects: uint
    + max_response_body_size: uint
    + max_response_header_size: uint
    + max_tls_version: ?TlsVersion
    + min_tls_version: TlsVersion
    + output: ?Writer
    + query_data: ?Map[String]
    + read_timeout_ms: uint
    + timeout_ms: uint
    + tls_cipher_list: ?String
    + tls_cipher_suites: ?String
    + verify_ssl_cert: bool
    + write_timeout_ms: uint

    + fn clear_headers() Options
    + fn get_headers() Headers
    + fn set_header(key: String, value: String) Options
    + fn set_headers(headers: Headers) Options
}
```

```js
+ class Request {
    + method: String
    + path: String
    + query_string: String

    + get body: String
    + fn data() Map[String]
    + fn data_json() Value
    + fn files() Map[InMemoryFile]
    + fn headers() Headers
    + fn params() Map[String]
    + fn params_grouped() Map[Array[String]]
}
```

```js
+ class Response {
    + body: String
    + content_type: String
    + status: u32

    + fn add_header(name: String, value: String) void
    + static fn empty(code: u32 (200), headers: ?Headers (null)) Response
    + static fn file(path: String, filename: ?String (null)) Response
    + get headers: Headers
    + static fn html(body: String, code: u32 (200), headers: ?Headers (null)) Response
    + static fn json(body: String, code: u32 (200), headers: ?Headers (null)) Response
    + static fn redirect(location: String, code: u32 (302), headers: ?Headers (null)) Response
    + fn set_header(name: String, value: String) void
    + static fn stream(reader: Reader, size: uint, content_type: String ("application/octet-stream"), filename: ?String (null)) Response
    + static fn text(body: String, code: u32 (200), content_type: String ("text/plain"), headers: ?Headers (null)) Response
}
```

```js
+ class ResponseWriter {
    ~ responded: bool

    + static fn code_name(code: uint) String
    + fn respond(code: uint, content_type: String, body: String, headers: ?Headers (null)) void
    + fn send_file(path: String, filename: ?String (null), headers: ?Headers (null)) void
    + fn send_status(status_code: uint) void
    + fn send_stream(reader: Reader, size: uint, content_type: String ("application/octet-stream"), filename: ?String (null), headers: ?Headers (null)) void
}
```

```js
+ class Route[T] {
    + handler: T

    + fn params(path: String) Map[String]
}
```

```js
+ class Router[T] {
    + fn add(method: String, url: String, handler: T) void
    + fn find(method: String, url: String) Route[T] !LookupError
    + static fn new() Router[T]
}
```

```js
+ class Server {
    + body_timeout_ms: uint
    + fast_handler: ?shared fn(Context, ResponseWriter)()
    + header_timeout_ms: uint
    ~ host: String
    + http2: bool
    + idle_timeout_ms: uint
    + max_connections: uint
    + max_request_body_size: uint
    + max_request_header_size: uint
    + max_server_wide_body_size: uint
    ~ port: u16
    + show_info: bool
    + write_timeout_ms: uint

    + fn add_static_dir(path: String) void !LookupError
    + fn fast(handler: shared fn(Context, ResponseWriter)()) Server
    + fn handle(handler: shared fn(Request)(Response)) Server
    + static fn new(host: String, port: u16, handler: shared fn(Request)(Response) (handler_default)) Server
    + fn request_shutdown(timeout_ms: uint (5000)) void
    + fn shutdown(timeout_ms: uint (5000)) bool
    + fn start(worker_count: i32 (-1)) void !HttpError
    + fn tls(certificate_file: String, private_key_file: String, min_version: TlsVersion (net.TlsVersion.tls_1_2), cipher_list: ?String (null), cipher_suites: ?String (null)) Server !HttpError
}
```

# io

## Aliases for 'io'

```js
alias Fd for i32
```

## Functions for 'io'

```js
+ fn await_fd(fd: i32, read: bool, write: bool, timeout_ms: uint (0)) PollEvent
+ fn await_socket_fd(fd: i32, read: bool, write: bool, timeout_ms: uint (0)) PollEvent
+ fn close(fd: i32) void !IoError
+ fn copy(reader: Reader, writer: Writer, chunk_size: uint (65536)) uint !IoError
+ fn print(msg: String) void
+ fn println(msg: String) void
+ fn read(fd: i32, buf: Slice[u8], offset: uint (0)) uint !IoError
+ fn read_all(reader: Reader, chunk_size: uint (65536)) ByteBuffer !IoError
+ fn read_sync(fd: i32, buf: Slice[u8], offset: uint (0)) uint !IoError
+ fn seek(fd: i32, offset: int, from: SeekFrom (SeekFrom.start)) uint !IoError
+ fn set_mode(fd: i32, mode: Mode) void !IoError
+ fn set_nonblocking(fd: i32, value: bool) void !IoError
+ fn stderr() StdStream
+ fn stdin() StdStream
+ fn stdout() StdStream
+ fn sync(fd: i32, data_only: bool (false)) void !IoError
+ fn write(fd: i32, data: Slice[u8]) uint !IoError
```

## Classes for 'io'

```js
+ interface Closer {
    + fn close() void !IoError
}
```

```js
+ interface Reader {
    + fn read(buf: Slice[u8]) uint !IoError
}
```

```js
+ interface Seeker {
    + fn seek(offset: int, from: SeekFrom) uint !IoError
}
```

```js
+ class StdStream is Reader, Writer {
    ~ can_read: bool
    ~ can_write: bool
    ~ fd: i32

    + fn read(buf: Slice[u8]) uint !IoError
    + fn write(data: Slice[u8]) uint !IoError
}
```

```js
+ interface Writer {
    + fn write(data: Slice[u8]) uint !IoError
}
```

# json

## Functions for 'json'

```js
+ fn decode(json: String | ByteBuffer, max_depth: uint (JSON_MAX_DEPTH), max_bytes: uint (JSON_MAX_BYTES), max_entries: uint (JSON_MAX_ENTRIES)) Value !ParseError
+ fn decode_to[T](json: String | ByteBuffer, max_depth: uint (JSON_MAX_DEPTH), max_bytes: uint (JSON_MAX_BYTES), max_entries: uint (JSON_MAX_ENTRIES)) T !DecodeError
+ fn default_value(kind: Kind) Value
+ fn encode(data: $T, pretty: bool (false)) String
+ fn encode_into(data: $T, output: ByteBuffer, pretty: bool (false)) ByteBuffer
+ fn from(data: $T) Value
+ fn new_array(values: ?Array[Value] (null)) ArrayValue
+ fn new_bool(value: bool) Value
+ fn new_float(value: float) Value
+ fn new_int(value: int) Value
+ fn new_null() Value
+ fn new_object(values: ?Map[Value] (null)) ObjectValue
+ fn new_string(value: String) Value
```

## Classes for 'json'

```js
+ class ArrayValue {
    + values: Array[Value]

    + fn append(value: Value) ArrayValue
    + fn get(index: uint) Value !LookupError
    + get length: uint
    + fn prepend(value: Value) ArrayValue
    + fn remove(index: uint) ArrayValue
}
```

```js
+ class ObjectValue {
    + values: Map[Value]

    + fn get(key: String) Value !LookupError
    + fn has(key: String) bool
    + get length: uint
    + fn remove(key: String) ObjectValue
    + fn set(key: String, value: Value) ObjectValue
}
```

```js
+ union Value : String | bool | float | int | ArrayValue | ObjectValue | null {
    + fn append(value: Value) Value
    + fn append_bool(value: bool) Value
    + fn append_float(value: float) Value
    + fn append_int(value: int) Value
    + fn append_null() Value
    + fn append_string(value: String) Value
    + get array: ArrayValue
    + fn array_value() ArrayValue !LookupError
    + get bool: bool
    + fn bool_value() bool !LookupError
    + fn encode(pretty: bool (false)) String
    + fn encode_into(output: ByteBuffer, pretty: bool (false)) ByteBuffer
    + get float: float
    + fn float_value() float !LookupError
    + fn get(key: String | uint) Value
    + fn get_array(key: String | uint) ArrayValue !LookupError
    + fn get_bool(key: String | uint) bool !LookupError
    + fn get_float(key: String | uint) float !LookupError
    + fn get_int(key: String | uint) int !LookupError
    + fn get_object(key: String | uint) ObjectValue !LookupError
    + fn get_required(key: String | uint) Value !LookupError
    + fn get_string(key: String | uint) String !LookupError
    + fn has(key: String | uint) bool
    + fn has_array(key: String | uint) bool
    + fn has_bool(key: String | uint) bool
    + fn has_float(key: String | uint) bool
    + fn has_int(key: String | uint) bool
    + fn has_object(key: String | uint) bool
    + fn has_string(key: String | uint) bool
    + get int: int
    + fn int_value() int !LookupError
    + get is_array: bool
    + get is_bool: bool
    + get is_float: bool
    + get is_int: bool
    + fn is_kind(kind: Kind) bool
    + get is_null: bool
    + get is_number: bool
    + get is_object: bool
    + get is_string: bool
    + get kind: Kind
    + fn kind_name() String
    + get length: uint
    + get object: ObjectValue
    + fn object_value() ObjectValue !LookupError
    + fn prepend(value: Value) Value
    + fn remove(key: String | uint) Value
    + fn set(key: String | uint, value: Value) Value
    + fn set_bool(key: String | uint, value: bool) Value
    + fn set_float(key: String | uint, value: float) Value
    + fn set_int(key: String | uint, value: int) Value
    + fn set_null(key: String | uint) Value
    + fn set_string(key: String | uint, value: String) Value
    + get string: String
    + fn string_value() String !LookupError
    + fn to_type[T]() T !LookupError
}
```

# markdown

## Functions for 'markdown'

```js
+ fn to_html(md: String, options: ?ToHtmlOptions (null)) String
```

## Classes for 'markdown'

```js
+ class ToHtmlOptions {
    + allowed_schemes: Array[String]
    + code_class: ?String
    + paragraph_class: ?String
}
```

# math

## Functions for 'math'

```js
+ fn abs(value: float) float
+ fn acos(value: float) float
+ fn asin(value: float) float
+ fn atan(value: float) float
+ fn atan2(y: float, x: float) float
+ fn cbrt(value: float) float
+ fn ceil(value: float) float
+ fn cos(value: float) float
+ fn exp(value: float) float
+ fn exp2(value: float) float
+ fn floor(value: float) float
+ fn hypot(x: float, y: float) float
+ fn log(value: float) float
+ fn log10(value: float) float
+ fn log2(value: float) float
+ fn mod(value: float, divisor: float) float
+ fn pow(base: float, exponent: float) float
+ fn round(value: float) float
+ fn sin(value: float) float
+ fn sqrt(value: float) float
+ fn tan(value: float) float
+ fn trunc(value: float) float
```

# mem

## Functions for 'mem'

```js
+ fn alloc(size: uint) ptr
+ fn alloc_ob(size: uint) ptr
+ fn ascii_bytes_equal_ignore_case(a: ptr, b: ptr, len: uint) bool
+ fn ascii_bytes_to_lower(adr: ptr, len: uint) void
+ fn ascii_equal_ignore_case(a: Slice[u8], b: Slice[u8]) bool
+ fn ascii_to_lower(view: Slice[u8]) void
+ fn bytes_to_uint(adr: ptr, len: uint, allow_plus: bool (false)) uint !SyntaxError
+ fn calloc(size: uint) ptr
+ fn clear(view: Slice[u8]) void
+ fn clear_bytes(adr: ptr, length: uint) void
+ fn clear_value[T](value: *T) void
+ fn copy(from: Slice[u8], to: Slice[u8]) uint
+ fn copy_bytes(from: ptr, to: ptr, length: uint) void
+ fn copy_value[T](from: *T, to: *T) void
+ fn equal(a: Slice[u8], b: Slice[u8]) bool
+ fn equal_bytes(a: ptr, b: ptr, length: uint) bool
+ fn find_char(view: Slice[u8], ch: u8) uint !LookupError
+ fn find_char_bytes(adr: ptr, ch: u8, length: uint) uint !LookupError
+ fn free(value: $T) void
+ fn move(from: Slice[u8], to: Slice[u8]) uint
+ fn move_bytes(from: ptr, to: ptr, length: uint) void
+ fn move_value[T](from: *T, to: *T) void
+ fn new[T](initial: T (T.$default_value)) *T
+ fn resize(adr: ptr, size: uint, new_size: uint) ptr
+ fn to_uint(view: Slice[u8], allow_plus: bool (false)) uint !SyntaxError
```

# net

## Functions for 'net'

```js
+ fn recv(fd: i32, buf: Slice[u8], timeout_ms: uint (5000)) uint !io:IoError
+ fn write(fd: i32, data: Slice[u8], timeout_ms: uint (5000)) uint !io:IoError
```

## Classes for 'net'

```js
+ class AddrInfo {
    ~ data: *libc_gen_addrinfo

    + fn addr_len() u32
    + static fn new(host: String, port: u16, timeout_ms: uint (5000)) AddrInfo !NetError
    + fn sock_addr() *libc_gen_sockaddr
}
```

```js
+ class Connection is Reader, Writer, Closer {
    ~ fd: i32
    ~+ host: String
    + read_timeout_ms: uint
    ~ ssl: ?Ssl
    ~ ssl_enabled: bool
    + write_timeout_ms: uint

    + fn close() void !io:IoError
    + static fn new(fd: i32) Connection !NetError
    + fn read(buf: Slice[u8]) uint !io:IoError
    + fn set_timeouts(read_timeout_ms: uint, write_timeout_ms: uint) Connection
    + fn ssl_accept(context: shared SslServerContext, timeout_ms: uint (5000)) void !NetError
    + fn ssl_connect(ssl: Ssl, timeout_ms: uint (5000)) void !NetError
    + fn write(data: Slice[u8]) uint !io:IoError
}
```

```js
+ class Socket is Closer {
    ~ fd: i32
    ~ host: String
    ~ port: u16

    + static fn client(type: SocketType, host: String, port: u16, timeout_ms: uint (5000)) Connection !NetError
    + fn close() void !io:IoError
    + static fn server(type: SocketType, host: String, port: u16, timeout_ms: uint (5000)) shared SocketServer !NetError
}
```

```js
+ class SocketServer is Closer {
    ~+ socket: Socket

    + fn accept(timeout_ms: uint (0)) Connection !NetError
    + fn close() void !io:IoError
}
```

```js
+ class Ssl {
    ~ cert_dir: ?String
    ~ cert_file: ?String
    ~ connected: bool
    ~ ctx: SSL_CTX
    ~ error_code: uint
    ~ fd: i32
    ~ ssl: OSSL

    + fn accept(fd: i32, timeout_ms: uint (5000)) void !NetError
    + fn close(timeout_ms: uint (5000)) void !NetError
    + fn connect(fd: i32, timeout_ms: uint (5000)) void !NetError
    + fn custom_error(msg: String) void !NetError
    + static fn default_ca_cert_paths() Array[String]
    + fn get_error() uint
    + fn get_error_message() String
    + static fn new() Ssl
    + fn peer_certificate_sha256() String !NetError
    + fn recv(buf: Slice[u8], timeout_ms: uint (5000)) uint !NetError
    + fn selected_alpn() String
    + fn set_alpn(protocols: Array[String]) void !NetError
    + fn set_ca_cert(path: ?String) void !NetError
    + fn set_ca_cert_dir(dir: ?String) void !NetError
    + fn set_cipher_list(ciphers: String) void !NetError
    + fn set_cipher_suites(ciphers: String) void !NetError
    + fn set_host(host: String) void !NetError
    + fn set_max_version(version: TlsVersion) void !NetError
    + fn set_min_version(version: TlsVersion) void !NetError
    + fn set_verify(enable: bool) void
    + fn write(data: Slice[u8], timeout_ms: uint (5000)) uint !NetError
}
```

```js
+ class SslServerContext {
    ~ ctx: SSL_CTX

    + static fn connection(context: shared SslServerContext) Ssl
    + static fn new(certificate_file: String, private_key_file: String, min_version: TlsVersion (TlsVersion.tls_1_2), cipher_list: ?String (null), cipher_suites: ?String (null)) SslServerContext !NetError
}
```

# template

## Functions for 'template'

```js
+ fn render(name: String, data: $T, options: ?RenderOptions (null)) String !ParseError
+ fn render_content(content: String, data: $T, options: ?RenderOptions (null)) String !ParseError
+ fn set_content(name: String, content: String) void
+ fn set_content_many(content: Map[String]) void
```

## Classes for 'template'

```js
+ class RenderOptions {
    + escape: ?fn(String)(String)
    + max_depth: uint
}
```

# thread

## Functions for 'thread'

```js
+ fn start(func: shared fn()()) Thread[void] !InitError
+ fn suspend_ms(ms: uint) void
+ fn suspend_ns(ns: uint) void
+ fn task(handler: fn()()) Task !InitError
```

## Classes for 'thread'

```js
+ class Task {
    + fn await() void
}
```

```js
+ class Thread[T] {
    + fn await() T
    + static fn start(func: shared fn()(T)) Thread[T] !InitError
}
```

```js
+ class ThreadGroup[T] {
    + fn await_next() (uint, T)
    + fn has_pending() bool
    + static fn new() ThreadGroup[T]
    + fn start(handler: shared fn()(T)) uint !InitError
}
```

```js
+ class ThreadSuspendGate {
    + static fn new() ThreadSuspendGate
    + fn signal() void
    + fn wait(should_wait: fn()(bool), timeout_ms: uint (0)) bool
}
```

# time

## Functions for 'time'

```js
+ fn mono_ms() uint
+ fn mono_ns() uint
+ fn mono_us() uint
+ fn sleep_ms(ms: uint) void
+ fn sleep_ns(ns: uint) void
+ fn unix_ms() uint
+ fn unix_ns() uint
+ fn unix_us() uint
```

## Classes for 'time'

```js
+ class DateTime {
    + fn add_days(amount: int) DateTime
    + fn add_hours(amount: int) DateTime
    + fn add_microseconds(amount: int) DateTime
    + fn add_minutes(amount: int) DateTime
    + fn add_months(amount: int) DateTime
    + fn add_seconds(amount: int) DateTime
    + fn add_years(amount: int) DateTime
    + fn copy() DateTime
    + fn day() uint
    + fn day_of_week() uint
    + fn day_of_year() uint
    + fn format(pattern: String) String
    + static fn from_format(pattern: String, value: String) DateTime !SyntaxError
    + static fn from_unix_seconds(timestamp: int) DateTime
    + static fn from_unix_us(timestamp: int) DateTime
    + fn hash() uint
    + fn hour() uint
    + fn is_leap_year() bool
    + fn microsecond() uint
    + fn minute() uint
    + fn modify_add_days(amount: int) DateTime
    + fn modify_add_hours(amount: int) DateTime
    + fn modify_add_microseconds(amount: int) DateTime
    + fn modify_add_minutes(amount: int) DateTime
    + fn modify_add_months(amount: int) DateTime
    + fn modify_add_seconds(amount: int) DateTime
    + fn modify_add_years(amount: int) DateTime
    + fn modify_day(day: uint) DateTime
    + fn modify_hour(hour: uint) DateTime
    + fn modify_microsecond(microsecond: uint) DateTime
    + fn modify_minute(minute: uint) DateTime
    + fn modify_month(month: uint) DateTime
    + fn modify_second(second: uint) DateTime
    + fn modify_year(year: int) DateTime
    + fn month() uint
    + static fn new(year: ?int (null), month: ?uint (null), day: ?uint (null), hour: ?uint (null), minute: ?uint (null), second: ?uint (null), microsecond: ?uint (null)) DateTime
    + static fn now() DateTime
    + fn second() uint
    + fn to_iso8601() String
    + fn to_string() String
    + fn unix_seconds() int
    + fn unix_us() int
    + fn with_day(day: uint) DateTime
    + fn with_hour(hour: uint) DateTime
    + fn with_microsecond(microsecond: uint) DateTime
    + fn with_minute(minute: uint) DateTime
    + fn with_month(month: uint) DateTime
    + fn with_second(second: uint) DateTime
    + fn with_year(year: int) DateTime
    + fn year() int
}
```

# url

## Functions for 'url'

```js
+ fn decode(str: String) String
+ fn encode(str: String, component: Component (Component.unreserved)) String
+ fn parse(str: String) Url
```

## Classes for 'url'

```js
+ class Url {
    + fragment: String
    + host: String
    + path: String
    + query: String
    + scheme: String
}
```

# validate

## Functions for 'validate'

```js
+ fn email(email: String) bool
```

## Classes for 'validate'

```js
+ class Field {
    + static fn array(of: ?Field) Field
    + static fn bool() Field
    + fn custom(func: fn(Value)(bool), error: String) Field
    + fn default(val: $T) Field
    + fn email() Field
    + fn equals_string(str: ?String) Field
    + static fn float() Field
    + fn fmax(val: float) Field
    + fn fmin(val: float) Field
    + fn get_form_rules() Value
    + static fn int() Field
    + fn is_syntax(mask: String, mask_is_exclude: bool (false)) Field
    + fn lower(val: bool (true)) Field
    + fn max(val: int) Field
    + fn min(val: int) Field
    + fn nullable(value: bool (true)) Field
    + static fn object(fields: ?Map[Field]) Field
    + fn optional(value: bool (true)) Field
    + static fn string() Field
    + static fn translate_errors(errors: Map[String], translations: Map[String] (default_translations)) void
    + fn try_cast(data: Value) Value
    + fn upper(val: bool (true)) Field
    + fn username(numbers: bool, underscore: bool) Field
    + fn utf8_max(val: int) Field
    + fn utf8_min(val: int) Field
    + fn validate(data: Value, errors: ?Map[String] (null), field_name: ?String (null)) bool
    + fn validate_and_translate(data: Value, errors: Map[String], translations: Map[String] (default_translations)) bool
}
```

## Globals for 'validate'

```js
+ global default_translations : Map[String]
```
