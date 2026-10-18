#!/usr/bin/env python3
# Calls every public method of the core collections on a plain value, a `shared` view and a
# `locked` view, compiles each call and sorts the results: compiles, refused in the caller
# (with the message), or failed inside the stdlib, which is always a bug. The calls expected
# to compile are built together per subject and context, alone again if that fails.
#
#   tests/views/gen.py [--valk ./valk] [--jobs 8] [--only Array] [--update]
#
# The outcome of every call is kept in tests/views/expected.txt; `--update` rewrites it.

import argparse, json, os, re, subprocess, sys, tempfile
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))

# (label, class name in the doc, type arguments, property type, property default)
SUBJECTS = [
    ("Array[int]", "Array", {"T": "int"}, "Array[int]", ".{ 3, 1, 2 }"),
    ("Array[String]", "Array", {"T": "String"}, "Array[String]", '.{ "b", "a" }'),
    ("Array[Item]", "Array", {"T": "Item"}, "Array[Item]", ".{ Item { v: 2 }, Item { v: 1 } }"),
    ("HashMap[String,int]", "HashMap", {"K": "String", "T": "int"}, "HashMap[String, int]", '.{ "a" => 1 }'),
    ("HashMap[int,Item]", "HashMap", {"K": "int", "T": "Item"}, "HashMap[int, Item]", ".{ 1 => Item {} }"),
    ("Map[Item]", "HashMap", {"K": "String", "T": "Item"}, "Map[Item]", '.{ "a" => Item {} }'),
    ("HashSet[String]", "HashSet", {"T": "String"}, "HashSet[String]", '.{ "a" }'),
    ("HashSet[int]", "HashSet", {"T": "int"}, "HashSet[int]", ".{ 1, 2 }"),
    ("Deque[int]", "Deque", {"T": "int"}, "Deque[int]", ".{}"),
    ("Deque[Item]", "Deque", {"T": "Item"}, "Deque[Item]", ".{}"),
    ("Heap[int]", "Heap", {"T": "int"}, "Heap[int]", ".{}"),
    ("Heap[String]", "Heap", {"T": "String"}, "Heap[String]", ".{}"),
    ("FlatMap[String,int]", "FlatMap", {"K": "String", "T": "int"}, "FlatMap[String, int]", '.{}'),
    ("FlatMap[int,Item]", "FlatMap", {"K": "int", "T": "Item"}, "FlatMap[int, Item]", '.{}'),
    ("ByteBuffer", "ByteBuffer", {}, "ByteBuffer", "(ByteBuffer.new())"),
    ("String", "String", {}, "String", '("abc")'),
]

CONTEXTS = ["plain", "shared", "locked"]

SCALARS = {
    "int": "1", "uint": "0", "u8": "65", "u16": "1", "u32": "1", "u64": "1", "i64": "1",
    "f64": "1.5", "float": "1.5", "bool": "true", "String": '"a"', "Item": "Item { v: 3 }",
    "char": "'a'",
}


def split_top(s, sep=","):
    out, depth, cur = [], 0, ""
    for ch in s:
        if ch in "([{":
            depth += 1
        elif ch in ")]}":
            depth -= 1
        if ch == sep and depth == 0:
            out.append(cur.strip())
            cur = ""
        else:
            cur += ch
    if cur.strip():
        out.append(cur.strip())
    return out


def subst(t, args):
    return re.sub(r"\b([A-Z])\b", lambda m: args.get(m.group(1), m.group(1)), t)


def value_for(t, args, view=""):
    t = subst(t.strip(), args)
    if t.startswith("?"):
        return value_for(t[1:], args, view)
    if t in SCALARS:
        return SCALARS[t]
    m = re.fullmatch(r"fn\((.*?)\)\((.*)\)", t)
    if m:
        params = split_top(m.group(1))
        ret = m.group(2).strip()
        names = ["a%d" % i for i in range(len(params))]
        # A shared receiver hands its callbacks shared elements
        if view:
            params = [view + " " + p if p == "Item" else p for p in params]
        sig = ", ".join("%s: %s" % (n, p) for n, p in zip(names, params))
        if ret in ("", "void"):
            return "fn(%s) {}" % sig
        body = value_for(ret, args)
        if body is None:
            return None
        if ret == "bool" and len(params) == 2 and params[0] == params[1] and params[0] in ("int", "String"):
            body = "a0 < a1"
        return "fn(%s) %s { return %s }" % (sig, ret, body)
    m = re.fullmatch(r"(Array|HashSet|Deque)\[(.*)\]", t)
    if m:
        v = value_for(m.group(2), args)
        return None if v is None else "%s[%s]{ %s }" % (m.group(1), m.group(2), v)
    m = re.fullmatch(r"(HashMap|FlatMap)\[(.*)\]", t)
    if m:
        kt, vt = split_top(m.group(2))
        k, v = value_for(kt, args), value_for(vt, args)
        if k is None or v is None:
            return None
        if m.group(1) == "FlatMap":
            return "FlatMap[%s, %s].new()" % (kt, vt)
        return "%s[%s, %s]{ %s => %s }" % (m.group(1), kt, vt, k, v)
    if t == "local &[u8]" or t == "&[u8]":
        return "\"ab\""
    return None


def methods(doc, cls, args):
    funcs = dict(doc["functions"])
    for ext_type, ext in (doc.get("extensions") or {}).items():
        # Extensions for one element type, like Array[uint].sum
        inner = re.fullmatch(r"\w+\[(.*)\]", ext_type)
        if inner and list(args.values()) and inner.group(1) != ", ".join(args.values()):
            continue
        funcs.update(ext)
    for name, f in sorted(funcs.items()):
        if f["act"] != "+" or f["is_static"]:
            continue
        yield name, f


def call_code(name, f, args, ctx):
    if f["is_getter"]:
        return "let r = x.%s" % name
    values = []
    lets = []
    for a in f["arguments"]:
        if "default-value" in a:
            break
        v = value_for(a["type"], args, "" if ctx == "plain" else ctx)
        if v is None:
            return None
        # Values are passed as named locals, the way code usually passes them; callbacks inline
        if v.startswith("fn("):
            values.append(v)
        else:
            t = subst(a["type"].strip(), args)
            if t.startswith("local "):
                t = t[len("local "):]
            lets.append("let a%d: %s = %s" % (len(values), t, v))
            values.append("a%d" % len(values))
    call = "x.%s(%s)" % (name, ", ".join(values))
    ret = (f.get("return-type") or "void").strip()
    if f.get("error_type"):
        line = ("let r = %s ! return" if ret != "void" else "%s ! return") % call
    else:
        line = ("let r = %s" if ret != "void" else "%s") % call
    return "\n        ".join(lets + [line])


PRELUDE = """class Item {
    v: int (0)
    + fn lt(o: Item) bool $lt { return this.v < o.v }
    + fn eq(o: Item) bool $eq { return this.v == o.v }
    + fn hash() uint $hash { return this.v.to(uint) }
}
class Holder {
    p: %s %s
}
"""

# One function per call; a program holds one call, or every call of a subject and context that
# is expected to compile, since a program that compiles proves each of its calls does
SUBJECTS_CODE = {
    "plain": """fn subject%d(h: Holder) {
    let x = h.p
    %s
}
""",
    "shared": """fn subject%d(h: shared Holder) {
    let x = h.p
    %s
}
""",
    "locked": """fn subject%d(l: shared Lock[Holder]) {
    lock l as h {
        let x = h.p
        %s
    }
}
""",
}

MAINS = {
    "plain": ("fn main() {\n", "    subject%d(Holder {})\n"),
    "shared": ("fn main() {\n    let h: shared Holder = Holder {}\n", "    subject%d(h)\n"),
    "locked": ("fn main() {\n    let l: shared Lock[Holder] = .new(Holder {}) !!\n", "    subject%d(l)\n"),
}


def program(ptype, default, ctx, codes):
    default_text = default if default.startswith("(") else "(%s)" % default
    head, call = MAINS[ctx]
    return (PRELUDE % (ptype, default_text)
            + "".join(SUBJECTS_CODE[ctx] % (i, code) for i, code in enumerate(codes))
            + head + "".join(call % i for i in range(len(codes))) + "}\n")


def build(valk, workdir, key, source):
    path = os.path.join(workdir, re.sub(r"[^A-Za-z0-9]+", "_", key) + ".valk")
    with open(path, "w") as fh:
        fh.write(source)
    proc = subprocess.run([valk, "build", path, "-o", path[:-5] + ".ll", "--no-warn", "--ir"], capture_output=True, text=True)
    out = proc.stdout + proc.stderr
    with open(path[:-5] + ".log", "w") as fh:
        fh.write(out)
    if proc.returncode == 0:
        return "ok", ""
    file = re.search(r"# File: (.*)", out)
    error = re.search(r"# Error: (.*)", out)
    message = error.group(1).strip() if error else out.strip().splitlines()[-1] if out.strip() else "?"
    if file and file.group(1).strip() != path:
        lib = os.path.relpath(file.group(1).strip(), ROOT)
        line = re.search(r"# Line: (\d+)", out)
        return "stdlib", "%s:%s %s" % (lib, line.group(1) if line else "?", message)
    return "refused", message


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--valk", default=os.path.join(ROOT, "valk"))
    ap.add_argument("--jobs", type=int, default=os.cpu_count() or 4)
    ap.add_argument("--only")
    ap.add_argument("--update", action="store_true")
    opts = ap.parse_args()

    doc_path = os.path.join(tempfile.mkdtemp(), "stdlib.json")
    subprocess.run([opts.valk, "doc", os.path.join(ROOT, "lib"), "--stdlib", os.path.join(ROOT, "lib"),
                    "-o", doc_path, "--no-private"], check=True, capture_output=True)
    core = json.load(open(doc_path))["namespaces"]["core"]["classes"]

    expected_path = os.path.join(HERE, "expected.txt")
    expected = set(open(expected_path).read().splitlines()) if os.path.exists(expected_path) else set()
    expected_ok = set(l.split(" | ")[0] for l in expected if l.endswith(" | ok"))

    jobs = []
    groups = []
    for label, cls, args, ptype, default in SUBJECTS:
        if opts.only and opts.only not in label:
            continue
        for ctx in CONTEXTS:
            batch = []
            for name, f in methods(core[cls], cls, args):
                code = call_code(name, f, args, ctx)
                key = "%s.%s %s" % (label, name, ctx)
                jobs.append((key, None if code is None else program(ptype, default, ctx, [code])))
                if code is not None and key in expected_ok:
                    batch.append((key, code))
            if batch:
                groups.append((label + " " + ctx, program(ptype, default, ctx, [c for _, c in batch]), [k for k, _ in batch]))

    workdir = tempfile.mkdtemp(prefix="valk-views-")
    results = {}
    with ThreadPoolExecutor(opts.jobs) as pool:
        batches = {name: pool.submit(build, opts.valk, workdir, name, src) for name, src, _ in groups}
        proven = set()
        for name, _, keys in groups:
            if batches[name].result()[0] == "ok":
                proven.update(keys)
        futures = {key: pool.submit(build, opts.valk, workdir, key, src) for key, src in jobs if src and key not in proven}
        for key, src in jobs:
            if src is None:
                results[key] = ("skipped", "no argument for a parameter type")
            elif key in proven:
                results[key] = ("ok", "")
            else:
                results[key] = futures[key].result()

    lines = []
    for key in sorted(results):
        kind, message = results[key]
        lines.append("%s | %s%s" % (key, kind, (" | " + message) if message else ""))
    bugs = [l for l in lines if " | stdlib | " in l]

    if opts.update:
        with open(expected_path, "w") as fh:
            fh.write("\n".join(lines) + "\n")
    changed = [l for l in lines if l not in expected and not opts.only] if expected else []

    if opts.only:
        for l in lines:
            if " | ok" not in l:
                print(l)
    for l in bugs:
        print("STDLIB ERROR: " + l)
    for l in changed:
        if l not in bugs:
            print("CHANGED: " + l)
    counts = {}
    for kind, _ in results.values():
        counts[kind] = counts.get(kind, 0) + 1
    print("# %s" % ", ".join("%s %d" % kv for kv in sorted(counts.items())))
    if not opts.update and not opts.only:
        print("# workdir: " + workdir)
    sys.exit(1 if bugs or changed else 0)


if __name__ == "__main__":
    main()
