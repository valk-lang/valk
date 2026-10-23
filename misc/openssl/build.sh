#!/usr/bin/env bash
# Builds the static OpenSSL libraries valk links for one target, from Linux with clang.
#
#   misc/openssl/build.sh <target> <out-dir>     target: linux-x64 linux-arm64 macos-x64 macos-arm64 win-x64
#
# Every target is built from the same tarball with the same options, so all platforms carry the
# same OpenSSL. Cross targets use the sysroots that `make toolchains` installs under ./toolchains.
# Windows is compiled by clang for the MSVC ABI through OpenSSL's gcc-style `mingw64` configuration,
# which lets a plain Makefile drive it (the VC-* configurations need nmake); the result is a COFF
# archive that lld-link reads like a .lib.
set -euo pipefail

VERSION="${OPENSSL_VERSION:-3.5.9}"
SHA256="${OPENSSL_SHA256:-603f5602e2eef00d77fbd429d34dcd5822bb301757a1bc9cdb24c670f1eb859a}"
CLANG="${CLANG:-clang}"
JOBS="${JOBS:-$(nproc)}"

target="${1:?target}"
out="$(mkdir -p "${2:?out-dir}" && cd "$2" && pwd)"
repo="$(cd "$(dirname "$0")/../.." && pwd)"
work="${OPENSSL_WORK:-$repo/debug/openssl}"
mkdir -p "$work"

tarball="$work/openssl-$VERSION.tar.gz"
if [ ! -f "$tarball" ]; then
    curl -sfL -o "$tarball" "https://github.com/openssl/openssl/releases/download/openssl-$VERSION/openssl-$VERSION.tar.gz"
fi
echo "$SHA256  $tarball" | sha256sum -c - >/dev/null

src="$work/$target"
rm -rf "$src"
mkdir -p "$src"
tar xzf "$tarball" -C "$src" --strip-components=1

tc="$repo/toolchains/toolchains"
case "$target" in
    linux-x64)
        config=linux-x86_64
        cc="$CLANG --target=x86_64-linux-gnu --sysroot=$tc/linux-amd64"
        extra="-fPIC" ;;
    linux-arm64)
        config=linux-aarch64
        cc="$CLANG --target=aarch64-linux-gnu --sysroot=$tc/linux-arm64"
        # Inline atomics: the out-of-line helpers live in libgcc, which valk does not link
        extra="-fPIC -mno-outline-atomics" ;;
    macos-x64)
        config=darwin64-x86_64
        cc="$CLANG --target=x86_64-apple-macos11 -isysroot $tc/macos-11-3"
        extra="" ;;
    macos-arm64)
        config=darwin64-arm64
        cc="$CLANG --target=arm64-apple-macos11 -isysroot $tc/macos-11-3"
        extra="" ;;
    win-x64)
        config=mingw64
        msvc="$tc/win-sdk-x64/MSVC/14.36.32532"
        sdk="$tc/win-sdk-x64/Include/10.0.22621.0"
        cc="$CLANG --target=x86_64-pc-windows-msvc -fms-extensions -isystem $msvc/include -isystem $sdk/ucrt -isystem $sdk/um -isystem $sdk/shared"
        extra="-D_CRT_SECURE_NO_WARNINGS" ;;
    *) echo "unknown target: $target" >&2; exit 1 ;;
esac

cd "$src"
# Same options on every platform: static libraries only, no loadable modules, no legacy algorithms
perl ./Configure "$config" no-shared no-module no-legacy no-tests no-apps no-docs \
    $extra CC="$cc" AR=llvm-ar RANLIB=llvm-ranlib >/dev/null
make -j"$JOBS" build_libs >/dev/null

if [ "$target" = "win-x64" ]; then
    cp libcrypto.a "$out/libcrypto.lib"
    cp libssl.a "$out/libssl.lib"
else
    cp libcrypto.a libssl.a "$out/"
fi
ls -la "$out"
