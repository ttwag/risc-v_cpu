module DataMemory #(parameter NUM_BYTES = 4)
(
    input logic CLK,
    input logic WE,
    input logic [31:0] A,
    input logic [31:0] WD,
    input logic [2:0] MemWidth,
    output logic [31:0] RD
);
    // byte addressable memory
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
    
    always_ff @(posedge CLK) begin
        if (WE) begin
            // little endian write
            memory[A] <= WD[7:0];
            memory[A + 1] <= WD[15:8];
            memory[A + 2] <= WD[23:16];
            memory[A + 3] <= WD[31:24];
        end
    end
    
endmodule