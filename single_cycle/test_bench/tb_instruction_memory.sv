module tb_InstructionMemory;
    string dumpfile;
    logic [31:0] tb_addr;
    logic [31:0] tb_read_data;
    logic [31:0] expected_read_data;
    parameter NUM_BYTES = 8;

    InstructionMemory #(NUM_BYTES) DUT(
        .addr(tb_addr),
        .read_data(tb_read_data)
    );
    
    initial begin
        if (!$value$plusargs("DUMPFILE=%s", dumpfile))
            dumpfile = "dump.fst";
        $dumpfile(dumpfile);
        $dumpvars();

        // Check Memory Read
        // Test 1
        expected_read_data = 32'h76124293;
        DUT.instruct_memory[0] = expected_read_data[7:0];
        DUT.instruct_memory[1] = expected_read_data[15:8];
        DUT.instruct_memory[2] = expected_read_data[23:16];
        DUT.instruct_memory[3] = expected_read_data[31:24];

        tb_addr = 32'b0;
        #5;
        assert (tb_read_data == expected_read_data)
            else $fatal(1, "Asssertion Failed: Expected read_data == %h but got %h", expected_read_data, tb_read_data);

        // Test 2
        expected_read_data = 32'h01994391;
        DUT.instruct_memory[4] = expected_read_data[7:0];
        DUT.instruct_memory[5] = expected_read_data[15:8];
        DUT.instruct_memory[6] = expected_read_data[23:16];
        DUT.instruct_memory[7] = expected_read_data[31:24];

        tb_addr = 32'b100;
        #5;
        assert (tb_read_data == expected_read_data)
            else $fatal(1, "Asssertion Failed: Expected read_data == %h but got %h", expected_read_data, tb_read_data);
        
        $display("All tests passed.");
        $finish;
    end

endmodule