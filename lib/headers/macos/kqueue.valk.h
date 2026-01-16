
struct kEvent {
    ident: uint	// identifier for this event
    filter: i16 // filter for event
    flags: u16 // action flags for kqueue
    fflags: u32 // filter flag value
    data: i64 // filter data value
    udata: ptr // opaque user data identifier
}

fn kqueue() i32;
fn kevent(kq: i32, changelist: ?*[<kEvent>], nchanges: i32, eventlist: ?*[<kEvent>], nevents: i32, timeout: ?libc_timespec) i32;
