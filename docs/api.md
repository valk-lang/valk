
# Documentation

Namespaces: [ansi](#ansi) | [core](#core) | [coro](#coro) | [fs](#fs) | [gc](#gc) | [http](#http) | [io](#io) | [json](#json) | [mem](#mem) | [net](#net) | [template](#template) | [thread](#thread) | [time](#time) | [type](#type) | [url](#url) | [utils](#utils)

---

# ansi

## Functions for 'ansi'

```js
+ fn supported() bool
```

# core

## Functions for 'core'

```js
+ fn exec(cmd: String, stream_output: bool (false)) (i32, String)
+ fn exit(code: i32) void
+ fn getenv(var: String) String !not_found
+ fn libc_errno() i32
+ fn panic(msg: String) void
+ fn raise(code: i32) void
+ fn signal_ignore(sig: int) void
+ fn socket_errno() i32
```

## Classes for 'core'

```js
+ class Mutex[T] {
    + fn lock() T
    + static fn new(value: T) Mutex[T]
    + fn unlock(value: T) void
}
```

## Globals for 'core'

```js
~ global error_code : u32
~ global error_msg : String
~ global error_msg_index : uint
~ global error_msgs : [String x 100]
```

# coro

## Functions for 'coro'

```js
+ fn await_coro(coro: Coro) void
+ fn await_fd(fd: int, read: bool, write: bool) PollEvent
+ fn yield() void
```

# fs

## Functions for 'fs'

```js
+ fn add(dir: String, fn: String) String
+ fn basename(path: String) String
+ fn chdir(path: String) void
+ fn copy(from_path: String, to_path: String, recursive: bool (false)) void !fail
+ fn cwd() String
+ fn delete(path: String) void !delete
+ fn delete_recursive(path: String) void
+ fn dir_of(path: String) String
+ fn exe_dir() String
+ fn exe_path() String
+ fn exists(path: String) bool
+ fn ext(path: String, with_dot: bool (false)) String
+ fn files_in(dir: String, recursive: bool (false), files: bool (true), dirs: bool (true), prefix: ?String (null), result: Array[String] (...)) Array[String]
+ fn home_dir() String !not_found
+ fn is_dir(path: String) bool
+ fn is_file(path: String) bool
+ fn mime(ext_without_dot: String) String
+ fn mkdir(path: String, permissions: u32 (493)) void !fail
+ fn move(from_path: String, to_path: String) void !fail
+ fn open(path: String, writable: bool, append_on_write: bool) int !open
+ fn open_extend(path: String, writable: bool, append_on_write: bool, create_file_if_doesnt_exist: bool (false), create_file_permissions: u32 (420)) int !open !access
+ fn path(path: String) Path
+ fn read(path: String) String !open !read !close
+ fn read_bytes(path: String, buffer: ByteBuffer (...)) ByteBuffer !open !read !close
+ fn realpath(path: String) String
+ fn resolve(path: String) String
+ fn rmdir(path: String) void !fail
+ fn size(path: String) uint
+ fn stream(path: String, read: bool, write: bool, append: bool (false), auto_create: bool (false)) FileStream !err_open
+ fn symlink(link: String, target: String, is_directory: bool) void !permissions !exists !other
+ fn sync() void
+ fn write(path: String, content: String, append: bool (false)) void !open !write
+ fn write_bytes(path: String, data: ptr, size: uint, append: bool (false)) void !open !write
```

## Classes for 'fs'

```js
+ class FileStream {
    ~ path: String
    ~ reading: bool

    + fn close() void
    + fn read(bytes: uint (10240)) String !read_err
    + fn write_bytes(from: ptr, len: uint) void !write_err
}
```

```js
+ class InMemoryFile {
    ~ data: ptr
    ~ size: uint

    + static fn create_from_ptr(data: ptr, size: uint) InMemoryFile
    + fn save(path: String) void
}
```

```js
+ mode Path for String {
    ~ bytes: uint

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
+ fn collect() void
+ fn collect_if_threshold_reached() void
+ fn collect_shared() void
+ fn collect_shared_if_threshold_reached() void
+ fn lock() void
+ fn unlock() void
```

## Globals for 'gc'

```js
~ shared mem_usage_peak : uint
~ shared mem_usage_shared : uint
~ global mem_usage_thread : uint
+ shared verify : bool
```

# http

## Functions for 'http'

```js
+ fn create_request(method: String, url: String, options: ?Options (null)) ClientRequest !invalid_url !ssl !connect
+ fn download(url: String, to_path: String, method: String ("GET"), options: ?Options (null)) void !invalid_path !invalid_url !ssl !connect !disconnect !invalid_response
+ fn parse_http(input: ByteBuffer, context: Context, is_response: bool) void !invalid !http413 !incomplete !missing_host_header !file_error
+ fn request(method: String, url: String, options: ?Options (null)) ClientResponse !invalid_url !invalid_output_path !ssl !connect !disconnect !invalid_response
```

## Classes for 'http'

```js
+ class ClientRequest {
    ~ bytes_received: uint
    ~ bytes_sent: uint
    ~ bytes_to_recv: uint
    ~ bytes_to_send: uint
    ~ recv_buffer: ByteBuffer
    ~ recv_percent: uint
    ~ request_sent: bool
    ~ response_received: bool
    ~ sent_percent: uint

    + static fn create(method: String, url: String, options: ?Options (null)) ClientRequest !invalid_url !connection_failed !ssl !invalid_output_path
    + fn progress() bool !disconnect !invalid_response
    + fn response() ClientResponse !in_progress !invalid_response
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
    ~ fd: int
    ~ netcon: Connection
    ~ worker: Worker

    + fn close() void
}
```

```js
+ class Context {
    ~ body_received: uint
    ~ chunked: bool
    ~ content_length: uint
    ~ has_host: bool
    ~ method: ByteBufferStrRef
    ~ parsed_index: uint
    ~ path: ByteBufferStrRef
    ~ query_string: ByteBufferStrRef
    ~ status: uint

    + fn body() String
    + fn data() Map[String]
    + fn files() Map[InMemoryFile]
    + fn headers() Map[String]
    + fn params() Map[String]
    + fn params_grouped() Map[Array[String]]
}
```

```js
+ class Options {
    + body: String
    + follow_redirects: bool
    + headers: ?Map[String]
    + output_to_file: ?String
    + query_data: ?Map[String]

    + fn clear_headers(key: String, value: String) Options
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
    + headers: ?Map[String]
    + status: u32

    + static fn empty(code: u32, headers: ?Map[String] (null)) Response
    + static fn file(path: String, filename: ?String (null)) Response
    + static fn html(body: String, code: u32 (200), headers: ?Map[String] (null)) Response
    + static fn json(body: String, code: u32 (200), headers: ?Map[String] (null)) Response
    + static fn redirect(location: String, code: u32 (301), headers: ?Map[String] (null)) Response
    + static fn text(body: String, code: u32 (200), content_type: String ("text/plain"), headers: ?Map[String] (null)) Response
}
```

```js
+ class ResponseWriter {
    ~ responded: bool

    + fn respond(code: uint, content_type: String, body: String, headers: ?Map[String] (null)) void
    + fn send_file(path: String, custom_filename: ?String (null)) void
    + fn send_file_stream(stream: FileStream, filename: ?String (null)) void
    + fn send_status(status_code: uint) void
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
    + fn add(method: String, url: String, handler: T) void !invalid_route
    + fn find(method: String, url: String) Route[T] !not_found
    + static fn new() Router[T]
}
```

```js
+ class Server {
    + fast_handler: ?fn(Context, ResponseWriter)()
    ~ host: String
    ~ port: u16
    + show_info: bool

    + fn add_static_dir(path: String) void !notfound
    + static fn new(host: String, port: u16, handler: fn(Request)(Response)) Server !socket_init_error !socket_bind_error
    + fn start(worker_count: i32 (8)) void
}
```

# io

## Functions for 'io'

```js
+ fn close(fd: int) void
+ fn os_fd(fd: int) i32
+ fn print(msg: String) void
+ fn print_from_ptr(adr: ptr, len: uint) void
+ fn println(msg: String) void
+ fn read(fd: int, buffer: ptr, buffer_size: uint) uint !failed
+ fn set_non_block(fd: int, value: bool) void
+ fn valk_fd(fd: int) int
+ fn write(fd: int, str: String) void !failed !again
+ fn write_bytes(fd: int, data: ptr, length: uint) uint !failed !again
```

# json

## Functions for 'json'

```js
+ fn decode(json: String) Value !invalid
+ fn encode(data: $T, pretty: bool (false)) String
+ fn encode_value(json: Value, pretty: bool (false)) String
+ fn new_array(values: ?Array[Value] (null)) Value
+ fn new_bool(value: bool) Value
+ fn new_float(value: float) Value
+ fn new_int(value: int) Value
+ fn new_null() Value
+ fn new_object(values: ?Map[Value] (null)) Value
+ fn new_string(text: String) Value
+ fn new_uint(value: uint) Value
+ fn to_type[T](data: Value) T
+ fn value(data: $T) Value
```

# mem

## Functions for 'mem'

```js
+ fn alloc(size: uint) ptr
+ fn ascii_bytes_to_lower(adr: ptr, len: uint) void
+ fn bytes_to_uint(adr: ptr, len: uint) uint !not_a_number
+ fn calloc(size: uint) ptr
+ fn clear(adr: ptr, length: uint) void
+ fn copy(from: ptr, to: ptr, length: uint) void
+ fn equal(a: ptr, b: ptr, length: uint) bool
+ fn find_char(adr: ptr, ch: u8, length: uint) uint !not_found
+ fn free(adr: ptr) void
+ fn resize(adr: ptr, size: uint, new_size: uint) ptr
```

# net

## Functions for 'net'

```js
+ fn set_ca_cert_path(path: ?String) void
```

## Classes for 'net'

```js
+ class AddrInfo {
    ~ data: libc_gen_addrinfo

    + fn addr_len() u32
    + static fn new(host: String, port: u16) AddrInfo !fail
    + fn sock_addr() libc_gen_sockaddr
}
```

# template

## Functions for 'template'

```js
+ fn render(path: String, data: $T, template_directory: ?String (null)) String !FileNotFound
+ fn render_content(content: String, data: ?Value (null), template_directory: ?String (null), template_path: ?String (null)) String
```

# thread

## Functions for 'thread'

```js
+ fn sleep_ms(ms: uint) void
+ fn sleep_ns(ns: uint) void
+ fn start(func: fn()()) Thread
```

## Classes for 'thread'

```js
+ class Thread {
    ~ finished: bool

    + static fn start(func: fn()()) Thread
    + static fn start_unsafe(func: fn()()) Thread
    + fn wait() void
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

# type

## Classes for 'type'

```js
+ class Array[T] {
    ~ data: GcPtr
    ~ length: uint
    ~ size: uint

    + fn append(item: T, unique: bool (false)) Array[T]
    + fn append_copy(item: T, unique: bool (false)) Array[T]
    + fn append_many(items: Array[T]) Array[T]
    + fn append_many_copy(items: Array[T]) Array[T]
    + fn clear() Array[T]
    + fn contains(value: T) bool
    + fn copy() Array[T]
    + fn equal(array: Array[T]) bool
    + fn equal_ignore_order(array: Array[T]) bool
    + fn filter(func: ?fn(T)(bool) (null)) Array[T]
    + fn filter_copy(func: ?fn(T)(bool) (null)) Array[T]
    + fn fit_index(index: uint) void
    + fn get(index: uint) T !not_found
    + fn increase_size(new_size: uint) GcPtr
    + fn index_of(item: T) uint !not_found
    + fn intersect(with: Array[T]) Array[T]
    + fn merge(items: Array[T]) Array[T]
    + static fn new(start_size: uint (2)) Array[T]
    + fn part(start: uint, amount: uint) Array[T]
    + fn pop_first() T !empty
    + fn pop_last() T !empty
    + fn prepend(item: T, unique: bool (false)) Array[T]
    + fn prepend_copy(item: T, unique: bool (false)) Array[T]
    + fn prepend_many(items: Array[T]) Array[T]
    + fn prepend_many_copy(items: Array[T]) Array[T]
    + fn push(item: T, unique: bool (false)) Array[T]
    + fn range(start: uint, end: uint, inclusive: bool (true)) Array[T]
    + fn remove(index: uint) Array[T]
    + fn remove_copy(index: uint) Array[T]
    + fn remove_value(value: T) Array[T]
    + fn remove_value_copy(value: T) Array[T]
    + fn reverse() Array[T]
    + fn reverse_copy() Array[T]
    + fn set(index: uint, value: T) void !out_of_range
    + fn set_expand(index: uint, value: T, filler_value: T) void
    + fn sort(func: ?fn(T, T)(bool) (null)) Array[T]
    + fn sort_copy(func: ?fn(T, T)(bool) (null)) Array[T]
    + fn swap(index_a: uint, index_b: uint) void
    + fn to_json_value() Value
    + fn unique() Array[T]
    + fn unique_copy() Array[T]
}
```

```js
+ class FlatMap[K, T] {
    + fn clear() FlatMap[K, T]
    + fn copy() FlatMap[K, T]
    + fn get(key: K) T !not_found
    + fn has(key: K) bool
    + fn has_value(value: T) bool
    + fn keys() Array[K]
    + fn length() uint
    + fn merge(map: FlatMap[K, T]) FlatMap[K, T]
    + static fn new() FlatMap[K, T]
    + fn remove(key: K) FlatMap[K, T]
    + fn set(key: K, value: T) FlatMap[K, T]
    + fn set_many(map: FlatMap[K, T]) FlatMap[K, T]
    + fn set_unique(key: K, value: T) void !not_unique
    + fn sort_keys() FlatMap[K, T]
    + fn values() Array[T]
}
```

```js
+ class HashMap[K, T] {
    + fn clear() HashMap[K, T]
    + fn copy() HashMap[K, T]
    + fn get(key: K) T !not_found
    + fn has(key: K) bool
    + fn has_value(value: T) bool
    + fn keys() Array[K]
    + fn length() uint
    + fn merge(map: HashMap[K, T]) HashMap[K, T]
    + static fn new() HashMap[K, T]
    + fn remove(key: K) HashMap[K, T]
    + fn set(key: K, value: T) HashMap[K, T]
    + fn set_unique(key: K, value: T) HashMap[K, T]
    + fn sort_keys() HashMap[K, T]
    + fn values() Array[T]
}
```

```js
+ mode Map[T] for HashMap[String, T] {
    + static fn new() Map[T]
}
```

```js
+ class Pool[T] {
    ~ count: uint

    + fn add(item: T) void
    + fn get() T !empty
    + static fn new(start_size: uint (2)) Pool[T]
}
```

```js
+ class String {
    ~ bytes: uint

    + fn contains(part: String) bool
    + fn contains_byte(byte: u8) bool
    + fn data() ptr[u8]
    + fn data_cstring() cstring
    + fn ends_with(part: String) bool
    + fn escape() String
    + static fn from_json_value(val: Value) String
    + fn get(index: uint) u8
    + fn hex_to_int() int !invalid
    + fn hex_to_uint() uint !invalid
    + fn index_of(part: String, start_index: uint (0)) uint !not_found
    + fn index_of_byte(byte: u8, start_index: uint (0)) uint !not_found
    + fn is_alpha(allow_extra_bytes: String ("")) bool
    + fn is_alpha_numeric(allow_extra_bytes: String ("")) bool
    + fn is_empty() bool
    + fn is_integer() bool
    + fn is_number() bool
    + fn length() uint
    + fn lower() String
    + fn ltrim(part: String, limit: uint (0)) String
    + static fn make_empty(length: uint) String
    + static fn make_from_ptr(data: ptr, length: uint) String
    + fn octal_to_int() int !invalid
    + fn octal_to_uint() uint !invalid
    + fn part(start_index: uint, length: uint) String
    + fn range(start: uint, end: uint, inclusive: bool (true)) String
    + fn replace(part: String, with: String) String
    + fn rtrim(part: String, limit: uint (0)) String
    + fn split(on: String) Array[String]
    + fn starts_with(part: String) bool
    + fn to_float() f64 !invalid
    + fn to_int() int !invalid
    + fn to_json_value() Value
    + fn to_uint() uint !invalid
    + fn trim(part: String, limit: uint (0)) String
    + fn unescape() String
    + fn upper() String
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
    + fn to_str(decimals: uint (2)) String
}
```

```js
+ class f64 {
    + fn to_str(decimals: uint (2)) String
}
```

```js
+ class float {
    + fn to_str(decimals: uint (2)) String
}
```

```js
+ class i16 {
    + fn character_length(base: i16) uint
    + fn equals_str(str: String) bool
    + fn print(base: i16) void
    + fn round_down(modulo: i16) i16
    + fn round_up(modulo: i16) i16
    + fn to_base(base: i16) String
    + fn to_hex() String
    + fn to_str() String
}
```

```js
+ class i32 {
    + fn character_length(base: i32) uint
    + fn equals_str(str: String) bool
    + fn print(base: i32) void
    + fn round_down(modulo: i32) i32
    + fn round_up(modulo: i32) i32
    + fn to_base(base: i32) String
    + fn to_hex() String
    + fn to_str() String
}
```

```js
+ class i64 {
    + fn character_length(base: i64) uint
    + fn equals_str(str: String) bool
    + fn print(base: i64) void
    + fn round_down(modulo: i64) i64
    + fn round_up(modulo: i64) i64
    + fn to_base(base: i64) String
    + fn to_hex() String
    + fn to_str() String
}
```

```js
+ class i8 {
    + fn character_length(base: i8) uint
    + fn equals_str(str: String) bool
    + fn print(base: i8) void
    + fn round_down(modulo: i8) i8
    + fn round_up(modulo: i8) i8
    + fn to_base(base: i8) String
    + fn to_hex() String
    + fn to_str() String
}
```

```js
+ class int {
    + fn character_length(base: int) uint
    + fn equals_str(str: String) bool
    + fn print(base: int) void
    + fn round_down(modulo: int) int
    + fn round_up(modulo: int) int
    + fn to_base(base: int) String
    + fn to_hex() String
    + fn to_str() String
}
```

```js
+ class ptr {
    + fn index_of_byte(byte: u8, memory_size: uint) uint !not_found
    + fn offset(offset: uint) ptr
    + fn offset_int(offset: int) ptr
    + fn print_bytes(length: uint, end_with_newline: bool (true)) void
    + fn to_hex() String
}
```

```js
+ class u16 {
    + fn character_length(base: u16) uint
    + fn equals_str(str: String) bool
    + fn print(base: u16) void
    + fn round_down(modulo: u16) u16
    + fn round_up(modulo: u16) u16
    + fn to_base(base: u16) String
    + fn to_hex() String
    + fn to_str() String
}
```

```js
+ class u32 {
    + fn character_length(base: u32) uint
    + fn equals_str(str: String) bool
    + fn print(base: u32) void
    + fn round_down(modulo: u32) u32
    + fn round_up(modulo: u32) u32
    + fn to_base(base: u32) String
    + fn to_hex() String
    + fn to_str() String
}
```

```js
+ class u64 {
    + fn character_length(base: u64) uint
    + fn equals_str(str: String) bool
    + fn print(base: u64) void
    + fn round_down(modulo: u64) u64
    + fn round_up(modulo: u64) u64
    + fn to_base(base: u64) String
    + fn to_hex() String
    + fn to_str() String
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
    + fn round_down(modulo: u8) u8
    + fn round_up(modulo: u8) u8
    + fn to_ascii_string() String
    + fn to_base(base: u8) String
    + fn to_hex() String
    + fn to_str() String
    + fn unescape() u8
}
```

```js
+ class uint {
    + fn character_length(base: uint) uint
    + fn equals_str(str: String) bool
    + fn print(base: uint) void
    + fn round_down(modulo: uint) uint
    + fn round_up(modulo: uint) uint
    + fn to_base(base: uint) String
    + fn to_hex() String
    + fn to_str() String
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

# utils

## Classes for 'utils'

```js
+ class ByteBuffer {
    ~ data: ptr
    ~ length: uint
    ~ size: uint

    + fn append(buffer: ByteBuffer, start_index: uint (0)) void
    + fn append_byte(byte: u8) void
    + fn append_from_ptr(data: ptr, length: uint) void
    + fn append_int(value: int) void
    + fn append_str(str: String) void
    + fn append_uint(value: uint) void
    + fn clear() void
    + fn clear_part(index: uint, len: uint) void
    + fn clear_until(index: uint) void
    + fn clone() ByteBuffer
    + fn equals_str(str: String) bool
    + fn get(index: uint) u8
    + fn index_of(byte: u8, start_index: uint (0)) uint !not_found
    + fn index_where_byte_is_not(byte: u8, start_index: uint (0)) uint !not_found
    + fn minimum_free_space(length: uint) void
    + fn minimum_size(minimum_size: uint) void
    + static fn new(start_size: uint (128)) ByteBuffer
    + fn part(start_index: uint, length: uint) String
    + fn reduce_size(size: uint) void
    + fn starts_with(str: String, offset: uint) bool
    + fn str_ref(offset: uint, length: uint) ByteBufferStrRef
    + fn to_string() String
}
```

