.syntax unified
.cpu cortex-m0plus
.thumb
.section .data
.global uart_init2
.global serial_init
.global serial_write
.global serial_read
.global serial_readline
.global serial_flush
.global setupClocks
.global resetSubsys
.global configUart
.global initUart
.equ RESETS_BASE, 0x4000C000
.equ RESETS_RESET, RESETS_BASE + 0x00
.equ RESETS_WDSEL, RESETS_BASE + 0x08
.equ RESETS_RESET_DONE, RESETS_BASE + 0x10

.equ PADS_BANK0_BASE, 0x4001C000
.equ PADS_BANK0_GPIO0_CTRL, PADS_BANK0_BASE + 0x04

.equ IO_BANK0_BASE,    0x40014000
.equ IO_BANK0_GPIO00_CTRL, IO_BANK0_BASE + 0x04
.equ IO_BANK0_GPIO01_CTRL, IO_BANK0_BASE + 0x0C
.equ IO_BANK0_GPIO25_CTRL, IO_BANK0_BASE + 0xCC

.equ SIO_BASE,         0xD0000000
.equ SIO_GPIO_OE_SET,  SIO_BASE + 0x24

.equ UART_BASE, 0x40034000
.equ UART_DR, UART_BASE + 0x00
.equ UART_FR, UART_BASE + 0x18
.equ UART0_UARTCR,     UART_BASE + 0x30
.equ UART0_UARTLCR_H, UART_BASE + 0x2C
.equ UART0_UARTIBRD,   UART_BASE + 0x24
.equ UART0_UARTFBRD,   UART_BASE + 0x28

.equ UART_BAUD, 115200

.equ CLOCKS_BASE, 0x40008000
.equ CLK_REF_CTRL, CLOCKS_BASE + 0x30
.equ CLK_REF_DIV, CLOCKS_BASE + 0x34
.equ CLK_SYS_CTRL, CLOCKS_BASE + 0x3C
.equ CLK_PERI_CTRL, CLOCKS_BASE + 0x48

.equ XOSC_BASE,        0x40024000
.equ XOSC_CTRL,        XOSC_BASE + 0x00
.equ XOSC_STATUS,      XOSC_BASE + 0x04
.equ XOSC_STARTUP,     XOSC_BASE + 0x0C

.section .text
setupClocks:
    push {r0-r4, lr}

    @ Enable the XOSC
    ldr r0, =XOSC_CTRL
    movs r1, #0xAA      @ Frequency range: 1-15MHz
    lsls r1, #4
    str r1, [r0]

    ldr r0, =XOSC_STARTUP
    movs r1, #0xC4       @ Startup delay (default value)
    str r1, [r0]

    ldr r0, =XOSC_CTRL
    ldr r1, =0xFAB000   @ Enable magic word
    movs r2, #0x20
    lsls r2, #8
    orrs r0, r0, r2 @ SET bit
    str r1, [r0]

wait_xosc_ready:
    ldr r0, =XOSC_STATUS
    ldr r1, [r0]
    movs r4, #0x80
    lsls r4, #24
    tst r1, r4 @ Check if oscillator is running and stable
    beq wait_xosc_ready

    @ Set the XOSC as source clock for REF, SYS, and Peripherals
    ldr r0, =CLK_REF_CTRL
    movs r1, #2          @ CLK REF source = xosc_clksrc
    str r1, [r0]

    ldr r0, =CLK_SYS_CTRL
    movs r1, #0          @ CLK SYS source = clk_ref
    str r1, [r0]

    ldr r0, =CLK_REF_DIV
    movs r1, #1   @ CLK REF Divisor = 1
    LSLS r1, #8
    str r1, [r0]

    ldr r0, =CLK_PERI_CTRL
    movs r1, 1
    lsls r1, #11
    movs r4, #(4 << 5)   @ AUX SRC = xosc_clksrc
    orrs r1, r1, r4
    str r1, [r0]

    pop {r0-r4, pc}
resetSubsys:
    push {r0-r2, lr}

    @ Reset IO Bank
    ldr r0, =RESETS_RESET
    movs r2, #0x30
    lsls r2, #8
    orrs r0, r0, r2
    movs r1, #(1 << 5)
    str r1, [r0]
    ldr r0, =RESETS_RESET_DONE
wait_io_reset:
    ldr r1, [r0]
    movs r2, #(1 << 5)
    tst r1, r2
    beq wait_io_reset

    @ Reset PADS BANK
    ldr r0, =RESETS_RESET
    movs r2, #0x30
    lsls r2, #8
    orrs r0, r0, r2
    movs r1, 1
    lsls r1, #8
    str r1, [r0]
    ldr r0, =RESETS_RESET_DONE
wait_pads_reset:
    ldr r1, [r0]
    movs r2, 1
    lsls r2, #8
    tst r1, r2
    beq wait_pads_reset

    @ Reset UART0
    ldr r0, =RESETS_RESET
    movs r2, #0x30
    lsls r2, #8
    orrs r0, r0, r2
    movs r1, 1
    lsls r1, #22
    str r1, [r0]
    ldr r0, =RESETS_RESET_DONE
wait_uart_reset:
    ldr r1, [r0]
    movs r2, 1
    lsls r2, #22
    tst r1, r2
    beq wait_uart_reset

    pop {r0-r2, pc}

@ configUart functionf
configUart:
    push {r0-r2, lr}

    ldr r0, =UART0_UARTIBRD
    movs r1, #78
    str r1, [r0]

    ldr r0, =UART0_UARTFBRD
    movs r1, #8
    str r1, [r0]

    ldr r0, =UART0_UARTLCR_H
    movs r1, #(( 0x3 << 5 ) | ( 1 << 4 ))     @ 8-bit word length, 1 stop bit, no parity
    str r1, [r0]

    ldr r0, =UART0_UARTCR
    movs r1, #192
    lsls r1, #2
    movs r2, #( 1 << 0 ) @ UART Enable
    orrs r1, r2
    str r1, [r0]

    pop {r0-r2, pc}

@ initUart function
initUart:
    push {r0-r1, lr}

    bl setupClocks      @ Set up the clocks

    bl resetSubsys      @ Reset subsystems

    bl configUart       @ Configure UART

    @ Set GPIO0 and GPIO1 to function 2 (UART0)
    ldr r0, =IO_BANK0_GPIO00_CTRL
    movs r1, #2
    str r1, [r0]
    ldr r0, =IO_BANK0_GPIO01_CTRL
    movs r1, #2
    str r1, [r0]

    @ Set GPIO25 as SIO (F5) and GPIO OE
    ldr r0, =IO_BANK0_GPIO25_CTRL
    movs r1, #5
    str r1, [r0]
    ldr r0, =SIO_GPIO_OE_SET
    movs r1, 1
    lsls r1, 25
    str r1, [r0]

    pop {r0-r1, pc}

serial_write:
    push {r0-r1, lr}

_serial_write_wait:
    ldr r0, =UART_FR
    ldr r1, [r0]
    movs r2, #32
    ands r1, r2 @ Check TXFE bit
    cmp r1, #0
    bne _serial_write_wait
    pop {r0}
    ldr r1, =UART_DR
    str r0, [r1]

    pop {r1, pc}

serial_read:
    push {r0-r1, lr}

    ldr r1, =UART_DR
    ldr r0, [r1]

    pop {r0-r1, pc}

serial_readline:
    push {r0-r3, lr}

    movs r2, #0
    ldr r1, =UART_DR

read_loop:
    ldr r0, [r1]
    cmp r0, #0x0A  @ Check for newline character
    beq read_end
    strb r0, [r3, r2]
    adds r2, #1
    b read_loop

read_end:
    mov r0, r3
    pop {r0-r3, pc}

serial_flush:
    push {r0-r2, lr}

    ldr r0, =UART_FR
    ldr r1, [r0]
    movs r2, #0x10
    ands r1, r2 @ Check TXFE bit
    cmp r1, #0x10
    bne serial_flush

    pop {r0-r2, pc}