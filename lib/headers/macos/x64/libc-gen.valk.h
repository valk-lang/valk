
type libc_timespec (libc_gen_timespec)
type libc_timeval (libc_gen_timeval)
type libc_sockaddr (libc_gen_sockaddr)
type libc_pollfd (libc_gen_pollfd)
type libc_jmp_buf ([i32, 37])
type libc_stat (libc_gen_stat)
type libc_dirent (libc_gen_dirent)
type libc_timezone (libc_gen_timezone)
type libc_addrinfo (libc_gen_addrinfo)

cstruct libc_gen_timespec {
    tv_sec: int
    tv_nsec: int
}

cstruct libc_gen_stat {
    st_dev: i32
    st_ino: u32
    st_mode: u16
    st_nlink: u16
    st_uid: u32
    st_gid: u32
    st_rdev: i32
    st_atimespec: inline libc_gen_timespec
    st_mtimespec: inline libc_gen_timespec
    st_ctimespec: inline libc_gen_timespec
    st_size: int
    st_blocks: int
    st_blksize: i32
    st_flags: u32
    st_gen: u32
    st_lspare: i32
    st_qspare: inline [int, 2]
}

cstruct libc_gen_dirent {
    d_ino: u32
    d_reclen: u16
    d_type: u8
    d_namlen: u8
    d_name: inline [i8, 256]
}

cstruct libc_gen_timeval {
    tv_sec: int
    tv_usec: i32
}

cstruct libc_gen_pollfd {
    fd: i32
    events: i16
    revents: i16
}

cstruct libc_gen_sockaddr {
    sa_len: u8
    sa_family: u8
    sa_data: inline [i8, 14]
}

cstruct libc_gen_addrinfo {
    ai_flags: i32
    ai_family: i32
    ai_socktype: i32
    ai_protocol: i32
    ai_addrlen: u32
    ai_canonname: cstring
    ai_addr: libc_gen_sockaddr
    ai_next: libc_gen_addrinfo
}

cstruct libc_gen_timezone {
    tz_minuteswest: i32
    tz_dsttime: i32
}

