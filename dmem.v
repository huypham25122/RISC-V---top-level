module DMEM (
    input wire clk,
    input wire we,              // Write Enable từ MemRW
    input wire [31:0] addr,
    input wire [31:0] data_w,   // Dữ liệu cần ghi
    output wire [31:0] data_r   // Dữ liệu đọc ra
);
    // Khai báo RAM 256 words (1KB)
    reg [31:0] ram [0:255];

    // Đọc bất đồng bộ
    assign data_r = ram[addr[9:2]];

    // Ghi đồng bộ theo sườn lên của clock
    always @(posedge clk) begin
        if (we) begin
            ram[addr[9:2]] <= data_w;
        end
    end
endmodule