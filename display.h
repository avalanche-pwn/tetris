#include "pico/stdlib.h"
#pragma once

#define PINS_COUNT 6

typedef struct {
  union {
    struct {
      uint8_t oe;
      uint8_t a;
      uint8_t b;
      uint8_t clk;
      uint8_t latch;
      uint8_t r;
    };
    uint8_t pin_array[PINS_COUNT];
  };
  uint16_t *map;
} display;

void init_display(display *d);
void send_4by8(display *d, uint8_t x, uint8_t y);
void latch(display *d);
