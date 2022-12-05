.global	_start
 
/* Substitute a value to a label */

.equ GPIO_BASE, 0xFE200000
.equ GPFSEL1, 0x04 /* GPIO Function Select 1 */
.equ GPFSEL2, 0x08 /* GPIO Function Select 2 */

.equ GPIO_10_OUTPUT, 0x1
.equ GPIO_20_OUTPUT, 0x1
.equ GPIO_21_OUTPUT, 0x8
.equ GPIO_22_OUTPUT, 0x40
.equ GPIO_23_OUTPUT, 0x200
.equ GPIO_24_OUTPUT, 0x1000
.equ GPIO_25_OUTPUT, 0x8000
.equ GPIO_26_OUTPUT, 0x40000
.equ GPIO_27_OUTPUT, 0x200000

.equ GPFSET0, 0x1c //# Power 1 (LED power on)
.equ GPFCLR0, 0x28 //# Power 0 (LED power off)

.equ GPIOVAL_10, 0x400 /* Set bit 10 for GPIO10 */
.equ GPIOVAL_20, 0x100000 /* Set bit 20 for GPIO20 */
.equ GPIOVAL_21, 0x200000 /* Set bit 21 for GPIO21 */
.equ GPIOVAL_22, 0x400000 /* Set bit 22 for GPIO22 */
.equ GPIOVAL_23, 0x800000 /* Set bit 23 for GPIO23 */
.equ GPIOVAL_24, 0x1000000 /* Set bit 24 for GPIO24 */
.equ GPIOVAL_25, 0x2000000 /* Set bit 25 for GPIO25 */
.equ GPIOVAL_26, 0x4000000 /* Set bit 26 for GPIO26 */
.equ GPIOVAL_27, 0x8000000 /* Set bit 27 for GPIO27 */

_start:
    mrs x1, mpidr_el1        /* move register system (MPIDR_EL1, Multiprocessor Affinity Register, EL1) to x1 */
    and x1, x1, #3           /* and operation: x1 = x1 and 3 (#3 = decimal 3) 0b11 */
    cbz x1, 2f               /* check x1 not zero -> jump to 2: (2f -> 2: forward)   cbz: call branch on zero? */

1:  /* We're _not_ on the main core, so hang in an infinite wait loop */
	wfe                      /* wait for event */
    b   1b                   /* jump to 1: (1b -> 1: backward)  b: branch (Lazy loop) */

2:  /* We're on the main core! */
	mov	sp, #0x80000

3: /* Set GPIOs as Output*/
    ldr x0, = GPIO_BASE		/* set GPIO Base */

    mov w1, GPIO_10_OUTPUT	/* GPIO Output 10 */
    mov w2, GPIO_20_OUTPUT	/* GPIO Output 20 */
    orr w2, w2, GPIO_21_OUTPUT	/* GPIO Output 11 */
    orr w2, w2, GPIO_22_OUTPUT	/* GPIO Output 12 */
    orr w2, w2, GPIO_23_OUTPUT	/* GPIO Output 13 */
    orr w2, w2, GPIO_24_OUTPUT	/* GPIO Output 14 */
    orr w2, w2, GPIO_25_OUTPUT	/* GPIO Output 15 */
    orr w2, w2, GPIO_26_OUTPUT	/* GPIO Output 16 */
    orr w2, w2, GPIO_27_OUTPUT	/* GPIO Output 17 */
    
    str w1,[x0, GPFSEL1]        /* FSEL1(SELECT) (set the GPIO to output) */
    str w2,[x0, GPFSEL2]        /* FSEL2(SELECT) (set the GPIO to output) */

main:
    bl s
    bl o
    bl s
    bl wait_long
    b main

/* Define Brakes */

wait_short:
.initTimer:                  /* Start of Timer */

    stp x29, x30, [sp, -32]!  /* Store Pair of Registers, in this case the sp = stack pointer */
                              /*  x29 = frame pointer, x30 = link register
                                The memory location where the two values are stored is computed as sp -32
                                The ! at the end updates the sp to the computed value*/
    mov x29, sp               /* store stack pointer.
                                At this point the stack pointer and the frame pointer are referring to the same memory address.*/
 
    .equ short_Time, 250    /* Defines the wait time in ms */
    mov x4, short_Time      /* Move short_time to x4 for 500ms wait */

    mrs x3, CNTFRQ_EL0       /* Read frequency of system counter (read hz) */
    mov x2, 1000             /* Set x2 to 1000 (to divide frequency in ms) */
    sdiv x3, x3, x2          /* Divide the Frequency of the System Counter by 1000, to deal with it in ms */

    mul x5, x3, x4          /* multiply the x3 (System counter in HZ /1000) by set wait time in ms from x4*/
    msr CNTP_TVAL_EL0, x5  /* Write a comparator value to CNTP_TVAL_EL0, a 64-bit register. */
    mov x1, #1               /* Write 1 to x1, to enable counter */
    msr CNTP_CTL_EL0, x1    /* Enable the counter and interrupt generation*/
.readTimer:                  /* See if the timer condition is met */
    mrs x5, CNTP_CTL_EL0    /* Read the Status of the Timer */
    and x5, x5, 0b100         /* See if x5 equals 0b1 (timer condition is met) */
    cbz x5, .readTimer      /* If x3 is 0 (Timer condition is not met) go to .readTimer */
    ldp x29, x30, [sp], 32    /* restore context... */

    ret                     /* Timer condition is met, go back*/

wait_long:
stp x29, x30, [sp, -32]! 
mov x29, sp 
	bl wait_short
	bl wait_short
ldp x29, x30, [sp], 32 
ret

/* Turn LED ON or OFF */

led_on:
    ldr x0, = GPIO_BASE       /* Basis adresse in x0 speichern */
    ldr w1, = GPIOVAL_10 ;//# value to write to set register
    str w1, [x0, #GPFSET0] ;//# store in set register
ret

led_off:
    ldr x0, = GPIO_BASE      /* Basis adresse in x0 speichern */
    ldr w1, = GPIOVAL_10 ;//# value to write to set register
    str w1, [x0, #GPFCLR0] ;//# store in set register
ret

/* Turn on each Segment */

seg_A_on:
    ldr x0, = GPIO_BASE       /* Basis adresse in x0 speichern */
    ldr w2, = GPIOVAL_20 ;//# value to write to set register
    str w2, [x0, #GPFSET0] ;//# store in set register
ret

seg_B_on:
    ldr x0, = GPIO_BASE       /* Basis adresse in x0 speichern */
    ldr w2, = GPIOVAL_21 ;//# value to write to set register
    str w2, [x0, #GPFSET0] ;//# store in set register
ret

seg_C_on:
    ldr x0, = GPIO_BASE       /* Basis adresse in x0 speichern */
    ldr w2, = GPIOVAL_22 ;//# value to write to set register
    str w2, [x0, #GPFSET0] ;//# store in set register
ret

seg_D_on:
    ldr x0, = GPIO_BASE       /* Basis adresse in x0 speichern */
    ldr w2, = GPIOVAL_23 ;//# value to write to set register
    str w2, [x0, #GPFSET0] ;//# store in set register
ret
seg_E_on:
    ldr x0, = GPIO_BASE       /* Basis adresse in x0 speichern */
    ldr w2, = GPIOVAL_24 ;//# value to write to set register
    str w2, [x0, #GPFSET0] ;//# store in set register
ret

seg_F_on:
    ldr x0, = GPIO_BASE       /* Basis adresse in x0 speichern */
    ldr w2, = GPIOVAL_25 ;//# value to write to set register
    str w2, [x0, #GPFSET0] ;//# store in set register
ret
seg_G_on:
    ldr x0, = GPIO_BASE       /* Basis adresse in x0 speichern */
    ldr w2, = GPIOVAL_26 ;//# value to write to set register
    str w2, [x0, #GPFSET0] ;//# store in set registerw1
ret
seg_DP_on:
    ldr x0, = GPIO_BASE       /* Basis adresse in x0 speichern */
    ldr w2, = GPIOVAL_27 ;//# value to write to set register
    str w2, [x0, #GPFSET0] ;//# store in set register
ret

/* Turn off each Segment */

seg_A_off:
    ldr x0, = GPIO_BASE       /* Basis adresse in x0 speichern */
    ldr w2, = GPIOVAL_20 ;//# value to write to set register
    str w2, [x0, #GPFCLR0] ;//# store in set register
ret

seg_B_off:
    ldr x0, = GPIO_BASE       /* Basis adresse in x0 speichern */
    ldr w2, = GPIOVAL_21 ;//# value to write to set register
    str w2, [x0, #GPFCLR0] ;//# store in set register
ret

seg_C_off:
    ldr x0, = GPIO_BASE       /* Basis adresse in x0 speichern */
    ldr w2, = GPIOVAL_22 ;//# value to write to set register
    str w2, [x0, #GPFCLR0] ;//# store in set register
ret

seg_D_off:
    ldr x0, = GPIO_BASE       /* Basis adresse in x0 speichern */
    ldr w2, = GPIOVAL_23 ;//# value to write to set register
    str w2, [x0, #GPFCLR0] ;//# store in set register
ret

seg_E_off:
    ldr x0, = GPIO_BASE       /* Basis adresse in x0 speichern */
    ldr w2, = GPIOVAL_24 ;//# value to write to set register
    str w2, [x0, #GPFCLR0] ;//# store in set register
ret

seg_F_off:
    ldr x0, = GPIO_BASE       /* Basis adresse in x0 speichern */
    ldr w2, = GPIOVAL_25 ;//# value to write to set register
    str w2, [x0, #GPFCLR0] ;//# store in set register
ret

seg_G_off:
    ldr x0, = GPIO_BASE       /* Basis adresse in x0 speichern */
    ldr w2, = GPIOVAL_26 ;//# value to write to set register
    str w2, [x0, #GPFCLR0] ;//# store in set register
ret

seg_DP_off:
    ldr x0, = GPIO_BASE       /* Basis adresse in x0 speichern */
    ldr w2, = GPIOVAL_27 ;//# value to write to set register
    str w2, [x0, #GPFSET0] ;//# store in set register
ret

/* Define LED BLink Cycles short and long */

led_cycle_short:
stp x29, x30, [sp, -32]! 
mov x29, sp 
    bl led_on
    bl wait_short
    bl led_off
    bl wait_short
ldp x29, x30, [sp], 32
ret

led_cycle_long:
stp x29, x30, [sp, -32]! 
mov x29, sp 
    bl led_on
    bl wait_long
    bl led_off
    bl wait_short
ldp x29, x30, [sp], 32 
ret

/* 7-Segment Display Letters */

let_s_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_A_on
    bl seg_F_on
    bl seg_G_on
    bl seg_C_on
    bl seg_D_on
    ldp x29, x30, [sp], 32
    ret

let_s_off:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_A_off
    bl seg_F_off
    bl seg_G_off
    bl seg_C_off
    bl seg_D_off
    ldp x29, x30, [sp], 32
    ret

let_o_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_A_on
    bl seg_B_on
    bl seg_C_on
    bl seg_D_on
    bl seg_E_on
    bl seg_F_on
    ldp x29, x30, [sp], 32
    ret

let_o_off:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_A_off
    bl seg_B_off
    bl seg_C_off
    bl seg_D_off
    bl seg_E_off
    bl seg_F_off
    ldp x29, x30, [sp], 32
    ret

/* Morse Alphabet */

a: 
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl led_cycle_short
	bl led_cycle_long
    bl wait_short
	ldp x29, x30, [sp], 32
	ret
	
b:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl led_cycle_long
	bl led_cycle_short
	bl led_cycle_short
	bl led_cycle_short
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

c:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl led_cycle_long
	bl led_cycle_short
	bl led_cycle_long
	bl led_cycle_short
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

d:
	stp x29, x30, [sp, -32]! 
	mov x29, sp 
	bl led_cycle_long
	bl led_cycle_short
	bl led_cycle_short
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

e:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl led_cycle_short
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

f: 
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl led_cycle_short
	bl led_cycle_short
	bl led_cycle_long
	bl led_cycle_short
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

g:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl led_cycle_long
	bl led_cycle_long
	bl led_cycle_short
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

h:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl led_cycle_short
	bl led_cycle_short
	bl led_cycle_short
	bl led_cycle_short 
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

i:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl led_cycle_short
	bl led_cycle_short
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

j:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl led_cycle_short
	bl led_cycle_long
	bl led_cycle_long
	bl led_cycle_long
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

k:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl led_cycle_long
	bl led_cycle_short
	bl led_cycle_long
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

l:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl led_cycle_short
	bl led_cycle_long
	bl led_cycle_short
	bl led_cycle_short
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

m:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl led_cycle_long
	bl led_cycle_long
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

n:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl led_cycle_long
	bl led_cycle_short
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

o:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl let_o_on
	bl led_cycle_long
	bl led_cycle_long
	bl led_cycle_long
    bl let_o_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

p: 
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl led_cycle_short
	bl led_cycle_long
	bl led_cycle_long
	bl led_cycle_short
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

q:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl led_cycle_long
	bl led_cycle_long
	bl led_cycle_short
	bl led_cycle_long
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

r: 
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl led_cycle_short
	bl led_cycle_long
	bl led_cycle_short
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

s:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl let_s_on
	bl led_cycle_short
	bl led_cycle_short
	bl led_cycle_short
    bl let_s_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

t:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl led_cycle_long
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

u: 
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl led_cycle_short
	bl led_cycle_short
	bl led_cycle_long
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

v: 
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl led_cycle_short
	bl led_cycle_short
	bl led_cycle_short
	bl led_cycle_long
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

w:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl led_cycle_short
	bl led_cycle_long
	bl led_cycle_long
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

x:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl led_cycle_long
	bl led_cycle_short
	bl led_cycle_short
	bl led_cycle_long
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

y:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl led_cycle_long
	bl led_cycle_short
	bl led_cycle_long
	bl led_cycle_long
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

z:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl led_cycle_long
	bl led_cycle_long
	bl led_cycle_short
	bl led_cycle_short
    bl wait_short
	ldp x29, x30, [sp], 32
	ret