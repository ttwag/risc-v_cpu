module tb_RegisterFile;
    logic tb_clk;
    logic tb_rst_n;
    logic tb_write_enable_addr_3;
    logic [4:0] tb_addr_1, tb_addr_2, tb_addr_3;
    logic [31:0] tb_write_data_addr_3;
    logic [31:0] tb_read_data_addr_1, tb_read_data_addr_2;
    string dumpfile;
    parameter CLK_PERIOD = 10;

    RegisterFile TestRegisterFile(
        .clk(tb_clk), 
        .rst_n(tb_rst_n), 
        .write_enable_addr_3(tb_write_enable_addr_3), 
        .addr_1(tb_addr_1), 
        .addr_2(tb_addr_2),
        .addr_3(tb_addr_3), 
        .write_data_addr_3(tb_write_data_addr_3), 
        .read_data_addr_1(tb_read_data_addr_1), 
        .read_data_addr_2(tb_read_data_addr_2)
    );

    initial begin
        tb_clk = 0;
        forever #(CLK_PERIOD/2) tb_clk = ~tb_clk;
    end

    initial begin
        if (!$value$plusargs("DUMPFILE=%s", dumpfile))
            dumpfile = "dump.fst";
        $dumpfile(dumpfile);
        $dumpvars();
        
        // test write
        tb_addr_3 = 'b01;
        tb_addr_1 = 'b01;
        tb_write_enable_addr_3 = 'b1;
        tb_write_data_addr_3 = 'b101;
        tb_rst_n = 1'b0;
        @(negedge tb_clk);
        tb_rst_n = 1'b1;

        // test write with addr_1 outputs to read_data_addr_1
        @(negedge tb_clk);
        assert (tb_read_data_addr_1 == tb_write_data_addr_3);
            else   $fatal(1, "%b (read_data_addr_1) != %b (write_data_addr_3)", tb_read_data_addr_1, tb_write_data_addr_3);

        // test write with addr_2 outputs to read_data_addr_2
        tb_addr_3 = 'b10;
        tb_addr_2 = 'b10;
        tb_write_data_addr_3 = 'b111;
        @(negedge tb_clk);
        assert (tb_read_data_addr_2 == tb_write_data_addr_3);
            else   $fatal(1, "%b (read_data_addr_2) != %b (write_data_addr_3)", tb_read_data_addr_2, tb_write_data_addr_3);

        // test write to x0 is not possible
        tb_addr_1 = 'b0;
        tb_write_data_addr_3 = 'b1;
        @(negedge tb_clk);
        assert (tb_read_data_addr_1 == 'b0) 
            else   $fatal(1, "%b (read_data_addr_1) != 0)", tb_read_data_addr_2);
        
        $display("All tests passed.");
        $finish;
    end
endmodule