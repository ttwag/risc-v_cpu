# Single Cycle CPU

A basic RISC-V cpu that competes the fetch-decode-execute-memory-write sequence in one cycle.

- [Single Cycle CPU](#single-cycle-cpu)
  - [Supported Instructions](#supported-instructions)
  - [Directory Structure](#directory-structure)
  - [Arithmetic Logic Unit](#arithmetic-logic-unit)
    - [Operations](#operations)
  - [Register File](#register-file)
  - [Control Unit](#control-unit)
    - [Main Decoder Truth Table](#main-decoder-truth-table)
    - [ALU Decoder Truth Table](#alu-decoder-truth-table)
    - [Branch Decoder Truth Table](#branch-decoder-truth-table)
  - [Data Memory](#data-memory)
  - [Instruction Memory](#instruction-memory)
  - [Immediate Unit](#immediate-unit)
  - [Program Counter](#program-counter)
  - [References](#references)

## Supported Instructions

- I-type
  - **Load:** lb, lh, lw, lbu, lhu
  - **Non-shift Arithmetic:** addi, slti, sltiu, xori, ori, andi
  - **Shift Arithmetic:** slli, srli, srai
  - **Jump**: jalr
- S-type
  - **Store:** sb, sw, sh
- R-type
  - add, sub
  - and, or, xor
  - slt, sltu
  - sll, srl, sra
- B-type
  - **Branch Equality:** beq, bne
  - **Branch Comparison:** blt, bge
  - **Branch Unsigned Comparison:** bltu, bgeu
- U-type
  - **PC-Relative:** auipc
  - **Non PC-Relative:** lui
- J-type
  - jal

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

| ALUControl |              Operation |
| ---------: | ---------------------: |
|       0000 |               Addition |
|       0001 |            Subtraction |
|       0010 |            Bitwise And |
|       0011 |             Bitwise Or |
|       0100 |            Bitwise XOr |
|       0101 |                    SLT |
|       0110 |           SLT Unsigned |
|       0111 |     Shift Left Logical |
|       1000 |    Shift Right Logical |
|       1001 | Shift Right Arithmetic |

- SLT (Set Less Than) — outputs 1 if A < B (signed \* comparison), else 0

## Register File

- Register 0 is always 0
- Register file outputs the content of registers specified in A1 and A2 to RD1 and RD2
- When WE3 is 1, write WD3 to register specified in A3

## Control Unit

### Main Decoder Truth Table

| Instruction                 | Op      | RegWrite | ImmSrc | ALUSrcA | ALUSrcB | MemWrite | ResultSrc | PCSrc             | ALUOp | MemWidth |
| :-------------------------- | ------- | -------- | ------ | ------- | ------- | -------- | --------- | ----------------- | ----- | -------- |
| I-type Load                 | 0000011 | 1        | 000    | 0       | 1       | 0        | 01        | 00                | 00    | funct3   |
| I-Type Non-shift Arithmetic | 0010011 | 1        | 000    | 0       | 1       | 0        | 00        | 00                | 10    | funct3   |
| I-Type Shift Arithmetic     | 0010011 | 1        | 100    | 0       | 1       | 0        | 00        | 00                | 10    | funct3   |
| I-Type Jump                 | 1100111 | 1        | 000    | 0       | 1       | 0        | 10        | 10                | 00    | x        |
| sw                          | 0100011 | 0        | 001    | 0       | 1       | 1        | x         | 00                | 00    | funct3   |
| R-type                      | 0110011 | 1        | xx     | 0       | 0       | 0        | 00        | 00                | 10    | funct3   |
| B-type                      | 1100011 | 0        | 010    | 0       | 0       | 0        | x         | {0,BranchControl} | 01    | funct3   |
| U-type PC-Relative          | 0010111 | 1        | 101    | 0       | 0       | 0        | 11        | 00                | 00    | x        |
| U-type Non PC-Relative      | 0110111 | 1        | 101    | 1       | 1       | 0        | 00        | 00                | 00    | x        |
| J-type                      | 1101111 | 1        | 011    | 0       | 0       | 0        | 10        | 01                | 00    | x        |

### ALU Decoder Truth Table

| ALUOp | funct3 | {op_5, funct7_5} | ALUControl                    | Instruction        |
| :---- | ------ | ---------------- | ----------------------------- | ------------------ |
| 00    | x      | x                | 0000 (add)                    | lw, sw, auipc, lui |
| 01    | 000    | x                | 0001 (subtract)               | beq                |
|       | 001    | x                | 0001                          | bne                |
|       | 100    | x                | 0101 (set les than)           | blt                |
|       | 101    | x                | 0101 (set les than)           | bge                |
|       | 110    | x                | 0110 (set les than unsigned)  | bltu               |
|       | 111    | x                | 0110 (set les than unsigned)  | bgeu               |
| 10    | 000    | 00, 01, 10       | 0000 (add)                    | add                |
|       | 000    | 11               | 0001 (subtract)               | sub                |
|       | 001    | x                | 0111 (shift Left Logical)     | sll                |
|       | 010    | x                | 0101 (set less than)          | slt                |
|       | 011    | x                | 0110 (set less than unsigned) | sltu               |
|       | 100    | x                | 0100 (exclusive or)           | xor                |
|       | 101    | x0               | 1000 (shift right logical)    | srl                |
|       | 101    | x1               | 1001 (shift right arithmetic) | sra                |
|       | 110    | x                | 0011 (or)                     | or                 |
|       | 111    | x                | 0010 (and)                    | and                |

### Branch Decoder Truth Table

| funct3 | ALUControl                   | BranchControl |
| :----- | ---------------------------- | ------------- |
| 000    | 0001 (subtract)              | Zero          |
| 001    | 0001 (subtract)              | ~Zero         |
| 100    | 0101 (set les than)          | ~ALUResult[0] |
| 101    | 0101 (set les than)          | ALUResult[0]  |
| 110    | 0110 (set les than unsigned) | ~ALUResult[0] |
| 111    | 0110 (set les than unsigned) | ALUResult[0]  |

## Data Memory

- RISC-V is **Little Endian**
  - The least significant byte of a multi-byte data value is stored at the lowest memory address
  - Memory access would read the smaller memory address into least significant bit
- RISC-V is byte addressable
  - Each Memory address lives a byte
- Read has to be asynchronous because writing the value back to a register takes a cycle, and each instruction must take 1 cycle
- Depending on control unit's MemWidth, 1, 2, 4 bytes of memory could be read at once

## Instruction Memory

- Read only
- Byte addressable and little endian

## Immediate Unit

- For each instruction type, grabs the correct field to assemble them into the immediate

  | ImmSrc | ImmExt                                                         | Type | Description             |
  | :----- | :------------------------------------------------------------- | :--- | ----------------------- |
  | 000    | {{20{Instr[31]}}, Instr[31:20]}                                | I    | 12-bit signed immediate |
  | 001    | {{20{Instr[31]}}, Instr[31:25], Instr[11:7]}                   | S    | 12-bit signed immediate |
  | 010    | {{20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1’b0}   | B    | 13-bit signed immediate |
  | 011    | {{12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1’b0} | J    | 21-bit signed immediate |
  | 100    | {{20{Instr[31]}}, Instr[31:20]}                                | I    | 12-bit signed immediate |

## Program Counter

| pc_src | pc           |
| :----- | ------------ |
| 00     | pc + 4       |
| 01     | pc + imm_ext |
| 10     | alu_result   |

## References

- Digital Design and Computer Architecture RISC-V Edition By Sarah Harris (ISBN: 0128200642)
