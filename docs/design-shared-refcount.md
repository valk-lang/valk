# Shared data by reference counting

Status: design + prototype on branch `shared-refcount`, behind `--def SHARED_RC=1`.
Nothing here changes the language: `shared T`, `Lock[T]`, `locked T`, `shared fn`
and channels keep their syntax and checks.

## 1. Problem

Shared memory is collected by a stop-the-world trace (`lib/src/gc/gc-shared.valk`):
the collector locks every thread's gc, runs each thread's local collection,
scans every native and coroutine stack, re-marks the whole live shared graph
(`update_marks`) and sweeps every thread's `shared_items`. The pause grows with
the number of threads, coroutines and live shared objects:

- ~2.6 ms typical, up to 10 ms with 100+ coroutines, 50-114 ms while 10,000
  connections are open.
- Campfire (`shared-frames` branch): one shared `WebSocketFrame` per broadcast
  caused ~70 shared collections per run and moved p99 at 100 clients from
  5.4 to 10.5 ms.

The trigger is memory growth (`mem_shared` doubled plus 4 MB). Programs that
publish and drop a lot of short-lived data (messages, frames, responses) hit it
continuously, even though almost all of that data is acyclic and dies young.

## 2. Idea

Count references per **publication**, defer the stack part of the count
(Deutsch-Bobrow deferred reference counting) and free a publication only after
every thread has looked at its own roots since the count reached zero. No
thread ever stops another one for this.

- Publishing a unique graph makes it a **region**: the objects stay where they
  are, and every object of the graph points to one region header with one
  atomic count.
- A region is freed as a whole. Cycles inside one publication are fine.
- Immutable data can only point to regions that existed when it was
  published, so the region graph of immutable data has no cycles. Cycles
  between regions need a mutable edge (locked data, `@threadsafe` internals);
  those are left to a rare backup collection (section 8).

## 3. Data layout

### Region header

```
struct Region {
    word: uint          // count (bits 0-30) | DEAD (bit 31) | decrement sequence (bits 32-63)
    id: u32             // index in the region table
    owner: ?*Gc         // the publishing thread: its pool blocks hold the items
    items: inline list  // the region's objects (4 inline, then a Bump)
    bytes: uint         // slot bytes, for mem_shared
    flags               // backup-collection mark, retired, has_mutable_edge
}
```

Headers are allocated with `mem.alloc` from a type-stable free list and are
never returned to the system allocator, so a late atomic increment on a
header whose region was freed never touches foreign memory (section 6.4).

### Object to region

The 8-byte object header is `co_count: u32 | flags: u8 | slot_logs: u8 | offset: u16`.
`co_count` of a shared object is no longer a co-owner count: it holds the
region id. The region table is a two-level array (a fixed directory of
chunks of 4096 `*Region`), so `id -> Region` is two loads and readers never
see it move. Ids are recycled through a free list.

Lookup from an inner pointer stays what the conservative scan already does:
`find_root` maps a word to its slot through the block registry, then the slot
header gives the id. Stores and the local GC always hold the object pointer
itself, so they read the header directly.

Rejected alternatives:

- *Copy the graph into a region arena* (aligned chunks, region found by
  masking the address). Needs a forwarding walk and a second allocation per
  publication, and the copy's source still has to be freed by the local GC.
  Worth revisiting only if region-sized frees turn out to fragment the pools.
- *Block registry lookup per count operation*: a binary search per store.

### Static string literals

Literals have a zeroed header (`offset == 0`) and live in the binary. They are
never part of a region, never counted, and every RC path skips `offset == 0`
like the old collector does.

## 4. Publishing

`share(root)` (called where the compiler already publishes: stores into
shared storage, shared globals, `shared fn` environments, thread start)
walks the unique graph as today and:

1. creates a region `R` with count 0, owned by the calling thread;
2. for every object it reaches that is still local: flags it shared, writes
   `R.id` into its header, appends it to `R.items`, strips the ownership tags
   of its fields (as today);
3. for every field that points to an object of an **older** region `S`:
   increments `S` once per field. A field that was tagged co-owned by the local
   GC was already counted (section 5b), so only the tag is stripped;
4. registers `R` in the zero-count table (section 6) as if its count just
   dropped to 0, so a publication that is never stored anywhere is still
   freed.

The store that triggered the publication then increments `R` (or whatever
region the stored value belongs to).

Objects with `gc_free` (file handles, sockets) are published like any other.
Their hook runs on the region's owner thread when the region is freed, which
is a stronger guarantee than today's "any thread performing the shared
collection".

`share()` cannot start a collection (`dont_stop`), and the region is invisible
to other threads until the store that follows it.

## 5. Counting rules

`count(R)` is the number of references into `R` from places that more than
one thread can read, or that the local GC has already looked at:

| Reference held by | Counted when | Released when |
|---|---|---|
| (a) a field of an object of another region | publish (step 3), or a store into a shared object (`property_update`/`property_set` on a shared holder) | overwrite/clear of that field, or the holder's region is freed |
| (b) a field of a local object | the local GC tags it co-owned (`mark_used_props`, `update_props`, `transfer_refs`) | the tag is removed: holder dies (`dis_own_props`), field overwritten (`loop_props_removed`), holder published (converted to (a), net 0) |
| (c) a shared global slot (`shared`, `@shared`) | the store, through a runtime helper (`vgen_shared_store`) | the next store to that slot |
| (d) a thread's roots: native stack, registers, suspended coroutine stacks, thread-local globals | the thread's collection finds it: +1 per distinct region (a "hold") | the thread's next collection, after it took its new holds |

Nothing else is counted:

- **Loads, locals, arguments and returns cost nothing.** That is the point of
  deferring the stack: no borrow elision is needed because borrows are never
  counted.
- **Stores into local objects cost nothing at store time.** The local GC
  already logs stores into owned objects and walks new objects from the
  stack; it counts the reference when it walks the holder, which it does at
  the thread's next collection. Rows (b) are exactly today's atomic
  `co_count` operations on shared objects, redirected to the region.
- Internal references (holder and target in the same region) are never
  counted, so moving data around inside one locked graph is free.

The rule behind the table: **every location another thread can read is a
counted slot** (rows a, c). Locations only the owning thread can read are
covered by that thread's collection (rows b, d), which is what makes the
deferred freeing below sound.

Unsafe code that writes a managed pointer into shared storage with raw
`@ptrv` stores must call `gc.shared_store(slot, value)` instead; `GC_DEBUG`
builds verify counts against a recount in the backup collection.

### Hot regions

A region referenced by many local objects on many threads (a shared config
object) sees one atomic per co-own tag and removal, as today. If profiles show
contention, each thread can keep a small delta table (region -> +/-n) and
apply it at the end of its collection; zero transitions then only happen at
flush time, which the protocol below already tolerates.

## 6. Deferred freeing

### 6.1 Zero transitions

A decrement is one `atomic(word - 1 + (1 << 32))`: it lowers the count and
bumps the 32-bit sequence in the same instruction. When the returned value
says the count reached 0, the thread:

1. reads `g = atomic(zct_epoch + 1)` (the old value; the global epoch moves on),
2. appends `(R, seq, g)` to the zero-count table (a global list behind a
   spinlock; one push per region death).

Increments are `atomic(word + 1)` and do not touch the sequence.

### 6.2 Thread epochs

Every thread's collection reads `e = zct_epoch` **before** it scans its roots
and stores `done_epoch = e` when the collection (holds + local GC counting) is
complete. `min_done` is the minimum over all threads in `gc_list`.

### 6.3 Freeing

A table entry `(R, seq, g)` is eligible when

- `g < min_done`: every live thread completed a collection that started after
  the zero transition, and
- one atomic load of `R.word` shows count 0, no DEAD bit and sequence `seq`:
  this entry is the latest zero transition and nothing was decremented since
  (a decrement needs a count above 0 first).

Entries with a non-zero count or another sequence are dropped: a later zero
transition has its own entry. An eligible region gets `atomic(word | DEAD)`
and is handed to its owner's free inbox (spinlock list on the `Gc`), or freed
on the spot when the processing thread is the owner or the owner is gone.

The owner frees it inside its collection, after `loop_previous_stack_items`,
`loop_updates` and `loop_dis_own` (those lists may still name objects of the
region), before `settle_blocks`:

- for each item, each field pointing to another region: decrement it (may
  produce new zero transitions);
- run `onfree`, clear the header, `slots_used--`, `touch_block`, lower
  `mem_shared`;
- clear the table entry, put the header on the retired list.

### 6.4 Why this is correct

Claim: when an eligible region is freed at time `tf`, no thread can reach it.

Let `t0` be the region's latest zero transition (the entry's), and suppose a
thread T holds a pointer into it at `tf`. Let `ts` be T's last collection
before `tf`; eligibility says `t0 < ts`.

- If T already had the pointer at `ts` (stack, register, coroutine stack,
  thread-local global, or a local object reachable from those), its
  collection counted it: a hold (d) or a co-own tag (b). That count stays
  until T's next collection or until the local holder dies, either way after
  `ts`, and releasing it is a decrement after `t0`, which bumps the sequence.
  Contradiction with the entry being eligible.
- Otherwise T loaded the pointer after `ts`. Its own locals cannot be the
  source (they would have been filled from T's stack, recursing to an earlier
  load). So T read it from a location another thread can write: a field of a
  shared object or a shared global slot. Those are counted slots (a, c): the
  count was above 0 when T read it, so it returned to 0 after `ts > t0`,
  again a later zero transition. Contradiction.
- Channels, locks and thread start hand values over through shared objects,
  so they are the second case.

Stale words: a conservative scan can still find a word that points into a
region that is being freed (a dead slot, or an integer that looks like a
pointer). Its increment is either before the DEAD bit (the region is garbage
anyway by the argument above; the late hold is released at the scanner's next
collection) or after it (the scanner sees DEAD in the returned value, undoes
its increment and ignores the word). Headers are type-stable and a retired
header is reused only when its word shows DEAD with count 0 and a full epoch
has passed, so these late operations always hit a header and never
underflow a live count. Blocks cannot be freed during a scan (the scan holds
`block_lock`).

### 6.5 Liveness: idle and blocked threads

`min_done` waits for the slowest thread. Threads that allocate collect on
their own. A thread blocked in a syscall or an idle event loop has released
its gc lock (that is what lets today's shared collection scan it):

- idle loops already call `collect_if_threshold_almost_reached`; with
  pending table entries they also run a collection when their `done_epoch`
  holds the table back;
- a thread whose table entries wait on a blocked thread `X` takes `X`'s gc
  lock with a try-lock and runs `X`'s collection on its behalf (the
  existing `gc = X` switch), one thread at a time. No thread waits for
  another; a busy thread that never allocates simply delays reclamation.

### 6.6 Explicit collection

`gc.collect_shared()` keeps its meaning ("reclaim shared memory now"): it runs
the backup collection (section 8), which stops every thread once and frees
every unreachable region without waiting for epochs. Tests that assert exact
shared memory keep working.

## 7. Interaction with the local GC, coroutines and threads

- **Local objects holding shared references** count through the existing
  co-own path (5b). When the local GC frees the holder, `dis_own_props`
  decrements. Local GC code must never write the flags byte of a shared
  object (the owner may be freeing it concurrently): the owned-tag branch of
  `dis_own_props` skips `set_no_owner` for shared objects.
- **Coroutines**: `scan_stacks` already scans the running stack, the main
  stack while a coroutine runs and every suspended coroutine. Their shared
  words become holds. Coroutines never move between threads.
- **Thread exit** (`thread_stop`, under `shared_lock`): final collection,
  release all holds, mark the regions the thread owns as orphaned
  (`owner = null`: their blocks become unused blocks without an owner, and
  orphaned regions are freed by whoever finds them eligible, under
  `pool_lock`), drain its free inbox, leave `gc_list` so `min_done` stops
  waiting for it.
- **Thread start**: the handler closure environment is published with
  `share_null_check`; the `Thread` object that stores it is published into
  the `threads` lock, which counts the environment's region (a).
- **Channels** are `Lock[ChannelState]`: `send` stores into a locked
  `Deque`, `recv` clears the slot. Both are counted stores; nothing special.
- **Closures capturing shared values**: a `shared fn` environment is a
  publication like any other; its captured shared values are counted from it.
- **`shared` / `@shared` globals**: counted at the store (5c).
  `vgen_shared_store` emits `gc.shared_global_store(slot, value)` (publish,
  increment the new value, exchange, decrement the old one) instead of
  `share_null_check` plus a plain store; the exchange is an atomic swap, which
  also gives arm64 the release ordering a plain store lacks today. Aggregate
  globals (structs with managed fields) decrement the old fields before the
  copy and publish + increment the new ones after it.

## 8. Locked data and cycles

Locked data is mutable but stays in this scheme:

- A store through a `locked T` view publishes the stored unique graph as a
  new region and counts it from the holder (5a); the old value is
  decremented. Removing an entry from a locked map frees it once nothing
  else holds it. One `Lock` therefore owns many small regions. That is the
  price of per-entry reclamation; merging stored data into the lock's own
  region would keep every removed entry alive as long as the lock.
- `Array`/`Deque` internals that move elements with raw copies stay count
  neutral as long as the moved reference stays inside the same storage, as
  they do today for the local GC's `moved_elements`. Growth publishes the new
  storage (counting every element) and drops the old storage (which
  decrements every element when it is freed).

Cycles between regions need an edge from an older region to a newer one,
which only a mutable store can create. Example: a lock `L` (region `R0`)
whose locked data stores a fresh object `X` (region `R1`) that holds the
shared `L`. When the last outside reference to `L` goes, `R0` and `R1` keep
each other at 1.

Decision for v1: **keep a stop-the-world backup collection for cycles only**.

- It runs on an explicit `gc.collect_shared()` and when `mem_shared` passes
  its trigger (twice the shared memory after the last backup plus 4 MB, as
  today). Reference counting frees acyclic garbage continuously, so
  `mem_shared` only grows past the trigger when cycles leak or when frees are
  held back by a stuck thread.
- In the stopped world every thread first runs its collection, so all
  counts are exact. For each live region it computes the references coming
  from other live regions (one walk over every shared object, the same cost
  as today's mark), takes the regions whose count exceeds that as roots,
  marks what they reach over region edges and frees the rest, decrementing
  the marked regions the dead ones referenced.
- Stores that create an edge to a newer region set `has_mutable_edge` on the
  holder's region. The trigger can be limited to programs that have such
  regions.

Follow-up (v2): concurrent trial deletion (Bacon-Rajan) over candidate regions
(those with `has_mutable_edge` whose count was decremented to a non-zero
value), freeing a garbage cycle through the same epoch rule as a zero count:
record the cycle with the current epoch and the regions' sequences, free it
when every thread collected since and no member's sequence moved. That
removes the last stop-the-world from shared memory.

## 9. Platforms

- Atomics: increments, decrements, the DEAD `or` and the epoch counter are
  sequentially consistent read-modify-writes (`atomic()`), on x64 `lock xadd`
  and `lock or`, on arm64 `ldaddal`/`ldsetal` (LSE) or LL/SC loops.
- arm64 ordering: the region id and fields are written by the publisher
  before the store that makes the graph reachable. Channel and lock stores
  are ordered by the mutex; shared global stores become an atomic exchange
  (section 7).
- Windows: scans already include callee-saved xmm registers and fiber
  stacks; holds come out of the same scan. The free inbox uses the same
  fetch-or spinlock as `mem_usage_peak_lock`; no new OS primitive.
- macOS: nothing specific; the try-lock helping in 6.5 uses the existing
  `MutexStruct`.

## 10. Expected costs

- Per publication: one region header (~64 bytes, recycled) and one table
  entry, plus one atomic per field pointing to an older region.
- Per store of a shared value into shared storage (channel send, locked
  store, shared global): one increment, one decrement for the old value.
- Per thread collection: one increment per distinct region held by roots,
  one decrement per previously held region, a short spinlock section if the
  table has entries.
- Memory: a dead region lives until every thread has collected once since
  its count reached zero, normally a few local collection intervals. With
  helping, idle threads do not stretch this.
- Latency: no stop-the-world for acyclic data. The local collection of a
  thread gets the work of freeing its own dead regions (proportional to
  their size, like freeing local garbage).
- Lock-heavy programs: one region header per stored graph. A solo-object
  region (most map values, boxed strings) could keep its count in the object
  header instead (a later optimization; needs a 64-bit atomic header word).

## 11. Migration plan

Every step keeps `make test`, `make test-win` and `make test-gc-shared-stress`
passing; the new code is behind `--def SHARED_RC=1` until the last step.

1. Region headers, table, publish into regions, counts for rows (a)-(d), the
   zero-count table and deferred freeing, explicit `collect_shared` doing the
   backup collection. Start with leaf data: objects without references inside
   are trivially acyclic and exercise the whole free path.
2. General graphs: region-to-region counting at publish, counted stores into
   locked data, free-time decrements.
3. Shared globals through the counted helper, thread exit hand-over, helping
   blocked threads.
4. The backup collection as the cycle collector with its memory trigger; the
   old shared trace (`update_marks`, `shared_items`, `shared_dump`) removed
   under the define.
5. Benchmarks and Campfire; then make it the default, delete the old code.
6. Later: trial deletion for cycles, solo regions, per-thread delta tables.

## 12. Tests

- Existing: `tests/src/gc-shared.valk` (exact `mem_shared` after
  `collect_shared`, multi-thread spam, co-ownership across collects, thread
  suspend, spinning threads, collection run by another thread),
  `make test-gc-shared-stress`, threads, channels, locks.
- New, all with exact counts or `gc_free` counters:
  - a published message dropped by every receiver is freed **without**
    `collect_shared` once every thread has collected (mark_count unchanged);
  - a region held only by a local object stored after the holder thread's
    last collection survives a zero transition elsewhere;
  - a region held only on a suspended coroutine's stack survives;
  - a region held only by a blocked thread's registers survives (helping
    path);
  - a value moved through a channel to another thread and stored into a
    local object there survives while the sender drops it;
  - overwriting and clearing a shared global frees the old value;
  - locked map: removed entries are freed, kept ones survive;
  - a cycle through a lock is freed by `collect_shared` and only by it;
  - a `gc_free` object in a region runs its hook exactly once, on the
    publishing thread;
  - a thread that exits leaves its regions freeable (orphan path);
  - stale-word stress: threads publishing and dropping regions while others
    scan (the DEAD path), with `GC_DEBUG` recount verification.
