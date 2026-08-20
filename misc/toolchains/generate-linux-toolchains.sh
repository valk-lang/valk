SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_ROOT=$( cd -- "$SCRIPT_DIR/../.." &> /dev/null && pwd )
TC_DIR="$PROJECT_ROOT/toolchains/toolchains"

create_tc() {
    ARCH=$1
    echo "Toolchain: linux-$ARCH"
    mkdir -p linux-$ARCH
    rm -rf linux-$ARCH/*
    cd linux-$ARCH

    PACKAGES="libgcc-12-dev:$ARCH libssl-dev:$ARCH libcurl4-openssl-dev:$ARCH libstdc++-12-dev:$ARCH zlib1g-dev:$ARCH libncurses-dev:$ARCH libxml2-dev:$ARCH"

    apt-get download --print-uris $(apt-cache depends --recurse --no-recommends --no-suggests \
    --no-conflicts --no-breaks --no-replaces --no-enhances \
    --no-pre-depends ${PACKAGES} | grep "^\w") | cut -f 2 -d \' | grep \.deb \
    > download.txt

    wget -i download.txt

    mkdir -p buffer
    mkdir -p linux-$ARCH
    rm -rf buffer/*
    for i in ./*.deb; do dpkg-deb -R "$i" buffer && cp -r buffer/* linux-$ARCH/ && rm -rf buffer/*; done

    tar -czvf linux-$ARCH.tar.gz linux-$ARCH

    cd ..
    mv linux-$ARCH/linux-$ARCH.tar.gz .
}

mkdir -p "$TC_DIR"
cd "$TC_DIR"

create_tc "amd64"
create_tc "arm64"
