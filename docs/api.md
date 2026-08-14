
# Documentation

Namespaces: [ansi](#ansi) | [core](#core) | [coro](#coro) | [crypto](#crypto) | [ext](#ext) | [fs](#fs) | [gc](#gc) | [html](#html) | [http](#http) | [io](#io) | [json](#json) | [markdown](#markdown) | [mem](#mem) | [net](#net) | [template](#template) | [thread](#thread) | [time](#time) | [url](#url) | [validate](#validate)

---

# ansi

## Functions for 'ansi'

```js
+ fn supported() bool
```

# core

## Functions for 'core'

```js
+ fn clone_value(value: any) any
+ fn exec(cmd: String, print_output: bool (false)) (i32, String)
+ fn exit(code: i32) void
+ fn getenv(var: String) String !LookupError
+ fn panic(msg: String) void
+ fn race_lock() void
+ fn race_unlock() void
+ fn raise(code: i32) void
+ fn read_big_endian(from: @[u8], bytes: uint) uint
+ fn read_little_endian(from: @[u8], bytes: uint) uint
+ fn signal_ignore(sig: int) void
+ fn write_big_endian(to: @[u8], v: uint, bytes: uint) void
+ fn write_little_endian(to: @[u8], v: uint, bytes: uint) void
```

## Classes for 'core'

```js
+ array Array[T] {
}
```

```js
+ class ByteBuffer {
    ~ data: GcPtr
    ~ length: uint
    ~ size: uint

    + fn clear() void
    + fn clear_next_bytes(amount: uint) void
    + fn clear_part(index: uint, len: uint) void
    + fn clear_until(index: uint) void
    + fn clone() ByteBuffer
    + fn equals_str(str: String) bool
    + fn fill(with: u8, amount: uint) void
    + fn get(index: uint) u8
    + fn index_of(byte: u8, start_index: uint (0)) uint !LookupError
    + fn index_where_byte_is_not(byte: u8, start_index: uint (0)) uint !LookupError
    + fn ltrim(filter: fnptr(u8)(bool)) void
    + fn minimum_size(minimum_size: uint) void
    + static fn new(start_size: uint (128)) ByteBuffer
    + fn part(start_index: uint, length: uint) String
    + fn reader() ByteReader
    + fn reduce_size(size: uint) void
    + fn ref(offset: uint, length: uint) ByteBufferRef
    + fn reserve_space(length: uint) void
    + fn resize(length: uint) void
    + fn rtrim(filter: fnptr(u8)(bool)) void
    + fn set(index: uint, v: u8) void
    + fn skip(amount: uint) void
    + fn starts_with(str: String, offset: uint) bool
    + fn to_string() String
    + fn trim(filter: fnptr(u8)(bool)) void
    + fn truncate(length: uint) void
    + fn write_big_endian(value: uint, bytes: uint) void
    + fn write_buffer(buf: ByteBuffer, offset: uint (0)) void
    + fn write_buffer_part(buf: ByteBuffer, len: uint, offset: uint (0)) void
    + fn write_byte(v: u8) void
    + fn write_cstring(str: cstring, include_zero_byte: bool) void
    + fn write_f64_ascii(v: f64, decimals: uint (2), trim_zeros: bool (false)) void
    + fn write_f64_be(v: f64) void
    + fn write_f64_le(v: f64) void
    + fn write_from_ptr(data: ptr, length: uint) void
    + fn write_int_ascii(v: int, base: u8 (10)) void
    + fn write_little_endian(value: uint, bytes: uint) void
    + fn write_string(str: String) void
    + fn write_u16_be(v: u16) void
    + fn write_u16_le(v: u16) void
    + fn write_u32_be(v: u32) void
    + fn write_u32_le(v: u32) void
    + fn write_u64_be(v: u64) void
    + fn write_u64_le(v: u64) void
    + fn write_u64_str(v: u64) void
    + fn write_uint_ascii(v: uint, base: u8 (10)) void
}
```

```js
+ class ByteBufferRef {
    + fn clear() void
    + fn data() ptr
    + fn equals(cmp: String) bool
    + static fn new(buffer: ByteBuffer, offset: uint, length: uint) ByteBufferRef
    + fn to_str() String
}
```

```js
+ class ByteReader {
    + buf: ByteBuffer
    + pos: uint

    + fn back(amount: uint) void
    + fn get_pos() uint
    + static fn new(buf: ByteBuffer) ByteReader
    + fn read_big_endian(bytes: uint) uint
    + fn read_byte() u8
    + fn read_cstring() String
    + fn read_float() float
    + fn read_hex_int() uint
    + fn read_hex_uint() uint
    + fn read_int() int
    + fn read_little_endian(bytes: uint) uint
    + fn read_octal_int() uint
    + fn read_octal_uint() uint
    + fn read_string(len: uint) String
    + fn read_string_all() String
    + fn read_u16_be() u16
    + fn read_u16_le() u16
    + fn read_u32_be() u32
    + fn read_u32_le() u32
    + fn read_u64_be() u64
    + fn read_u64_le() u64
    + fn read_uint() uint
    + fn read_uint_be() uint
    + fn read_uint_le() uint
    + fn reset() void
    + fn set_pos(index: uint) void
    + fn skip(amount: uint) void
}
```

```js
+ class FlatMap[K, T] {
}
```

```js
+ class HashMap[K, T] {
}
```

```js
+ mode Map[T] {
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

    + fn add(item: any) void
    + fn get() any !LookupError
    + static fn new(start_size: uint (2)) Pool[any]
}
```

```js
+ class Process {
    + fn did_exit() bool
    + static fn run(exe: String, args: ?Array[String], print_output: bool (false)) Process !ExternError
    + fn stop() void
}
```

```js
+ slice Slice[T] of any {
    ~ data: *any
    ~ length: uint

    + fn append() void
    + fn get() void
    + fn set() void
    + fn set_all() void
}
```

```js
+ slice String of u8 {
    ~ data: *u8
    ~ length: uint

    + fn bytes() uint
    + fn clone() String
    + fn contains(part: String, start_index: uint (0)) bool
    + fn contains_byte(byte: u8, start_index: uint (0)) bool
    + fn data_cstring() cstring
    + fn ends_with(part: String) bool
    + fn escape() String
    + fn get(index: uint) u8
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
    + static fn make_empty(length: uint) String
    + static fn make_from_ptr(data: ptr, length: uint) String
    + fn octal_to_int() int !SyntaxError
    + fn octal_to_uint() uint !SyntaxError
    + fn pad_left(char: u8, length: uint) String
    + fn pad_right(char: u8, length: uint) String
    + fn part(start_index: uint, length: uint) String
    + static fn random(len: uint, characters: String ("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")) String
    + fn range(start: uint, end: uint, inclusive: bool (true)) String
    + fn replace(part: String, with: String) String
    + fn rtrim(part: String, limit: uint (0)) String
    + fn split(on: String) Array[String]
    + fn starts_with(part: String) bool
    + fn to_float() f64 !SyntaxError
    + fn to_int() int !SyntaxError
    + fn to_uint() uint !SyntaxError
    + fn trim(part: String, limit: uint (0)) String
    + fn unescape() String
    + fn upper() String
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
+ class cstring {
    + fn get(index: uint) u8
    + fn index_of(find: u8) uint !LookupError
    + fn length() uint
    + fn to_string() String
}
```

```js
+ class f32 {
    + fn to_str(decimals: uint (2), trim_zeros: bool (false)) String
    + fn to_string_in_ptr(buf: ptr, decimals: uint (2), trim_zeros: bool (false)) uint
}
```

```js
+ class f64 {
    + fn to_str(decimals: uint (2), trim_zeros: bool (false)) String
    + fn to_string_in_ptr(buf: ptr, decimals: uint (2), trim_zeros: bool (false)) uint
}
```

```js
+ class float {
    + fn to_str(decimals: uint (2), trim_zeros: bool (false)) String
    + fn to_string_in_ptr(buf: ptr, decimals: uint (2), trim_zeros: bool (false)) uint
}
```

```js
+ class i16 {
    + fn character_length(base: i16) uint
    + fn equals_str(str: String) bool
    + fn print(base: i16) void
    + static fn random() i16
    + static fn read_big_endian(from: @[u8 x 2]) i16
    + static fn read_little_endian(from: @[u8 x 2]) i16
    + fn round_down(modulo: i16) i16
    + fn round_up(modulo: i16) i16
    + fn to_base(base: i16) String
    + fn to_base_to_ptr(base: i16, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_str() String
    + static fn write_big_endian(v: i16, to: @[u8 x 2]) void
    + static fn write_little_endian(v: i16, to: @[u8 x 2]) void
}
```

```js
+ class i32 {
    + fn character_length(base: i32) uint
    + fn equals_str(str: String) bool
    + fn print(base: i32) void
    + static fn random() i32
    + static fn read_big_endian(from: @[u8 x 4]) i32
    + static fn read_little_endian(from: @[u8 x 4]) i32
    + fn round_down(modulo: i32) i32
    + fn round_up(modulo: i32) i32
    + fn to_base(base: i32) String
    + fn to_base_to_ptr(base: i32, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_str() String
    + static fn write_big_endian(v: i32, to: @[u8 x 4]) void
    + static fn write_little_endian(v: i32, to: @[u8 x 4]) void
}
```

```js
+ class i64 {
    + fn character_length(base: i64) uint
    + fn equals_str(str: String) bool
    + fn print(base: i64) void
    + static fn random() i64
    + static fn read_big_endian(from: @[u8 x 8]) i64
    + static fn read_little_endian(from: @[u8 x 8]) i64
    + fn round_down(modulo: i64) i64
    + fn round_up(modulo: i64) i64
    + fn to_base(base: i64) String
    + fn to_base_to_ptr(base: i64, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_str() String
    + static fn write_big_endian(v: i64, to: @[u8 x 8]) void
    + static fn write_little_endian(v: i64, to: @[u8 x 8]) void
}
```

```js
+ class i8 {
    + fn character_length(base: i8) uint
    + fn equals_str(str: String) bool
    + fn print(base: i8) void
    + static fn random() i8
    + static fn read_big_endian(from: @[u8 x 1]) i8
    + static fn read_little_endian(from: @[u8 x 1]) i8
    + fn round_down(modulo: i8) i8
    + fn round_up(modulo: i8) i8
    + fn to_base(base: i8) String
    + fn to_base_to_ptr(base: i8, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_str() String
    + static fn write_big_endian(v: i8, to: @[u8 x 1]) void
    + static fn write_little_endian(v: i8, to: @[u8 x 1]) void
}
```

```js
+ class int {
    + fn character_length(base: int) uint
    + fn equals_str(str: String) bool
    + fn print(base: int) void
    + static fn random() int
    + static fn read_big_endian(from: @[u8 x 8]) int
    + static fn read_little_endian(from: @[u8 x 8]) int
    + fn round_down(modulo: int) int
    + fn round_up(modulo: int) int
    + fn to_base(base: int) String
    + fn to_base_to_ptr(base: int, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_str() String
    + static fn write_big_endian(v: int, to: @[u8 x 8]) void
    + static fn write_little_endian(v: int, to: @[u8 x 8]) void
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
    + fn write_big_endian(value: uint, bytes: uint) void
    + fn write_buffer(buf: ByteBuffer, len: uint, offset: uint (0)) void
    + fn write_buffer_all(buf: ByteBuffer, offset: uint (0)) void
    + fn write_cstring(str: cstring, include_zero_byte: bool) void
    + fn write_from_ptr(from: ptr, len: uint) void
    + fn write_int_ascii(v: int, base: u8 (10), lowercase: bool (false)) uint
    + fn write_little_endian(value: uint, bytes: uint) void
    + fn write_string(str: String) void
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
    + fn character_length(base: u16) uint
    + fn equals_str(str: String) bool
    + fn print(base: u16) void
    + static fn random() u16
    + static fn read_big_endian(from: @[u8 x 2]) u16
    + static fn read_little_endian(from: @[u8 x 2]) u16
    + fn round_down(modulo: u16) u16
    + fn round_up(modulo: u16) u16
    + fn to_base(base: u16) String
    + fn to_base_to_ptr(base: u16, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_str() String
    + static fn write_big_endian(v: u16, to: @[u8 x 2]) void
    + static fn write_little_endian(v: u16, to: @[u8 x 2]) void
}
```

```js
+ class u32 {
    + fn character_length(base: u32) uint
    + fn equals_str(str: String) bool
    + fn print(base: u32) void
    + static fn random() u32
    + static fn read_big_endian(from: @[u8 x 4]) u32
    + static fn read_little_endian(from: @[u8 x 4]) u32
    + fn round_down(modulo: u32) u32
    + fn round_up(modulo: u32) u32
    + fn to_base(base: u32) String
    + fn to_base_to_ptr(base: u32, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_str() String
    + static fn write_big_endian(v: u32, to: @[u8 x 4]) void
    + static fn write_little_endian(v: u32, to: @[u8 x 4]) void
}
```

```js
+ class u64 {
    + fn character_length(base: u64) uint
    + fn equals_str(str: String) bool
    + fn print(base: u64) void
    + static fn random() u64
    + static fn read_big_endian(from: @[u8 x 8]) u64
    + static fn read_little_endian(from: @[u8 x 8]) u64
    + fn round_down(modulo: u64) u64
    + fn round_up(modulo: u64) u64
    + fn to_base(base: u64) String
    + fn to_base_to_ptr(base: u64, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_str() String
    + static fn write_big_endian(v: u64, to: @[u8 x 8]) void
    + static fn write_little_endian(v: u64, to: @[u8 x 8]) void
}
```

```js
+ class u8 {
    + fn character_length(base: u8) uint
    + fn equals_str(str: String) bool
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
    + fn print(base: u8) void
    + static fn random() u8
    + static fn read_big_endian(from: @[u8 x 1]) u8
    + static fn read_little_endian(from: @[u8 x 1]) u8
    + fn round_down(modulo: u8) u8
    + fn round_up(modulo: u8) u8
    + fn to_ascii_string() String
    + fn to_base(base: u8) String
    + fn to_base_to_ptr(base: u8, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_str() String
    + fn unescape() u8
    + static fn write_big_endian(v: u8, to: @[u8 x 1]) void
    + static fn write_little_endian(v: u8, to: @[u8 x 1]) void
}
```

```js
+ class uint {
    + fn character_length(base: uint) uint
    + fn equals_str(str: String) bool
    + fn print(base: uint) void
    + static fn random() uint
    + static fn read_big_endian(from: @[u8 x 8]) uint
    + static fn read_little_endian(from: @[u8 x 8]) uint
    + fn round_down(modulo: uint) uint
    + fn round_up(modulo: uint) uint
    + fn to_base(base: uint) String
    + fn to_base_to_ptr(base: uint, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_str() String
    + static fn write_big_endian(v: uint, to: @[u8 x 8]) void
    + static fn write_little_endian(v: uint, to: @[u8 x 8]) void
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
+ fn bcrypt(cost: uint, salt: String, password: String, output: ByteBuffer) void
+ fn bcrypt_hash(password: String, cost: uint (12)) String
+ fn bcrypt_verify(password: String, hash: String) bool
+ fn blowfish_encrypt_block(context: BlowfishContext, input: @[u8], output: @[u8]) void
+ fn blowfish_expand_key(context: BlowfishContext, salt: ?ByteBuffer, key: ByteBuffer) void !CryptoError
+ fn blowfish_init_state(context: BlowfishContext) void
+ fn blowfish_xor_block(data: &[u8], salt: ByteBuffer, saltIndex: &[uint]) void
+ fn sha1_encode(str: String) String
+ fn sha256_encode(str: String) String
```

## Classes for 'crypto'

```js
+ class Blake2b {
    + fn finalize(out: @[u8]) void
    + static fn hash_str(input: String, key: ?String (null), lowercase: bool (true)) String !CryptoError
    + static fn new(hash_size: uint, key: ?String (null)) Blake2b !CryptoError
    + fn update(data: @[u8], length: uint) void
}
```

```js
+ class BlowfishContext {
}
```

```js
+ class Sha1 {
    + fn add_hash_data(data: &[u8 x 20]) void
    + fn add_raw_data_unsafe(data: @[u8], len: uint) void
    + fn add_string_data(str: String) void
    + fn final() [u8 x 20]
    + fn reset() void
}
```

```js
+ class Sha256 {
    + fn add_hash_data(data: &[u8 x 32]) void
    + fn add_raw_data_unsafe(data: @[u8], len: uint) void
    + fn add_string_data(str: String) void
    + fn final() [u8 x 32]
    + fn reset() void
}
```

## Globals for 'crypto'

```js
+ global IV : [u64 x 8]
+ global SIGMA : [[u8 x 16] x 12]
+ global parray : [u32 x 18]
+ global sbox1 : [u32 x 256]
+ global sbox2 : [u32 x 256]
+ global sbox3 : [u32 x 256]
+ global sbox4 : [u32 x 256]
```

# ext

## Aliases for 'ext'

```js
alias DIR for ptr
alias FILE for ptr
type libc_addrinfo (libc_gen_addrinfo)
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

# fs

## Functions for 'fs'

```js
+ fn add(dir: String, fn: String) String
+ fn basename(path: String) String
+ fn chdir(path: String) void
+ fn copy(from_path: String, to_path: String, recursive: bool (false)) void !io:IoError
+ fn cwd() String
+ fn delete(path: String) void !io:IoError
+ fn delete_recursive(path: String) void
+ fn dir_of(path: String) String
+ fn exe_dir() String
+ fn exe_path() String
+ fn exists(path: String) bool
+ fn ext(path: String, with_dot: bool (false)) String
+ fn files_in(dir: String, recursive: bool (false), files: bool (true), dirs: bool (true), prefix: ?String (null), result: Array[String] (.{})) Array[String]
+ fn home_dir() String !ExternError
+ fn is_dir(path: String) bool
+ fn is_file(path: String) bool
+ fn mime(ext_without_dot: String) String
+ fn mkdir(path: String, permissions: u32 (0c755)) void !io:IoError
+ fn modified_time(path: String) uint !io:IoError
+ fn move(from_path: String, to_path: String) void !io:IoError
+ fn open(path: String, writable: bool, append_on_write: bool) i32 !io:IoError
+ fn open_extend(path: String, writable: bool, append_on_write: bool, create_file_if_doesnt_exist: bool (false), create_file_permissions: u32 (0c644)) i32 !io:IoError
+ fn path(path: String) Path
+ fn read(path: String) String !io:IoError
+ fn realpath(path: String) String
+ fn resolve(path: String) String
+ fn rmdir(path: String) void !io:IoError
+ fn size(path: String) uint
+ fn stream(path: String, read: bool, write: bool, append: bool (false), auto_create: bool (false)) FileStream !io:IoError
+ fn symlink(link: String, target: String, is_directory: bool) void !io:IoError
+ fn sync() void
+ fn write(path: String, content: String, append: bool (false)) void !io:IoError
+ fn write_from_ptr(path: String, data: ptr, size: uint, append: bool (false)) void !io:IoError
```

## Classes for 'fs'

```js
+ class FileStream {
    ~ path: String
    + read_offset: uint
    ~ reading: bool

    + fn close() void
    + fn read(bytes: uint (10240), buffer: ByteBuffer) bool !io:IoError
    + fn write(str: String) void !io:IoError
    + fn write_buffer(buffer: ByteBuffer) void !io:IoError
    + fn write_from_ptr(from: ptr, len: uint) void !io:IoError
}
```

```js
+ class InMemoryFile {
    ~ data: ptr
    ~ filename: String
    ~ mime_type: String
    ~ size: uint

    + static fn create_from_buffer(buffer: ByteBuffer) InMemoryFile
    + static fn create_from_file(path: String) InMemoryFile !io:IoError
    + static fn create_from_ptr(data: ptr, size: uint) InMemoryFile
    + fn read_all() String
    + fn save(path: String) void
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

## Functions for 'gc'

```js
+ fn alloc(size: uint) GcPtr
~+ fn alloc_typed(size: uint, props: ?fnptr(ptr, Lifo)()) GcPtr
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
~+ global gc : Gc
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
+ fn sanitize(code: String, options: ?SanitizeOptions (null)) String
+ fn sanitize_filter(code: String) String
```

## Classes for 'html'

```js
+ class SanitizeOptions {
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
+ fn parse_http(input: ByteBuffer, context: Context, is_response: bool) void !HttpParseError
+ fn request(method: String, url: String, options: ?Options (null)) ClientResponse !HttpError
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

    + static fn create(method: String, url: String, options: ?Options (null)) ClientRequest !HttpError
    + fn progress() bool !HttpError
    + fn response() ClientResponse !HttpError
}
```

```js
+ class ClientResponse {
    + body: String
    + headers: Map[String]
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
    ~+ body_received: uint
    ~+ chunked: bool
    ~+ content_length: uint
    ~+ has_host: bool
    ~+ method: ByteBufferRef
    ~+ parsed_index: uint
    ~+ path: ByteBufferRef
    ~+ query_string: ByteBufferRef
    ~+ status: uint

    + fn body() String
    + fn data() Map[String]
    + fn data_json() Value
    + fn files() Map[InMemoryFile]
    + fn headers() Map[String]
    + fn params() Map[String]
    + fn params_grouped() Map[Array[String]]
}
```

```js
+ class Options {
    + body: String
    + ca_cert: ?String
    + follow_redirects: bool
    + headers: ?Map[String]
    + output_to_file: ?String
    + query_data: ?Map[String]
    + verify_ssl_cert: bool

    + fn clear_headers() Options
    + fn get_headers() Map[String]
    + fn set_header(key: String, value: String) Options
    + fn set_headers(headers: Map[String]) Options
}
```

```js
+ class Request {
    + method: String
    + path: String
    + query_string: String

    + fn body() String
    + fn data() Map[String]
    + fn data_json() Value
    + fn files() Map[InMemoryFile]
    + fn headers() Map[String]
    + fn params() Map[String]
    + fn params_grouped() Map[Array[String]]
}
```

```js
+ class Response {
    + body: String
    + content_type: String
    + extra_headers: ?Array[String]
    + headers: ?Map[String]
    + status: u32

    + fn add_header(name: String, value: String) void
    + static fn empty(code: u32 (200), headers: ?Map[String] (null)) Response
    + static fn file(path: String, filename: ?String (null)) Response
    + static fn html(body: String, code: u32 (200), headers: ?Map[String] (null)) Response
    + static fn json(body: String, code: u32 (200), headers: ?Map[String] (null)) Response
    + static fn redirect(location: String, code: u32 (302), headers: ?Map[String] (null)) Response
    + fn set_header(name: String, value: String, extend_existing: bool (false)) void
    + static fn text(body: String, code: u32 (200), content_type: String ("text/plain"), headers: ?Map[String] (null)) Response
}
```

```js
+ class ResponseWriter {
    ~ responded: bool

    + static fn code_name(code: uint) String
    + fn respond(code: uint, content_type: String, body: String, headers: ?Map[String] (null), extra_headers: ?Array[String] (null)) void
    + fn send_file(path: String, custom_filename: ?String (null)) void
    + fn send_file_stream(stream: FileStream, filename: ?String (null)) void
    + fn send_status(status_code: uint) void
}
```

```js
+ class Route[T] {
}
```

```js
+ class Router[T] {
    + fn add(method: String, url: String, handler: any) void
    + fn find(method: String, url: String) Route[any] !LookupError
    + static fn new() Router[any]
}
```

```js
+ class Server {
    + fast_handler: ?shared fn(Context, ResponseWriter)()
    ~ host: String
    ~ port: u16
    + show_info: bool

    + fn add_static_dir(path: String) void !LookupError
    + static fn new(host: String, port: u16, handler: shared fn(Request)(Response)) Server !HttpError
    + fn start(worker_count: i32 (-1)) void
}
```

# io

## Aliases for 'io'

```js
alias FD for i32
```

## Functions for 'io'

```js
+ fn await_fd(fd: i32, read: bool, write: bool) PollEvent
+ fn await_socket_fd(fd: i32, read: bool, write: bool) PollEvent
+ fn close(fd: i32) void
+ fn print(msg: String) void
+ fn print_from_ptr(adr: ptr, len: uint) void
+ fn println(msg: String) void
+ fn read(fd: i32, buf: ByteBuffer, amount: uint, offset: uint) uint !IoError
+ fn read_to_ptr(fd: i32, buf: ptr, amount: uint, offset: uint) uint !IoError
+ fn read_to_ptr_sync(fd: i32, buf: ptr, amount: uint, offset: uint) uint !IoError
+ fn set_mode(fd: i32, mode: int) void
+ fn set_non_block(fd: i32, value: bool) void
+ fn write(fd: i32, buf: ByteBuffer, amount: uint) uint !IoError
+ fn write_from_ptr(fd: i32, buf: ptr, amount: uint) uint !IoError
+ fn write_from_ptr_sync(fd: i32, buf: ptr, amount: uint) uint !IoError
+ fn write_string(fd: i32, str: String) uint !IoError
```

# json

## Functions for 'json'

```js
+ fn decode(json: ByteBuffer | String) Value !ParseError
+ fn default_value(kind: int) Value
+ fn encode(data: any, pretty: bool (false)) String
+ fn encode_to(data: any, output: ByteBuffer, pretty: bool (false)) ByteBuffer
+ fn from(data: any) Value
+ fn from_value[T](data: Value) any !ValueError
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
    + fn get(index: uint) Value !ValueError
    + fn length() uint
    + fn prepend(value: Value) ArrayValue
    + fn remove(index: uint) ArrayValue
}
```

```js
+ class ObjectValue {
    + values: Map[Value]

    + fn get(key: String) Value !ValueError
    + fn get_or(key: String) Value !LookupError
    + fn has(key: String) bool
    + fn length() uint
    + fn remove(key: String) ObjectValue
    + fn set(key: String, value: Value) ObjectValue
}
```

```js
+ union Value : String | bool | float | int | ArrayValue | ObjectValue | null {
    + fn append(value: Value) Value
    + fn array() ArrayValue
    + fn array_or() ArrayValue !LookupError
    + fn bool() bool
    + fn bool_or() bool !LookupError
    + fn encode(pretty: bool (false)) String
    + fn encode_to(output: ByteBuffer, pretty: bool (false)) ByteBuffer
    + fn float() float
    + fn float_or() float !LookupError
    + fn get(key: String | uint) Value
    + fn has(key: String | uint) bool
    + fn int() int
    + fn int_or() int !LookupError
    + fn is_array() bool
    + fn is_bool() bool
    + fn is_float() bool
    + fn is_int() bool
    + fn is_null() bool
    + fn is_number() bool
    + fn is_object() bool
    + fn is_string() bool
    + fn kind() int
    + fn kind_name() String
    + fn length() uint
    + fn object() ObjectValue
    + fn object_or() ObjectValue !LookupError
    + fn prepend(value: Value) Value
    + fn remove(key: String | uint) Value
    + fn set(key: String | uint, value: Value) Value
    + fn string() String
    + fn string_or() String !LookupError
}
```

# markdown

## Functions for 'markdown'

```js
+ fn to_html(md: String, options: ?ToHtmlOptions (null)) String
```

# mem

## Functions for 'mem'

```js
+ fn alloc(size: uint) ptr
+ fn alloc_ob(size: uint) ptr
+ fn ascii_bytes_to_lower(adr: ptr, len: uint) void
+ fn bytes_to_uint(adr: ptr, len: uint) uint !SyntaxError
+ fn calloc(size: uint) ptr
+ fn clear(adr: ptr, length: uint) void
+ fn copy(from: ptr, to: ptr, length: uint) void
+ fn equal(a: ptr, b: ptr, length: uint) bool
+ fn find_char(adr: ptr, ch: u8, length: uint) uint !LookupError
+ fn free(adr: ptr) void
+ fn move(from: ptr, to: ptr, length: uint) void
+ fn resize(adr: ptr, size: uint, new_size: uint) ptr
```

# net

## Functions for 'net'

```js
+ fn recv(fd: i32, buf: ByteBuffer, amount: uint) uint !NetError
+ fn recv_to_ptr(fd: i32, buf: ptr, amount: uint) uint !NetError
+ fn send(fd: i32, buf: ByteBuffer, amount: uint) uint !NetError
+ fn send_from_ptr(fd: i32, buf: ptr, amount: uint) uint !NetError
+ fn send_string(fd: i32, str: String) uint !NetError
```

## Classes for 'net'

```js
+ class AddrInfo {
    ~ data: libc_gen_addrinfo

    + fn addr_len() u32
    + static fn new(host: String, port: u16) AddrInfo !NetError
    + fn sock_addr() libc_gen_sockaddr
}
```

```js
+ class Connection {
    ~ fd: i32
    ~+ host: String
    ~ ssl: ?SSL
    ~ ssl_enabled: bool

    + fn close() void
    + static fn new(fd: i32) Connection
    + fn recv(buffer: ByteBuffer, bytes: uint) uint !NetError
    + fn send(data: String) void !NetError
    + fn send_buffer(data: ByteBuffer, skip_bytes: uint, send_all: bool) uint !NetError
    + fn send_bytes(data: ptr, bytes: uint, send_all: bool) uint !NetError
    + fn ssl_connect(ssl: SSL) void !NetError
}
```

```js
+ class SSL {
    ~ cert_dir: ?String
    ~ cert_file: ?String
    ~ connected: bool
    ~ ctx: SSL_CTX
    ~ error_code: uint
    ~ fd: i32
    ~ ssl: OSSL

    + fn connect(fd: i32) void !NetError
    + fn custom_error(msg: String) void !NetError
    + static fn default_ca_cert_paths() Array[String]
    + fn get_error() uint
    + fn get_error_message() String
    + static fn new() SSL
    + fn recv(buffer: ByteBuffer, max_bytes: uint) uint !NetError
    + fn set_ca_cert(path: ?String) void !NetError
    + fn set_ca_cert_dir(dir: ?String) void !NetError
    + fn set_host(host: String) void !NetError
    + fn set_verify(enable: bool) void
    + fn write(from: ptr, len: uint) uint !NetError
}
```

```js
+ class Socket {
    ~ fd: i32
    ~ host: String
    ~ port: u16

    + static fn client(type: int, host: String, port: u16) Connection !NetError
    + fn close() void
    + static fn close_fd(fd: i32) void
    + static fn server(type: int, host: String, port: u16) shared SocketServer !NetError
}
```

```js
+ class SocketServer {
    ~+ socket: Socket

    + fn accept() Connection !NetError
    + fn close() void
}
```

# template

## Functions for 'template'

```js
+ fn render(name: String, data: any, options: ?RenderOptions (null)) String !ParseError
+ fn render_content(content: String, data: any, options: ?RenderOptions (null)) String
+ fn set_content(name: String, content: String) void
+ fn set_content_many(content: Map[String]) void
```

## Classes for 'template'

```js
+ class RenderOptions {
    + sanitize: ?fn(String)(String)
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
    ~ done: bool
    ~ started: bool

    + fn await() void
}
```

```js
+ class Thread[T] {
    + fn await_result() void
    + static fn start() void
    + fn wait() void
}
```

```js
+ class ThreadGroup[T] {
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
+ fn microtime() uint
+ fn mstime() uint
+ fn sleep_ms(ms: uint) void
+ fn sleep_ns(ns: uint) void
```

## Classes for 'time'

```js
+ class Datetime {
    + fn add_days(amount: int) Datetime
    + fn add_hours(amount: int) Datetime
    + fn add_microseconds(amount: int) Datetime
    + fn add_minutes(amount: int) Datetime
    + fn add_months(amount: int) Datetime
    + fn add_seconds(amount: int) Datetime
    + fn add_years(amount: int) Datetime
    + fn copy() Datetime
    + fn day() uint
    + fn day_of_week() uint
    + fn day_of_year() uint
    + fn format(pattern: String) String
    + static fn from_format(pattern: String, value: String) Datetime !SyntaxError
    + static fn from_timestamp(timestamp: int) Datetime
    + static fn from_unix_microseconds(timestamp: int) Datetime
    + fn hour() uint
    + fn is_leap_year() bool
    + fn microsecond() uint
    + fn minute() uint
    + fn modify_add_days(amount: int) Datetime
    + fn modify_add_hours(amount: int) Datetime
    + fn modify_add_microseconds(amount: int) Datetime
    + fn modify_add_minutes(amount: int) Datetime
    + fn modify_add_months(amount: int) Datetime
    + fn modify_add_seconds(amount: int) Datetime
    + fn modify_add_years(amount: int) Datetime
    + fn modify_day(day: uint) Datetime
    + fn modify_hour(hour: uint) Datetime
    + fn modify_microsecond(microsecond: uint) Datetime
    + fn modify_minute(minute: uint) Datetime
    + fn modify_month(month: uint) Datetime
    + fn modify_second(second: uint) Datetime
    + fn modify_year(year: int) Datetime
    + fn month() uint
    + static fn new(year: ?int (null), month: ?uint (null), day: ?uint (null), hour: ?uint (null), minute: ?uint (null), second: ?uint (null), microsecond: ?uint (null)) Datetime
    + static fn now() Datetime
    + fn second() uint
    + fn timestamp() int
    + fn to_iso8601() String
    + fn to_string() String
    + fn unix_microseconds() int
    + fn with_day(day: uint) Datetime
    + fn with_hour(hour: uint) Datetime
    + fn with_microsecond(microsecond: uint) Datetime
    + fn with_minute(minute: uint) Datetime
    + fn with_month(month: uint) Datetime
    + fn with_second(second: uint) Datetime
    + fn with_year(year: int) Datetime
    + fn year() int
}
```

# url

## Functions for 'url'

```js
+ fn decode(str: String) String
+ fn encode(str: String) String
+ fn parse(str: String) Url
```

## Classes for 'url'

```js
+ class Url {
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
    + fn default(val: any) Field
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
    + fn validate(data: Value, errors: ?Map[String] (null), field_name: ?String (null)) bool
    + fn validate_and_translate(data: Value, errors: Map[String], translations: Map[String] (default_translations)) bool
}
```

## Globals for 'validate'

```js
+ global default_translations : Map[String]
```
