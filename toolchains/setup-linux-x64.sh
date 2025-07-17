
DIST_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TC_DIR="$DIST_DIR/toolchains"
LIB_DIR="$DIST_DIR/libraries"

mkdir -p $TC_DIR
mkdir -p $LIB_DIR

LIN_X64="$TC_DIR/linux-amd64"
LLVM_LIN_X64="$LIB_DIR/linux-llvm-15-x64"
CURL_LIN_X64="$LIB_DIR/linux-curl-x64"

if [ ! -d "$LIN_X64" ]; then
	echo "Download linux-x64 toolchain"
	cd $TC_DIR
	wget "https://files.valk-cdn.dev/toolchains/linux-amd64.tar.gz"
	tar -xf "linux-amd64.tar.gz" --checkpoint=.100
	rm "linux-amd64.tar.gz"
fi

if [ ! -d "$LLVM_LIN_X64" ]; then
	echo "Download LLVM linux x64"
	cd $LIB_DIR
	wget "https://files.valk-cdn.dev/toolchains/linux-llvm-15-x64.tar.gz"
	tar -xf "linux-llvm-15-x64.tar.gz" --checkpoint=.100
	rm "linux-llvm-15-x64.tar.gz"
fi

if [ ! -d "$CURL_LIN_X64" ]; then
	echo "Download Curl linux x64"
	cd $LIB_DIR
	wget "https://files.valk-cdn.dev/toolchains/linux-curl-x64.tar.gz"
	tar -xf "linux-curl-x64.tar.gz" --checkpoint=.100
	rm "linux-curl-x64.tar.gz"
fi
