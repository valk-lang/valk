SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DIST_DIR=$( cd -- "$SCRIPT_DIR/../.." &> /dev/null && pwd )/toolchains
TC_DIR="$DIST_DIR/toolchains"
LIB_DIR="$DIST_DIR/libraries"

mkdir -p $TC_DIR
mkdir -p $LIB_DIR

LIN_ARM64="$TC_DIR/linux-arm64"
LLVM_LIN_ARM64="$LIB_DIR/linux-llvm-22-arm64"

if [ ! -d "$LIN_ARM64" ]; then
	echo "Download linux-arm64 toolchain"
	cd $TC_DIR
	wget "https://files.valk-cdn.dev/toolchains/linux-arm64.tar.gz"
	tar -xf "linux-arm64.tar.gz" --checkpoint=.100
	rm "linux-arm64.tar.gz"
fi

if [ ! -d "$LLVM_LIN_ARM64" ]; then
	echo "Download LLVM linux arm64"
	cd $LIB_DIR
	wget "https://files.valk-cdn.dev/toolchains/linux-llvm-22-arm64.tar.gz"
	tar -xf "linux-llvm-22-arm64.tar.gz" --checkpoint=.100
	rm "linux-llvm-22-arm64.tar.gz"
fi
