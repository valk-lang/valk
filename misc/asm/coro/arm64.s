
.global _valk_stack_swap
_valk_stack_swap:
.global valk_stack_swap
valk_stack_swap:

# Store caller registers on the current stack
# Each register requires 8 bytes, there are 20 registers to save
sub sp, sp, 0xa0
# d* are the 128-bit floating point registers, the lower 64 bits are preserved
stp d8,   d9, [sp, 0x00]
stp d10, d11, [sp, 0x10]
stp d12, d13, [sp, 0x20]
stp d14, d15, [sp, 0x30]
# x* are the scratch registers
stp x19, x20, [sp, 0x40]
stp x21, x22, [sp, 0x50]
stp x23, x24, [sp, 0x60]
stp x25, x26, [sp, 0x70]
stp x27, x28, [sp, 0x80]
# fp=frame pointer, lr=link register
stp fp,   lr, [sp, 0x90]

# Modify stack pointer of current coroutine (x0, first argument)
mov x2, sp
str x2, [x0, 0]

# Load stack pointer from target coroutine (x1, second argument)
ldr x9, [x1, 0]
mov sp, x9

# Restore target registers
ldp d8,   d9, [sp, 0x00]
ldp d10, d11, [sp, 0x10]
ldp d12, d13, [sp, 0x20]
ldp d14, d15, [sp, 0x30]
ldp x19, x20, [sp, 0x40]
ldp x21, x22, [sp, 0x50]
ldp x23, x24, [sp, 0x60]
ldp x25, x26, [sp, 0x70]
ldp x27, x28, [sp, 0x80]
ldp fp,   lr, [sp, 0x90]

# Pop stack frame
add sp, sp, 0xa0

# jump to lr
ret

# valk_gc_scan_stack(callback, ctx): push the callee-saved registers, then
# call callback(sp, ctx) so a conservative scan from sp sees every register
.global _valk_gc_scan_stack
_valk_gc_scan_stack:
.global valk_gc_scan_stack
valk_gc_scan_stack:

sub sp, sp, 0xa0
stp d8,   d9, [sp, 0x00]
stp d10, d11, [sp, 0x10]
stp d12, d13, [sp, 0x20]
stp d14, d15, [sp, 0x30]
stp x19, x20, [sp, 0x40]
stp x21, x22, [sp, 0x50]
stp x23, x24, [sp, 0x60]
stp x25, x26, [sp, 0x70]
stp x27, x28, [sp, 0x80]
stp fp,   lr, [sp, 0x90]

mov x9, x0
mov x0, sp
blr x9

ldp x19, x20, [sp, 0x40]
ldp x21, x22, [sp, 0x50]
ldp x23, x24, [sp, 0x60]
ldp x25, x26, [sp, 0x70]
ldp x27, x28, [sp, 0x80]
ldp fp,   lr, [sp, 0x90]
add sp, sp, 0xa0
ret

# The collector entry installed by valk_gc_set_entry(callback)
.data
.p2align 3
valk_gc_entry:
.quad 0
.text

.global _valk_gc_set_entry
_valk_gc_set_entry:
.global valk_gc_set_entry
valk_gc_set_entry:
adrp x9, valk_gc_entry@PAGE
add x9, x9, valk_gc_entry@PAGEOFF
str x0, [x9]
ret

# valk_gc_collect(): called straight from user code, so no frame of the
# runtime sits between the caller and the register capture. Pushes the
# callee-saved registers and calls the entry with the stack pointer
.global _valk_gc_collect
_valk_gc_collect:
.global valk_gc_collect
valk_gc_collect:

sub sp, sp, 0xa0
stp d8,   d9, [sp, 0x00]
stp d10, d11, [sp, 0x10]
stp d12, d13, [sp, 0x20]
stp d14, d15, [sp, 0x30]
stp x19, x20, [sp, 0x40]
stp x21, x22, [sp, 0x50]
stp x23, x24, [sp, 0x60]
stp x25, x26, [sp, 0x70]
stp x27, x28, [sp, 0x80]
stp fp,   lr, [sp, 0x90]

adrp x9, valk_gc_entry@PAGE
add x9, x9, valk_gc_entry@PAGEOFF
ldr x9, [x9]
mov x0, sp
blr x9

ldp x19, x20, [sp, 0x40]
ldp x21, x22, [sp, 0x50]
ldp x23, x24, [sp, 0x60]
ldp x25, x26, [sp, 0x70]
ldp x27, x28, [sp, 0x80]
ldp fp,   lr, [sp, 0x90]
add sp, sp, 0xa0
ret
