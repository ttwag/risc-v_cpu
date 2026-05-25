module tb_CPUTop;
    string dumpfile;
    parameter tb_NUM_BYTES = 64;
    parameter tb_CLK_PERIOD = 5;
    parameter tb_SETTLE = 1; // must be >= 1 and < tb_CLK_PERIOD/2
    logic tb_clk;
    logic tb_rst_n;
    logic [31:0] tb_instr;

    // -------------------------
    // DUT
    // -------------------------
    CpuTop #(
        .CLK_PERIOD(tb_CLK_PERIOD),
        .NUM_BYTES(tb_NUM_BYTES)
    ) DUT(
        .clk(tb_clk),
        .rst_n(tb_rst_n)
    );
    
    // -------------------------
    // Waveform viewer for register
    // -------------------------
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : clean_reg
            // By declaring it INSIDE, every index gets its own isolated 32-bit tracking wire
            wire [31:0] view_reg;
            assign view_reg = DUT.registerFile.registers[i]; 
        end
    endgenerate


    // -------------------------
    // Utility Tasks
    // -------------------------
    task load_instr(input integer addr, input [31:0] instr);
        DUT.instructionMemory.instruct_memory[addr]   = instr[7:0];
        DUT.instructionMemory.instruct_memory[addr+1] = instr[15:8];
        DUT.instructionMemory.instruct_memory[addr+2] = instr[23:16];
        DUT.instructionMemory.instruct_memory[addr+3] = instr[31:24];    
    endtask

    task load_data(input integer addr, input [31:0] data);
        DUT.dataMemory.memory[addr]   = data[7:0];
        DUT.dataMemory.memory[addr+1] = data[15:8];
        DUT.dataMemory.memory[addr+2] = data[23:16];
        DUT.dataMemory.memory[addr+3] = data[31:24];    
    endtask

    task load_reg(input [4:0] register, input [31:0] data);
        DUT.registerFile.registers[register] = data;
    endtask

    task reset_dut();
        tb_rst_n = 1'b0;
        @(posedge tb_clk); #tb_SETTLE;
        tb_rst_n = 1'b1;
    endtask

    task reset_mem();
        for (int i = 0; i < tb_NUM_BYTES; i++) begin
            DUT.instructionMemory.instruct_memory[i] = 8'b0;
            DUT.dataMemory.memory[i] = 8'b0;
        end
    endtask

    // -------------------------
    // Utility Functions
    // -------------------------
    function [31:0] read_reg(input [4:0] register);
        return DUT.registerFile.registers[register];
    endfunction

    // -------------------------
    // Test Tasks
    // -------------------------
    task test_load_and_add();
        // reset memory so this test stays clean from other tests
        reset_mem();
        
        // reset the register and pc to 0
        reset_dut();
        
        // load data
        load_data(0, 32'b0011);
        load_data(4, 32'b0100);

        // load instructions
        load_instr(0, 32'b000000000000_00000_010_00010_0000011); // lw x2, 0(x0)
        load_instr(4, 32'b000000000100_00000_010_00001_0000011); // lw x1, 4(x0)
        load_instr(8, 32'b0000000_00010_00001_000_00001_0110011); // add x1, x1, x2

        // check the state of reg after each instruction is done
        @(posedge tb_clk); #tb_SETTLE;
        assert (read_reg(2) == 3)
            else $fatal(1, "x2 expected 3, got %0d", read_reg(2));

        @(posedge tb_clk); #tb_SETTLE;
        assert (read_reg(1) == 4)
            else $fatal(1, "x1 expected 4, got %0d", read_reg(1));
        
        @(posedge tb_clk); #tb_SETTLE;
        assert (read_reg(1) == 7)
            else $fatal(1, "x1 expected 7, got %0d", read_reg(1));
    endtask

    task test_store_and_load();
        reset_mem();
        reset_dut();
        load_reg(5'b11, 32'b1011);
        load_instr(0, 32'b0000000_00011_00000_010_01000_0100011); //sw x3, 8(x0)
        load_instr(4, 32'b000000001000_00000_010_00010_0000011); //lw x2, 8(x0)
        
        @(posedge tb_clk); #tb_SETTLE;

        @(posedge tb_clk); #tb_SETTLE;
        assert (read_reg(2) == 11)
            else $fatal(1, "x2 expected 11, got %0d", read_reg(2));
    endtask

    task test_r_type_instr();
        reset_mem();
        reset_dut();
        load_reg(5'b10, 32'b1111); //x2 = 32'b1111
        load_reg(5'b11, 32'b1111); //x3 = 32'b1111
        
        load_instr(0, 32'b0000000_00011_00010_000_00001_0110011); //add x1, x2, x3
        load_instr(4, 32'b0100000_00011_00001_000_00001_0110011); //sub x1, x1, x3
        load_instr(8, 32'b0000000_00000_00010_111_00001_0110011); //and x1, x2, x0
        load_instr(12, 32'b0000000_00011_00010_110_00001_0110011); //or x1, x2, x3
        load_instr(16, 32'b0000000_00011_00010_010_00001_0110011); //slt x1, x2, x3

        @(posedge tb_clk); #tb_SETTLE;
        assert (read_reg(1) == 30)
            else $fatal(1, "x1 expected 30, got %0d", read_reg(1));

        @(posedge tb_clk); #tb_SETTLE;
        assert (read_reg(1) == 15)
            else $fatal(1, "x1 expected 15, got %0d", read_reg(1));

        @(posedge tb_clk); #tb_SETTLE;
        assert (read_reg(1) == 0)
            else $fatal(1, "x1 expected 0, got %0d", read_reg(1));

        @(posedge tb_clk); #tb_SETTLE;
        assert (read_reg(1) == 15)
            else $fatal(1, "x1 expected 15, got %0d", read_reg(1));

        @(posedge tb_clk); #tb_SETTLE;
        assert (read_reg(1) == 0)
            else $fatal(1, "x1 expected 0, got %0d", read_reg(1));
    endtask

    task test_add_branch_equal();
        reset_mem();
        reset_dut();
        load_reg(5'b1, 32'b1); //x1 = 32'b1

        load_instr(0, 32'b0000000_00001_00000_000_00010_0110011); //add x2 x0, x1
        load_instr(4, 32'b0000000_00001_00010_000_01000_1100011); //beq x2, x1, 8
        load_instr(12, 32'b0000000_00000_00010_000_01000_1100011); //beq x2, x0, 8

        @(posedge tb_clk); #tb_SETTLE;
        assert (read_reg(2) == 1)
            else $fatal(1, "x2 expected 1, got %0d", read_reg(2));
        
        @(posedge tb_clk); #tb_SETTLE;
        assert (DUT.pc == 12)
            else $fatal(1, "pc expected 12, got %0d", DUT.pc);

        @(posedge tb_clk); #tb_SETTLE;
        assert (DUT.pc == 16)
            else $fatal(1, "pc expected 16, got %0d", DUT.pc);
    endtask

    task test_sltiu_branch_equal();
        reset_mem();
        reset_dut();

        load_instr(0, 32'b100000000000_00000_011_00010_0010011); //sltiu x2, x0, 12'b100000000000
        load_instr(4, 32'b0000000_00000_00010_000_01000_1100011); //beq x2, x0, 8

        @(posedge tb_clk); #tb_SETTLE;
        assert (read_reg(2) == 1)
            else $fatal(1, "x2 expected 1, got %0d", read_reg(2));

        // expects branch is not true: pc := pc + 4
        @(posedge tb_clk); #tb_SETTLE;
        assert (DUT.pc == 8)
            else $fatal(1, "pc expected 8, got %0d", DUT.pc);
    endtask

    task test_slli_branch_equal();
        reset_mem();
        reset_dut();
        load_reg(5'b10, 32'b1); //x2 = 1
        load_reg(5'b1, 32'b1_0000_0000_0000_0000); //x1 = 16

        load_instr(0, 32'b000000010000_00010_001_00010_0010011); //slli x2, x2, 16
        load_instr(4, 32'b0000000_00001_00010_000_01000_1100011); //beq x2, x1, 8

        @(posedge tb_clk); #tb_SETTLE;
        assert (read_reg(2) == 32'b1_0000_0000_0000_0000)
            else $fatal(1, "x2 expected 16, got 0x%h", read_reg(2));

        // expects branch is true: pc := pc + 8
        @(posedge tb_clk); #tb_SETTLE;
        assert (DUT.pc == 12)
            else $fatal(1, "pc expected 12, got %0d", DUT.pc);
    endtask

    task test_addi_branch_less_than_unsigned();
        reset_mem();
        reset_dut();
        
        load_instr(0, 32'b111111111111_00000_000_00001_0010011); //addi x1, x0, -1
        load_instr(4, 32'b0000000_00001_00000_110_01000_1100011); //bltu x0, x1, 8

        @(posedge tb_clk); #tb_SETTLE;
        assert (read_reg(1) == -32'sd1)
            else $fatal(1, "x1 expected %h, got 0x%h", -32'sd1, read_reg(1));

        // expects branch is true: pc := pc + 8
        @(posedge tb_clk); #tb_SETTLE;
        assert (DUT.pc == 12)
            else $fatal(1, "pc expected 12, got %0d", DUT.pc);
    endtask

    task test_u_type_pc_relative_intr();
        reset_mem();
        reset_dut();
        
        load_instr(4, 32'b00000000000000000001_00001_0010111); //auipc x1, 1
        
        @(posedge tb_clk); #tb_SETTLE;
        // Do nothing
        @(posedge tb_clk); #tb_SETTLE;
        assert (read_reg(32'b1) == {20'b1, 12'b0} + 32'b100)
            else $fatal(1, "pc expected %b, got %b", {20'b1, 12'b0} + 32'b100, read_reg(32'b1));
    endtask

    task test_u_type_non_pc_relative_instr();
        reset_mem();
        reset_dut();
        
        load_instr(0, 32'b00000000000000001000_00001_0110111); //lui x1, 8
        
        @(posedge tb_clk); #tb_SETTLE;
        // Do nothing
        @(posedge tb_clk); #tb_SETTLE;
        assert (read_reg(32'b1) == {20'b1000, 12'b0})
            else $fatal(1, "pc expected %b, got %b", {20'b1, 12'b0}, read_reg(32'b1));
    endtask

    task test_jal();
        reset_mem();
        reset_dut();
        
        load_instr(0, 32'b0_0000010000_0_00000000_00001_1101111); //jal x1, 16
        @(posedge tb_clk); #tb_SETTLE;
        assert (read_reg(32'b1) == 4)
            else $fatal(1, "x1 expected %d, got %b", 4, read_reg(32'b1));
        assert (DUT.pc == 32)
            else $fatal(1, "pc expected %d, got %b", 32, DUT.pc);
    endtask

    task test_addi_jalr();
        reset_mem();
        reset_dut();
        
        load_instr(0, 32'b000000000101_00000_000_00001_0010011); //addi x1, x0, 5
        load_instr(4, 32'b000000001000_00001_000_00001_1100111); //jalr x1, x1, 8

        @(posedge tb_clk); #tb_SETTLE;
        assert (read_reg(32'b1) == 5)
            else $fatal(1, "x1 expected %d, got %b", 5, read_reg(32'b1));
        
        @(posedge tb_clk); #tb_SETTLE;
        assert (read_reg(32'b1) == 8)
            else $fatal(1, "x1 expected %d, got %b", 8, read_reg(32'b1));
        assert (DUT.pc == 13)
            else $fatal(1, "pc expected %d, got %b", 13, DUT.pc);
    endtask

    // -------------------------
    // Clock
    // -------------------------
    initial begin
        tb_clk = 0;
        forever #(tb_CLK_PERIOD/2) tb_clk = ~tb_clk;
    end

    // -------------------------
    // Main test
    // -------------------------
    initial begin
        if (!$value$plusargs("DUMPFILE=%s", dumpfile))
                dumpfile = "dump.fst";
        $dumpfile(dumpfile);
        $dumpvars();
        
        test_r_type_instr();
        test_load_and_add();
        test_store_and_load();
        test_add_branch_equal();
        test_sltiu_branch_equal();
        test_slli_branch_equal();
        test_addi_branch_less_than_unsigned();
        test_u_type_pc_relative_intr();
        test_u_type_non_pc_relative_instr();
        test_jal();
        test_addi_jalr();
        // test b type
        // test branch taken
        // test branch not taken
        // test immediate
        // test jump
        $finish;
    end


endmodule