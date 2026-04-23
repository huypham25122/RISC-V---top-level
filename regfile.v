module RegFile (
    input wire clk,
    input wire rst,
    input wire we,
    input wire [4:0] addr_a,
    input wire [4:0] addr_b,
    input wire [4:0] addr_d,
    input wire [31:0] data_d,
    output wire [31:0] data_a,
    output wire [31:0] data_b
);
    reg [31:0] registers [31:0];
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;
        end
        else if (we && addr_d != 5'b00000) begin
            registers[addr_d] <= data_d;
        end
    end

    assign data_a = (addr_a == 5'b00000) ? 32'b0 : registers[addr_a];
    assign data_b = (addr_b == 5'b00000) ? 32'b0 : registers[addr_b];
endmodule