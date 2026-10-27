
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
jmp Lvalk_gc_collect

# valk_gc_poll_most(): valk_gc_poll for a caller that keeps its values in every general
# register but r11 across the call (LLVM's preserve_mostcc), so a loop keeps its registers.
# They are saved where the stack scan sees them, then restored
.global _valk_gc_poll_most
_valk_gc_poll_most:
.global valk_gc_poll_most
valk_gc_poll_most:
pushq %rax
pushq %rcx
pushq %rdx
pushq %rsi
pushq %rdi
pushq %r8
pushq %r9
pushq %r10
subq $8, %rsp
call Lvalk_gc_poll
addq $8, %rsp
popq %r10
popq %r9
popq %r8
popq %rdi
popq %rsi
popq %rdx
popq %rcx
popq %rax
retq

# valk_gc_poll(): Grove-MT's loop poll, whose word fired: a round waits for the thread, or a
# collection is pending
.global _valk_gc_poll
_valk_gc_poll:
.global valk_gc_poll
valk_gc_poll:
Lvalk_gc_poll:
movl $2, %esi

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

# Grove-MT native regions (v6 C7, RT6). The control block starts with the thread's state
# (0 RUN, 1 NAT, 2 HELD, 3 SAFE), its NAT save area (the caller's stack pointer and its
# callee-saved registers, at 8..96) and its count of NAT exits (104)

# valk_gc_native_enter(ctl): RUN -> NAT before a call into native code. A null ctl is a thread
# that is not registered
.global _valk_gc_native_enter
_valk_gc_native_enter:
.global valk_gc_native_enter
valk_gc_native_enter:
testq %rdi, %rdi
jz 1f
leaq 8(%rsp), %rax
movq %rax, 8(%rdi)
movq %rbx, 16(%rdi)
movq %rbp, 24(%rdi)
movq %r12, 32(%rdi)
movq %r13, 40(%rdi)
movq %r14, 48(%rdi)
movq %r15, 56(%rdi)
movq $1, %rax
xchgq %rax, (%rdi)
1:
retq

# valk_gc_native_leave(ctl): NAT -> RUN by a compare-and-swap; while a round holds the thread
# (HELD) the installed slow path waits for its release
.global _valk_gc_native_leave
_valk_gc_native_leave:
.global valk_gc_native_leave
valk_gc_native_leave:
testq %rdi, %rdi
jz 1f
incq 104(%rdi)
movq $1, %rax
xorl %ecx, %ecx
lock cmpxchgq %rcx, (%rdi)
jne 2f
1:
retq
2:
jmp *valk_gc_leave_slow(%rip)

.data
valk_gc_leave_slow:
.quad 0
.text

.global _valk_gc_set_leave_slow
_valk_gc_set_leave_slow:
.global valk_gc_set_leave_slow
valk_gc_set_leave_slow:
movq %rdi, valk_gc_leave_slow(%rip)
retq

# valk_gc_cas(address, expected, desired): returns the old value
.global _valk_gc_cas
_valk_gc_cas:
.global valk_gc_cas
valk_gc_cas:
movq %rsi, %rax
lock cmpxchgq %rdx, (%rdi)
retq
