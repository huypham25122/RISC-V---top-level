module riscv_single_cycle (
    input wire clk,
    input wire rst
);

    wire [31:0] pc_current, pc_next, pc_plus_4;
    wire [31:0] instr;
    wire [31:0] data_a, data_b, data_d;
    wire [31:0] imm;
    wire [31:0] alu_a, alu_b, alu_out;
    wire [31:0] mem_data_r;

    wire pc_sel, reg_wen, br_un, b_sel, a_sel, mem_rw;
    wire [2:0] imm_sel;
    wire [3:0] alu_sel;
    wire [1:0] wb_sel;
    wire br_eq, br_lt;

    assign pc_plus_4 = pc_current + 4;
    assign pc_next = (pc_sel) ? alu_out : pc_plus_4;

    PC_Reg pc_inst (
        .clk(clk),
        .rst(rst),
        .d(pc_next),
        .q(pc_current)
    );

    IMEM imem_inst (
        .address(pc_current),
        .inst(instr)
    );

    ControlUnit cu_inst (
        .inst(instr),
        .br_eq(br_eq),
        .br_lt(br_lt),
        .pc_sel(pc_sel),
        .imm_sel(imm_sel),
        .reg_wen(reg_wen),
        .br_un(br_un),
        .b_sel(b_sel),
        .a_sel(a_sel),
        .alu_sel(alu_sel),
        .mem_rw(mem_rw),
        .wb_sel(wb_sel)
    );

    RegFile rf_inst (
        .clk(clk),
        .rst(rst),
        .we(reg_wen),
        .addr_a(instr[19:15]),
        .addr_b(instr[24:20]),
        .addr_d(instr[11:7]),
        .data_d(data_d),
        .data_a(data_a),
        .data_b(data_b)
    );

    ImmGen immgen_inst (
        .inst(instr[31:7]),
        .imm_sel(imm_sel),
        .imm(imm)
    );

    BranchComp brcomp_inst (
        .rs1_data(data_a),
        .rs2_data(data_b),
        .br_un(br_un),
        .br_eq(br_eq),
        .br_lt(br_lt)
    );

    assign alu_a = (a_sel) ? pc_current : data_a;
    assign alu_b = (b_sel) ? imm : data_b;

    ALU alu_inst (
        .a(alu_a),
        .b(alu_b),
        .alu_sel(alu_sel),
        .alu_out(alu_out)
    );

    DMEM dmem_inst (
        .clk(clk),
        .we(mem_rw),
        .funct3(instr[14:12]),
        .addr(alu_out),
        .data_w(data_b),
        .data_r(mem_data_r)
    );

    assign data_d = (wb_sel == 2'b00) ? mem_data_r :
                    (wb_sel == 2'b01) ? alu_out    :
                    (wb_sel == 2'b10) ? pc_plus_4  : 32'b0;

endmodule