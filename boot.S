.section .text.boot
.global _start

_start:
    msr daifset, #0xf           // Disable interrups during startup.

    ldr x0, =stack_top          // Load stack pointer into general purpose register temporarily.
                                // You can't load immediate value directly into sp in ARM.
    mov sp, x0

    bl kernel_main

hang:
    wfe
    b hang

.section .bss
.align 16
.space 0x10000                  // Reserve 64kb stack.
stack_top: