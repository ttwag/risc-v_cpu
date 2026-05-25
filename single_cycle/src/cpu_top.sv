`include "alu.sv"
`include "control_unit.sv"
`include "data_memory.sv"
`include "instruction_memory.sv"
`include "register_file.sv"
`include "sign_extend.sv"
`include "program_counter.sv"

module CpuTop #(
        parameter CLK_PERIOD = 10,
        parameter NUM_BYTES = 64
    ) 
(
    input logic clk,
    input logic rst_n
);
    // ALU
    logic signed [31:0] src_a;
    logic signed [31:0] src_b;
    logic [31:0] alu_result;
    
    // Control Unit
    logic       zero;
    logic [1:0] pc_src;
    logic [1:0] result_src;
    logic       mem_write;
    logic [3:0] alu_control;
    logic       alu_src_a;
    logic       alu_src_b;
    logic [2:0] imm_src;
    logic       reg_write;
    logic [2:0] mem_width;

    // Data Memory
    logic [31:0] read_data;
    
    // Instruction Memory
    logic [31:0] instr;

    // program counter
    logic [31:0] pc_target;
    logic [31:0] pc_plus_4;
    logic [31:0] pc;

    // Register File
    logic [4:0] reg_A1, reg_A2, reg_A3;
    logic [31:0] reg_rd1, reg_rd2;
    logic [31:0] result;

    // Sign Extend
    logic [31:0] imm_ext;

    // Multiplexors
    assign src_a = (alu_src_a == 1'b0) ? reg_rd1 :
                   (alu_src_a == 1'b1) ? 32'b0 :
                   32'bx; 
    assign src_b = (alu_src_b == 1'b0) ? reg_rd2 :
                   (alu_src_b == 1'b1) ? imm_ext :
                   32'bx;
    
    assign result = (result_src == 2'b00) ? alu_result :
                    (result_src == 2'b01) ? read_data  :
                    (result_src == 2'b10) ? pc_plus_4  :
                    (result_src == 2'b11) ? pc_target  :
                    32'bx;

    // PC
    ProgramCounter programCounter(
        .clk(clk),
        .rst_n(rst_n),
        .pc_src(pc_src),
        .imm_ext(imm_ext),
        .alu_result(alu_result),
        .pc(pc),
        .pc_target(pc_target),
        .pc_plus_4(pc_plus_4)
    );

    InstructionMemory #(NUM_BYTES) instructionMemory(
        .addr(pc),
        .read_data(instr)
    );

    Alu alu(
        .src_a(src_a), 
        .src_b(src_b), 
        .alu_control(alu_control),
        .zero(zero), 
        .alu_result(alu_result)
    );
    ControlUnit controlUnit(
        .op        (instr[6:0]),
        .funct3    (instr[14:12]),
        .funct7    (instr[30]),
        .zero      (zero),
        .alu_result (alu_result[0]),
        .pc_src     (pc_src),
        .result_src (result_src),
        .mem_write  (mem_write),
        .alu_control(alu_control),
        .alu_src_a  (alu_src_a),
        .alu_src_b  (alu_src_b),
        .imm_src    (imm_src),
        .reg_write  (reg_write),
        .mem_width  (mem_width)
    );

    DataMemory #(.NUM_BYTES(NUM_BYTES)) dataMemory(
        .clk(clk), 
        .write_enable(mem_write),
        .addr(alu_result),
        .write_data(reg_rd2),
        .mem_width(mem_width),
        .read_data(read_data)
    );

    RegisterFile registerFile(
        .clk(clk), 
        .rst_n(rst_n), 
        .write_enable_addr_3(reg_write), 
        .addr_1(instr[19:15]), 
        .addr_2(instr[24:20]),
        .addr_3(instr[11:7]), 
        .write_data_addr_3(result),
        .read_data_addr_1(reg_rd1), 
        .read_data_addr_2(reg_rd2)
    );
    
    SignExtend signExtend(
        .instr(instr),
        .imm_src(imm_src),
        .imm_ext(imm_ext)
    );

endmodule