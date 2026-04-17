module RegFile (
    input wire clk,
    input wire rst,
    input wire we,              // Write Enable
    input wire [4:0] addr_a,    // rs1
    input wire [4:0] addr_b,    // rs2
    input wire [4:0] addr_d,    // rd
    input wire [31:0] data_d,
    output wire [31:0] data_a,
    output wire [31:0] data_b
);
    reg [31:0] registers [31:0];
    integer i;

    // Ghi dữ liệu đồng bộ
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) 
                registers[i] <= 32'b0;
        end 
        // Không cho phép ghi vào thanh ghi x0 (addr_d != 0)
        else if (we && addr_d != 5'b00000) begin
            registers[addr_d] <= data_d;
        end
    end

    // Đọc dữ liệu bất đồng bộ. Nếu địa chỉ là 0, luôn xuất ra 0.
    assign data_a = (addr_a == 5'b00000) ? 32'b0 : registers[addr_a];
    assign data_b = (addr_b == 5'b00000) ? 32'b0 : registers[addr_b];
endmodule