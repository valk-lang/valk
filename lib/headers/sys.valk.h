
#if OS == linux

link dynamic "pthread"
link dynamic "c"
link ":libc_nonshared.a"
link ":ld-linux-x86-64.so.2"

header "linux/abi"
#if ARCH == arm64
header "linux/arm64/libc-enums"
header "linux/arm64/libc-gen"
#else
header "linux/x64/libc-enums"
header "linux/x64/libc-gen"
#end
header "pthread"

#elif OS == macos

link dynamic "System"

header "macos/abi"
#if ARCH == arm64
header "macos/arm64/enum"
header "macos/arm64/libc-enums"
header "macos/arm64/libc-gen"
#elif ARCH == x64
header "macos/x64/enum"
header "macos/x64/libc-enums"
header "macos/x64/libc-gen"
#end
header "pthread"

#elif OS == win

link "kernel32"
link "ws2_32"
link "libucrt" // static c-runtime
link "libvcruntime" // static c-runtime
link "libcmt" // static c-runtime startup

header "win/structs"
header "win/abi"
header "win/x64/enum"
header "win/x64/libc-enums"
header "win/x64/libc-gen"

#end
