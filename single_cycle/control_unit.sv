module ControlUnit (
    input logic [6:0] op,
    input logic [2:0] funct3,
    input logic funct7,
    input logic Zero,
    output logic PCSrc,
    output logic ResultSrc,
    output logic MemWrite,
    output logic [2:0] ALUControl,
    output logic ALUSrc,
    output logic [1:0] ImmSrc,
    output logic RegWrite
);
    logic Branch;
    logic [1:0] ALUOp;

    assign PCSrc = Branch & Zero;

    ControlUnitMainDecoder md(
        .op(op), .Branch(Branch), .ResultSrc(ResultSrc),
        .MemWrite(MemWrite), .ALUSrc(ALUSrc), .ImmSrc(ImmSrc),
        .RegWrite(RegWrite), .ALUOp(ALUOp)
    );

    ControlUnitALUDecoder ad(
        .funct3(funct3), .op_5(op[5]), .funct7(funct7),
        .ALUOp(ALUOp), .ALUControl(ALUControl)
    );

endmodule

module ControlUnitMainDecoder (
    input logic [6:0] op,
    output logic Branch,
    output logic ResultSrc,
    output logic MemWrite,
    output logic ALUSrc,
    output logic [1:0] ImmSrc,
    output logic RegWrite,
    output logic [1:0] ALUOp
);
    always_comb begin
        // defaults
        ALUOp     = 2'b00;
        ALUSrc    = 1'b0;
        RegWrite  = 1'b0;
        MemWrite  = 1'b0;
        Branch    = 1'b0;
        ResultSrc = 1'b0;
        ImmSrc    = 2'b00;
        case (op)
            7'b0000011: begin //lw
                ResultSrc = 1'b1;
                ALUSrc = 1'b1;
                RegWrite = 1'b1;
            end
            7'b0100011: begin //sw
                MemWrite = 1'b1;
                ALUSrc = 1'b1;
                ImmSrc = 2'b1;
            end
            7'b0110011: begin// R-type
                RegWrite = 1'b1;
                ALUOp = 2'b10;
            end
            7'b1100011: begin //beq
                Branch = 1'b1;
                ImmSrc = 2'b10;
                ALUOp = 2'b1;
            end
        endcase
    end
endmodule

module ControlUnitALUDecoder (
    input logic [2:0] funct3,
    input logic op_5,
    input logic funct7,
    input logic [1:0] ALUOp,
    output logic [2:0] ALUControl
);
    always_comb begin
        case (ALUOp)
            2'b00:
                ALUControl = 3'b000;
            2'b01:
                ALUControl = 3'b001;
            2'b10:
                if (funct3 == 3'b000)
                    if (op_5 & funct7 == 1'b0)
                        ALUControl = 3'b000;
                    else
                        ALUControl = 3'b001;
                else if (funct3 == 3'b010)
                    ALUControl = 3'b101;
                else if (funct3 == 3'b110)
                    ALUControl = 3'b011;
                else if (funct3 == 3'b111)
                    ALUControl = 3'b010;
            default:
                ALUControl = 3'bx;
        endcase
    end
endmodule