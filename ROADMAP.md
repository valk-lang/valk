
# Roadmap

`+` = Done | `~` = Works but needs to be improved | `-` = Todo

```
- Release 0.7.11
+ GC: a shared collection runs once the shared memory has doubled since the last one plus 4 MB (was +30% plus 256 KB), so short-lived shared data such as broadcast messages no longer stops every thread every few hundred KB: 1,420 -> ~150 collections for 20,000 shared 20 KB messages
+ Fix: collections inside a `lock` block. `remove` on a `HashMap`, `Map` or `FlatMap` failed with `Only a provably unique value graph can be converted to 'locked Array[bool]'`; removing inside `each`, `sort_keys`, `Deque` pops, `Array.sort()`, `sort_by`, `remove_where` on plain elements and `HashSet.remove_where`/`retain` failed in the stdlib too, and now work in place. A closure that captures outside data can be passed to a method on locked data when the method is known not to keep it, and a generic method on locked data (`sort_by`, `map`) is checked after its type arguments are known. Callbacks that would be handed managed elements of locked data stay refused
+ Fix: `==` and `!=` on a locked or shared view. `t.numbers == .{ 1 }` inside a `lock` block compared addresses and returned false, and `t.numbers == plain` failed with `Expected 'locked Array[uint]'`; a view now compares like its plain type through the `$eq` (and ordering) hook in both orders, with literals, plain values and other views, and a hook called with a view on its right gets that view as its argument. `HashSet` equality works on views too

+ Release 0.7.10
+ WebSocket: permessage-deflate compression (RFC 7692). `WebSocket.connect` offers it by default (`Options.websocket_compression`); a server accepts it with `Server.websocket_compression = true` or per endpoint with `WebSocket.upgrade(req, handler, true)` / `send_websocket(ctx, handler, true)` (off by default, as in Go and Node servers: it costs CPU per message). The server answers without context takeover either way, so a connection keeps no compression window; the client also inflates a server's context takeover. Messages under 64 bytes, or that would not shrink, go uncompressed, and a decompressed message counts against `max_message_size`. Frames are built in a reused buffer and masked 4 bytes at a time (uncompressed 16 KB echo 26.7k -> 32.4k round trips/s)
+ Fix: a `shared` (or locked) `String`, `Array` or `ByteBuffer` passes to a `&[T]` / `local &[T]` parameter; `String` and `ByteBuffer` failed inside the stdlib with `Expected '?GcPtr', got '?shared GcPtr'`. A view literal over shared or locked storage is now a shared or locked view itself
+ Fix: `link "gobject-2.0"` (any library name with a dot, like `python3.12`) links as `-lgobject-2.0` (`gobject-2.0.lib` on Windows) instead of failing with `cannot find -l:gobject-2.0`. Only `:name` and names ending in `.a`, `.so`, `.so.N`, `.o`, `.obj`, `.dylib`, `.tbd`, `.lib` or `.dll` are exact file names
+ HTTP/1 responses: a large output buffer goes to a per-thread pool (up to 16 buffers of at most 1 MiB) after the response instead of being shrunk to 2 KB, and the next large body takes it from there, so a 400 KB page no longer grows and zero-fills a new 512 KB buffer per request (fast handler, 400 KB page, release build: 16 connections 49.8k -> 54.4k req/s, 64 connections 38.0k -> 50.9k). Idle keep-alive connections still hold only 2 KB (1000 idle connections after a 400 KB page each: 74 -> 69 MB RSS); small responses are unchanged
+ WebSocket: `WebSocket.upgrade` and `send_websocket` take `protocol:`, sent back in `Sec-WebSocket-Protocol` when the client offered it (Action Cable and most subprotocol clients refuse a handshake without it), and `headers:` for extra response fields such as `Set-Cookie` (the handshake fields cannot be replaced there). `WebSocket.protocol` is the agreed subprotocol on both sides
+ WebSocket: `WebSocketFrame.text(data)` / `binary(data)` prepare a message once and `ws.write_frame(frame)` sends it, for fan-out to many connections. The frame bytes are built once and a server writes them as they are; the permessage-deflate form is made on first use, once per window size, so compressing and plain connections share one frame. A frame cannot change and can be published as `shared` to send from any thread (1 message of 1.8 KB to 1000 connections, release build: plain 5.5 -> 5.2 us per connection, compressed 12.4 -> 4.8 us)
+ Fix: a call result passed straight to a `shared T` parameter, like `hub.push(Frame.text("b"))`, is published when it is a unique graph, the same proof `let f: shared Frame = Frame.text("b")` uses. It failed with `Only a provably unique value graph can be converted` when the callee's summary was not settled yet (a recursion cycle, an interface method, or a callee that appends to an array). A result built from a local consumes that local, and one built from an aliased value is still refused
+ Linux: `TcpConnection.write` (and `net.write`) sends right away while the socket buffer has room and only waits through io_uring for what does not fit, so a write no longer suspends the coroutine (macOS already did). `WebSocket.write_frame` of 1.5 KB to 1000 local connections: 8.2 -> 6.5 us per connection (10,000: 9.0 -> 7.6 us, p99 delivery 154 -> 81 ms); 8 MB HTTP responses 368 -> 420 req/s; small responses unchanged
+ `TcpConnection.write_many(.{ header, body })` sends several buffers in order with one `sendmsg` (Linux) / `writev` (macOS) while the socket has room, waiting only for what does not fit; TLS and Windows join them and use `write`
+ WebSocket writes without TLS on Linux and macOS no longer wait for a slow peer: what its socket cannot take is queued and sent by a coroutine of the connection, and writes made meanwhile queue behind it instead of polling every millisecond for their turn (a write waits once 4 MB are queued; a failed queued write closes the connection). A server sends an uncompressed message's header and payload with one `write_many` instead of copying the payload. Fan-out of 100 messages of 64 KB to 200 connections of which 4 read nothing for 3 s: the others got everything in 312 ms instead of 2.9 s (p99 delivery 2.6 s -> 17 ms, 29 -> 3.1 ms per fan-out)
+ Fix: a local whose graph is unique passed to a `shared T` parameter that keeps it, like `let item = Item {}; publish(item)` where `publish` sends to a channel, is published and consumed the way `let s: shared Item = item` is; it failed with `Only a provably unique value graph can be converted` when the callee's summary was not settled yet. Using the local (or anything naming part of its graph) after the call is a compile error, following branches and loops; a callee that only reads keeps it a borrow and the local stays usable. Locals aliased elsewhere (stored, captured, read from a parameter, a global, `this` or locked data) and frame storage are still refused
+ WebSocket: permessage-deflate compresses at level 6 from 256 bytes instead of level 1 from 64 bytes, as Rails (websocket-driver) and Rust (tungstenite) do, and both are settings: `Server.websocket_compression_level` / `websocket_compression_min_size` and the same fields on `http.Options` (0 sends uncompressed). A `WebSocketFrame` caches its compressed form per window size and level. 9.4 KB Action Cable turbo stream: 1992 -> 1858 bytes (-7%) for 84 -> 94 us of compression, paid once per frame on fan-out; messages under 256 bytes (pings, confirmations) saved 9-27% of their bytes for 4-5 us each
+ WebSocket: `ws.write_frames(frames)` sends several prepared frames in order with one `sendmsg` / `writev` per 64 frames instead of one per frame, for a connection's writer that finds several messages waiting (as tungstenite writes all pending frames of a socket at once); what the socket cannot take is queued as before. Bursts of 5 frames of 1.5 KB to local connections, one server thread (fan-out loop / until all arrived): 1000 connections 23.8 / 25.3 -> 6.9 / 8.5 ms, with deflate 23.5 / 25.2 -> 6.3 / 11.8 ms; 10,000 connections 237 / 289 -> 97 / 154 ms, with deflate 244 / 302 -> 81 / 161 ms
+ Fix: a struct that carries references keeps its `shared` (or `locked`) view in property types, including nullable and generic positions (`last: ?shared Pair`, `Array[shared Pair]`); the view was dropped when the property was parsed before the struct's own fields, so storing a `shared Pair` parameter there did not count as keeping it, and the caller could still change data that other threads read. A local struct passed to a `shared` parameter that keeps it is now published and consumed like a class; using it afterwards is a compile error. `Array[shared Pair]` no longer fails inside the stdlib with `Expected '*[shared Pair]', got 'shared *Pair'`. Structs of plain values are unchanged
+ compress: faster DEFLATE. Compression matches 4 bytes at a time through 16-bit hash chains, levels 4-9 match lazily with zlib's per-level settings and walk the sparsest chain inside the best match (as zlib-ng), blocks hold 16K symbols as in zlib, and one-shot calls and WebSocket messages reuse a per-thread compressor instead of allocating and clearing 512 KB of tables. Decompression decodes from a 64-bit bit buffer straight into the output, and one-shot calls reuse a per-thread decoder. Release build, raw DEFLATE (zlib-ng 2.3 in brackets): 11.6 KB JSON message at level 1 71 -> 15 us (13), level 6 101 -> 64 us (46); 200 B 15 -> 2.2 us (2.6-5); 1 MB JSON level 1 132 -> 562 MB/s (684), level 6 49 -> 98 MB/s (74), level 9 37 -> 39 MB/s (66); 1 MB HTML level 1 98 -> 298 MB/s, level 6 50 -> 87 MB/s (106); decompressing 1 MB JSON 452 -> 1330 MB/s (970), 11.6 KB 555 -> 1195 MB/s, 200 B 5.6 -> 1.1 us. Output at levels 6 and 9 is 1-9% smaller than before and within 1.5% of zlib-ng's (2% larger for binary data at level 9); level 1 uses zlib's settings and is up to 5% larger than before, still 16-25% smaller than zlib-ng's level 1
+ Fix: memory corruption on Windows (seen as the HTTP tests' overwritten strings, consumed buffers and divisions by zero): the GC's list of memory blocks, which finds objects that only the stack points to, was marked sorted again by the program's startup after its first two blocks were added, and Windows hands those out in descending order. Lookups then missed some blocks and objects still in use were freed and reused

+ Release 0.7.9
+ crypto: `Hmac` keeps the hash state after the padded key, so `reset` and `finish` no longer hash a key block again: `pbkdf2` with 100k iterations 74 -> 32 ms (SHA-256), 94 -> 40 ms (SHA-512). `hash`, `hash_hex`, `hex_encode` and `Hmac.sign` allocate less: `sha256_hex` of 64 bytes 0.44 -> 0.32 us, `Hmac.sign` 1.07 -> 0.78 us
+ crypto: MD5, SHA-1, SHA-256 and SHA-512/384 run unrolled rounds on whole blocks in place, with no copy or zeroed schedule per block; release builds: SHA-256 350 -> 418 MiB/s, SHA-512 540 -> 645, SHA-1 500 -> 570, MD5 630 -> 785; default builds: SHA-256 74 -> 164, SHA-512 100 -> 244. BLAKE2b inlines its mixing in default builds (206 -> 279)
+ `compress.crc32` uses slicing-by-16 tables built once (600 MiB/s -> 3.4 GiB/s, also for gzip streams), and `adler32` (zlib streams) adds 16 bytes per step with the modulo deferred per 5552 bytes (4.7 -> 18 GiB/s)
+ The compiler itself is built for linux-arm64 too (glibc 2.35, like linux-x64): LLVM 22 cross-compiled for arm64 against an Ubuntu 22.04 sysroot. install.sh accepts arm64 Linux, and CI tests the released arm64 compiler, once a release has it
+ Fix: `markdown.to_html` is linear on long lines: spans, links and escapes rebuilt the line each (a 300 KB line of them took 79 s, now 45 ms). A digit between two backslash escapes (`\[0\[`) no longer leaks placeholder bytes, and a `!` at the end of a disallowed link's label no longer turns the next link into an image
+ Fix: templates: the `round` filter gives a number, so `{{ a + b | round }}` adds instead of joining text (`round(2)` no longer keeps trailing zeros: the new `fixed(2)` writes `12.50`); a whole number literal beyond `int` is a float instead of 0, numbers take an exponent (`1e3`), and `int.$min / -1` no longer panics the render
+ Fix: `sort()` on floats puts NaN last; one NaN left the other numbers unsorted (`binary_search`, `sort_by`, `min_by` and `max_by` use the same order)
+ Fix: a borrowed struct (`this` in a struct method, a `&T` parameter) is copied where the struct itself is expected: `neg(this)` failed with 'An implicit pointer borrow cannot be passed to raw pointer storage', and `let copy: T = this` did not compile
+ Fix: a `Semaphore.acquire`, `Channel.recv` or bounded `send` cancelled right after a release or send woke it kept that wake, so the next waiter slept on while a permit, value or slot was free; the wake now goes on
+ Fix: `CookieJar` refuses a cookie whose `Domain` is a single label such as `com` (it reached every site under it); `Domain=localhost` on localhost is a host-only cookie
+ Fix: `Multipart.add_file` writes its content type as given; quotes became `%22`, so `charset="utf-8"` was mangled
+ Fix: `http.Client` reuses its connection when a response body goes to `Options.output`; every such request opened a new connection
+ Fix: `defer obj.method()` and `co obj.method()` compiled only when everything the object reaches could be cloned, so an object holding an `http.Client` or a socket failed with 'Cannot clone type SSL_CTX'. Such closures now build, and cloning one panics with the reason
+ Fix: a `shared` object's array property can be passed to a `local &[T]` parameter; the conversion failed inside `Array.view` with 'Expected ?GcPtr, got ?shared GcPtr'
+ Fix: `gunzip` and gzip `Decompressor` reject a header with reserved flag bits set, as RFC 1952 requires
+ `fs.set_modified_time(path, unix_ns)` sets a file's modification time (all platforms), and `fs.read_link(path)` returns a symlink's target
+ GC: idle threads no longer keep freed objects alive through stale words: event loops and task runners clear the stack below them before they wait, a task runner holds no finished task in a register while it waits, and a thread's entry returns null (glibc kept its leftover return register in the thread descriptor, which the next thread on that stack exposed). The shared-leak tests allow no slack anymore
+ Fix: WebSocket: a frame with a reserved control opcode (0xB-0xF) was read as a binary message, and a close frame with a code a peer may not send (1005, 1006, 1015, below 1000, 1016-2999, 5000 and up) was echoed back; both now close the connection with 1002
+ Fix: an IPv6 address with an interface name as zone (`fe80::1%eth0`) is numeric: `SocketAddress.parse` threw `invalid_host` and `tcp_client` sent it to a DNS lookup
+ Fix: `log` text records escape control characters (`\x1b` as `\\x1b`) in the message and in quoted field values; they were written raw, so logged input could carry terminal escape sequences
+ Fix: `Ssl.set_host` with an IPv6 address that has a zone (`fe80::1%2`) threw `ssl`; the certificate is checked against the address without its zone
+ Fix: HTTP/1 `Server.header_timeout_ms` bounds the whole request head, as it does for HTTP/2; it applied to each read, so a client sending a byte every few seconds held a connection for hours
+ Fix: HTTP/1 chunked bodies: a chunk size line (with its extensions) is limited to 4 KiB and a trailer line to the header size limit while it is still arriving; one that never ended was buffered without bound (40 MB of extension grew the server by 130 MB)
+ Fix: `Request.form()` / `files()`: a multipart part ends only at a delimiter line, so `--boundary` inside a value no longer cuts it; a file part without `Content-Type` is `text/plain` instead of dropped; `Content-Disposition` parameter names ignore case; a urlencoded name without `=` (`a&b=1`) is kept with an empty value
+ Fix: `WebSocket.connect` fails with `handshake` when the server picks a `Sec-WebSocket-Protocol` or an extension (such as `permessage-deflate`) that the request did not offer, as RFC 6455 requires; such a connection was accepted
+ Fix: the `timeout_ms` of a TLS handshake (`Ssl.accept` / `connect`, `ssl_accept`, and the server's `header_timeout_ms`) bounds the whole handshake; it applied to each wait, so a client sending a byte at a time held the handshake open
+ Fix: `Array.prepend_many(items, true)` keeps the order of `items` when some are equal: it prepended them back to front, so the last of equal items won (`{5, 7, 6, 7}` gave `5, 6, 7`). It also inserts them in one move now instead of one shift per item
+ Fix: `WebSocket.close(code)` throws `protocol` for a code a close frame may not carry (1005, 1006, 1015, below 1000, ...) instead of sending it
+ HTTP server: a worker holding more than its share of the open connections (plus an eighth) lets the others accept, so a burst of a few long-lived connections spreads over all threads (8 connections on 8 workers: one each, was 6 to 8 threads used)
+ Release 0.7.8
+ Fix: a thread waiting for a shared collection that another thread ran was scanned from the collector's own frames, whose stale words could keep freed objects alive
+ LSP: a statement that does not parse or does not check is skipped, so the rest of its function keeps hover, go to definition and completion; diagnostics show one error per broken statement. `x =` or `a +` at the end of a line before a new statement is now "Missing a value after '='" instead of reading the next line's keyword as a name
+ Fix: a list or map literal of a struct with an `$append` / `$set_key` hook (`Bag{ 1, 2, 3 }`) gave the struct without its items; the hooks worked on copies
+ `valk doc http.Server.compress` prints one namespace, declaration or member (stdlib, or `valk doc <dir> <name>` for a package); `core.` is optional and an unknown name suggests close ones
+ Test runner: a failed comparison `assert(a == b)` (and `!=`, `<`, …) shows both sides; the summary counts tests and lists the failed ones; the test binary takes `--filter <text>` at run time
+ Error codes as text: `E.code.name()`, `"failed: " + E.code`, `%{E.code}` and `E.code.to(String)` give the code's name, inherited codes included
+ `linux-arm64` target (Raspberry Pi, Graviton, arm64 Docker images): cross-compile with `--target linux-arm64` from any host; glibc 2.31 like linux-x64. CI builds the test suite on linux-x64 and runs it on a native arm64 runner. The compiler itself is not distributed for arm64 Linux yet
+ Tuple assignment: `(a, b) = (b, a)`, `(w, h) = size()`, also properties, setters and elements, `_` skips a value; the right side is evaluated first, then the targets left to right
+ HTTP server: `Response.stream(reader)` without a size streams until the reader ends (chunked; HTTP/1.0 clients until the connection closes; HTTP/2 DATA frames), and `Response.events(channel)` sends Server-Sent Events from a `Channel[String]` (a ping every 15 s; the stream ends when the channel closes or the server shuts down)
+ HTTP server: files from static dirs and `Response.file` carry `ETag` / `Last-Modified`, answer `If-None-Match` / `If-Modified-Since` with 304 and one `Range` of bytes with 206 (416 past the end, `If-Range` checked); with `compress` text-like files up to 1 MiB are sent gzipped (HTTP/1.1 and HTTP/2)
+ HTTP server: `compress = true` gzips text-like responses of 1 KiB and more for clients that accept it (HTTP/1.1 and HTTP/2), with `Vary: Accept-Encoding`
+ HTTP router: `route.params(path)` decodes the values (`decode: false` gives them as written; they were always raw before) and returns what `*` matched as `*`; `router.allowed_methods(path)` for 405 answers
+ HTTP server: `add_middleware(fn(req, next) Response)` wraps the handler; the first added runs first
+ HTTP client: proxies from `Options.proxy` or `HTTPS_PROXY` / `HTTP_PROXY` / `NO_PROXY` (localhost is always direct; plain HTTP is not proxied from the environment in CGI). HTTPS goes through a `CONNECT` tunnel and still checks the URL's certificate; proxy credentials in the proxy URL
+ `http.Client`: keeps connections open between requests to the same host (200 local HTTPS requests: 640 -> 8 ms) and keeps cookies in a `CookieJar` (RFC 6265 domain, path, Secure and expiry rules; cookies set on a redirect are kept). A kept connection the server closed is retried on a new one when safe. Redirects and downloads now keep the client certificate options
+ HTTP client: `http.Multipart` builds a `multipart/form-data` upload (`add_field`, `add_file`, `apply(options)`)
+ HTTP client: `Options.host` sends another `Host` header, for reaching a virtual host through an IP
+ HTTP client: credentials in the URL (`https://user:pass@host/`) are sent as `Authorization: Basic` (they failed with `invalid_url`), and `Options.basic_auth(user, password)` sets it
+ HTTP client: asks for gzip and decompresses the body (`Options.decompress`, on by default; not with `output` or an own `Accept-Encoding`)
+ sync: `select(.{ a, b }, timeout_ms)` waits on several channels (of any element types) and returns the ready one; `after(ms)` and `ticker(ms)` channels for deadlines and periodic work; `WaitGroup` (`add`, `done`, `wait`) and `Semaphore` (`acquire`, `try_acquire`, `release`)
+ url: `parse_query` / `parse_query_grouped` and `build_query` / `build_query_grouped` outside HTTP, `Url.to_string()` (also `"%{u}"`), `Url.resolve(reference)` per RFC 3986 section 5 (all its examples are tests) and `remove_dot_segments`. HTTP requests, the client's query data and its redirects use them
+ String: `split(on, limit)` (`"key=a=b".split("=", 2)`, also `utf8.split`), `lines()`, `last_index_of`, `count`, `repeat`. `trim` / `ltrim` / `rtrim` also remove Unicode spaces such as the non-breaking space (U+00A0) and the ideographic space (U+3000), like JS, Python and Go; `limit` counts characters
+ Array: `insert(index, value)`, `first()` / `last()` (without removing), `binary_search(value)` on a sorted array (found, and the position or where to insert), `min_by(key)` / `max_by(key)`
+ `Array.sort` / `sorted` are stable (a merge sort; equal elements keep their order), and faster on numbers and presorted input: 1M random ints 99 -> 35 ms, sorted input 52 -> 5 ms. New `sort_by(fn(x) { return x.age })` / `sorted_by` with the key computed once per element
+ A named union can contain itself through a container: `union Json : int | String | Array[Json] | Map[Json] {}` (it was 'Recursive union alternatives are not allowed'); containing itself directly or by value is a clear error
+ `defer { ... }` defers a block of statements; like `defer call()` it captures values when the line runs, and it cannot `return` or `throw`
+ Setters: `set name(value: T) { ... }` next to the getter `name` runs for `x.name = v` and for `+=` and the other compound operators (`x` is evaluated once). Assigning to a getter without a setter, and `++` on a getter, are errors now (`++` used to change a temporary copy)
+ `$mul` and `$div` hooks define `*` and `/` (and `*=`, `/=`) for a class, like `$add` and `$sub`; `time.Duration` uses them: `d * 3`, `d / 2`
+ `<<=` and `>>=`, also on `shared` integers (atomic) and array elements
+ `*=`, `/=` and `%=` on a `shared` integer are atomic like `+=` (a compare-and-swap loop); they stopped the build with a compiler bug before
+ Binary integer literals: `0b1010`, `0b1111_0000`
+ `break 2` and `continue 2` leave that many loops, counted from the innermost (`break 1` is a plain `break`). Collections whose `each` needs cleanup (removals inside `each`) get it for every loop that is left
+ Optional chaining: `user?.address?.city` is null when a value on the way is, and a null skips the rest of the chain (`user?.name.length`); the result is nullable, so it combines with `??` and `?!`, and `user?.save()` is skipped on null. Nothing can be assigned through `?.`. A ternary branch that starts with `.name` needs a space after the `?` now: `c ? .red : .blue`
+ Comparing a nullable value with `==` or `!=` evaluates each side once: `next() == 3` called `next` twice when it returned a nullable, and a handled call inside a nullable ternary failed to compile when compared
+ Processes: `Process.start(exe, args, stdin:, stdout:, stderr:, cwd:, env:)` without a shell, each stream `.inherit`, `.pipe` or `.discard` (`p.stdin.write`, `p.stdout.read_all`), and `Process.output(exe, args, input:)` runs one to its end and returns its code, stdout and stderr. `wait(timeout_ms)`, `signal(.terminate)` and `id()`. Waiting for a child or its pipes only pauses the current coroutine, so a server on the same thread keeps answering (a child that called it hung before). `core.exec` runs on top of it; on Windows through `cmd.exe /d /s /c`, so a command that starts with a quote keeps it
+ LSP: find references, rename (declarations of the own package, checked names) and workspace symbols
+ Named arguments: `resize(height: 5, width: 7)` after the positional ones, in any order, leaving out defaults; they are evaluated in the order written. Variadic parameters: `fn sum(values: ...int)` receives an `Array[int]`, called as `sum(1, 2, 3)` or `sum(...numbers)`
+ Interface methods may have a default body, used by classes that do not define the method; a class method overrides a trait method of the same name (two traits with one name need the class to choose)
+ Function literals leave out parameter and return types where a function type is expected (`nums.filter(fn(x) { return x > 1 })`, `let f: fn(int)(int) = fn(x) { return x * 2 }`). Generic arguments in `[R]` are inferred from the arguments when left out: `nums.map(fn(x) { return "n" + x })` (R from the literal's first return value), `nums.reduce(0, fn(t, v) { return t + v })`; `$R` also works inside a function type
+ Structs, tuples and fixed arrays are `HashMap`/`HashSet` keys without a `$hash` of their own: they hash their parts (integers, enums, pointers, `$hash` types such as `String`, nested structs, nullable parts) consistently with `==`. `each` over a custom `_next` that returns a type parameter holding a tuple gives the tuple whole, like `$offset` (only a declared `(A, B)` list is several values)
+ Enums take methods with `extend Color { ... }` (instance and static), and every enum gets `name()`, `items()` and `from_name()`. `to(String)`, `%{c}` and `"x" + c` give an item's name instead of its number (`to(int)` gives the number); an enum of text keeps giving its text
+ `match` cases take several patterns (`1, 2 =>`, `.red, .blue =>`, `int, float =>`), guards (`int as n if n > 9 =>`, `_ if x < 0 =>`) and integer ranges (`'a' .. 26 =>`, start + count like `each`); a guarded case does not count toward exhaustiveness. The formatter no longer indents `.name =>` cases as a method chain
+ `valk completion bash|zsh|fish` prints a tab-completion script: commands, build options, `--target` values and the make commands of the project (`valk ls --names` lists those one per line)
+ Template expressions compute: `{{ count + 1 }}`, `* / %`, a leading `-` and parentheses; `+` with text joins it, and dividing by zero is a render error
+ `time.Duration`: `of_days` to `of_us`, whole-unit getters, `+`, `-`, comparisons and text like `1h30m`. `later - earlier` on two `DateTime` values gives one (`since`), `DateTime.add` and `subtract` take one, and `time.sleep(duration)` waits one
+ `DateTime.format` and `from_format` know PHP's other `date()` tokens: `y`, `n`, `M`, `F`, `j`, `D`, `l`, `N`, `G`, `h`, `g`, `A`, `a`, `O`, `P`, `T` and `U` (names in English, parsed without regard to case). Those letters were copied as is before; escape one with `\` to keep it literal (`"\\T"` in a string). `from_iso8601` takes a date alone (midnight UTC) and a lowercase `t` and `z`
+ fs: `create_dir_all` (`mkdir -p`), `temp_dir`, `create_temp_dir` and `create_temp_file` (unique names, private permissions), `glob` (`*`, `?`, `[a-z]`, `**`) and `relative(path, base)`
+ New `valk.random`: `between(min, max)`, `below(n)`, `fraction()`, `chance(p)` and `seed` on a fast per-thread generator (xoshiro256**), and `random.Rng.new(seed)` for repeatable sequences. `Array.shuffle` uses it (unbiased, no system call per element) and takes an optional `Rng`
+ `core.cpu_thread_count()` and `core.cpu_core_count()` are public and work on macOS and Windows too; new `core.process_id()`, `core.hostname()` and `core.env_vars()`. An HTTP server without a `worker_count` now starts one worker per logical CPU on macOS and Windows as well (it used 8 there)
+ `remove_where` and `retain` on `Map`, `HashMap`, `FlatMap` and `HashSet`: remove or keep the entries a function picks, in order, also inside `each` over the map
+ `PublicKey.verify` with `rsa_pss_*` accepts any salt length (like Go), so signatures made with the largest salt (Python's `PSS.MAX_LENGTH`, the `openssl` command) verify; `sign` still uses a salt as long as the hash, as JWT and TLS require
+ HTTP static directories serve `index.html` for a directory path (`/` gives `public/index.html`) and redirect `/docs` to `/docs/` first, like Go, nginx and Caddy; `add_static_dir(path, index: "")` turns it off
+ The HTTP client keeps the trailing slash of a redirect's `Location` (and leaves its query alone), so a `/docs` -> `/docs/` redirect no longer loops until `too_many_redirects`
+ `ansi.supported()` is false when standard output is a pipe or a file, so `./app > out.txt` gets no escape codes; `FORCE_COLOR` or `CLICOLOR_FORCE` (not `0`) turns colors on anyway, for CI logs. Piped test output uses the plain `OK`/`FAIL` rows
+ `sync.Channel.new(0)` makes a rendezvous channel: `send` returns once a receiver took the value (as in Go, Rust's `sync_channel(0)` and crossbeam's `bounded(0)`). `new()` stays unbounded; before, `0` meant unbounded too
+ HTTP `req.parse_json()` throws `json.ParseError` for a body that is not JSON, so a handler can answer 400; `json()` stays lenient and gives an empty object
+ `json` integer readers (`.int`, `int_value`, `get_int`, `to_type`, `decode_to`) accept a whole float such as `3.0`; `3.5` still is not an integer
+ `json` writes a whole float as `2.0` instead of `2`, so it reads back as a float (as Python and serde_json do)
+ A float's `to_string()` (and `_in`, `_into`) without `decimals` gives the shortest text that reads back, like interpolation; it gave 2 decimals, so `(0.0001).to_string()` was `0.00`. Pass `to_string(2)` for the old output
+ `fs.extension` gives no extension for a hidden file such as `.bashrc` (it gave `bashrc`); `.config.json` still gives `json`
+ `ByteReader.parse_int`, `parse_uint` and `parse_float` throw `syntax` without advancing when there is no number, where `read_int` and friends return 0
+ `url.decode_path` (and `_into`) decode a path or route parameter and keep `+` (`url.decode` turns it into a space); the HTTP and WebSocket clients reject a port that is not a number with `invalid_url`
+ `http.download` throws `status` when the final answer is not 2xx, and removes the file on any failure, so an error page is never saved as the download
+ `json.decode` reads an integer beyond the `int` range as the nearest float (like JavaScript) instead of failing; `decode_to` into a `u64` field still reads it exactly
+ `Mutex`, `Lock`, `Channel`, `CancelToken` and `Waker` no longer hold a pipe each: a free lock is one atomic operation, waiters are parked and woken directly (from another thread through one wake handle per thread), and creating them never runs out of file descriptors; a cross-thread channel moved 200k values in 11 ms instead of 1.2 s
+ Removing entries of a `Map`, `HashMap`, `HashSet`, `FlatMap` or JSON object inside `each` over it is safe: every other entry is still visited once, and the index stays 0, 1, 2, ... (it used to skip entries silently)
+ `valk fmt --check` lists files that need formatting and exits 1 without writing; `valk --version` prints the version
+ A dependency whose `src` is neither relative nor on GitHub gets that error instead of "No package named ... found"
+ A `use` of a namespace that does not exist is reported at the `use` (with "did you mean 'use valk.fs'"), and an unknown identifier suggests a close name (`printn` -> `println`)
+ An object compares with `==` to an interface it implements; interpolating a value whose `$to` String hook is not `$auto` says how to fix it
+ A private hook (`$eq`, `$offset`, `$to`, ...) used by an operator elsewhere, such as inside `Array`, is reported at the hook with "mark it public", and the use as a note
+ A `match` on an enum, union, error code or bool that misses cases lists them
+ A `match` used as a value without its type, or a `{ ... }` case in a value `match`, gets an error that shows the right form
+ `let v = f() ! { ... }` with a block that carries on explains that the handler gives no value, instead of "A void expression does not produce a value"
+ A call that can throw in a function without an error type names the error and the ways to handle it (`!`, `!?`, `!!` or adding `!Error` to the signature)
+ LSP: empty hover, definition and completion replies are `null`; completion no longer offers compiler-made names (`&`, main's implicit `cli_args`)
+ `valk ls` colors its output only on a terminal and not when `NO_COLOR` is set
+ Test failures print paths relative to the package root like panics; a `--filter` that matches no test is an error; `valk make` names the line that failed
+ `valk run src alice` points at `valk run src -- alice` when `alice` is not a path
+ `valk fmt` lists the files it changed (and leaves unchanged files untouched); `valk fmt -h` and `valk make -h` have their own help; an unknown command says so; `valk -h` lists `valk lsp`
+ The compiler writes errors and warnings to stderr
+ A panic (and its `--debug` stack trace) is written to stderr, so `./app > out.json` no longer swallows the crash
+ `-o` creates the missing directories of the output path
+ A repeated compiler option (`-o`, `--target`, `--filter`, ...) keeps its last value instead of stopping with an internal panic, so arguments after `valk make name` override the declared ones
+ `crypto.base64_decode` and its variants skip line breaks, so wrapped PEM and MIME bodies decode
+ HTTP: `parse_date` reads the RFC 850 and asctime forms too; an oversized request head gets 431 instead of 413; `code_name` knows every RFC 9110 status
+ HTTP `Response.text`, `Response.html` and the plain-text defaults send `charset=utf-8`
+ HTTP `query()` keeps a key without `=` (`?flag`) with the value `""` instead of dropping it
+ HTTP static directories percent-decode the request path, so `/my%20file.txt` serves `my file.txt` (HTTP/1 and HTTP/2)
+ `ansi.supported` is false when `NO_COLOR` is set (no-color.org); the compiler follows from the next release
+ `to_base` and its variants accept bases up to 36 (digits past 9 are letters); 17 to 36 used to give base 16
+ `String.escape` writes other control characters as `\xHH` and a zero byte as `\0`; `unescape` reads `\xHH` and keeps the backslash of an unknown escape, so the two round trip
+ `fs.copy` gives the copy the permission bits of the source on Linux and macOS, like `cp`
+ `log`: a record field replaces a context field from `with` that has the same key, instead of writing the key twice
+ `json` object members keep their order when one is removed
+ `valk doc` labels an extension that only some key or element types get by its pattern, such as `HashMap[String, T]` and `HashMap[u32, T]`, instead of one concrete instantiation
+ `Array.unique`, `remove_duplicates`, `intersect` and `append_many(.., true)` use a set for integers and `$hash` types (such as `String`) from 128 items: O(n) instead of O(n²)
+ HTTPS on Windows verifies servers with the certificates of the system store; no `cacert.pem` needed
+ HTTP ignores chunk extensions (`5;name=value`) in requests and responses, as RFC 9112 asks
+ `utf8.length` and `utf8.chars()` end an invalid sequence at a byte that cannot continue it, instead of swallowing the next character
+ Markdown: `---` after a blank line and `* * *` are rules, a heading's closing `##` is dropped, link and image titles become a `title` attribute, and backslash escapes work
+ A `value` number constant that does not fit the other operand widens like its literal (`small_u8 + BIG`), and a misfit is reported at the use instead of the declaration
+ JSON writes a `DateTime` as ISO 8601 text and reads it back, a `HashSet` or `Deque` as an array, and a `HashMap` with integer keys as an object (they wrote their internal fields)
+ Tuples as values of `Map`, `HashMap` and `Deque`; one name over an array of tuples holds each element whole (generic `each items as item` got the first member only, and `json.encode` of an array of tuples wrote invalid JSON)
+ A panic in a test names the test and its location and still prints the summary of the tests that finished
+ A TCP connect to a name tries its other addresses when the first refuses: `localhost` reaches a server on `::1` only
+ A bool is not a number in operators: `n + flag`, `flag == 1` and `0 < x < 3` are errors (use `.to(int)`); `&`, `|` and `^` of two bools give a bool (was `u8`)
+ `to_string(decimals)` and `to_scientific_string` round an exact half to the even digit, like C, Python, Go and Rust (`(1.5).to_string(0)` was "1")
+ A statement `match` case with a one-line body may be followed by a `.member` case; the next line no longer continues the body as a method chain
+ One ordering hook (`$lt`, `$gt`, `$lte` or `$gte`) answers all four comparisons; `>=` with only `$lt` no longer gives a wrong answer for equal values, and objects without a hook can no longer be ordered (or sorted) by address
+ TCP connections send small writes right away (`TCP_NODELAY`); file and stream responses no longer wait ~40 ms. `TcpConnection.set_no_delay(false)` turns it off

+ Release 0.7.7
+ Structs by value to and from C: extern and export functions follow the target's C calling convention
+ Struct sizes round up to their own alignment, like C
+ The `x n` of a fill goes on the value's line, so a field named `x` can start a line in a literal
+ `@ref(x)` is typed `*T` for `x` of type `T` (was `ptr`), from the declared type: `*?T` after `isset` too
+ Extern pointer parameters take `&value` or a borrow such as `this`
+ `&fixed[start .. length]` is a view into a fixed array, as it is for arrays and slices
+ Integer `read/write_big/little_endian` take byte slices (`&buf`, `&bytes[i .. 4]`) and panic when too short
+ A package whose `require.valk.min` is newer than the compiler gives a warning, shown with the error when the build fails
+ `x[i] += v` (and the other compound assignments) on Array, HashMap, ByteBuffer and other `$offset` types
+ An import used only in `test` blocks is no longer reported as unused
+ A literal in a ternary takes the type of the other side (`cond ? 0 : n`), or the closest type holding both (`cond ? 300 : small_u8` is u16); `value` number constants type like their literal
+ A variable declared from a number that does not fit where it is used gets a fix: 'let bar: i32 = 360'
+ Tuple members by position: `pair[0]`, `pair[1]`
+ `each 0 .. 4 { ... }` / `each items : stmt` without names
+ `String.trim()`, `ltrim()`, `rtrim()` without an argument remove whitespace
+ `&[$T]` infers `T` from an Array, fixed array, String or ByteBuffer argument

+ Release 0.7.6
+ Faster small HashMaps (linear scan up to 8 entries)
+ Faster JSON encoding and float decoding
+ Integer bit counts and the wide product: `leading_zeros`, `trailing_zeros`, `count_ones`, `mul_wide`
+ Faster MD5/SHA updates on large inputs
+ GC: longer steps between collections when most allocations die young
+ HashMap buckets in groups of 8 (faster misses, inserts and large maps)
+ Faster float to text, and Eisel-Lemire float parsing
+ Faster JSON number scanning
+ Fix a struct literal inside a loop growing the stack until it overflows
+ Regex: a lazy DFA finds matches (5 to 20x faster); the VM only fills in capture groups
+ Fix regex matches that could start inside a multi-byte character
+ Fix an HTTP/2 connection closing without its GOAWAY during a shutdown

+ Release 0.7.5
+ `dim()` in the ansi group of String
+ GC optimizations
+ Time zones in DateTime (bundled time zone database on Windows)
+ `log` namespace
+ Ciphers (AES-GCM, ChaCha20-Poly1305), keys and signatures (RSA, ECDSA, Ed25519) in the crypto namespace
+ base64url encoding
+ TLS client certificates: `Ssl.set_certificate`
+ Fix `ssl_connect` replacing a name set with `Ssl.set_host`
+ Fix `??` staying nullable with an isset-checked local on the right
+ `--debug`: debug info for gdb/lldb/Visual Studio, and stack traces on panics and crashes
+ `each start .. count as i`
+ Servers can require client certificates (`SslServerContext.set_client_ca`, `http.Server.tls_client_ca`), and the HTTP client can send one
+ Arrays convert to `&[T]` views where one is expected
+ Fix a runtime NaN printing as `-nan`

+ Release 0.7.4
+ Make commands in valk.json: `valk make {name}` and `valk ls`
+ Cookies in the http namespace
+ `each`/`lock` take a literal without parentheses

+ Release 0.7.3
+ Method chains over several lines
+ Enum members and clearer errors for `.name` typehints
+ Fix conditions that carry an error handler
+ Close file descriptors properly
+ Use Process for `--run`

+ Release 0.7.2
+ Fix compiler analysis bug
+ Handle HTTP 100 continue request

+ Release 0.7.1
+ Api change guard
+ Enum/error output in `valk doc`
+ fmt correction
+ Selective parsing options
+ Doc generate improvements
+ Websockets
+ Deprecation flagging
+ Reuse address option
+ HTTP server shutdown signal
+ Improve template api (breaking change: RenderOptions.escape is now fn(local &[u8], io.Writer)(uint !io.IoError))
+ Json null value to string is now empty string instead of `"null"`
+ Deprecate flag on unsafe raw pointer functions

+ Release 0.7.0
+ Audit API & language syntax
+ Bug fixes standard library
+ Documentation feature using `///`

+ Release 0.6.4
+ Fix isset on union containing null
+ HTTP/1.0 support
+ HTTP/2.0 optimizations
```

## Maybe

```
- Complete libc integration
- on exit thread/process { ... }
- WASM support
- Allow @undefined for entire struct. E.g. let user = User { @undefined }
- @stack(StructName) -> stackalloc StructName { ... }
-- This is the same as `let x : <StructName> = { ... }`
-- but stackalloc can be used as a value, e.g. in function arguments
```

## Done

```
+ Release 0.6.3
+ Optimize GC (transfer refs)
+ Remove void pointers from the escape analysis

+ Release 0.6.2
+ Language audit + fixes

+ Release 0.6.1
+ Fix enum type bug
+ Fix missing gc roots for embedded files
+ Compiler optimizations
+ GC stack & scan rewrite
+ Data race solution
+ Improve slice syntax

+ Release 0.6.0
+ math namespace
+ more valk lib functions
+ integer .$max/.$min
+ redesign borrows & slices

+ Release 0.5.0
+ Big api overhaul
+ Full security audit
+ Replace unsafe code with safe code
+ Update docs

+ Release 0.4.4
+ Full design doc
+ Stablize the language
+ Benchmarks
+ uslice (cstring) / slice (String)
+ Coroutine growing stack

+ Release 0.4.3
+ Recompile for windows

+ Release 0.4.2
+ Restore embedded LLVM and remove the valkir dependency

+ Release 0.4.0/1
+ Rework Type logic + syntax
+ LSP improvements

+ Release 0.3.5
+ Upgrade valkir version

+ Release 0.3.4
+ Bug fixes (parsing / stdlib / $clone)

+ Release 0.3.3
+ Fix code gen bug
+ Optimize compile speed

+ Release 0.3.2
+ Fix alignment
+ Multi thread IR compiling
+ Upgrade valkir version
+ Remove --no-opt / Add --opt

+ Release 0.3.1
+ Remove llvm-lib dependency
~ Data race solution (Threads done via shared type, MutexValue not done)
+ Remove union gc slot
~ uslice (cstring) / slice (String)

+ Release 0.3.0
+ Cache directory hash fix + race lock
+ Date/time classes
+ Remove LLVM (valkir is the default backend, `--clang` compiles the IR instead)
+ 'export' functions + build library instead of executable
+ Fix access types in extend

+ Release 0.2.6
+ Adjust package directory lookup
+ Improve error payload parsing
+ Fix Array prepend many
+ Implement `--valkir` flag

+ Release 0.2.5
+ Bugfixing

+ Release 0.2.4
+ load "define" from config (alternative for --def)
+ valk command output & usage improvements

+ Release 0.2.3
+ Json improvements
+ Http lowercase header keys
+ Extend access types `~+ -+ -~ -~+`
+ IR & type improvements
+ [start-index .. length] -> calls the $range function (start_index: uint, length: uint)

+ Release 0.2.2
+ Tagged unions
+ Class interfaces
+ Lib bug fixes

+ Release 0.2.1
+ `$default` type value hook
+ LSP improvements
+ Defer statements

+ Release 0.2.0
+ Rewrite entire compiler
+ valk code formatter


+ Release 0.1.14
+ Improve watch command
+ Validator functions
+ Template improvements
+ Package platform (vpkg.dev)
+ Http fixes
+ Rename `--no-default-libs` to `--no-system-libs`
+ Json changes `.get` -> `.get_or`
+ Allow using `main` namespace from another package

+ Release 0.1.13
+ Process class to start a process async

+ Release 0.1.12
+ Fix errors missing payload, e.g. println(E.message) -> crash, because no message was set in the throw code
+ SSL allow to disable ca-cert host verification
+ ByteReader + Rewrite ByteBuffer functions
+ Move 'type' namespace to 'core'
+ Only allow references on local variable
+ each ... skip ... as ... {}

+ Release 0.1.11
+ Rework namespaces
+ Nullable int
+ fnptr -> fn without allocation
+ use error pass handler by default
+ 1 object per file instead of namespace

+ Release 0.1.10
+ options: --no-default-libs --link-arg {arg} --sysroot {path}

+ Release 0.1.9
+ Rework errors

+ Release 0.1.8
+ Multi assign
+ Directory as package src
+ Crypto: base64/sha1/sha256

+ Release 0.1.7
+ --release option
+ json optimizations
+ slice type + array optimizations
+ rework value scope parsing

+ Release 0.1.1 - 0.1.6
+ Optimizations & rewrites

+ Release 0.1.0

+ A `--watch` build argument
+ A `--ir` build argument (output is a single IR file)
+ Improve link command
+ Release 0.0.17

+ Markdown parser
+ Embed file into code `#embed({path})`
+ Rename `#STR` to `#string`
+ A `extern` keyword to define things in .valk files instead .valk.h
+ Remove all header logic - no more `.valk.h` files
+ Release 0.0.16

+ LSP improvements
+ rename `fnRef` -> `fnptr`
+ Release 0.0.15

+ Fix function type type-checking
+ Improve docs
+ Make sure the LSP works on windows
+ Check `TODO` in the code base
+ Release 0.0.14

+ Global cross-thread race lock & .$is_shared builtin
+ Rework stack allocation arrays & structs + init values
+ Update docs
+ Release 0.0.13

+ Syntax clean up
+ Release 0.0.12

+ Re-enable multi threaded compiling
+ Fix closure data binding order
+ Fix cast ptr -> u32/u16/u8
+ Rework async IO
+ Rework stack & coroutines
+ Socket API change
+ Remove `utils` namespace / move ByteBuffer to `type` namespace
+ Rework AST parse flow
+ Async mutexes
+ Release 0.0.11

+ Fix shared gc bug
+ Release 0.0.10

+ template engine improvements
+ Rework arrays from `@array[...]{...}` to `{1, 2, 3}`
+ Basic crypto functions
+ Improve enums
+ Release 0.0.9

+ valk lsp
+ vscode extension
+ Release 0.0.8

+ fn encode[T](value: T) -> fn encode(value: $T)
+ valk doc
+ use "x" as X { a, b as B, c }
+ Allocate stack/heap arrays : @array[u8 x 3]{ 'a', 'b', 'c' }
+ Copy on assign if not pointer or number
~ template engine
+ Release 0.0.7

+ Update HTTP client options
+ Release 0.0.6

+ Allow identifiers for numbers in types, e.g. *[u8 x fs:PATH_MAX_LEN] or global list : [uint x MAX_ITEMS]
+ Add more standard library functions
+ Update docs
+ Release 0.0.5

+ Rework GC to remove reconnect list
+ Http option follow redirects (default: true)
+ Use fs:resolve on all paths in the compiler
+ Warn unused variables / namespaces. And --no-warn/-nw option
+ Type modes (mode Path for String) (extends type but no new properties allowed)
+ Dont use hashes to compare IR. Just compare file content (= faster & more correct)
+ Release 0.0.4

+ Use $lazy properties in compiler
+ Path class for creating correct win/macos/linux paths
+ Release 0.0.3

+ Finish all GC related todos
+ Add more basic features
+ Release 0.0.2

+ Release 0.0.1
```
