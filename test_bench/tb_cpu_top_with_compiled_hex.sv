module tb_CPUTop;
    string dumpfile;
    integer tb_cycle_cnt = 0;
    parameter tb_NUM_BYTES = 1024;
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
    endgenerate;

    // -------------------------
    // Clock
    // -------------------------
    initial begin
        tb_clk = 0;
        forever begin
            #(tb_CLK_PERIOD/2) tb_clk = ~tb_clk;
            #1 if (tb_clk == 1'b1) begin
                tb_cycle_cnt = tb_cycle_cnt + 1;
            end
        end
    end

    // -------------------------
    // Utility Tasks
    // -------------------------
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

    task load_reg(input [4:0] register, input [31:0] data);
        DUT.registerFile.registers[register] = data;
    endtask

    // -------------------------
    // Utility Function
    // -------------------------
    function [31:0] read_reg(input [4:0] register);
        return DUT.registerFile.registers[register];
    endfunction

    // Checks for ecall instruction because the RTL haven't implemented it
    always @(posedge tb_clk) begin
        if (DUT.instr == 32'h00000073) begin
            $display("========================================");
            $display("Halting simulation. Test finished!");
            $display("ECALL detected at PC: 0x%08h", DUT.pc);
            $display("A0 = %d", read_reg(5'b1010));
            $display("Cycle Count = %d", tb_cycle_cnt);
            $display("========================================");
            $finish;
        end
    end

    initial begin
        if (!$value$plusargs("DUMPFILE=%s", dumpfile))
                dumpfile = "dump.fst";
        $dumpfile(dumpfile);
        $dumpvars();
        
        reset_dut();
        reset_mem();
        load_reg(5'b10, tb_NUM_BYTES - 1);

        // hardcoded path to main.hex
        $readmemh("./toy_compile/build/main.hex", DUT.instructionMemory.instruct_memory, 0, tb_NUM_BYTES-1);
    end
endmodule