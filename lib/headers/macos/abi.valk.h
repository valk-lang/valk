
@shared errno: i32;
@shared stderr : ?ptr;
@shared stdin : ?ptr;
@shared stdout : ?ptr;

alias FILE for ptr;
alias DIR for ptr
alias libc_addrinfo_fix for libc_addrinfo

value SEEK_SET (0) // set file offset to offset

// pid_t = i32
// socklen_t = u32
// mode_t = u32
// uid_t = u32
// gid_t = u32

fn __error() ptr;
fn malloc(size: uint) ptr;
fn free(adr: ptr) void;

fn getenv(key: cstring) ?cstring;

fn sync() void;
fn read(fd: i32, buf: cstring, size: uint) int;
fn write(fd: i32, buf: cstring, size: uint) int;
fn open(path: cstring, flags: i32, @infinite) i32;
fn close(fd: i32) i32;
fn lseek(fd: i32, offset: int, flags: u32) int;

fn getcwd(buf: cstring, size: uint) ?cstring;
fn chdir(path: cstring) i32;

fn recv(fd: i32, buf: ptr, len: uint, flags: i32) int;
fn send(fd: i32, buf: ptr, len: uint, flags: i32) int;

fn fcntl(fd: i32, action: i32, @infinite) i32;

// Files
fn stat(path: cstring, stat_buf: libc_stat) i32;
fn fstat(fd: i32, stat_buf: libc_stat) i32;
fn lstat(path: cstring, stat_buf: libc_stat) i32;
fn access(path: cstring, mode: i32) i32;

fn opendir(name: cstring) ?ptr;
fn readdir(dirp: ptr) ?libc_dirent;
fn closedir(dirp: ptr) i32;

// OS
fn popen(command: cstring, type: cstring) ?ptr;
fn fgets(s: cstring, n: i32, stream: ptr) ?cstring;
fn pclose(stream: ptr) i32;
fn system(cmd: cstring) i32;

fn nanosleep(req: libc_timespec, rem: libc_timespec) i32;
fn srand(seed: u32);
fn rand() i32;

// Poll
fn poll(fds: ptr, nfds: u32, timeout: i32) i32;

fn pipe(pipefd: *[i32 x 2]) i32;
//int select(int nfds, fd_set restrict readfds, fd_set restrict writefds, fd_set restrict exceptfds, struct timeval restrict timeout);
fn dup(old_fd: i32) i32;
fn dup2(old_fd: i32, new_fd: i32) i32;

fn socket(domain: i32, type: i32, protocol: i32) i32;
fn connect(sockfd: i32, addr: libc_sockaddr, addrlen: u32) i32;
fn accept(sockfd: i32, addr: ?libc_sockaddr, addrlen: ?ptr) i32;
//fn accept4(sockfd: i32, addr: ?libc_sockaddr, addrlen: ?ptr, flags: i32) i32;
fn shutdown(sockfd: i32, how: i32) i32;
fn bind(sockfd: i32, addr: libc_sockaddr, addrlen: u32) i32;
fn listen(sockfd: i32, backlog: i32) i32;

fn getsockopt(sockfd: i32, level: i32, optname: i32, optval: ptr, optlen: u32) i32;
fn setsockopt(sockfd: i32, level: i32, optname: i32, optval: ptr, optlen: u32) i32;
fn getaddrinfo(host: cstring, port: cstring, hints: libc_addrinfo, res: ptr) i32;
fn freeaddrinfo(info: libc_addrinfo) i32;

//int clone(int (fn)(void *), void stack, int flags, void arg, .../* pid_t parent_tid, void tls, pid_t child_tid */ );
fn fork() i32;
fn vfork() i32;

fn execve(pathname: cstring, argv: ptr, envp: ptr) i32;

//fn wait3(wstatus: i32[1], options: i32, struct rusage rusage) i32;
//fn wait4(pid: i32, wstatus: i32[1], options: i32, struct rusage rusage) i32;

fn kill(pid: i32, sig: i32) i32;
//fn uname(struct utsname buf) i32;

fn rename(oldpath: cstring, newpath: cstring) i32;
fn mkdir(pathname: cstring, mode: u32) i32;
fn rmdir(pathname: cstring) i32;
fn link(oldpath: cstring, newpath: cstring) i32;
fn unlink(pathname: cstring) i32;
fn symlink(target: cstring, linkpath: cstring) i32;
fn readlink(pathname: cstring, buf: ptr, bufsiz: uint) int;

fn chmod(pathname: cstring, mode: u32) i32;
fn fchmod(fd: i32, mode: u32) i32;
fn chown(pathname: cstring, owner: u32, group: u32) i32;
fn fchown(fd: i32, owner: u32, group: u32) i32;
fn lchown(pathname: cstring, owner: u32, group: u32) i32;

fn umask(mask: u32) u32;

fn gettid() i32;

fn exit(status: i32) void $exit;
fn signal(signum: i32, handler: ?fnRef(i32)()) void;
fn raise(sig: i32) i32;

fn _NSGetExecutablePath(buf: ptr, len_u32_ptr: ptr) i32;
fn realpath(dir: ptr, buf: ptr) cstring;

// Time
fn gettimeofday(tv: libc_timeval, tz: ?libc_timezone) i32;
fn settimeofday(tv: libc_timeval, tz: ?libc_timezone) i32;

