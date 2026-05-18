module tb_RegisterFile;
    logic tb_CLK;
    logic tb_rst_n;
    logic tb_WE3;
    logic [4:0] tb_A1, tb_A2, tb_A3;
    logic [31:0] tb_WD3;
    logic [31:0] tb_RD1, tb_RD2;
    string dumpfile;
    parameter CLK_PERIOD = 10;

    RegisterFile TestRegisterFile(
        .CLK(tb_CLK), .rst_n(tb_rst_n), .WE3(tb_WE3), .A1(tb_A1), .A2(tb_A2),
        .A3(tb_A3), .WD3(tb_WD3), .RD1(tb_RD1), .RD2(tb_RD2)
    );

    initial begin
        tb_CLK = 0;
        forever #(CLK_PERIOD/2) tb_CLK = ~tb_CLK;
    end

    initial begin
        $value$plusargs("DUMPFILE=%s", dumpfile);
        $dumpfile(dumpfile);
        $dumpvars();
        
        // test write
        tb_A3 = 'b01;
        tb_A1 = 'b01;
        tb_WE3 = 'b1;
        tb_WD3 = 'b101;
        tb_rst_n = 1'b0;
        @(negedge tb_CLK);
        tb_rst_n = 1'b1;

        // test write with A1 outputs to RD1
        @(negedge tb_CLK);
        assert (tb_RD1 == tb_WD3);
            else   $fatal(1, "%b (tb_RD1) != %b (tb_WD3)", tb_RD1, tb_WD3);

        // test write with A2 outputs to RD2
        tb_A3 = 'b10;
        tb_A2 = 'b10;
        tb_WD3 = 'b111;
        @(negedge tb_CLK);
        assert (tb_RD2 == tb_WD3);
            else   $fatal(1, "%b (tb_RD2) != %b (tb_WD3)", tb_RD2, tb_WD3);

        // test write to x0 is not possible
        tb_A1 = 'b0;
        tb_WD3 = 'b1;
        @(negedge tb_CLK);
        assert (tb_RD1 == 'b0) 
            else   $fatal(1, "%b (tb_RD1) != 0)", tb_RD2);
        
        $finish;
    end
endmodule