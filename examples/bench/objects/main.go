
package main

import (
	"fmt"
    "time"
    "runtime"
    "runtime/debug"
)

type Node struct {
	next  *Node
}

func gen(amount int) *Node {
    prev := &Node{}
    first := prev
    for i := 0; i < amount; i++ {
		n := &Node{}
		prev.next = n
		prev = n
    }
	return first
}

func verify(n *Node) int {
    if n.next == nil {
        return 1
    }
    return verify(n.next) + 1
}

func create_objects() {
    first := gen(0)
    start := time.Now()
    for i := amount; i > 0; i-- {
        n := gen(0)
        first = n
    }
    elapsed := time.Since(start)

	fmt.Printf("Created %d objects in %d ms\n", amount, int(elapsed / time.Millisecond))
	fmt.Printf("Verify: %d\n", verify(first))
}

var amount int = 10000000
var keep *Node
var m runtime.MemStats

func longlived_objects() {
    first := gen(0)
    last := first
    start := time.Now()
    for i := amount; i > 0; i-- {
        n := gen(0)
        last.next = n
        last = n
    }
    elapsed := time.Since(start)
    keep = first

	fmt.Printf("Created %d long lived objects in %d ms\n", amount, int(elapsed / time.Millisecond))
	fmt.Printf("Verify: %d\n", verify(first))
}

func free_objects() {
    check := verify(keep)
    //
    start := time.Now()
    keep = nil
    runtime.GC()
    debug.FreeOSMemory()
    elapsed := time.Since(start)
    //

	fmt.Printf("Free %d long lived objects in %d ms\n", amount, int(elapsed / time.Millisecond))
	fmt.Printf("Verify: %d\n", check)
}

func log_mem_usage() {
    runtime.GC()
    debug.FreeOSMemory()
	runtime.ReadMemStats(&m)
	fmt.Printf("Sys mem usage = %v KB\n", m.Sys / 1024)
	fmt.Printf("Alloc mem usage = %v KB\n", m.Alloc / 1024)
}

func main() {
	fmt.Printf("\n")
    create_objects()
    log_mem_usage()
	fmt.Printf("\n")
    longlived_objects()
    log_mem_usage()
	fmt.Printf("\n")
    free_objects()
    log_mem_usage()
	fmt.Printf("\n")
}
