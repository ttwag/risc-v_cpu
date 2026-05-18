module tb_InstructionMemory;
    string dumpfile;
    logic [31:0] tb_A;
    logic [31:0] tb_RD;
    logic [31:0] expected_RD;
    parameter NUM_BYTES = 8;

    InstructionMemory #(NUM_BYTES) DUT(
        .A(tb_A),
        .RD(tb_RD)
    );
    
    initial begin
        $value$plusargs("DUMPFILE=%s", dumpfile);
        $dumpfile(dumpfile);
        $dumpvars();

        // Check Memory Read
        // Test 1
        expected_RD = 32'h76124293;
        DUT.instruct_memory[0] = expected_RD[7:0];
        DUT.instruct_memory[1] = expected_RD[15:8];
        DUT.instruct_memory[2] = expected_RD[23:16];
        DUT.instruct_memory[3] = expected_RD[31:24];

        tb_A = 32'b0;
        #5;
        assert (tb_RD == expected_RD)
            else $fatal(1, "Asssertion Failed: Expected RD == %h but got %h", expected_RD, tb_RD);

        // Test 2
        expected_RD = 32'h01994391;
        DUT.instruct_memory[4] = expected_RD[7:0];
        DUT.instruct_memory[5] = expected_RD[15:8];
        DUT.instruct_memory[6] = expected_RD[23:16];
        DUT.instruct_memory[7] = expected_RD[31:24];

        tb_A = 32'b100;
        #5;
        assert (tb_RD == expected_RD)
            else $fatal(1, "Asssertion Failed: Expected RD == %h but got %h", expected_RD, tb_RD);

        $finish;
    end

endmodule