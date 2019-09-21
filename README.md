# Reduced RISC-V Implementation 

Verilog implementation of CPU microarchitecture supporting a miniaturized 32-bit RISC-V ISA.  
This project includes three types of microarchitectures:  

- Single-cycle CPU
- Multi-cycle CPU
- Pipelined CPU

## Setup
- Verilog
- HDL simulator, or FPGA hardware

## Reduced RISC-V Instruction Set

| Instruction | Type | Semantics |
|---|:---:|:---:|
| `JAL` |  |  |
| `JALR` |  |  |
| `BEQ` |  |  |
| `BNE` |  |  |
| `BLT` |  |  |
| `BGE` |  |  |
| `BLTU` |  |  |
| `BGEU` |  |  |
| `LW` |  |  |
| `SW` |  |  |
| `ADDI` |  |  |
| `SLTI` |  |  |
| `SLTIU` |  |  |
| `XORI` |  |  |
| `ORI` |  |  |
| `ANDI` |  |  |
| `SLLI` |  |  |
| `SRLI` |  |  |
| `SRAI` |  |  |
| `ADD` |  |  |
| `SUB` |  |  |
| `SLL` |  |  |
| `SLT` |  |  |
| `SLTU` |  |  |
| `XOR` |  |  |
| `SRL` |  |  |
| `SRA` |  |  |
| `OR` |  |  |
| `AND` |  |  |

## Reference
- [Andrew Waterman, Krste Asanović, SiFive Inc., 2017, *The RISC-V Instruction Set Manual (Version 2.2)*](https://riscv.org/specifications/)