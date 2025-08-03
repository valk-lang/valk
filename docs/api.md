
# Documentation

Namespaces: [main](#main) | [core](#core) | [gc](#gc) | [io](#io) | [type](#type) | [mem](#mem) | [ansi](#ansi) | [coro](#coro) | [fs](#fs) | [http](#http) | [json](#json) | [net](#net) | [thread](#thread) | [time](#time) | [utils](#utils) | [url](#url)

---

# main

## Functions for 'main'

```js
- main:malloc(size: type:uint) type:ptr
- main:free(adr: type:ptr) type:i32
- main:exit(code: type:i32) void
- main:signal(signum: type:i32, handler: ?fnRef(type:i32)()) void
- main:raise(sig: type:i32) type:i32
- main:__errno_location() type:ptr
- main:getenv(key: type:cstring) ?type:cstring
- main:sync() void
- main:read(fd: type:i32, buf: type:ptr, size: type:uint) type:int
- main:write(fd: type:i32, data: type:ptr, length: type:uint) type:i32
- main:open(path: type:ptr, flags: type:i32) type:i32
- main:close(fd: type:i32) type:i32
- main:getcwd(buf: type:cstring, size: type:uint) ?type:cstring
- main:chdir(path: type:cstring) type:i32
- main:recv(fd: type:i32, buf: type:ptr, len: type:uint, flags: type:i32) type:int
- main:send(fd: type:i32, buf: type:ptr, len: type:uint, flags: type:i32) type:int
- main:pipe(fds: type:ptr[2 x type:i32]) type:i32
- main:fcntl(fd: type:i32, action: type:i32) type:i32
- main:socket(domain: type:i32, type: type:i32, protocol: type:i32) type:i32
- main:connect(sockfd: type:i32, addr: libc_gen_sockaddr, addrlen: type:u32) type:i32
- main:accept(sockfd: type:i32, addr: ?libc_gen_sockaddr, addrlen: ?type:ptr) type:i32
- main:accept4(sockfd: type:i32, addr: ?libc_gen_sockaddr, addrlen: ?type:ptr, flags: type:i32) type:i32
- main:shutdown(sockfd: type:i32, how: type:i32) type:i32
- main:bind(sockfd: type:i32, addr: libc_gen_sockaddr, addrlen: type:u32) type:i32
- main:listen(sockfd: type:i32, backlog: type:i32) type:i32
- main:getsockopt(sockfd: type:i32, level: type:i32, optname: type:i32, optval: type:ptr, optlen: type:u32) type:i32
- main:setsockopt(sockfd: type:i32, level: type:i32, optname: type:i32, optval: type:ptr, optlen: type:u32) type:i32
- main:getaddrinfo(host: type:ptr, port: type:ptr, hints: libc_gen_addrinfo, res: type:ptr) type:i32
- main:freeaddrinfo(info: libc_gen_addrinfo) type:i32
- main:poll(fds: type:ptr, nfds: type:u32, timeout: type:i32) type:i32
- main:epoll_create(size: type:i32) type:i32
- main:epoll_wait(epfd: type:i32, events: type:ptr, maxevents: type:i32, timeout: type:i32) type:i32
- main:epoll_ctl(epfd: type:i32, op: type:i32, fd: type:i32, event: libc_gen_epoll_event) type:i32
- main:nanosleep(req: libc_gen_timespec, rem: libc_gen_timespec) type:i32
- main:stat(path: type:cstring, stat_buf: libc_gen_stat) type:i32
- main:fstat(fd: type:i32, stat_buf: libc_gen_stat) type:i32
- main:lstat(path: type:cstring, stat_buf: libc_gen_stat) type:i32
- main:access(path: type:cstring, mode: type:i32) type:i32
- main:opendir(name: type:cstring) ?type:ptr
- main:readdir(dirp: type:ptr) ?libc_gen_dirent
- main:closedir(dirp: type:ptr) type:i32
- main:mkdir(pathname: type:cstring, mode: type:u32) type:i32
- main:rmdir(pathname: type:cstring) type:i32
- main:realpath(dir: type:ptr, buf: type:ptr) type:cstring
- main:rename(oldpath: type:cstring, newpath: type:cstring) type:i32
- main:link(oldpath: type:cstring, newpath: type:cstring) type:i32
- main:unlink(pathname: type:cstring) type:i32
- main:symlink(target: type:cstring, linkpath: type:cstring) type:i32
- main:readlink(pathname: type:cstring, buf: type:ptr, bufsiz: type:uint) type:int
- main:popen(cmd: type:cstring, type: type:cstring) ?type:ptr
- main:pclose(stream: type:ptr) type:i32
- main:fgets(buffer: type:cstring, size: type:i32, stream: type:ptr) ?type:cstring
- main:gettimeofday(tv: libc_gen_timeval, tz: ?libc_gen_timezone) type:i32
- main:settimeofday(tv: libc_gen_timeval, tz: ?libc_gen_timezone) type:i32
- main:pthread_create(thread: pthread_t, attr: ?type:ptr, entry: type:ptr, data: ?type:ptr) type:i32
- main:pthread_join(thread: type:uint, exit_value: ?type:ptr) type:i32
- main:pthread_mutex_init(mutex: type:ptr, attr: ?type:ptr) type:i32
- main:pthread_mutex_destroy(mutex: type:ptr) type:i32
- main:pthread_mutex_lock(mutex: type:ptr) type:i32
- main:pthread_mutex_unlock(mutex: type:ptr) type:i32
```

## Classes for 'main'

```js
- main:libc_gen_timespec {
    - tv_sec: type:int
    - tv_nsec: type:int
}
```

```js
- main:libc_gen_stat {
    - st_dev: type:uint
    - st_ino: type:uint
    - st_nlink: type:uint
    - st_mode: type:u32
    - st_uid: type:u32
    - st_gid: type:u32
    - __pad0: type:i32
    - st_rdev: type:uint
    - st_size: type:int
    - st_blksize: type:int
    - st_blocks: type:int
    - st_atim: <libc_gen_timespec>
    - st_mtim: <libc_gen_timespec>
    - st_ctim: <libc_gen_timespec>
    - __glibc_reserved: [3 x type:int]
}
```

```js
- main:libc_gen_anon_struct_2 {
    - __val: [16 x type:uint]
}
```

```js
- main:libc_gen___jmp_buf_tag {
    - __jmpbuf: [8 x type:int]
    - __mask_was_saved: type:i32
    - __saved_mask: <libc_gen_anon_struct_2>
}
```

```js
- main:libc_gen_dirent {
    - d_ino: type:uint
    - d_off: type:int
    - d_reclen: type:u16
    - d_type: type:u8
    - d_name: [256 x type:i8]
}
```

```js
- main:libc_gen_pollfd {
    - fd: type:i32
    - events: type:i16
    - revents: type:i16
}
```

```js
- main:libc_gen_timeval {
    - tv_sec: type:int
    - tv_usec: type:int
}
```

```js
- main:libc_gen_sockaddr {
    - sa_family: type:u16
    - sa_data: [14 x type:i8]
}
```

```js
- main:libc_gen_addrinfo {
    - ai_flags: type:i32
    - ai_family: type:i32
    - ai_socktype: type:i32
    - ai_protocol: type:i32
    - ai_addrlen: type:u32
    - ai_addr: libc_gen_sockaddr
    - ai_canonname: type:cstring
    - ai_next: libc_gen_addrinfo
}
```

```js
- main:libc_gen_timezone {
    - tz_minuteswest: type:i32
    - tz_dsttime: type:i32
}
```

```js
- main:libc_gen_epoll_data {
    - ptr: type:ptr
    - fd: type:i32
    - u32: type:u32
    - u64: type:uint
}
```

```js
- main:libc_gen_epoll_event {
    - events: type:u32
    - data: <libc_gen_epoll_data>
}
```

```js
- main:pthread_t {
    - data: type:uint
}
```

# core

## Functions for 'core'

```js
+ core:libc_errno() type:i32
+ core:socket_errno() type:i32
+ core:signal_ignore(sig: type:int) void
+ core:exec(cmd: type:String, stream_output: type:bool (false)) (type:i32, type:String)
- core:WEXITSTATUS(status: type:i32) type:i32
+ core:exit(code: type:i32) void
+ core:panic(msg: type:String) void
+ core:raise(code: type:i32) void
+ core:getenv(var: type:String) type:String
- core:submit_entry(entry: core:TestEntry) void
- core:finalize() void
- core:passed() type:bool
- core:print() void
- core:init(name: type:String, file: type:String, line: type:uint) core:TestEntry
- core:assert_panic(check: type:bool, code: type:String, file: type:String, line: type:uint) type:bool
- core:assert_test(check: type:bool, code: type:String, file: type:String, line: type:uint) type:bool
```

## Classes for 'core'

```js
+ core:TestResults {
    - entries: type:Array[core:TestEntry]
    - asserts_total: type:uint
    - asserts_passed: type:uint
    - submit_entry(entry: core:TestEntry) void
    - finalize() void
    - passed() type:bool
    - print() void
}
```

```js
+ core:TestEntry {
    - name: type:String
    - file: type:String
    - failures: type:Array[type:String]
    - line: type:uint
    - assert_count: type:uint
    - assert_passed: type:uint
    - passed: type:bool
    - init(name: type:String, file: type:String, line: type:uint) core:TestEntry
    - assert_panic(check: type:bool, code: type:String, file: type:String, line: type:uint) type:bool
    - assert_test(check: type:bool, code: type:String, file: type:String, line: type:uint) type:bool
}
```

```js
+ core:Closure {
    - data: ?gc:GcPtr
    - inner_func: type:ptr
    - outer_func: type:ptr
}
```

## Globals for 'core'

```js
~ global core:error_code : type:u32
~ global core:error_msg : type:String
- global core:cli_args : type:Array[type:String]
```

# gc

## Functions for 'gc'

```js
- gc:dump_shared(shared_list: gc:Bump) void
- gc:check_shared_dump() void
- gc:loop_all_blocks(func: fnRef(gc:Block)()) void
- gc:add_unused_block(block: gc:Block) void
- gc:get_unused_block(isize: type:uint) type:ptr
- gc:free_empty_unused_blocks() void
- gc:collect() void
- gc:lock() void
- gc:unlock() void
+ gc:collect_if_threshold_reached() void
+ gc:collect_shared_if_threshold_reached() void
+ gc:alloc(size: type:uint) gc:GcPtr
- gc:property_update(on_object: type:ptr, property_ref: type:ptr, new_value: ?type:ptr) void
- gc:property_set(on_object: type:ptr, property_ref: type:ptr, value: ?type:ptr) void
- gc:property_get(property_ref: type:ptr) type:ptr
- gc:property_remove(on_object: type:ptr, property_ref: type:ptr) void
- gc:property_mark(on_object: gc:GcItem, property_ref: type:ptr) void
- gc:property_dis_own(on_object: type:ptr, property_ref: type:ptr) void
- gc:property_share(on_object: type:ptr, property_ref: type:ptr) void
- gc:property_update_mark(on_object: type:ptr, property_ref: type:ptr) void
- gc:property_add_mark_list(on_object: type:ptr, property_ref: type:ptr) void
- gc:pools_init() void
- gc:pools_free() void
- gc:get_pool_index_for_size(size: type:uint) type:uint
- gc:get_pool_for_size(size: type:uint) gc:Pool
- gc:get_pool(i: type:uint, size: type:uint) gc:Pool
- gc:reset_pools(pools: type:ptr, poolc: type:uint) void
- gc:log_pools() void
- gc:backup_gc_stack() void
- gc:restore_gc_stack() void
- gc:increase_block(block: type:ptr) void
- gc:decrease_block(block: type:ptr) void
- gc:increase_block_of_item(item: type:ptr) void
- gc:decrease_block_of_item(item: type:ptr) void
- gc:mark_used(item: ?gc:GcItem) void
- gc:free_blank(item: type:ptr) void
- gc:dis_own_rec(item: type:ptr) void
- gc:share_null_check(item: ?type:ptr) void
- gc:share(item: gc:GcItem) void
- gc:update_mark(item: gc:GcItem) void
- gc:mark_leak_rec(item: gc:GcItem, on: type:bool) void
+ gc:collect_shared() void
- gc:update_shared_trigger() void
- gc:free_shared_item(item: gc:GcItem) void
- gc:thread_init(is_main: type:bool (false)) void
- gc:thread_stop() void
- gc:new() gc:Lifo
- gc:add(item: type:ptr) void
- gc:pop() type:ptr
- gc:clear() void
- gc:free() void
- gc:get() type:ptr
- gc:minimum_size(size: type:uint) void
- gc:reset() void
- gc:add_ptr(item: type:ptr) void
- gc:reduce_size() void
+ gc:init() gc:Gc
- gc:create_block(size: type:uint, isize: type:uint) type:ptr
- gc:get_vtable() type:ptr
- gc:set_next_block(block: type:ptr) void
- gc:set_block(block: ?type:ptr) void
- gc:to_ptr() type:ptr
- gc:item() gc:GcItem
- gc:is_marked() type:bool
- gc:set_mark() void
- gc:remove_mark() void
- gc:has_leak_mark() type:bool
- gc:set_leak_mark() void
- gc:remove_leak_mark() void
- gc:set_new() void
- gc:set_owned() void
- gc:set_no_owner() void
- gc:is_new() type:bool
- gc:is_not_new() type:bool
- gc:is_owned() type:bool
- gc:is_owned_not_shared() type:bool
- gc:is_not_owned() type:bool
- gc:is_not_owned_not_shared() type:bool
- gc:is_no_owner_not_shared() type:bool
- gc:is_shared() type:bool
- gc:set_shared() void
- gc:remove_shared() void
- gc:is_on_stack() type:bool
- gc:set_on_stack() void
- gc:remove_on_stack() void
- gc:has_vtable() type:bool
- gc:set_has_vtable() void
- gc:remove_has_vtable() void
- gc:is_still_co_owned() type:bool
- gc:set_still_co_owned() void
- gc:remove_still_co_owned() void
- gc:is_in_updates() type:bool
- gc:set_in_updates() void
- gc:remove_in_updates() void
- gc:is_in_blanks() type:bool
- gc:set_in_blanks() void
- gc:remove_in_blanks() void
- gc:co_own() void
- gc:dis_co_own() void
- gc:leak_check() void
- gc:mark_stack_item(item: type:ptr) void
- gc:loop_previous_stack_items() void
- gc:loop_dis_own() void
- gc:loop_re_own() void
- gc:loop_updates() void
- gc:check_blanks() void
- gc:loop_stack_items(func: fnRef(type:ptr)()) void
- gc:clear_stack_items() void
- gc:collect_stack_item(item: type:ptr) void
- gc:collect_stack_items() void
- gc:mark_shared_items() void
- gc:update_marks() void
- gc:clear_shared() void
+ gc:shutdown() void
```

## Classes for 'gc'

```js
- gc:Block {
    - next: ?type:ptr
    - size: type:uint
    - used: type:uint
    - used_percent: type:uint
    - isize: type:uint
}
```

```js
+ gc:PtrRing {
    - data: type:ptr
    - slots: type:uint
    - head: type:uint
    - tail: type:uint
    - new() gc:PtrRing
    - add(item: type:ptr) void
    - pop() type:ptr
    - clear() void
    - free() void
}
```

```js
- gc:Bump {
    - data: type:ptr
    - size: type:uint
    - index: type:uint
    - new(size: type:uint (1000)) gc:Bump
    - get(isize: type:uint) type:ptr
    - minimum_size(size: type:uint) void
    - reset() void
    - free() void
    - add_ptr(item: type:ptr) void
    - reduce_size() void
    - loop_items() void
}
```

```js
- gc:Pool {
    - blockc: type:uint
    - first: type:ptr
    - block: type:ptr
    - item: type:ptr
    - last: type:ptr
    - isize: type:uint
    + init(size: type:uint) gc:Pool
    - free() void
    - create_block(size: type:uint, isize: type:uint) type:ptr
    - get_vtable() type:ptr
    - get() type:ptr
    - set_next_block(block: type:ptr) void
    - set_block(block: ?type:ptr) void
    - reset() void
}
```

```js
+ gc:GcPtr {
    - data: type:uint
    - to_ptr() type:ptr
}
```

```js
- gc:GcData {
    - co_count: type:u32
    - flags: type:u8
    - propc: type:u8
    - block_offset: type:u16
    - vtable: type:ptr
    - item() gc:GcItem
    - is_marked() type:bool
    - set_mark() void
    - remove_mark() void
    - has_leak_mark() type:bool
    - set_leak_mark() void
    - remove_leak_mark() void
    - set_new() void
    - set_owned() void
    - set_no_owner() void
    - is_new() type:bool
    - is_not_new() type:bool
    - is_owned() type:bool
    - is_owned_not_shared() type:bool
    - is_not_owned() type:bool
    - is_not_owned_not_shared() type:bool
    - is_no_owner_not_shared() type:bool
    - is_shared() type:bool
    - set_shared() void
    - remove_shared() void
    - is_on_stack() type:bool
    - set_on_stack() void
    - remove_on_stack() void
    - has_vtable() type:bool
    - set_has_vtable() void
    - remove_has_vtable() void
    - is_still_co_owned() type:bool
    - set_still_co_owned() void
    - remove_still_co_owned() void
    - is_in_updates() type:bool
    - set_in_updates() void
    - remove_in_updates() void
    - is_in_blanks() type:bool
    - set_in_blanks() void
    - remove_in_blanks() void
    - co_own() void
    - dis_co_own() void
}
```

```js
- gc:GcItem {
}
```

```js
- gc:Lifo {
    - data: type:ptr
    - size: type:uint
    - index: type:uint
    - new() gc:Lifo
    - add(item: type:ptr) void
    - pop() type:ptr
    - clear() void
    - free() void
}
```

```js
- gc:Gc {
    - mutex: core:MutexStruct[void]
    - globals: gc:Bump
    - stack_items: gc:Bump
    - prev_stack_items: gc:Bump
    - updated_list: gc:Bump
    - blanks: gc:Bump
    - dis_owned_list: gc:Bump
    - re_own_list: gc:Bump
    - shared_items: gc:Bump
    - mark_list: gc:Lifo
    - stack_root: type:ptr
    - stack_top_ptr: type:ptr[type:ptr]
    - stack_backup: type:ptr
    - stack_backup_size_ptr: type:ptr[type:uint]
    - coros_ptr: type:ptr[type:Array[?coro:Coro]]
    - pools: type:ptr
    - poolc_ptr: type:ptr[type:uint]
    - mark_shared: type:bool
    - dont_stop: type:bool
    - disable: type:bool
    - did_shutdown: type:bool
    + init() gc:Gc
    - lock() void
    - unlock() void
    - collect() void
    - leak_check() void
    - mark_stack_item(item: type:ptr) void
    - loop_previous_stack_items() void
    - loop_dis_own() void
    - loop_re_own() void
    - loop_updates() void
    - check_blanks() void
    - loop_stack_items(func: fnRef(type:ptr)()) void
    - clear_stack_items() void
    - collect_stack_item(item: type:ptr) void
    - collect_stack_items() void
    - mark_shared_items() void
    - update_marks() void
    - clear_shared() void
    + shutdown() void
}
```

## Globals for 'gc'

```js
- shared gc:shared_dump : gc:Bump
- shared gc:unused_blocks : [128 x type:ptr]
- shared gc:pool_lock : core:Mutex[void]
~ global gc:mem_usage_thread : type:uint
~ shared gc:mem_usage_shared : type:uint
~ shared gc:mem_usage_peak : type:uint
- global gc:poolc : type:uint
- global gc:pools : [128 x type:ptr]
- global gc:stack_root : [40000 x type:ptr]
- global gc:stack_top : type:ptr
- global gc:stack_backup : [40000 x type:ptr]
- global gc:stack_backup_size : type:uint
- global gc:gc : gc:Gc
- global gc:mem_marked : type:uint
- global gc:mem_trigger : type:uint
- global gc:mem_new : type:uint
- global gc:dis_own_count : type:uint
- global gc:collect_count : type:uint
- global gc:trigger_list : [5 x type:uint]
- global gc:dis_own_list : [5 x type:uint]
- global gc:marked_max_reset_at : type:uint
- global gc:marked_max : type:uint
- global gc:marked_max_next : type:uint
- shared gc:shared_lock : core:MutexStruct[void]
- shared gc:gc_list : type:Array[gc:Gc]
- shared gc:mark : type:u16
- shared gc:mem_shared : type:uint
- shared gc:mem_shared_trigger : type:uint
- shared gc:running_shared : type:bool
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

# type

## Functions for 'type'

```js
+ type:to_str() type:String
+ type:to_hex() type:String
+ type:round_up(modulo: type:i8) type:i8
+ type:round_down(modulo: type:i8) type:i8
+ type:to_base(base: type:i8) type:String
- type:to_base_to_ptr(base: type:i8, result: type:ptr) type:uint
+ type:character_length(base: type:i8) type:uint
+ type:print(base: type:i8) void
+ type:equals_str(str: type:String) type:bool
+ type:length() type:uint
- type:to_string() type:String
+ type:data() type:ptr[type:u8]
+ type:data_cstring() type:cstring
+ type:starts_with(part: type:String) type:bool
+ type:ends_with(part: type:String) type:bool
+ type:is_empty() type:bool
+ type:to_uint() type:uint
+ type:to_int() type:int
+ type:hex_to_uint() type:uint
+ type:hex_to_int() type:int
+ type:octal_to_uint() type:uint
+ type:octal_to_int() type:int
+ type:to_float() type:f64
+ type:lower() type:String
+ type:upper() type:String
+ type:is_alpha() type:bool
+ type:is_alpha_numeric() type:bool
+ type:is_integer() type:bool
+ type:is_number() type:bool
- type:add(add: type:String) type:String
- type:equal(cmp: type:String) type:bool
- type:lt(cmp: type:String) type:bool
- type:gt(cmp: type:String) type:bool
- type:lte(cmp: type:String) type:bool
- type:gte(cmp: type:String) type:bool
- type:default_array_filter(i: ?type:String) type:bool
- type:map_hash() type:uint
- type:clone() type:String
+ type:make_empty(length: type:uint) type:String
+ type:make_from_ptr(data: type:ptr, length: type:uint) type:String
+ type:index_of(part: type:String, start_index: type:uint (0)) type:uint
+ type:index_of_byte(byte: type:u8, memory_size: type:uint) type:uint
+ type:contains(part: type:String) type:bool
+ type:contains_byte(byte: type:u8) type:bool
+ type:get(index: type:uint) type:String
+ type:range(start: type:uint, end: type:uint, inclusive: type:bool (true)) type:String
+ type:part(start_index: type:uint, length: type:uint) type:String
+ type:split(on: type:String) type:Array[type:String]
- type:split_on_first_occurance_of_byte(byte: type:u8) (type:String, type:String)
+ type:trim(part: type:String, limit: type:uint (0)) type:String
+ type:rtrim(part: type:String, limit: type:uint (0)) type:String
+ type:ltrim(part: type:String, limit: type:uint (0)) type:String
+ type:replace(part: type:String, with: type:String) type:String
+ type:escape() type:String
+ type:unescape() type:u8
- type:esc() type:String
- type:reset() type:String
+ type:black(bold: type:bool (false)) type:String
+ type:red(bold: type:bool (false)) type:String
+ type:green(bold: type:bool (false)) type:String
+ type:yellow(bold: type:bool (false)) type:String
+ type:blue(bold: type:bool (false)) type:String
+ type:purple(bold: type:bool (false)) type:String
+ type:cyan(bold: type:bool (false)) type:String
+ type:white(bold: type:bool (false)) type:String
+ type:to_json_value() json:Value
+ type:from_json_value(val: json:Value) type:String
- type:set(str: type:String) void
- type:skip_bytes(len: type:uint) void
- type:next() type:u8
+ type:is_ascii() type:bool
+ type:is_hex() type:bool
+ type:is_octal() type:bool
+ type:is_lower() type:bool
+ type:is_upper() type:bool
+ type:is_space_or_tab() type:bool
+ type:is_html_spacing() type:bool
+ type:is_html_whitespace() type:bool
+ type:is_whitespace() type:bool
+ type:is_newline() type:bool
+ type:hex_byte_to_hex_value() type:u8
+ type:to_ascii_string() type:String
- type:print_content(length: type:uint) void
+ type:print_bytes(length: type:uint, end_with_newline: type:bool (true)) void
- type:create_string(length: type:uint) type:String
+ type:offset(offset: type:uint) type:ptr
+ type:offset_int(offset: type:int) type:ptr
- type:read_uint_value(len: type:uint) type:uint
- type:read_octal_value(len: type:uint) type:uint
- type:read_hex_value(len: type:uint) type:uint
```

## Classes for 'type'

```js
- type:uint {
    + to_str() type:String
    + to_hex() type:String
    + round_up(modulo: type:uint) type:uint
    + round_down(modulo: type:uint) type:uint
    + to_base(base: type:uint) type:String
    - to_base_to_ptr(base: type:uint, result: type:ptr) type:uint
    + character_length(base: type:uint) type:uint
    + print(base: type:uint) void
    + equals_str(str: type:String) type:bool
}
```

```js
- type:cstring {
    - length() type:uint
    - to_string() type:String
}
```

```js
- type:u64 {
    + to_str() type:String
    + to_hex() type:String
    + round_up(modulo: type:u64) type:u64
    + round_down(modulo: type:u64) type:u64
    + to_base(base: type:u64) type:String
    - to_base_to_ptr(base: type:u64, result: type:ptr) type:uint
    + character_length(base: type:u64) type:uint
    + print(base: type:u64) void
    + equals_str(str: type:String) type:bool
}
```

```js
+ type:String {
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
    - add(add: type:String) type:String
    - equal(cmp: type:String) type:bool
    - lt(cmp: type:String) type:bool
    - gt(cmp: type:String) type:bool
    - lte(cmp: type:String) type:bool
    - gte(cmp: type:String) type:bool
    - default_array_filter(i: ?type:String) type:bool
    - map_hash() type:uint
    - clone() type:String
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
    - split_on_first_occurance_of_byte(byte: type:u8) (type:String, type:String)
    + trim(part: type:String, limit: type:uint (0)) type:String
    + rtrim(part: type:String, limit: type:uint (0)) type:String
    + ltrim(part: type:String, limit: type:uint (0)) type:String
    + replace(part: type:String, with: type:String) type:String
    + escape() type:String
    + unescape() type:String
    + to_json_value() json:Value
    + from_json_value(val: json:Value) type:String
}
```

```js
- type:u32 {
    + to_str() type:String
    + to_hex() type:String
    + round_up(modulo: type:u32) type:u32
    + round_down(modulo: type:u32) type:u32
    + to_base(base: type:u32) type:String
    - to_base_to_ptr(base: type:u32, result: type:ptr) type:uint
    + character_length(base: type:u32) type:uint
    + print(base: type:u32) void
    + equals_str(str: type:String) type:bool
}
```

```js
- type:i32 {
    + to_str() type:String
    + to_hex() type:String
    + round_up(modulo: type:i32) type:i32
    + round_down(modulo: type:i32) type:i32
    + to_base(base: type:i32) type:String
    - to_base_to_ptr(base: type:i32, result: type:ptr) type:uint
    + character_length(base: type:i32) type:uint
    + print(base: type:i32) void
    + equals_str(str: type:String) type:bool
}
```

```js
- type:CharStep {
    - data: type:ptr
    - bytes: type:uint
    - pos: type:uint
    - set(str: type:String) void
    - skip_bytes(len: type:uint) void
    - next() type:u8
}
```

```js
- type:float {
    - to_string() type:String
    + to_str(decimals: type:uint (2)) type:String
    - equals_str(str: type:String) type:bool
}
```

```js
- type:bool {
    - to_str() type:String
}
```

```js
- type:f64 {
    - to_string() type:String
    + to_str(decimals: type:uint (2)) type:String
    - equals_str(str: type:String) type:bool
}
```

```js
- type:u16 {
    + to_str() type:String
    + to_hex() type:String
    + round_up(modulo: type:u16) type:u16
    + round_down(modulo: type:u16) type:u16
    + to_base(base: type:u16) type:String
    - to_base_to_ptr(base: type:u16, result: type:ptr) type:uint
    + character_length(base: type:u16) type:uint
    + print(base: type:u16) void
    + equals_str(str: type:String) type:bool
}
```

```js
- type:int {
    + to_str() type:String
    + to_hex() type:String
    + round_up(modulo: type:int) type:int
    + round_down(modulo: type:int) type:int
    + to_base(base: type:int) type:String
    - to_base_to_ptr(base: type:int, result: type:ptr) type:uint
    + character_length(base: type:int) type:uint
    + print(base: type:int) void
    + equals_str(str: type:String) type:bool
}
```

```js
- type:u8 {
    + to_str() type:String
    + to_hex() type:String
    + round_up(modulo: type:u8) type:u8
    + round_down(modulo: type:u8) type:u8
    + to_base(base: type:u8) type:String
    - to_base_to_ptr(base: type:u8, result: type:ptr) type:uint
    + character_length(base: type:u8) type:uint
    + print(base: type:u8) void
    + equals_str(str: type:String) type:bool
    + is_ascii() type:bool
    + is_hex() type:bool
    + is_octal() type:bool
    + is_number() type:bool
    + is_lower() type:bool
    + is_upper() type:bool
    + is_alpha() type:bool
    + is_alpha_numeric() type:bool
    + is_space_or_tab() type:bool
    + is_html_spacing() type:bool
    + is_html_whitespace() type:bool
    + is_whitespace() type:bool
    + is_newline() type:bool
    + hex_byte_to_hex_value() type:u8
    + to_ascii_string() type:String
    + unescape() type:u8
}
```

```js
- type:i64 {
    + to_str() type:String
    + to_hex() type:String
    + round_up(modulo: type:i64) type:i64
    + round_down(modulo: type:i64) type:i64
    + to_base(base: type:i64) type:String
    - to_base_to_ptr(base: type:i64, result: type:ptr) type:uint
    + character_length(base: type:i64) type:uint
    + print(base: type:i64) void
    + equals_str(str: type:String) type:bool
}
```

```js
- type:f32 {
    - to_string() type:String
    + to_str(decimals: type:uint (2)) type:String
    - equals_str(str: type:String) type:bool
}
```

```js
- type:ptr {
    + to_hex() type:String
    - print() void
    - print_content(length: type:uint) void
    + index_of_byte(byte: type:u8, memory_size: type:uint) type:uint
    + print_bytes(length: type:uint, end_with_newline: type:bool (true)) void
    - create_string(length: type:uint) type:String
    + offset(offset: type:uint) type:ptr
    + offset_int(offset: type:int) type:ptr
    - read_uint_value(len: type:uint) type:uint
    - read_octal_value(len: type:uint) type:uint
    - read_hex_value(len: type:uint) type:uint
}
```

```js
- type:i16 {
    + to_str() type:String
    + to_hex() type:String
    + round_up(modulo: type:i16) type:i16
    + round_down(modulo: type:i16) type:i16
    + to_base(base: type:i16) type:String
    - to_base_to_ptr(base: type:i16, result: type:ptr) type:uint
    + character_length(base: type:i16) type:uint
    + print(base: type:i16) void
    + equals_str(str: type:String) type:bool
}
```

```js
- type:i8 {
    + to_str() type:String
    + to_hex() type:String
    + round_up(modulo: type:i8) type:i8
    + round_down(modulo: type:i8) type:i8
    + to_base(base: type:i8) type:String
    - to_base_to_ptr(base: type:i8, result: type:ptr) type:uint
    + character_length(base: type:i8) type:uint
    + print(base: type:i8) void
    + equals_str(str: type:String) type:bool
}
```

## Globals for 'type'

```js
- global type:num2str_buf1 : ?type:ptr
- global type:num2str_buf2 : ?type:ptr
```

# mem

## Functions for 'mem'

```js
+ mem:alloc(size: type:uint) type:ptr
+ mem:free(adr: type:ptr) void
+ mem:calloc(size: type:uint) type:ptr
+ mem:copy(from: type:ptr, to: type:ptr, length: type:uint) void
- mem:resized_clone_and_free(from: type:ptr, size: type:uint, new_size: type:uint) type:ptr
+ mem:clear(adr: type:ptr, length: type:uint) void
+ mem:equal(a: type:ptr, b: type:ptr, length: type:uint) type:bool
+ mem:ascii_bytes_to_lower(adr: type:ptr, len: type:uint) void
+ mem:bytes_to_uint(adr: type:ptr, len: type:uint) type:uint
+ mem:find_char(adr: type:ptr, ch: type:u8, length: type:uint) type:uint
+ mem:find_char_(adr: type:ptr, ch: type:u8, length: type:uint) type:uint
- mem:gnu_libc_memchar(adr: type:ptr, ch: type:u8, length: type:uint) type:ptr
```

# ansi

## Functions for 'ansi'

```js
+ ansi:supported() type:bool
```

## Globals for 'ansi'

```js
- global ansi:ansi_supported : type:u8
```

# coro

## Functions for 'coro'

```js
- coro:await_fd(fd: type:int, read: type:bool, write: type:bool) coro:PollEvent
+ coro:yield() void
- coro:await_coro(coro: coro:Coro) void
+ coro:throw(code: type:u32, msg: type:String) void
- coro:new(handler: type:ptr, start_func: type:ptr) coro:Coro
- coro:set(fd: type:int, data: coro:Coro, read: type:bool, write: type:bool) void
- coro:wait(timeout: type:i32 (-1), result: type:Array[coro:Coro] (null)) type:Array[coro:Coro]
- coro:is_closed() type:bool
- coro:is_readable() type:bool
- coro:is_writable() type:bool
- coro:get_poll() coro:CoroPoll
- coro:poll_fd(fd: type:int, read: type:bool, write: type:bool) void
- coro:await_last() void
- coro:block() void
- coro:start() void
- coro:continue() void
- coro:setjmp(buf: type:ptr) type:i32
- coro:resume() void
- coro:complete() void
- coro:loop(until: ?coro:Coro (null)) void
- coro:gc_free() void
```

## Classes for 'coro'

```js
+ coro:CoroPoll {
    - poll_items: type:StructArray[libc_gen_pollfd]
    - items1: type:Array[coro:Coro]
    - items2: type:Array[coro:Coro]
    - index: type:uint
    - new() coro:CoroPoll
    - set(fd: type:int, data: coro:Coro, read: type:bool, write: type:bool) void
    - wait(timeout: type:i32 (-1), result: type:Array[coro:Coro] (null)) type:Array[coro:Coro]
}
```

```js
- coro:PollEvent {
    - is_closed() type:bool
    - is_readable() type:bool
    - is_writable() type:bool
}
```

```js
+ coro:Coro {
    - gc_args: type:Array[gc:GcPtr]
    - follow_up: ?coro:Coro
    - next_resume: ?coro:Coro
    - error_msg: type:String
    - args: type:ptr
    - stack: ?type:ptr
    - stack_mem_size: type:uint
    - stack_size: type:uint
    - start_func: fnRef(coro:Coro)()
    - handler: fnRef()()
    - g_list_index: type:uint
    - s_stack: ?type:ptr
    - s_top: type:ptr
    - s_bottom: type:ptr
    - s_cont: type:ptr
    - s_size: type:uint
    - s_back_buf: type:ptr
    - error_code: type:u32
    - poll_event: coro:PollEvent
    - sleep_until: type:uint
    - test: type:uint
    - error: type:u32
    - started: type:bool
    - done: type:bool
    - new(handler: type:ptr, start_func: type:ptr) coro:Coro
    - get_poll() coro:CoroPoll
    - await_coro(coro: coro:Coro) void
    - await_fd(fd: type:int, read: type:bool, write: type:bool) coro:PollEvent
    - poll_fd(fd: type:int, read: type:bool, write: type:bool) void
    - await_last() void
    - block() void
    - start() void
    - continue() void
    - setjmp(buf: type:ptr) type:i32
    - resume() void
    - complete() void
    - loop(until: ?coro:Coro (null)) void
    - gc_free() void
}
```

## Globals for 'coro'

```js
- global coro:coro_run_first : ?coro:Coro
- global coro:coro_run_last : ?coro:Coro
- global coro:current_coro : ?coro:Coro
- global coro:coro_poll : ?coro:CoroPoll
- global coro:g_coros : type:Array[?coro:Coro]
- global coro:g_coro_sleepers : type:Array[coro:Coro]
- global coro:g_coro_sleepers_next : type:Array[coro:Coro]
- global coro:g_coro_indexes : type:Pool[type:uint]
- global coro:g_coro_poll_count : type:uint
- global coro:g_coro_count : type:uint
```

# fs

## Functions for 'fs'

```js
+ fs:open(path: type:String, writable: type:bool, append_on_write: type:bool) type:int
+ fs:open_extend(path: type:String, writable: type:bool, append_on_write: type:bool, create_file_if_doesnt_exist: type:bool (false), create_file_permissions: type:u32 (420)) type:int
- fs:stat(path: type:String, buf: libc_gen_stat) void
+ fs:size(path: type:String) type:uint
+ fs:sync() void
+ fs:read_bytes(path: type:String, buffer: utils:ByteBuffer (/)) utils:ByteBuffer
+ fs:read(bytes: type:uint (10240)) type:String
+ fs:write(path: type:String, content: type:String, append: type:bool (false)) void
+ fs:write_bytes(from: type:ptr, len: type:uint) void
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
+ fs:resolve() fs:Path
+ fs:add(part: type:String) fs:Path
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
+ fs:new(path: type:String) fs:Path
+ fs:pop() fs:Path
+ fs:close() void
- fs:gc_free() void
+ fs:create_from_ptr(data: type:ptr, size: type:uint) fs:InMemoryFile
+ fs:save(path: type:String) void
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
    - equal(cmp: type:String) type:bool
    - lt(cmp: type:String) type:bool
    - gt(cmp: type:String) type:bool
    - lte(cmp: type:String) type:bool
    - gte(cmp: type:String) type:bool
    - default_array_filter(i: ?type:String) type:bool
    - map_hash() type:uint
    - clone() type:String
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
    - split_on_first_occurance_of_byte(byte: type:u8) (type:String, type:String)
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
    - fd: type:int
    - can_read: type:bool
    - can_write: type:bool
    ~ reading: type:bool
    + read(bytes: type:uint (10240)) type:String
    + write_bytes(from: type:ptr, len: type:uint) void
    + close() void
    - gc_free() void
}
```

```js
+ fs:InMemoryFile {
    - filename: type:String
    - mime_type: type:String
    ~ data: type:ptr
    ~ size: type:uint
    + create_from_ptr(data: type:ptr, size: type:uint) fs:InMemoryFile
    + save(path: type:String) void
}
```

## Globals for 'fs'

```js
- global fs:g_mimes : ?type:Map[type:String]
- global fs:EXE_PATH : ?type:String
- global fs:EXE_DIR : ?type:String
```

# http

## Functions for 'http'

```js
+ http:create_request(method: type:String, url: type:String, options: ?http:Options (null)) http:ClientRequest
+ http:request(method: type:String, url: type:String, options: ?http:Options (null)) http:ClientResponse
+ http:download(url: type:String, to_path: type:String, method: type:String ("GET"), options: ?http:Options (null)) void
- http:handler_default(req: http:Request) http:Response
- http:fast_handler_default(req: http:Context, res: http:ResponseWriter) void
- http:parse_http(input: utils:ByteBuffer, context: http:Context, is_response: type:bool) void
- http:worker(server: http:Server) void
- http:SSL_CTX_new(method: type:ptr) SSL_CTX
- http:SSL_CTX_free(ctx: SSL_CTX) void
- http:SSL_new(ctx: SSL_CTX) SSL
- http:SSL_set_fd(ssl: SSL, fd: type:i32) void
- http:SSL_free(ctx: SSL_CTX) void
- http:SSL_connect(ctx: SSL_CTX) type:i32
- http:SSL_get_version(ssl: SSL) type:cstring
- http:SSL_write(ssl: SSL, data: type:ptr, bytes: type:uint) type:i32
- http:SSL_read(ssl: SSL, data: type:ptr, bytes: type:uint) type:i32
- http:SSL_write_ex(ssl: SSL, data: type:ptr, bytes: type:uint, bytes_written_uint_ptr: type:ptr) type:i32
- http:SSL_read_ex(ssl: SSL, data: type:ptr, bytes: type:uint, bytes_read_uint_ptr: type:ptr) type:i32
- http:SSL_set1_host(ssl: SSL, host: type:cstring) type:i32
- http:SSL_set_verify(ssl: SSL, mode: type:i32, cb: ?fn(type:i32, type:ptr)(type:i32)) type:i32
- http:SSL_set_cipher_list(ssl: SSL, ciphers: type:cstring) type:i32
- http:SSL_ctrl(ssl: SSL, cmd: type:i32, larg: type:int, parg: ?type:ptr) type:int
- http:SSL_get_error(ssl: SSL, ret: type:i32) type:i32
- http:ERR_clear_error() void
- http:ERR_get_error() type:uint
- http:ERR_error_string(error: type:uint, buffer: ?type:ptr) type:cstring
- http:TLS_client_method() type:ptr
- http:SSLv23_client_method() type:ptr
- http:SSL_CTX_set_verify(ssl: SSL, mode: type:i32, cb: ?fn(type:i32, type:ptr)(type:i32)) type:i32
- http:SSL_CTX_set_options(ctx: SSL_CTX, flags: type:int) void
- http:SSL_CTX_ctrl(ctx: SSL_CTX, cmd: type:i32, larg: type:int, parg: ?type:ptr) type:int
- http:SSL_CTX_load_verify_locations(ctx: SSL_CTX, ca_file: type:cstring, ca_path: ?type:cstring) type:i32
- http:SSL_CTX_set_default_verify_paths(ctx: SSL_CTX) type:i32
- http:X509_get_default_cert_file() type:cstring
- http:reset_cache() void
+ http:headers() type:Map[type:String]
+ http:params() type:Map[type:String]
+ http:params_grouped() type:Map[type:Array[type:String]]
+ http:data() type:Map[type:String]
+ http:files() type:Map[fs:InMemoryFile]
- http:data_urlencoded(result: type:Map[type:String]) void
- http:data_multipart(result: type:Map[type:String], files: type:Map[fs:InMemoryFile], boundary: type:String) void
- http:parse_content_disposition(value: type:String, result: type:Map[type:String]) void
- http:data_json(result: type:Map[type:String]) void
- http:parse_headers(data: type:ptr, length: type:uint, result: type:Map[type:String]) type:uint
+ http:body() type:String
+ http:html(body: type:String, code: type:u32 (200), headers: ?type:Map[type:String] (null)) http:Response
+ http:json(body: type:String, code: type:u32 (200), headers: ?type:Map[type:String] (null)) http:Response
+ http:text(body: type:String, code: type:u32 (200), content_type: type:String ("text/plain"), headers: ?type:Map[type:String] (null)) http:Response
+ http:redirect(location: type:String, code: type:u32 (301), headers: ?type:Map[type:String] (null)) http:Response
+ http:empty(code: type:u32, headers: ?type:Map[type:String] (null)) http:Response
+ http:file(path: type:String, filename: ?type:String (null)) http:Response
- http:reset() void
+ http:create(method: type:String, url: type:String, options: ?http:Options (null)) http:ClientRequest
- http:create_payload(method: type:String, url: url:Url, options: ?http:Options) utils:ByteBuffer
- http:stop() void
+ http:progress() type:bool
+ http:response() http:ClientResponse
- http:new(buffer: utils:ByteBuffer) http:Context
+ http:start(worker_count: type:i32 (8)) void
+ http:add_static_dir(path: type:String) void
- http:handle() void
- http:read_more(buffer: utils:ByteBuffer) type:uint
- http:send_error(code: type:uint, res: http:ResponseWriter) void
- http:close() void
+ http:get_headers() type:Map[type:String]
+ http:set_header(key: type:String, value: type:String) http:Options
+ http:set_headers(headers: type:Map[type:String]) http:Options
+ http:clear_headers(key: type:String, value: type:String) http:Options
- http:allow_new_response() void
- http:send_response(resp: http:Response) void
- http:send_status(status_code: type:uint) void
- http:send_file(path: type:String, custom_filename: ?type:String (null)) void
- http:send_file_stream(stream: fs:FileStream, filename: ?type:String (null)) void
+ http:respond(code: type:uint, content_type: type:String, body: type:String, headers: ?type:Map[type:String] (null)) void
- http:count_bytes_to_send() type:uint
- http:should_send() type:bool
- http:send_bytes(connection: net:Connection) void
```

## Classes for 'http'

```js
+ http:Request {
    + method: type:String
    + path: type:String
    + query_string: type:String
    - body_data: type:String
    - header_data: type:String
    - header_map: ?type:Map[type:String]
    - params_map: ?type:Map[type:String]
    - params_grp: ?type:Map[type:Array[type:String]]
    - data_map: ?type:Map[type:String]
    - files_map: ?type:Map[fs:InMemoryFile]
    - reset_cache() void
    + headers() type:Map[type:String]
    + params() type:Map[type:String]
    + params_grouped() type:Map[type:Array[type:String]]
    + data() type:Map[type:String]
    + files() type:Map[fs:InMemoryFile]
    - data_urlencoded(result: type:Map[type:String]) void
    - data_multipart(result: type:Map[type:String], files: type:Map[fs:InMemoryFile], boundary: type:String) void
    - parse_content_disposition(value: type:String, result: type:Map[type:String]) void
    - data_json(result: type:Map[type:String]) void
    - parse_headers(data: type:ptr, length: type:uint, result: type:Map[type:String]) type:uint
    + body() type:String
}
```

```js
+ http:Response {
    - body: type:String
    - filepath: ?type:String
    - filename: ?type:String
    - content_type: type:String
    - headers: ?type:Map[type:String]
    - status: type:u32
    + html(body: type:String, code: type:u32 (200), headers: ?type:Map[type:String] (null)) http:Response
    + json(body: type:String, code: type:u32 (200), headers: ?type:Map[type:String] (null)) http:Response
    + text(body: type:String, code: type:u32 (200), content_type: type:String ("text/plain"), headers: ?type:Map[type:String] (null)) http:Response
    + redirect(location: type:String, code: type:u32 (301), headers: ?type:Map[type:String] (null)) http:Response
    + empty(code: type:u32, headers: ?type:Map[type:String] (null)) http:Response
    + file(path: type:String, filename: ?type:String (null)) http:Response
    - reset() void
}
```

```js
+ http:ClientRequest {
    ~ recv_buffer: utils:ByteBuffer
    - ctx: http:Context
    - con: net:Connection
    - payload: utils:ByteBuffer
    - output_file: ?fs:FileStream
    - resp: ?http:ClientResponse
    - stage: type:uint
    ~ bytes_to_send: type:uint
    ~ bytes_sent: type:uint
    ~ bytes_to_recv: type:uint
    ~ bytes_received: type:uint
    ~ sent_percent: type:uint
    ~ recv_percent: type:uint
    ~ done: type:bool
    + create(method: type:String, url: type:String, options: ?http:Options (null)) http:ClientRequest
    - create_payload(method: type:String, url: url:Url, options: ?http:Options) utils:ByteBuffer
    - stop() void
    + progress() type:bool
    + response() http:ClientResponse
}
```

```js
+ http:Server {
    ~ host: type:String
    - socket: net:SocketTCP
    - handler: fn(http:Request)(http:Response)
    + fast_handler: ?fn(http:Context, http:ResponseWriter)()
    - static_dirs: type:Array[type:String]
    ~ port: type:u16
    - max_connections: type:uint
    - connections: type:uint
    - active_body_size: type:uint
    - max_request_header_size: type:uint
    - max_request_body_size: type:uint
    - max_server_wide_body_size: type:uint
    + show_info: type:bool
    + new(host: type:String, port: type:u16, handler: fn(http:Request)(http:Response)) http:Server
    + start(worker_count: type:i32 (8)) void
    + add_static_dir(path: type:String) void
}
```

```js
+ http:Context {
    ~ method: utils:ByteBufferStrRef
    ~ path: utils:ByteBufferStrRef
    ~ query_string: utils:ByteBufferStrRef
    ~ header_data: utils:ByteBufferStrRef
    - body_data: utils:ByteBufferStrRef
    - chunks: utils:ByteBuffer
    ~ save_to_file: ?fs:FileStream
    - header_map: ?type:Map[type:String]
    - params_map: ?type:Map[type:String]
    - params_grp: ?type:Map[type:Array[type:String]]
    - data_map: ?type:Map[type:String]
    - files_map: ?type:Map[fs:InMemoryFile]
    ~ status: type:uint
    ~ stage: type:uint
    ~ parsed_index: type:uint
    ~ content_length: type:uint
    ~ body_received: type:uint
    ~ has_host: type:bool
    ~ chunked: type:bool
    ~ done: type:bool
    - reset_cache() void
    + headers() type:Map[type:String]
    + params() type:Map[type:String]
    + params_grouped() type:Map[type:Array[type:String]]
    + data() type:Map[type:String]
    + files() type:Map[fs:InMemoryFile]
    - data_urlencoded(result: type:Map[type:String]) void
    - data_multipart(result: type:Map[type:String], files: type:Map[fs:InMemoryFile], boundary: type:String) void
    - parse_content_disposition(value: type:String, result: type:Map[type:String]) void
    - data_json(result: type:Map[type:String]) void
    - parse_headers(data: type:ptr, length: type:uint, result: type:Map[type:String]) type:uint
    - new(buffer: utils:ByteBuffer) http:Context
    - reset() void
    + body() type:String
}
```

```js
+ http:Worker {
    - server: http:Server
    - connections: type:uint
}
```

```js
+ http:Connection {
    - worker: http:Worker
    - netcon: net:Connection
    - fd: type:int
    - handle() void
    - read_more(buffer: utils:ByteBuffer) type:uint
    - send_error(code: type:uint, res: http:ResponseWriter) void
    - close() void
}
```

```js
+ http:Options {
    + body: type:String
    + query_data: ?type:Map[type:String]
    + headers: ?type:Map[type:String]
    + output_to_file: ?type:String
    + follow_redirects: type:bool
    + get_headers() type:Map[type:String]
    + set_header(key: type:String, value: type:String) http:Options
    + set_headers(headers: type:Map[type:String]) http:Options
    + clear_headers(key: type:String, value: type:String) http:Options
}
```

```js
+ http:RouteArg {
    - name: type:String
    - i: type:uint
}
```

```js
+ http:ClientResponse {
    + headers: type:Map[type:String]
    + body: type:String
    + status: type:uint
}
```

```js
+ http:ResponseWriter {
    - output: utils:ByteBuffer
    - file_response: ?fs:FileStream
    ~ responded: type:bool
    - output_pos: type:uint
    - reset() void
    - allow_new_response() void
    - send_response(resp: http:Response) void
    - send_status(status_code: type:uint) void
    - send_file(path: type:String, custom_filename: ?type:String (null)) void
    - send_file_stream(stream: fs:FileStream, filename: ?type:String (null)) void
    + respond(code: type:uint, content_type: type:String, body: type:String, headers: ?type:Map[type:String] (null)) void
    - count_bytes_to_send() type:uint
    - should_send() type:bool
    - send_bytes(connection: net:Connection) void
}
```

```js
- http:SSL {
}
```

```js
- http:SSL_CTX {
}
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
- json:encode_value_buf(val: json:Value, result: utils:ByteBuffer, depth: type:uint, pretty: type:bool) void
- json:indent(result: utils:ByteBuffer, depth: type:uint) void
- json:parse(data: utils:ByteBuffer) json:Value
- json:parse_value() json:Value
- json:parse_object() json:Value
- json:parse_array() json:Value
- json:parse_number() json:Value
- json:get_word() type:String
- json:expect(ch: type:u8) void
- json:skip_whitespace() void
- json:read_string() type:String
+ json:get(key: type:String) json:Value
+ json:set(key: type:String, val: json:Value) void
+ json:has(key: type:String) type:bool
+ json:remove(key: type:String) void
+ json:add(value: json:Value) void
+ json:remove_index(index: type:uint) void
+ json:string() type:String
+ json:int() type:int
+ json:float() type:float
+ json:bool() type:bool
+ json:array() type:Array[json:Value]
+ json:map() type:Map[json:Value]
+ json:is_null() type:bool
+ json:is_string() type:bool
+ json:is_bool() type:bool
+ json:is_number() type:bool
+ json:is_array() type:bool
+ json:is_object() type:bool
+ json:set_null(key: type:String) json:Value
+ json:set_string(key: type:String, value: type:String) json:Value
+ json:set_number_int(key: type:String, value: type:int) json:Value
+ json:set_number_uint(key: type:String, value: type:uint) json:Value
+ json:set_number_float(key: type:String, value: type:float) json:Value
+ json:set_bool(key: type:String, value: type:bool) json:Value
+ json:set_array(key: type:String, values: type:Array[json:Value]) json:Value
+ json:set_object(key: type:String, values: type:Map[json:Value]) json:Value
+ json:add_null() json:Value
+ json:add_string(value: type:String) json:Value
+ json:add_number_int(value: type:int) json:Value
+ json:add_number_uint(value: type:uint) json:Value
+ json:add_number_float(value: type:float) json:Value
+ json:add_bool(value: type:bool) json:Value
+ json:add_array(value: type:Array[json:Value]) json:Value
+ json:add_object(value: type:Map[json:Value]) json:Value
+ json:encode(pretty: type:bool (false)) type:String
```

## Classes for 'json'

```js
+ json:Parser {
    - data: utils:ByteBuffer
    - str_buf: utils:ByteBuffer
    - index: type:uint
    - parse(data: utils:ByteBuffer) json:Value
    - parse_value() json:Value
    - parse_object() json:Value
    - parse_array() json:Value
    - parse_number() json:Value
    - get_word() type:String
    - expect(ch: type:u8) void
    - skip_whitespace() void
    - read_string() type:String
}
```

```js
+ json:Value {
    + object_values: ?type:Map[json:Value]
    + array_values: ?type:Array[json:Value]
    + string_value: type:String
    + type: type:int
    + int_value: type:int
    + float_value: type:float
    + bool_value: type:bool
    + get(key: type:String) json:Value
    + set(key: type:String, val: json:Value) void
    + has(key: type:String) type:bool
    + remove(key: type:String) void
    + add(value: json:Value) void
    + remove_index(index: type:uint) void
    + string() type:String
    + int() type:int
    + float() type:float
    + bool() type:bool
    + array() type:Array[json:Value]
    + map() type:Map[json:Value]
    + is_null() type:bool
    + is_string() type:bool
    + is_bool() type:bool
    + is_number() type:bool
    + is_array() type:bool
    + is_object() type:bool
    + set_null(key: type:String) json:Value
    + set_string(key: type:String, value: type:String) json:Value
    + set_number_int(key: type:String, value: type:int) json:Value
    + set_number_uint(key: type:String, value: type:uint) json:Value
    + set_number_float(key: type:String, value: type:float) json:Value
    + set_bool(key: type:String, value: type:bool) json:Value
    + set_array(key: type:String, values: type:Array[json:Value]) json:Value
    + set_object(key: type:String, values: type:Map[json:Value]) json:Value
    + add_null() json:Value
    + add_string(value: type:String) json:Value
    + add_number_int(value: type:int) json:Value
    + add_number_uint(value: type:uint) json:Value
    + add_number_float(value: type:float) json:Value
    + add_bool(value: type:bool) json:Value
    + add_array(value: type:Array[json:Value]) json:Value
    + add_object(value: type:Map[json:Value]) json:Value
    + encode(pretty: type:bool (false)) type:String
}
```

# net

## Functions for 'net'

```js
+ net:set_ca_cert_path(path: ?type:String) void
- net:new_tcp(host: type:String, port: type:u16) net:SocketTCP
+ net:close() void
- net:ca_paths() type:Array[type:String]
- net:try_ca_path(ctx: SSL_CTX, path: ?type:String) type:bool
+ net:new(fd: type:int) net:Connection
- net:gc_free() void
+ net:connect() net:Connection
+ net:bind() void
+ net:accept() net:Connection
+ net:sock_addr() libc_gen_sockaddr
+ net:addr_len() type:u32
+ net:ssl_connect(host: type:String, ca_cert_path: ?type:String (null)) void
+ net:send(data: type:String) void
+ net:send_buffer(data: utils:ByteBuffer, skip_bytes: type:uint, send_all: type:bool) type:uint
+ net:send_bytes(data: type:ptr, bytes: type:uint, send_all: type:bool) type:uint
+ net:recv(buffer: utils:ByteBuffer, bytes: type:uint) type:uint
```

## Classes for 'net'

```js
+ net:Socket {
    - new_tcp(host: type:String, port: type:u16) net:SocketTCP
    - close(fd: type:int) void
}
```

```js
+ net:SSL {
    - host: type:String
    - ca_cert_path: ?type:String
    ~ ctx: SSL
    ~ ssl: SSL
    - ca_paths() type:Array[type:String]
    - try_ca_path(ctx: SSL_CTX, path: ?type:String) type:bool
    - new(fd: type:int, host: type:String, ca_path: ?type:String (null)) net:SSL
    - gc_free() void
}
```

```js
+ net:SocketTCP {
    ~ host: type:String
    - addrinfo: net:AddrInfo
    ~ fd: type:int
    ~ port: type:u16
    - closed: type:bool
    + new(host: type:String, port: type:u16) net:SocketTCP
    + close() void
    - gc_free() void
    + connect() net:Connection
    + bind() void
    + accept() net:Connection
}
```

```js
+ net:AddrInfo {
    ~ data: libc_gen_addrinfo
    + new(host: type:String, port: type:u16) net:AddrInfo
    - gc_free() void
    + sock_addr() libc_gen_sockaddr
    + addr_len() type:u32
}
```

```js
+ net:Connection {
    ~ ssl: ?net:SSL
    ~ fd: type:int
    ~ ssl_enabled: type:bool
    - closed: type:bool
    + new(fd: type:int) net:Connection
    + close() void
    - gc_free() void
    + ssl_connect(host: type:String, ca_cert_path: ?type:String (null)) void
    + send(data: type:String) void
    + send_buffer(data: utils:ByteBuffer, skip_bytes: type:uint, send_all: type:bool) type:uint
    + send_bytes(data: type:ptr, bytes: type:uint, send_all: type:bool) type:uint
    + recv(buffer: utils:ByteBuffer, bytes: type:uint) type:uint
}
```

## Globals for 'net'

```js
- shared net:ca_cert : ?type:String
- global net:ca_dirs : ?type:Array[type:String]
- global net:ca_paths : ?type:Array[type:String]
```

# thread

## Functions for 'thread'

```js
+ thread:sleep_ns(ns: type:uint) void
+ thread:sleep_ms(ms: type:uint) void
+ thread:start(func: fn()()) thread:Thread
+ thread:start_unsafe(func: fn()()) thread:Thread
- thread:init() void
- thread:entry() void
+ thread:wait() void
- thread:gc_free() void
```

## Classes for 'thread'

```js
+ thread:Thread {
    - handler: fn()()
    - thread: ?type:ptr
    ~ finished: type:bool
    + start(func: fn()()) thread:Thread
    + start_unsafe(func: fn()()) thread:Thread
    - init() void
    - entry() void
    + wait() void
    - gc_free() void
}
```

## Globals for 'thread'

```js
- global thread:current_thread : ?thread:Thread
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

## Functions for 'utils'

```js
+ utils:new(buffer: utils:ByteBuffer, offset: type:uint, length: type:uint) utils:ByteBufferStrRef
- utils:gc_free() void
+ utils:clone() utils:ByteBuffer
+ utils:clear() void
+ utils:clear_until(index: type:uint) void
+ utils:clear_part(index: type:uint, len: type:uint) void
+ utils:get(index: type:uint) type:u8
+ utils:append(buffer: utils:ByteBuffer, start_index: type:uint (0)) void
+ utils:append_from_ptr(data: type:ptr, length: type:uint) void
+ utils:append_byte(byte: type:u8) void
+ utils:append_str(str: type:String) void
+ utils:append_uint(value: type:uint) void
+ utils:append_int(value: type:int) void
+ utils:equals_str(str: type:String) type:bool
+ utils:starts_with(str: type:String, offset: type:uint) type:bool
+ utils:index_of_byte(byte: type:u8, start_index: type:uint (0)) type:uint
+ utils:index_where_byte_is_not(byte: type:u8, start_index: type:uint (0)) type:uint
+ utils:to_string() type:String
+ utils:part(start_index: type:uint, length: type:uint) type:String
+ utils:str_ref(offset: type:uint, length: type:uint) utils:ByteBufferStrRef
+ utils:minimum_free_space(length: type:uint) void
+ utils:minimum_size(minimum_size: type:uint) void
+ utils:reduce_size(size: type:uint) void
+ utils:data() type:ptr
+ utils:to_str() type:String
+ utils:equals(cmp: type:String) type:bool
```

## Classes for 'utils'

```js
+ utils:ByteBuffer {
    ~ data: type:ptr
    ~ size: type:uint
    ~ length: type:uint
    + new(start_size: type:uint (128)) utils:ByteBuffer
    - gc_free() void
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

```js
+ utils:ByteBufferStrRef {
    - buffer: utils:ByteBuffer
    - offset: type:uint
    - length: type:uint
    + new(buffer: utils:ByteBuffer, offset: type:uint, length: type:uint) utils:ByteBufferStrRef
    + data() type:ptr
    + clear() void
    + to_str() type:String
    + equals(cmp: type:String) type:bool
}
```

# url

## Functions for 'url'

```js
+ url:parse(str: type:String) url:Url
+ url:encode(str: type:String) type:String
+ url:decode(str: type:String) type:String
```

## Classes for 'url'

```js
+ url:Url {
    + scheme: type:String
    + host: type:String
    + path: type:String
    + query: type:String
}
```

