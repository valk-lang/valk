
struct OVERLAPPED {
    Internal: uint
    InternalHigh: uint
    Offset: u32
    OffsetHigh: u32
    hEvent: HANDLE
}

fn CreateIoCompletionPort(FileHandle: ptr, ExistingCompletionPort: ?ptr, CompletionKey: uint, NumberOfConcurrentThreads: u32) ptr;
fn GetQueuedCompletionStatus(CompletionPort: ptr, lpNumberOfBytesTransferred: ptr, lpCompletionKey: ptr, lpOverlapped: ptr, dwMilliseconds: u32) bool;

