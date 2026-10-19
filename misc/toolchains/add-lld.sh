#!/usr/bin/env bash
# Adds lld to a vendored LLVM, so the compiler built against it links in-process:
#   misc/toolchains/add-lld.sh <llvm> toolchains/libraries/linux-llvm-22-x64
#   misc/toolchains/add-lld.sh <llvm> toolchains/libraries/win-llvm-22-x64
#   misc/toolchains/add-lld.sh <llvm> toolchains/libraries/macos-llvm-22-arm64
# <llvm>: an install of the same LLVM version for that target, built with lld
# (-DLLVM_ENABLE_PROJECTS=lld) and without Polly. Its LLVM and lld libraries replace the
# vendored ones, so all of them come from one build.
set -euo pipefail
LLVM=$(cd "$1" && pwd)
OUT=$(cd "$2" && pwd)/lib
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
SHIM="$ROOT/src/llvm/lld/lld.cpp"

if [[ "$(basename "$(dirname "$OUT")")" == win-* ]]; then
    SDK="$ROOT/toolchains/toolchains/win-sdk-x64"
    INC="$SDK/Include/10.0.22621.0"
    cp "$LLVM"/lib/LLVM*.lib "$LLVM"/lib/lld*.lib "$OUT/"
    clang-cl --target=x86_64-pc-windows-msvc /O2 /MT /std:c++17 /GR- /EHs-c- \
        -imsvc"$ROOT/misc/toolchains/include/windows" -imsvc"$SDK/MSVC/14.36.32532/include" \
        -imsvc"$INC/ucrt" -imsvc"$INC/shared" -imsvc"$INC/um" -imsvc"$INC/winrt" \
        -I"$LLVM/include" -c "$SHIM" -Fo"$OUT/valk-lld.obj"
    llvm-lib /out:"$OUT/valk-lld.lib" "$OUT/valk-lld.obj"
    rm "$OUT/valk-lld.obj"
elif [[ "$(basename "$(dirname "$OUT")")" == macos-* ]]; then
    ARCH=x86_64
    [[ "$OUT" == *arm64* ]] && ARCH=arm64
    cp "$LLVM"/lib/libLLVM*.a "$LLVM"/lib/liblld*.a "$OUT/"
    clang++ --target=$ARCH-apple-macos11 -isysroot "$ROOT/toolchains/toolchains/macos-11-3" -stdlib=libc++ \
        -O2 -std=c++17 -fno-exceptions -fno-rtti -I"$LLVM/include" -c "$SHIM" -o "$OUT/valk-lld.o"
    llvm-ar rcs "$OUT/libvalk-lld.a" "$OUT/valk-lld.o"
    rm "$OUT/valk-lld.o"
else
    # Compiled against the release sysroot (setup-linux-*.sh), like the LLVM libraries
    ARCH=x86_64; SYSROOT=linux-amd64
    [[ "$OUT" == *arm64* ]] && ARCH=aarch64 && SYSROOT=linux-arm64
    cp "$LLVM"/lib/libLLVM*.a "$LLVM"/lib/liblld*.a "$OUT/"
    clang++ --target=$ARCH-linux-gnu --sysroot="$ROOT/toolchains/toolchains/$SYSROOT" \
        -O2 -fPIC -std=c++17 -fno-exceptions -fno-rtti -I"$LLVM/include" -c "$SHIM" -o "$OUT/valk-lld.o"
    llvm-ar rcs "$OUT/libvalk-lld.a" "$OUT/valk-lld.o"
    rm "$OUT/valk-lld.o"
fi
echo "# lld added to $OUT"
