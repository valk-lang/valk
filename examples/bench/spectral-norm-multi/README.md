# Multithreaded spectral norm

Safe, standard-library implementations of the spectral-norm benchmark in
Valk, Go, and Rust. Each matrix-vector multiplication divides its output into
independent chunks and computes those chunks on worker threads.

The first argument is the matrix size and the second is the worker count. They
default to the benchmark site's `8000` elements and four workers:

```sh
./main 8000 4
```

All implementations print the spectral norm with nine decimal places. They do
not use explicit SIMD, unsafe pointer sharing, or third-party thread pools.
