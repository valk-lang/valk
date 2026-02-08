
@shared stderr : ?ptr;
@shared stdin : ?ptr;
@shared stdout : ?ptr;

alias FILE for ptr
alias SOCKET for uint
alias HANDLE for uint
alias BOOLEAN for u8

// HANDLE : ptr
// DWORD : u32
// ULONG : u32

alias read for _read;
alias write for _write;
alias open for _open;
alias close for _close;
alias sync for _flushall;

alias stat for _stat;
alias mkdir for _mkdir;
alias rmdir for _rmdir;
alias unlink for _unlink;

alias popen for _popen;
alias pclose for _pclose;
alias getcwd for _getcwd;
alias chdir for _chdir;

alias poll for WSAPoll;

fn malloc(size: uint) ptr;
fn free(adr: ptr) void;

fn getenv(key: cstring) ?cstring;
fn GetLastError() u32;

fn _setmode(fd: i32, mode: i32) i32;
fn _read(fd: i32, buf: cstring, size: u32) int;
fn _write(fd: i32, buf: cstring, size: u32) int;
fn _open(path: cstring, flags: i32, mode: i32) i32;
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

fn ReadFile(hFile: uint, lpBuffer: ptr, nNumberOfBytesToRead: u32, lpNumberOfBytesRead: ?ptr, lpOverlapped: ?ptr) bool;
fn WriteFile(hFile: uint, lpBuffer: ptr, nNumberOfBytesToWrite: u32, lpNumberOfBytesWritten: ?ptr, lpOverlapped: ?ptr) bool;
fn CreateFileA(path: cstring, access: u32, share_mode: u32, lpSecurityAttributes: ?ptr, dwCreationDisposition: u32, dwFlagsAndAttributes: u32, hTemplateFile: HANDLE) HANDLE;

// OS
fn _popen(command: cstring, type: cstring) ?FILE;
fn fgets(s: cstring, n: i32, stream: FILE) ?cstring;
fn _pclose(stream: FILE) i32;
fn system(cmd: cstring) i32;
fn Sleep(ms: u32) void;

fn srand(seed: u32);
fn rand() i32;

// Poll
fn WSAPoll(fds: ptr, nfds: uint, timeout: i32) i32;
fn WSAGetLastError() i32;
fn WSAStartup(wVersionRequired: u16, lpWSAData: ptr) i32;
fn WSACleanup() i32;
fn WSARecv(fd: uint, lpBuffers: ?ptr, dwBufferCount: u32, lpNumberOfBytesRecvd: ?&u32, lpFlags: ?&u32, lpOverlapped: ?ptr, lpCompletionRoutine: ?ptr) i32;
fn WSASend(fd: uint, lpBuffers: ?ptr, dwBufferCount: u32, lpNumberOfBytesSent: ?&u32, dwFlags: u32, lpOverlapped: ?ptr, lpCompletionRoutine: ?ptr) i32;
fn WSASocketA(af: i32, type: i32, protocol: i32, lpProtocolInfo: ?ptr, g: uint, dwFlags: u32) SOCKET;
fn WSAAccept(s: SOCKET, name: ?libc_sockaddr, namelen: i32, lpfnCondition: ?ptr, dwCallbackData: ?&u32) i32;
fn WSAConnect(s: SOCKET, name: libc_sockaddr, namelen: i32, lpCallerData: ?ptr, lpCalleeData: ?ptr, lpSQOS: ?ptr, lpGQOS: ?ptr) i32;
fn WSAIoctl(s: SOCKET, dwIoControlCode: u32, lpvInBuffer: ptr, cbInBuffer: u32, lpvOutBuffer: ptr, cbOutBuffer: u32, lpcbBytesReturned: &u32, lpOverlapped: ?ptr, lpCompletionRoutine: ?ptr) i32;
fn closesocket(fd: uint) i32;
fn ioctlsocket(fd: uint, cmd: int, arg: ptr) i32;

fn CreatePipe(hReadPipe: &HANDLE, hWritePipe: &HANDLE, lpPipeAttributes: ?ptr, nSize: u32) bool;
fn CreateNamedPipeA(name: cstring, dwOpenMode: u32, dwPipeMode: u32, nMaxInstances: u32, nOutBufferSize: u32, nInBufferSize: u32, nDefaultTimeOut: u32, lpSecurityAttributes: ?ptr) HANDLE;
fn ConnectNamedPipe(pipe: HANDLE, lpOverlapped: ?ptr) bool;
//fn pipe(pipefd: i32[2]) i32;
//int select(int nfds, fd_set restrict readfds, fd_set restrict writefds, fd_set restrict exceptfds, struct timeval restrict timeout);
fn dup(old_fd: i32) i32;
fn dup2(old_fd: i32, new_fd: i32) i32;

fn socket(domain: i32, type: i32, protocol: i32) uint;
fn connect(sockfd: uint, addr: libc_sockaddr, addrlen: u32) i32;
fn accept(sockfd: uint, addr: ?libc_sockaddr, addrlen: ?ptr) uint;
fn AcceptEx(sListenSocket: SOCKET, sAcceptSocket: SOCKET, lpOutputBuffer: ptr, dwReceiveDataLength: u32, dwLocalAddressLength: u32, dwRemoteAddressLength: u32, lpdwBytesReceived: &u32, lpOverlapped: ?ptr) bool;
//fn accept4(sockfd: i32, addr: ?libc_sockaddr, addrlen: ?ptr, flags: i32) i32;
fn shutdown(sockfd: uint, how: i32) i32;
fn bind(sockfd: uint, addr: libc_sockaddr, addrlen: u32) i32;
fn listen(sockfd: uint, backlog: i32) i32;

fn getsockopt(sockfd: uint, level: i32, optname: i32, optval: ptr, optlen: u32) i32;
fn setsockopt(sockfd: uint, level: i32, optname: i32, optval: ptr, optlen: u32) i32;
fn getaddrinfo(host: cstring, port: cstring, hints: libc_addrinfo_fix, res: ptr) i32;
fn freeaddrinfo(info: libc_addrinfo_fix) i32;

//int clone(int (fn)(void *), void stack, int flags, void arg, .../* pid_t parent_tid, void tls, pid_t child_tid */ );
fn fork() i32;
fn vfork() i32;

fn execve(pathname: cstring, argv: ptr, envp: ptr) i32;

//fn wait3(wstatus: i32[1], options: i32, struct rusage rusage) i32;
//fn wait4(pid: i32, wstatus: i32[1], options: i32, struct rusage rusage) i32;

fn kill(pid: i32, sig: i32) i32;
//fn uname(struct utsname buf) i32;

fn _getcwd(buf: cstring, size: i32) ?cstring;
fn _chdir(path: cstring) i32;

fn rename(oldpath: cstring, newpath: cstring) i32;
fn _mkdir(pathname: cstring, mode: u32) i32;
fn _rmdir(pathname: cstring) i32;
fn link(oldpath: cstring, newpath: cstring) i32;
fn _unlink(pathname: cstring) i32;
fn symlink(target: cstring, linkpath: cstring) i32;
fn GetModuleFileNameA(hmodule: ?ptr, buf: ptr, len: u32) u32;
fn GetFileAttributesA(path: cstring) u32;
fn GetCurrentDirectory(buffer_size: u32, buffer: ptr) u32;
fn CreateSymbolicLinkA(link: cstring, target: cstring, flags: u32) BOOLEAN;
fn _fullpath(buf: ptr, path: cstring, maxlen: uint) cstring;

fn chmod(pathname: cstring, mode: u32) i32;
fn fchmod(fd: i32, mode: u32) i32;
fn chown(pathname: cstring, owner: u32, group: u32) i32;
fn fchown(fd: i32, owner: u32, group: u32) i32;
fn lchown(pathname: cstring, owner: u32, group: u32) i32;

fn umask(mask: u32) u32;

fn _flushall() void;

fn gettid() i32;

fn exit(status: i32) void $exit;
fn signal(signum: i32, handler: ?fnptr(i32)()) void;
fn raise(sig: i32) i32;
fn _get_errno(int_ref: ptr) ptr;

fn CreateThread(lpThreadAttributes: ?ptr, dwStackSize: uint, lpStartAddress: ptr, lpParameter: ?ptr, dwCreationFlags: u32, lpThreadId: ?ptr) HANDLE;
fn TerminateThread(handle: ptr, exit_code: i32) bool;
fn WaitForSingleObject(handle: ptr, timeout_ms: u32) u32;
fn CloseHandle(handle: HANDLE) bool;

fn CreateMutexA(lpMutexAttributes: ?ptr, bInitialOwner: bool, lpName: ?cstring) HANDLE;
fn ReleaseMutex(mutex: HANDLE) void;

// Time
fn GetSystemTimeAsFileTime(ft: libc_FILETIME) void;
fn CreateWaitableTimerExW(lpTimerAttributes: ?ptr, name: ?ptr, flags: u32, dwDesiredAccess: u32) ?HANDLE;
fn SetWaitableTimer(hTimer: HANDLE, due: &i64, lPeriod: i64, pfnCompletionRoutine: ?ptr, lpArgToCompletionRoutine: ?ptr, fResume: bool) bool;

