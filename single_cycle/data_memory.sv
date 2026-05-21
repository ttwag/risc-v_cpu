module DataMemory #(parameter NUM_BYTES = 4)
(
    input logic CLK,
    input logic WE,
    input logic [31:0] A,
    input logic [31:0] WD,
    input logic [2:0] MemWidth,
    output logic [31:0] RD
);
    // byte addressable little-endian memory
    logic [7:0] memory [NUM_BYTES - 1 : 0];

    logic [7:0] b0, b1, b2, b3;
    logic b0_msb, b1_msb;

    always @(*) begin //combinational read
        b0 = memory[A];
        b1 = memory[A+1];
        b2 = memory[A+2];
        b3 = memory[A+3];
        b0_msb = b0[7];
        b1_msb = b1[7];

        case (MemWidth)
            3'b000: RD = {{24{b0_msb}}, b0};
            3'b001: RD = {{16{b1_msb}}, b1, b0};
            3'b010: RD = {b3, b2, b1, b0};
            3'b100: RD = {{24{1'b0}}, b0};
            3'b101: RD = {{16{1'b0}}, b1, b0};
            default: RD = 32'bx;
        endcase
    end
    
    always_ff @(posedge CLK) begin //sequential write
        if (WE) begin
            case (MemWidth)
                3'b000: memory[A] <= WD[7:0];
                3'b001: {memory[A+1], memory[A]} <= WD[15:0];
                3'b010: {memory[A+3], memory[A+2], memory[A+1], memory[A]} <= WD[31:0];
                default: begin end
            endcase
        end
    end
    
endmodule