import core.memory : GC;
import std.datetime.stopwatch : MonoTime;
import std.stdio : writeln;

class Node {
    Node next;
}

class Tree {
    Tree left;
    Tree right;

    static Tree build(int depth) {
        if (depth <= 0) return new Tree();
        auto tree = new Tree();
        tree.left = build(depth - 1);
        tree.right = build(depth - 1);
        return tree;
    }

    ulong check() {
        ulong result = 1;
        if (left !is null) result += left.check();
        if (right !is null) result += right.check();
        return result;
    }
}

Node sink;
Node keep;

Node heapNode() {
    auto node = new Node();
    sink = node;
    return node;
}

Node chain(size_t count) {
    auto first = new Node();
    auto previous = first;
    for (size_t i = 1; i < count; i++) {
        auto node = new Node();
        previous.next = node;
        previous = node;
    }
    return first;
}

size_t chainLength(Node node) {
    size_t count;
    while (node !is null) {
        count++;
        node = node.next;
    }
    return count;
}

long microsecondsSince(MonoTime start) {
    return (MonoTime.currTime - start).total!"usecs";
}

void printTime(long microseconds) {
    writeln("time_us:  ", microseconds);
    writeln("time_ms:  ", microseconds / 1000);
}

size_t memoryKB() {
    return GC.stats.usedSize / 1024;
}

void header(string name) {
    writeln();
    writeln("=== ", name, " ===");
}

void fullGC() {
    GC.collect();
    GC.minimize();
}

void collectN(size_t count) {
    for (size_t i = 0; i < count; i++) GC.collect();
    GC.minimize();
}

void benchShortLived() {
    header("short-lived alloc");
    enum amount = 10_000_000;
    auto root = new Node();

    auto start = MonoTime.currTime;
    for (int i = amount; i > 0; i--) {
        auto node = heapNode();
        if (i == 1) root.next = node;
    }
    auto us = microsecondsSince(start);
    collectN(2);

    writeln("objects:  ", amount);
    printTime(us);
    writeln("rate:     ", cast(long) amount * 1000 / (us + 1), " allocs/ms");
    writeln("mem_kb:   ", memoryKB());
    writeln("verify:   ", chainLength(root));
}

void benchStableCollect() {
    header("stable-heap forced collects");
    enum live = 500_000;
    enum collects = 5_000;
    auto list = chain(live);
    fullGC();

    auto start = MonoTime.currTime;
    for (int i = 0; i < collects; i++) {
        heapNode();
        GC.collect();
    }
    auto us = microsecondsSince(start);

    writeln("live:     ", live);
    writeln("collects: ", collects);
    printTime(us);
    writeln("rate:     ", cast(long) collects * 1_000_000 / (us + 1), " collects/s");
    writeln("mem_kb:   ", memoryKB());
    writeln("verify:   ", chainLength(list) == live ? "OK" : "FAIL");
}

void benchBuildChain() {
    header("build long-lived chain");
    enum amount = 5_000_000;

    auto start = MonoTime.currTime;
    auto list = chain(amount);
    auto us = microsecondsSince(start);
    keep = list;

    writeln("objects:  ", amount);
    printTime(us);
    writeln("rate:     ", cast(long) amount * 1000 / (us + 1), " allocs/ms");
    writeln("mem_kb:   ", memoryKB());
    writeln("verify:   ", chainLength(list) == amount ? "OK" : "FAIL");
}

void benchFreeChain() {
    header("free long-lived chain");
    auto list = keep;
    if (list is null) {
        writeln("skipped: no chain from build step");
        return;
    }
    auto amount = chainLength(list);
    auto verification = amount;

    auto start = MonoTime.currTime;
    keep = null;
    list = null;
    collectN(4);
    auto us = microsecondsSince(start);

    writeln("objects:  ", amount);
    printTime(us);
    writeln("mem_kb:   ", memoryKB());
    writeln("verify:   ", verification);
}

void benchMutateLinks() {
    header("mutate live links");
    enum live = 200_000;
    enum rounds = 50;
    auto list = chain(live);
    fullGC();

    auto start = MonoTime.currTime;
    for (int round = 0; round < rounds; round++) {
        auto head = list;
        auto second = head.next;
        if (second is null) break;
        head.next = null;
        auto tail = second;
        while (tail.next !is null) tail = tail.next;
        tail.next = head;
        list = second;
    }
    auto us = microsecondsSince(start);
    fullGC();

    writeln("live:     ", live);
    writeln("rounds:   ", rounds);
    printTime(us);
    writeln("mem_kb:   ", memoryKB());
    writeln("verify:   ", chainLength(list) == live ? "OK" : "FAIL");
}

void benchChurnWithLive() {
    header("short-lived churn with large live set");
    enum live = 500_000;
    enum churn = 5_000_000;
    auto list = chain(live);
    fullGC();

    auto start = MonoTime.currTime;
    for (int i = churn; i > 0; i--) heapNode();
    GC.collect();
    auto us = microsecondsSince(start);

    writeln("live:     ", live);
    writeln("churn:    ", churn);
    printTime(us);
    writeln("rate:     ", cast(long) churn * 1000 / (us + 1), " allocs/ms");
    writeln("mem_kb:   ", memoryKB());
    writeln("verify:   ", chainLength(list) == live ? "OK" : "FAIL");
}

void benchTreeChurn() {
    header("tree churn");
    enum depth = 14;
    enum trees = 400;
    enum nodesPerTree = (1 << (depth + 1)) - 1;

    auto start = MonoTime.currTime;
    ulong verification;
    for (int i = 0; i < trees; i++) verification += Tree.build(depth).check();
    GC.collect();
    auto us = microsecondsSince(start);

    writeln("depth:    ", depth);
    writeln("trees:    ", trees);
    writeln("nodes:    ~", trees * nodesPerTree);
    printTime(us);
    writeln("mem_kb:   ", memoryKB());
    writeln("verify:   ", verification);
}

void main() {
    writeln("D GC bench suite");
    writeln("mem_kb before: ", memoryKB());

    benchShortLived();
    benchStableCollect();
    benchBuildChain();
    benchFreeChain();
    benchMutateLinks();
    benchChurnWithLive();
    benchTreeChurn();

    writeln();
    writeln("=== done ===");
    writeln("mem_kb after: ", memoryKB());
}
