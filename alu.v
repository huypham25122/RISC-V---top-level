ư`timescale 1ns / 1ps

module ALU (
    input wire [31:0] a,         // Toán hạng A (thường từ RegA hoặc PC)
    input wire [31:0] b,         // Toán hạng B (thường từ RegB hoặc Immediate)
    input wire [3:0] alu_sel,    // Tín hiệu chọn phép toán từ Control Unit
    output reg [31:0] alu_out    // Kết quả tính toán của ALU
);

    always @(*) begin
        // Giá trị mặc định để tránh chốt ngầm (inferred latch) khi tổng hợp phần cứng
        alu_out = 32'b0;

        case (alu_sel)
            // Phép toán số học cơ bản
            4'b0000: alu_out = a + b;                        // ADD  (Cộng)
            4'b0001: alu_out = a - b;                        // SUB  (Trừ)
            
            // Phép toán dịch bit (Shift)
            // Lưu ý: Chỉ dịch tối đa 31 bit, nên ta lấy 5 bit cuối của b (b[4:0])
            4'b0010: alu_out = a << b[4:0];                  // SLL  (Dịch trái logic)
            4'b0110: alu_out = a >> b[4:0];                  // SRL  (Dịch phải logic - không giữ dấu)
            4'b0111: alu_out = $signed(a) >>> b[4:0];        // SRA  (Dịch phải số học - giữ nguyên dấu)
            
            // Phép toán so sánh (Set Less Than)
            4'b0011: alu_out = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0; // SLT  (So sánh có dấu)
            4'b0100: alu_out = (a < b) ? 32'b1 : 32'b0;                   // SLTU (So sánh không dấu)
            
            // Phép toán logic (Bitwise)
            4'b0101: alu_out = a ^ b;                        // XOR
            4'b1000: alu_out = a | b;                        // OR
            4'b1001: alu_out = a & b;                        // AND
            
            // Các phép toán đặc biệt
            4'b1111: alu_out = b;                            // PASS_B (Chỉ xuất toán hạng B - Dùng cho lệnh LUI)
            
            // Xử lý các trường hợp không xác định
            default: alu_out = 32'b0;
        endcase
    end

endmodule