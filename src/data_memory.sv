module DataMemory #(parameter NUM_BYTES = 4)
(
    input logic clk,
    input logic write_enable,
    input logic [31:0] addr,
    input logic [31:0] write_data,
    input logic [2:0] mem_width,
    output logic [31:0] read_data
);
    // byte addressable little-endian memory
    logic [7:0] memory [NUM_BYTES - 1 : 0];

    logic [7:0] b0, b1, b2, b3;
    logic b0_msb, b1_msb;

    always @(*) begin //combinational read
        b0 = memory[addr];
        b1 = memory[addr+1];
        b2 = memory[addr+2];
        b3 = memory[addr+3];
        b0_msb = b0[7];
        b1_msb = b1[7];

        case (mem_width)
            3'b000: read_data = {{24{b0_msb}}, b0};
            3'b001: read_data = {{16{b1_msb}}, b1, b0};
            3'b010: read_data = {b3, b2, b1, b0};
            3'b100: read_data = {{24{1'b0}}, b0};
            3'b101: read_data = {{16{1'b0}}, b1, b0};
            default: read_data = 32'bx;
        endcase
    end
    
    always_ff @(posedge clk) begin //sequential write
        if (write_enable) begin
            case (mem_width)
                3'b000: memory[addr] <= write_data[7:0];
                3'b001: {memory[addr+1], memory[addr]} <= write_data[15:0];
                3'b010: {memory[addr+3], memory[addr+2], memory[addr+1], memory[addr]} <= write_data[31:0];
                default: begin end
            endcase
        end
    end
    
endmodule