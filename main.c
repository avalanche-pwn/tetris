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
  const uint B = 2;
  const uint C = 3;
  const uint CLK = 4;
  const uint LATCH = 5;
  const uint R = 6;
  gpio_init(OE);
  gpio_init(A);
  gpio_init(B);
  gpio_init(C);
  gpio_init(CLK);
  gpio_init(LATCH);
  gpio_init(R);
  gpio_set_dir(OE, GPIO_OUT);
  gpio_set_dir(A, GPIO_OUT);
  gpio_set_dir(B, GPIO_OUT);
  gpio_set_dir(C, GPIO_OUT);
  gpio_set_dir(CLK, GPIO_OUT);
  gpio_set_dir(LATCH, GPIO_OUT);
  gpio_set_dir(R, GPIO_OUT);

  gpio_put(OE, 1);
  int d = A;
  while (true) {
    gpio_put(d, 1);
    for (int i = 0; i < 16; i++) {
      gpio_put(CLK, 1);
      gpio_put(R, 1);
      gpio_put(CLK, 0);
      gpio_put(R, 0);
    }
    gpio_put(LATCH, 1);
    gpio_put(LATCH, 0);
    gpio_put(d, 0);
    d = (d + 1) % 3 + A;
  }
}
