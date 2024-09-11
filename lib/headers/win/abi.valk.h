
shared stderr : ?ptr;
shared stdin : ?ptr;
shared stdout : ?ptr;

alias FILE as ptr
alias SOCKET as uint
alias HANDLE as ptr

// HANDLE : ptr
// DWORD : u32
// ULONG : u32

alias read as _read;
alias write as _write;
alias open as _open;
alias close as _close;
alias sync as _flushall;

alias stat as _stat;
alias mkdir as _mkdir;
alias rmdir as _rmdir;
alias unlink as _unlink;

alias popen as _popen;
alias pclose as _pclose;

alias poll as WSAPoll;

fn malloc(size: uint) ptr;
fn free(adr: ptr) void;

fn getenv(key: cstring) ?cstring;

fn _read(fd: i32, buf: cstring, size: uint) int;
fn _write(fd: i32, buf: cstring, size: u32) int;
fn _open(path: cstring, flags: i32, mode: u32) i32;
fn _close(fd: i32) i32;

fn recv(fd: uint, buf: ptr, len: i32, flags: i32) i32;
fn send(fd: uint, buf: ptr, len: i32, flags: i32) i32;

// Files
fn _stat(path: cstring, stat_buf: libc_stat) i32;
fn fstat(fd: i32, stat_buf: libc_stat) i32;
fn lstat(path: cstring, stat_buf: libc_stat) i32;

fn FindFirstFileA(lpFileName: cstring, lpFindFileData: ptr) ptr;
fn FindNextFileA(hFindFile: ptr, lpFindFileData: ptr) bool;
fn FindClose(hFindFile: ptr) bool;

// OS
fn _popen(command: cstring, type: cstring) ?FILE;
fn fgets(s: cstring, n: i32, stream: FILE) ?cstring;
fn _pclose(stream: FILE) i32;
fn system(cmd: cstring) i32;
fn Sleep(ms: u32) void;

// Poll
fn WSAPoll(fds: ptr, nfds: u32, timeout: i32) i32;
fn WSAGetLastError() i32;
fn WSAStartup(wVersionRequired: u16, lpWSAData: ptr) i32;
fn closesocket(fd: uint) i32;
fn ioctlsocket(fd: uint, cmd: int, arg: ptr) i32;

//fn pipe(pipefd: i32[2]) i32;
//int select(int nfds, fd_set restrict readfds, fd_set restrict writefds, fd_set restrict exceptfds, cstruct timeval restrict timeout);
fn dup(old_fd: i32) i32;
fn dup2(old_fd: i32, new_fd: i32) i32;

fn socket(domain: i32, type: i32, protocol: i32) uint;
fn connect(sockfd: uint, addr: libc_sockaddr, addrlen: i32) i32;
fn accept(sockfd: uint, addr: ?libc_sockaddr, addrlen: ?ptr) uint;
//fn accept4(sockfd: i32, addr: ?libc_sockaddr, addrlen: ?ptr, flags: i32) i32;
fn shutdown(sockfd: uint, how: i32) i32;
fn bind(sockfd: uint, addr: libc_sockaddr, addrlen: i32) i32;
fn listen(sockfd: uint, backlog: i32) i32;

fn getsockopt(sockfd: uint, level: i32, optname: i32, optval: ptr, optlen: u32) i32;
fn setsockopt(sockfd: uint, level: i32, optname: i32, optval: ptr, optlen: u32) i32;
fn getaddrinfo(host: cstring, port: cstring, hints: libc_addrinfo_fix, res: ptr) i32;
fn freeaddrinfo(info: libc_addrinfo_fix) i32;

//int clone(int (fn)(void *), void stack, int flags, void arg, .../* pid_t parent_tid, void tls, pid_t child_tid */ );
fn fork() i32;
fn vfork() i32;

fn execve(pathname: cstring, argv: ptr, envp: ptr) i32;

//fn wait3(wstatus: i32[1], options: i32, cstruct rusage rusage) i32;
//fn wait4(pid: i32, wstatus: i32[1], options: i32, cstruct rusage rusage) i32;

fn kill(pid: i32, sig: i32) i32;
//fn uname(cstruct utsname buf) i32;

fn getcwd(buf: cstring, size: uint) cstring;
//char getwd(char buf);
//char get_current_dir_name();
//int chdir(path: cstring);
//int fchdir(int fd);

fn rename(oldpath: cstring, newpath: cstring) i32;
fn _mkdir(pathname: cstring, mode: u32) i32;
fn _rmdir(pathname: cstring) i32;
fn link(oldpath: cstring, newpath: cstring) i32;
fn _unlink(pathname: cstring) i32;
fn symlink(target: cstring, linkpath: cstring) i32;
fn GetModuleFileNameA(hmodule: ?ptr, buf: ptr, len: u32) u32;
fn GetFileAttributesA(path: cstring) u32;

fn chmod(pathname: cstring, mode: u32) i32;
fn fchmod(fd: i32, mode: u32) i32;
fn chown(pathname: cstring, owner: u32, group: u32) i32;
fn fchown(fd: i32, owner: u32, group: u32) i32;
fn lchown(pathname: cstring, owner: u32, group: u32) i32;

fn umask(mask: u32) u32;

fn gettimeofday(tv: libc_timeval, tz: libc_timezone) i32;
fn settimeofday(tv: libc_timeval, tz: libc_timezone) i32;
//time_t time(time_t tloc);

//int sysinfo(cstruct sysinfo info);

fn _flushall() void;

fn gettid() i32;

fn exit(status: i32) void;
fn signal(signum: i32, handler: ?fn(i32)()) void;
fn raise(sig: i32) i32;
fn _get_errno(int_ref: ptr) ptr;

fn CreateThread(lpThreadAttributes: ?ptr, dwStackSize: uint, lpStartAddress: ptr, lpParameter: ?ptr, dwCreationFlags: u32, lpThreadId: ?ptr) ?ptr;
fn TerminateThread(handle: ptr, exit_code: i32) bool;
fn WaitForSingleObject(handle: ptr, timeout_ms: u32) u32;
fn CloseHandle(handle: ptr) bool;

fn CreateMutexA(lpMutexAttributes: ?ptr, bInitialOwner: bool, lpName: ?cstring) HANDLE;
fn ReleaseMutex(mutex: ptr) void;
