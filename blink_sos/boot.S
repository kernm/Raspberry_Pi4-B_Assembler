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
.initTimer:
    stp x29, x30, [sp, -32]!
    mov x29, sp 

    str x0, [sp, 24]

    .equ short_Time, 500
    mov x4, short_Time

    mrs x3, CNTFRQ_EL0
    mov x2, 1000
    sdiv x3, x3, x2

    mul x5, x3, x4
    msr CNTP_TVAL_EL0, x5
    mov x1, #1
    msr CNTP_CTL_EL0, x1

.readTimer:
    mrs x5, CNTP_CTL_EL0
    and x5, x5, 0b1
    cbz x5, .readTimer

    ldp x29, x30, [sp], 32
ret

led_on:
stp x29, x30, [sp, -16]!
mov x29, sp
ldr x0,=0xFE200000       /* Basis adresse in x0 speichern */
    ldr w1, = GPIOVAL       /* value to write to set register */
    str w1, [x0, #GPFSET0]  /* store in set register */
ldp x29, x30, [sp], 16
ret

led_off:
stp x29, x30, [sp, -16]!
mov x29, sp
ldr x0,=0xFE200000       /* Basis adresse in x0 speichern */
    ldr w1, =GPIOVAL        /* value to write to set register */
    str w1, [x0, #GPFCLR0]  /* store in set register */
ldp x29, x30, [sp], 16
ret