
DIST_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TC_DIR="$DIST_DIR/toolchains"
LIB_DIR="$DIST_DIR/libraries"

mkdir -p $TC_DIR
mkdir -p $LIB_DIR

WIN_X64="$TC_DIR/win-sdk-x64"
LLVM_WIN_X64="$LIB_DIR/win-llvm-15-x64"
CURL_WIN_X64="$LIB_DIR/win-curl-x64"

if [ ! -d "$WIN_X64" ]; then
	echo "Download windows toolchain"
	cd $TC_DIR
	wget "https://files.valk-cdn.dev/toolchains/win-sdk-x64.tar.gz"
	tar -xf "win-sdk-x64.tar.gz" --checkpoint=.100
	rm "win-sdk-x64.tar.gz"
fi

if [ ! -d "$LLVM_WIN_X64" ]; then
	echo "Download LLVM windows x64"
	cd $LIB_DIR
	wget "https://files.valk-cdn.dev/toolchains/win-llvm-15-x64.tar.gz"
	tar -xf "win-llvm-15-x64.tar.gz" --checkpoint=.100
	rm "win-llvm-15-x64.tar.gz"
fi

if [ ! -d "$CURL_WIN_X64" ]; then
	echo "Download Curl windows x64"
	cd $LIB_DIR
	wget "https://files.valk-cdn.dev/toolchains/win-curl-x64.tar.gz"
	tar -xf "win-curl-x64.tar.gz" --checkpoint=.100
	rm "win-curl-x64.tar.gz"
fi
