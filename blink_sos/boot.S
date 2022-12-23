.global	_start
 
/*-------------------------------*/
/* Substitute a value to a label */
/*-------------------------------*/

    .equ GPIO_BASE, 0xFE200000  /* Define the GPIO Base address */
    .equ GPFSEL1, 0x04          /* GPIO Function Select 1 */
    .equ GPFSEL2, 0x08          /* GPIO Function Select 2 */

/*--------------------------------------------------------------*/
/* Substitute the responding bits to define the GPIOs as Output */
/*--------------------------------------------------------------*/

    .equ GPIO_10_OUTPUT, 0x1
    .equ GPIO_20_OUTPUT, 0x1
    .equ GPIO_21_OUTPUT, 0x8
    .equ GPIO_22_OUTPUT, 0x40
    .equ GPIO_23_OUTPUT, 0x200
    .equ GPIO_24_OUTPUT, 0x1000
    .equ GPIO_25_OUTPUT, 0x8000
    .equ GPIO_26_OUTPUT, 0x40000
    .equ GPIO_27_OUTPUT, 0x200000

/*--------------------------------------------------------*/
/* Substitute the responding bits for GPFSET1 and GPFCLR0 */
/*--------------------------------------------------------*/

    .equ GPFSET0, 0x1c /* Power 1 (LED power on) */
    .equ GPFCLR0, 0x28 /* Power 0 (LED power off) */

/*---------------------------------------------------*/
/* Substitute the responding bits for each GPIO Port */
/*---------------------------------------------------*/

    .equ GPIOVAL_10, 0x400      /* Set bit 10 for GPIO10 */
    .equ GPIOVAL_20, 0x100000   /* Set bit 20 for GPIO20 */
    .equ GPIOVAL_21, 0x200000   /* Set bit 21 for GPIO21 */
    .equ GPIOVAL_22, 0x400000   /* Set bit 22 for GPIO22 */
    .equ GPIOVAL_23, 0x800000   /* Set bit 23 for GPIO23 */
    .equ GPIOVAL_24, 0x1000000  /* Set bit 24 for GPIO24 */
    .equ GPIOVAL_25, 0x2000000  /* Set bit 25 for GPIO25 */
    .equ GPIOVAL_26, 0x4000000  /* Set bit 26 for GPIO26 */
    .equ GPIOVAL_27, 0x8000000  /* Set bit 27 for GPIO27 */

/*-------------------*/
/* Starting sequence */
/*-------------------*/
    _start:
        mrs x1, mpidr_el1        /* move register system (MPIDR_EL1, Multiprocessor Affinity Register, EL1) to x1 */
        and x1, x1, #3           /* and operation: x1 = x1 and 3 (#3 = decimal 3) 0b11 */
        cbz x1, 2f               /* check x1 not zero -> jump to 2: (2f -> 2: forward)   cbz: Compare and Branch on Zero */

/*----------------------------------------------------------------*/
/* We're _not_ on the main core, so hang in an infinite wait loop */
/*----------------------------------------------------------------*/

    1:  
        wfe                      /* wait for event */
        b   1b                   /* jump to 1: (1b -> 1: backward)  b: branch (Lazy loop) */

/*-------------------------*/
/* We're on the main core! */
/*-------------------------*/

    2:  
        mov	sp, #0x80000 /* Define stack and load into stack pointer */

/*---------------------*/
/* Set GPIOs as Output */
/*---------------------*/

    3: 
        ldr x0, = GPIO_BASE		    /* set GPIO Base */

        mov w1, GPIO_10_OUTPUT	    /* GPIO Output 10 */
        mov w2, GPIO_20_OUTPUT	    /* GPIO Output 20 */
        orr w2, w2, GPIO_21_OUTPUT	/* GPIO Output 11 */
        orr w2, w2, GPIO_22_OUTPUT	/* GPIO Output 12 */
        orr w2, w2, GPIO_23_OUTPUT	/* GPIO Output 13 */
        orr w2, w2, GPIO_24_OUTPUT	/* GPIO Output 14 */
        orr w2, w2, GPIO_25_OUTPUT	/* GPIO Output 15 */
        orr w2, w2, GPIO_26_OUTPUT	/* GPIO Output 16 */
        orr w2, w2, GPIO_27_OUTPUT	/* GPIO Output 17 */
        
        str w1,[x0, GPFSEL1]        /* FSEL1(SELECT) (set the GPIO to output) */
        str w2,[x0, GPFSEL2]        /* FSEL2(SELECT) (set the GPIO to output) */

/*-----------*/
/* Main loop */
/*-----------*/

/*-----------------------------------------------------------------------------
   Change the content of the main loop as needed.
   Each letter of the latin alphabet is implemented and defined as subroutine. 
-------------------------------------------------------------------------------*/

main:
    bl s            /* Execute subroutines for letter "S". bl = Branch with Link */
    bl o            /* Execute subroutines for letter "O". bl = Branch with Link */
    bl s            /* Execute subroutines for letter "S". bl = Branch with Link */
    bl wait_long    /* Wait 500ms until we loop again */
    b main          /* Go back to main (infinity loop) b = Branch */

/*--------------------*/
/* Define wait timers */
/*--------------------*/

/*---------------------*/
/* Short Timer = 250ms */
/*---------------------*/

wait_short:
    .initTimer:                     /* Start of Timer */
        stp x29, x30, [sp, -32]!    /* Store Pair of Registers, in this case the sp = stack pointer */
                                    /* x29 = frame pointer, x30 = link register
                                       The memory location where the two values are stored is computed as sp -32
                                       The ! at the end updates the sp to the computed value */
        mov x29, sp                 /* store stack pointer.
                                       At this point the stack pointer and the frame pointer are referring to the same memory address. */
 
            .equ short_Time, 250    /* Defines the wait time in ms */
            mov x4, short_Time      /* Move short_time to x4 for 500ms wait */

            mrs x3, CNTFRQ_EL0      /* Read frequency of system counter (read hz) */
            mov x2, 1000            /* Set x2 to 1000 (to divide frequency in ms) */
            sdiv x3, x3, x2         /* Divide the Frequency of the System Counter by 1000, to deal with it in ms */

            mul x5, x3, x4          /* multiply the x3 (System counter in HZ /1000) by set wait time in ms from x4 */
            msr CNTP_TVAL_EL0, x5   /* Write a comparator value to CNTP_TVAL_EL0, a 64-bit register. */
            mov x1, #1              /* Write 1 to x1, to enable counter */
            msr CNTP_CTL_EL0, x1    /* Enable the counter and interrupt generation */
            
    .readTimer:                     /* See if the timer condition is met */
            mrs x5, CNTP_CTL_EL0    /* Read the Status of the Timer */
            and x5, x5, 0b100       /* See if x5 equals 0b100 (timer condition is met) */
            cbz x5, .readTimer      /* If x3 is 0 (Timer condition is not met) go to .readTimer */
        ldp x29, x30, [sp], 32      /* restore context... */

ret                                 /* Timer condition is met, go back */

/*--------------------*/
/* Long Timer = 500ms */
/*--------------------*/

wait_long:
    stp x29, x30, [sp, -32]! 
    mov x29, sp 
    bl wait_short           /* Wait 250ms */
    bl wait_short           /* Wait 250ms */
    ldp x29, x30, [sp], 32 
ret

/*--------------------*/
/* Turn LED ON or OFF */
/*--------------------*/

led_on:
    ldr x0, = GPIO_BASE         /* Store GPIO Base to x0 */
    ldr w1, = GPIOVAL_10        /* Value to write to set register */
    str w1, [x0, #GPFSET0]      /* Store in set register */
ret

led_off:
    ldr x0, = GPIO_BASE
    ldr w1, = GPIOVAL_10
    str w1, [x0, #GPFCLR0]
ret

/*----------------------*/
/* Turn on each Segment */
/*----------------------*/

seg_A_on:
    ldr x0, = GPIO_BASE
    ldr w2, = GPIOVAL_20
    str w2, [x0, #GPFSET0]
ret

seg_B_on:
    ldr x0, = GPIO_BASE
    ldr w2, = GPIOVAL_21
    str w2, [x0, #GPFSET0]
ret

seg_C_on:
    ldr x0, = GPIO_BASE
    ldr w2, = GPIOVAL_22
    str w2, [x0, #GPFSET0]
ret

seg_D_on:
    ldr x0, = GPIO_BASE
    ldr w2, = GPIOVAL_23
    str w2, [x0, #GPFSET0]
ret
seg_E_on:
    ldr x0, = GPIO_BASE
    ldr w2, = GPIOVAL_24
    str w2, [x0, #GPFSET0]
ret

seg_F_on:
    ldr x0, = GPIO_BASE
    ldr w2, = GPIOVAL_25
    str w2, [x0, #GPFSET0]
ret
seg_G_on:
    ldr x0, = GPIO_BASE
    ldr w2, = GPIOVAL_26
    str w2, [x0, #GPFSET0]
ret
seg_DP_on:
    ldr x0, = GPIO_BASE
    ldr w2, = GPIOVAL_27
    str w2, [x0, #GPFSET0]
ret

/*-----------------------*/
/* Turn off each Segment */
/*-----------------------*/

seg_A_off:
    ldr x0, = GPIO_BASE
    ldr w2, = GPIOVAL_20
    str w2, [x0, #GPFCLR0]
ret

seg_B_off:
    ldr x0, = GPIO_BASE
    ldr w2, = GPIOVAL_21
    str w2, [x0, #GPFCLR0]
ret

seg_C_off:
    ldr x0, = GPIO_BASE
    ldr w2, = GPIOVAL_22
    str w2, [x0, #GPFCLR0]
ret

seg_D_off:
    ldr x0, = GPIO_BASE
    ldr w2, = GPIOVAL_23
    str w2, [x0, #GPFCLR0]
ret

seg_E_off:
    ldr x0, = GPIO_BASE
    ldr w2, = GPIOVAL_24
    str w2, [x0, #GPFCLR0]
ret

seg_F_off:
    ldr x0, = GPIO_BASE
    ldr w2, = GPIOVAL_25
    str w2, [x0, #GPFCLR0]
ret

seg_G_off:
    ldr x0, = GPIO_BASE
    ldr w2, = GPIOVAL_26
    str w2, [x0, #GPFCLR0]
ret

seg_DP_off:
    ldr x0, = GPIO_BASE
    ldr w2, = GPIOVAL_27
    str w2, [x0, #GPFCLR0]
ret

/*----------------------------------------*/
/* Define LED BLink Cycles short and long */
/*----------------------------------------*/

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

/*----------------------------------*/
/* Define ABC for 7-Segment Display */
/*----------------------------------*/

let_a_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_A_on
    bl seg_B_on
    bl seg_C_on
    bl seg_E_on
    bl seg_F_on
	bl seg_G_on
    ldp x29, x30, [sp], 32
    ret

let_b_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl seg_C_on
    bl seg_D_on
    bl seg_E_on
    bl seg_F_on
	bl seg_G_on
    ldp x29, x30, [sp], 32
    ret

let_c_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_A_on
    bl seg_D_on
    bl seg_E_on
    bl seg_F_on
    ldp x29, x30, [sp], 32
    ret

let_d_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_B_on
	bl seg_C_on
    bl seg_D_on
    bl seg_E_on
	bl seg_G_on
    ldp x29, x30, [sp], 32
    ret

let_e_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_A_on
    bl seg_D_on
    bl seg_E_on
    bl seg_F_on
	bl seg_G_on
    ldp x29, x30, [sp], 32
    ret

let_f_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_A_on
    bl seg_E_on
    bl seg_F_on
	bl seg_G_on
    ldp x29, x30, [sp], 32
    ret

let_g_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_A_on
	bl seg_C_on
    bl seg_D_on
    bl seg_E_on
    bl seg_F_on
    ldp x29, x30, [sp], 32
    ret

let_h_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl seg_C_on
    bl seg_E_on
    bl seg_F_on
	bl seg_G_on
    ldp x29, x30, [sp], 32
    ret

let_i_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_E_on
    bl seg_F_on
    ldp x29, x30, [sp], 32
    ret

let_j_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_B_on
	bl seg_C_on
    bl seg_D_on
    ldp x29, x30, [sp], 32
    ret

let_k_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_A_on
	bl seg_C_on
    bl seg_E_on
    bl seg_F_on
	bl seg_G_on
    ldp x29, x30, [sp], 32
    ret

let_l_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_D_on
    bl seg_E_on
    bl seg_F_on
    ldp x29, x30, [sp], 32
    ret

let_m_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_A_on
	bl seg_C_on
    bl seg_E_on
	bl seg_G_on
    ldp x29, x30, [sp], 32
    ret

let_n_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl seg_C_on
    bl seg_E_on
	bl seg_G_on
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

let_p_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_A_on
    bl seg_B_on
    bl seg_E_on
    bl seg_F_on
	bl seg_G_on
    ldp x29, x30, [sp], 32
    ret

let_q_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_A_on
    bl seg_B_on
	bl seg_C_on
    bl seg_F_on
	bl seg_G_on
    ldp x29, x30, [sp], 32
    ret

let_r_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_E_on
	bl seg_G_on
    ldp x29, x30, [sp], 32
    ret

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

let_t_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_D_on
    bl seg_E_on
    bl seg_F_on
	bl seg_G_on
    ldp x29, x30, [sp], 32
    ret

let_u_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_B_on
    bl seg_C_on
    bl seg_D_on
    bl seg_E_on
    bl seg_F_on
    ldp x29, x30, [sp], 32
    ret

let_v_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_B_on
    bl seg_D_on
    bl seg_F_on
    ldp x29, x30, [sp], 32
    ret

let_w_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_B_on
    bl seg_D_on
    bl seg_F_on
    bl seg_G_on
    ldp x29, x30, [sp], 32
    ret

let_x_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_B_on
    bl seg_C_on
    bl seg_E_on
    bl seg_F_on
    bl seg_G_on
    ldp x29, x30, [sp], 32
    ret

let_y_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_B_on
    bl seg_C_on
    bl seg_D_on
    bl seg_F_on
    bl seg_G_on
    ldp x29, x30, [sp], 32
    ret

let_z_on:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_A_on
    bl seg_B_on
    bl seg_D_on
    bl seg_E_on
    bl seg_G_on
    ldp x29, x30, [sp], 32
    ret

seg_all_off:
    stp x29, x30, [sp, -32]! 
	mov x29, sp
    bl seg_A_off
    bl seg_B_off
    bl seg_C_off
    bl seg_D_off
    bl seg_E_off
    bl seg_F_off
	bl seg_G_off
    bl seg_DP_off
    ldp x29, x30, [sp], 32
    ret

/*-------------------------------*/
/* Define Morse Alphabet for LED */
/*-------------------------------*/

a: 
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl let_a_on
	bl led_cycle_short
	bl led_cycle_long
	bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret
	
b:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl let_b_on
	bl led_cycle_long
	bl led_cycle_short
	bl led_cycle_short
	bl led_cycle_short
	bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

c:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl let_c_on
	bl led_cycle_long
	bl led_cycle_short
	bl led_cycle_long
	bl led_cycle_short
	bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

d:
	stp x29, x30, [sp, -32]! 
	mov x29, sp 
	bl let_d_on
	bl led_cycle_long
	bl led_cycle_short
	bl led_cycle_short
	bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

e:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl let_e_on
	bl led_cycle_short
	bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

f: 
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl let_f_on
	bl led_cycle_short
	bl led_cycle_short
	bl led_cycle_long
	bl led_cycle_short
	bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

g:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl let_g_on
	bl led_cycle_long
	bl led_cycle_long
	bl led_cycle_short
	bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

h:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl let_h_on
	bl led_cycle_short
	bl led_cycle_short
	bl led_cycle_short
	bl led_cycle_short 
	bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

i:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl let_i_on
	bl led_cycle_short
	bl led_cycle_short
	bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

j:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl let_j_on
	bl led_cycle_short
	bl led_cycle_long
	bl led_cycle_long
	bl led_cycle_long
	bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

k:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl let_k_on
	bl led_cycle_long
	bl led_cycle_short
	bl led_cycle_long
	bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

l:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl let_l_on
	bl led_cycle_short
	bl led_cycle_long
	bl led_cycle_short
	bl led_cycle_short
	bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

m:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl let_m_on
	bl led_cycle_long
	bl led_cycle_long
	bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

n:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl let_n_on
	bl led_cycle_long
	bl led_cycle_short
	bl seg_all_off
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
    bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

p: 
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl let_p_on
	bl led_cycle_short
	bl led_cycle_long
	bl led_cycle_long
	bl led_cycle_short
	bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

q:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl let_q_on
	bl led_cycle_long
	bl led_cycle_long
	bl led_cycle_short
	bl led_cycle_long
	bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

r: 
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl let_r_on
	bl led_cycle_short
	bl led_cycle_long
	bl led_cycle_short
	bl seg_all_off
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
    bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

t:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl let_t_on
	bl led_cycle_long
	bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

u: 
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl let_u_on
	bl led_cycle_short
	bl led_cycle_short
	bl led_cycle_long
	bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

v: 
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl let_v_on
	bl led_cycle_short
	bl led_cycle_short
	bl led_cycle_short
	bl led_cycle_long
	bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

w:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl let_w_on
	bl led_cycle_short
	bl led_cycle_long
	bl led_cycle_long
	bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

x:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl let_x_on
	bl led_cycle_long
	bl led_cycle_short
	bl led_cycle_short
	bl led_cycle_long
	bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

y:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl let_y_on
	bl led_cycle_long
	bl led_cycle_short
	bl led_cycle_long
	bl led_cycle_long
	bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret

z:
	stp x29, x30, [sp, -32]! 
	mov x29, sp
	bl let_z_on
	bl led_cycle_long
	bl led_cycle_long
	bl led_cycle_short
	bl led_cycle_short
	bl seg_all_off
    bl wait_short
	ldp x29, x30, [sp], 32
	ret