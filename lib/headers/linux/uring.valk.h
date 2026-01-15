
struct io_uring_sqe {
    opcode: u8
    flags: u8
    ioprio: u16
    fd: i32
    off: u64 // offset, aka. addr2
    addr: u64 // aka. splice_off_in
    len: u32 // buffer size or number of iovecs
    event_flags: u32
    user_data: u64 // data to be passed back at completion time
    buf_index: u16 // aka. buf_group
    personality: u16
    file_index: u32 // aka. splice_fd_in: i32
    pad2: [u64 x 8]
}

struct io_uring_cqe {
    user_data: u64
    res: i32
    flags: u32
}

struct io_uring_sq {
        khead: *u32
        ktail: *u32
        kring_mask: *u32
        kring_entries: *u32
        kflags: *u32
        kdropped: *u32
        array: *u32
        sqes: *[<io_uring_sqe>]
        sqe_head: u32
        sqe_tail: u32
        ring_sz: uint
        ring_ptr: ptr
        pad: [u32 x 4]
}

struct io_uring_cq {
        khead: *u32
        ktail: *u32
        kring_mask: *u32
        kring_entries: *u32
        kflags: *u32
        koverflow: *u32
        cqes: *[<io_uring_cqe>]
        ring_sz: uint
        ring_ptr: ptr
        pad: [u32 x 4]
}

struct io_uring {
    sq: <io_uring_sq>
    cq: <io_uring_cq>
    flags: u32
    ring_fd: i32
    features: u32
    pad: [u32 x 3]
}

// struct io_uring_params {
//     sq_entries: u32
//     cq_entries: u32
//     flags: u32
//     sq_thread_cpu: u32
//     sq_thread_idle: u32
//     features: u32
//     wq_fd: u32
//     resv: [u32 x 3]
//     sq_off: <io_sqring_offsets>
//     cq_off: <io_cqring_offsets>
// }

enum IOSQE {
    FIXED_FILE_BIT
    IO_DRAIN_BIT
    IO_LINK_BIT
    IO_HARDLINK_BIT
    ASYNC_BIT
    BUFFER_SELECT_BIT
}

fn io_uring_queue_init(entries: u32, ring: ptr, flags: u32) i32;
