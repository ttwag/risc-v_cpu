module ControlUnit (
    input logic [6:0] op,
    input logic [2:0] funct3,
    input logic funct7,
    input logic zero,
    input logic alu_result,
    output logic [1:0] pc_src,
    output logic [1:0] result_src,
    output logic mem_write,
    output logic [3:0] alu_control,
    output logic alu_src_a,
    output logic alu_src_b,
    output logic [2:0] imm_src,
    output logic reg_write,
    output logic [2:0] mem_width
);
    logic [1:0] alu_op;
    logic branch_control;

    ControlUnitMainDecoder md(
        .op(op), .funct3(funct3), .branch_control(branch_control), .pc_src(pc_src), .result_src(result_src),
        .mem_write(mem_write), .alu_src_a(alu_src_a), .alu_src_b(alu_src_b), .imm_src(imm_src),
        .reg_write(reg_write), .alu_op(alu_op), .mem_width(mem_width)
    );

    ControlUnitAluDecoder ad(
        .funct3(funct3), .op_5(op[5]), .funct7(funct7),
        .alu_op(alu_op), .alu_control(alu_control)
    );

    ControlUnitBranchDecoder bd(
        .funct3(funct3),
        .zero(zero),
        .alu_result(alu_result),
        .branch_control(branch_control)
    );
endmodule

module ControlUnitMainDecoder (
    input logic [6:0] op,
    input logic [2:0] funct3,
    input logic branch_control,
    output logic [1:0] pc_src,
    output logic [1:0] result_src,
    output logic mem_write,
    output logic alu_src_a,
    output logic alu_src_b,
    output logic [2:0] imm_src,
    output logic reg_write,
    output logic [1:0] alu_op,
    output logic [2:0] mem_width
);
    always_comb begin
        // defaults
        alu_op     = 2'b00;
        alu_src_a  = 1'b0;
        alu_src_b  = 1'b0;
        reg_write  = 1'b0;
        mem_write  = 1'b0;
        pc_src    = 2'b0;
        result_src = 2'b0;
        imm_src    = 3'b000;
        mem_width  = funct3;

        case (op)
            7'b0000011: begin //load
                result_src = 2'b1;
                alu_src_b = 1'b1;
                reg_write = 1'b1;
            end
            7'b0100011: begin //sw
                mem_write = 1'b1;
                alu_src_b = 1'b1;
                imm_src = 3'b1;
            end
            7'b0010011: begin// I-type arithmetic
                reg_write = 1'b1;
                alu_src_b = 1'b1;
                imm_src = (funct3 == 3'b001 || funct3 == 3'b101) ? 3'b100 : 3'b000;
                alu_op = 2'b10;
            end
            7'b1100111: begin //I-type Jump
                reg_write = 1'b1;
                alu_src_b = 1'b1;
                result_src = 2'b10;
                pc_src = 2'b10;
            end
            7'b0110011: begin// R-type
                reg_write = 1'b1;
                alu_op = 2'b10;
            end
            7'b1100011: begin //B-type
                imm_src = 3'b10;
                alu_op = 2'b1;
                pc_src = {1'b0, branch_control};
            end
            7'b0010111: begin //U-type PC-Relative
                reg_write = 1'b1;
                imm_src = 3'b101;
                result_src = 2'b11;
            end
            7'b0110111: begin //U-type Non PC-Relative
                reg_write = 1'b1;
                alu_src_a = 1'b1;
                alu_src_b = 1'b1;
                imm_src = 3'b101;
            end
            7'b1101111: begin //J-type
                reg_write = 1'b1;
                result_src = 2'b10;
                imm_src = 3'b011;
                pc_src = 2'b1;
            end
        endcase
    end
endmodule

module ControlUnitAluDecoder (
    input logic [2:0] funct3,
    input logic op_5,
    input logic funct7,
    input logic [1:0] alu_op,
    output logic [3:0] alu_control
);
    always_comb begin
        case (alu_op)
            2'b00:
                alu_control = 4'b000;
            2'b01: //b-type
                case (funct3)
                    3'b000: alu_control = 4'b0001;
                    3'b001: alu_control = 4'b0001;
                    3'b100: alu_control = 4'b0101;
                    3'b101: alu_control = 4'b0101;
                    3'b110: alu_control = 4'b0110;
                    3'b111: alu_control = 4'b0110;
                    default alu_control = 4'bx;
                endcase
            2'b10:
                case (funct3)
                    3'b000: alu_control = ~(op_5 & funct7) ? 4'b0000 : 4'b0001; // add, sub
                    3'b001: alu_control = 4'b0111;                             // sll
                    3'b010: alu_control = 4'b0101;                             // slt
                    3'b011: alu_control = 4'b0110;                             // sltu
                    3'b100: alu_control = 4'b0100;                             // xor
                    3'b101: alu_control = ~funct7 ? 4'b1000 : 4'b1001;          // sra, srl
                    3'b110: alu_control = 4'b0011;                             // or
                    3'b111: alu_control = 4'b0010;                             // and
                    default: alu_control = 4'bx;
                endcase
            default:
                alu_control = 3'bx;
        endcase
    end
endmodule

module ControlUnitBranchDecoder(
    input logic [2:0] funct3,
    input logic zero,
    input logic alu_result,
    output logic branch_control
);
    always_comb begin
        case (funct3)
            3'b000: branch_control = zero;
            3'b001: branch_control = ~zero;
            3'b100: branch_control = alu_result;
            3'b101: branch_control = ~alu_result;
            3'b110: branch_control = alu_result;
            3'b111: branch_control = ~alu_result;
            default: branch_control = 1'bx;
        endcase
    end
endmodule