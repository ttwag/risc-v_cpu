module tb_alu;
  logic signed [31:0] tb_src_a;
  logic signed [31:0] tb_src_b;
  logic [2:0] tb_control;
  logic tb_zero;
  logic [31:0] tb_result;
  string dumpfile;

  ALU TestALU(.SrcA(tb_src_a), .SrcB(tb_src_b), .ALUControl(tb_control),
  .Zero(tb_zero), .ALUResult(tb_result));
  
  initial begin
    // for waveform analysis
    $value$plusargs("DUMPFILE=%s", dumpfile);
    $dumpfile(dumpfile);
    $dumpvars();

    repeat (16) begin
      tb_src_a = $urandom(); 
      tb_src_b = $urandom();
      
      tb_control = 3'b000;
      #10;
      assert (tb_result == tb_src_a + tb_src_b);
    	    else $fatal(1, "ADDITION failed, got %b with %b & %b", tb_result, tb_src_a, tb_src_b);

      tb_control = 3'b001;
      #10;
      assert (tb_result == tb_src_a - tb_src_b);
        else $fatal(1, "SUBTRACTION failed, got %b with %b & %b", tb_result, tb_src_a, tb_src_b);
      tb_control = 3'b010;
      #10;
      assert (tb_result == (tb_src_a & tb_src_b));
        else $fatal(1, "AND failed, got %b with %b & %b", tb_result, tb_src_a, tb_src_b);

      tb_control = 3'b011;
      #10; 
      assert (tb_result == (tb_src_a | tb_src_b));
        else $fatal(1, "OR failed, got %b with %b & %b", tb_result, tb_src_a, tb_src_b);

      tb_control = 3'b101;
      #10;
      assert (tb_result == {31'b0, tb_src_a < tb_src_b});
        else $fatal(1, "COMPARISON failed, got %b with %b & %b", tb_result, tb_src_a, tb_src_b);

      tb_control = 3'b111;
      #10;
      assert (tb_result == 32'b0);
        else $fatal(1, "DEFAULT failed, got %b with %b & %b", tb_result, tb_src_a, tb_src_b);
    end
    
  end
  
endmodule