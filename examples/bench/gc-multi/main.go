// Stronger GC comparison suite (Go).
// Same scenarios and sizes as main.valk.
//
// Heap allocations are forced via a global sink overwrite so escape analysis
// cannot stack-allocate or DCE the objects (Valk class `{}` always pool-allocs).
//
// Run: go run main.go

package main

import (
	"fmt"
	"runtime"
	"sync"
	"sync/atomic"
	"time"
)

type Node struct {
	next    *Node
	payload uint64
}

type Tree struct {
	left  *Tree
	right *Tree
	tag   uint64
}

// Overwritten every alloc so only one short-lived object stays live, but every
// allocation must hit the heap (escape analysis cannot stack-allocate).
var sink atomic.Pointer[Node]
var sinkTree atomic.Pointer[Tree]
var sinkAny atomic.Value

//go:noinline
func heapNode(p uint64) *Node {
	n := &Node{payload: p}
	sink.Store(n)
	return n
}

//go:noinline
func heapNodePair(p uint64) *Node {
	a := &Node{payload: p}
	b := &Node{payload: p + 1}
	a.next = b
	sink.Store(a)
	return a
}

func buildTree(depth int) *Tree {
	if depth <= 0 {
		t := &Tree{}
		return t
	}
	return &Tree{
		left:  buildTree(depth - 1),
		right: buildTree(depth - 1),
	}
}

func chain(n int) *Node {
	first := &Node{}
	prev := first
	for i := 1; i < n; i++ {
		node := &Node{payload: uint64(i)}
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

func usSince(start time.Time) int64 {
	return time.Since(start).Microseconds()
}

func printTime(us int64) {
	fmt.Printf("time_us:  %d\n", us)
	fmt.Printf("time_ms:  %d\n", us/1000)
}

func header(name string) {
	fmt.Printf("\n=== %s ===\n", name)
}

func memKB() uint64 {
	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	return m.Alloc / 1024
}

func sysKB() uint64 {
	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	return m.Sys / 1024
}

func heapInuseKB() uint64 {
	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	return m.HeapInuse / 1024
}

func printGCStats() {
	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	fmt.Printf("num_gc:   %d\n", m.NumGC)
	fmt.Printf("pause_total_ms: %d\n", m.PauseTotalNs/1_000_000)
	var max uint64
	n := m.NumGC
	if n > 256 {
		n = 256
	}
	for i := uint32(0); i < n; i++ {
		if m.PauseNs[(m.NumGC-1-i)%256] > max {
			max = m.PauseNs[(m.NumGC-1-i)%256]
		}
	}
	fmt.Printf("max_pause_us: %d\n", max/1000)
	fmt.Printf("gc_cpu_frac: %.4f\n", m.GCCPUFraction)
	fmt.Printf("total_alloc_mb: %d\n", m.TotalAlloc/1024/1024)
}

// ---------- 1) Multi-thread local ----------

func benchMTLocal() {
	header("mt-local churn (no share)")
	const threads = 4
	const per = 2_000_000

	start := time.Now()
	var wg sync.WaitGroup
	wg.Add(threads)
	for t := 0; t < threads; t++ {
		go func() {
			defer wg.Done()
			for i := per; i > 0; i-- {
				heapNode(uint64(i))
			}
		}()
	}
	wg.Wait()
	us := usSince(start)

	fmt.Printf("threads:  %d\n", threads)
	fmt.Printf("per_thr:  %d\n", per)
	fmt.Printf("total:    %d\n", threads*per)
	printTime(us)
	fmt.Printf("rate:     %d allocs/ms\n", int64(threads*per)*1000/(us+1))
	fmt.Printf("mem_kb:   %d\n", memKB())
	fmt.Printf("sys_kb:   %d\n", sysKB())
	printGCStats()
}

// ---------- 2) Multi-thread shared ----------

var (
	sharedRoot atomic.Pointer[Tree]
	sharedMu   sync.Mutex
)

func benchMTShared() {
	header("mt-shared publish/replace")
	const threads = 4
	const iters = 80
	const depth = 10
	nodesPer := (1 << (depth + 1)) - 1

	sharedRoot.Store(nil)
	runtime.GC()

	start := time.Now()
	var wg sync.WaitGroup
	wg.Add(threads)
	for t := 0; t < threads; t++ {
		go func() {
			defer wg.Done()
			for i := 0; i < iters; i++ {
				tr := buildTree(depth)
				sharedMu.Lock()
				sharedRoot.Store(tr)
				sharedMu.Unlock()
			}
		}()
	}
	wg.Wait()
	sharedMu.Lock()
	sharedRoot.Store(nil)
	sharedMu.Unlock()
	runtime.GC()
	runtime.GC()
	us := usSince(start)

	fmt.Printf("threads:  %d\n", threads)
	fmt.Printf("iters:    %d / thread\n", iters)
	fmt.Printf("depth:    %d (~%d nodes/tree)\n", depth, nodesPer)
	fmt.Printf("publishes:%d\n", threads*iters)
	printTime(us)
	fmt.Printf("mem_kb:   %d\n", memKB())
	fmt.Printf("sys_kb:   %d\n", sysKB())
	printGCStats()
}

// ---------- 3) Natural pacing ----------

func benchNatural() {
	header("natural pacing (no forced GC)")
	const amount = 8_000_000
	const keepEvery = 64
	keep := make([]*Node, 0, amount/keepEvery+8)

	start := time.Now()
	for i := 0; i < amount; i++ {
		n := heapNode(uint64(i))
		if i%keepEvery == 0 {
			keep = append(keep, n)
		}
	}
	us := usSince(start)
	kept := len(keep)
	// Prevent DCE of keep before timing end (already ended).
	sinkAny.Store(kept)
	keep = nil

	fmt.Printf("allocs:   %d\n", amount)
	fmt.Printf("retained: %d (1/%d)\n", kept, keepEvery)
	printTime(us)
	fmt.Printf("rate:     %d allocs/ms\n", amount*1000/(us+1))
	fmt.Printf("mem_kb:   %d\n", memKB())
	fmt.Printf("sys_kb:   %d\n", sysKB())
	printGCStats()
}

// ---------- 4) Fragmentation ----------

func benchFragment() {
	header("fragmentation / mixed retention")
	const rounds = 40
	const batch = 50_000

	start := time.Now()
	checksum := 0
	for r := 0; r < rounds; r++ {
		keep := make([]*Node, 0, batch/2+8)
		for i := 0; i < batch; i++ {
			if (r+i)%2 == 0 {
				n := heapNode(uint64(i))
				if i%2 == 0 {
					keep = append(keep, n)
				}
			} else {
				a := heapNodePair(uint64(i))
				if i%3 == 0 {
					keep = append(keep, a)
				}
			}
		}
		checksum += len(keep)
		keep = nil
	}
	us := usSince(start)
	sinkAny.Store(checksum)

	fmt.Printf("rounds:   %d\n", rounds)
	fmt.Printf("batch:    %d\n", batch)
	fmt.Printf("checksum: %d\n", checksum)
	printTime(us)
	fmt.Printf("mem_kb:   %d\n", memKB())
	fmt.Printf("sys_kb:   %d\n", sysKB())
	printGCStats()
}

// ---------- 5) Pause proxy ----------

func benchPauseProxy() {
	header("pause proxy (max batch latency)")
	const total = 6_000_000
	const batch = 50_000
	live := chain(300_000)

	var maxUs, sumUs int64
	batches := 0

	startAll := time.Now()
	for done := 0; done < total; done += batch {
		start := time.Now()
		for i := 0; i < batch; i++ {
			heapNode(uint64(i))
		}
		us := usSince(start)
		if us > maxUs {
			maxUs = us
		}
		sumUs += us
		batches++
	}
	wall := usSince(startAll)
	avg := sumUs / int64(batches+1)

	fmt.Printf("live:     300000\n")
	fmt.Printf("allocs:   %d\n", total)
	fmt.Printf("batch:    %d\n", batch)
	fmt.Printf("batches:  %d\n", batches)
	printTime(wall)
	fmt.Printf("max_batch_us: %d\n", maxUs)
	fmt.Printf("avg_batch_us: %d\n", avg)
	fmt.Printf("mem_kb:   %d\n", memKB())
	fmt.Printf("sys_kb:   %d\n", sysKB())
	printGCStats()
	fmt.Printf("verify:   %d\n", lenChain(live))
}

// ---------- 6) Live + natural churn ----------

func benchLiveNatural() {
	header("large live set + natural churn")
	const liveN = 1_000_000
	const churn = 8_000_000
	live := chain(liveN)

	start := time.Now()
	for i := churn; i > 0; i-- {
		heapNode(uint64(i))
	}
	us := usSince(start)

	fmt.Printf("live:     %d\n", liveN)
	fmt.Printf("churn:    %d\n", churn)
	printTime(us)
	fmt.Printf("rate:     %d allocs/ms\n", churn*1000/(us+1))
	fmt.Printf("mem_kb:   %d\n", memKB())
	fmt.Printf("heap_inuse_kb: %d\n", heapInuseKB())
	fmt.Printf("sys_kb:   %d\n", sysKB())
	printGCStats()
	fmt.Printf("verify:   %d\n", lenChain(live))
}

func main() {
	fmt.Println("Go GC hard suite")
	fmt.Printf("GOMAXPROCS: %d\n", runtime.GOMAXPROCS(0))
	fmt.Printf("mem_kb:  %d\n", memKB())
	fmt.Printf("sys_kb:  %d\n", sysKB())

	benchMTLocal()
	benchMTShared()
	benchNatural()
	benchFragment()
	benchPauseProxy()
	benchLiveNatural()

	// Keep sinks live for the process lifetime reporting.
	_ = sink.Load()
	_ = sinkTree.Load()
	_ = sinkAny.Load()

	fmt.Printf("\n=== done ===\n")
	fmt.Printf("mem_kb:  %d\n", memKB())
	fmt.Printf("sys_kb:  %d\n", sysKB())
}
