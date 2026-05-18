module DataMemory #(parameter NUM_BYTES = 4)
(
    input logic CLK,
    input logic WE,
    input logic [31:0] A,
    input logic [31:0] WD,
    output logic [31:0] RD
);
    // byte addressable memory
    logic [7:0] memory [NUM_BYTES - 1 : 0];

    // little endian read
    assign RD = {memory[A+3], memory[A+2], memory[A+1], memory[A]};
    
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