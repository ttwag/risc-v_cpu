module ProgramCounter(
    input logic clk,
    input logic rst_n,
    input logic [1:0] pc_src,
    input logic [31:0] imm_ext,
    input logic [31:0] alu_result,
    output logic [31:0] pc,
    output logic [31:0] pc_target,
    output logic [31:0] pc_plus_4
);
    assign pc_target = pc + imm_ext;
    assign pc_plus_4 = pc + 4'b100;

    always_ff @(posedge clk) begin
        if (rst_n == 1'b0)
            pc <= 32'b0;
        else if (pc_src == 2'b0)
            pc <= pc_plus_4;
        else if (pc_src == 2'b1)
            pc <= pc_target;
        else if (pc_src == 2'b10)
            pc <= alu_result;
        else
            pc <= 32'bx;
    end
endmodule