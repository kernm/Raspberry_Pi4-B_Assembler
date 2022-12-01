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

	; mrs x3, CNTFRQ_EL0       /* Read frequency of system counter (read hz) */
    ; mov x2, 1000             /* Set x2 to 1000 (to divide frequency in ms) */
    ; sdiv x3, x3, x2          /* Divide the Frequency of the System Counter by 1000, to deal with it in ms */

    ldr x0,=0xFE200000       /* Basis adresse in x0 speichern */

    mov w1,#0x1000           /* Bit 12(13) setzen */
    str w1,[x0,#0x08]        /* FSEL2(SELECT) (funktion wählen) */

//    mov w1,#0x1000000        /* Bit 24 (25) setzen */
//    str w1,[x0,#0x1c]        /* SET (voltage setzen) */

    ; #set counter
    ; ldr x22, =0x300000 
    ; ldr x23, =0x100000
    ; ldr x24, =0x800000
    ; ldr x25, =0xf00000

    mov x26, 4 
    mov x27, 4 

main:
    bl loop_kurz
    bl loop_kurz
    bl loop_kurz
    mov x26, 4
    bl loop_lang
    mov x27, 4
    bl loop_kurz
    mov x26, 4
    bl wait_timer
    bl main

wait_short:
.initTimer:                  /* Start of Time */
    .equ short_Time, 500    /* Defines the wait time in ms */
    mov x4, short_Time      /* Move short_time to x4 for 500ms wait */

    mrs x3, CNTFRQ_EL0       /* Read frequency of system counter (read hz) */
    mov x2, 1000             /* Set x2 to 1000 (to divide frequency in ms) */
    sdiv x3, x3, x2          /* Divide the Frequency of the System Counter by 1000, to deal with it in ms */

    mul x5, x3, x4          /* multiply the x3 (System counter in HZ /1000) by set wait time in ms from x4*/
    msr CNTP_TVAL_EL0, x5  /* Write a comparator value to CNTP_CVAL_EL0, a 64-bit register. */

    msr CNTP_CTL_EL0, x5    /* Enable the counter and interrupt generation*/

.readTimer:                  /* See if the timer condition is met */
    mrs x5, CNTP_CTL_EL0    /* Read the Status of the Timer */
    and x5, x5, 0b100         /* See if x3 equals 0b1 (timer condition is met) */
    cbz x5, .readTimer      /* If x3 is 0 (Timer condition is not met) go to .readTimer */
    ret                     /* Timer condition is met, go back*/



; wait_timer:
;    # wait for some time, delay
;     eor x10, x10, x10
;     delay5:
;         add x10, x10, #1
;         cmp x10, x25
;         bne delay5
;     ret

loop_kurz:
    # turn on the LED
    ldr w1, = GPIOVAL ;//# value to write to set register
    str w1, [x0, #GPFSET0] ;//# store in set register
    bl wait_short
    ; # wait for some time, delay
    ; eor x10, x10, x10

    ; delay1:
    ;     add x10, x10, #1
    ;     cmp x10, x22
    ;     bne delay1

    # turn off the LED
    ldr w1, =GPIOVAL ;//# value to write to set register
    str w1, [x0, #GPFCLR0] ;//# store in set register

    # wait for some time, delay
;     eor x10, x10, x10
;     delay2:
;         add x10, x10, #1
;         cmp x10, x23
;         bne delay2
; sub x26, x26, #1 ;//# decrement the value of count1 by 1
; cmp x26, 1
; bne loop_kurz
    bl wait_short
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
