#include "display.h"
#include "pico/stdlib.h"

void init_display(display *d) {
  for (int i = 0; i < PINS_COUNT; i++) {
    uint8_t pin = d->pin_array[i];
    gpio_init(pin);
    gpio_set_dir(pin, GPIO_OUT);
  }
  // Turn on enable pin
  gpio_put(d->oe, 1);
};

void send_4by8(display *d, uint8_t x, uint8_t y) {
  int mask = 278528 >> x;
  int nibble_mask = 0xf000 >> x;
  int mod_counter = 1;
  for (int i = 0; i < 4; i++) {
    gpio_put(d->b, mod_counter & 2);
    gpio_put(d->a, mod_counter & 1);
    for (int j = y; j < y + 8; j++) {
      gpio_put(d->clk, 1);
      sleep_ms(3);
      gpio_put(d->r, (d->map[j] & mask) & nibble_mask);
      sleep_ms(3);
      gpio_put(d->clk, 0);
      sleep_ms(3);
      gpio_put(d->r, 0);
      sleep_ms(3);
    }
    mask >>= 1;
    mod_counter = (mod_counter + 1) % 4;
  }
}

void send_16by32(display *d) {
  for (int y = 32 - 8; y >= 0; y -= 8) {
    for (int x = 16 - 4; x >= 0; x -= 4) {
      send_4by8(d, x, y);
    }
  }
}

void latch(display *d) {
  gpio_put(d->latch, 1);
  gpio_put(d->latch, 0);
}
