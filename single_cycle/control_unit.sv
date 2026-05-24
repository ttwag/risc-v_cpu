module ControlUnit (
    input logic [6:0] op,
    input logic [2:0] funct3,
    input logic funct7,
    input logic Zero,
    input logic ALUResult,
    output logic PCSrc,
    output logic [1:0] ResultSrc,
    output logic MemWrite,
    output logic [3:0] ALUControl,
    output logic ALUSrcA,
    output logic ALUSrcB,
    output logic [2:0] ImmSrc,
    output logic RegWrite,
    output logic [2:0] MemWidth
);
    logic [1:0] ALUOp;
    logic BranchControl;

    ControlUnitMainDecoder md(
        .op(op), .funct3(funct3), .BranchControl(BranchControl), .PCSrc(PCSrc), .ResultSrc(ResultSrc),
        .MemWrite(MemWrite), .ALUSrcA(ALUSrcA), .ALUSrcB(ALUSrcB), .ImmSrc(ImmSrc),
        .RegWrite(RegWrite), .ALUOp(ALUOp), .MemWidth(MemWidth)
    );

    ControlUnitALUDecoder ad(
        .funct3(funct3), .op_5(op[5]), .funct7(funct7),
        .ALUOp(ALUOp), .ALUControl(ALUControl)
    );

    ControlUnitBranchDecoder bd(
        .funct3(funct3),
        .Zero(Zero),
        .ALUResult(ALUResult),
        .BranchControl(BranchControl)
    );
endmodule

module ControlUnitMainDecoder (
    input logic [6:0] op,
    input logic [2:0] funct3,
    input logic BranchControl,
    output logic PCSrc,
    output logic [1:0] ResultSrc,
    output logic MemWrite,
    output logic ALUSrcA,
    output logic ALUSrcB,
    output logic [2:0] ImmSrc,
    output logic RegWrite,
    output logic [1:0] ALUOp,
    output logic [2:0] MemWidth
);
    always_comb begin
        // defaults
        ALUOp     = 2'b00;
        ALUSrcA  = 1'b0;
        ALUSrcB  = 1'b0;
        RegWrite  = 1'b0;
        MemWrite  = 1'b0;
        PCSrc    = 1'b0;
        ResultSrc = 2'b0;
        ImmSrc    = 3'b000;
        MemWidth  = funct3;

        case (op)
            7'b0000011: begin //load
                ResultSrc = 2'b1;
                ALUSrcB = 1'b1;
                RegWrite = 1'b1;
            end
            7'b0100011: begin //sw
                MemWrite = 1'b1;
                ALUSrcB = 1'b1;
                ImmSrc = 3'b1;
            end
            7'b0010011: begin// I-type arithmetic
                RegWrite = 1'b1;
                ALUSrcB = 1'b1;
                ImmSrc = (funct3 == 3'b001 || funct3 == 3'b101) ? 3'b100 : 3'b000;
                ALUOp = 2'b10;
            end
            7'b0110011: begin// R-type
                RegWrite = 1'b1;
                ALUOp = 2'b10;
            end
            7'b1100011: begin //B-type
                ImmSrc = 3'b10;
                ALUOp = 2'b1;
                PCSrc = BranchControl;
            end
            7'b0010111: begin //U-type PC-Relative
                RegWrite = 1'b1;
                ImmSrc = 3'b101;
                ResultSrc = 2'b11;
            end
            7'b0110111: begin //U-type Non PC-Relative
                RegWrite = 1'b1;
                ALUSrcA = 1'b1;
                ALUSrcB = 1'b1;
                ImmSrc = 3'b101;
            end
            7'b1101111: begin //J-type
                RegWrite = 1'b1;
                ResultSrc = 2'b10;
                ImmSrc = 3'b011;
                PCSrc = 1'b1;
            end
        endcase
    end
endmodule

module ControlUnitALUDecoder (
    input logic [2:0] funct3,
    input logic op_5,
    input logic funct7,
    input logic [1:0] ALUOp,
    output logic [3:0] ALUControl
);
    always_comb begin
        case (ALUOp)
            2'b00:
                ALUControl = 4'b000;
            2'b01: //b-type
                case (funct3)
                    3'b000: ALUControl = 4'b0001;
                    3'b001: ALUControl = 4'b0001;
                    3'b100: ALUControl = 4'b0101;
                    3'b101: ALUControl = 4'b0101;
                    3'b110: ALUControl = 4'b0110;
                    3'b111: ALUControl = 4'b0110;
                    default ALUControl = 4'bx;
                endcase
            2'b10:
                case (funct3)
                    3'b000: ALUControl = ~(op_5 & funct7) ? 4'b0000 : 4'b0001; // add, sub
                    3'b001: ALUControl = 4'b0111;                             // sll
                    3'b010: ALUControl = 4'b0101;                             // slt
                    3'b011: ALUControl = 4'b0110;                             // sltu
                    3'b100: ALUControl = 4'b0100;                             // xor
                    3'b101: ALUControl = ~funct7 ? 4'b1000 : 4'b1001;          // sra, srl
                    3'b110: ALUControl = 4'b0011;                             // or
                    3'b111: ALUControl = 4'b0010;                             // and
                    default: ALUControl = 4'bx;
                endcase
            default:
                ALUControl = 3'bx;
        endcase
    end
endmodule

module ControlUnitBranchDecoder(
    input logic [2:0] funct3,
    input logic Zero,
    input logic ALUResult,
    output logic BranchControl
);
    always_comb begin
        case (funct3)
            3'b000: BranchControl = Zero;
            3'b001: BranchControl = ~Zero;
            3'b100: BranchControl = ALUResult;
            3'b101: BranchControl = ~ALUResult;
            3'b110: BranchControl = ALUResult;
            3'b111: BranchControl = ~ALUResult;
            default: BranchControl = 1'bx;
        endcase
    end
endmodule