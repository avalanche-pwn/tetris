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
extern uint8_t *rotate_left(uint8_t *tetrimone);
extern void shift_left(uint8_t *tetrimone);
extern void shift_right(uint8_t *tetrimone);
extern void sift_down(uint8_t *tetrimone);
extern void display(uint8_t *tetrimone);

#define BUTTON_GPIO 2

int main() {
  gpio_init(BUTTON_GPIO);
  gpio_set_dir(BUTTON_GPIO, GPIO_IN);
    // We are using the button to pull down to 0v when pressed, so ensure that when
    // unpressed, it uses internal pull ups. Otherwise when unpressed, the input will
    // be floating.
  gpio_pull_up(BUTTON_GPIO);
  while(gpio_get(BUTTON_GPIO)) {};
  // gpio_init(25);
  // gpio_set_dir(25, GPIO_OUT);
  // gpio_put(25, 1);
  //
  stdio_uart_init();
  uint8_t *t = get_tetrimone();
  t = rotate_left(t);
  shift_left(t);
  sift_down(t);
  for(;;) {
    serial_write('a');
    serial_flush();
    // puts("s");
  }
}
