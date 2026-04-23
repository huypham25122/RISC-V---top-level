module BranchComp (
    input wire [31:0] rs1_data,
    input wire [31:0] rs2_data,
    input wire br_un,
    output wire br_eq,
    output wire br_lt
);
    assign br_eq = (rs1_data == rs2_data);

    assign br_lt = (br_un) ? (rs1_data < rs2_data) : ($signed(rs1_data) < $signed(rs2_data));
endmodule