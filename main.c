/**
 * Copyright (c) 2020 Raspberry Pi (Trading) Ltd.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include <stdio.h>
#include "pico/stdlib.h"

extern void my_main();

int main() 
{
    stdio_init_all();
    puts("asf");
    return 0;
}
