module tb_SignExtend;
    string dumpfile;
    logic [31:0] tb_Instr;
    logic [2:0] tb_ImmSrc;
    logic [31:0] tb_ImmExt;
    logic [31:0] expected_ImmExt;


    SignExtend DUT(
        .Instr(tb_Instr),
        .ImmSrc(tb_ImmSrc),
        .ImmExt(tb_ImmExt)
    );

    initial begin
        $value$plusargs("DUMPFILE=%s", dumpfile);
        $dumpfile(dumpfile);
        $dumpvars();
        
        // I-type instruction
        tb_ImmSrc = 3'b00;
        tb_Instr = 32'b111000110100_00000000000000000000; // sign=1, imm=0xE34
        expected_ImmExt = 32'hFFFFF_E34;
        
        #5;
        assert (tb_ImmExt == expected_ImmExt)
            else $fatal(1, "I-Type Instruction Assertion failed: %h != %h (expected)", tb_ImmExt, expected_ImmExt);

        // I-type shift arithmetic instruction
        tb_ImmSrc = 3'b100;
        tb_Instr = 32'b000000010001_00010_101_00010_0010011; // imm=0x11
        expected_ImmExt = 32'h11;
        
        #5;
        assert (tb_ImmExt == expected_ImmExt)
            else $fatal(1, "I-Type Shift Arithmetic Instruction Assertion failed: %h != %h (expected)", tb_ImmExt, expected_ImmExt);

        // S-type instruction
        tb_ImmSrc = 3'b01;
        tb_Instr = 32'b0011000_1010000000000_01110_0000000; // sign=0, imm=0x30E
        expected_ImmExt = 32'h00000_30E;
        
        #5;
        assert (tb_ImmExt == expected_ImmExt)
            else $fatal(1, "S-Type Instruction Assertion failed: %h != %h (expected)", tb_ImmExt, expected_ImmExt);
        

        // B-type instruction
        tb_ImmSrc = 3'b10;
        tb_Instr = 32'b0_111000_1010000000000_0111_0_0000000; // sign=0, imm=0xF0E
        expected_ImmExt = 32'h00000_70E;
        #5;
        assert (tb_ImmExt == expected_ImmExt)
            else $fatal(1, "B-Type Instruction Assertion failed: %h != %h (expected)", tb_ImmExt, expected_ImmExt);

        // J-type instruction
        tb_ImmSrc = 3'b11;
        tb_Instr = 32'b1_0100101101_0_10100101_011100000000; // sign=0, imm=0x1_10100101_0_01001011010 = 0xFFF_A525A
        expected_ImmExt = 32'hFFF_A525A;
        #5;
        assert (tb_ImmExt == expected_ImmExt)
            else $fatal(1, "J-Type Instruction Assertion failed: %h != %h (expected)", tb_ImmExt, expected_ImmExt);
        
        $finish;
    end

endmodule