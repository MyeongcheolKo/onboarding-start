<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

SPI-controlled PWM peripheral for Tiny Tapeout. An SPI peripheral receives 16-bit write transactions (1 R/W bit + 7 address bits + 8 data bits) using SPI Mode 0. It writes to five registers that control 16 output channels: output enable, PWM enable, and a shared duty cycle. A PWM module generates a 3 kHz signal with configurable duty cycle (0-100%). SPI signals are synchronized to the system clock using 2-stage flip-flop chains to prevent metastability.

## How to test

Send SPI transactions to configure registers. Write to 0x00/0x01 to enable outputs, 0x02/0x03 to enable PWM mode, and 0x04 to set the duty cycle (0x00 = 0%, 0xFF = 100%). Outputs appear on uo_out[7:0] and uio_out[7:0].

## External hardware

SPI controller (e.g. microcontroller) connected to ui_in[0] (SCLK), ui_in[1] (COPI), ui_in[2] (nCS). LEDs or other loads on uo_out and uio_out pins to observe PWM output.
