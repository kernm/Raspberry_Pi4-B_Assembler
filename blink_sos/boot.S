.global	_start
 
.equ GPIO_BASE, 0xFE200000
.equ GPFSEL1, 0x04 /* GPIO Function Select 1 */
.equ GPFSEL2, 0x08 /* GPIO Function Select 2 */

.equ GPIO_24_OUTPUT, 0x1000
.equ GPIO_20_OUTPUT, 0x1

.equ GPFSET0, 0x1c //# Power 1 (LED power on)
.equ GPFCLR0, 0x28 //# Power 0 (LED power off)

.equ GPIOVAL_24, 0x1000000 /* Set bit 24 for GPIO24*/
.equ GPIOVAL_20, 0x100000 /* Set bit 20 for GPIO20*/


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

    mov w1, GPIO_24_OUTPUT	/* GPIO Output 24 */
    mov w2, GPIO_20_OUTPUT	/* GPIO Output 20 */
    
    str w1,[x0, GPFSEL1]        /* FSEL1(SELECT) (set the GPIO to output) */
    str w2,[x0, GPFSEL2]        /* FSEL2(SELECT) (set the GPIO to output) */

main:
    bl led_on
    bl seg_A_on
    bl wait_long
    bl led_off
    bl seg_A_off
    b main

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

led_on:
    ldr x0, = GPIO_BASE       /* Basis adresse in x0 speichern */
    ldr w1, = GPIOVAL_24 ;//# value to write to set register
    str w1, [x0, #GPFSET0] ;//# store in set register
ret

led_off:
    ldr x0, = GPIO_BASE      /* Basis adresse in x0 speichern */
    ldr w1, = GPIOVAL_24 ;//# value to write to set register
    str w1, [x0, #GPFCLR0] ;//# store in set register
ret

seg_A_on:
    ldr x0, = GPIO_BASE       /* Basis adresse in x0 speichern */
    ldr w2, = GPIOVAL_20 ;//# value to write to set register
    str w2, [x0, #GPFSET0] ;//# store in set register
ret

seg_A_off:
    ldr x0, = GPIO_BASE       /* Basis adresse in x0 speichern */
    ldr w2, = GPIOVAL_20 ;//# value to write to set register
    str w2, [x0, #GPFCLR0] ;//# store in set register
ret

wait_long:
stp x29, x30, [sp, -32]! 
mov x29, sp 
	bl wait_short
	bl wait_short
ldp x29, x30, [sp], 32 
ret

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

/* Morse Alphabet*/

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
	bl led_cycle_long
	bl led_cycle_long
	bl led_cycle_long
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
    bl seg_A_on
	bl led_cycle_short
	bl led_cycle_short
	bl led_cycle_short
    bl seg_A_off
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