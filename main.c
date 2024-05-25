/**
 * Copyright (c) 2020 Raspberry Pi (Trading) Ltd.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include "display.h"
#include "pico/stdio.h"
#include "pico/stdlib.h"
#include <stdio.h>

extern void initUart();
extern void serial_write(uint8_t a);
extern void serial_flush();

uint16_t map[32] = {
    0b0000000000000000,
    0b0000000000000000,
    0b0000000000000000,
    0b0000000000000000,
    0b0000000000000000,
    0b0000000000000000,
    0b0000000000000000,
    0b0000000000000000,
    0b0000000000000000,
    0b0000000000000000,
    0b0000000000000000,
    0b0000000000000000,
    0b0000000000000000,
    0b0001111111111100,
    0b0010000100000000,
    0b0010000100000000,
    0b0001111111111100,
    0b0000000000000000,
    0b0001111000000000,
    0b0010000100000000,
    0b0010000100000000,
    0b0011111111111100,
    0b0000000000000000,
    0b0011111111111000,
    0b0000000000000100,
    0b0000000000000100,
    0b0011111111111000,
    0b0000000000000000,
    0b0001111111111000,
    0b0010000000000100,
    0b0010000000000100,
    0b0011111111111100,
};

int main() {
  initUart();
  //
  //stdio_uart_init();
  for (;;){
    serial_write('a');
    serial_write('\n');
    serial_flush();
    // puts("s");
  }
}
