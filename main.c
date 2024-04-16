/**
 * Copyright (c) 2020 Raspberry Pi (Trading) Ltd.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include "pico/stdlib.h"
#include <stdio.h>

extern void my_main();

int main() {
  const uint OE = 16;
  const uint A = 17;
  const uint B = 18;
  const uint CLK = 21;
  const uint LATCH = 22;
  const uint R = 26;
  gpio_init(OE);
  gpio_init(A);
  gpio_init(B);
  gpio_init(CLK);
  gpio_init(LATCH);
  gpio_init(R);
  gpio_set_dir(OE, GPIO_OUT);
  gpio_set_dir(A, GPIO_OUT);
  gpio_set_dir(B, GPIO_OUT);
  gpio_set_dir(CLK, GPIO_OUT);
  gpio_set_dir(LATCH, GPIO_OUT);
  gpio_set_dir(R, GPIO_OUT);

  gpio_put(OE, 1);
  int d = 1;
  while (true) {
    gpio_put(B, d & 2);
    gpio_put(A, d & 1);
    for (int i = 0; i < 16; i++) {
      gpio_put(CLK, 1);
      sleep_ms(3);
      gpio_put(R, 1);
      gpio_put(CLK, 0);
      gpio_put(R, 0);
      sleep_ms(3);
    }
    gpio_put(LATCH, 1);
    sleep_ms(3);
    gpio_put(LATCH, 0);
    sleep_ms(3);
    d = (d + 1) % 4 + 0;
  }
}
