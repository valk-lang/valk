
struct OVERLAPPED {
    Internal: uint
    InternalHigh: uint
    Offset: u32
    OffsetHigh: u32
    hEvent: HANDLE
}

fn CreateIoCompletionPort(FileHandle: ptr, ExistingCompletionPort: ?ptr, CompletionKey: uint, NumberOfConcurrentThreads: u32) HANDLE;
fn GetQueuedCompletionStatus(CompletionPort: ptr, lpNumberOfBytesTransferred: ptr, lpCompletionKey: ptr, lpOverlapped: ptr, dwMilliseconds: u32) bool;
fn PostQueuedCompletionStatus(CompletionPort: HANDLE, dwNumberOfBytesTransferred: u32, dwCompletionKey: uint, lpOverlapped: ?ptr) bool;
fn SetFileCompletionNotificationModes(FileHandle: HANDLE, Flags: u8) bool;

fn NtAssociateWaitCompletionPacket(WaitCompletionPacketHandle: HANDLE, IoCompletionHandle: HANDLE, TargetObjectHandle: HANDLE, KeyContext: ?ptr, ApcContext: ?ptr, IoStatus: i32, IoStatusInformation: uint, AlreadySignaled: ?&bool) i32;
fn NtCreateWaitCompletionPacket(WaitCompletionPacketHandle: &HANDLE, DesiredAccess: u32, ObjectAttributes: ?ptr) i32;

