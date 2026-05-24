`include "alu.sv"
`include "control_unit.sv"
`include "data_memory.sv"
`include "instruction_memory.sv"
`include "register_file.sv"
`include "sign_extend.sv"


module CPUTop #(
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
    logic       pc_src;
    logic [1:0] result_src;
    logic       mem_write;
    logic [3:0] alu_control;
    logic [1:0] alu_src_a;
    logic       alu_src_b;
    logic [2:0] imm_src;
    logic       reg_write;
    logic [2:0] mem_width;

    // Data Memory
    logic [31:0] read_data;
    
    // Instruction Memory
    logic [31:0] pc_target;
    logic [31:0] pc_plus_4;
    logic [31:0] pc;
    logic [31:0] instr;

    // Register File
    logic [4:0] reg_A1, reg_A2, reg_A3;
    logic [31:0] reg_rd1, reg_rd2;
    logic [31:0] result;

    // Sign Extend
    logic [31:0] imm_ext;

    // Multiplexors
    assign pc_target = pc + imm_ext;
    assign pc_plus_4 = pc + 4'b100;
    assign src_a = (alu_src_a == 2'b0) ? reg_rd1 :
                   (alu_src_a == 2'b1) ? pc :
                   (alu_src_a == 2'b10) ? 32'b0 :
                   32'bx; 
    assign src_b = (alu_src_b == 1'b0) ? reg_rd2 :
                   (alu_src_b == 1'b1) ? imm_ext :
                   32'bx;
    
    always_comb begin
        if (result_src == 2'b0)
            result = alu_result;
        else if (result_src == 2'b1)
            result = read_data;
        else if (result_src == 2'b10)
            result = pc_plus_4;
        else
            result = 32'bx;
    end

    // PC
    always_ff @(posedge clk) begin
        if (rst_n == 1'b0)
            pc <= 32'b0;
        else if (pc_src == 1'b1)
            pc <= pc_target;
        else 
            pc <= pc_plus_4;
    end
    

    InstructionMemory #(NUM_BYTES) instructionMemory(
        .A(pc),
        .RD(instr)
    );

    ALU alu(
        .SrcA(src_a), 
        .SrcB(src_b), 
        .ALUControl(alu_control),
        .Zero(zero), 
        .ALUResult(alu_result)
    );
    ControlUnit controlUnit(
        .op        (instr[6:0]),
        .funct3    (instr[14:12]),
        .funct7    (instr[30]),
        .Zero      (zero),
        .ALUResult (alu_result[0]),
        .PCSrc     (pc_src),
        .ResultSrc (result_src),
        .MemWrite  (mem_write),
        .ALUControl(alu_control),
        .ALUSrcA  (alu_src_a),
        .ALUSrcB  (alu_src_b),
        .ImmSrc    (imm_src),
        .RegWrite  (reg_write),
        .MemWidth  (mem_width)
    );

    DataMemory #(.NUM_BYTES(NUM_BYTES)) dataMemory(
        .CLK(clk), 
        .WE(mem_write),
        .A(alu_result),
        .WD(reg_rd2),
        .MemWidth(mem_width),
        .RD(read_data)
    );

    RegisterFile registerFile(
        .CLK(clk), 
        .rst_n(rst_n), 
        .WE3(reg_write), 
        .A1(instr[19:15]), 
        .A2(instr[24:20]),
        .A3(instr[11:7]), 
        .WD3(result),
        .RD1(reg_rd1), 
        .RD2(reg_rd2)
    );
    
    SignExtend signExtend(
        .Instr(instr),
        .ImmSrc(imm_src),
        .ImmExt(imm_ext)
    );

endmodule