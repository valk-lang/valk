package main

import (
	"fmt"
	"os"
	"strconv"
	"sync"
)

type Entry struct {
	Key  uint64
	Name string
	Data []uint64
}

func entry(key uint64) *Entry {
	data := make([]uint64, 0, 16)
	for i := uint64(0); i < 16; i++ {
		data = append(data, key*31+i)
	}
	return &Entry{Key: key, Name: "entry" + strconv.FormatUint(key, 10), Data: data}
}

type Cache struct {
	mutex sync.Mutex
	items map[uint64]*Entry
}

func work(cache *Cache, slots uint64, seed uint64, operations uint64) uint64 {
	total := uint64(0)
	r := seed
	for i := uint64(0); i < operations; i++ {
		r = (r*1103515245 + 12345) % 2147483648
		key := r % slots
		if r%10 == 0 {
			fresh := entry(key)
			cache.mutex.Lock()
			cache.items[key] = fresh
			cache.mutex.Unlock()
		} else {
			cache.mutex.Lock()
			found := cache.items[key]
			cache.mutex.Unlock()
			if found != nil {
				total += found.Key + uint64(len(found.Name))
				for _, value := range found.Data {
					total += value
				}
			}
		}
	}
	return total
}

func main() {
	slots := uint64(100000)
	operations := uint64(2000000)
	if len(os.Args) > 1 {
		slots, _ = strconv.ParseUint(os.Args[1], 10, 64)
	}
	if len(os.Args) > 2 {
		operations, _ = strconv.ParseUint(os.Args[2], 10, 64)
	}

	cache := &Cache{items: make(map[uint64]*Entry, slots)}
	for i := uint64(0); i < slots; i++ {
		cache.items[i] = entry(i)
	}

	results := make([]uint64, 4)
	var wg sync.WaitGroup
	for t := uint64(0); t < 4; t++ {
		wg.Add(1)
		go func(t uint64) {
			defer wg.Done()
			results[t] = work(cache, slots, t+1, operations)
		}(t)
	}
	wg.Wait()
	total := uint64(0)
	for _, result := range results {
		total += result
	}
	fmt.Printf("slots: %d, operations: %d, checksum: %d\n", slots, operations*4, total)
}
