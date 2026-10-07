# Shared data by reference counting

Status: prototype on branch `shared-refcount`, behind `--def SHARED_RC=1`
(`make test-rc` runs the suite with it). Nothing here changes the language:
`shared T`, `Lock[T]`, `locked T`, `shared fn` and channels keep their syntax
and checks. Measurements are in section 13, the assessment in section 14.

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

Count references per **region**, defer the stack part of the count
(Deutsch-Bobrow deferred reference counting) and free a region only after
every thread has collected since its count reached zero. No thread stops
another one for this.

- Immutable data (what is published as `shared T`) is one region per
  publication: one count for the whole graph, cycles inside it are fine, and
  nothing can unlink an object inside it, so it dies as a whole.
- Mutable shared data (the value of a `Lock`, and everything stored under it)
  can lose objects while the rest lives on, so each of its objects is a
  region of its own.
- Cycles between regions need a store into mutable data. They are left to a
  backup collection: the old stop-the-world rendezvous, now only for cycles
  (section 9).

## 3. Data layout

### Region header

```
struct Region {
    word      // count (bits 0-30) | DEAD (bit 31) | decrement sequence (bits 32-63)
    id        // index in the region table; what objects store
    owner     // the publishing thread's Gc: its pool blocks hold the objects
    items     // the region's objects
    bytes     // slot bytes, for mem_shared
    live, mark, freeable, internal   // backup collection
    epoch     // when it was retired
    stamp     // the collection that last took a hold on it
    next      // inbox / retired / free lists
}
```

Headers live in a two-level table (a fixed directory of 4096-entry chunks,
`regions.valk`) and are never returned to the system allocator, so a late
atomic on a freed header hits a header, never foreign memory. Each thread
keeps its own free and retired header lists; a retired header is reused once
every thread collected since and no stale hold is left on it.

### Object to region

The 8-byte object header is `co_count: u32 | flags: u8 | slot_logs: u8 | offset: u16`.
A shared object's `co_count` holds its region id (local objects keep their
co-owner count there). Stores and the local GC hold the object pointer, so they
read the header directly; the conservative scan finds the object through the
block registry as before.

Rejected: copying a publication into its own arena (a forwarding walk and a
second allocation per publication) and a block-registry lookup per count
operation.

### Static string literals

Literals have a zeroed header (`offset == 0`). They are never part of a region
and every count path skips them, as the old collector does.

## 4. Publishing

`gc.share(root)` publishes immutable data; a store into shared storage publishes
the stored value (`rc_share`, four passes over the unique graph):

1. collect the graph, strip its ownership tags (fixing the local co-owner
   counts), count each reference to an object of an older region;
2. mark mutable data: everything when the store goes into a slot that is not
   declared `shared T` (it is locked data), else what the values of `Lock`
   objects reach;
3. flag every object shared, give the immutable part one region and every
   mutable object a region of its own; local co-owners outside the graph
   (none in safe code) are added to the count, as they release through it;
4. count the references between the new regions; a new region with count 0
   goes to the zero-count table, so a publication nothing stores is freed too.

The compiler tells the runtime which kind of store it is: a slot declared
`shared T` stores through `property_update_shared` / `property_set_shared`,
every other slot through `property_update` / `property_set`; layouts of
`Lock[T]` instances carry kind 2 instead of 0 (`ir_write_allocator_helpers`).

Objects with `gc_free` (file handles, sockets) are published like any other.
Their hook runs on the publishing thread when the region is freed.

## 5. Counting rules

`count(R)` is the number of references into `R` from places that more than
one thread can read, or that the local GC has already looked at:

| Reference held by | Counted when | Released when |
|---|---|---|
| (a) a field of an object of another region | publish, or a store into a shared object | overwrite/clear of the field, or the holder's region is freed |
| (b) a field of a local object | the local GC tags it co-owned (`mark_used_props`, `update_props`, `transfer_refs`) | the tag goes: holder dies (`dis_own_props`), field overwritten (`loop_props_removed`), holder published (it becomes (a)) |
| (c) a `shared` / `@shared` global | the store (`shared_global_store`, an exchange under a spinlock) | the next store to that global |
| (d) a thread's roots: native stack, registers, suspended coroutine stacks, thread-local globals | the thread's collection finds it: +1 per region (a "hold") | the thread's next collection, after it took its new holds |

Nothing else is counted. Loads, locals, arguments and returns cost nothing,
and so do stores into local objects: the local GC counts them when it walks
the holder at the thread's next collection. Rows (b) are today's atomic
`co_count` operations on shared objects, redirected to the region. References
inside one region are never counted.

The rule behind the table: **every location another thread can read is a
counted slot** (rows a, c). Locations only the owning thread reads are counted
by that thread's collection (rows b, d), which is what makes deferred freeing
sound.

Raw writes into shared storage have to keep the counts: `transfer_refs` into
shared storage counts the copied references (a locked array that grows), and
raw moves inside one storage (`Array.remove`, `prepend`) are count-neutral.

## 6. Deferred freeing

### 6.1 Zero transitions

A decrement is one `atomic(word - 1 + (1 << 32))`: it lowers the count and
bumps the sequence in the same instruction. When it reached 0, the thread
appends `(R, sequence, rc_epoch)` to its own zero-count list (no lock).
Increments are `atomic(word + 1)`.

### 6.2 Epochs

Every collection starts with `e = atomic(rc_epoch + 1) + 1` and, once its
holds and co-owner counts are complete, publishes `done_epoch = e`. A zero
transition that read epoch `g` happened before every collection with
`done_epoch > g` started. `min_done` is the minimum over `gc_list`.

### 6.3 Freeing

In each collection a thread moves its own entries to the shared table and
looks at all of them. An entry is eligible when `g < min_done` and one atomic
load of `R.word` shows count 0, no DEAD bit and the entry's sequence: it is
the latest zero transition and nothing was decremented since (a decrement
needs a count above 0 first). Entries with a count or another sequence are
dropped; a later zero transition has its own entry. An eligible region gets
`atomic(word | DEAD)` and goes to its owner: freed on the spot when that is
the collecting thread or a thread that exited, otherwise put in the owner's
inbox, which it frees at its next collection.

A region is freed inside its owner's collection, after the local lists that
may still name its objects were processed and before the allocation windows
close: references to other regions are released (possibly new zero
transitions), `onfree` runs, slots are cleared, the header is retired.

### 6.4 Why this is correct

When an eligible region is freed at time `tf`, no thread can reach it. Let
`t0` be its latest zero transition, and suppose thread T holds a pointer into
it at `tf`. Let `ts` be the start of T's last collection before `tf`;
eligibility says `t0 < ts`.

- If T had the pointer at `ts` (a root, or a local object reachable from
  one), that collection counted it: a hold or a co-own tag. That count lasts
  until T's next collection or until the holder dies; releasing it is a
  decrement after `t0`, which bumps the sequence. Contradiction.
- Otherwise T loaded it after `ts`, from a location another thread can write
  (its own locals were filled from its stack): a field of a shared object or
  a shared global. Those are counted, so the count was above 0 at the load
  and fell to 0 again later: a zero transition after `ts > t0`.
  Contradiction.

A dead region's references are released when it is freed; that zero
transition starts a new wait (freeing a chain takes one round per level).

Stale words: a conservative scan may find a word pointing into a region that
is being freed. Its increment is either before the DEAD bit (the region is
garbage anyway; the late hold is released at the scanner's next collection)
or after it (the scanner sees DEAD, undoes its increment and ignores the
word). Headers are type-stable and reused only with a DEAD word and no hold,
and recycling bumps the sequence past every old entry.

### 6.5 Threads that do not collect

`min_done` waits for the slowest thread. After its own collection a thread
looks at the threads whose gc lock is free (they block) and are behind it:

- one that has not run since a collection was run for it only gets its epoch
  moved on: it let go of its gc (`release_lock` counts that), so nothing it
  references changed;
- one that did not collect since our previous collection gets its collection
  run by us (the existing `gc = other` switch, a try-lock, never a wait);
- threads that keep up with us are left alone, and a thread that computes
  without allocating or blocking only delays frees.

Tried and dropped (numbers in section 13):

- Rounds triggered like the old shared collection (shared memory doubled plus
  4 MB, every thread collects once per round): dead chains free one level per
  round, so under a steady publish rate the dead memory at the end of a round
  set the next trigger and it ratcheted up (90-100 MB instead of 6 MB on the
  message benchmark).
- Threads that hold back the oldest dead region collect at their idle point:
  moves the work off the busiest thread (+9% instead of +15% wall time), but a
  thread with many coroutines then collects at almost every event-loop
  iteration; under Wine the suite ran into network timeouts.

## 7. Interaction with the local GC, coroutines and threads

- **Local holders** count through the existing co-own path. The local GC never
  writes the flags byte of a shared object (its owner may be freeing it).
- **Coroutines**: `scan_stacks` already scans every suspended coroutine;
  their shared words become holds. Coroutines never move between threads.
- **Thread-local globals** sit in the thread's stack block on Linux and are
  scanned conservatively: runtime walk contexts kept in globals are cleared
  after use, or they pin a region (found by the leak tests).
- **Thread exit**: the final collection releases the holds; the thread's live
  regions lose their owner (freed under `orphan_lock` later), its entries and
  headers go to the shared lists, its inbox is freed.
- **Channels** are `Lock[ChannelState]`: `send` stores into locked storage,
  `recv` clears the slot; both counted. A value sent as `shared T` is one
  region.
- **Closures**: a `shared fn` environment is a publication; its captured
  shared values are counted from it.
- **Globals**: `vgen_shared_store` calls `gc.shared_global_store(slot, value)`,
  which publishes, counts the new value, exchanges and releases the old one.
  It is `$noinline`: inlined, the old value stayed in a callee-saved register
  of the caller and a later scan held it. Aggregate globals release their old
  fields before the copy (`GC_WALK.unshare`) and publish + count the new ones
  after it.

## 8. Mutable data

A store through a `locked T` view publishes the stored graph per object and
counts it from the holder; the old value is released. Removing an entry from a
locked map frees it once nothing else holds it, at the price of one region
header per object of mutable data.

Why per object: with one region per stored graph, a store that unlinks an
object inside a live region (a locked array's storage replaced on growth,
a deque moving its halves) leaves that object and everything it references
alive until the whole region dies. Channels did exactly that and kept every
message alive. `GC_DEBUG` builds panic when a store unlinks an object inside
a multi-object region, so an `@threadsafe` class that mutates immutable data
shows up in the tests.

## 9. Cycles: the backup collection

Cycles between regions need an edge created by a store into mutable data. Two
examples: a lock whose data holds an object that holds the lock; two locked
objects pointing at each other.

The old rendezvous stays as the cycle collector:

- it runs on an explicit `gc.collect_shared()` and when `mem_shared` passes its
  trigger, `2 x mem_shared + step` after the last backup; the step starts at
  4 MB and doubles (up to 1 GB) after every backup that found less than an
  eighth of the shared memory in cycles, so live data that grows and shrinks
  (queues) does not keep stopping threads;
- every thread is stopped and has collected, so counts are exact. For each
  live region it subtracts the references from other live regions (one walk
  over every shared object, the old mark's cost); regions with references left
  are roots; what they do not reach is garbage. Garbage with a count of 0 and
  what only it reaches would have been freed anyway; the rest is cyclic and
  feeds the step.

Follow-up: concurrent trial deletion (Bacon-Rajan) over regions of mutable
data, freeing a garbage cycle through the same epoch rule, would remove the
last stop-the-world.

## 10. Platforms

- Atomics are sequentially consistent read-modify-writes (`atomic()`): `lock
  xadd` / `lock cmpxchg` on x64, LSE or LL/SC on arm64.
- A published object's region id is written before its shared flag; the
  store that makes the graph reachable follows. Channel and lock stores are
  ordered by the mutex; shared global stores take a spinlock.
- Windows: holds come out of the same scan (xmm registers, fiber stacks). The
  helping try-lock is `WaitForSingleObject(mutex, 0)`. `make test-win` passes
  under Wine with `--def SHARED_RC=1`.
- macOS and linux-arm64: nothing specific; not run yet.

## 11. Costs

- Per publication of immutable data: one region header (~100 bytes, reused)
  and one atomic per reference to an older region. Per object of mutable
  data: one region header.
- Per store into shared storage: one increment, one decrement for the old value.
- Per collection: one atomic per distinct region its roots hold, one per region
  held the time before, two short spinlock sections for the zero-count table,
  and the collections it runs for blocked threads.
- A dead region lives until every thread collected once after its count
  reached 0 (one more round per level of a dead chain).

## 12. Tests

- `tests/src/gc-shared.valk` and the rest of the suite pass with the define
  (`make test-rc`, `make test-win FLAGS=--def SHARED_RC=1`).
- `tests/src/gc-shared-rc.valk` (only with the define): a value sent to other
  threads is freed without a shared collection; a value held only by a new
  local object, or only by a suspended coroutine, survives its count reaching
  0; overwriting a shared global frees the old values; objects removed from
  locked data are freed and the rest survives; a cycle through a lock is freed
  by `collect_shared` and only by it; a value published by an exited thread is
  freed; values bouncing between threads are each freed exactly once.
- `GC_DEBUG` checks: increments or decrements of a dead region, count
  underflow and overflow, a hold underflow, a shared object referencing a
  local one, a store unlinking an object inside a multi-object region, and in
  the backup collection a count below the references other regions hold.

## 13. Results (2026-10-07)

All on linux-x64 (12 cores), base = the same branch without the define, the
final helping policy of 6.5. The machine was shared with other jobs; numbers
are medians of alternating runs, benchmarks pinned to CPUs 4-11.

| Benchmark (release) | base | SHARED_RC |
|---|---|---|
| 4 threads, 20k shared 20 KB messages (sgc) | 74 ms wall, 233 ms CPU, 165 shared collections (max 31-44 us), RSS 7-9 MB | 85 ms wall, 242 ms CPU, 0 shared collections, RSS 5.7-6.1 MB |
| gc-multi "mt-shared publish/replace" | 9-10 ms, peak 6.1-6.3 MB | 8 ms, peak 2.2 MB |
| binary-tree 19, binary-tree-multi 19, merkletrees 18, json, objects, gc-overhead | unchanged (±2%) | unchanged |
| locked HashMap, 200k entries filled then 5x replaced, 1 thread | 22 + 89 ms | 50 + 210 ms (mem_shared 26 MB instead of 51 MB, same RSS) |

Campfire `shared-frames`, `bench/run --quick --apps valk --routes static_css
--upload-reps 0 --cable-clients 100 1000 10000 --deflate 0 1`, 4 runs each
(debug builds, as the app's Makefile builds them):

| Cable clients / deflate | base msg/s, p99, paced p99 | SHARED_RC msg/s, p99, paced p99 |
|---|---|---|
| 100 / off | 4,218, 3.23 ms, 1.59 ms | 4,270, 3.12 ms, 2.13 ms |
| 100 / on | 2,900, 5.21 ms, 1.58 ms | 2,905, 5.01 ms, 2.03 ms |
| 1,000 / off | 332, 59.3 ms, 7.7 ms | 331, 60.7 ms, 7.3 ms |
| 1,000 / on | 288, 70.6 ms, 9.8 ms | 288, 79.2 ms, 9.6 ms |
| 10,000 / off | 34.4, 776 ms, 92 ms | 33.5, 584 ms, 89 ms |
| 10,000 / on | 28.8, 724 ms, 85 ms | 28.6, 763 ms, 89 ms |
| static_css c=16 | 425,192 req/s | 425,309 req/s |

Shared collections per run: base 88 (about 1 ms each at 100 clients, 10-14 ms
at 1,000, worst 46-124 ms in the 10,000-client phases); SHARED_RC 2 backup
collections per run (1.2-1.9 ms). RSS is the same. Throughput and saturated
p99 do not move beyond the run-to-run noise (two earlier series with other
helping policies gave the same picture); paced p99 at 100 clients is about
0.5 ms worse with SHARED_RC, where workers collect for each other.

Tests: `make test-rc` passes on Linux (the only failure, `Https: Client`,
needs internet, which the network namespace used for the runs has not);
`make test-win` with the define passes 3/3 under Wine; soak on two cores
(`taskset -c 0,1`): 10/10 and 12/12 with earlier policies, see the branch
for the final run. The default build (`make test`, no define) passes.

## 14. Assessment

What reference counting gives:

- no stop-the-world for acyclic shared data: the shared collection runs 1-2
  times per Campfire run instead of 88, and only as the cycle collector;
- lower shared memory for message passing (dead messages go after one round
  instead of at the next doubling).

What it costs:

- CPU: frees wait until every thread collected, so the busiest thread runs
  the collections of the threads that block (+15% wall, +4% CPU on the
  4-thread message benchmark); every store into locked data creates and later
  frees one region per object (2.4x slower on a locked map that is replaced in
  a loop).
- Complexity: ~1,000 lines of runtime (regions, deferred freeing, helping,
  orphans, backup), a compiler hook for `Lock` layouts and for stores into
  `shared T` slots, and three policies with tuned behaviour (who collects for
  whom, when an idle thread collects itself, when the backup runs).
- New invariants the rest of the stdlib must keep: every raw write into
  shared storage keeps counts (`transfer_refs` was the first miss), runtime
  thread-local globals must not keep pointers, mutation of immutable data by
  `@threadsafe` code must not unlink objects inside a region.

Recommendation: keep the current shared collection. The prototype removes the
pauses but no workload measured here gets faster (Campfire: same throughput
and p99, paced p99 slightly worse), message passing and lock-heavy code get
slower, and the runtime gets a second set of GC states, invariants and
policies (three helping policies were needed to get the Windows suite and
the memory numbers right at the same time). If
shared pauses come back as a measured problem (many threads and coroutines
and immutable data published at a high rate), the branch is a working
starting point; the cheaper first step stays parallel marking during the
stop.

Found on the way and useful without reference counting (separate commit on
the branch): `moved_elements` left the storage it worked on in a thread-local
global; on threads other than main that global lies in the scanned stack
block, so it kept the last array a raw move touched (and everything in it)
alive. Test: "GC: Storage whose elements a raw move logged is freed on a
worker thread".

Open problems if this is continued:

- cascading frees take one round per level of a dead chain; a per-region
  "last decrement" epoch would allow freeing a chain in one round but needs an
  atomic maximum;
- per-object regions make locked data expensive; per-lock tracing (the lock
  holder traces the locked graph at unlock, strings as regions) would be
  cheaper but is a third collector;
- the backup collection still stops the world for cycles through locks;
  concurrent trial deletion would remove it;
- macOS and linux-arm64 are untested; shared global stores use a spinlock,
  not an atomic exchange.
