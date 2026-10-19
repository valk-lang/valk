
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DIST_DIR=$( cd -- "$SCRIPT_DIR/../.." &> /dev/null && pwd )/toolchains
TC_DIR="$DIST_DIR/toolchains"
LIB_DIR="$DIST_DIR/libraries"

mkdir -p $TC_DIR
mkdir -p $LIB_DIR

LIN_X64="$TC_DIR/linux-amd64"
LLVM_LIN_X64="$LIB_DIR/linux-llvm-22-x64"
CURL_LIN_X64="$LIB_DIR/linux-curl-x64"

# Older downloads have no headers (needed to build LLVM against it)
if [ ! -f "$LIN_X64/usr/include/stdio.h" ]; then
	echo "Download linux-x64 toolchain"
	rm -rf "$LIN_X64"
	cd $TC_DIR
	wget "https://files.valk-cdn.dev/toolchains/linux-amd64.tar.gz"
	tar -xf "linux-amd64.tar.gz" --checkpoint=.100
	rm "linux-amd64.tar.gz"
fi

# Older downloads have no lld
if [ ! -f "$LLVM_LIN_X64/lib/libvalk-lld.a" ]; then
	echo "Download LLVM linux x64"
	rm -rf "$LLVM_LIN_X64"
	cd $LIB_DIR
	wget "https://files.valk-cdn.dev/toolchains/linux-llvm-22-x64.tar.gz"
	tar -xf "linux-llvm-22-x64.tar.gz" --checkpoint=.100
	rm "linux-llvm-22-x64.tar.gz"
fi

if [ ! -d "$CURL_LIN_X64" ]; then
	echo "Download Curl linux x64"
	cd $LIB_DIR
	wget "https://files.valk-cdn.dev/toolchains/linux-curl-x64.tar.gz"
	tar -xf "linux-curl-x64.tar.gz" --checkpoint=.100
	rm "linux-curl-x64.tar.gz"
fi
