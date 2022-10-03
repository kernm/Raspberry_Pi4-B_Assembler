.global	_start

.equ GPIO_BASE, 0xFE200000
.equ GPFSEL2, 0x08

.equ GPIO_24_OUTPUT, 0x1000

.equ GPFSET0, 0x1c //# Power 1 (LED power)
.equ GPFCLR0, 0x28 //# Power 0 (LED power off)

.equ GPIOVAL, 0x1000000

_start:
    mrs x1, mpidr_el1        /* move register system (MPIDR_EL1, Multiprocessor Affinity Register, EL1) to x1 */
    and x1, x1, #3           /* and operation: x1 = x1 and 3 (#3 = decimal 3) 0b11 */
    cbz x1, 2f               /* check x1 not zero -> jump to 2: (2f -> 2: forward)   cbz: call branch on zero? */

1:  /* We're _not_ on the main core, so hang in an infinite wait loop */
	wfe                      /* wait for event */
    b   1b                   /* jump to 1: (1b -> 1: backward)  b: branch (Lazy loop) */

2:  /* We're on the main core! */
	mov	sp, #0x80000

	mrs x3, CNTFRQ_EL0       /* Read frequency of system counter (read hz) */
    ldr x0,=0xFE200000       /* Basis adresse in x0 speichern */

    mov w1,#0x1000           /* Bit 12(13) setzen */
    str w1,[x0,#0x08]        /* FSEL2(SELECT) (funktion wählen) */

//    mov w1,#0x1000000        /* Bit 24 (25) setzen */
//    str w1,[x0,#0x1c]        /* SET (voltage setzen) */

    #set counter
    ldr x22, =0x300000 
    ldr x23, =0x100000
    ldr x24, =0x800000
    ldr x25, =0xf00000

    mov x26, 4 
    mov x27, 4 

main:
    bl loop_kurz
    mov x26, 4
    bl loop_lang
    mov x27, 4
    bl loop_kurz
    mov x26, 4
    bl wait_timer
    bl main

wait_timer:
   # wait for some time, delay
    eor x10, x10, x10
    delay5:
        add x10, x10, #1
        cmp x10, x25
        bne delay5
    ret

loop_kurz:
    #turn on the LED
    ldr w1, = GPIOVAL ;//# value to write to set register
    str w1, [x0, #GPFSET0] ;//# store in set register

    # wait for some time, delay
    eor x10, x10, x10

    delay1:
        add x10, x10, #1
        cmp x10, x22
        bne delay1

    # turn off the LED
    ldr w1, =GPIOVAL ;//# value to write to set register
    str w1, [x0, #GPFCLR0] ;//# store in set register

    # wait for some time, delay
    eor x10, x10, x10
    delay2:
        add x10, x10, #1
        cmp x10, x23
        bne delay2
sub x26, x26, #1 ;//# decrement the value of count1 by 1
cmp x26, 1
bne loop_kurz
ret

loop_lang:
    #turn on the LED
    ldr w1, = GPIOVAL ;//# value to write to set register
    str w1, [x0, #GPFSET0] ;//# store in set register

    # wait for some time, delay
    eor x10, x10, x10

    delay3:
        add x10, x10, #1
        cmp x10, x24
        bne delay3

    # turn off the LED
    ldr w1, =GPIOVAL ;//# value to write to set register
    str w1, [x0, #GPFCLR0] ;//# store in set register

    # wait for some time, delay
    eor x10, x10, x10
    delay4:
        add x10, x10, #1
        cmp x10, x23
        bne delay4
sub x27, x27, #1 ;//# decrement the value of count1 by 1
cmp x27, 1
bne loop_lang
ret
