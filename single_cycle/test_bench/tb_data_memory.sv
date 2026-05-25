module tb_DataMemory;
    string dumpfile;
    logic tb_clk;
    logic tb_write_enable;
    logic [31:0] tb_addr;
    logic [31:0] tb_write_data;
    logic [31:0] tb_read_data;
    logic [2:0] tb_mem_width = 3'b000;
    parameter CLK_PERIOD = 10;
    parameter tb_NUM_BYTES = 64;

    DataMemory #(.NUM_BYTES(tb_NUM_BYTES)) DUT(
        .clk(tb_clk), 
        .write_enable(tb_write_enable),
        .addr(tb_addr),
        .write_data(tb_write_data),
        .mem_width(tb_mem_width),
        .read_data(tb_read_data)
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
    // Read Function
    // -------------------------
    function [31:0] read_data(input integer addr);
        return {DUT.memory[addr + 3], DUT.memory[addr + 2], DUT.memory[addr + 1], DUT.memory[addr]};
    endfunction


    // -------------------------
    // Tests
    // -------------------------
    task test_lb();
        tb_addr = 32'b0;
        tb_mem_width = 3'b000;

        load_data(tb_addr, 32'b11010111_01010100);

        @(posedge tb_clk); #1
        assert (tb_read_data == 32'b01010100) //test no sign extension
            else $fatal(1, "read_data expected %b, got %b", 32'b01010100, tb_read_data);

        tb_addr = tb_addr + 1;
        @(posedge tb_clk); #1
        assert (tb_read_data == 32'($signed(8'b11010111))) //test sign extension
            else $fatal(1, "read_data expected %b, got %b", 32'($signed(8'b11010111)), tb_read_data);
    endtask

    task test_lh();
        tb_addr = 32'b0;
        tb_mem_width = 3'b001;

        load_data(tb_addr, 32'b1000000000000000_0101011101010100);

        @(posedge tb_clk); #1
        assert (tb_read_data == 32'b0101011101010100) //test no sign extension
            else $fatal(1, "read_data expected %b, got %b", 32'b01010100, tb_read_data);

        tb_addr = tb_addr + 2;
        @(posedge tb_clk); #1
        assert (tb_read_data == 32'($signed(16'b1000000000000000))) //test sign extension
            else $fatal(1, "read_data expected %b, got %b", 32'($signed(16'b1000000000000000)), tb_read_data);
    endtask

    task test_lw();
        tb_addr = 32'b0;
        tb_mem_width = 3'b010;
        load_data(tb_addr, 32'b10000000000000000101011101010100);

        @(posedge tb_clk); #1
        assert (tb_read_data == 32'b10000000000000000101011101010100)
            else $fatal(1, "read_data expected %b, got %b", 32'b10000000000000000101011101010100, tb_read_data);
    endtask

    task test_lbu();
        tb_addr = 32'b0;
        tb_mem_width = 3'b100;

        load_data(tb_addr, 32'b11011111_01010101);

        @(posedge tb_clk); #1
        assert (tb_read_data == 32'b01010101) //test no sign extension
            else $fatal(1, "read_data expected %b, got %b", 32'b01010101, tb_read_data);

        tb_addr = tb_addr + 1;
        @(posedge tb_clk); #1
        assert (tb_read_data == 32'b11011111) //test zero extension on negative number
            else $fatal(1, "read_data expected %b, got %b", 32'b11011111, tb_read_data);
    endtask

    task test_lhu();
        tb_addr = 32'b0;
        tb_mem_width = 3'b101;

        load_data(tb_addr, 32'b1000000010000000_0101011001010100);

        @(posedge tb_clk); #1
        assert (tb_read_data == 32'b0101011001010100) //test no sign extension
            else $fatal(1, "read_data expected %b, got %b", 32'b0101011001010100, tb_read_data);

        tb_addr = tb_addr + 2;
        @(posedge tb_clk); #1
        assert (tb_read_data == 32'b1000000010000000) //test zero extension on negative number
            else $fatal(1, "read_data expected %b, got %b", 32'b1000000010000000, tb_read_data);
    endtask

    task test_read_after_write();
        tb_addr = 32'b0;
        tb_write_data = 32'b1;
        tb_write_enable = 1'b1;
        tb_mem_width = 3'b010;

        @(posedge tb_clk); #1
        assert (tb_read_data == tb_write_data)
            else $fatal(1, "Read Write Mismatched: %b (read_data) != %b write_data", tb_read_data, tb_write_data);
        tb_write_enable = 1'b0;
    endtask

    task test_sb();
        tb_addr = 32'b0;
        tb_write_data = 32'b1_0000_0001;
        tb_write_enable = 1'b1;
        tb_mem_width = 3'b000;
        load_data(tb_addr, 32'b0);


        // store at clock edge then read after some delay
        @(posedge tb_clk); #1
        assert (read_data(tb_addr) == {24'b0, tb_write_data[7:0]})
            else $fatal(1, "Expected %b to be read, got %b", {24'b0, tb_write_data[7:0]}, read_data(tb_addr));
    endtask

    task test_sh();
        tb_addr = 32'b0;
        tb_write_data = 32'b1_0000_0001;
        tb_write_enable = 1'b1;
        tb_mem_width = 3'b001;

        load_data(tb_addr, 32'b0);

        @(posedge tb_clk); #1
        assert (read_data(tb_addr) == {16'b0, tb_write_data[15:0]})
            else $fatal(1, "Expected %b to be read, got %b", {16'b0, tb_write_data[15:0]}, read_data(tb_addr));
    endtask

    task test_sw();
        tb_addr = 32'b0;
        tb_write_data = 32'b1_0000_0001;
        tb_write_enable = 1'b1;
        tb_mem_width = 3'b010;

        @(posedge tb_clk); #1
        assert (read_data(tb_addr) == tb_write_data)
            else $fatal(1, "Expected %b to be read, got %b", tb_write_data, read_data(tb_addr));
    endtask

    initial begin
        tb_clk = 0;
        forever #(CLK_PERIOD/2) tb_clk = ~tb_clk;
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
        test_sb();
        test_sh();
        test_sw();
        test_read_after_write();
        
        $finish;
    end
    
endmodule