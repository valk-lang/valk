// lld inside the compiler: linking needs no installed linker
#include <lld/Common/Driver.h>
#include <llvm/Support/raw_ostream.h>
#include <cstdlib>
#include <cstring>
#include <mutex>
#include <string>
#include <vector>

LLD_HAS_DRIVER(elf)
LLD_HAS_DRIVER(macho)
LLD_HAS_DRIVER(coff)

// Links with these arguments; argv[0] picks the driver: "ld.lld", "ld64.lld" or "lld-link". What lld printed goes to *out (malloc'ed).
extern "C" int valk_lld(int argc, const char **argv, char **out) {
    // lld keeps its state in globals: one link at a time
    static std::mutex lock;
    std::lock_guard<std::mutex> guard(lock);
    std::string text;
    llvm::raw_string_ostream os(text);
    std::vector<const char *> args(argv, argv + argc);
    lld::Result result = lld::lldMain(args, os, os, {
        {lld::Gnu, &lld::elf::link},
        {lld::Darwin, &lld::macho::link},
        {lld::WinLink, &lld::coff::link},
    });
    os.flush();
    *out = (char *)malloc(text.size() + 1);
    memcpy(*out, text.c_str(), text.size() + 1);
    return result.retCode;
}
