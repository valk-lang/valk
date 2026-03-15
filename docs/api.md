
# Documentation

Namespaces: [ansi](#ansi) | [core](#core) | [coro](#coro) | [crypto](#crypto) | [fs](#fs) | [gc](#gc) | [html](#html) | [http](#http) | [io](#io) | [json](#json) | [markdown](#markdown) | [mem](#mem) | [net](#net) | [template](#template) | [thread](#thread) | [time](#time) | [type](#type) | [url](#url)

---

# ansi

## Functions for 'ansi'

```js
+ fn supported() bool
```

# core

## Functions for 'core'

```js
+ fn exec(cmd: String, print_output: bool (false)) (i32, String)
+ fn exit(code: i32) void
+ fn getenv(var: String) String !core:LookupError
+ fn panic(msg: String) void
+ fn race_lock() void
+ fn race_unlock() void
+ fn raise(code: i32) void
+ fn signal_ignore(sig: int) void
```

## Classes for 'core'

```js
+ class Mutex {
    + fn await_unlock() void
    + fn lock() void
    + static fn new() Mutex !core:InitError
    + fn unlock() void
}
```

```js
+ class SyncMutex {
    + fn lock() void
    + static fn new() SyncMutex
    + fn unlock() void
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
+ fn base64_decode(str: String) String
+ fn base64_decode_ptr(data: ptr, len: uint, out: ByteBuffer) void
+ fn base64_encode(str: String) String
+ fn base64_encode_ptr(data: ptr, len: uint, out: ByteBuffer) void
+ fn bcrypt(cost: uint, salt: String, password: String, output: ByteBuffer) void
+ fn bcrypt_hash(password: String, cost: uint (12)) String
+ fn bcrypt_verify(password: String, hash: String) bool
+ fn blowfish_encrypt_block(context: BlowfishContext, input: ptr[u8], output: ptr[u8]) void
+ fn blowfish_expand_key(context: BlowfishContext, salt: ?ByteBuffer, key: ByteBuffer) void !crypto:CryptoError
+ fn blowfish_init_state(context: BlowfishContext) void
+ fn blowfish_xor_block(data: &[u8], salt: ByteBuffer, saltIndex: &[uint]) void
+ fn sha1_encode(str: String) String
+ fn sha256_encode(str: String) String
```

## Classes for 'crypto'

```js
+ class Blake2b {
    + fn finalize(out: ptr[u8]) void
    + static fn hash_str(input: String, key: ?String (null), lowercase: bool (true)) String !crypto:CryptoError
    + static fn new(hash_size: uint, key: ?String (null)) Blake2b !crypto:CryptoError
    + fn update(data: ptr[u8], length: uint) void
}
```

```js
+ class BlowfishContext {
}
```

```js
+ class Sha1 {
    + fn add_hash_data(data: &[u8 x 20]) void
    + fn add_raw_data_unsafe(data: ptr[u8], len: uint) void
    + fn add_string_data(str: String) void
    + fn final() [u8 x 20]
    + fn reset() void
}
```

```js
+ class Sha256 {
    + fn add_hash_data(data: &[u8 x 32]) void
    + fn add_raw_data_unsafe(data: ptr[u8], len: uint) void
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
+ fn files_in(dir: String, recursive: bool (false), files: bool (true), dirs: bool (true), prefix: ?String (null), result: Array[String] (...)) Array[String]
+ fn home_dir() String !core:ExternError
+ fn is_dir(path: String) bool
+ fn is_file(path: String) bool
+ fn mime(ext_without_dot: String) String
+ fn mkdir(path: String, permissions: u32 (493)) void !io:IoError
+ fn modified_time(path: String) uint !io:IoError
+ fn move(from_path: String, to_path: String) void !io:IoError
+ fn open(path: String, writable: bool, append_on_write: bool) i32 !io:IoError
+ fn open_extend(path: String, writable: bool, append_on_write: bool, create_file_if_doesnt_exist: bool (false), create_file_permissions: u32 (420)) i32 !io:IoError
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
    ~ size: uint

    + static fn create_from_buffer(buffer: ByteBuffer) InMemoryFile
    + static fn create_from_file(path: String) InMemoryFile !io:IoError
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
+ fn collect_if_threshold_almost_reached() void
+ fn collect_if_threshold_reached() void
+ fn collect_shared() void
+ fn collect_shared_if_threshold_reached() void
+ fn lock() void
+ fn unlock() void
```

## Globals for 'gc'

```js
~ global gc : Gc
~ shared mem_usage_peak : uint
~ shared mem_usage_shared : uint
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
+ fn create_request(method: String, url: String, options: ?Options (null)) ClientRequest !http:HttpError
+ fn download(url: String, to_path: String, method: String (""), options: ?Options (null)) void !http:HttpError
+ fn parse_http(input: ByteBuffer, context: Context, is_response: bool) void !http:HttpParseError
+ fn request(method: String, url: String, options: ?Options (null)) ClientResponse !http:HttpError
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

    + static fn create(method: String, url: String, options: ?Options (null)) ClientRequest !http:HttpError
    + fn progress() bool !http:HttpError
    + fn response() ClientResponse !http:HttpError
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
    ~ fd: i32
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
    + static fn text(body: String, code: u32 (200), content_type: String (""), headers: ?Map[String] (null)) Response
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
    + fn add(method: String, url: String, handler: T) void
    + fn find(method: String, url: String) Route[T] !core:LookupError
    + static fn new() Router[T]
}
```

```js
+ class Server {
    + fast_handler: ?fn(Context, ResponseWriter)()!
    ~ host: String
    ~ port: u16
    + show_info: bool

    + fn add_static_dir(path: String) void !core:LookupError
    + static fn new(host: String, port: u16, handler: fn(Request)(Response)!) Server !http:HttpError
    + fn start(worker_count: i32 (-1)) void
}
```

# io

## Functions for 'io'

```js
+ fn await_fd(fd: i32, read: bool, write: bool) PollEvent
+ fn await_socket_fd(fd: i32, read: bool, write: bool) PollEvent
+ fn close(fd: i32) void
+ fn print(msg: String) void
+ fn print_from_ptr(adr: ptr, len: uint) void
+ fn println(msg: String) void
+ fn read(fd: i32, buf: ByteBuffer, amount: uint, offset: uint) uint !io:IoError
+ fn read_to_ptr(fd: i32, buf: ptr, amount: uint, offset: uint) uint !io:IoError
+ fn read_to_ptr_sync(fd: i32, buf: ptr, amount: uint, offset: uint) uint !io:IoError
+ fn set_mode(fd: i32, mode: io:MODE(int)) void
+ fn set_non_block(fd: i32, value: bool) void
+ fn write(fd: i32, buf: ByteBuffer, amount: uint) uint !io:IoError
+ fn write_from_ptr(fd: i32, buf: ptr, amount: uint) uint !io:IoError
+ fn write_from_ptr_sync(fd: i32, buf: ptr, amount: uint) uint !io:IoError
+ fn write_string(fd: i32, str: String) uint !io:IoError
```

# json

## Functions for 'json'

```js
+ fn decode(json: String) Value !json:ParseError
+ fn encode(data: $T, pretty: bool (false), output: ?StringComposer (null), depth: uint (0)) StringComposer
+ fn encode_to_string(data: $T, pretty: bool (false)) String
+ fn new_array(values: ?Array[Value] (null)) Value
+ fn new_bool(value: bool) Value
+ fn new_float(value: float) Value
+ fn new_int(value: int) Value
+ fn new_null() Value
+ fn new_object(values: ?Map[Value] (null)) Value
+ fn new_string(text: String) Value
+ fn new_uint(value: uint) Value
+ fn value(data: $T) Value
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
+ fn bytes_to_uint(adr: ptr, len: uint) uint !core:SyntaxError
+ fn calloc(size: uint) ptr
+ fn clear(adr: ptr, length: uint) void
+ fn copy(from: ptr, to: ptr, length: uint) void
+ fn equal(a: ptr, b: ptr, length: uint) bool
+ fn find_char(adr: ptr, ch: u8, length: uint) uint !core:LookupError
+ fn free(adr: ptr) void
+ fn resize(adr: ptr, size: uint, new_size: uint) ptr
```

# net

## Functions for 'net'

```js
+ fn recv(fd: i32, buf: ByteBuffer, amount: uint) uint !net:NetError
+ fn recv_to_ptr(fd: i32, buf: ptr, amount: uint) uint !net:NetError
+ fn send(fd: i32, buf: ByteBuffer, amount: uint) uint !net:NetError
+ fn send_from_ptr(fd: i32, buf: ptr, amount: uint) uint !net:NetError
+ fn send_string(fd: i32, str: String) uint !net:NetError
+ fn set_ca_cert_path(path: ?String) void
```

## Classes for 'net'

```js
+ class AddrInfo {
    ~ data: libc_gen_addrinfo

    + fn addr_len() u32
    + static fn new(host: String, port: u16) AddrInfo !net:NetError
    + fn sock_addr() libc_gen_sockaddr
}
```

```js
+ class Connection {
    ~ fd: i32
    ~ ssl: ?SSL
    ~ ssl_enabled: bool
    ~ ssl_error: String
    ~ ssl_error_code: i32

    + fn close() void
    + static fn new(fd: i32) Connection
    + fn recv(buffer: ByteBuffer, bytes: uint) uint !net:NetError
    + fn send(data: String) void !net:NetError
    + fn send_buffer(data: ByteBuffer, skip_bytes: uint, send_all: bool) uint !net:NetError
    + fn send_bytes(data: ptr, bytes: uint, send_all: bool) uint !net:NetError
    + fn ssl_connect(host: String, ca_cert_path: ?String (null)) void !net:NetError
}
```

```js
+ class SSL {
    ~ ctx: OSSL
    ~ ssl: OSSL

    + static fn ca_paths() Array[String]
    + static fn last_error_msg() String
}
```

```js
+ class Socket {
    ~ fd: i32
    ~ host: String
    ~ port: u16

    + static fn client(type: net:SOCKET_TYPE(int), host: String, port: u16) Connection !net:NetError
    + fn close() void
    + static fn close_fd(fd: i32) void
    + static fn server(type: net:SOCKET_TYPE(int), host: String, port: u16) SocketServer !net:NetError
}
```

```js
+ class SocketServer {
    ~ socket: Socket

    + fn accept() Connection !net:NetError
    + fn close() void
}
```

# template

## Functions for 'template'

```js
+ fn render(name: String, data: $T, options: ?RenderOptions (null)) String !template:Error
+ fn render_content(content: String, data: $T, options: ?RenderOptions (null)) String
+ fn set_content(name: String, content: String) void
+ fn set_content_many(content: Map[String]) void
```

## Classes for 'template'

```js
+ class RenderOptions {
    + sanitize: ?fn(String)(String)!
}
```

# thread

## Functions for 'thread'

```js
+ fn start(func: fn()()!) Thread !core:InitError
+ fn suspend_ms(ms: uint) void
+ fn suspend_ns(ns: uint) void
+ fn task(handler: fn()()!) Task !core:InitError
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
+ class Thread {
    ~ finished: bool
    ~ started: bool

    + static fn start(func: fn()()!) Thread !core:InitError
    + fn wait() void
}
```

```js
+ class ThreadSuspendGate {
    + static fn new() ThreadSuspendGate
    + fn signal() void
    + fn wait(should_wait: fn()(bool)!, timeout_ms: uint (0)) bool
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
    ~ each_slice: ?Slice[T]
    ~ length: uint
    ~ size: uint

    + fn append(item: T, unique: bool (false)) Array[T]
    + fn append_many(items: Array[T]) Array[T]
    + fn clear(reduce_size: bool (false)) Array[T]
    + fn compose_json(str: StringComposer, pretty: bool, depth: uint) void
    + fn contains(value: T) bool
    + fn copy() Array[T]
    + fn equal(array: Array[T]) bool
    + fn equal_ignore_order(array: Array[T]) bool
    + fn filter(func: ?fn(T)(bool)! (null)) Array[T]
    + fn fit_index(index: uint) void
    + fn get(index: uint) T !core:LookupError
    + fn increase_size(new_size: uint) GcPtr
    + fn index_of(item: T) uint !core:LookupError
    + fn intersect(with: Array[T]) Array[T]
    + fn iter() Slice[T]
    + fn lock() void
    + fn merge(items: Array[T]) Array[T]
    + static fn new(start_size: uint (2)) Array[T]
    + fn part(start: uint, amount: uint) Array[T]
    + fn pop_first() T !core:LookupError
    + fn pop_last() T !core:LookupError
    + fn prepend(item: T, unique: bool (false)) Array[T]
    + fn prepend_many(items: Array[T]) Array[T]
    + fn range(start: uint, end: uint, inclusive: bool (true)) Array[T]
    + fn remove(index: uint) Array[T]
    + fn remove_value(value: T) Array[T]
    + fn reverse() Array[T]
    + fn set(index: uint, value: T) void !core:LookupError
    + fn set_all(value: T) void
    + fn set_expand(index: uint, value: T, filler_value: T) void
    + fn slice(start: uint, amount: uint) Slice[T]
    + fn sort(func: ?fn(T, T)(bool)! (null)) Array[T]
    + fn swap(index_a: uint, index_b: uint) void
    + fn to_json_value() Value
    + fn unique() Array[T]
    + fn unlock() void
}
```

```js
+ class ByteBuffer {
    ~ data: GcPtr
    ~ length: uint
    ~ size: uint

    + fn append(buffer: ByteBuffer, start_index: uint (0)) void
    + fn append_byte(byte: u8) void
    + fn append_f64(value: f64, decimals: uint (2), trim_zeros: bool (false)) ByteBuffer
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
    + fn index_of(byte: u8, start_index: uint (0)) uint !core:LookupError
    + fn index_where_byte_is_not(byte: u8, start_index: uint (0)) uint !core:LookupError
    + fn ltrim(filter: fnptr(u8)(bool)!) void
    + fn minimum_free_space(length: uint) void
    + fn minimum_size(minimum_size: uint) void
    + static fn new(start_size: uint (128)) ByteBuffer
    + fn part(start_index: uint, length: uint) String
    + fn reduce_size(size: uint) void
    + fn rtrim(filter: fnptr(u8)(bool)!) void
    + fn set(index: uint, v: u8) void
    + fn starts_with(str: String, offset: uint) bool
    + fn str_ref(offset: uint, length: uint) ByteBufferStrRef
    + fn to_string() String
    + fn trim(filter: fnptr(u8)(bool)!) void
}
```

```js
+ class FlatMap[K, T] {
    + fn clear() FlatMap[K, T]
    + fn copy() FlatMap[K, T]
    + fn get(key: K) T !core:LookupError
    + fn has(key: K) bool
    + fn has_value(value: T) bool
    + fn keys() Array[K]
    + fn length() uint
    + fn merge(map: FlatMap[K, T]) FlatMap[K, T]
    + static fn new() FlatMap[K, T]
    + fn remove(key: K) FlatMap[K, T]
    + fn set(key: K, value: T) FlatMap[K, T]
    + fn set_many(map: FlatMap[K, T]) FlatMap[K, T]
    + fn set_unique(key: K, value: T) void !core:LookupError
    + fn sort_keys() FlatMap[K, T]
    + fn values() Array[T]
}
```

```js
+ class HashMap[K, T] {
    + fn clear() HashMap[K, T]
    + fn copy() HashMap[K, T]
    + fn get(key: K) T !core:LookupError
    + fn has(key: K) bool
    + fn has_value(value: T) bool
    + fn keys() Array[K]
    + fn length() uint
    + fn lock() void
    + fn merge(map: HashMap[K, T]) HashMap[K, T]
    + static fn new() HashMap[K, T]
    + fn remove(key: K) HashMap[K, T]
    + fn set(key: K, value: T) HashMap[K, T]
    + fn set_unique(key: K, value: T) HashMap[K, T]
    + fn sort_keys() HashMap[K, T]
    + fn unlock() void
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
    + fn get() T !core:LookupError
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
    + fn hex_to_int() int !core:SyntaxError
    + fn hex_to_uint() uint !core:SyntaxError
    + fn index_of(part: String, start_index: uint (0)) uint !core:LookupError
    + fn index_of_byte(byte: u8, start_index: uint (0)) uint !core:LookupError
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
    + fn octal_to_int() int !core:SyntaxError
    + fn octal_to_uint() uint !core:SyntaxError
    + fn pad_left(char: u8, length: uint) String
    + fn pad_right(char: u8, length: uint) String
    + fn part(start_index: uint, length: uint) String
    + fn range(start: uint, end: uint, inclusive: bool (true)) String
    + fn replace(part: String, with: String) String
    + fn rtrim(part: String, limit: uint (0)) String
    + fn split(on: String) Array[String]
    + fn starts_with(part: String) bool
    + fn to_float() f64 !core:SyntaxError
    + fn to_int() int !core:SyntaxError
    + fn to_json_value() Value
    + fn to_uint() uint !core:SyntaxError
    + fn trim(part: String, limit: uint (0)) String
    + fn unescape() String
    + fn upper() String
}
```

```js
+ class StringComposer {
    + fn append(buffer: StringComposer) StringComposer
    + fn append_byte(byte: u8) StringComposer
    + fn append_f64(value: f64, decimals: uint (2), trim_zeros: bool (false)) StringComposer
    + fn append_from_ptr(data: ptr, length: uint) StringComposer
    + fn append_int(value: int) StringComposer
    + fn append_str(str: String) StringComposer
    + fn append_str_json_escaped(add: String) StringComposer
    + fn append_uint(value: uint) StringComposer
    + fn clear() void
    + static fn new(start_size: uint (256)) StringComposer
    + fn to_string() String
}
```

```js
+ class bool {
}
```

```js
+ class cstring {
    + fn get(index: uint) u8
    + fn index_of(find: u8) uint !core:LookupError
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
    + static fn read_big_endian(from: ptr[u8 x 2]) i16
    + static fn read_little_endian(from: ptr[u8 x 2]) i16
    + fn round_down(modulo: i16) i16
    + fn round_up(modulo: i16) i16
    + fn to_base(base: i16) String
    + fn to_base_to_ptr(base: i16, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_str() String
    + static fn write_big_endian(v: i16, to: ptr[u8 x 2]) void
    + static fn write_little_endian(v: i16, to: ptr[u8 x 2]) void
}
```

```js
+ class i32 {
    + fn character_length(base: i32) uint
    + fn equals_str(str: String) bool
    + fn print(base: i32) void
    + static fn random() i32
    + static fn read_big_endian(from: ptr[u8 x 4]) i32
    + static fn read_little_endian(from: ptr[u8 x 4]) i32
    + fn round_down(modulo: i32) i32
    + fn round_up(modulo: i32) i32
    + fn to_base(base: i32) String
    + fn to_base_to_ptr(base: i32, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_str() String
    + static fn write_big_endian(v: i32, to: ptr[u8 x 4]) void
    + static fn write_little_endian(v: i32, to: ptr[u8 x 4]) void
}
```

```js
+ class i64 {
    + fn character_length(base: i64) uint
    + fn equals_str(str: String) bool
    + fn print(base: i64) void
    + static fn random() i64
    + static fn read_big_endian(from: ptr[u8 x 8]) i64
    + static fn read_little_endian(from: ptr[u8 x 8]) i64
    + fn round_down(modulo: i64) i64
    + fn round_up(modulo: i64) i64
    + fn to_base(base: i64) String
    + fn to_base_to_ptr(base: i64, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_str() String
    + static fn write_big_endian(v: i64, to: ptr[u8 x 8]) void
    + static fn write_little_endian(v: i64, to: ptr[u8 x 8]) void
}
```

```js
+ class i8 {
    + fn character_length(base: i8) uint
    + fn equals_str(str: String) bool
    + fn print(base: i8) void
    + static fn random() i8
    + static fn read_big_endian(from: ptru8) i8
    + static fn read_little_endian(from: ptru8) i8
    + fn round_down(modulo: i8) i8
    + fn round_up(modulo: i8) i8
    + fn to_base(base: i8) String
    + fn to_base_to_ptr(base: i8, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_str() String
    + static fn write_big_endian(v: i8, to: ptru8) void
    + static fn write_little_endian(v: i8, to: ptru8) void
}
```

```js
+ class int {
    + fn character_length(base: int) uint
    + fn equals_str(str: String) bool
    + fn print(base: int) void
    + static fn random() int
    + static fn read_big_endian(from: ptr[u8 x 8]) int
    + static fn read_little_endian(from: ptr[u8 x 8]) int
    + fn round_down(modulo: int) int
    + fn round_up(modulo: int) int
    + fn to_base(base: int) String
    + fn to_base_to_ptr(base: int, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_str() String
    + static fn write_big_endian(v: int, to: ptr[u8 x 8]) void
    + static fn write_little_endian(v: int, to: ptr[u8 x 8]) void
}
```

```js
+ class ptr {
    + fn index_of_byte(byte: u8, memory_size: uint) uint !core:LookupError
    + fn print_bytes(length: uint, end_with_newline: bool (true)) void
    + fn to_hex() String
}
```

```js
+ class u16 {
    + fn character_length(base: u16) uint
    + fn equals_str(str: String) bool
    + fn print(base: u16) void
    + static fn random() u16
    + static fn read_big_endian(from: ptr[u8 x 2]) u16
    + static fn read_little_endian(from: ptr[u8 x 2]) u16
    + fn round_down(modulo: u16) u16
    + fn round_up(modulo: u16) u16
    + fn to_base(base: u16) String
    + fn to_base_to_ptr(base: u16, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_str() String
    + static fn write_big_endian(v: u16, to: ptr[u8 x 2]) void
    + static fn write_little_endian(v: u16, to: ptr[u8 x 2]) void
}
```

```js
+ class u32 {
    + fn character_length(base: u32) uint
    + fn equals_str(str: String) bool
    + fn print(base: u32) void
    + static fn random() u32
    + static fn read_big_endian(from: ptr[u8 x 4]) u32
    + static fn read_little_endian(from: ptr[u8 x 4]) u32
    + fn round_down(modulo: u32) u32
    + fn round_up(modulo: u32) u32
    + fn to_base(base: u32) String
    + fn to_base_to_ptr(base: u32, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_str() String
    + static fn write_big_endian(v: u32, to: ptr[u8 x 4]) void
    + static fn write_little_endian(v: u32, to: ptr[u8 x 4]) void
}
```

```js
+ class u64 {
    + fn character_length(base: u64) uint
    + fn equals_str(str: String) bool
    + fn print(base: u64) void
    + static fn random() u64
    + static fn read_big_endian(from: ptr[u8 x 8]) u64
    + static fn read_little_endian(from: ptr[u8 x 8]) u64
    + fn round_down(modulo: u64) u64
    + fn round_up(modulo: u64) u64
    + fn to_base(base: u64) String
    + fn to_base_to_ptr(base: u64, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_str() String
    + static fn write_big_endian(v: u64, to: ptr[u8 x 8]) void
    + static fn write_little_endian(v: u64, to: ptr[u8 x 8]) void
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
    + static fn read_big_endian(from: ptru8) u8
    + static fn read_little_endian(from: ptru8) u8
    + fn round_down(modulo: u8) u8
    + fn round_up(modulo: u8) u8
    + fn to_ascii_string() String
    + fn to_base(base: u8) String
    + fn to_base_to_ptr(base: u8, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_str() String
    + fn unescape() u8
    + static fn write_big_endian(v: u8, to: ptru8) void
    + static fn write_little_endian(v: u8, to: ptru8) void
}
```

```js
+ class uint {
    + fn character_length(base: uint) uint
    + fn equals_str(str: String) bool
    + fn print(base: uint) void
    + static fn random() uint
    + static fn read_big_endian(from: ptr[u8 x 8]) uint
    + static fn read_little_endian(from: ptr[u8 x 8]) uint
    + fn round_down(modulo: uint) uint
    + fn round_up(modulo: uint) uint
    + fn to_base(base: uint) String
    + fn to_base_to_ptr(base: uint, result: ptr, lowercase: bool (false)) uint
    + fn to_hex() String
    + fn to_str() String
    + static fn write_big_endian(v: uint, to: ptr[u8 x 8]) void
    + static fn write_little_endian(v: uint, to: ptr[u8 x 8]) void
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

