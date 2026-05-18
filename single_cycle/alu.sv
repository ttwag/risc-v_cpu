module ALU(
  input logic signed [31:0] SrcA, SrcB,
  input logic [2:0] ALUControl,
  output logic [31:0] ALUResult,
  output logic Zero
);

assign Zero = ALUResult == 0;

always_comb begin
  case (ALUControl)
    3'b000 : ALUResult = SrcA + SrcB;
    3'b001 : ALUResult = SrcA - SrcB;
    3'b010 : ALUResult = SrcA & SrcB;
    3'b011 : ALUResult = SrcA | SrcB;
    3'b101 : ALUResult = {31'b0, SrcA < SrcB};
    default : ALUResult = 32'bx;
  endcase  
end

endmodule