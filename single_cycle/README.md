# Single Cycle CPU

A basic RISC-V cpu that competes the fetch-decode-execute-memory-write sequence in one cycle.

- [Single Cycle CPU](#single-cycle-cpu)
  - [Supported Instructions](#supported-instructions)
  - [Directory Structure](#directory-structure)
  - [Arithmetic Logic Unit](#arithmetic-logic-unit)
    - [Operations](#operations)
  - [Register File](#register-file)
  - [Control Unit](#control-unit)
    - [Supported Instructions](#supported-instructions-1)
    - [Main Decoder Truth Table](#main-decoder-truth-table)
    - [ALU Decoder Truth Table](#alu-decoder-truth-table)
  - [Data Memory](#data-memory)
  - [Instruction Memory](#instruction-memory)
  - [Immediate Unit](#immediate-unit)
  - [References](#references)

## Supported Instructions

- I-type
  - lw
- S-type
  - sw
- R-type
  - add
  - sub
  - and
  - or
  - slt
- B-type
  - beq

## Directory Structure

```text
single_cycle/
├── alu.sv
├── register_file.sv
├── control_unit.sv
├── data_memory.sv
├── instruction_memory.sv
├── sign_extend.sv
├── top_cpu.sv
└── testbench/
    ├── tb_alu.sv
    :
    └── tb_top_cpu.sv
```

## Arithmetic Logic Unit

### Operations

| ALUControl |   Operation |
| ---------: | ----------: |
|        000 |    Addition |
|        001 | Subtraction |
|        010 | Bitwise And |
|        011 |  Bitwise Or |
|        101 |         SLT |

- SLT (Set Less Than) — outputs 1 if A < B (signed \* comparison), else 0

## Register File

- Register 0 is always 0
- Register file outputs the content of registers specified in A1 and A2 to RD1 and RD2
- When WE3 is 1, write WD3 to register specified in A3

## Control Unit

### Supported Instructions

- lw
- sw
- R-type
- beq

### Main Decoder Truth Table

| Instruction | Op      | RegWrite | ImmSrc | ALUSrc | MemWrite | ResultSrc | Branch | ALUOp |
| :---------- | ------- | -------- | ------ | ------ | -------- | --------- | ------ | ----- |
| lw          | 0000011 | 1        | 00     | 1      | 0        | 1         | 0      | 00    |
| sw          | 0100011 | 0        | 01     | 1      | 1        | x         | 0      | 00    |
| R-type      | 0110011 | 1        | xx     | 0      | 0        | 0         | 0      | 10    |
| beq         | 1100011 | 0        | 10     | 0      | 0        | x         | 1      | 01    |

### ALU Decoder Truth Table

| ALUOp | funct3 | {op_5, funct7_5} | ALUControl          | Instruction |
| :---- | ------ | ---------------- | ------------------- | ----------- |
| 00    | x      | x                | 000 (add)           | lw, sw      |
| 01    | x      | x                | 001 (subtract)      | beq         |
| 10    | 000    | 00, 01, 10       | 000 (add)           | add         |
|       | 000    | 11               | 001 (subtract)      | sub         |
|       | 010    | x                | 101 (set less than) | slt         |
|       | 110    | x                | 011 (or)            | or          |
|       | 111    | x                | 010 (and)           | and         |

## Data Memory

- RISC-V is **Little Endian**
  - The least significant byte of a multi-byte data value is stored at the lowest memory address
  - Memory access would read the smaller memory address into least significant bit
- RISC-V is byte addressable
  - Each Memory address lives a byte
- Read has to be asynchronous because writing the value back to a register takes a cycle, and each instruction must take 1 cycle

## Instruction Memory

- Read only
- Byte addressable and little endian

## Immediate Unit

- For each instruction type, grabs the correct field to assemble them into the immediate

  | ImmSrc | ImmExt                                                         | Type | Description             |
  | :----- | :------------------------------------------------------------- | :--- | ----------------------- |
  | 00     | {{20{Instr[31]}}, Instr[31:20]}                                | I    | 12-bit signed immediate |
  | 01     | {{20{Instr[31]}}, Instr[31:25], Instr[11:7]}                   | S    | 12-bit signed immediate |
  | 10     | {{20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1’b0}   | B    | 13-bit signed immediate |
  | 11     | {{12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1’b0} | J    | 21-bit signed immediate |

## References

- Digital Design and Computer Architecture RISC-V Edition By Sarah Harris (ISBN: 0128200642)
