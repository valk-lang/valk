#!/usr/bin/env bash

DIST_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TC_DIR="$DIST_DIR/toolchains"
LIB_DIR="$DIST_DIR/libraries"

LIN_X64="$TC_DIR/linux-amd64"
LIN_ARM64="$TC_DIR/linux-arm64"
MAC_ANY="$TC_DIR/macos-11-3"
WIN_X64="$TC_DIR/win-sdk-x64"

LLVM_LIN_X64="$LIB_DIR/linux-llvm-15-x64"
LLVM_MAC_X64="$LIB_DIR/macos-llvm-15-x64"
LLVM_MAC_ARM64="$LIB_DIR/macos-llvm-15-arm64"
LLVM_WIN_X64="$LIB_DIR/win-llvm-15-x64"

CURL_LIN_X64="$LIB_DIR/linux-curl-x64"
CURL_WIN_X64="$LIB_DIR/win-curl-x64"

mkdir -p $LIB_DIR
mkdir -p $TC_DIR

##############
# Toolchains
##############

if [ ! -d "$LIN_X64" ]; then
	echo "Download linux-x64 toolchain"
	cd $TC_DIR
	wget "https://cdn.valk-lang.dev/toolchains/linux-amd64.tar.gz"
	tar -xf "linux-amd64.tar.gz" --checkpoint=.100
	rm "linux-amd64.tar.gz"
fi

if [ ! -d "$LIN_ARM64" ]; then
	echo "Download linux-arm64 toolchain"
	cd $TC_DIR
	wget "https://cdn.valk-lang.dev/toolchains/linux-arm64.tar.bz2"
	tar -xf "linux-arm64.tar.bz2" --checkpoint=.100
	rm "linux-arm64.tar.bz2"
	mv "aarch64--glibc--stable-2022.08-1" "linux-arm64" 
fi

if [ ! -d "$MAC_ANY" ]; then
	echo "Download macos toolchain"
	cd $TC_DIR
	wget "https://cdn.valk-lang.dev/toolchains/macos-sdk-11-3.tar.xz"
	tar -xf "macos-sdk-11-3.tar.xz" --checkpoint=.100
	rm "macos-sdk-11-3.tar.xz"
	mv "MacOSX11.3.sdk" "macos-11-3" 
fi

if [ ! -d "$WIN_X64" ]; then
	echo "Download windows toolchain"
	cd $TC_DIR
	wget "https://cdn.valk-lang.dev/toolchains/win-sdk-x64.tar.gz"
	tar -xf "win-sdk-x64.tar.gz" --checkpoint=.100
	rm "win-sdk-x64.tar.gz"
fi

#########
# LLVM
#########

if [ ! -d "$LLVM_LIN_X64" ]; then
	echo "Download LLVM linux x64"
	cd $LIB_DIR
	wget "https://cdn.valk-lang.dev/toolchains/linux-llvm-15-x64.tar.gz"
	tar -xf "linux-llvm-15-x64.tar.gz" --checkpoint=.100
	rm "linux-llvm-15-x64.tar.gz"
fi

if [ ! -d "$LLVM_MAC_X64" ]; then
	echo "Download LLVM macos x64"
	cd $LIB_DIR
	wget "https://cdn.valk-lang.dev/toolchains/macos-llvm-15-x64.tar.gz"
	tar -xf "macos-llvm-15-x64.tar.gz" --checkpoint=.100
	rm "macos-llvm-15-x64.tar.gz"
fi

if [ ! -d "$LLVM_MAC_ARM64" ]; then
	echo "Download LLVM macos arm64"
	cd $LIB_DIR
	wget "https://cdn.valk-lang.dev/toolchains/macos-llvm-15-arm64.tar.gz"
	tar -xf "macos-llvm-15-arm64.tar.gz" --checkpoint=.100
	rm "macos-llvm-15-arm64.tar.gz"
fi

if [ ! -d "$LLVM_WIN_X64" ]; then
	echo "Download LLVM windows x64"
	cd $LIB_DIR
	wget "https://cdn.valk-lang.dev/toolchains/win-llvm-15-x64.tar.gz"
	tar -xf "win-llvm-15-x64.tar.gz" --checkpoint=.100
	rm "win-llvm-15-x64.tar.gz"
fi


#########
# Curl
#########

if [ ! -d "$CURL_LIN_X64" ]; then
	echo "Download Curl linux x64"
	cd $LIB_DIR
	wget "https://cdn.valk-lang.dev/toolchains/linux-curl-x64.tar.gz"
	tar -xf "linux-curl-x64.tar.gz" --checkpoint=.100
	rm "linux-curl-x64.tar.gz"
fi

if [ ! -d "$CURL_WIN_X64" ]; then
	echo "Download Curl windows x64"
	cd $LIB_DIR
	wget "https://cdn.valk-lang.dev/toolchains/win-curl-x64.tar.gz"
	tar -xf "win-curl-x64.tar.gz" --checkpoint=.100
	rm "win-curl-x64.tar.gz"
fi


##############

echo "# All toolchains & libraries are ready"
