module InstructionMemory #(parameter NUM_BYTES = 4)
(
    input [31:0] A,
    output [31:0] RD
);
    logic [7:0] instruct_memory [NUM_BYTES - 1 : 0];

    assign RD = {instruct_memory[A + 3], instruct_memory[A + 2], instruct_memory[A + 1], instruct_memory[A]};

endmodule