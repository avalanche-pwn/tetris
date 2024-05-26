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
extern uint8_t get_random();
extern void enable_rosc();
extern uint8_t *get_tetrimone();
extern uint8_t *rotate_left(uint8_t *tetrimone);
extern void shift_left(uint8_t *tetrimone);
extern void shift_right(uint8_t *tetrimone);
extern void sift_down(uint8_t *tetrimone);
extern void display(uint8_t *tetrimone);



int main() {
  initUart();
  //
  //stdio_uart_init();
  uint8_t *t = get_tetrimone();
  t = rotate_left(t);
  shift_left(t);
  sift_down(t);
  for(;;) {
    display(t);
    serial_write('\n');
    serial_flush();
    // puts("s");
  }
}
