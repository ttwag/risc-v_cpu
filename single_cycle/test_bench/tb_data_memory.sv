module tb_DataMemory;
    string dumpfile;
    logic tb_CLK;
    logic tb_WE;
    logic [31:0] tb_A;
    logic [31:0] tb_WD;
    logic [31:0] tb_RD;
    parameter CLK_PERIOD = 10;
    parameter tb_NUM_BYTES = 64;

    DataMemory #(.NUM_BYTES(tb_NUM_BYTES)) DUT(
        .CLK(tb_CLK), 
        .WE(tb_WE),
        .A(tb_A),
        .WD(tb_WD),
        .RD(tb_RD)
    );

    initial begin
        tb_CLK = 0;
        forever #(CLK_PERIOD/2) tb_CLK = ~tb_CLK;
    end

    initial begin
        $value$plusargs("DUMPFILE=%s", dumpfile);
        $dumpfile(dumpfile);
        $dumpvars();
        
        // Test Read after write
        for (int i = 0; i < tb_NUM_BYTES; i+=4) begin
            @(posedge tb_CLK);
            tb_A = i;
            tb_WD = 32'b1;
            tb_WE = 1'b1;

            #1
            assert (tb_RD == tb_WD)
                else $fatal(1, "Read Write Mismatched: %b (RD) != %b WD", tb_RD, tb_WD);
        end
        $finish;
    end
    
endmodule