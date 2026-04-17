module IMEM (
    input wire [31:0] address,
    output wire [31:0] inst
);
    // Khai báo bộ nhớ 256 words (1024 Bytes / 1KB)
    reg [31:0] rom [0:255];

    initial begin
        // Nạp file mã máy vào rom khi bắt đầu mô phỏng
        $readmemh("imem.hex", rom); 
    end

    // Đọc bất đồng bộ (Asynchronous read) cho Single-Cycle
    // address[9:2] dịch địa chỉ byte thành chỉ số mảng (chia cho 4)
    assign inst = rom[address[9:2]];
endmodule