
type libc_timespec (libc_gen_timespec)
type libc_timeval (libc_gen_timeval)
type libc_sockaddr (libc_gen_sockaddr)
type libc_pollfd (libc_gen_pollfd)
type libc_stat (libc_gen_stat)
type libc_addrinfo (libc_gen_addrinfo)
type libc_WIN32_FIND_DATAA (libc_gen__WIN32_FIND_DATAA)
type libc_FILETIME (libc_gen__FILETIME)

cstruct libc_gen_stat {
    st_dev: u32
    st_ino: u16
    st_mode: u16
    st_nlink: i16
    st_uid: i16
    st_gid: i16
    st_rdev: u32
    st_size: i32
    st_atime: int
    st_mtime: int
    st_ctime: int
}

cstruct libc_gen__FILETIME {
    dwLowDateTime: u32
    dwHighDateTime: u32
}

cstruct libc_gen__WIN32_FIND_DATAA {
    dwFileAttributes: u32
    ftCreationTime: inline libc_gen__FILETIME
    ftLastAccessTime: inline libc_gen__FILETIME
    ftLastWriteTime: inline libc_gen__FILETIME
    nFileSizeHigh: u32
    nFileSizeLow: u32
    dwReserved0: u32
    dwReserved1: u32
    cFileName: inline [i8, 260]
    cAlternateFileName: inline [i8, 14]
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
    ai_addrlen: uint
    ai_canonname: cstring
    ai_addr: libc_gen_sockaddr
    ai_next: libc_gen_addrinfo
}

cstruct libc_gen_timeval {
    tv_sec: i32
    tv_usec: i32
}

cstruct libc_gen_pollfd {
    fd: uint
    events: i16
    revents: i16
}

cstruct libc_gen_timespec {
    tv_sec: int
    tv_nsec: i32
}

