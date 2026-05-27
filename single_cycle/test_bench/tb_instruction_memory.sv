module tb_InstructionMemory;
    string dumpfile;
    logic [31:0] tb_addr;
    logic [31:0] tb_instr;
    logic [31:0] expected_instr;
    parameter NUM_BYTES = 8;

    InstructionMemory #(NUM_BYTES) DUT(
        .addr(tb_addr),
        .instr(tb_instr)
    );
    
    initial begin
        if (!$value$plusargs("DUMPFILE=%s", dumpfile))
            dumpfile = "dump.fst";
        $dumpfile(dumpfile);
        $dumpvars();

        // Check Memory Read
        // Test 1
        expected_instr = 32'h76124293;
        DUT.instruct_memory[0] = expected_instr[7:0];
        DUT.instruct_memory[1] = expected_instr[15:8];
        DUT.instruct_memory[2] = expected_instr[23:16];
        DUT.instruct_memory[3] = expected_instr[31:24];

        tb_addr = 32'b0;
        #5;
        assert (tb_instr == expected_instr)
            else $fatal(1, "Asssertion Failed: Expected instr == %h but got %h", expected_instr, tb_instr);

        // Test 2
        expected_instr = 32'h01994391;
        DUT.instruct_memory[4] = expected_instr[7:0];
        DUT.instruct_memory[5] = expected_instr[15:8];
        DUT.instruct_memory[6] = expected_instr[23:16];
        DUT.instruct_memory[7] = expected_instr[31:24];

        tb_addr = 32'b100;
        #5;
        assert (tb_instr == expected_instr)
            else $fatal(1, "Asssertion Failed: Expected instr == %h but got %h", expected_instr, tb_instr);
        
        $display("All tests passed.");
        $finish;
    end

endmodule