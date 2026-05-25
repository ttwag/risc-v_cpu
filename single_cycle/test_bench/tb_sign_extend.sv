module tb_SignExtend;
    string dumpfile;
    logic [31:0] tb_instr;
    logic [2:0] tb_imm_src;
    logic [31:0] tb_imm_ext;
    logic [31:0] expected_imm_ext;


    SignExtend DUT(
        .instr(tb_instr),
        .imm_src(tb_imm_src),
        .imm_ext(tb_imm_ext)
    );

    initial begin
        $value$plusargs("DUMPFILE=%s", dumpfile);
        $dumpfile(dumpfile);
        $dumpvars();
        
        // I-type instruction
        tb_imm_src = 3'b00;
        tb_instr = 32'b111000110100_00000000000000000000; // sign=1, imm=0xE34
        expected_imm_ext = 32'hFFFFF_E34;
        
        #5;
        assert (tb_imm_ext == expected_imm_ext)
            else $fatal(1, "I-Type instruction Assertion failed: %h != %h (expected)", tb_imm_ext, expected_imm_ext);

        // I-type shift arithmetic instruction
        tb_imm_src = 3'b100;
        tb_instr = 32'b000000010001_00010_101_00010_0010011; // imm=0x11
        expected_imm_ext = 32'h11;
        
        #5;
        assert (tb_imm_ext == expected_imm_ext)
            else $fatal(1, "I-Type Shift Arithmetic instruction Assertion failed: %h != %h (expected)", tb_imm_ext, expected_imm_ext);

        // S-type instruction
        tb_imm_src = 3'b01;
        tb_instr = 32'b0011000_1010000000000_01110_0000000; // sign=0, imm=0x30E
        expected_imm_ext = 32'h00000_30E;
        
        #5;
        assert (tb_imm_ext == expected_imm_ext)
            else $fatal(1, "S-Type instruction Assertion failed: %h != %h (expected)", tb_imm_ext, expected_imm_ext);
        

        // B-type instruction
        tb_imm_src = 3'b10;
        tb_instr = 32'b0_111000_1010000000000_0111_0_0000000; // sign=0, imm=0xF0E
        expected_imm_ext = 32'h00000_70E;
        #5;
        assert (tb_imm_ext == expected_imm_ext)
            else $fatal(1, "B-Type instruction Assertion failed: %h != %h (expected)", tb_imm_ext, expected_imm_ext);

        // J-type instruction
        tb_imm_src = 3'b11;
        tb_instr = 32'b1_0100101101_0_10100101_011100000000; // sign=0, imm=0x1_10100101_0_01001011010 = 0xFFF_A525A
        expected_imm_ext = 32'hFFF_A525A;
        #5;
        assert (tb_imm_ext == expected_imm_ext)
            else $fatal(1, "J-Type instruction Assertion failed: %h != %h (expected)", tb_imm_ext, expected_imm_ext);

        tb_imm_src = 3'b101;
        tb_instr = 32'b00000000000000001010_00001_0110111; //upimm={20'b1010, 12'b0}
        expected_imm_ext = {20'b1010, 12'b0};
        #5;
        assert (tb_imm_ext == expected_imm_ext)
            else $fatal(1, "U-Type instruction Assertion failed: %h != %h (expected)", tb_imm_ext, expected_imm_ext);
        
        $finish;
    end

endmodule