
type libc_timespec (libc_gen_timespec)
type libc_timeval (libc_gen_timeval)
type libc_sockaddr (libc_gen_sockaddr)
type libc_pollfd (libc_gen_pollfd)
type libc_jmp_buf ([inline libc_gen___jmp_buf_tag, 1])
type libc_stat (libc_gen_stat)
type libc_dirent (libc_gen_dirent)
type libc_timezone (libc_gen_timezone)
type libc_addrinfo (libc_gen_addrinfo)
type libc_epoll_event (libc_gen_epoll_event)

cstruct libc_gen_timespec {
    tv_sec: int
    tv_nsec: int
}

cstruct libc_gen_stat {
    st_dev: uint
    st_ino: uint
    st_nlink: uint
    st_mode: u32
    st_uid: u32
    st_gid: u32
    __pad0: i32
    st_rdev: uint
    st_size: int
    st_blksize: int
    st_blocks: int
    st_atim: inline libc_gen_timespec
    st_mtim: inline libc_gen_timespec
    st_ctim: inline libc_gen_timespec
    __glibc_reserved: inline [int, 3]
}

cstruct libc_gen_anon_struct_2 {
    __val: inline [uint, 16]
}

cstruct libc_gen___jmp_buf_tag {
    __jmpbuf: inline [int, 8]
    __mask_was_saved: i32
    __saved_mask: inline libc_gen_anon_struct_2
}

cstruct libc_gen_dirent {
    d_ino: uint
    d_off: int
    d_reclen: u16
    d_type: u8
    d_name: inline [i8, 256]
}

cstruct libc_gen_pollfd {
    fd: i32
    events: i16
    revents: i16
}

cstruct libc_gen_timeval {
    tv_sec: int
    tv_usec: int
}

cstruct libc_gen_sockaddr {
    sa_family: u16
    sa_data: inline [i8, 14]
}

cstruct libc_gen_addrinfo {
    ai_flags: i32
    ai_family: i32
    ai_socktype: i32
    ai_protocol: i32
    ai_addrlen: u32
    ai_addr: libc_gen_sockaddr
    ai_canonname: cstring
    ai_next: libc_gen_addrinfo
}

cstruct libc_gen_timezone {
    tz_minuteswest: i32
    tz_dsttime: i32
}

cstruct libc_gen_epoll_data {
    ptr: ptr
    fd: i32
    u32: u32
    u64: uint
}

cstruct libc_gen_epoll_event {
    events: u32
    data: inline libc_gen_epoll_data
}

