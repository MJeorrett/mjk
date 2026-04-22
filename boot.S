/* boot_lock in .data so the loaded image is 0 (BSS is not zero-filled by the linker for NOBITS). */
.section .data
.align 4                        // Required for clean ldxr / stlxr to this address.
boot_lock:
    .word 0

.section .text.boot
.global _start

_start:
    msr daifset, #0xf           // No exceptions handled at the moment, only interrupts.

    /*
     * Qemu can run all 4 vCPUs from the same entry; all may report the same
     * MPIDR_EL1 so we don't try to distinguish using this.  First to succeed at the exclusive store runs primary boot;
     * others wait in WFE.  (ldxr / stlxr, not a spin mutex.)
     */
    ldr   x0, =boot_lock        // Load the address of the boot lock into x0 (general purpose register).
    
1:
    ldxr  w1, [x0]              // Exclusive load of the 32-bit value at address x0 (boot_lock) into register w1.
    cbnz  w1, park              // If the value is not zero, branch to park.
    mov   w1, #1                // Set the value to 1.
    stlxr w2, w1, [x0]          // Exclusive store of the 32-bit value 1 at address x0 (boot_lock) into register w2.
    cbnz  w2, 1b                // If the store failed, branch to 1.
    b     primary               // Branch to primary.

park:
    wfe
    b     park

primary:
    ldr x0, =stack_top
    mov sp, x0
    bl  kernel_main

hang:
    wfe
    b   hang

.section .bss
.align 16
.space 0x10000
stack_top:
