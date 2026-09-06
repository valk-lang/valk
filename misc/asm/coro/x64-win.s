
.global valk_stack_swap
valk_stack_swap:

# Store Windows stack information
pushq %gs:0x10
pushq %gs:0x08

# Store caller registers
pushq %rbp
pushq %rbx
pushq %rdi
pushq %rsi
pushq %r12
pushq %r13
pushq %r14
pushq %r15

# Store caller simd/float registers
subq $0xa0, %rsp
movups %xmm6,  0x00(%rsp)
movups %xmm7,  0x10(%rsp)
movups %xmm8,  0x20(%rsp)
movups %xmm9,  0x30(%rsp)
movups %xmm10, 0x40(%rsp)
movups %xmm11, 0x50(%rsp)
movups %xmm12, 0x60(%rsp)
movups %xmm13, 0x70(%rsp)
movups %xmm14, 0x80(%rsp)
movups %xmm15, 0x90(%rsp)

# Modify stack pointer of current coroutine (rcx, first argument)
movq %rsp, (%rcx)

# Load stack pointer from target coroutine (rdx, second argument)
movq (%rdx), %rsp

# Restore target simd/float registers
movups 0x00(%rsp), %xmm6
movups 0x10(%rsp), %xmm7
movups 0x20(%rsp), %xmm8
movups 0x30(%rsp), %xmm9
movups 0x40(%rsp), %xmm10
movups 0x50(%rsp), %xmm11
movups 0x60(%rsp), %xmm12
movups 0x70(%rsp), %xmm13
movups 0x80(%rsp), %xmm14
movups 0x90(%rsp), %xmm15
addq $0xa0, %rsp

# Restore target registers
popq %r15
popq %r14
popq %r13
popq %r12
popq %rsi
popq %rdi
popq %rbx
popq %rbp

# Restore Windows stack information
popq %gs:0x08
popq %gs:0x10

retq

.global valk_gc_keep_alive
valk_gc_keep_alive:
retq

# valk_gc_scan_stack(callback, ctx): push the callee-saved registers, then
# call callback(sp, ctx) so a conservative scan from sp sees every register
.global valk_gc_scan_stack
valk_gc_scan_stack:

pushq %rbp
pushq %rbx
pushq %rdi
pushq %rsi
pushq %r12
pushq %r13
pushq %r14
pushq %r15
# Callee-saved simd registers, then 32 bytes of shadow space plus 8 for alignment
subq $0xa0, %rsp
movups %xmm6,  0x00(%rsp)
movups %xmm7,  0x10(%rsp)
movups %xmm8,  0x20(%rsp)
movups %xmm9,  0x30(%rsp)
movups %xmm10, 0x40(%rsp)
movups %xmm11, 0x50(%rsp)
movups %xmm12, 0x60(%rsp)
movups %xmm13, 0x70(%rsp)
movups %xmm14, 0x80(%rsp)
movups %xmm15, 0x90(%rsp)
subq $40, %rsp

movq %rcx, %rax
leaq 40(%rsp), %rcx
call *%rax

addq $40, %rsp
movups 0x00(%rsp), %xmm6
movups 0x10(%rsp), %xmm7
movups 0x20(%rsp), %xmm8
movups 0x30(%rsp), %xmm9
movups 0x40(%rsp), %xmm10
movups 0x50(%rsp), %xmm11
movups 0x60(%rsp), %xmm12
movups 0x70(%rsp), %xmm13
movups 0x80(%rsp), %xmm14
movups 0x90(%rsp), %xmm15
addq $0xa0, %rsp
popq %r15
popq %r14
popq %r13
popq %r12
popq %rsi
popq %rdi
popq %rbx
popq %rbp
retq

# valk_gc_stack_base(): highest address of the current fiber's stack
.global valk_gc_stack_base
valk_gc_stack_base:
movq %gs:0x08, %rax
retq

# The collector entry installed by valk_gc_set_entry(callback)
.data
valk_gc_entry:
.quad 0
.text

.global valk_gc_set_entry
valk_gc_set_entry:
movq %rcx, valk_gc_entry(%rip)
retq

# valk_gc_collect(): called straight from user code, so no frame of the
# runtime sits between the caller and the register capture. Pushes the
# callee-saved registers, clears the shadow space the caller reserved for
# us, and calls the entry with the stack pointer
.global valk_gc_collect
valk_gc_collect:
xorl %edx, %edx
jmp Lvalk_gc_collect

.global valk_gc_collect_shared
valk_gc_collect_shared:
movl $1, %edx

Lvalk_gc_collect:
movq $0, 0x08(%rsp)
movq $0, 0x10(%rsp)
movq $0, 0x18(%rsp)
movq $0, 0x20(%rsp)

pushq %rbp
pushq %rbx
pushq %rdi
pushq %rsi
pushq %r12
pushq %r13
pushq %r14
pushq %r15
subq $0xa0, %rsp
movups %xmm6,  0x00(%rsp)
movups %xmm7,  0x10(%rsp)
movups %xmm8,  0x20(%rsp)
movups %xmm9,  0x30(%rsp)
movups %xmm10, 0x40(%rsp)
movups %xmm11, 0x50(%rsp)
movups %xmm12, 0x60(%rsp)
movups %xmm13, 0x70(%rsp)
movups %xmm14, 0x80(%rsp)
movups %xmm15, 0x90(%rsp)
subq $40, %rsp

# Start at the saved registers, above the callee's shadow space and padding
leaq 40(%rsp), %rcx
call *valk_gc_entry(%rip)

addq $40, %rsp
movups 0x00(%rsp), %xmm6
movups 0x10(%rsp), %xmm7
movups 0x20(%rsp), %xmm8
movups 0x30(%rsp), %xmm9
movups 0x40(%rsp), %xmm10
movups 0x50(%rsp), %xmm11
movups 0x60(%rsp), %xmm12
movups 0x70(%rsp), %xmm13
movups 0x80(%rsp), %xmm14
movups 0x90(%rsp), %xmm15
addq $0xa0, %rsp
popq %r15
popq %r14
popq %r13
popq %r12
popq %rsi
popq %rdi
popq %rbx
popq %rbp
retq
