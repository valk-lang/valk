
// alias libc_stat as libc_stat_fix

struct libc_jmp_buf {
    data: <[5 x ptr]>
}

struct libc_timezone {
    tz_minuteswest: i32 // Minutes west of GMT
    tz_dsttime: i32 // Nonzero if DST is ever in effect
}

struct libc_addrinfo_fix {
    ai_flags: i32
    ai_family: i32
    ai_socktype: i32
    ai_protocol: i32
    ai_addrlen: i64
    ai_canonname: ptr
    ai_addr: ptr
    ai_next: ptr
}

struct libc_stat_fix {
    st_dev: u32
    st_ino: u16
    st_mode: u16

    st_nlink: i16
    st_uid: i16
    st_gid: i16
    st_rdev: u32
    st_size: i32

    st_atime: i64
    st_mtime: i64
    st_ctime: i64
}

struct libc_timeval_fix {
    tv_sec: int
    tv_usec: int
}
