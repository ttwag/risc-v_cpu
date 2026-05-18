module RegisterFile(
    input logic CLK, rst_n,
    input logic WE3,
    input logic [4:0] A1, A2, A3,
    input logic [31:0] WD3,
    output logic [31:0] RD1, RD2
);
    logic [31:0] registers [31:0];
    
    assign RD1 = (A1 != 5'b0) ? registers[A1] : 32'b0;
    assign RD2 = (A2 != 5'b0) ? registers[A2] : 32'b0;
    
    always_ff @(posedge CLK) begin
        if (rst_n == 0)
            for (int i = 0; i < 32; i++)
                registers[i] <= '0;
        else if (WE3 && A3 != 5'b0)
            registers[A3] <= WD3;
    end
    
endmodule