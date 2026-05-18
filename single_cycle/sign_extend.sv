module SignExtend(
    input logic [31:0] Instr,
    input logic [1:0] ImmSrc,
    output logic [31:0] ImmExt
); 
    // Immediate field extractions
    wire [11:0] i_imm = Instr[31:20];
    wire [11:0] s_imm = {Instr[31:25], Instr[11:7]};
    wire [12:0] b_imm = {Instr[31], Instr[7], Instr[30:25], Instr[11:8], 1'b0};
    wire [20:0] j_imm = {Instr[31], Instr[19:12], Instr[20], Instr[30:21], 1'b0};
    assign ImmExt = (ImmSrc == 2'b00) ? {{20{i_imm[11]}}, i_imm} :
                    (ImmSrc == 2'b01) ? {{20{s_imm[11]}}, s_imm} :
                    (ImmSrc == 2'b10) ? {{19{b_imm[12]}}, b_imm} :
                    (ImmSrc == 2'b11) ? {{11{j_imm[20]}}, j_imm} :
                    32'bx;
endmodule