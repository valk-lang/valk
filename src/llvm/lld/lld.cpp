// lld inside the compiler: linking needs no installed linker
#include <lld/Common/Driver.h>
#include <llvm/Support/raw_ostream.h>
#include <cstring>
#include <mutex>
#include <string>
#include <vector>

LLD_HAS_DRIVER(elf)

// Links with these arguments; argv[0] is "ld.lld". What lld printed goes to *out (malloc'ed).
extern "C" int valk_lld(int argc, const char **argv, char **out) {
    // lld keeps its state in globals: one link at a time
    static std::mutex lock;
    std::lock_guard<std::mutex> guard(lock);
    std::string text;
    llvm::raw_string_ostream os(text);
    std::vector<const char *> args(argv, argv + argc);
    lld::Result result = lld::lldMain(args, os, os, {{lld::Gnu, &lld::elf::link}});
    os.flush();
    *out = strdup(text.c_str());
    return result.retCode;
}
