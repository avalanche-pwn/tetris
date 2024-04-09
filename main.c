/**
 * Copyright (c) 2020 Raspberry Pi (Trading) Ltd.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include "pico/stdlib.h"
#include <stdio.h>

extern void my_main();

int main() {
  const uint OE = 0;
  const uint A = 1;
  const uint CLK = 4;
  const uint LATCH = 5;
  const uint R = 6;
  gpio_init(OE);
  gpio_init(A);
  gpio_init(CLK);
  gpio_init(LATCH);
  gpio_init(R);
  gpio_set_dir(OE, GPIO_OUT);
  gpio_set_dir(A, GPIO_OUT);
  gpio_set_dir(CLK, GPIO_OUT);
  gpio_set_dir(LATCH, GPIO_OUT);
  gpio_set_dir(R, GPIO_OUT);

  gpio_put(OE, 1);
  gpio_put(A, 1);
  while (true) {
    for (int i = 0; i < 16; i++) {
      gpio_put(CLK, 1);
      sleep_ms(125);
      sleep_ms(125);
      gpio_put(R, 1);
      gpio_put(CLK, 0);
      sleep_ms(125);
      gpio_put(R, 0);
      sleep_ms(125);
    }
    gpio_put(LATCH, 1);
    sleep_ms(125);
    gpio_put(LATCH, 0);
    sleep_ms(125);
  }
}
