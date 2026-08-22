
package main

import "github.com/go-www/silverlining"

func main() {
	silverlining.ListenAndServe(":3000", func(r *silverlining.Context) {
		r.WriteFullBodyString(200, "Hello, World!")
	})
}
