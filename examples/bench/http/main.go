// Go: fasthttp hello-world server, port 9002
//
//   go mod init bench && go get github.com/valyala/fasthttp && go build -o fasthttp-srv .
//
// GOMAXPROCS controls the number of worker threads (defaults to the core count).
package main

import "github.com/valyala/fasthttp"

func handler(ctx *fasthttp.RequestCtx) {
	ctx.SetContentType("text/plain")
	ctx.SetBodyString("Hello, World!")
}

func main() {
	s := &fasthttp.Server{Handler: handler}
	if err := s.ListenAndServe("127.0.0.1:9002"); err != nil {
		panic(err)
	}
}
