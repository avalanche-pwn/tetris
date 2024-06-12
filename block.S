#include "defs.S"
.syntax unified
.cpu cortex-m0plus
.thumb
.equ XOR, 0x1000
.equ SET, 0x2000
.equ CLEAR, 0x3000

.equ TETRIMONE_SIZE, tetrimone_j-tetrimone_i

.equ ROSC_BASE, 0x40060000
.equ ROSC_CTRL, ROSC_BASE + 0
.equ ROSC_CTRL_SET, ROSC_CTRL + SET
.equ ROSC_RANDOMBIT, ROSC_BASE + 0x1c

.section .data
.balign 4
tetrimone_arr:
tetrimone_i: 
.4byte 0b00000
.4byte 0b11110
.4byte 0b00000
.4byte 0b00000
.byte 12, 0, 4
.balign 4
tetrimone_j: 
.4byte 0b10000
.4byte 0b11100
.4byte 0b00000
.4byte 0b00000
.byte 12, 0, 3
.balign 4
tetrimone_l: 
.4byte 0b00100
.4byte 0b11100
.4byte 0b00000
.4byte 0b00000
.byte 12, 0, 3
.balign 4
tetrimone_o: 
.4byte 0b11000
.4byte 0b11000
.4byte 0b00000
.4byte 0b00000
.byte 12, 0, 2
.balign 4
tetrimone_s: 
.4byte 0b01100
.4byte 0b11000
.4byte 0b00000
.4byte 0b00000
.byte 12, 0, 3
.balign 4
tetrimone_t: 
.4byte 0b01000
.4byte 0b11100
.4byte 0b00000
.4byte 0b00000
.byte 12, 0, 3
.balign 4
tetrimone_z: 
.4byte 0b11000
.4byte 0b01100
.4byte 0b00000
.4byte 0b00000
.byte 12, 0, 3
.balign 4
tetrimone_z2: 
.4byte 0b11000
.4byte 0b01100
.4byte 0b00000
.4byte 0b00000
.byte 12, 0, 3
current_swap: .byte 0
.equ TETRIMONE_ARR_SIZE, .-tetrimone_arr

.balign 4
swap_tetrimone:
.skip TETRIMONE_SIZE * SWAP_NUM

.global enable_rosc
.global get_random
.global get_tetrimone
.global rotate_right
.global rotate_left
.global shift_right
.global shift_left
.global sift_down
.global check_sift_down
.global check_shift_right
.global check_shift_left
.global check_rotate_left
.global check_rotate_right
.section .text
_swap_reset:
    eors r2, r2
    b _get_swap_ret
get_swap:
    push {r1-r4, lr}
    ldr r1, =swap_tetrimone
    ldr r2, =current_swap
    ldrb r2, [r2]
    movs r3, #TETRIMONE_SIZE
    muls r2, r3
    adds r1, r2
    ldrb r4, [r0, TETRIMONE_X]
    strb r4, [r1, TETRIMONE_X]
    ldrb r4, [r0, TETRIMONE_Y]
    strb r4, [r1, TETRIMONE_Y]
    ldrb r4, [r0, TETRIMONE_WIDTH]
    strb r4, [r1, TETRIMONE_WIDTH]
    movs r0, r1
    ldr r2, =current_swap
    ldrb r2, [r2]
    adds r2, #1
    cmp r2, #SWAP_NUM
    beq _swap_reset
_get_swap_ret:
    ldr r3, =current_swap
    strb r2, [r3]
    pop {r1-r4, pc}
enable_rosc:
    push {r0-r1, lr}
    ldr r0, =ROSC_CTRL_SET
    ldr r1, =0xfab
    lsls r1, #12
    str r1, [r0]
    pop {r0-r1, pc}
get_random:
    push {r1-r3, lr}
    movs r2, 3
    eors r0, r0
_get_random_loop:
    ldr r1, =ROSC_RANDOMBIT
    ldr r1, [r1]
    lsls r0, #1
    movs r3, #1
    ands r1, r1, r3
    orrs r0, r0, r1
    subs r2, r2, #1
    cmp r2, #0
    bne _get_random_loop
    pop {r1-r3, pc}
get_tetrimone:
    push {r1-r3, lr}
    bl get_random
    movs r1, #TETRIMONE_SIZE
    muls r0, r0, r1
    ldr r1, =tetrimone_arr
    adds r1, r1, r0
    movs r0, r1
    bl get_swap
    movs r2, #TETRIMONE_SIZE
_get_tetrimone_loop:
    subs r2, r2, #1
    ldrb r3, [r1, r2]
    strb r3, [r0, r2]
    cmp r2, #0
    bne _get_tetrimone_loop
    pop {r1-r3, pc}
clear_tetrimone:
    @r0 - tetrimone to clear
    push {r1-r3, lr}
    ldrb r1, [r0, TETRIMONE_WIDTH]
    adds r0, #TETRIMONE_MATRIX
    eors r3, r3
_clear_tetrimone_loop:
    subs r1, r1, #1
    lsls r2, r1, #2
    str r3, [r0, r2]
    cmp r1, #0
    bne _clear_tetrimone_loop
    pop {r1-r3, pc}
rotate_right:
    @r0 - tetrimone to rotate
    push {r1-r6, lr}
    movs r1, r0
    bl get_swap
    bl clear_tetrimone
    @r2 - tetrimone x
    @r3 - tetrimone width
    @r5 - iterator 1
    eors r5, r5
_rotate_right_loop:
    push {r5}
    ldrb r2, [r1, #TETRIMONE_X]  
    ldrb r3, [r1, #TETRIMONE_WIDTH]
    @r4 shift value
    movs r4, #16
    subs r4, r3
    subs r4, r2
    cmp r4, #0
    bge _rotate_right_neg_shift_skip
    eors r0, r0
    pop {r5}
    pop {r1-r6, pc}
_rotate_right_neg_shift_skip:
    lsls r5, #2
    adds r5, #TETRIMONE_MATRIX
    @r2 - row
    ldr r2, [r1, r5]
    lsrs r2, r4
    @r5 inner loop iterator
    eors r5, r5
_rotate_right_inner_loop:
    push {r5}
    @r5 tetrimone x
    ldrb r5, [r1, #TETRIMONE_X]
    @r4 shift value
    movs r4, #16
    subs r4, r3
    subs r4, r5
    @r5 bit value
    movs r5, #(1 << 1)
    ands r5, r2, r5
    ldr r6, [sp, #4]
    adds r4, r6
    lsls r5, r4
    ldr r4, [sp, #0]
    subs r4, r3, r4
    subs r4, #1
    lsls r4, #2
    adds r4, #TETRIMONE_MATRIX
    ldr r6, [r0, r4]
    orrs r5, r6
    str r5, [r0, r4]
    lsrs r2, #1
    pop {r5}
    adds r5, #1
    cmp r5, r3
    blt _rotate_right_inner_loop
    pop {r5}
    adds r5, #1
    cmp r5, r3
    blt _rotate_right_loop
    pop {r1-r6, pc}

rotate_left:
   @r0 - tetrimone to rotate
    push {r1-r6, lr}
    movs r1, r0
    bl get_swap
    bl clear_tetrimone
    @r2 - tetrimone x
    @r3 - tetrimone width
    @r5 - iterator 1
    eors r5, r5
_rotate_left_loop:
    push {r5}
    ldrb r2, [r1, #TETRIMONE_X]  
    ldrb r3, [r1, #TETRIMONE_WIDTH]
    @r4 shift value
    movs r4, #16
    subs r4, r3
    subs r4, r2
    cmp r4, #0
    bge _rotate_left_neg_shift_skip
    eors r0, r0
    pop {r5}
    pop {r1-r6, pc}
_rotate_left_neg_shift_skip:
    lsls r5, #2
    adds r5, #TETRIMONE_MATRIX
    @r2 - row
    ldr r2, [r1, r5]
    lsrs r2, r4
    @r5 inner loop iterator
    eors r5, r5
_rotate_left_inner_loop:
    push {r5}
    @r5 tetrimone x
    ldrb r5, [r1, #TETRIMONE_X]
    @r4 shift value
    movs r4, #15
    subs r4, r5
    @r5 bit value
    movs r5, #(1 << 1)
    ands r5, r2, r5
    ldr r6, [sp, #4]
    subs r4, r6
    lsls r5, r4
    ldr r4, [sp, #0]
    lsls r4, #2
    adds r4, #TETRIMONE_MATRIX
    ldr r6, [r0, r4]
    orrs r5, r6
    str r5, [r0, r4]
    lsrs r2, #1
    pop {r5}
    adds r5, #1
    cmp r5, r3
    blt _rotate_left_inner_loop
    pop {r5}
    adds r5, #1
    cmp r5, r3
    blt _rotate_left_loop
    pop {r1-r6, pc}

shift_right:
    @r0 - tetrimone to shift
    push {r0-r3, lr}
    ldrb r1, [r0, #TETRIMONE_X]
    adds r1, #1
    strb r1, [r0, #TETRIMONE_X]
    ldrb r1, [r0, #TETRIMONE_WIDTH]
    lsls r1, #2
    adds r0, #TETRIMONE_MATRIX
    @r3 - iterator
    eors r3, r3
_shift_right_loop_start:
    ldr r2, [r0, r3]
    lsrs r2, #1
    str r2, [r0, r3]
    adds r3, 4
    cmp r3, r1
    blt _shift_right_loop_start
    pop {r0-r3, pc}

shift_left:
    @r0 - tetrimone to shift
    push {r0-r3, lr}
    ldrb r1, [r0, #TETRIMONE_X]
    subs r1, #1
    strb r1, [r0, #TETRIMONE_X]
    ldrb r1, [r0, #TETRIMONE_WIDTH]
    lsls r1, #2
    adds r0, #TETRIMONE_MATRIX
    @r3 - iterator
    eors r3, r3
_shift_left_loop_start:
    ldr r2, [r0, r3]
    lsls r2, #1
    str r2, [r0, r3]
    adds r3, 4
    cmp r3, r1
    blt _shift_left_loop_start
    pop {r0-r3, pc}

sift_down:
    push {r0-r1, lr}
    ldrb r1, [r0, #TETRIMONE_Y]
    adds r1, 1
    strb r1, [r0, #TETRIMONE_Y]
    pop {r0-r1, pc}

check_sift_down:
    @r0 - tetrimone
    push {r1-r2, lr}
    bl sift_down
    movs r2, r0
    bl check_collisions
    beq _check_sift_down_ret
    ldrb r1, [r2, #TETRIMONE_Y]
    subs r1, 1
    strb r1, [r2, #TETRIMONE_Y]
_check_sift_down_ret:
    pop {r1-r2, pc}

check_shift_right:
    @r0 - tetrimone
    push {r1-r2, lr}
    bl shift_right
    movs r2, r0
    bl check_collisions
    beq _check_shift_right_ret
    movs r1, r0
    movs r0, r2
    bl shift_left
    movs r0, r2
_check_shift_right_ret:
    pop {r1-r2, pc}


check_shift_left:
    @r0 - tetrimone
    push {r1-r2, lr}
    bl shift_left
    movs r2, r0
    bl check_collisions
    beq _check_shift_left_ret
    movs r1, r0
    movs r0, r2
    bl shift_right
    movs r0, r2
_check_shift_left_ret:
    pop {r1-r2, pc}

check_rotate_right:
    push {r1-r2, lr}
    movs r2, r0
    bl rotate_right
    cmp r0, #0
    beq _check_rotate_right_failed
    movs r2, r0
    bl check_collisions
    cmp r0, r2
    beq _check_rotate_right_ret
_check_rotate_right_failed:
    movs r0, r2
    bl get_swap
_check_rotate_right_ret:
    pop {r1-r2, pc}

check_rotate_left:
    push {r1-r2, lr}
    movs r2, r0
    bl rotate_left
    cmp r0, #0
    beq _check_rotate_left_failed
    movs r2, r0
    bl check_collisions
    cmp r0, r2
    beq _check_rotate_left_ret
_check_rotate_left_failed:
    movs r0, r2
    bl get_swap
_check_rotate_left_ret:
    pop {r1-r2, pc}
