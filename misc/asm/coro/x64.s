
.global _valk_stack_swap
_valk_stack_swap:
.global valk_stack_swap
valk_stack_swap:

# Store caller registers on the current stack
pushq %rbp
pushq %rbx
pushq %r12
pushq %r13
pushq %r14
pushq %r15

# Modify stack pointer of current coroutine (rdi, first argument)
movq %rsp, (%rdi)

# Load stack pointer from target coroutine (rsi, second argument)
movq (%rsi), %rsp

# Restore target registers
popq %r15
popq %r14
popq %r13
popq %r12
popq %rbx
popq %rbp

# jump
retq

# valk_gc_scan_stack(callback, ctx): push the callee-saved registers, then
# call callback(sp, ctx) so a conservative scan from sp sees every register
.global _valk_gc_scan_stack
_valk_gc_scan_stack:
.global valk_gc_scan_stack
valk_gc_scan_stack:

pushq %rbp
pushq %rbx
pushq %r12
pushq %r13
pushq %r14
pushq %r15
subq $8, %rsp

movq %rdi, %rax
leaq 8(%rsp), %rdi
call *%rax

addq $8, %rsp
popq %r15
popq %r14
popq %r13
popq %r12
popq %rbx
popq %rbp
retq

# The collector entry installed by valk_gc_set_entry(callback)
.data
valk_gc_entry:
.quad 0
.text

.global _valk_gc_set_entry
_valk_gc_set_entry:
.global valk_gc_set_entry
valk_gc_set_entry:
movq %rdi, valk_gc_entry(%rip)
retq

# valk_gc_collect(): called straight from user code, so no frame of the
# runtime sits between the caller and the register capture. Pushes the
# callee-saved registers and calls the entry with the stack pointer
.global _valk_gc_collect
_valk_gc_collect:
.global valk_gc_collect
valk_gc_collect:
xorl %esi, %esi
jmp Lvalk_gc_collect

.global _valk_gc_collect_shared
_valk_gc_collect_shared:
.global valk_gc_collect_shared
valk_gc_collect_shared:
movl $1, %esi

Lvalk_gc_collect:
pushq %rbp
pushq %rbx
pushq %r12
pushq %r13
pushq %r14
pushq %r15
subq $8, %rsp

# Start at the saved registers, above the alignment slot
leaq 8(%rsp), %rdi
call *valk_gc_entry(%rip)

addq $8, %rsp
popq %r15
popq %r14
popq %r13
popq %r12
popq %rbx
popq %rbp
retq
