# Language design

This document defines the intended language and compiler model. It is a design
contract for the compiler, standard library, diagnostics, and generated ABI. It
is not a collection of independent syntax experiments.

Valk distinguishes value aggregates from reference objects. Structs and fixed
arrays are copied values, while classes are references. The language defines
its own syntax, GC, tagged unions, error handling, modes, and inferred borrow
and uniqueness effects.

## Goals

- Syntax must be parseable without resolving identifiers.
- Parsing and ordinary incremental builds should remain fast.
- Value and reference behavior must be predictable from the type.
- Safe code must not create dangling references or untracked GC pointers.
- Unsafe operations must be explicit and visually recognizable.
- The compiler should infer mechanical safety contracts when it can do so
  cheaply and deterministically.

## Compiler stages

The compiler separates syntax from semantic resolution:

1. Lex and parse declarations and raw function bodies.
2. Load packages and namespaces from `use` declarations.
3. Register named declarations, aliases, errors, traits, and extensions.
4. Resolve types and finalize aggregate layouts.
5. Parse and type-check function bodies when required.
6. Infer and cache per-parameter escape and uniqueness effects.
7. Determine reachability and lower required functions to IR.
8. Generate objects and link only when the selected command requires them.

Syntax parsing may use grammar context, but never the resolved meaning of an
identifier. Semantic stages may resolve identifiers and specialize generics.

## Core type model

### Scalar values

- `bool` is one byte.
- Signed integers: `i8`, `i16`, `i32`, `i64`, and pointer-sized `int`.
- Unsigned integers: `u8`, `u16`, `u32`, `u64`, and pointer-sized `uint`.
- Floating-point values: `f32`, `f64`, and pointer-sized `float`.
- `void` represents no value.

Scalar values are copied by value.

### Numeric operations

Integer addition, subtraction, multiplication, negation, increment, and
decrement wrap modulo the width of their result type. This applies to both
signed and unsigned integers and does not require runtime overflow checks.

Integer division and remainder truncate toward zero. Their operands must meet
these unchecked preconditions:

- The divisor is not zero.
- For a signed type, the minimum value is not divided by `-1` and its remainder
  is not taken with `-1`.

Violating either precondition at runtime is undefined behavior, and the
compiler may assume it does not happen. A violation known at compile time is a
compile error. No implicit runtime check is inserted.

The shift amount must be non-negative and less than the bit width of the left
operand. A statically invalid shift is a compile error; a dynamically invalid
shift is undefined behavior and receives no implicit runtime check.

Integer narrowing retains the least-significant bits. Signed and unsigned
conversions preserve that bit pattern, extending with the source type's sign or
with zero when the destination is wider.

Floating-point addition, subtraction, multiplication, division, and comparisons
follow IEEE 754, including its rules for infinities, signed zero, and NaN.
Floating remainder is `x - trunc(x / y) * y`, so a nonzero result has the sign
of `x`. Converting a finite, representable float to an integer truncates toward
zero. Converting NaN, infinity, or a value outside the destination integer's
range is undefined behavior and receives no implicit runtime check.

`bool` converts explicitly to numeric types as `0` or `1`. Numeric values do
not convert to `bool` through `.to(bool)`; code must state the intended
condition with a comparison. Conversion hooks may still return `bool`.

### Value aggregates

The following types have inline storage and are copied by value:

- Fixed arrays: `[T x N]`.
- Tuples and multiple values: `(T1, T2, ...)`.
- `struct` values.
- Tagged unions.
- Closures, represented as a function pointer and an optional environment
  pointer.

Copying a value aggregate copies its fields. It does not recursively clone
referenced class or array objects stored in those fields.

```valk
struct Point {
    x: int
    y: int
}

fn move(point: Point) Point {
    point.x++
    return point
}
```

`Point` has no object identity: assignment creates an independent value copy.
If it contains a class reference, the reference is copied and both structs
refer to the same class object.

### Reference types

The following types have reference identity and are assigned by reference:

- `class` values.
- `Array[T]` and `Slice[T]`.
- Interface values.
- Coroutine handles.
- Non-inline/manual pointers to structs.

Reference values are non-null by default. Use `?T` when `null` is valid.

### Classes

Classes are GC-managed reference types. A class initializer allocates an object
and evaluates its property initializers before publishing the resulting
reference.

```valk
class User {
    name: String
    age: uint (0)
}

let first = User { name: "Ada" }
let second = first
second.age = 37 // also observable through first
```

Class assignment copies the reference, not the object. Deep copying is only
performed by an explicit clone operation or user-defined clone hook.

### Structs

Structs are inline value types with fields in declaration order. Local structs
normally live in their containing stack frame, class, array, or aggregate.

```valk
struct Header packed {
    kind: u8
    length: u32
}
```

`packed` suppresses normal padding between fields. Pointers to structs and
manual heap allocation are unsafe facilities; the value type itself is safe.
A struct initializer always creates an inline value; an expected pointer type
does not implicitly change it into a heap allocation. Typed manual allocation
uses `mem.new[T]()` and must eventually be released with `mem.free`.
A struct may contain GC references, in which case its containing storage is
walked using the struct's generated GC layout.

A struct cannot contain itself inline, directly or through another inline
aggregate. Recursive structures must use a class, array, nullable reference,
or explicit pointer indirection.

### Fixed arrays, arrays, and slices

Valk distinguishes three sequence categories:

| Type | Storage | Copy behavior | Resize |
| --- | --- | --- | --- |
| `[T x N]` | Inline elements | Copies all elements | No |
| `Array[T]` | GC-managed reference to `Slice[T]` storage | Copies the reference | Yes |
| `&[T]` | Owned borrow of fixed-size storage | Copies the borrow | No |
| `Slice[T]`, `String` | `&[T]` with a class attached | Copies the borrow | No |

Fixed arrays store their elements inline. `Array` is a GC reference type that
owns resizable element storage. That storage is a `Slice[T]` block: a header
with the slot count followed by the elements, traced by the block itself. The
array holds the block in `storage` and its first element in `data`. Growth
allocates a new block and registers the elements there as well; the old block
stays alive only while something else, such as a view, still holds it. Every
operation that drops an element clears its slot, so the array never keeps a
removed element reachable.

`&array[i]` borrows one element as `&T` with the storage block as owner, and
the same works on `Slice[T]` and `&[T]`; `&view[a..b]` borrows a range of an
`&[T]` as `&[T]`. A class `$offset` or `$range` hook takes precedence, which
is why a range of an array goes through `view`. `array.view(start, length)`
returns a `Slice[T]` over the array's block without copying. The view shares the elements it covers, observes in-place
writes through the array, and survives the array growing because it keeps the
block it was taken from. A view keeps its whole block alive, including slots
past the elements it covers. `array.iter()` and `array.slice(...)` still copy.

A `slice X of T` class is an `&[T]` with methods: the same three words
(`owner`, element pointer, `length`), the same GC handling, and the same
bounds policy. `Slice[T]` and `String` are the two in the core library. A
value converts implicitly between a named slice and `&[T]` in both directions
when the element types agree, so a function taking `&[u8]` accepts a `String`
and a function taking `Slice[T]` accepts any `&[T]`. `String` is the
exception in one direction: its storage always carries a terminating zero
byte so `data_cstring` is valid, which an arbitrary `&[u8]` cannot promise,
so a bare view never becomes a `String` implicitly. Two different named
slices stay distinct: `String` is not `Slice[u8]`. A newly initialized
`Slice[T]` owns fixed-length element storage, while `slice.view(offset,
length)` creates a bounded alias of that storage without allocating or
copying elements. There is no anonymous `slice[T]` type.

Indexing has one policy for every native sequence. A class hook comes first:
`$offset`, `$offset_assign`, and `$range` on the class define the operation
when present, which is how `String[i]` answers 0 past the end. Without a hook
the compiler emits the native access, which checks the index against the
length and panics when it is out of bounds. A native read of a non-nullable
reference element also panics when the slot is empty: storage can be
zero-filled or cleared by a removal, and the language never hands out an empty
slot as a valid reference. This applies to `Array[T]`,
`Slice[T]`, `&[T]`, and named unbound pointers alike. The `get` and `set`
methods remain the fallible forms that return `LookupError`. For assignment,
`Array[length] = value` appends. Fixed arrays use checked inline indexing and
reject a known invalid index at compile time.

```valk
let fixed: [int x 3] = { 1, 2, 3 }
let values = Array[int]{ 1, 2, 3 }
let first_two = values[0 .. 2]
```

### Functions, function pointers, and closures

Function declarations use an optional return type and optional error type:

```valk
fn parse(text: String) int !ParseError {
    // ...
}
```

Callable type syntax is:

- `fn(A, B)(R1, R2 !Error)` for a closure-compatible callable.
- `fnptr(A, B)(R1, R2 !Error)` for a raw function pointer.
- `co(R1, R2 !Error)` for a coroutine returning values when awaited.

Multiple return types and the optional error type appear inside the return
parentheses. `()` means no return value, and `(!Error)` means error-only.

A closure is an inline two-word value:

```text
{ function: fnptr, environment: ?GcPtr }
```

Capture-free functions have a null environment and may convert to `fnptr`.
Captured values live in a GC-managed environment. A raw function pointer does
not carry an environment and cannot represent a capturing closure.

Coroutines may return payload-free errors. Error types with payload fields,
including inherited fields, must be handled inside the coroutine or encoded in
its ordinary return type.

### Interfaces

Interfaces describe method and getter requirements. Only classes implement
interfaces. A class-to-interface conversion is implicit when the class
implements the complete interface contract.

```valk
interface Printable {
    fn text(prefix: String) String;
}

class User is Printable {
    name: String

    fn text(prefix: String) String {
        return prefix + this.name
    }
}
```

Valk interface values are two-word values containing:

```text
{ object: GcPtr, vtable: ptr }
```

The object field keeps the concrete class alive. Vtables are static, and method
slots are assigned in interface declaration order. `value is_a Type` checks
the concrete class stored in an interface value. Interface methods cannot be
generic, and an implementation must match argument types, return types,
getter/function form, variadic behavior, and error type exactly.

### Tagged unions

A tagged union stores exactly one value from a closed set of alternatives:

```valk
union Value : String | int | bool {
}

fn describe(value: Value) String {
    return match value : String {
        String as text => text
        int as number => "number: %number"
        bool as enabled => enabled ? "enabled" : "disabled"
    }
}
```

The current tagged-union ABI uses:

```text
{ tag: u8, padding to byte 8, payload: largest alternative }
```

- A union may contain at most 256 distinct alternatives.
- Tags are assigned from `0` through `255` in canonical type-identity order.
- The payload has enough size and alignment for the largest alternative.
- The complete union receives the required tail padding.
- GC walking inspects the active tag.
- Recursive inline alternatives are rejected.
- Tagged unions are not allowed directly in `extern` or `export` signatures.

Anonymous union types use `A | B`. A named union may also define methods and
getters. Nullability is represented separately with `?` rather than by adding
an implicit union alternative.

### Enums

Enums are named constants over an underlying type. The default underlying type
is `int`.

```valk
enum Status {
    pending       // 0
    complete (2)  // 2
    running       // 1
}

enum Header: String {
    json ("application/json")
    text ("text/plain")
}
```

An implicit integer value is the smallest non-negative value not already used
by an earlier implicit item or an explicit integer literal anywhere in the
enum. Explicit duplicate values are allowed. Non-integer enum items require an
explicit value.

Enum items with the same underlying value are aliases and cannot be
distinguished at runtime. A match case handles every alias for that value, and
a later case with the same value is rejected as duplicate and unreachable. A
`default` case may be omitted when the compiler can prove that the match covers
every distinct declared value. If any declared value or case cannot be resolved
at compile time, the match must include `default`. Values created through
unsafe casts do not affect exhaustiveness.

The underlying type does not implicitly convert to the enum, and `.to(Enum)`
cannot manufacture an enum value. `.@cast(Enum)` remains the unsafe escape
hatch. A `$to` or `$auto` conversion hook may return a declared enum value.

### Modes

A mode is a distinct named view of an existing named type. It preserves the
base representation and is implicitly compatible with the base type in both
directions, while allowing methods and operator hooks to be replaced.

```valk
mode Path for String {
    fn add(part: String) Path {
        // ...
    }
}
```

A mode cannot add stored properties. Member lookup checks the mode first and
then falls through to the base type. Nested modes ultimately use the original
base representation.

Mode identity is preserved during overload and hook selection. An overload
whose parameter exactly matches the static type passed at the call site wins
over one that matches only through mode/base compatibility.

Generic arguments are invariant and do not inherit mode compatibility.
Specializations retain distinct identities because their methods and hooks may
differ. Consequently, `Array[Mode]` is not compatible with `Array[Base]` in
either direction, and `HashMap[Mode, V]` is not compatible with
`HashMap[Base, V]`. Converting a hash map between those types could otherwise
make entries unreachable when the mode supplies different equality or hashing.

## Nullability

`T` is non-null unless its type inherently represents no value. `?T` permits
`null`.

- Nullable pointer-represented types use a null pointer as the empty state.
- Nullable closures use a null function pointer as the empty state.
- Nullable inline values use a presence tag plus the inline payload.
- Flow checks such as `isset(value)` narrow `?T` to `T` on the proven path.
- `value ?? fallback` evaluates and returns `fallback` only when `value` is
  null.

The compiler must not erase nullable state until control-flow analysis proves
the value non-null.

## Borrows and raw pointers

### Borrows

Valk has two borrow forms. Both are safe: neither can dangle, and neither
requires the programmer to track lifetimes. They share one layout; what
differs is where the storage may live and whether the borrow may escape.

| Type | Layout | Kept alive by | May be stored or returned |
| --- | --- | --- | --- |
| `stack T` | `{ owner: ?GcPtr, adr: ptr }` | The frame, or `owner` when set | No |
| `&T` | `{ owner: ?GcPtr, adr: ptr }` | Its own `owner` field | Yes |
| `&[T]` | `{ owner: ?GcPtr, adr: ptr, length: uint }` | Its own `owner` field | Yes |

#### Stack borrows

`stack T` borrows storage for the rest of the frame: an inline local, an
argument, a temporary aggregate, or, through another borrow, storage inside a
GC object. `&local` produces it with a null owner; `&ref.prop` through a
`stack T` produces it with that borrow's owner word. A stack borrow follows
the frame rules:

- May be stored only in local variables and non-escaping parameters.
- Cannot be stored in a class, array, map, global, interface adapter, or closure.
- Cannot be returned.
- Cannot be converted implicitly to persistent raw-pointer storage.
- May cross a coroutine suspension point when its stabilized storage is
  retained in the coroutine frame.

Taking a stack borrow makes the local addressable. The compiler uses native
stack storage when the function is proven not to suspend. If the function may
suspend directly or through a call, address-taken inline locals use stable
storage so their addresses remain valid while another coroutine uses the
execution stack.

`stack [T x N]` is the bounded form; its length is part of the type and
indexing is checked against it.

Struct method receivers are stack borrows: `this` is `stack T`. Calling a
method on a struct that lives inside a GC object hands the method that
object's owner word, so a store to a managed field through `this` updates the
owner's bookkeeping. A method called on a frame local or through a raw
pointer gets a null owner and a plain store.

#### Owned borrows

`&T` is an owned borrow: a fat reference whose `owner` names the GC allocation
that contains the storage. The collector walks `owner` and ignores `adr`.
Because the heap does not move objects, `adr` stays valid for as long as
`owner` is reachable, so the borrow needs no lifetime tracking and may live
anywhere a GC reference may live: class properties, arrays, globals, closures,
return values, and coroutine frames.

`&obj.prop` on a GC object produces `&T` with `owner` set to that object, and
so does `&ref.prop` through another owned borrow. A property of inline
aggregate type converts implicitly, as in `let p: &Payload = owner.payload`.
The members of `&T` are the members of `T`, read through the address. When
`T` is itself a reference type, such as a class, the borrow names the slot
that holds the reference: `ref.label` and `ref.method()` read the object out
of the slot first, while `ref[0]` addresses the slot, so `ref[0] = other` and
`ref[0] = null` replace what the owner holds with the owner's bookkeeping.

`&[T]` is the sequence form: an owned borrow plus a visible length, without a
class. Indexing and ranges are checked against `length` and panic when out of
bounds. `each` iterates it natively. It converts from `&[T x N]`, from a fixed
array inside an owner, and to and from any `Slice[T]` or `String` value: the
named slices are `&[T]` with a class, so the conversion is a retype.

An owned borrow is an alias into `owner`, and its owner word is part of the
borrow value. The owner's graph therefore stops being uniquely held exactly
when the borrow escapes: stored in an object or global, returned, captured,
bound to a local, or passed to a parameter the callee keeps. A borrow that
only lives through a call, such as `read(&owner.payload)` with a callee that
does not keep it, leaves `owner` publishable as `shared`. Borrowing
`shared T` data remains an error.

#### Null owner

`owner` is nullable, and null means nothing owns the storage. For `stack T`
that includes frame storage. For `&T` safe code produces a null owner only
for permanent storage: globals and other static data. Unsafe code may build
an `&T` from a raw pointer with `.@cast(&T)`, which yields a null owner over
memory whose lifetime the programmer manages. A `stack T` does not convert to
`&T`, because its null owner may stand for a frame, and the compiler reports
the missing owner instead of the old "cannot be stored" errors.

#### Conversions

- `&T` converts to `stack T` in place; the layouts are the same and only the
  escape rule changes.
- `stack T` does not convert to `&T` or `&[T]`.
- `&[T x N]` converts to `&[T]`; `[T x N]` storage with an owner converts to
  either.
- A raw pointer converts to `stack T` implicitly, as before, and to `&T` only
  through explicit `.@cast(&T)` under `@unsafe`.
- Every borrow converts to `ptr` and to a matching `*T`; a bounded `*[T x N]`
  takes exactly its own length. A raw pointer taken from a `stack T` keeps
  the frame rules: it may be passed to a pointer parameter but not stored.
- `?&T` uses a null address as its empty state and costs no extra word.
  Equality on borrows compares addresses.

The convention that follows: a function that only reads takes `stack T`, a
function that may store takes `&T`, and callers may pass an owned borrow to
either.

#### Owners are fixed-size

An owned borrow points into its owner's storage, which must not relocate.
Valid owners are class objects, and structs or fixed arrays inlined in them,
plus `Slice` and `String` storage, and the storage blocks of arrays. An
element borrowed out of an `Array[T]` names the block as its owner, so it
stays valid when the array grows, although it then points into the old block.

#### Stores through borrows

A store through any borrow whose target holds managed references runs the
owner's ownership bookkeeping when `owner` is set and a plain store when it
is null. The check is a runtime test of the owner word, so it holds across
function boundaries and struct method receivers. The same applies to
`sequence[i] = value` and `storage.prop = value` on inline storage that lives
inside a GC object. Reads of managed elements through any borrow or fixed
array strip the collector's tag bits.

Internally, every read or write through a borrow goes through its address as
a one-word value that the user cannot name; the fat borrow itself is only
copied, passed, and stored.

#### Not done here

Allocating class objects in the frame when escape inference proves they do not
escape is a separate optimization. Promoting a frame-allocated object to the
heap at the moment it escapes is rejected: raw pointers and existing borrows
may already hold the frame address, and rewriting them would require a moving
collector for frames.

### Inferred parameter effects

Borrow compatibility and uniqueness preservation are inferred from function
bodies rather than requiring developers to repeat effects in every signature.

For every parameter, the compiler computes and caches:

- `escapes`: the function may return, store, capture, publish, or otherwise
  retain data reachable through the parameter.
- `invalidates_unique`: the function may insert an external alias into data
  reachable through the parameter.

Return summaries distinguish unconditional fresh graphs from graphs whose
freshness depends on particular arguments also being fresh temporaries.

For an analyzable body, both parameter effects start as false. Direct operations
may only change them from false to true, and direct calls record dependency edges
from callee parameters to the corresponding caller parameters. After the bodies
have been analyzed, effects propagate along those edges until no value changes.
This computes the least fixed point for recursive call groups and does not depend
on body-analysis order. Functions without an analyzable body and calls through
unknown code are conservative. Generic functions cache effects per
specialization; rebuilding a changed body recomputes its summary.

Suspension is inferred by the same monotone fixed-point process. Direct
coroutine suspension seeds the effect, direct calls propagate it to callers,
and indirect or unknown Valk calls are conservative. This effect controls
whether address-taken inline locals use native or stable storage.

Return-graph freshness is a separate summary. A return whose freshness depends
on a recursive return summary that is still being computed is treated as not
fresh.

All Valk package source is available to the compiler and is reanalysed when
needed. Effect summaries are compiler-owned in-memory metadata, not source
annotations or library artifacts.

- A borrowed argument is accepted when the target parameter does not escape.
- For an indirect call, the callable carries the combined effects of its
  possible targets; an unknown target is treated conservatively.
- Extern calls have no analyzable body and form an explicit unsafe boundary.

This inference is a semantic pass after identifiers and call targets are
resolved. It does not affect syntax parsing.

### Raw pointers

Raw pointer types are `ptr`, `*void`, `*T`, and bounded forms such as
`*[T x N]`. They have no ownership and are not GC roots.

Raw-pointer operations are unsafe even when expressed with ordinary operators.
`@ref(value)` creates a raw pointer whose lifetime the programmer must enforce.
Integer-to-pointer conversions are never implicit and require
`value.@cast(ptr)`. A raw `ptr` converts implicitly to pointer-sized `uint`,
which preserves every address bit; conversions to other integer types remain
explicit. Dereferences that cannot be proven safe use explicit unsafe
operations. `pointer.$offset(bytes)` computes an address offset without
converting the integer offset itself to `ptr`.

Raw pointers may erase to `ptr`, and a bare `ptr` may acquire either a raw `*T`
element type or a `stack T` borrow type. Converting any raw pointer to an owned
`&T` requires explicit `.@cast(&T)` and yields a borrow without an owner.

Bitwise `ptr & integer`, `ptr | integer`, and `ptr ^ integer` operations retain
the pointer type. Assigning such a result to `uint` uses the same one-way
implicit conversion.

The GC never walks arbitrary raw pointers. Converting a GC reference to a raw
pointer does not keep the object alive; safe code must retain the owning GC
reference for as long as the raw pointer is used.

## Shared views

### `shared T`

`shared T` is a transitive view for data published across threads. It cannot be
converted back to ordinary mutable `T`. Data-race-unsafe properties cannot be
mutated through a shared view; supported integer operations use atomic access,
and explicitly synchronized low-level code uses the shared-unsafe mechanisms.

Language-level atomic reads use acquire ordering, atomic writes use release
ordering, and atomic read-modify-write operations are sequentially consistent.
An acquire operation that observes a release operation also observes everything
sequenced before that release. Mutex unlock and lock form the corresponding
release/acquire synchronization boundary.

Starting a thread publishes everything sequenced before the start to the new
thread. Successfully waiting for a thread observes everything sequenced before
that thread completed. Coroutines are thread-affine and do not migrate between
threads. Ordinary `global` storage is thread-local; `shared` and `@shared`
storage is process-wide.

Creating a `shared T` view does not by itself move its reachable GC graph to the
shared collector. GC publication occurs only at an actual cross-thread transfer
or shared-storage boundary. The compiler tracks uniqueness as internal value
provenance; it is not part of source-level types. Fresh construction and
functions proven to return fresh graphs produce unique values. Nonescaping calls
preserve uniqueness, while aliasing, capture, persistent storage, and calls
through unknown code remove it.

An ordinary value may become `shared T` only when its complete reachable managed
graph is still provably unique. Creating the view consumes that internal
capability; using another mutable alias is rejected. Strings and other immutable
values are always compatible. Function argument escape and fresh-return
summaries are inferred from bodies and cached, so APIs do not need ownership
annotations.
An ordinary graph may receive a temporary `shared` view for a parameter proven
not to escape or introduce aliases; this does not publish the graph or consume
its uniqueness.
When a fresh local is placed into a fresh aggregate, dependent provenance keeps
the aggregate unique only while the source local is not read again. Ordinary
aliasing remains ordinary aliasing; it never silently consumes a value.

Ownership provenance covers managed references; raw pointers retain their
separate explicit unsafe lifetime and aliasing rules.
`@shared` globals are the explicit unsafe override when an external protocol
guarantees synchronization and lifetime safety. Within an expression,
`value.@cast(shared T)` is the corresponding explicit unsafe conversion.

## GC and lifetime model

The GC manages classes, arrays, slices, coroutine objects, closure environments,
interface adapters, and other types explicitly defined as GC objects.

The compiler generates layout-specific GC walking information:

- Direct GC references contribute one root.
- Structs, tuples, and fixed arrays recursively expose contained roots.
- Closures expose their environment pointer.
- Interfaces expose the concrete object stored in their adapter.
- Tagged unions expose roots only from the active alternative.
- Nullable inline values expose their payload only when present.
- Raw pointers and borrows are not independent roots.

Inline aggregates may contain GC references. The compiler must preserve and
walk those references wherever the aggregate is stored, copied, buffered, or
returned.

The local collector invokes `gc_free` for unreachable local objects on the
thread that owns that local collector. Once an object has been published as
shared, only the shared collector may invoke its `gc_free`. The call runs on
whichever thread performs that shared collection, with the object treated as a
shared value; code must not depend on a particular finalizer thread. A
particular object receives at most one `gc_free` call, finalization order is
unspecified, and program shutdown does not guarantee that every remaining
object is finalized. Deterministic resource release therefore uses an explicit
operation such as `close`.

`gc_free` is a restricted instance method:

- Its implicit `this` is a borrow. It cannot escape into persistent storage,
  be captured, or otherwise resurrect the object.
- It takes no explicit arguments, returns `void`, and cannot return or throw an
  error. It may call `panic`, which terminates the process.
- It cannot allocate GC-managed objects, directly or through known callees, and
  cannot call code whose allocation effects are unknown. Raw/native resource
  allocation and release remain permitted.
- It cannot start a nested local or shared collection.
- It must not access other GC-managed objects: their finalizers may already
  have run and finalization order is unspecified.
- It must not acquire or wait on locks. A shared finalizer can run on an
  arbitrary collecting thread while collector locks are held; blocking can
  deadlock collection. Releasing or destroying an unheld native lock is
  permitted.

## Layout and ABI

- Layout is target-specific and computed from the target pointer size and
  alignment rules.
- Struct and class fields appear in declaration order.
- Natural padding is inserted before fields and at the end of aggregates.
- `packed` suppresses normal inter-field padding for a struct.
- Classes, arrays, and coroutines are reference-sized values.
- Slices contain a backing reference, an element pointer, and a visible
  length: the same three words as `&[T]`.
- Closures and interfaces are two pointers.
- Fixed arrays contain `N` consecutive elements.
- Tuple members use their natural alignment in tuple order.
- The tagged-union payload begins at byte offset 8 in the current ABI.

Source-level layout compatibility does not by itself guarantee a C ABI.
Extern/export lowering must validate every argument and return type supported
by the selected target ABI. Unsupported aggregate or tagged-union signatures
are compile errors rather than silently using an incorrect calling convention.

Extern and export signatures cannot contain GC-managed references, including
references nested in inline aggregates. Extern signatures also cannot contain
`&T`. Pointer parameters use raw `*T` or `ptr`, and callers must cross an extern
boundary explicitly:

```valk
extern fn inspect(value: *Value) void

let value = Value {}
inspect(@ref(value))
```

C-style variadic arguments use a final `...` marker and are restricted to
extern declarations. Valk-defined and exported functions cannot be variadic.

`@ref` stabilizes inline stack storage and retains the exact GC owner of an
interior address for the current function or coroutine frame. It still returns
an unsafe raw pointer with no lifetime guarantee beyond that frame. An extern
API that retains a pointer must therefore use a longer-lived explicit
pinning/rooting protocol.

## Traits, extensions, and type finalization

Traits reuse declarations inside classes or structs. Generic trait parameters
are resolved in the receiving type's scope. Conflicting member names are compile
errors.

Extensions attach methods, getters, and hooks to classes and structs. An
extension in the type's defining package may also add stored properties unless
the type uses `$noNewProperties`:

```valk
extend User {
    fn display_name() String {
        return this.name
    }
}
```

Extensions from other packages may add only methods and getters. Exported ABI
types cannot receive extension properties. All declarations and extensions in
the build's package graph are discovered before type layouts are finalized.
Exported ABI reachability is transitive through properties, generic arguments,
sequence elements, union members, callable arguments and returns, and error
payloads; every reachable type is subject to the same restriction.
Therefore:

- Extension discovery order must not affect the final layout.
- Duplicate stored property names are errors.
- Adding an extension property changes the extended type's ABI.
- Precompiled code cannot assume an extended layout unless it was built against
  the same complete extension set.

Modes, interfaces, unions, arrays, slices, and other representation-sensitive
built-ins do not accept extension properties.

## Access control

Access markers follow the current compiler contract:

- No marker: accessible throughout the package, private outside it.
- `-`: private outside the defining source file.
- `~`: read-only outside the defining source file.
- `+`: public everywhere.
- `-~`: read-only in the namespace, private outside it.
- `-+`: public in the namespace, private outside it.
- `~+`: public in the namespace, read-only outside it.
- `-~+`: public in the namespace, read-only in the package, private outside it.

`@ignore_access` is an unsafe file-level escape hatch for compiler and low-level
library code.

## Errors and control flow

Errors are explicit return channels rather than exceptions.

```valk
error ParseError (invalid, missing) payload {
    message: String
}

fn parse(text: String) int !ParseError {
    if text.length == 0 {
        throw .missing { message: "Input is empty" }
    }
    return text.to(int) ! throw .invalid { message: "Invalid integer" }
}
```

The `!Error` suffix belongs to function declaration/type grammar. Postfix `!`
forms belong to call error handling. Prefix `!` is boolean negation. These are
distinguished by grammar context, not by resolving identifiers.

`main` may omit a return type, in which case it returns `void` and the process
exits successfully. An integer return type supplies the process exit code.
Other `main` return types are compile errors.

## Context-sensitive punctuation

The parser uses its current grammar context to classify overloaded punctuation:

- `{` starts a declaration/control-flow body when a body is expected.
- `{` after a type/value constructor starts an initializer.
- `{` at the start of a value is a type-hinted initializer.
- `{` after a call error operator starts an error-handler body.
- `!` in a function declaration or a callable type's result group introduces
  an error type.
- Postfix `!` after a call introduces error handling.
- Prefix `!` in a value expression is boolean negation.
- Prefix `?` in a type context creates a nullable type.
- In a value context, `condition ? yes : no` is a conditional expression.
- `??` is nullable fallback and is lexed as one operator.
- `[` in a type context introduces generics, fixed arrays, or bounded pointer
  information; in a value context it introduces indexing or a range.

New syntax must preserve the ability to determine these forms from tokens and
parser context alone.

## Unsafe boundary

Safe code cannot:

- Forge or perform unchecked arithmetic on raw pointers.
- Return or persist a borrow beyond its owner.
- Store an untracked GC reference in raw memory.
- Bypass bounds, access, or shared-data checks.
- Call an unknown external pointer operation without entering an unsafe path.

Tokens beginning with `@` identify operations that bypass one or more of these
checks. Raw pointer types may appear in declarations and extern signatures, but
creating, converting, dereferencing, or persisting them requires an operation
whose safety is either proven by the compiler or explicitly accepted by the
programmer.
