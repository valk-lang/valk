package main

import (
	"fmt"
	"os"
	"strconv"
	"sync"
)

func words(count uint64) []string {
	result := make([]string, 0, count)
	for i := uint64(0); i < count; i++ {
		result = append(result, "word"+strconv.FormatUint(i, 10))
	}
	return result
}

type Counts struct {
	mutex sync.Mutex
	items map[string]uint64
}

func work(counts *Counts, keys []string, seed uint64, updates uint64) {
	r := seed
	for i := uint64(0); i < updates; i++ {
		r = (r*1103515245 + 12345) % 2147483648
		key := keys[r%uint64(len(keys))]
		counts.mutex.Lock()
		counts.items[key]++
		counts.mutex.Unlock()
	}
}

func main() {
	count := uint64(10000)
	updates := uint64(2000000)
	if len(os.Args) > 1 {
		count, _ = strconv.ParseUint(os.Args[1], 10, 64)
	}
	if len(os.Args) > 2 {
		updates, _ = strconv.ParseUint(os.Args[2], 10, 64)
	}

	keys := words(count)
	counts := &Counts{items: make(map[string]uint64, count)}

	var wg sync.WaitGroup
	for t := uint64(0); t < 4; t++ {
		wg.Add(1)
		go func(seed uint64) {
			defer wg.Done()
			work(counts, keys, seed, updates)
		}(t + 1)
	}
	wg.Wait()

	total := uint64(0)
	most := uint64(0)
	counts.mutex.Lock()
	for _, value := range counts.items {
		total += value
		if value > most {
			most = value
		}
	}
	counts.mutex.Unlock()
	fmt.Printf("keys: %d, updates: %d, most: %d\n", count, total, most)
}
