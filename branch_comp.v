module BranchComp (
    input wire [31:0] rs1_data,
    input wire [31:0] rs2_data,
    input wire br_un,             // Tín hiệu từ Control: 1 nếu là Unsigned (BGEU, BLTU)
    output wire br_eq,            // Bằng nhau
    output wire br_lt             // Nhỏ hơn (Less than)
);
    assign br_eq = (rs1_data == rs2_data);
    
    // Nếu br_un = 1, so sánh không dấu. Nếu = 0, so sánh có dấu ($signed).
    assign br_lt = (br_un) ? (rs1_data < rs2_data) : ($signed(rs1_data) < $signed(rs2_data));
endmodule