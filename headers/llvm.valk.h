
#if STATIC
#if OS == win
link static "LLVM-C"
#else
link static "LLVMOption"
link static "LLVMObjCARCOpts"
link static "LLVMMCJIT"
link static "LLVMInterpreter"
link static "LLVMExecutionEngine"
link static "LLVMRuntimeDyld"
link static "LLVMXCoreDisassembler"
link static "LLVMXCoreCodeGen"
link static "LLVMXCoreDesc"
link static "LLVMXCoreInfo"
link static "LLVMX86Disassembler"
link static "LLVMX86AsmParser"
link static "LLVMX86CodeGen"
link static "LLVMX86Desc"
link static "LLVMX86Info"
link static "LLVMWebAssemblyDisassembler"
link static "LLVMWebAssemblyCodeGen"
link static "LLVMWebAssemblyDesc"
link static "LLVMWebAssemblyAsmParser"
link static "LLVMWebAssemblyInfo"
link static "LLVMWebAssemblyUtils"
link static "LLVMSystemZDisassembler"
link static "LLVMSystemZCodeGen"
link static "LLVMSystemZAsmParser"
link static "LLVMSystemZDesc"
link static "LLVMSystemZInfo"
link static "LLVMSparcDisassembler"
link static "LLVMSparcCodeGen"
link static "LLVMSparcAsmParser"
link static "LLVMSparcDesc"
link static "LLVMSparcInfo"
link static "LLVMRISCVDisassembler"
link static "LLVMRISCVCodeGen"
link static "LLVMRISCVAsmParser"
link static "LLVMRISCVDesc"
link static "LLVMRISCVInfo"
link static "LLVMPowerPCDisassembler"
link static "LLVMPowerPCCodeGen"
link static "LLVMPowerPCAsmParser"
link static "LLVMPowerPCDesc"
link static "LLVMPowerPCInfo"
link static "LLVMNVPTXCodeGen"
link static "LLVMNVPTXDesc"
link static "LLVMNVPTXInfo"
link static "LLVMMSP430Disassembler"
link static "LLVMMSP430CodeGen"
link static "LLVMMSP430AsmParser"
link static "LLVMMSP430Desc"
link static "LLVMMSP430Info"
link static "LLVMMipsDisassembler"
link static "LLVMMipsCodeGen"
link static "LLVMMipsAsmParser"
link static "LLVMMipsDesc"
link static "LLVMMipsInfo"
link static "LLVMLanaiDisassembler"
link static "LLVMLanaiCodeGen"
link static "LLVMLanaiAsmParser"
link static "LLVMLanaiDesc"
link static "LLVMLanaiInfo"
link static "LLVMHexagonDisassembler"
link static "LLVMHexagonCodeGen"
link static "LLVMHexagonAsmParser"
link static "LLVMHexagonDesc"
link static "LLVMHexagonInfo"
link static "LLVMBPFDisassembler"
link static "LLVMBPFCodeGen"
link static "LLVMBPFAsmParser"
link static "LLVMBPFDesc"
link static "LLVMBPFInfo"
link static "LLVMAVRDisassembler"
link static "LLVMAVRCodeGen"
link static "LLVMAVRAsmParser"
link static "LLVMAVRDesc"
link static "LLVMAVRInfo"
link static "LLVMARMDisassembler"
link static "LLVMARMCodeGen"
link static "LLVMARMAsmParser"
link static "LLVMARMDesc"
link static "LLVMARMUtils"
link static "LLVMARMInfo"
link static "LLVMAMDGPUDisassembler"
link static "LLVMAMDGPUCodeGen"
link static "LLVMMIRParser"
link static "LLVMipo"
link static "LLVMInstrumentation"
link static "LLVMVectorize"
link static "LLVMLinker"
link static "LLVMIRReader"
link static "LLVMAsmParser"
link static "LLVMFrontendOpenMP"
link static "LLVMAMDGPUAsmParser"
link static "LLVMAMDGPUDesc"
link static "LLVMAMDGPUUtils"
link static "LLVMAMDGPUInfo"
link static "LLVMAArch64Disassembler"
link static "LLVMMCDisassembler"
link static "LLVMAArch64CodeGen"
link static "LLVMCFGuard"
link static "LLVMGlobalISel"
link static "LLVMSelectionDAG"
link static "LLVMAsmPrinter"
link static "LLVMCodeGen"
link static "LLVMTarget"
link static "LLVMScalarOpts"
link static "LLVMInstCombine"
link static "LLVMAggressiveInstCombine"
link static "LLVMTransformUtils"
link static "LLVMBitWriter"
link static "LLVMAnalysis"
link static "LLVMProfileData"
link static "LLVMDebugInfoDWARF"
link static "LLVMObject"
link static "LLVMTextAPI"
link static "LLVMBitReader"
link static "LLVMCore"
link static "LLVMRemarks"
link static "LLVMBitstreamReader"
link static "LLVMAArch64AsmParser"
link static "LLVMMCParser"
link static "LLVMAArch64Desc"
link static "LLVMMC"
link static "LLVMDebugInfoCodeView"
link static "LLVMDebugInfoMSF"
link static "LLVMBinaryFormat"
link static "LLVMAArch64Utils"
link static "LLVMAArch64Info"
link static "LLVMSupport"
link static "LLVMDemangle"
link static "LLVMPasses"
link static "LLVMCoroutines"
link static "LLVMVECodeGen"
link static "LLVMVEAsmParser"
link static "LLVMVEDesc"
link static "LLVMVEDisassembler"
link static "LLVMVEInfo"
#end

#if OS == linux
link dynamic "pthread"
link dynamic "m"
link static "stdc++"
link static "z"
link static "zstd"
link static "tinfo"
link static "gcc_eh"

#elif OS == macos
link static "ncurses"
link static "c++"
link static "z"
link static "zstd"

#elif OS == win
link dynamic "msvcprt"
link dynamic "oldnames"

link dynamic "advapi32"
link dynamic "shell32"
link dynamic "ole32"
#end

#else
link dynamic "LLVM-15"
#end

// $(LLVM_LIBS) -lc -lstdc++ -lrt -ldl -lpthread -lm -lz -ltinfo -lxml2
// link static "stdc++"
// // link static "rt"
// // link static "dl"
// link dynamic "pthread"
// link dynamic "m"
// link static "z"
// link static "tinfo"
// // link static "xml2"
// link static "gcc_eh"

alias LLVMBool for bool

// Output types
value LLVMAssemblyFile (0)
value LLVMObjectFile (1)

// Return status action
value LLVMAbortProcessAction (0) // verifier will print to stderr and abort()
value LLVMPrintMessageAction (1) // verifier will print to stderr and return 1
value LLVMReturnStatusAction (2) // verifier will just return 1

// LLVMCodeGenOptLevel
value LLVMCodeGenLevelNone (0)
value LLVMCodeGenLevelLess (1)
value LLVMCodeGenLevelDefault (2)
value LLVMCodeGenLevelAggressive (3)

// LLVMRelocMode
value LLVMRelocDefault (0)
value LLVMRelocStatic (1)
value LLVMRelocPIC (2)
value LLVMRelocDynamicNoPic (3)
value LLVMRelocROPI (4)
value LLVMRelocRWPI (5)
value LLVMRelocROPI_RWPI (6)

// LLVMCodeModel
value LLVMCodeModelDefault (0)
value LLVMCodeModelJITDefault (1)
value LLVMCodeModelTiny (2)
value LLVMCodeModelSmall (3)
value LLVMCodeModelKernel (4)
value LLVMCodeModelMedium (5)
value LLVMCodeModelLarge (6)

// Types
pointer LLVMModuleRef {}
pointer LLVMPassManagerRef {}
pointer LLVMContextRef {}
pointer LLVMMemoryBufferRef {}
pointer LLVMTargetMachineRef {}
pointer LLVMTargetDataRef {}
pointer LLVMTargetRef {}
pointer LLVMPassManagerBuilderRef {}
pointer LLVMValueRef {}

// Init
fn LLVMContextCreate() LLVMContextRef;
fn LLVMContextSetOpaquePointers(context: LLVMContextRef, enable: bool) void;
fn LLVMModuleCreateWithNameInContext(name: cstring, context: LLVMContextRef) LLVMModuleRef;
fn LLVMCreateMemoryBufferWithContentsOfFile(path: cstring, buffer_ref: ptr, msg_ref: ptr) LLVMBool;

// Moodule / verify
fn LLVMLinkModules2(mod1: LLVMModuleRef, mod2: LLVMModuleRef) LLVMBool;
fn LLVMPrintModuleToString(mod: LLVMModuleRef) cstring;
fn LLVMParseIRInContext(context: LLVMContextRef, buffer: LLVMMemoryBufferRef, mod_ref: ptr, msg_ref: ptr) LLVMBool;
fn LLVMVerifyModule(mod: LLVMModuleRef, return_status_action: i32, error_msg_ref: ptr) LLVMBool;

// Target
fn LLVMGetTargetFromTriple(triple: cstring, target_ref: ptr, msg_ref: ptr) LLVMBool;
fn LLVMCreateTargetMachine(target: LLVMTargetRef, triple: cstring, cpu: cstring, features: ?cstring, code_gen_level: i32, reloc_mode: i32, code_model: i32) ?LLVMTargetMachineRef;
fn LLVMCreateTargetDataLayout(machine: LLVMTargetMachineRef) LLVMTargetDataRef;
fn LLVMCopyStringRepOfTargetData(target: LLVMTargetDataRef) cstring;
fn LLVMGetHostCPUFeatures() cstring;
fn LLVMGetDefaultTargetTriple() cstring;
fn LLVMGetTargetName(target: LLVMTargetDataRef) cstring;
fn LLVMGetTargetDescription(target: LLVMTargetDataRef) cstring;
fn LLVMGetTargetHasJIT(target: LLVMTargetDataRef) LLVMBool;
fn LLVMGetTargetHasTargetMachine(target: LLVMTargetDataRef) LLVMBool;

// Optimize
fn LLVMPassManagerBuilderCreate() LLVMPassManagerBuilderRef;
fn LLVMPassManagerBuilderSetOptLevel(pm_builder: LLVMPassManagerBuilderRef, opt_level: u32) void;
fn LLVMPassManagerBuilderSetSizeLevel(pm_builder: LLVMPassManagerBuilderRef, opt_level: u32) void;
fn LLVMPassManagerBuilderUseInlinerWithThreshold(pm_builder: LLVMPassManagerBuilderRef, threshold: u32) void;
fn LLVMCreateFunctionPassManagerForModule(mod: LLVMModuleRef) LLVMPassManagerRef;
fn LLVMCreatePassManager() LLVMPassManagerRef;
fn LLVMPassManagerBuilderPopulateFunctionPassManager(pm_builder: LLVMPassManagerBuilderRef, func_pm: LLVMPassManagerRef) void;
fn LLVMPassManagerBuilderPopulateModulePassManager(pm_builder: LLVMPassManagerBuilderRef, func_pm: LLVMPassManagerRef) void;
fn LLVMInitializeFunctionPassManager(func_pm: LLVMPassManagerRef) void;
fn LLVMGetFirstFunction(mod: LLVMModuleRef) ?LLVMValueRef;
fn LLVMGetNextFunction(val: LLVMValueRef) ?LLVMValueRef;
fn LLVMRunFunctionPassManager(func_pm: LLVMPassManagerRef, func: LLVMValueRef) void;
fn LLVMFinalizeFunctionPassManager(func_pm: LLVMPassManagerRef) void;
fn LLVMRunPassManager(pm: LLVMPassManagerRef, mod: LLVMModuleRef) void;

// Build
fn LLVMSetTarget(mod: LLVMModuleRef, triple: cstring) void;
fn LLVMSetDataLayout(mod: LLVMModuleRef, layout: cstring) void;
fn LLVMTargetMachineEmitToFile(target_machine: LLVMTargetMachineRef, mod: LLVMModuleRef, path_out: cstring, output_type: i32, error_msg_ref: ptr) LLVMBool;

// Dispose
fn LLVMDisposeMessage(cstr: ?cstring) void;
fn LLVMDisposeModule(module: LLVMModuleRef) void;
fn LLVMContextDispose(context: LLVMContextRef) void;
fn LLVMDisposePassManager(pm: LLVMPassManagerRef) void;
fn LLVMPassManagerBuilderDispose(pm_builder: LLVMPassManagerBuilderRef) void;

// Target c magic
// x86
fn LLVMInitializeX86TargetInfo() void;
fn LLVMInitializeX86Target() void;
fn LLVMInitializeX86TargetMC() void;
fn LLVMInitializeX86AsmPrinter() void;
fn LLVMInitializeX86AsmParser() void;
fn LLVMInitializeX86Disassembler() void;
// Aarch64
fn LLVMInitializeAArch64TargetInfo() void;
fn LLVMInitializeAArch64Target() void;
fn LLVMInitializeAArch64TargetMC() void;
fn LLVMInitializeAArch64AsmPrinter() void;
fn LLVMInitializeAArch64AsmParser() void;
fn LLVMInitializeAArch64Disassembler() void;
// #define LLVM_TARGET(TargetName) LLVMInitialize##TargetName##TargetInfo()
// LLVM_TARGET(AArch64)
// LLVM_TARGET(AMDGPU)
// LLVM_TARGET(ARM)
// LLVM_TARGET(AVR)
// LLVM_TARGET(BPF)
// LLVM_TARGET(Hexagon)
// LLVM_TARGET(Lanai)
// LLVM_TARGET(Mips)
// LLVM_TARGET(MSP430)
// LLVM_TARGET(NVPTX)
// LLVM_TARGET(PowerPC)
// LLVM_TARGET(RISCV)
// LLVM_TARGET(Sparc)
// LLVM_TARGET(SystemZ)
// LLVM_TARGET(VE)
// LLVM_TARGET(WebAssembly)
// LLVM_TARGET(X86)
// LLVM_TARGET(XCore)
// LLVM_TARGET(M68k)