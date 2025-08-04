
# Documentation

Namespaces: [core](#core) | [gc](#gc) | [io](#io) |  | [mem](#mem) | [ansi](#ansi) | [coro](#coro) | [fs](#fs) | [http](#http) | [json](#json) | [net](#net) | [thread](#thread) | [time](#time) | [utils](#utils) | [url](#url)

---

# core

## Functions for 'core'

```js
+ fn libc_errno() type:i32
+ fn socket_errno() type:i32
+ fn signal_ignore(sig: type:int) void
+ fn exec(cmd: type:String, stream_output: type:bool (false)) (type:i32, type:String)
+ fn exit(code: type:i32) void
+ fn panic(msg: type:String) void
+ fn raise(code: type:i32) void
+ fn getenv(var: type:String) type:String
```

## Globals for 'core'

```js
~ global core:error_code : type:u32
~ global core:error_msg : type:String
```

# gc

## Functions for 'gc'

```js
+ fn collect() void
+ fn lock() void
+ fn unlock() void
+ fn collect_if_threshold_reached() void
+ fn collect_shared_if_threshold_reached() void
+ fn alloc(size: type:uint) gc:GcPtr
+ fn collect_shared() void
```

## Globals for 'gc'

```js
~ global gc:mem_usage_thread : type:uint
~ shared gc:mem_usage_shared : type:uint
~ shared gc:mem_usage_peak : type:uint
```

# io

## Functions for 'io'

```js
+ fn valk_fd(fd: type:int) type:int
+ fn os_fd(fd: type:int) type:i32
+ fn write(fd: type:int, str: type:String) void
+ fn write_bytes(fd: type:int, data: type:ptr, length: type:uint) type:uint
+ fn read(fd: type:int, buffer: type:ptr, buffer_size: type:uint) type:uint
+ fn set_non_block(fd: type:int, value: type:bool) void
+ fn close(fd: type:int) void
+ fn println(msg: type:String) void
+ fn print(msg: type:String) void
+ fn print_from_ptr(adr: type:ptr, len: type:uint) void
```

# mem

## Functions for 'mem'

```js
+ fn alloc(size: type:uint) type:ptr
+ fn free(adr: type:ptr) void
+ fn calloc(size: type:uint) type:ptr
+ fn copy(from: type:ptr, to: type:ptr, length: type:uint) void
+ fn clear(adr: type:ptr, length: type:uint) void
+ fn equal(a: type:ptr, b: type:ptr, length: type:uint) type:bool
+ fn ascii_bytes_to_lower(adr: type:ptr, len: type:uint) void
+ fn bytes_to_uint(adr: type:ptr, len: type:uint) type:uint
+ fn find_char(adr: type:ptr, ch: type:u8, length: type:uint) type:uint
```

# ansi

## Functions for 'ansi'

```js
+ fn supported() type:bool
```

# coro

## Functions for 'coro'

```js
+ fn await_fd(fd: type:int, read: type:bool, write: type:bool) coro:PollEvent
+ fn yield() void
+ fn await_coro(coro: coro:Coro) void
+ fn throw(code: type:u32, msg: type:String) void
```

# fs

## Functions for 'fs'

```js
+ fn open(path: type:String, writable: type:bool, append_on_write: type:bool) type:int
+ fn open_extend(path: type:String, writable: type:bool, append_on_write: type:bool, create_file_if_doesnt_exist: type:bool (false), create_file_permissions: type:u32 (420)) type:int
+ fn size(path: type:String) type:uint
+ fn sync() void
+ fn read_bytes(path: type:String, buffer: utils:ByteBuffer (/)) utils:ByteBuffer
+ fn read(path: type:String) type:String
+ fn write(path: type:String, content: type:String, append: type:bool (false)) void
+ fn write_bytes(path: type:String, data: type:ptr, size: type:uint, append: type:bool (false)) void
+ fn exists(path: type:String) type:bool
+ fn delete(path: type:String) void
+ fn delete_recursive(path: type:String) void
+ fn move(from_path: type:String, to_path: type:String) void
+ fn copy(from_path: type:String, to_path: type:String, recursive: type:bool (false)) void
+ fn mkdir(path: type:String, permissions: type:u32 (493)) void
+ fn rmdir(path: type:String) void
+ fn is_file(path: type:String) type:bool
+ fn is_dir(path: type:String) type:bool
+ fn files_in(dir: type:String, recursive: type:bool (false), files: type:bool (true), dirs: type:bool (true), prefix: ?type:String (null), result: type:Array[type:String] (/)) type:Array[type:String]
+ fn symlink(link: type:String, target: type:String, is_directory: type:bool) void
+ fn mime(ext_without_dot: type:String) type:String
+ fn path(path: type:String) fs:Path
+ fn resolve(path: type:String) type:String
+ fn add(dir: type:String, fn: type:String) type:String
+ fn cwd() type:String
+ fn chdir(path: type:String) void
+ fn exe_dir() type:String
+ fn exe_path() type:String
+ fn realpath(path: type:String) type:String
+ fn ext(path: type:String, with_dot: type:bool (false)) type:String
+ fn dir_of(path: type:String) type:String
+ fn basename(path: type:String) type:String
+ fn home_dir() type:String
+ fn stream(path: type:String, read: type:bool, write: type:bool, append: type:bool (false), auto_create: type:bool (false)) fs:FileStream
```

## Classes for 'fs'

```js
+ class Path {
    ~ bytes: type:uint

    + fn length() type:uint
    + fn data() type:ptr[type:u8]
    + fn data_cstring() type:cstring
    + fn starts_with(part: type:String) type:bool
    + fn ends_with(part: type:String) type:bool
    + fn is_empty() type:bool
    + fn to_uint() type:uint
    + fn to_int() type:int
    + fn hex_to_uint() type:uint
    + fn hex_to_int() type:int
    + fn octal_to_uint() type:uint
    + fn octal_to_int() type:int
    + fn to_float() type:f64
    + fn lower() type:String
    + fn upper() type:String
    + fn is_alpha(allow_extra_bytes: type:String ("")) type:bool
    + fn is_alpha_numeric(allow_extra_bytes: type:String ("")) type:bool
    + fn is_integer() type:bool
    + fn is_number() type:bool
    + fn add(part: type:String) fs:Path
    + fn make_empty(length: type:uint) type:String
    + fn make_from_ptr(data: type:ptr, length: type:uint) type:String
    + fn index_of(part: type:String, start_index: type:uint (0)) type:uint
    + fn index_of_byte(byte: type:u8, start_index: type:uint (0)) type:uint
    + fn contains(part: type:String) type:bool
    + fn contains_byte(byte: type:u8) type:bool
    + fn get(index: type:uint) type:u8
    + fn range(start: type:uint, end: type:uint, inclusive: type:bool (true)) type:String
    + fn part(start_index: type:uint, length: type:uint) type:String
    + fn split(on: type:String) type:Array[type:String]
    + fn trim(part: type:String, limit: type:uint (0)) type:String
    + fn rtrim(part: type:String, limit: type:uint (0)) type:String
    + fn ltrim(part: type:String, limit: type:uint (0)) type:String
    + fn replace(part: type:String, with: type:String) type:String
    + fn escape() type:String
    + fn unescape() type:String
    + fn to_json_value() json:Value
    + fn from_json_value(val: json:Value) type:String
    + fn new(path: type:String) fs:Path
    + fn pop() fs:Path
    + fn resolve() fs:Path
}
```

```js
+ class FileStream {
    ~ path: type:String
    ~ reading: type:bool

    + fn read(bytes: type:uint (10240)) type:String
    + fn write_bytes(from: type:ptr, len: type:uint) void
    + fn close() void
}
```

```js
+ class InMemoryFile {
    ~ data: type:ptr
    ~ size: type:uint

    + fn create_from_ptr(data: type:ptr, size: type:uint) fs:InMemoryFile
    + fn save(path: type:String) void
}
```

# http

## Functions for 'http'

```js
+ fn create_request(method: type:String, url: type:String, options: ?http:Options (null)) http:ClientRequest
+ fn request(method: type:String, url: type:String, options: ?http:Options (null)) http:ClientResponse
+ fn download(url: type:String, to_path: type:String, method: type:String ("GET"), options: ?http:Options (null)) void
```

# json

## Functions for 'json'

```js
+ fn decode(json: type:String) json:Value
+ fn null_value() json:Value
+ fn bool_value(value: type:bool) json:Value
+ fn int_value(value: type:int) json:Value
+ fn uint_value(value: type:uint) json:Value
+ fn float_value(value: type:float) json:Value
+ fn string_value(text: type:String) json:Value
+ fn array_value(values: ?type:Array[json:Value] (null)) json:Value
+ fn object_value(values: ?type:Map[json:Value] (null)) json:Value
+ fn encode_value(json: json:Value, pretty: type:bool (false)) type:String
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

    + fn new(host: type:String, port: type:u16) net:AddrInfo
    + fn sock_addr() libc_gen_sockaddr
    + fn addr_len() type:u32
}
```

# thread

## Functions for 'thread'

```js
+ fn sleep_ns(ns: type:uint) void
+ fn sleep_ms(ms: type:uint) void
+ fn start(func: fn()()) thread:Thread
```

# time

## Functions for 'time'

```js
+ fn sleep_ns(ns: type:uint) void
+ fn sleep_ms(ms: type:uint) void
+ fn microtime() type:uint
+ fn mstime() type:uint
```

# utils

## Classes for 'utils'

```js
+ class ByteBuffer {
    ~ data: type:ptr
    ~ size: type:uint
    ~ length: type:uint

    + fn new(start_size: type:uint (128)) utils:ByteBuffer
    + fn clone() utils:ByteBuffer
    + fn clear() void
    + fn clear_until(index: type:uint) void
    + fn clear_part(index: type:uint, len: type:uint) void
    + fn get(index: type:uint) type:u8
    + fn append(buffer: utils:ByteBuffer, start_index: type:uint (0)) void
    + fn append_from_ptr(data: type:ptr, length: type:uint) void
    + fn append_byte(byte: type:u8) void
    + fn append_str(str: type:String) void
    + fn append_uint(value: type:uint) void
    + fn append_int(value: type:int) void
    + fn equals_str(str: type:String) type:bool
    + fn starts_with(str: type:String, offset: type:uint) type:bool
    + fn index_of_byte(byte: type:u8, start_index: type:uint (0)) type:uint
    + fn index_where_byte_is_not(byte: type:u8, start_index: type:uint (0)) type:uint
    + fn to_string() type:String
    + fn part(start_index: type:uint, length: type:uint) type:String
    + fn str_ref(offset: type:uint, length: type:uint) utils:ByteBufferStrRef
    + fn minimum_free_space(length: type:uint) void
    + fn minimum_size(minimum_size: type:uint) void
    + fn reduce_size(size: type:uint) void
}
```

# url

## Functions for 'url'

```js
+ fn parse(str: type:String) url:Url
+ fn encode(str: type:String) type:String
+ fn decode(str: type:String) type:String
```

