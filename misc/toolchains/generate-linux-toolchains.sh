# Builds the linux-amd64 and linux-arm64 sysroots from Ubuntu 22.04 packages (glibc 2.35, GCC 12).
# Run it in an ubuntu:22.04 container (`docker run --network host`) that can fetch arm64 packages:
#   dpkg --add-architecture arm64
#   sed -i 's|^deb http|deb [arch=amd64] http|' /etc/apt/sources.list
#   echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports jammy main universe" > /etc/apt/sources.list.d/arm64.list
#   (the same for jammy-updates and jammy-security), then apt-get update && apt-get install -y wget
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_ROOT=$( cd -- "$SCRIPT_DIR/../.." &> /dev/null && pwd )
TC_DIR="$PROJECT_ROOT/toolchains/toolchains"

create_tc() {
    ARCH=$1
    echo "Toolchain: linux-$ARCH"
    mkdir -p linux-$ARCH
    rm -rf linux-$ARCH/*
    cd linux-$ARCH

    PACKAGES="libgcc-12-dev:$ARCH libssl-dev:$ARCH libcurl4-openssl-dev:$ARCH libstdc++-12-dev:$ARCH zlib1g-dev:$ARCH libncurses-dev:$ARCH libxml2-dev:$ARCH libzstd-dev:$ARCH libicu-dev:$ARCH libc6-dev:$ARCH"

    apt-get download --print-uris $(apt-cache depends --recurse --no-recommends --no-suggests \
    --no-conflicts --no-breaks --no-replaces --no-enhances \
    --no-pre-depends ${PACKAGES} | grep "^\w") | cut -f 2 -d \' | grep -E "_($ARCH|all)\.deb$" \
    > download.txt

    wget -i download.txt

    mkdir -p linux-$ARCH
    for i in ./*.deb; do dpkg-deb -x "$i" linux-$ARCH; done
    # Absolute links would point into the host
    (cd linux-$ARCH && find . -type l -lname '/*' | while read -r link; do
        ln -sfn "$(realpath -m --relative-to="$(dirname "$link")" ".$(readlink "$link")")" "$link"
    done)

    tar -czvf linux-$ARCH.tar.gz linux-$ARCH

    cd ..
    mv linux-$ARCH/linux-$ARCH.tar.gz .
}

mkdir -p "$TC_DIR"
cd "$TC_DIR"

create_tc "amd64"
create_tc "arm64"
