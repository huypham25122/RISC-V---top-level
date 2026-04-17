module PC_Reg (
    input wire clk,
    input wire rst,
    input wire [31:0] d,
    output reg [31:0] q
);
    always @(posedge clk or posedge rst) begin
        if (rst) 
            q <= 32'h00000000; // Reset PC về địa chỉ bắt đầu
        else     
            q <= d;            // Cập nhật PC mới
    end
endmodule