module InstructionMemory #(parameter NUM_BYTES = 4)
(
    input [31:0] addr,
    output [31:0] instr
);
    logic [7:0] instruct_memory [NUM_BYTES - 1 : 0];

    assign instr = {instruct_memory[addr + 3], instruct_memory[addr + 2], instruct_memory[addr + 1], instruct_memory[addr]};

endmodule