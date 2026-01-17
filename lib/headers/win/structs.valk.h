
// alias libc_stat as libc_stat_fix

struct libc_jmp_buf {
    data: [ptr x 5]
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
    ai_addrlen: uint
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

type libc_timeval (libc_timeval_fix)

struct libc_timeval_fix {
    tv_sec: int
    tv_usec: int
}

struct in_addr {
    addr: u32
}

struct sockaddr_in {
    sa_family: u16
    sin_port: u16
    sin_addr: u32
    sin_zero: [u8 x 8]
}

struct GUID {
    Data1: u32
    Data2: u16
    Data3: u16
    Data4: [u8 x 8]
}

value _SS_MAXSIZE   (128)          // Maximum size
value _SS_ALIGNSIZE (size_of(i64)) // Desired alignment
value _SS_PAD1SIZE  (_SS_ALIGNSIZE - size_of(u16))
value _SS_PAD2SIZE  (_SS_MAXSIZE - (size_of(u16) + _SS_PAD1SIZE + _SS_ALIGNSIZE))

struct sockaddr_storage {
    ss_family: u16
    __ss_pad1: [u8 x _SS_PAD1SIZE]
    __ss_align: i64
    __ss_pad2: [u8 x _SS_PAD2SIZE]
}
