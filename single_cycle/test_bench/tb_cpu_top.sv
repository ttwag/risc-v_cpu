module tb_CPUTop;
    string dumpfile;
    parameter tb_NUM_BYTES = 64;
    parameter tb_CLK_PERIOD = 5;
    logic tb_clk;
    logic tb_rst_n;
    logic [31:0] tb_instr;

    // -------------------------
    // DUT
    // -------------------------
    CPUTop #(
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
    // Tasks
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

    task reset_dut();
        tb_rst_n = 1'b0;
        @(posedge tb_clk); #1;
        tb_rst_n = 1'b1;
    endtask

    task test_load_and_add();

        // load data
        load_data(0, 32'b0011);
        load_data(4, 32'b0100);

        // load instructions
        load_instr(0, 32'b000000000000_00000_010_00010_0000011); // lw x2, 0(x0)
        load_instr(4, 32'b000000000100_00000_010_00001_0000011); // lw x1, 4(x0)
        load_instr(8, 32'b0000000_00010_00001_000_00001_0110011); // add x1, x1, x2

        // reset the register and pc to 0
        reset_dut();

        // check the state of reg after each instruction is done
        @(posedge tb_clk); #1;
        assert (DUT.registerFile.registers[2] == 3)
            else $fatal(1, "x2 expected 3, got %0d", DUT.registerFile.registers[2]);

        @(posedge tb_clk); #1;
        assert (DUT.registerFile.registers[1] == 4)
            else $fatal(1, "x1 expected 4, got %0d", DUT.registerFile.registers[1]);
        
        @(posedge tb_clk); #1;
        assert (DUT.registerFile.registers[1] == 7)
            else $fatal(1, "x1 expected 7, got %0d", DUT.registerFile.registers[1]);
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
        
        test_load_and_add();
        $finish;
    end


endmodule