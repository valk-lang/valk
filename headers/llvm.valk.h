
#if STATIC
#if OS == win
link_static "LLVM-C"
#else
link_static "LLVMOption"
link_static "LLVMObjCARCOpts"
link_static "LLVMMCJIT"
link_static "LLVMInterpreter"
link_static "LLVMExecutionEngine"
link_static "LLVMRuntimeDyld"
link_static "LLVMXCoreDisassembler"
link_static "LLVMXCoreCodeGen"
link_static "LLVMXCoreDesc"
link_static "LLVMXCoreInfo"
link_static "LLVMX86Disassembler"
link_static "LLVMX86AsmParser"
link_static "LLVMX86CodeGen"
link_static "LLVMX86Desc"
link_static "LLVMX86Info"
link_static "LLVMWebAssemblyDisassembler"
link_static "LLVMWebAssemblyCodeGen"
link_static "LLVMWebAssemblyDesc"
link_static "LLVMWebAssemblyAsmParser"
link_static "LLVMWebAssemblyInfo"
link_static "LLVMWebAssemblyUtils"
link_static "LLVMSystemZDisassembler"
link_static "LLVMSystemZCodeGen"
link_static "LLVMSystemZAsmParser"
link_static "LLVMSystemZDesc"
link_static "LLVMSystemZInfo"
link_static "LLVMSparcDisassembler"
link_static "LLVMSparcCodeGen"
link_static "LLVMSparcAsmParser"
link_static "LLVMSparcDesc"
link_static "LLVMSparcInfo"
link_static "LLVMRISCVDisassembler"
link_static "LLVMRISCVCodeGen"
link_static "LLVMRISCVAsmParser"
link_static "LLVMRISCVDesc"
link_static "LLVMRISCVInfo"
link_static "LLVMPowerPCDisassembler"
link_static "LLVMPowerPCCodeGen"
link_static "LLVMPowerPCAsmParser"
link_static "LLVMPowerPCDesc"
link_static "LLVMPowerPCInfo"
link_static "LLVMNVPTXCodeGen"
link_static "LLVMNVPTXDesc"
link_static "LLVMNVPTXInfo"
link_static "LLVMMSP430Disassembler"
link_static "LLVMMSP430CodeGen"
link_static "LLVMMSP430AsmParser"
link_static "LLVMMSP430Desc"
link_static "LLVMMSP430Info"
link_static "LLVMMipsDisassembler"
link_static "LLVMMipsCodeGen"
link_static "LLVMMipsAsmParser"
link_static "LLVMMipsDesc"
link_static "LLVMMipsInfo"
link_static "LLVMLanaiDisassembler"
link_static "LLVMLanaiCodeGen"
link_static "LLVMLanaiAsmParser"
link_static "LLVMLanaiDesc"
link_static "LLVMLanaiInfo"
link_static "LLVMHexagonDisassembler"
link_static "LLVMHexagonCodeGen"
link_static "LLVMHexagonAsmParser"
link_static "LLVMHexagonDesc"
link_static "LLVMHexagonInfo"
link_static "LLVMBPFDisassembler"
link_static "LLVMBPFCodeGen"
link_static "LLVMBPFAsmParser"
link_static "LLVMBPFDesc"
link_static "LLVMBPFInfo"
link_static "LLVMAVRDisassembler"
link_static "LLVMAVRCodeGen"
link_static "LLVMAVRAsmParser"
link_static "LLVMAVRDesc"
link_static "LLVMAVRInfo"
link_static "LLVMARMDisassembler"
link_static "LLVMARMCodeGen"
link_static "LLVMARMAsmParser"
link_static "LLVMARMDesc"
link_static "LLVMARMUtils"
link_static "LLVMARMInfo"
link_static "LLVMAMDGPUDisassembler"
link_static "LLVMAMDGPUCodeGen"
link_static "LLVMMIRParser"
link_static "LLVMipo"
link_static "LLVMInstrumentation"
link_static "LLVMVectorize"
link_static "LLVMLinker"
link_static "LLVMIRReader"
link_static "LLVMAsmParser"
link_static "LLVMFrontendOpenMP"
link_static "LLVMAMDGPUAsmParser"
link_static "LLVMAMDGPUDesc"
link_static "LLVMAMDGPUUtils"
link_static "LLVMAMDGPUInfo"
link_static "LLVMAArch64Disassembler"
link_static "LLVMMCDisassembler"
link_static "LLVMAArch64CodeGen"
link_static "LLVMCFGuard"
link_static "LLVMGlobalISel"
link_static "LLVMSelectionDAG"
link_static "LLVMAsmPrinter"
link_static "LLVMCodeGen"
link_static "LLVMTarget"
link_static "LLVMScalarOpts"
link_static "LLVMInstCombine"
link_static "LLVMAggressiveInstCombine"
link_static "LLVMTransformUtils"
link_static "LLVMBitWriter"
link_static "LLVMAnalysis"
link_static "LLVMProfileData"
link_static "LLVMDebugInfoDWARF"
link_static "LLVMObject"
link_static "LLVMTextAPI"
link_static "LLVMBitReader"
link_static "LLVMCore"
link_static "LLVMRemarks"
link_static "LLVMBitstreamReader"
link_static "LLVMAArch64AsmParser"
link_static "LLVMMCParser"
link_static "LLVMAArch64Desc"
link_static "LLVMMC"
link_static "LLVMDebugInfoCodeView"
link_static "LLVMDebugInfoMSF"
link_static "LLVMBinaryFormat"
link_static "LLVMAArch64Utils"
link_static "LLVMAArch64Info"
link_static "LLVMSupport"
link_static "LLVMDemangle"
link_static "LLVMPasses"
link_static "LLVMCoroutines"
link_static "LLVMVECodeGen"
link_static "LLVMVEAsmParser"
link_static "LLVMVEDesc"
link_static "LLVMVEDisassembler"
link_static "LLVMVEInfo"
#end

#if OS == linux
link_dynamic "pthread"
link_dynamic "m"
link_static "stdc++"
link_static "z"
link_static "zstd"
link_static "tinfo"
link_static "gcc_eh"

#elif OS == macos
link_static "ncurses"
link_static "c++"
link_static "z"
// link_static "zstd"

#elif OS == win
link_dynamic "msvcprt"
link_dynamic "oldnames"

link_dynamic "advapi32"
link_dynamic "shell32"
link_dynamic "ole32"
#end

#else
link_dynamic "LLVM-15"
#end

// $(LLVM_LIBS) -lc -lstdc++ -lrt -ldl -lpthread -lm -lz -ltinfo -lxml2
// link_static "stdc++"
// // link_static "rt"
// // link_static "dl"
// link_dynamic "pthread"
// link_dynamic "m"
// link_static "z"
// link_static "tinfo"
// // link_static "xml2"
// link_static "gcc_eh"

alias LLVMBool as bool

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