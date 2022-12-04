.global	_start

.equ GPIO_BASE, 0xFE200000
.equ GPFSEL2, 0x08

.equ GPIO_24_OUTPUT, 0x1000

.equ GPFSET0, 0x1c //# Power 1 (LED power on)
.equ GPFCLR0, 0x28 //# Power 0 (LED power off)

.equ GPIOVAL, 0x1000000 /* Was Passiert hier?????????????????????*/

_start:
    mrs x1, mpidr_el1        /* move register system (MPIDR_EL1, Multiprocessor Affinity Register, EL1) to x1 */
    and x1, x1, #3           /* and operation: x1 = x1 and 3 (#3 = decimal 3) 0b11 */
    cbz x1, 2f               /* check x1 not zero -> jump to 2: (2f -> 2: forward)   cbz: call branch on zero? */

1:  /* We're _not_ on the main core, so hang in an infinite wait loop */
	wfe                      /* wait for event */
    b   1b                   /* jump to 1: (1b -> 1: backward)  b: branch (Lazy loop) */

2:  /* We're on the main core! */
	mov	sp, #0x80000

	; mrs x3, CNTFRQ_EL0       /* Read frequency of system counter (read hz) */
    ; mov x2, 1000             /* Set x2 to 1000 (to divide frequency in ms) */
    ; sdiv x3, x3, x2          /* Divide the Frequency of the System Counter by 1000, to deal with it in ms */

    ldr x0,=0xFE200000       /* Basis adresse in x0 speichern */

    mov w1,#0x1000           /* Bit 12(13) setzen */
    str w1,[x0,#0x08]        /* FSEL2(SELECT) (funktion wählen) */

;    mov w1,#0x1000000        /* Bit 24 (25) setzen */
;    str w1,[x0,#0x1c]        /* SET (voltage setzen) */

main:
    bl led_on
    bl wait_short
    bl led_off
    bl wait_short
    bl main

wait_short:
.initTimer:                  /* Start of Time */
    stp x29, x30, [sp, -32]!  /* Store Pair of Registers, in this case the sp = stack pointer
                                x29 = frame pointer, x30 = link register
                                The memory location where the two values are stored is computed as sp -32
                                The ! at the end updates the sp to the computed value */
    mov x29, sp               /* store stack pointer.
                                At this point the stack pointer and the frame pointer are referring to the same memory address. */
  
  /* Braucht es vermutlich nicht, kann entfernt werden.... */
    str x0, [sp, 24]          /* push argument (timeout) on stack (what for?)
                               Callee-saved registers (AKA non-volatile registers, or call-preserved) are used to hold long-lived values that should be preserved across calls. */
  /* Ab hier brauchts den Code wieder ;) */

    .equ short_Time, 500    /* Defines the wait time in ms */
    mov x4, short_Time      /* Move short_time to x4 for 500ms wait */

    mrs x3, CNTFRQ_EL0       /* Read frequency of system counter (read hz) */
    mov x2, 1000             /* Set x2 to 1000 (to divide frequency in ms) */
    sdiv x3, x3, x2          /* Divide the Frequency of the System Counter by 1000, to deal with it in ms */

    mul x5, x3, x4          /* multiply the x3 (System counter in HZ /1000) by set wait time in ms from x4 */
    msr CNTP_TVAL_EL0, x5  /* Write a comparator value to CNTP_TVAL_EL0, a 64-bit register. */
    mov x1, #1               /* Write 1 to x1, to enable counter */
    msr CNTP_CTL_EL0, x1    /* Enable the counter and interrupt generation */

.readTimer:                  /* See if the timer condition is met */
    mrs x5, CNTP_CTL_EL0    /* Read the Status of the Timer */
    and x5, x5, 0b1         /* See if x5 equals 0b1 (timer condition is met) */
    cbz x5, .readTimer      /* If x3 is 0 (Timer condition is not met) go to .readTimer */

    ldp x29, x30, [sp], 32    /* load the old frame pointer and return address, and also move the stack pointer back up 32 bit */
ret                         /* Return to main */

led_on:
    ldr w1, = GPIOVAL       /* value to write to set register */
    str w1, [x0, #GPFSET0]  /* store in set register */
ret

led_off:
    ldr w1, =GPIOVAL        /* value to write to set register */
    str w1, [x0, #GPFCLR0]  /* store in set register */
ret