module ALU(
  input logic signed [31:0] SrcA, SrcB,
  input logic [3:0] ALUControl,
  output logic [31:0] ALUResult,
  output logic Zero
);

assign Zero = ALUResult == 0;

always_comb begin
  case (ALUControl)
    4'b0000 : ALUResult = SrcA + SrcB;
    4'b0001 : ALUResult = SrcA - SrcB;
    4'b0010 : ALUResult = SrcA & SrcB;
    4'b0011 : ALUResult = SrcA | SrcB;
    4'b0100 : ALUResult = SrcA ^ SrcB;
    4'b0101 : ALUResult = {31'b0, SrcA < SrcB};
    4'b0110 : ALUResult = {31'b0, $unsigned(SrcA) < $unsigned(SrcB)};
    4'b0111 : ALUResult = $unsigned(SrcA) << SrcB;
    4'b1000 : ALUResult = $unsigned(SrcA) >> SrcB;
    4'b1001 : ALUResult = SrcA >>> SrcB;
    default : ALUResult = 32'bx;
  endcase
end

endmodule