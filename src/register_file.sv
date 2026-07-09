module RegisterFile(
    input logic clk, rst_n,
    input logic write_enable_addr_3,
    input logic [4:0] addr_1, addr_2, addr_3,
    input logic [31:0] write_data_addr_3,
    output logic [31:0] read_data_addr_1, read_data_addr_2
);
    logic [31:0] registers [31:0];
    
    assign read_data_addr_1 = (addr_1 != 5'b0) ? registers[addr_1] : 32'b0;
    assign read_data_addr_2 = (addr_2 != 5'b0) ? registers[addr_2] : 32'b0;
    
    always_ff @(posedge clk) begin
        if (rst_n == 0)
            for (int i = 0; i < 32; i++)
                registers[i] <= '0;
        else if (write_enable_addr_3 && addr_3 != 5'b0)
            registers[addr_3] <= write_data_addr_3;
    end
    
endmodule