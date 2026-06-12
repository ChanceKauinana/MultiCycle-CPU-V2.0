# Multi-Cycle CPU on Basys 3

This project is a 16-bit multi-cycle CPU written in Verilog for the Digilent Basys 3 FPGA board.

The goal is to build an educational CPU with a simple control unit, register file, ALU, instruction memory, and visible hardware debugging using the Basys 3 seven-segment display and LEDs.

## Hardware

- Board: Digilent Basys 3
- FPGA: Artix-7 `xc7a35tcpg236-1`
- Clock: 100 MHz onboard clock

## Current Features

- 16-bit instructions
- 16-bit datapath
- 8-bit program counter
- 8 general-purpose registers
- Multi-cycle FSM
- Register-register ALU operations
- Instruction register
- ALU output register
- HALT instruction
- Seven-segment display debug output

## Instruction Format

Each instruction is 16 bits:

```text
[15:12] opcode
[11:8]  rd
[7:4]   rs
[3:0]   rt