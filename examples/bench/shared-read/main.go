package main

import (
	"fmt"
	"os"
	"strconv"
	"sync"
)

type User struct {
	ID    uint64
	Name  string
	Tags  []string
	Score uint64
}

type Hit struct {
	ID    uint64
	Score uint64
}

func build(count uint64) map[string]*User {
	users := make(map[string]*User, count)
	for i := uint64(0); i < count; i++ {
		name := "user" + strconv.FormatUint(i, 10)
		users[name] = &User{
			ID:    i,
			Name:  name,
			Tags:  []string{"tag" + strconv.FormatUint(i%7, 10), "tag" + strconv.FormatUint(i%13, 10)},
			Score: i * 7 % 1000,
		}
	}
	return users
}

func names(count uint64) []string {
	result := make([]string, 0, count)
	for i := uint64(0); i < count; i++ {
		result = append(result, "user"+strconv.FormatUint(i, 10))
	}
	return result
}

func work(users map[string]*User, keys []string, seed uint64, lookups uint64) uint64 {
	total := uint64(0)
	hits := make([]*Hit, 0, 1000)
	r := seed
	for i := uint64(0); i < lookups; i++ {
		r = (r*1103515245 + 12345) % 2147483648
		user := users[keys[r%uint64(len(keys))]]
		total += user.Score + uint64(len(user.Name)) + uint64(len(user.Tags))
		hits = append(hits, &Hit{ID: user.ID, Score: user.Score})
		if len(hits) == 1000 {
			hits = hits[:0]
		}
	}
	return total
}

func main() {
	count := uint64(200000)
	lookups := uint64(5000000)
	if len(os.Args) > 1 {
		count, _ = strconv.ParseUint(os.Args[1], 10, 64)
	}
	if len(os.Args) > 2 {
		lookups, _ = strconv.ParseUint(os.Args[2], 10, 64)
	}

	users := build(count)
	keys := names(count)

	results := make([]uint64, 4)
	var wg sync.WaitGroup
	for t := 0; t < 4; t++ {
		wg.Add(1)
		go func(t int) {
			defer wg.Done()
			results[t] = work(users, keys, uint64(t+1), lookups)
		}(t)
	}
	wg.Wait()
	total := uint64(0)
	for _, result := range results {
		total += result
	}
	fmt.Printf("users: %d, lookups: %d, checksum: %d\n", count, lookups*4, total)
}
