module Alu(
  input logic signed [31:0] src_a, src_b,
  input logic [3:0] alu_control,
  output logic [31:0] alu_result,
  output logic zero
);

assign zero = alu_result == 0;

always_comb begin
  case (alu_control)
    4'b0000 : alu_result = src_a + src_b;
    4'b0001 : alu_result = src_a - src_b;
    4'b0010 : alu_result = src_a & src_b;
    4'b0011 : alu_result = src_a | src_b;
    4'b0100 : alu_result = src_a ^ src_b;
    4'b0101 : alu_result = {31'b0, src_a < src_b};
    4'b0110 : alu_result = {31'b0, $unsigned(src_a) < $unsigned(src_b)};
    4'b0111 : alu_result = $unsigned(src_a) << src_b;
    4'b1000 : alu_result = $unsigned(src_a) >> src_b;
    4'b1001 : alu_result = src_a >>> src_b;
    default : alu_result = 32'bx;
  endcase
end

endmodule