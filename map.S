#include "defs.S"
.syntax unified
.cpu cortex-m0plus
.thumb
@.equ MAP_REAL_SIZE, MAP_SIZE - 2
.section .data
map:
.fill 32, 4, 0x20001
.word 0x3ffff
.word 0x3ffff
.equ MAP_SIZE, .-map

.global apply
.global deapply
.global display
.global check_collisions
.section .text
apply:
    @r0 - tetrimone to apply
    push {r0-r5, lr}
    @r1 - tetrimone width
    @r2 - tetrimone_y
    ldrb r1, [r0, #TETRIMONE_WIDTH]
    ldrb r2, [r0, #TETRIMONE_Y]
    @r1 - 2x tetrimone_width
    adds r2, r1
    lsls r2, #2
    lsls r1, #2
    adds r0, #TETRIMONE_MATRIX
_apply_loop:
    subs r1, #4
    subs r2, #4
    @r3 - current tetrimone row
    ldr r3, [r0, r1]
    @r4 - map addr
    ldr r4, =map
    @r5 - current map row
    ldr r5, [r4, r2]
    orrs r5, r3
    str r5, [r4, r2]
    cmp r1, #0
    bne _apply_loop
    pop {r0-r5, pc}

deapply:
    @r0 - tetrimone to apply
    push {r0-r5, lr}
    @r1 - tetrimone width
    @r2 - tetrimone_y
    ldrb r1, [r0, #TETRIMONE_WIDTH]
    ldrb r2, [r0, #TETRIMONE_Y]
    @r1 - 2x tetrimone_width
    adds r2, r1
    lsls r2, #2
    lsls r1, #2
    adds r0, #TETRIMONE_MATRIX
_deapply_loop:
    subs r1, #4
    subs r2, #4
    @r3 - current tetrimone row
    ldr r3, [r0, r1]
    @r4 - map addr
    ldr r4, =map
    @r5 - current map row
    ldr r5, [r4, r2]
    eors r5, r3
    str r5, [r4, r2]
    cmp r1, #0
    bne _deapply_loop
    pop {r0-r5, pc}

display:
    push {r0-r3, lr}
    @r0 - current tetrimone - also on top of the stack
    bl apply
    @r1 - iterator
    eors r1, r1
    @r2 - map addr
    ldr r2, =map
_display_loop:
    ldr r0, [r2, r1]
    @r3 - first send byte mask
    movs r3, #0xff
    lsls r3, #9
    push {r0}
    ands r0, r3
    lsrs r0, #9
    bl serial_write
    pop {r0}
    lsrs r3, #8
    ands r0, r3
    lsrs r0, #1
    bl serial_write
    adds r1, #4
    @substract 8 to ignore bottom border
    cmp r1, #(MAP_SIZE - 8)
    blt _display_loop
    pop {r0}
    bl deapply
    movs r1, #4
_display_msg_flush:
    movs r0, #0xff
    bl serial_write
    subs r1, #1
    bne _display_msg_flush
    pop {r1-r3, pc}

check_collisions:
    @r0 - current tetrimone
    push {r0-r5, lr}
    @r1 - tetrimone width
    @r2 - tetrimone_y
    ldrb r1, [r0, #TETRIMONE_WIDTH]
    ldrb r2, [r0, #TETRIMONE_Y]
    @r1 - 2x tetrimone_width
    adds r2, r1
    lsls r2, #2
    lsls r1, #2
    adds r0, #TETRIMONE_MATRIX
_check_collisions_loop:
    subs r1, #4
    subs r2, #4
    @r3 - current tetrimone row
    ldr r3, [r0, r1]
    @r4 - map addr
    ldr r4, =map
    @r5 - current map row
    ldr r5, [r4, r2]
    ands r5, r3
    bne _check_collisions_ret
    cmp r1, #0
    bne _check_collisions_loop
    pop {r0-r5, pc}
_check_collisions_ret:
    pop {r0}
    movs r0, r5
    pop {r1-r5, pc}
