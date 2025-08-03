
# Documentation

Namespaces: [core](#core) | [gc](#gc) | [io](#io) |  | [mem](#mem) | [ansi](#ansi) | [coro](#coro) | [fs](#fs) | [http](#http) | [json](#json) | [net](#net) | [thread](#thread) | [time](#time) | [utils](#utils) | [url](#url)

---

# core

## Functions for 'core'

```js
+ core:libc_errno() type:i32
+ core:socket_errno() type:i32
+ core:signal_ignore(sig: type:int) void
+ core:exec(cmd: type:String, stream_output: type:bool (false)) (type:i32, type:String)
+ core:exit(code: type:i32) void
+ core:panic(msg: type:String) void
+ core:raise(code: type:i32) void
+ core:getenv(var: type:String) type:String
```

## Globals for 'core'

```js
~ global core:error_code : type:u32
~ global core:error_msg : type:String
```

# gc

## Functions for 'gc'

```js
+ gc:collect() void
+ gc:lock() void
+ gc:unlock() void
+ gc:collect_if_threshold_reached() void
+ gc:collect_shared_if_threshold_reached() void
+ gc:alloc(size: type:uint) gc:GcPtr
+ gc:collect_shared() void
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
+ io:valk_fd(fd: type:int) type:int
+ io:os_fd(fd: type:int) type:i32
+ io:write(fd: type:int, str: type:String) void
+ io:write_bytes(fd: type:int, data: type:ptr, length: type:uint) type:uint
+ io:read(fd: type:int, buffer: type:ptr, buffer_size: type:uint) type:uint
+ io:fd_set_non_block(fd: type:int, value: type:bool) void
+ io:close(fd: type:int) void
+ io:println(msg: type:String) void
+ io:print(msg: type:String) void
+ io:print_from_ptr(adr: type:ptr, len: type:uint) void
```

# mem

## Functions for 'mem'

```js
+ mem:alloc(size: type:uint) type:ptr
+ mem:free(adr: type:ptr) void
+ mem:calloc(size: type:uint) type:ptr
+ mem:copy(from: type:ptr, to: type:ptr, length: type:uint) void
+ mem:clear(adr: type:ptr, length: type:uint) void
+ mem:equal(a: type:ptr, b: type:ptr, length: type:uint) type:bool
+ mem:ascii_bytes_to_lower(adr: type:ptr, len: type:uint) void
+ mem:bytes_to_uint(adr: type:ptr, len: type:uint) type:uint
+ mem:find_char(adr: type:ptr, ch: type:u8, length: type:uint) type:uint
+ mem:find_char_(adr: type:ptr, ch: type:u8, length: type:uint) type:uint
```

# ansi

## Functions for 'ansi'

```js
+ ansi:supported() type:bool
```

# coro

## Functions for 'coro'

```js
+ coro:await_fd(fd: type:int, read: type:bool, write: type:bool) coro:PollEvent
+ coro:yield() void
+ coro:await_coro(coro: coro:Coro) void
+ coro:throw(code: type:u32, msg: type:String) void
```

# fs

## Functions for 'fs'

```js
+ fs:open(path: type:String, writable: type:bool, append_on_write: type:bool) type:int
+ fs:open_extend(path: type:String, writable: type:bool, append_on_write: type:bool, create_file_if_doesnt_exist: type:bool (false), create_file_permissions: type:u32 (420)) type:int
+ fs:size(path: type:String) type:uint
+ fs:sync() void
+ fs:read_bytes(path: type:String, buffer: utils:ByteBuffer (/)) utils:ByteBuffer
+ fs:read(path: type:String) type:String
+ fs:write(path: type:String, content: type:String, append: type:bool (false)) void
+ fs:write_bytes(path: type:String, data: type:ptr, size: type:uint, append: type:bool (false)) void
+ fs:exists(path: type:String) type:bool
+ fs:delete(path: type:String) void
+ fs:delete_recursive(path: type:String) void
+ fs:move(from_path: type:String, to_path: type:String) void
+ fs:copy(from_path: type:String, to_path: type:String, recursive: type:bool (false)) void
+ fs:mkdir(path: type:String, permissions: type:u32 (493)) void
+ fs:rmdir(path: type:String) void
+ fs:is_file(path: type:String) type:bool
+ fs:is_dir(path: type:String) type:bool
+ fs:files_in(dir: type:String, recursive: type:bool (false), files: type:bool (true), dirs: type:bool (true), prefix: ?type:String (null), result: type:Array[type:String] (/)) type:Array[type:String]
+ fs:symlink(link: type:String, target: type:String, is_directory: type:bool) void
+ fs:mime(ext_without_dot: type:String) type:String
+ fs:path(path: type:String) fs:Path
+ fs:resolve(path: type:String) type:String
+ fs:add(dir: type:String, fn: type:String) type:String
+ fs:cwd() type:String
+ fs:chdir(path: type:String) void
+ fs:exe_dir() type:String
+ fs:exe_path() type:String
+ fs:realpath(path: type:String) type:String
+ fs:ext(path: type:String, with_dot: type:bool (false)) type:String
+ fs:dir_of(path: type:String) type:String
+ fs:basename(path: type:String) type:String
+ fs:home_dir() type:String
+ fs:stream(path: type:String, read: type:bool, write: type:bool, append: type:bool (false), auto_create: type:bool (false)) fs:FileStream
```

## Classes for 'fs'

```js
+ fs:Path {
    ~ bytes: type:uint
    + length() type:uint
    + data() type:ptr[type:u8]
    + data_cstring() type:cstring
    + starts_with(part: type:String) type:bool
    + ends_with(part: type:String) type:bool
    + is_empty() type:bool
    + to_uint() type:uint
    + to_int() type:int
    + hex_to_uint() type:uint
    + hex_to_int() type:int
    + octal_to_uint() type:uint
    + octal_to_int() type:int
    + to_float() type:f64
    + lower() type:String
    + upper() type:String
    + is_alpha(allow_extra_bytes: type:String ("")) type:bool
    + is_alpha_numeric(allow_extra_bytes: type:String ("")) type:bool
    + is_integer() type:bool
    + is_number() type:bool
    + add(part: type:String) fs:Path
    + make_empty(length: type:uint) type:String
    + make_from_ptr(data: type:ptr, length: type:uint) type:String
    + index_of(part: type:String, start_index: type:uint (0)) type:uint
    + index_of_byte(byte: type:u8, start_index: type:uint (0)) type:uint
    + contains(part: type:String) type:bool
    + contains_byte(byte: type:u8) type:bool
    + get(index: type:uint) type:u8
    + range(start: type:uint, end: type:uint, inclusive: type:bool (true)) type:String
    + part(start_index: type:uint, length: type:uint) type:String
    + split(on: type:String) type:Array[type:String]
    + trim(part: type:String, limit: type:uint (0)) type:String
    + rtrim(part: type:String, limit: type:uint (0)) type:String
    + ltrim(part: type:String, limit: type:uint (0)) type:String
    + replace(part: type:String, with: type:String) type:String
    + escape() type:String
    + unescape() type:String
    + to_json_value() json:Value
    + from_json_value(val: json:Value) type:String
    + new(path: type:String) fs:Path
    + pop() fs:Path
    + resolve() fs:Path
}
```

```js
+ fs:FileStream {
    ~ path: type:String
    ~ reading: type:bool
    + read(bytes: type:uint (10240)) type:String
    + write_bytes(from: type:ptr, len: type:uint) void
    + close() void
}
```

```js
+ fs:InMemoryFile {
    ~ data: type:ptr
    ~ size: type:uint
    + create_from_ptr(data: type:ptr, size: type:uint) fs:InMemoryFile
    + save(path: type:String) void
}
```

# http

## Functions for 'http'

```js
+ http:create_request(method: type:String, url: type:String, options: ?http:Options (null)) http:ClientRequest
+ http:request(method: type:String, url: type:String, options: ?http:Options (null)) http:ClientResponse
+ http:download(url: type:String, to_path: type:String, method: type:String ("GET"), options: ?http:Options (null)) void
```

# json

## Functions for 'json'

```js
+ json:decode(json: type:String) json:Value
+ json:null_value() json:Value
+ json:bool_value(value: type:bool) json:Value
+ json:int_value(value: type:int) json:Value
+ json:uint_value(value: type:uint) json:Value
+ json:float_value(value: type:float) json:Value
+ json:string_value(text: type:String) json:Value
+ json:array_value(values: ?type:Array[json:Value] (null)) json:Value
+ json:object_value(values: ?type:Map[json:Value] (null)) json:Value
+ json:encode_value(json: json:Value, pretty: type:bool (false)) type:String
```

# net

## Functions for 'net'

```js
+ net:set_ca_cert_path(path: ?type:String) void
```

## Classes for 'net'

```js
+ net:AddrInfo {
    ~ data: libc_gen_addrinfo
    + new(host: type:String, port: type:u16) net:AddrInfo
    + sock_addr() libc_gen_sockaddr
    + addr_len() type:u32
}
```

# thread

## Functions for 'thread'

```js
+ thread:sleep_ns(ns: type:uint) void
+ thread:sleep_ms(ms: type:uint) void
+ thread:start(func: fn()()) thread:Thread
```

# time

## Functions for 'time'

```js
+ time:sleep_ns(ns: type:uint) void
+ time:sleep_ms(ms: type:uint) void
+ time:microtime() type:uint
+ time:mstime() type:uint
```

# utils

## Classes for 'utils'

```js
+ utils:ByteBuffer {
    ~ data: type:ptr
    ~ size: type:uint
    ~ length: type:uint
    + new(start_size: type:uint (128)) utils:ByteBuffer
    + clone() utils:ByteBuffer
    + clear() void
    + clear_until(index: type:uint) void
    + clear_part(index: type:uint, len: type:uint) void
    + get(index: type:uint) type:u8
    + append(buffer: utils:ByteBuffer, start_index: type:uint (0)) void
    + append_from_ptr(data: type:ptr, length: type:uint) void
    + append_byte(byte: type:u8) void
    + append_str(str: type:String) void
    + append_uint(value: type:uint) void
    + append_int(value: type:int) void
    + equals_str(str: type:String) type:bool
    + starts_with(str: type:String, offset: type:uint) type:bool
    + index_of_byte(byte: type:u8, start_index: type:uint (0)) type:uint
    + index_where_byte_is_not(byte: type:u8, start_index: type:uint (0)) type:uint
    + to_string() type:String
    + part(start_index: type:uint, length: type:uint) type:String
    + str_ref(offset: type:uint, length: type:uint) utils:ByteBufferStrRef
    + minimum_free_space(length: type:uint) void
    + minimum_size(minimum_size: type:uint) void
    + reduce_size(size: type:uint) void
}
```

# url

## Functions for 'url'

```js
+ url:parse(str: type:String) url:Url
+ url:encode(str: type:String) type:String
+ url:decode(str: type:String) type:String
```

