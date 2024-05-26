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
.global display
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
    lsls r1, #1
    adds r0, #TETRIMONE_MATRIX
_apply_loop:
    subs r1, #2
    subs r2, #4
    @r3 - current tetrimone row
    ldrh r3, [r0, r1]
    lsls r3, #1         @shift current row to align with the row in map which has 1 representing border as first and last bit
    @r4 - map addr
    ldr r4, =map
    @r5 - current map row
    ldr r5, [r4, r2]
    orrs r5, r3
    str r5, [r4, r2]
    cmp r1, #0
    bne _apply_loop
    pop {r0-r5, pc}

display:
    push {r1-r3, lr}
    @r0 - current tetrimone
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
    cmp r1, #(MAP_SIZE)
    blt _display_loop
    pop {r1-r3, pc}