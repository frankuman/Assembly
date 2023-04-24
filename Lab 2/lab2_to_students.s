/******************************************************************************
    Define symbols
******************************************************************************/

// Proposed interrupt vector base address
.equ INTERRUPT_VECTOR_BASE, 0x00000000

// Proposed stack base addresses
.equ SVC_MODE_STACK_BASE, 0x3FFFFFFF - 3 // set SVC stack to top of DDR3 memory
.equ IRQ_MODE_STACK_BASE, 0xFFFFFFFF - 3 // set IRQ stack to A9 onchip memory

// GIC Base addresses
.equ GIC_CPU_INTERFACE_BASE, 0xFFFEC100
.equ GIC_DISTRIBUTOR_BASE, 0xFFFED000

// Other I/O device base addresses
.equ RED_LIGHT, 0xFF200000 //FF200000 - FF20000F
.equ BUTTON_1, 0xFF200050 //FF200050 - FF20005F
/* Data section, for global data/variables if needed. */
.data
hexValues: 
    .byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07
    .byte 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71
R11_value: .word 1

my_device_base_address:
    .word 0xFF200020
/* Code section */
.text

/*****************************************************************************
    Interrupt Vector
*****************************************************************************/

// Write your Interrupt Vector here
.section .vectors, "ax"
    B _start // reset vector
    B SERVICE_UND // undefined instruction vector
    B SERVICE_SVC // software interrrupt vector
    B SERVICE_ABT_INST // aborted prefetch vector
    B SERVICE_ABT_DATA // aborted data vector
	.word 0 // unused vector
    PUSH {R0-R11,R12, LR}
    BL SERVICE_IRQ // IRQ interrupt vector
    LDR R0, =0xFF200050 // base address of pushbutton KEY port
    LDR R1, [R0, #0xC] // read edge capture register
    MOV R2, #0xF
    STR R2, [R0, #0xC] // clear the interrupt
    LDR R0, =0xFF200020 // based address of HEX display
    ANDS R3, R3, R1 // check for KEY0
    LDR R11, =R11_value
    LDR R9, [R11]
    LDRB R4, [R12, R9]
    STR R4,[R0]
    ADD R9, #1
    STR R9, [R11]
    MOV R10,#0
    POP {R0-R11,R12, LR}
    SUBS PC, LR, #4
	
	
.global _start

_start:
        //1. Setup stack pointers for each used processor mode'
    MOV R1, #0b11010010 // interrupts masked, MODE = IRQ
    MSR CPSR_c, R1 // change to IRQ mode
    LDR SP, =0xFFFFFFFF - 3 // set IRQ stack to A9 onchip memory
    /* Change to SVC (supervisor) mode with interrupts disabled */
    MOV R1, #0b11010011 // interrupts masked, MODE = SVC
    MSR CPSR, R1 // change to supervisor mode
    LDR SP, =0x3FFFFFFF - 3 // set SVC stack to top of DDR3 memory
    
    //2. Configure the Generic Interrupt Controller (GIC). Use the given help function CONFIG_GIC!
    BL CONFIG_GIC

    //3. Configure the used I/O devices and enable them for interrupt
    LDR R0, =BUTTON_1 // pushbutton KEY base address
    MOV R1, #0xF // set interrupt mask bits
    STR R1, [R0, #0x8] // interrupt mask register (base + 8)
    
    //4. Change to the processor mode for the main program loop (for example supervisor mode)
    MRS r0, CPSR
    STMFD sp!, {r0}
    MSR CPSR_c, #0x13

    //5. Enable the processor interrupts (IRQ in our case)
    MOV R0, #0b01010011 // IRQ unmasked, MODE = SVC
    MSR CPSR_c, R0
     //wait for interupt
    MOV R10, #0
    LDR R12, =hexValues

/*******************************************************************
Main program
*******************************************************************/

MAIN:
	B MAIN
	


/* Define the exception service routines */
/*--- Undefined instructions --------------------------------------------------*/
SERVICE_UND:
    B SERVICE_UND
/*--- Software interrupts -----------------------------------------------------*/
SERVICE_SVC:
    B SERVICE_SVC
/*--- Aborted data reads ------------------------------------------------------*/
SERVICE_ABT_DATA:
    B SERVICE_ABT_DATA
/*--- Aborted instruction fetch -----------------------------------------------*/
SERVICE_ABT_INST:
    B SERVICE_ABT_INST
/*--- IRQ ---------------------------------------------------------------------*/

SERVICE_IRQ:
    PUSH {R4-R5, LR}

    /* Save the value of R10 on the stack */
    /* Read the ICCIAR from the CPU Interface */
    LDR R4, =0xFFFEC100
    LDR R5, [R4, #0x0C] // read from ICCIAR
FPGA_IRQ1_HANDLER:
    CMP R5, #73
UNEXPECTED:
    BNE UNEXPECTED // if not recognized, stop here
EXIT_IRQ:
    /* Write to the End of Interrupt Register (ICCEOIR) */
    STR R5, [R4, #0x10] // write to ICCEOIR
    /* Restore the value of R10 from the stack */
    POP {R4-R5, LR}
    BX LR



/****************************************************************************
    Other Interrupt Service Routines (except for IRQ)
    -------------------------------------------------
    
Other interrupts are unused in this program, but should at least be defined.
These interrupt routines can just "idle" if ever called...

****************************************************************************/
// Write code for your other interrupt service routines here

//why


/*******************************************************************
    HELP FUNCTION!
    --------------

Configures the Generic Interrupt Controller (GIC)
    Arguments:  R0: Interrupt ID

*******************************************************************/
CONFIG_GIC:
    PUSH {LR}
    /* To configure a specific interrupt ID:
    * 1. set the target to cpu0 in the ICDIPTRn register
    * 2. enable the interrupt in the ICDISERn register */
    /* CONFIG_INTERRUPT (int_ID (R0), CPU_target (R1)); */
    MOV R0, #73 // KEY port (Interrupt ID = 73)
    MOV R1, #1 // this field is a bit-mask; bit 0 targets cpu0
    BL CONFIG_INTERRUPT
    /* configure the GIC CPU Interface */
    LDR R0, =GIC_CPU_INTERFACE_BASE // base address of CPU Interface, 0xFFFEC100
    /* Set Interrupt Priority Mask Register (ICCPMR) */
    LDR R1, =0xFFFF // enable interrupts of all priorities levels
    STR R1, [R0, #0x04]
    /* Set the enable bit in the CPU Interface Control Register (ICCICR).
    * This allows interrupts to be forwarded to the CPU(s) */
    MOV R1, #1
    STR R1, [R0]
    /* Set the enable bit in the Distributor Control Register (ICDDCR).
    * This enables forwarding of interrupts to the CPU Interface(s) */
    LDR R0, =GIC_DISTRIBUTOR_BASE   // 0xFFFED000
    STR R1, [R0]
    POP {PC}


/*********************************************************************
    HELP FUNCTION!
    --------------

Configure registers in the GIC for an individual Interrupt ID.

We configure only the Interrupt Set Enable Registers (ICDISERn) and
Interrupt Processor Target Registers (ICDIPTRn). The default (reset)
values are used for other registers in the GIC.

Arguments:  R0 = Interrupt ID, N
            R1 = CPU target

*********************************************************************/
CONFIG_INTERRUPT:
    PUSH {R4-R5, LR}
    /* Configure Interrupt Set-Enable Registers (ICDISERn).
    * reg_offset = (integer_div(N / 32) * 4
    * value = 1 << (N mod 32) */
    LSR R4, R0, #3 // calculate reg_offset
    BIC R4, R4, #3 // R4 = reg_offset
    LDR R2, =0xFFFED100 // Base address of ICDISERn
    ADD R4, R2, R4 // R4 = address of ICDISER
    AND R2, R0, #0x1F // N mod 32
    MOV R5, #1 // enable
    LSL R2, R5, R2 // R2 = value
    /* Using the register address in R4 and the value in R2 set the
    * correct bit in the GIC register */
    LDR R3, [R4] // read current register value
    ORR R3, R3, R2 // set the enable bit
    STR R3, [R4] // store the new register value
    /* Configure Interrupt Processor Targets Register (ICDIPTRn)
    * reg_offset = integer_div(N / 4) * 4
    * index = N mod 4 */
    BIC R4, R0, #3 // R4 = reg_offset
    LDR R2, =0xFFFED800 // Base address of ICDIPTRn
    ADD R4, R2, R4 // R4 = word address of ICDIPTR
    AND R2, R0, #0x3 // N mod 4
    ADD R4, R2, R4 // R4 = byte address in ICDIPTR
    /* Using register address in R4 and the value in R2 write to
    * (only) the appropriate byte */
    STRB R1, [R4]
    POP {R4-R5, PC}

.end
	