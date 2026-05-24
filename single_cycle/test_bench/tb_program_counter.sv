module tb_PC;
    string dumpfile;
    parameter tb_CLK_PERIOD = 5;
    parameter tb_SETTLE = 1;
    logic tb_clk, tb_rst_n;
    logic tb_pc_src;
    logic [31:0] tb_imm_ext;
    logic [31:0] tb_pc;
    logic [31:0] tb_pc_target;
    logic [31:0] tb_pc_plus_4;

    ProgramCounter DUT(
        .clk(tb_clk),
        .rst_n(tb_rst_n),
        .pc_src(tb_pc_src),
        .imm_ext(tb_imm_ext),
        .pc(tb_pc),
        .pc_target(tb_pc_target),
        .pc_plus_4(tb_pc_plus_4)
    );

    initial begin
        tb_clk = 0;
        forever #(tb_CLK_PERIOD/2) tb_clk = ~tb_clk;
    end

    initial begin
        $value$plusargs("DUMPFILE=%s", dumpfile);
        $dumpfile(dumpfile);
        $dumpvars();
        
        tb_rst_n = 1'b0;
        @(negedge tb_clk);
        tb_rst_n = 1'b1;

        tb_pc_src = 1'b0;
        tb_imm_ext = 32'b0;
        @(posedge tb_clk); #tb_SETTLE;
        assert(tb_pc == 4)
            else $fatal(1, "pc expected %d, got %b", 4, tb_pc);
        
        tb_pc_src = 1'b1;
        tb_imm_ext = 32'b10;
        @(posedge tb_clk); #tb_SETTLE;
        assert(tb_pc == 6)
            else $fatal(1, "pc expected %d, got %b", 6, tb_pc);
        $finish;
    end

endmodule