module tb_DataMemory;
    string dumpfile;
    logic tb_CLK;
    logic tb_WE;
    logic [31:0] tb_A;
    logic [31:0] tb_WD;
    logic [31:0] tb_RD;
    logic [2:0] tb_MemWidth = 3'b000;
    parameter CLK_PERIOD = 10;
    parameter tb_NUM_BYTES = 64;

    DataMemory #(.NUM_BYTES(tb_NUM_BYTES)) DUT(
        .CLK(tb_CLK), 
        .WE(tb_WE),
        .A(tb_A),
        .WD(tb_WD),
        .MemWidth(tb_MemWidth),
        .RD(tb_RD)
    );

    // -------------------------
    // Utilities task
    // -------------------------
    task load_data(input integer addr, input [31:0] data);
        DUT.memory[addr]   = data[7:0];
        DUT.memory[addr+1] = data[15:8];
        DUT.memory[addr+2] = data[23:16];
        DUT.memory[addr+3] = data[31:24];
    endtask

    // -------------------------
    // Tests
    // -------------------------
    task test_lb();
        tb_A = 32'b0;
        tb_MemWidth = 3'b000;

        load_data(tb_A, 32'b11010111_01010100);

        @(posedge tb_CLK); #1
        assert (tb_RD == 32'b01010100) //test no sign extension
            else $fatal(1, "RD expected %b, got %b", 32'b01010100, tb_RD);

        tb_A = tb_A + 1;
        @(posedge tb_CLK); #1
        assert (tb_RD == 32'($signed(8'b11010111))) //test sign extension
            else $fatal(1, "RD expected %b, got %b", 32'($signed(8'b11010111)), tb_RD);
    endtask

    task test_lh();
        tb_A = 32'b0;
        tb_MemWidth = 3'b001;

        load_data(tb_A, 32'b1000000000000000_0101011101010100);

        @(posedge tb_CLK); #1
        assert (tb_RD == 32'b0101011101010100) //test no sign extension
            else $fatal(1, "RD expected %b, got %b", 32'b01010100, tb_RD);

        tb_A = tb_A + 2;
        @(posedge tb_CLK); #1
        assert (tb_RD == 32'($signed(16'b1000000000000000))) //test sign extension
            else $fatal(1, "RD expected %b, got %b", 32'($signed(16'b1000000000000000)), tb_RD);
    endtask

    task test_lw();
        tb_A = 32'b0;
        tb_MemWidth = 3'b010;
        load_data(tb_A, 32'b10000000000000000101011101010100);

        @(posedge tb_CLK); #1
        assert (tb_RD == 32'b10000000000000000101011101010100)
            else $fatal(1, "RD expected %b, got %b", 32'b10000000000000000101011101010100, tb_RD);
    endtask

    task test_lbu();
        tb_A = 32'b0;
        tb_MemWidth = 3'b100;

        load_data(tb_A, 32'b11011111_01010101);

        @(posedge tb_CLK); #1
        assert (tb_RD == 32'b01010101) //test no sign extension
            else $fatal(1, "RD expected %b, got %b", 32'b01010101, tb_RD);

        tb_A = tb_A + 1;
        @(posedge tb_CLK); #1
        assert (tb_RD == 32'b11011111) //test zero extension on negative number
            else $fatal(1, "RD expected %b, got %b", 32'b11011111, tb_RD);
    endtask

    task test_lhu();
        tb_A = 32'b0;
        tb_MemWidth = 3'b101;

        load_data(tb_A, 32'b1000000010000000_0101011001010100);

        @(posedge tb_CLK); #1
        assert (tb_RD == 32'b0101011001010100) //test no sign extension
            else $fatal(1, "RD expected %b, got %b", 32'b0101011001010100, tb_RD);

        tb_A = tb_A + 2;
        @(posedge tb_CLK); #1
        assert (tb_RD == 32'b1000000010000000) //test zero extension on negative number
            else $fatal(1, "RD expected %b, got %b", 32'b1000000010000000, tb_RD);
    endtask

    task test_read_after_write();
        tb_A = 32'b0;
        tb_WD = 32'b1;
        tb_WE = 1'b1;

        @(posedge tb_CLK); #1
        assert (tb_RD == tb_WD)
            else $fatal(1, "Read Write Mismatched: %b (RD) != %b WD", tb_RD, tb_WD);
        tb_WE = 1'b0;
    endtask

    initial begin
        tb_CLK = 0;
        forever #(CLK_PERIOD/2) tb_CLK = ~tb_CLK;
    end

    initial begin
        $value$plusargs("DUMPFILE=%s", dumpfile);
        $dumpfile(dumpfile);
        $dumpvars();
        
        test_lb();
        test_lh();
        test_lw();
        test_lbu();
        test_lhu();
        test_read_after_write();
        
        $finish;
    end
    
endmodule