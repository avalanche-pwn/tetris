#include "defs.S"
.syntax unified
.cpu cortex-m0plus
.thumb
.section .data
.equ TIMER_BASE, 0x40054000
.equ TIMER_TIMERAWL, TIMER_BASE + 0x28
.equ DTR_GPIO, 2
.equ BTN_SHIFT_LEFT, 3
.equ BTN_SHIFT_RIGHT, 4
.equ BTN_ROTATE_LEFT, 5
.equ BTN_ROTATE_RIGHT, 6

button_prev_state: .4byte 0xffffffff

.global main
.section .text
.thumb_func
tetrimone=0
time=4
main:
    push {r4, lr}
    sub sp, #8
    movs r0, #DTR_GPIO
    bl init_gpio_pullup
_main_wait_usb:
    movs r0, #1
    ldr r1, =DTR_GPIO
    lsls r0, r1
    bl gpio_read
    bne _main_wait_usb
    bl initUart
    ldr r0, =BTN_SHIFT_LEFT
    bl init_gpio_pullup
    ldr r0, =BTN_SHIFT_RIGHT
    bl init_gpio_pullup
    ldr r0, =BTN_ROTATE_LEFT
    bl init_gpio_pullup
    ldr r0, =BTN_ROTATE_RIGHT
    bl init_gpio_pullup
    bl get_tetrimone
    str r0, [sp, #tetrimone]
    bl display

    ldr r1, =TIMER_TIMERAWL
    ldr r1, [r1]
    str r1, [sp, #time]
_main_loop:

    @check left_btn_clicked
    movs r0, #1
    movs r1, #BTN_SHIFT_LEFT
    lsls r0, r1
    movs r4, r0
    bl gpio_read
    movs r2, r0

    ldr r1, =button_prev_state
    ldr r3, [r1]
    movs r0, r4
    ands r0, r3
    cmp r0, r2
    beq _main_skip_released_left
    eors r3, r4
    str r3, [r1]
    cmp r2, #0
    beq _main_skip_released_left
    ldr r0, [sp, #tetrimone]
    bl check_shift_left
    ldr r0, [sp, #tetrimone]
    bl display
_main_skip_released_left:

    movs r0, #1
    movs r1, #BTN_SHIFT_RIGHT
    lsls r0, r1
    movs r4, r0
    bl gpio_read
    movs r2, r0

    ldr r1, =button_prev_state
    ldr r3, [r1]
    movs r0, r4
    ands r0, r3
    cmp r0, r2
    beq _main_skip_released_right
    eors r3, r4
    str r3, [r1]
    cmp r2, #0
    beq _main_skip_released_right
    ldr r0, [sp, #tetrimone]
    bl check_shift_right
    ldr r0, [sp, #tetrimone]
    bl display
_main_skip_released_right:

    movs r0, #1
    movs r1, #BTN_ROTATE_LEFT
    lsls r0, r1
    movs r4, r0
    bl gpio_read
    movs r2, r0

    ldr r1, =button_prev_state
    ldr r3, [r1]
    movs r0, r4
    ands r0, r3
    cmp r0, r2
    beq _main_skip_released_ror_left
    eors r3, r4
    str r3, [r1]
    cmp r2, #0
    beq _main_skip_released_ror_left
    ldr r0, [sp, #tetrimone]
    bl check_rotate_left
    str r0, [sp, #tetrimone]
    bl display
_main_skip_released_ror_left:

    movs r0, #1
    movs r1, #BTN_ROTATE_RIGHT
    lsls r0, r1
    movs r4, r0
    bl gpio_read
    movs r2, r0

    ldr r1, =button_prev_state
    ldr r3, [r1]
    movs r0, r4
    ands r0, r3
    cmp r0, r2
    beq _main_skip_released_ror_right
    eors r3, r4
    str r3, [r1]
    cmp r2, #0
    beq _main_skip_released_ror_right
    ldr r0, [sp, #tetrimone]
    bl check_rotate_right
    str r0, [sp, #tetrimone]
    bl display
_main_skip_released_ror_right:
    
    @r0 - last time
    @r2 - current time
    ldr r0, [sp, #time]
    ldr r1, =TIMER_TIMERAWL
    ldr r2, [r1]
    subs r4, r2, r0
    ldr r3, =#1000000
    cmp r4, r3
    blo _main_skip_down_mov
    str r2, [sp, #time]
    ldr r0, [sp, #tetrimone]
    movs r1, r0
    bl check_sift_down
    cmp r0, r1
    beq _main_display_move_down
    ldr r0, [sp, #tetrimone]
    bl apply
    bl get_tetrimone
    str r0, [sp, #tetrimone]
_main_display_move_down:
    ldr r0, [sp, #tetrimone]
    bl display
_main_skip_down_mov:
    b _main_loop
    pop {r4, pc}
