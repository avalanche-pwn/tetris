/**
 * Copyright (c) 2020 Raspberry Pi (Trading) Ltd.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include "pico/stdio.h"
#include "pico/stdlib.h"
#include <stdio.h>

extern void initUart();
extern void serial_write(uint8_t a);
extern void serial_flush();
extern uint8_t get_random();
extern void enable_rosc();
extern uint8_t *get_tetrimone();
extern uint8_t *rotate_right(uint8_t *tetrimone);
extern uint8_t *rotate_left(uint8_t *tetrimone);
extern void check_shift_left(uint8_t *tetrimone);
extern void check_shift_right(uint8_t *tetrimone);
extern void check_sift_down(uint8_t *tetrimone);
extern void display(uint8_t *tetrimone);
extern void deapply(uint8_t *tetrimone);
extern void check_collisions(uint8_t *tetrimone);
extern void init_gpio_pullup(int gpio);
extern int gpio_read(int gpio);

#define BUTTON_GPIO 2

int main() {
  init_gpio_pullup(BUTTON_GPIO);

  while (gpio_read(BUTTON_GPIO));
  // // gpio_init(25);
  // gpio_set_dir(25, GPIO_OUT);
  // gpio_put(25, 1);
  //
  initUart();
  uint8_t *t = get_tetrimone();
  // // display(t);
  while (true) {
    check_shift_left(t);
    display(t);
  }
}
