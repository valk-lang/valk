
DIST_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TC_DIR="$DIST_DIR/toolchains"
LIB_DIR="$DIST_DIR/libraries"

mkdir -p $TC_DIR
mkdir -p $LIB_DIR

MAC_ANY="$TC_DIR/macos-11-3"
LLVM_MAC_ARM64="$LIB_DIR/macos-llvm-15-arm64"

if [ ! -d "$MAC_ANY" ]; then
	echo "Download macos toolchain"
	cd $TC_DIR
	wget "https://files.valk-cdn.dev/toolchains/macos-sdk-11-3.tar.xz"
	tar -xf "macos-sdk-11-3.tar.xz" --checkpoint=.100
	rm "macos-sdk-11-3.tar.xz"
	mv "MacOSX11.3.sdk" "macos-11-3" 
fi

if [ ! -d "$LLVM_MAC_ARM64" ]; then
	echo "Download LLVM macos arm64"
	cd $LIB_DIR
	wget "https://files.valk-cdn.dev/toolchains/macos-llvm-15-arm64.tar.gz"
	tar -xf "macos-llvm-15-arm64.tar.gz" --checkpoint=.100
	rm "macos-llvm-15-arm64.tar.gz"
fi
