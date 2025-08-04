
# Documentation

Namespaces: [ansi](#ansi) | [core](#core) | [coro](#coro) | [fs](#fs) | [gc](#gc) | [http](#http) | [io](#io) | [json](#json) |  | [mem](#mem) | [net](#net) | [thread](#thread) | [time](#time) | [type](#type) | [url](#url) | [utils](#utils)

---

# ansi

## Functions for 'ansi'

```js
+ fn supported() type:bool
```

# core

## Functions for 'core'

```js
+ fn exec(cmd: type:String, stream_output: type:bool (false)) (type:i32, type:String)
+ fn exit(code: type:i32) void
+ fn getenv(var: type:String) type:String
+ fn libc_errno() type:i32
+ fn panic(msg: type:String) void
+ fn raise(code: type:i32) void
+ fn signal_ignore(sig: type:int) void
+ fn socket_errno() type:i32
```

## Classes for 'core'

```js
+ class Mutex[T] {
    + fn lock() T
    + static fn new(value: T) core:Mutex
    + fn unlock(value: T) void
}
```

## Globals for 'core'

```js
~ global error_code : type:u32
~ global error_msg : type:String
```

# coro

## Functions for 'coro'

```js
+ fn await_coro(coro: coro:Coro) void
+ fn await_fd(fd: type:int, read: type:bool, write: type:bool) coro:PollEvent
+ fn throw(code: type:u32, msg: type:String) void
+ fn yield() void
```

# fs

## Functions for 'fs'

```js
+ fn add(dir: type:String, fn: type:String) type:String
+ fn basename(path: type:String) type:String
+ fn chdir(path: type:String) void
+ fn copy(from_path: type:String, to_path: type:String, recursive: type:bool (false)) void
+ fn cwd() type:String
+ fn delete(path: type:String) void
+ fn delete_recursive(path: type:String) void
+ fn dir_of(path: type:String) type:String
+ fn exe_dir() type:String
+ fn exe_path() type:String
+ fn exists(path: type:String) type:bool
+ fn ext(path: type:String, with_dot: type:bool (false)) type:String
+ fn files_in(dir: type:String, recursive: type:bool (false), files: type:bool (true), dirs: type:bool (true), prefix: ?type:String (null), result: type:Array[type:String] (...)) type:Array[type:String]
+ fn home_dir() type:String
+ fn is_dir(path: type:String) type:bool
+ fn is_file(path: type:String) type:bool
+ fn mime(ext_without_dot: type:String) type:String
+ fn mkdir(path: type:String, permissions: type:u32 (493)) void
+ fn move(from_path: type:String, to_path: type:String) void
+ fn open(path: type:String, writable: type:bool, append_on_write: type:bool) type:int
+ fn open_extend(path: type:String, writable: type:bool, append_on_write: type:bool, create_file_if_doesnt_exist: type:bool (false), create_file_permissions: type:u32 (420)) type:int
+ fn path(path: type:String) fs:Path
+ fn read(path: type:String) type:String
+ fn read_bytes(path: type:String, buffer: utils:ByteBuffer (...)) utils:ByteBuffer
+ fn realpath(path: type:String) type:String
+ fn resolve(path: type:String) type:String
+ fn rmdir(path: type:String) void
+ fn size(path: type:String) type:uint
+ fn stream(path: type:String, read: type:bool, write: type:bool, append: type:bool (false), auto_create: type:bool (false)) fs:FileStream
+ fn symlink(link: type:String, target: type:String, is_directory: type:bool) void
+ fn sync() void
+ fn write(path: type:String, content: type:String, append: type:bool (false)) void
+ fn write_bytes(path: type:String, data: type:ptr, size: type:uint, append: type:bool (false)) void
```

## Classes for 'fs'

```js
+ class FileStream {
    ~ path: type:String
    ~ reading: type:bool

    + fn close() void
    + fn read(bytes: type:uint (10240)) type:String
    + fn write_bytes(from: type:ptr, len: type:uint) void
}
```

```js
+ class InMemoryFile {
    ~ data: type:ptr
    ~ size: type:uint

    + static fn create_from_ptr(data: type:ptr, size: type:uint) fs:InMemoryFile
    + fn save(path: type:String) void
}
```

```js
+ mode Path for type:String {
    ~ bytes: type:uint

    + fn add(part: type:String) fs:Path
    + static fn new(path: type:String) fs:Path
    + fn pop() fs:Path
    + fn resolve() fs:Path
}
```

# gc

## Functions for 'gc'

```js
+ fn alloc(size: type:uint) gc:GcPtr
+ fn collect() void
+ fn collect_if_threshold_reached() void
+ fn collect_shared() void
+ fn collect_shared_if_threshold_reached() void
+ fn lock() void
+ fn unlock() void
```

## Globals for 'gc'

```js
~ shared mem_usage_peak : type:uint
~ shared mem_usage_shared : type:uint
~ global mem_usage_thread : type:uint
```

# http

## Functions for 'http'

```js
+ fn create_request(method: type:String, url: type:String, options: ?http:Options (null)) http:ClientRequest
+ fn download(url: type:String, to_path: type:String, method: type:String ("GET"), options: ?http:Options (null)) void
+ fn request(method: type:String, url: type:String, options: ?http:Options (null)) http:ClientResponse
```

## Classes for 'http'

```js
+ class Options {
    + body: type:String
    + follow_redirects: type:bool
    + headers: ?type:Map[type:String]
    + output_to_file: ?type:String
    + query_data: ?type:Map[type:String]

    + fn clear_headers(key: type:String, value: type:String) http:Options
    + fn get_headers() type:Map[type:String]
    + fn set_header(key: type:String, value: type:String) http:Options
    + fn set_headers(headers: type:Map[type:String]) http:Options
}
```

```js
+ class Response {
    + body: type:String
    + content_type: type:String
    + headers: ?type:Map[type:String]
    + status: type:u32

    + static fn empty(code: type:u32, headers: ?type:Map[type:String] (null)) http:Response
    + static fn file(path: type:String, filename: ?type:String (null)) http:Response
    + static fn html(body: type:String, code: type:u32 (200), headers: ?type:Map[type:String] (null)) http:Response
    + static fn json(body: type:String, code: type:u32 (200), headers: ?type:Map[type:String] (null)) http:Response
    + static fn redirect(location: type:String, code: type:u32 (301), headers: ?type:Map[type:String] (null)) http:Response
    + static fn text(body: type:String, code: type:u32 (200), content_type: type:String ("text/plain"), headers: ?type:Map[type:String] (null)) http:Response
}
```

```js
+ class Router[T] {
    + fn add(method: type:String, url: type:String, handler: T) void
    + fn find(method: type:String, url: type:String) http:Route
    + static fn new() http:Router
}
```

```js
+ class Server {
    + fast_handler: ?fn(http:Context, http:ResponseWriter)()
    ~ host: type:String
    ~ port: type:u16
    + show_info: type:bool

    + fn add_static_dir(path: type:String) void
    + static fn new(host: type:String, port: type:u16, handler: fn(http:Request)(http:Response)) http:Server
    + fn start(worker_count: type:i32 (8)) void
}
```

# io

## Functions for 'io'

```js
+ fn close(fd: type:int) void
+ fn os_fd(fd: type:int) type:i32
+ fn print(msg: type:String) void
+ fn print_from_ptr(adr: type:ptr, len: type:uint) void
+ fn println(msg: type:String) void
+ fn read(fd: type:int, buffer: type:ptr, buffer_size: type:uint) type:uint
+ fn set_non_block(fd: type:int, value: type:bool) void
+ fn valk_fd(fd: type:int) type:int
+ fn write(fd: type:int, str: type:String) void
+ fn write_bytes(fd: type:int, data: type:ptr, length: type:uint) type:uint
```

# json

## Functions for 'json'

```js
+ fn array_value(values: ?type:Array[json:Value] (null)) json:Value
+ fn bool_value(value: type:bool) json:Value
+ fn decode(json: type:String) json:Value
+ fn encode_value(json: json:Value, pretty: type:bool (false)) type:String
+ fn float_value(value: type:float) json:Value
+ fn int_value(value: type:int) json:Value
+ fn null_value() json:Value
+ fn object_value(values: ?type:Map[json:Value] (null)) json:Value
+ fn string_value(text: type:String) json:Value
+ fn uint_value(value: type:uint) json:Value
```

# mem

## Functions for 'mem'

```js
+ fn alloc(size: type:uint) type:ptr
+ fn ascii_bytes_to_lower(adr: type:ptr, len: type:uint) void
+ fn bytes_to_uint(adr: type:ptr, len: type:uint) type:uint
+ fn calloc(size: type:uint) type:ptr
+ fn clear(adr: type:ptr, length: type:uint) void
+ fn copy(from: type:ptr, to: type:ptr, length: type:uint) void
+ fn equal(a: type:ptr, b: type:ptr, length: type:uint) type:bool
+ fn find_char(adr: type:ptr, ch: type:u8, length: type:uint) type:uint
+ fn free(adr: type:ptr) void
```

# net

## Functions for 'net'

```js
+ fn set_ca_cert_path(path: ?type:String) void
```

## Classes for 'net'

```js
+ class AddrInfo {
    ~ data: libc_gen_addrinfo

    + fn addr_len() type:u32
    + static fn new(host: type:String, port: type:u16) net:AddrInfo
    + fn sock_addr() libc_gen_sockaddr
}
```

# thread

## Functions for 'thread'

```js
+ fn sleep_ms(ms: type:uint) void
+ fn sleep_ns(ns: type:uint) void
+ fn start(func: fn()()) thread:Thread
```

## Classes for 'thread'

```js
+ class Thread {
    ~ finished: type:bool

    + static fn start(func: fn()()) thread:Thread
    + static fn start_unsafe(func: fn()()) thread:Thread
    + fn wait() void
}
```

# time

## Functions for 'time'

```js
+ fn microtime() type:uint
+ fn mstime() type:uint
+ fn sleep_ms(ms: type:uint) void
+ fn sleep_ns(ns: type:uint) void
```

# type

## Classes for 'type'

```js
+ class Array[T] {
    ~ data: gc:GcPtr
    ~ length: type:uint
    ~ size: type:uint

    + fn append(item: T, unique: type:bool (false)) type:Array
    + fn append_copy(item: T, unique: type:bool (false)) type:Array
    + fn append_many(items: type:Array) type:Array
    + fn append_many_copy(items: type:Array) type:Array
    + fn clear() type:Array
    + fn contains(value: T) type:bool
    + fn copy() type:Array
    + fn equal(array: type:Array) type:bool
    + fn equal_ignore_order(array: type:Array) type:bool
    + fn filter(func: ?fn(T)(type:bool) (null)) type:Array
    + fn filter_copy(func: ?fn(T)(type:bool) (null)) type:Array
    + fn fit_index(index: type:uint) void
    + static fn from_json_value_auto() void
    + fn get(index: type:uint) T
    + fn increase_size(new_size: type:uint) gc:GcPtr
    + fn index_of(item: T) type:uint
    + fn intersect(with: type:Array) type:Array
    + fn merge(items: type:Array) type:Array
    + static fn new(start_size: type:uint (2)) type:Array
    + fn part(start: type:uint, amount: type:uint) type:Array
    + fn pop_first() T
    + fn pop_last() T
    + fn prepend(item: T, unique: type:bool (false)) type:Array
    + fn prepend_copy(item: T, unique: type:bool (false)) type:Array
    + fn prepend_many(items: type:Array) type:Array
    + fn prepend_many_copy(items: type:Array) type:Array
    + fn push(item: T, unique: type:bool (false)) type:Array
    + fn range(start: type:uint, end: type:uint, inclusive: type:bool (true)) type:Array
    + fn remove(index: type:uint) type:Array
    + fn remove_copy(index: type:uint) type:Array
    + fn remove_value(value: T) type:Array
    + fn remove_value_copy(value: T) type:Array
    + fn reverse() type:Array
    + fn reverse_copy() type:Array
    + fn set(index: type:uint, value: T) void
    + fn set_expand(index: type:uint, value: T, filler_value: T) void
    + fn sort(func: ?fn(T, T)(type:bool) (null)) type:Array
    + fn sort_copy(func: ?fn(T, T)(type:bool) (null)) type:Array
    + fn swap(index_a: type:uint, index_b: type:uint) void
    + fn to_json_value() json:Value
    + fn unique() type:Array
    + fn unique_copy() type:Array
}
```

```js
+ class FlatMap[K, T] {
    + fn clear() type:FlatMap
    + fn copy() type:FlatMap
    + fn get(key: K) T
    + fn has(key: K) type:bool
    + fn has_value(value: T) type:bool
    + fn keys() type:Array[K]
    + fn length() type:uint
    + fn merge(map: type:FlatMap) type:FlatMap
    + static fn new() type:FlatMap
    + fn remove(key: K) type:FlatMap
    + fn set(key: K, value: T) type:FlatMap
    + fn set_many(map: type:FlatMap) type:FlatMap
    + fn set_unique(key: K, value: T) void
    + fn sort_keys() type:FlatMap
    + fn values() type:Array
}
```

```js
+ class HashMap[K, T] {
    + fn clear() type:HashMap
    + fn copy() type:HashMap
    + fn get(key: K) T
    + fn has(key: K) type:bool
    + fn has_value(value: T) type:bool
    + fn keys() type:Array[K]
    + fn length() type:uint
    + fn merge(map: type:HashMap) type:HashMap
    + static fn new() type:HashMap
    + fn remove(key: K) type:HashMap
    + fn set(key: K, value: T) type:HashMap
    + fn set_unique(key: K, value: T) type:HashMap
    + fn sort_keys() type:HashMap
    + fn values() type:Array
}
```

```js
+ mode Map[T] for type:HashMap[type:String, T] {
    + static fn new() type:Map
}
```

```js
+ class Pool[T] {
    ~ count: type:uint

    + fn add(item: T) void
    + fn get() T
    + static fn new(start_size: type:uint (2)) type:Pool
}
```

```js
+ class String {
    ~ bytes: type:uint

    + fn contains(part: type:String) type:bool
    + fn contains_byte(byte: type:u8) type:bool
    + fn data() type:ptr[type:u8]
    + fn data_cstring() type:cstring
    + fn ends_with(part: type:String) type:bool
    + fn escape() type:String
    + static fn from_json_value(val: json:Value) type:String
    + fn get(index: type:uint) type:u8
    + fn hex_to_int() type:int
    + fn hex_to_uint() type:uint
    + fn index_of(part: type:String, start_index: type:uint (0)) type:uint
    + fn index_of_byte(byte: type:u8, start_index: type:uint (0)) type:uint
    + fn is_alpha(allow_extra_bytes: type:String ("")) type:bool
    + fn is_alpha_numeric(allow_extra_bytes: type:String ("")) type:bool
    + fn is_empty() type:bool
    + fn is_integer() type:bool
    + fn is_number() type:bool
    + fn length() type:uint
    + fn lower() type:String
    + fn ltrim(part: type:String, limit: type:uint (0)) type:String
    + static fn make_empty(length: type:uint) type:String
    + static fn make_from_ptr(data: type:ptr, length: type:uint) type:String
    + fn octal_to_int() type:int
    + fn octal_to_uint() type:uint
    + fn part(start_index: type:uint, length: type:uint) type:String
    + fn range(start: type:uint, end: type:uint, inclusive: type:bool (true)) type:String
    + fn replace(part: type:String, with: type:String) type:String
    + fn rtrim(part: type:String, limit: type:uint (0)) type:String
    + fn split(on: type:String) type:Array[type:String]
    + fn starts_with(part: type:String) type:bool
    + fn to_float() type:f64
    + fn to_int() type:int
    + fn to_json_value() json:Value
    + fn to_uint() type:uint
    + fn trim(part: type:String, limit: type:uint (0)) type:String
    + fn unescape() type:String
    + fn upper() type:String
}
```

```js
+ class bool {
}
```

```js
+ class cstring {
}
```

```js
+ class f32 {
    + fn to_str(decimals: type:uint (2)) type:String
}
```

```js
+ class f64 {
    + fn to_str(decimals: type:uint (2)) type:String
}
```

```js
+ class float {
    + fn to_str(decimals: type:uint (2)) type:String
}
```

```js
+ class i16 {
    + fn character_length(base: type:i16) type:uint
    + fn equals_str(str: type:String) type:bool
    + fn print(base: type:i16) void
    + fn round_down(modulo: type:i16) type:i16
    + fn round_up(modulo: type:i16) type:i16
    + fn to_base(base: type:i16) type:String
    + fn to_hex() type:String
    + fn to_str() type:String
}
```

```js
+ class i32 {
    + fn character_length(base: type:i32) type:uint
    + fn equals_str(str: type:String) type:bool
    + fn print(base: type:i32) void
    + fn round_down(modulo: type:i32) type:i32
    + fn round_up(modulo: type:i32) type:i32
    + fn to_base(base: type:i32) type:String
    + fn to_hex() type:String
    + fn to_str() type:String
}
```

```js
+ class i64 {
    + fn character_length(base: type:i64) type:uint
    + fn equals_str(str: type:String) type:bool
    + fn print(base: type:i64) void
    + fn round_down(modulo: type:i64) type:i64
    + fn round_up(modulo: type:i64) type:i64
    + fn to_base(base: type:i64) type:String
    + fn to_hex() type:String
    + fn to_str() type:String
}
```

```js
+ class i8 {
    + fn character_length(base: type:i8) type:uint
    + fn equals_str(str: type:String) type:bool
    + fn print(base: type:i8) void
    + fn round_down(modulo: type:i8) type:i8
    + fn round_up(modulo: type:i8) type:i8
    + fn to_base(base: type:i8) type:String
    + fn to_hex() type:String
    + fn to_str() type:String
}
```

```js
+ class int {
    + fn character_length(base: type:int) type:uint
    + fn equals_str(str: type:String) type:bool
    + fn print(base: type:int) void
    + fn round_down(modulo: type:int) type:int
    + fn round_up(modulo: type:int) type:int
    + fn to_base(base: type:int) type:String
    + fn to_hex() type:String
    + fn to_str() type:String
}
```

```js
+ class ptr {
    + fn index_of_byte(byte: type:u8, memory_size: type:uint) type:uint
    + fn offset(offset: type:uint) type:ptr
    + fn offset_int(offset: type:int) type:ptr
    + fn print_bytes(length: type:uint, end_with_newline: type:bool (true)) void
    + fn to_hex() type:String
}
```

```js
+ class u16 {
    + fn character_length(base: type:u16) type:uint
    + fn equals_str(str: type:String) type:bool
    + fn print(base: type:u16) void
    + fn round_down(modulo: type:u16) type:u16
    + fn round_up(modulo: type:u16) type:u16
    + fn to_base(base: type:u16) type:String
    + fn to_hex() type:String
    + fn to_str() type:String
}
```

```js
+ class u32 {
    + fn character_length(base: type:u32) type:uint
    + fn equals_str(str: type:String) type:bool
    + fn print(base: type:u32) void
    + fn round_down(modulo: type:u32) type:u32
    + fn round_up(modulo: type:u32) type:u32
    + fn to_base(base: type:u32) type:String
    + fn to_hex() type:String
    + fn to_str() type:String
}
```

```js
+ class u64 {
    + fn character_length(base: type:u64) type:uint
    + fn equals_str(str: type:String) type:bool
    + fn print(base: type:u64) void
    + fn round_down(modulo: type:u64) type:u64
    + fn round_up(modulo: type:u64) type:u64
    + fn to_base(base: type:u64) type:String
    + fn to_hex() type:String
    + fn to_str() type:String
}
```

```js
+ class u8 {
    + fn character_length(base: type:u8) type:uint
    + fn equals_str(str: type:String) type:bool
    + fn hex_byte_to_hex_value() type:u8
    + fn is_alpha() type:bool
    + fn is_alpha_numeric() type:bool
    + fn is_ascii() type:bool
    + fn is_hex() type:bool
    + fn is_html_spacing() type:bool
    + fn is_html_whitespace() type:bool
    + fn is_lower() type:bool
    + fn is_newline() type:bool
    + fn is_number() type:bool
    + fn is_octal() type:bool
    + fn is_space_or_tab() type:bool
    + fn is_upper() type:bool
    + fn is_whitespace() type:bool
    + fn print(base: type:u8) void
    + fn round_down(modulo: type:u8) type:u8
    + fn round_up(modulo: type:u8) type:u8
    + fn to_ascii_string() type:String
    + fn to_base(base: type:u8) type:String
    + fn to_hex() type:String
    + fn to_str() type:String
    + fn unescape() type:u8
}
```

```js
+ class uint {
    + fn character_length(base: type:uint) type:uint
    + fn equals_str(str: type:String) type:bool
    + fn print(base: type:uint) void
    + fn round_down(modulo: type:uint) type:uint
    + fn round_up(modulo: type:uint) type:uint
    + fn to_base(base: type:uint) type:String
    + fn to_hex() type:String
    + fn to_str() type:String
}
```

# url

## Functions for 'url'

```js
+ fn decode(str: type:String) type:String
+ fn encode(str: type:String) type:String
+ fn parse(str: type:String) url:Url
```

# utils

## Classes for 'utils'

```js
+ class ByteBuffer {
    ~ data: type:ptr
    ~ length: type:uint
    ~ size: type:uint

    + fn append(buffer: utils:ByteBuffer, start_index: type:uint (0)) void
    + fn append_byte(byte: type:u8) void
    + fn append_from_ptr(data: type:ptr, length: type:uint) void
    + fn append_int(value: type:int) void
    + fn append_str(str: type:String) void
    + fn append_uint(value: type:uint) void
    + fn clear() void
    + fn clear_part(index: type:uint, len: type:uint) void
    + fn clear_until(index: type:uint) void
    + fn clone() utils:ByteBuffer
    + fn equals_str(str: type:String) type:bool
    + fn get(index: type:uint) type:u8
    + fn index_of_byte(byte: type:u8, start_index: type:uint (0)) type:uint
    + fn index_where_byte_is_not(byte: type:u8, start_index: type:uint (0)) type:uint
    + fn minimum_free_space(length: type:uint) void
    + fn minimum_size(minimum_size: type:uint) void
    + static fn new(start_size: type:uint (128)) utils:ByteBuffer
    + fn part(start_index: type:uint, length: type:uint) type:String
    + fn reduce_size(size: type:uint) void
    + fn starts_with(str: type:String, offset: type:uint) type:bool
    + fn str_ref(offset: type:uint, length: type:uint) utils:ByteBufferStrRef
    + fn to_string() type:String
}
```

