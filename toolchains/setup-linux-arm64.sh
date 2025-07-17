
DIST_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TC_DIR="$DIST_DIR/toolchains"
LIB_DIR="$DIST_DIR/libraries"

mkdir -p $TC_DIR
mkdir -p $LIB_DIR

LIN_ARM64="$TC_DIR/linux-arm64"

if [ ! -d "$LIN_ARM64" ]; then
	echo "Download linux-arm64 toolchain"
	cd $TC_DIR
	wget "https://files.valk-cdn.dev/toolchains/linux-arm64.tar.bz2"
	tar -xf "linux-arm64.tar.bz2" --checkpoint=.100
	rm "linux-arm64.tar.bz2"
	mv "aarch64--glibc--stable-2022.08-1" "linux-arm64" 
fi
