#!/usr/bin/env python3
# Metamorphic probe of the borrow, shared and lock rules. Every rule has a safe and an unsafe
# program around one marked expression; each wrapper (value scope, ternary, tuple, `??`, call,
# closure, ...) rewrites that expression, which must not change the verdict:
#   hole:     the unsafe program compiles
#   refused:  the safe program does not (a false positive, or a wrapper invalid there)
#
#   tests/probe/gen.py [--valk ./valk] [--jobs 8] [--only text] [--update] [--show]
#
# The outcome of every case is kept in tests/probe/expected.txt; `--update` rewrites it.

import argparse, os, re, shutil, subprocess, sys, tempfile
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))

PRELUDE = """use valk.thread
error ProbeFail (no)
class Item {
    n: int (0)
    + fn me() Item { return this }
}
class Store { list: Array[Item] (.{}) }
struct WrapItem { v: Item }
class BoxItem { v: Item }
struct WrapRef { v: &Item }
class BoxRef { v: &Item }
struct WrapSlice { v: &[int] }
class BoxSlice { v: &[int] }
global probe_flag: bool (true)
global probe_item: Item (Item{})
global probe_ints: [int x 2] ({ 1, 2 })
global keep: ?Item (null)
global keep_ref: ?&Item (null)
fn id_item(x: Item) Item { return x }
fn id_ref(x: &Item) &Item { return x }
fn id_slice(x: &[int]) &[int] { return x }
fn opt_item(x: Item) ?Item { return x }
fn opt_ref(x: &Item) ?&Item { return x }
fn opt_slice(x: &[int]) ?&[int] { return x }
fn fails_item(x: Item) Item !ProbeFail {
    if !probe_flag : throw .no
    return x
}
fn fails_ref(x: &Item) &Item !ProbeFail {
    if !probe_flag : throw .no
    return x
}
fn fails_slice(x: &[int]) &[int] !ProbeFail {
    if !probe_flag : throw .no
    return x
}
fn gid[T](x: T) T { return x }
fn stash(x: Item) { keep = x }
fn view2(p: &[int]) &[int] { return p.view(0, 2) }
"""

# Each value type: its name, a fallback of that type, and the helper suffix
TYPES = {
    "item": ("Item", "Item{}", "item"),
    "ref": ("&Item", "&probe_item", "ref"),
    "slice": ("&[int]", "&probe_ints", "slice"),
}


def wrappers():
    # name -> fn(expr, type key, n) -> (statements before, expression)
    def W(f):
        return f
    return {
        "plain": W(lambda e, t, n: ([], e)),
        "vscope": W(lambda e, t, n: ([], "<{ return %s }" % e)),
        "ternary": W(lambda e, t, n: ([], "(probe_flag ? %s : %s)" % (e, e))),
        "ternary-other": W(lambda e, t, n: ([], "(probe_flag ? %s : %s)" % (e, TYPES[t][1]))),
        "tuple": W(lambda e, t, n: (["let t%d = (%s, 1)" % (n, e)], "t%d[0]" % n)),
        "coalesce": W(lambda e, t, n: ([], "(opt_%s(%s) ?? %s)" % (TYPES[t][2], e, TYPES[t][1]))),
        "call": W(lambda e, t, n: ([], "id_%s(%s)" % (TYPES[t][2], e))),
        "generic": W(lambda e, t, n: ([], "gid[%s](%s)" % (TYPES[t][0], e))),
        "handler": W(lambda e, t, n: ([], "(fails_%s(%s) !? %s)" % (TYPES[t][2], e, TYPES[t][1]))),
        "struct": W(lambda e, t, n: ([], "Wrap%s{ v: %s }.v" % (TYPES[t][2].capitalize(), e))),
        "class": W(lambda e, t, n: ([], "Box%s{ v: %s }.v" % (TYPES[t][2].capitalize(), e))),
        "local": W(lambda e, t, n: (["let l%d = %s" % (n, e)], "l%d" % n)),
        "closure": W(lambda e, t, n: (["let f%d = fn() %s { return %s }" % (n, TYPES[t][0], e)], "f%d()" % n)),
        "if": W(lambda e, t, n: (["let w%d: ?%s = null" % (n, TYPES[t][0]),
                                  "if probe_flag { w%d = %s } else { w%d = %s }" % (n, e, n, e)],
                                 "(w%d ?! panic(\"probe\"))" % n)),
        "array": W(lambda e, t, n: ([], "(Array[%s]{ %s }.get(0) !? %s)" % (TYPES[t][0], e, TYPES[t][1]))),
    }


# A borrow of a local may not be stored: these wrappers refuse it by type, whatever the rule
LOCAL_BORROW_SKIP = ("struct", "class", "closure", "if", "array")

# A rule: the type of the marked expression, then the safe and unsafe bodies of `probe_main`.
# `@W(...)` marks the expression the wrappers rewrite; `SETUP` lines come first.
RULES = [
    ("alias-then-publish", "item",
     """let o = Item{}
let a = @W(Item{})
let s: shared Item = o
a.n = 5
println(s.n)""",
     """let o = Item{}
let a = @W(o)
let s: shared Item = o
a.n = 5
println(s.n)"""),
    ("publish-escaped", "item",
     """let o = Item{}
let s: shared Item = @W(o)
println(s.n)""",
     """let o = Item{}
keep = o
let s: shared Item = @W(o)
println(s.n)"""),
    ("publish-then-reuse", "item",
     """let o = Item{}
let s: shared Item = @W(o)
println(s.n)""",
     """let o = Item{}
let s: shared Item = @W(o)
o.n = 5
println(s.n)"""),
    ("borrow-then-publish", "ref",
     """let o = Item{}
let o2 = Item{}
let r = @W(&o2)
let s: shared Item = o
println(r.n + s.n)""",
     """let o = Item{}
let r = @W(&o)
let s: shared Item = o
println(r.n + s.n)""", LOCAL_BORROW_SKIP),
    ("stash-then-publish", "item",
     """let o = Item{}
stash(@W(Item{}))
let s: shared Item = o
println(s.n)""",
     """let o = Item{}
stash(@W(o))
let s: shared Item = o
println(s.n)"""),
    ("alias-then-lock-store", "item",
     """let st: shared Lock[Store] = .new(Store{}) !!
let x = Item{}
let a = @W(Item{})
lock st as s { s.list.append(x) }
a.n = 5""",
     """let st: shared Lock[Store] = .new(Store{}) !!
let x = Item{}
let a = @W(x)
lock st as s { s.list.append(x) }
a.n = 5"""),
    ("lock-store-escaped", "item",
     """let st: shared Lock[Store] = .new(Store{}) !!
let x = Item{}
lock st as s { s.list.append(@W(x)) }""",
     """let st: shared Lock[Store] = .new(Store{}) !!
let x = Item{}
keep = x
lock st as s { s.list.append(@W(x)) }"""),
    ("lock-store-then-reuse", "item",
     """let st: shared Lock[Store] = .new(Store{}) !!
let x = Item{}
lock st as s { s.list.append(@W(x)) }
println("stored")""",
     """let st: shared Lock[Store] = .new(Store{}) !!
let x = Item{}
lock st as s { s.list.append(@W(x)) }
x.n = 5"""),
    ("frame-storage-returned", "slice",
     """FN fn probe_make() &[int] {
    let a = [int]{ 1, 2, 3, 4 }
    return @W(view2(a))
}
println(probe_make()[0])""",
     """FN fn probe_make() &[int] {
    let a: [int x 4] = { 1, 2, 3, 4 }
    return @W(view2(a))
}
println(probe_make()[0])"""),
    ("frame-storage-kept", "slice",
     """FN global probe_kept: ?&[int] (null)
let a = [int]{ 1, 2, 3, 4 }
probe_kept = @W(view2(a))""",
     """FN global probe_kept: ?&[int] (null)
let a: [int x 4] = { 1, 2, 3, 4 }
probe_kept = @W(view2(a))"""),
    ("attach-then-reuse", "item",
     """FN fn attach_xs(x: Item, s: locked Store) { s.list.append(x) }
let st: shared Lock[Store] = .new(Store{}) !!
let x = Item{}
lock st as s { attach_xs(@W(x), s) }
println("attached")""",
     """FN fn attach_xs(x: Item, s: locked Store) { s.list.append(x) }
let st: shared Lock[Store] = .new(Store{}) !!
let x = Item{}
lock st as s { attach_xs(@W(x), s) }
x.n = 5"""),
    ("attach-swapped-then-reuse", "item",
     """FN fn attach_sx(s: locked Store, x: Item) { s.list.append(x) }
let st: shared Lock[Store] = .new(Store{}) !!
let x = Item{}
lock st as s { attach_sx(s, @W(x)) }
println("attached")""",
     """FN fn attach_sx(s: locked Store, x: Item) { s.list.append(x) }
let st: shared Lock[Store] = .new(Store{}) !!
let x = Item{}
lock st as s { attach_sx(s, @W(x)) }
x.n = 5"""),
    ("attach-also-global", "item",
     """FN fn attach_keep(s: locked Store, x: Item) { s.list.append(x) }
let st: shared Lock[Store] = .new(Store{}) !!
let x = Item{}
lock st as s { attach_keep(s, @W(x)) }""",
     """FN fn attach_keep(s: locked Store, x: Item) {
    s.list.append(x)
    keep = x
}
let st: shared Lock[Store] = .new(Store{}) !!
let x = Item{}
lock st as s { attach_keep(s, @W(x)) }"""),
    ("closure-lock-store-then-reuse", "item",
     """let st: shared Lock[Store] = .new(Store{}) !!
let x = Item{}
lock st as s {
    let put = fn(t: locked Store, v: Item) { t.list.append(v) }
    put(s, @W(x))
}
println("stored")""",
     """let st: shared Lock[Store] = .new(Store{}) !!
let x = Item{}
lock st as s {
    let put = fn(t: locked Store, v: Item) { t.list.append(v) }
    put(s, @W(x))
}
x.n = 5"""),
    ("shared-fixed-array-then-reuse", "item",
     """let x = Item{}
let s: shared [Item x 1] = { @W(x) }
println(s[0].n)""",
     """let x = Item{}
let s: shared [Item x 1] = { @W(x) }
x.n = 5
println(s[0].n)"""),
    ("locked-escape", "item",
     """let st: shared Lock[Store] = .new(Store{}) !!
let out: ?Item = null
lock st as s {
    s.list.append(Item{})
    let v = s.list.get(0) ! return
    out = @W($clone(v))
}""",
     """let st: shared Lock[Store] = .new(Store{}) !!
let out: ?Item = null
lock st as s {
    s.list.append(Item{})
    let v = s.list.get(0) ! return
    out = @W(v)
}"""),
    ("two-locks", "item",
     """let a: shared Lock[Store] = .new(Store{}) !!
let b: shared Lock[Store] = .new(Store{}) !!
lock a as x {
    x.list.append(Item{})
    lock b as y { y.list.append(@W(Item{})) }
}""",
     """let a: shared Lock[Store] = .new(Store{}) !!
let b: shared Lock[Store] = .new(Store{}) !!
lock a as x {
    x.list.append(Item{})
    lock b as y { y.list.append(@W(x.list.get(0) ! return)) }
}"""),
    ("picked-lock", "item",
     """let a: shared Lock[Store] = .new(Store{}) !!
let b: shared Lock[Store] = .new(Store{}) !!
lock a as x {
    x.list.append(Item{})
    lock b as y {
        let t = probe_flag ? y.list : x.list
        t.append(@W(Item{}))
    }
}""",
     """let a: shared Lock[Store] = .new(Store{}) !!
let b: shared Lock[Store] = .new(Store{}) !!
lock a as x {
    x.list.append(Item{})
    lock b as y {
        let t = probe_flag ? y.list : x.list
        t.append(@W(x.list.get(0) ! return))
    }
}"""),
]

MARK = re.compile(r"@W\(")


def find_marked(line):
    m = MARK.search(line)
    if not m:
        return None
    depth = 0
    i = m.end()
    while i < len(line):
        c = line[i]
        if c == "(":
            depth += 1
        elif c == ")":
            if depth == 0:
                return m.start(), m.end(), i
            depth -= 1
        i += 1
    raise ValueError("unbalanced @W( in: " + line)


def render(body, type_key, wrap):
    top = []
    lines = []
    n = 0
    for line in body.split("\n"):
        if line.startswith("FN "):
            top.append(line[3:])
            continue
        if top and (line.startswith("    ") or line == "}") and not lines and top[-1] != "":
            top.append(line)
            continue
        lines.append(line)
    out_top = []
    for line in top:
        out_top.extend(apply(line, type_key, wrap, n))
    out = []
    for line in lines:
        out.extend(["    " + l for l in apply(line, type_key, wrap, n)])
    return "\n".join(out_top), "\n".join(out)


def apply(line, type_key, wrap, n):
    found = find_marked(line)
    if not found:
        return [line]
    start, inner, end = found
    expr = line[inner:end]
    before, replaced = wrap(expr, type_key, n)
    indent = line[:len(line) - len(line.lstrip())]
    return [indent + b for b in before] + [line[:start] + replaced + line[end + 1:]]


def program(body, type_key, wrap):
    top, main = render(body, type_key, wrap)
    return PRELUDE + top + "\nfn main() {\n" + main + "\n}\n"


def build(valk, workdir, key, source):
    path = os.path.join(workdir, re.sub(r"[^A-Za-z0-9]+", "_", key) + ".valk")
    with open(path, "w") as fh:
        fh.write(source)
    proc = subprocess.run([valk, "build", path, "-o", path[:-5], "--no-warn"], capture_output=True, text=True)
    out = proc.stdout + proc.stderr
    if proc.returncode == 0:
        return True, ""
    error = re.search(r"# Error: (.*)", out)
    return False, (error.group(1).strip() if error else (out.strip().splitlines() or ["?"])[-1])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--valk", default=os.path.join(ROOT, "valk"))
    ap.add_argument("--jobs", type=int, default=os.cpu_count() or 4)
    ap.add_argument("--only")
    ap.add_argument("--update", action="store_true")
    ap.add_argument("--show", action="store_true", help="print every case that is not ok")
    opts = ap.parse_args()

    cases = []
    for rule, type_key, safe, unsafe, *rest in RULES:
        skip = rest[0] if rest else ()
        for wname, wrap in wrappers().items():
            key = "%s %s" % (rule, wname)
            if wname in skip:
                continue
            if opts.only and opts.only not in key:
                continue
            cases.append((key, program(safe, type_key, wrap), program(unsafe, type_key, wrap)))

    workdir = tempfile.mkdtemp(prefix="valk-probe-")
    results = {}
    with ThreadPoolExecutor(opts.jobs) as pool:
        futures = {}
        for key, safe, unsafe in cases:
            futures[key] = (pool.submit(build, opts.valk, workdir, key + " safe", safe),
                            pool.submit(build, opts.valk, workdir, key + " unsafe", unsafe))
        for key, (fs, fu) in futures.items():
            safe_ok, safe_err = fs.result()
            unsafe_ok, _ = fu.result()
            if unsafe_ok and safe_ok:
                results[key] = ("hole", "")
            elif unsafe_ok:
                results[key] = ("hole", "safe twin refused: " + safe_err)
            elif not safe_ok:
                results[key] = ("refused", safe_err)
            else:
                results[key] = ("ok", "")

    lines = ["%s | %s%s" % (k, v[0], (" | " + v[1]) if v[1] else "") for k, v in sorted(results.items())]
    expected_path = os.path.join(HERE, "expected.txt")
    if opts.update:
        with open(expected_path, "w") as fh:
            fh.write("\n".join(lines) + "\n")
    expected = set(open(expected_path).read().splitlines()) if os.path.exists(expected_path) else set()
    changed = [l for l in lines if l not in expected] if expected and not opts.only else []
    for l in lines:
        if opts.show and " | ok" not in l:
            print(l)
    for l in changed:
        print("CHANGED: " + l)
    counts = {}
    for kind, _ in results.values():
        counts[kind] = counts.get(kind, 0) + 1
    print("# %s" % ", ".join("%s %d" % kv for kv in sorted(counts.items())))
    failed = bool(changed)
    if failed and not opts.update:
        print("# workdir: " + workdir)
    else:
        shutil.rmtree(workdir, ignore_errors=True)
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
