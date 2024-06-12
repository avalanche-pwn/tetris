.syntax unified
.cpu cortex-m0plus
.thumb

.section .data
@ RP2040 Section: 2.19.6.1. IO - User Bank
.equ IO_BANK0_BASE, 0x40014000
.equ IO_BANK0_GPIO_CTRL_BASE, IO_BANK0_BASE + 0x04

.equ FUNCSEL_SIO, 5
.equ GPIO_FUNCSEL, FUNCSEL_SIO
@ Init value specifing function 5 - SIO
.equ GPIO_INIT_VALUE, (GPIO_FUNCSEL<<0)

@ RP2040 Section: 2.19.6.3. Pad Control - User Bank
.equ PADS_BANK0_BASE, 0x4001c000 
.equ PADS_BANK0_GPIO_OFFSET, 0x04 
.equ PADS_BANK0_GPIO_BASE, PADS_BANK0_BASE + PADS_BANK0_GPIO_OFFSET
@ Bit 7 - OD Output disable. Has priority over output enable from peripherals RW 0x0
@ Bit 6 - IE Input enable RW 0x1
@ Bits 5:4 - DRIVE Drive strength.
@           0x0 → 2mA
@           0x1 → 4mA
@           0x2 → 8mA
@           0x3 → 12mA
@           RW 0x1
@ Bit 3 - PUE Pull up enable RW 0x0
@ Bit 2 - PDE Pull down enable RW 0x1
@ Bit 1 - SCHMITT Enable schmitt trigger RW 0x1
@ Bit 0 - SLEWFAST Slew rate control. 1 = Fast, 0 = Slow RW 0x0
@          bit nums:   76543210
.equ PAD_PULL_DOWN, 0b00010110
.equ PAD_IN, 0b01000000
.equ PAD_PULL_UP, 0b00011010

@ RP2040 Section: 2.3.1. SIO
@ 2.3.1.7. List of Registers
.equ SIO_BASE, 0xd0000000
.equ GPIO_IN, SIO_BASE + 0x4
.equ GPIO_OE,     SIO_BASE + 0x020 @ GPIO output enable
.equ GPIO_OE_SET, SIO_BASE + 0x024 @ GPIO output enable set
.equ GPIO_OE_CLR, SIO_BASE + 0x028 @ GPIO output enable clear
.equ GPIO_OE_XOR, SIO_BASE + 0x02c @ GPIO output enable XOR
.equ GPIO_OUT,     SIO_BASE + 0x010 @ GPIO output value
.equ GPIO_OUT_SET, SIO_BASE + 0x014 @ GPIO output value set
.equ GPIO_OUT_CLR, SIO_BASE + 0x018 @ GPIO output value clear
.equ GPIO_OUT_XOR, SIO_BASE + 0x01c @ GPIO output value XOR

.global init_gpio_pullup
.global gpio_read
.global gpio_read_all
.section .text
init_gpio_pullup:
    @ Input:
    @ r0 - LED number
    push    {r1-r3, LR}
    @ Usage:
    @ r1 - base addresses
    @ r2 - computed address offsets
    @ r3 - (computed) values to set in register

    @ init IO_BANK0 register
    ldr     r1, =IO_BANK0_GPIO_CTRL_BASE
    ldr     r3, =GPIO_INIT_VALUE    
    lsls    r2, r0, #3
    str     r3, [r1, r2]

    @ init PAD
    ldr     r1, =PADS_BANK0_GPIO_BASE
    ldr     r3, =#(PAD_PULL_UP | PAD_IN)    @ Load early to reduce stall cycles (Probably makes no difference on Cortex M0+!)
    lsls    r2, r0, #2      @ Multiply LED number by 4 as 4 bytes per registers
    str     r3, [r1, r2]

    pop     {r1-r3, PC}

.section .text
gpio_read:
    @r0 - gpio num
    push {r1-r3, lr}
    ldr r1, =GPIO_IN
    ldr r1, [r1]
    ands r0, r1
    pop {r1-r3, pc}
gpio_read_all:
    push {r1-r3, lr}
    movs r1, #1
    lsls r1, r0
    ldr r0, =GPIO_IN
    ldr r0, [r0]
    pop {r1-r3, pc}
