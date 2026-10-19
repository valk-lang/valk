#!/usr/bin/env bash
# Adds lld to a vendored LLVM, so `make static` builds a compiler that links in-process:
#   misc/toolchains/add-lld.sh <llvm> toolchains/libraries/linux-llvm-22-x64
# <llvm>: an install of the same LLVM version built with lld (-DLLVM_ENABLE_PROJECTS=lld),
# holding include/ and lib/liblld*.a. The vendored LLVM must not be built with Polly linked
# in (LLVMLTO then needs Polly's libraries).
set -euo pipefail
LLVM=$(cd "$1" && pwd)
OUT=$(cd "$2" && pwd)/lib
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

cp "$LLVM/lib/liblldELF.a" "$LLVM/lib/liblldCommon.a" "$OUT/"
c++ -O2 -fPIC -std=c++17 -fno-exceptions -fno-rtti -I"$LLVM/include" \
    -c "$ROOT/src/llvm/lld/lld.cpp" -o "$OUT/valk-lld.o"
ar rcs "$OUT/libvalk-lld.a" "$OUT/valk-lld.o"
rm "$OUT/valk-lld.o"
echo "# lld added to $OUT"
