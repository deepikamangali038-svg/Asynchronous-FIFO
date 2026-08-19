# Asynchronous FIFO in Verilog

A fully synthesizable Asynchronous FIFO implemented using Verilog HDL.

This project demonstrates how to safely transfer data between two
independent clock domains using an asynchronous FIFO architecture.

## Features

- Pure Verilog implementation
- Independent read and write clocks
- Independent read and write resets
- Parameterized data width
- Parameterized FIFO depth
- Gray-code read/write pointers
- Two-stage clock-domain synchronization
- Full detection
- Empty detection
- Simulation testbench
- VCD waveform generation

## Project Structure

```text
async-fifo-verilog/
├── README.md
├── src/
│   └── async_fifo.v
├── tb/
│   └── tb_async_fifo.v
└── output/
    └── output.txt
