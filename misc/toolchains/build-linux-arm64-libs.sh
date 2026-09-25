#!/bin/bash
# Rebuilds lib/libs/linux-arm64: glibc 2.31 from Ubuntu 20.04 (as linux-x64 uses), liburing 2.1
# and OpenSSL 1.1.1t built with clang against that sysroot. Needs clang, llvm-ar and ld.lld.
set -euo pipefail

ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )/../.." &> /dev/null && pwd )
OUT="$ROOT/lib/libs/linux-arm64"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
SYSROOT="$WORK/sysroot"
PORTS="https://ports.ubuntu.com/ubuntu-ports/pool/main"
mkdir -p "$SYSROOT" "$OUT"

for deb in \
    "g/glibc/libc6_2.31-0ubuntu9.18_arm64.deb" \
    "g/glibc/libc6-dev_2.31-0ubuntu9.18_arm64.deb" \
    "g/gcc-9/libgcc-9-dev_9.4.0-1ubuntu1~20.04.2_arm64.deb" \
    "l/linux/linux-libc-dev_5.4.0-216.236_arm64.deb"; do
    curl -fsSL -o "$WORK/pkg.deb" "$PORTS/$deb"
    (cd "$WORK" && rm -rf deb && mkdir deb && cd deb && ar x ../pkg.deb && tar -xf data.tar.* -C "$SYSROOT")
done

LIBC="$SYSROOT/lib/aarch64-linux-gnu"
DEV="$SYSROOT/usr/lib/aarch64-linux-gnu"
GCC="$SYSROOT/usr/lib/gcc/aarch64-linux-gnu/9"
cp "$DEV/Scrt1.o" "$DEV/crti.o" "$DEV/crtn.o" "$DEV/libc_nonshared.a" "$OUT/"
cp "$GCC/crtbeginS.o" "$GCC/crtendS.o" "$OUT/"
cp "$LIBC/libc-2.31.so" "$OUT/libc.so"
cp "$LIBC/libm-2.31.so" "$OUT/libm.so"
cp "$LIBC/libpthread-2.31.so" "$OUT/libpthread.so"
cp "$LIBC/libdl-2.31.so" "$OUT/libdl.so"
cp "$LIBC/ld-2.31.so" "$OUT/ld-linux-aarch64.so.1"

# No outline atomics: those need libgcc's helpers, which valk does not link
CC="clang --target=aarch64-linux-gnu --sysroot=$SYSROOT -mno-outline-atomics"
LINK="-fuse-ld=lld -B$GCC -L$GCC"

curl -fsSL -o "$WORK/liburing.tar.gz" https://github.com/axboe/liburing/archive/refs/tags/liburing-2.1.tar.gz
tar -xf "$WORK/liburing.tar.gz" -C "$WORK"
(cd "$WORK/liburing-liburing-2.1" && ./configure --cc="$CC $LINK" > /dev/null \
    && make -C src liburing.a CC="$CC $LINK" AR=llvm-ar RANLIB=llvm-ranlib > /dev/null)
cp "$WORK/liburing-liburing-2.1/src/liburing.a" "$OUT/"

curl -fsSL -o "$WORK/openssl.tar.gz" https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1t/openssl-1.1.1t.tar.gz
tar -xf "$WORK/openssl.tar.gz" -C "$WORK"
(cd "$WORK/openssl-1.1.1t" && CC="$CC" AR=llvm-ar RANLIB=llvm-ranlib ./Configure linux-aarch64 no-shared no-tests > /dev/null \
    && make -j"$(nproc)" build_libs > /dev/null)
cp "$WORK/openssl-1.1.1t/libcrypto.a" "$WORK/openssl-1.1.1t/libssl.a" "$OUT/"

clang -c "$ROOT/misc/asm/coro/arm64-linux.s" --target=aarch64-linux-gnu -o "$OUT/valk-stack-swap.o"
echo "Wrote $OUT"
