module SignExtend(
    input logic [31:0] instr,
    input logic [2:0] imm_src,
    output logic [31:0] imm_ext
); 
    // Immediate field extractions
    wire [11:0] i_imm = instr[31:20];
    wire [11:0] s_imm = {instr[31:25], instr[11:7]};
    wire [12:0] b_imm = {instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
    wire [20:0] j_imm = {instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
    wire [19:0] u_imm = instr[31:12];

    always @(*) begin
        case (imm_src)
            3'b000: imm_ext = {{20{i_imm[11]}}, i_imm};
            3'b001: imm_ext = {{20{s_imm[11]}}, s_imm};
            3'b010: imm_ext = {{19{b_imm[12]}}, b_imm};
            3'b011: imm_ext = {{11{j_imm[20]}}, j_imm};
            3'b100: imm_ext = {27'b0, i_imm[4:0]};
            3'b101: imm_ext = {u_imm, 12'b0};
            default: imm_ext = 32'bx;
        endcase
    end
endmodule