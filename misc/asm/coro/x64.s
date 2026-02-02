
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

.global _valk_save_registers
_valk_save_registers:
.global valk_save_registers
valk_save_registers:
movq %rbp, (%rdi)
movq %rbx, 8(%rdi)
movq %r12, 16(%rdi)
movq %r13, 24(%rdi)
movq %r14, 32(%rdi)
movq %r15, 40(%rdi)
retq

.global _valk_restore_registers
_valk_restore_registers:
.global valk_restore_registers
valk_restore_registers:
movq (%rdi), %rbp
movq 8(%rdi), %rbx
movq 16(%rdi), %r12
movq 24(%rdi), %r13
movq 32(%rdi), %r14
movq 40(%rdi), %r15
retq

.global _valk_get_rsp
_valk_get_rsp:
movq  %rsp, %rax
retq
