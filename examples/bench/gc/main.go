// GC microbenchmarks — Go counterpart to main.valk in this directory.
// Same scenarios and sizes so results are comparable.
//
// Scenarios:
//   1. short-lived     - allocate objects that never escape
//   2. stable-collect  - force collects while a large live graph is untouched
//   3. build-chain     - build a long-lived singly linked list
//   4. free-chain      - drop the root and reclaim the list
//   5. mutate-links    - rewrite pointers in a live list
//   6. churn+live      - short-lived allocs while holding a large live set
//   7. tree-churn      - allocate and discard binary trees
//
// Run: go run main.go

package main

import (
	"fmt"
	"runtime"
	"time"
)

type Node struct {
	next *Node
}

type Tree struct {
	left  *Tree
	right *Tree
}

// Overwrite sink: every alloc escapes; only the last stays live.
var gSink *Node

func chain(n int) *Node {
	first := &Node{}
	prev := first
	for i := 1; i < n; i++ {
		node := &Node{}
		prev.next = node
		prev = node
	}
	return first
}

func lenChain(n *Node) int {
	c := 0
	for n != nil {
		c++
		n = n.next
	}
	return c
}

func buildTree(depth int) *Tree {
	if depth <= 0 {
		return &Tree{}
	}
	return &Tree{
		left:  buildTree(depth - 1),
		right: buildTree(depth - 1),
	}
}

func (t *Tree) check() int {
	res := 1
	if t.left != nil {
		res += t.left.check()
	}
	if t.right != nil {
		res += t.right.check()
	}
	return res
}

func usSince(start time.Time) int64 {
	return time.Since(start).Microseconds()
}

func printTime(us int64) {
	fmt.Printf("time_us:  %d\n", us)
	fmt.Printf("time_ms:  %d\n", us/1000)
}

func memKB() uint64 {
	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	return m.Alloc / 1024
}

func header(name string) {
	fmt.Printf("\n=== %s ===\n", name)
}

func collectN(n int) {
	for i := 0; i < n; i++ {
		runtime.GC()
	}
}

// 1) Objects that die while only the final allocation remains rooted.
func benchShortLived() {
	header("short-lived alloc")
	const amount = 10_000_000
	root := &Node{}
	start := time.Now()
	for i := amount; i > 0; i-- {
		n := &Node{}
		gSink = n
		if i == 1 {
			root.next = n
		}
	}
	us := usSince(start)
	collectN(2)

	fmt.Printf("objects:  %d\n", amount)
	printTime(us)
	fmt.Printf("rate:     %d allocs/ms\n", amount*1000/(us+1))
	fmt.Printf("mem_kb:   %d\n", memKB())
	fmt.Printf("verify:   %d\n", lenChain(root))
}

// 2) Large stable live set; force many collections.
func benchStableCollect() {
	header("stable-heap forced collects")
	const live = 500_000
	const collects = 5_000
	list := chain(live)

	runtime.GC()

	start := time.Now()
	for c := 0; c < collects; c++ {
		runtime.GC()
	}
	us := usSince(start)

	fmt.Printf("live:     %d\n", live)
	fmt.Printf("collects: %d\n", collects)
	printTime(us)
	fmt.Printf("rate:     %d collects/s\n", collects*1_000_000/(us+1))
	fmt.Printf("mem_kb:   %d\n", memKB())
	if lenChain(list) == live {
		fmt.Printf("verify:   OK\n")
	} else {
		fmt.Printf("verify:   FAIL\n")
	}
}

var gKeep *Node

// 3) Build a long-lived chain.
func benchBuildChain() {
	header("build long-lived chain")
	const amount = 5_000_000

	start := time.Now()
	list := chain(amount)
	us := usSince(start)

	gKeep = list

	fmt.Printf("objects:  %d\n", amount)
	printTime(us)
	fmt.Printf("rate:     %d allocs/ms\n", amount*1000/(us+1))
	fmt.Printf("mem_kb:   %d\n", memKB())
	if lenChain(list) == amount {
		fmt.Printf("verify:   OK\n")
	} else {
		fmt.Printf("verify:   FAIL\n")
	}
}

// 4) Drop a large graph and reclaim.
func benchFreeChain() {
	header("free long-lived chain")
	list := gKeep
	if list == nil {
		fmt.Printf("skipped: no chain from build step\n")
		return
	}
	amount := lenChain(list)
	check := amount

	start := time.Now()
	// Drop every root — including this local — before reclaiming.
	gKeep = nil
	list = nil
	collectN(4)
	us := usSince(start)

	fmt.Printf("objects:  %d\n", amount)
	printTime(us)
	fmt.Printf("mem_kb:   %d\n", memKB())
	fmt.Printf("verify:   %d\n", check)
}

// 5) Mutate every link via list rotation.
func benchMutateLinks() {
	header("mutate live links")
	const live = 200_000
	const rounds = 50
	list := chain(live)
	runtime.GC()

	start := time.Now()
	for r := 0; r < rounds; r++ {
		head := list
		second := head.next
		if second == nil {
			break
		}
		head.next = nil
		tail := second
		for tail.next != nil {
			tail = tail.next
		}
		tail.next = head
		list = second
	}
	us := usSince(start)
	runtime.GC()

	fmt.Printf("live:     %d\n", live)
	fmt.Printf("rounds:   %d\n", rounds)
	printTime(us)
	fmt.Printf("mem_kb:   %d\n", memKB())
	if lenChain(list) == live {
		fmt.Printf("verify:   OK\n")
	} else {
		fmt.Printf("verify:   FAIL\n")
	}
}

// 6) Short-lived churn while a large live set is rooted.
func benchChurnWithLive() {
	header("short-lived churn with large live set")
	const live = 500_000
	const churn = 5_000_000
	list := chain(live)
	runtime.GC()

	start := time.Now()
	for i := churn; i > 0; i-- {
		n := &Node{}
		gSink = n
	}
	runtime.GC()
	us := usSince(start)

	fmt.Printf("live:     %d\n", live)
	fmt.Printf("churn:    %d\n", churn)
	printTime(us)
	fmt.Printf("rate:     %d allocs/ms\n", churn*1000/(us+1))
	fmt.Printf("mem_kb:   %d\n", memKB())
	if lenChain(list) == live {
		fmt.Printf("verify:   OK\n")
	} else {
		fmt.Printf("verify:   FAIL\n")
	}
}

// 7) Build and discard trees.
func benchTreeChurn() {
	header("tree churn")
	const depth = 14
	const trees = 400
	nodesPer := (1 << (depth + 1)) - 1

	start := time.Now()
	check := 0
	for i := 0; i < trees; i++ {
		check += buildTree(depth).check()
	}
	runtime.GC()
	us := usSince(start)

	fmt.Printf("depth:    %d\n", depth)
	fmt.Printf("trees:    %d\n", trees)
	fmt.Printf("nodes:    ~%d\n", trees*nodesPer)
	printTime(us)
	fmt.Printf("mem_kb:   %d\n", memKB())
	fmt.Printf("verify:   %d\n", check)
}

func main() {
	fmt.Println("Go GC bench suite")
	fmt.Printf("mem_kb before: %d\n", memKB())

	benchShortLived()
	benchStableCollect()
	benchBuildChain()
	benchFreeChain()
	benchMutateLinks()
	benchChurnWithLive()
	benchTreeChurn()

	fmt.Printf("\n=== done ===\n")
	fmt.Printf("mem_kb after: %d\n", memKB())
}
