module ControlUnit (
    input wire [31:0] inst,
    input wire br_eq,
    input wire br_lt,

    output reg pc_sel,
    output reg [2:0] imm_sel,
    output reg reg_wen,
    output reg br_un,
    output reg b_sel,
    output reg a_sel,
    output reg [3:0] alu_sel,
    output reg mem_rw,
    output reg [1:0] wb_sel
);

    wire [6:0] opcode = inst[6:0];
    wire [2:0] funct3 = inst[14:12];
    wire [6:0] funct7 = inst[31:25];

    localparam OPCODE_R     = 7'b0110011;
    localparam OPCODE_I_ARI = 7'b0010011;
    localparam OPCODE_LOAD  = 7'b0000011;
    localparam OPCODE_STORE = 7'b0100011;
    localparam OPCODE_BRANCH= 7'b1100011;
    localparam OPCODE_JAL   = 7'b1101111;
    localparam OPCODE_JALR  = 7'b1100111;
    localparam OPCODE_LUI   = 7'b0110111;
    localparam OPCODE_AUIPC = 7'b0010111;

    always @(*) begin
        pc_sel  = 1'b0;
        imm_sel = 3'b000;
        reg_wen = 1'b0;
        br_un   = 1'b0;
        b_sel   = 1'b0;
        a_sel   = 1'b0;
        alu_sel = 4'b0000;
        mem_rw  = 1'b0;
        wb_sel  = 2'b01;

        case (opcode)
            OPCODE_R: begin
                reg_wen = 1'b1;
                b_sel   = 1'b0;
                a_sel   = 1'b0;
                wb_sel  = 2'b01;

                case (funct3)
                    3'b000: alu_sel = (funct7[5]) ? 4'b0001 : 4'b0000;
                    3'b001: alu_sel = 4'b0010;
                    3'b010: alu_sel = 4'b0011;
                    3'b011: alu_sel = 4'b0100;
                    3'b100: alu_sel = 4'b0101;
                    3'b101: alu_sel = (funct7[5]) ? 4'b0111 : 4'b0110;
                    3'b110: alu_sel = 4'b1000;
                    3'b111: alu_sel = 4'b1001;
                endcase
            end

            OPCODE_I_ARI: begin
                imm_sel = 3'b000;
                reg_wen = 1'b1;
                b_sel   = 1'b1;
                a_sel   = 1'b0;
                wb_sel  = 2'b01;

                case (funct3)
                    3'b000: alu_sel = 4'b0000;
                    3'b001: alu_sel = 4'b0010;
                    3'b010: alu_sel = 4'b0011;
                    3'b011: alu_sel = 4'b0100;
                    3'b100: alu_sel = 4'b0101;
                    3'b101: alu_sel = (funct7[5]) ? 4'b0111 : 4'b0110;
                    3'b110: alu_sel = 4'b1000;
                    3'b111: alu_sel = 4'b1001;
                endcase
            end

            OPCODE_LOAD: begin
                imm_sel = 3'b000;
                reg_wen = 1'b1;
                b_sel   = 1'b1;
                a_sel   = 1'b0;
                alu_sel = 4'b0000;
                wb_sel  = 2'b00;
            end

            OPCODE_STORE: begin
                imm_sel = 3'b001;
                mem_rw  = 1'b1;
                b_sel   = 1'b1;
                a_sel   = 1'b0;
                alu_sel = 4'b0000;
            end

            OPCODE_BRANCH: begin
                imm_sel = 3'b010;
                b_sel   = 1'b1;
                a_sel   = 1'b1;
                alu_sel = 4'b0000;

                br_un = (funct3 == 3'b110 || funct3 == 3'b111);

                case (funct3)
                    3'b000: pc_sel = br_eq;
                    3'b001: pc_sel = ~br_eq;
                    3'b100: pc_sel = br_lt;
                    3'b101: pc_sel = ~br_lt;
                    3'b110: pc_sel = br_lt;
                    3'b111: pc_sel = ~br_lt;
                    default: pc_sel = 1'b0;
                endcase
            end

            OPCODE_JAL: begin
                imm_sel = 3'b100;
                reg_wen = 1'b1;
                pc_sel  = 1'b1;
                b_sel   = 1'b1;
                a_sel   = 1'b1;
                alu_sel = 4'b0000;
                wb_sel  = 2'b10;
            end

            OPCODE_JALR: begin
                imm_sel = 3'b000;
                reg_wen = 1'b1;
                pc_sel  = 1'b1;
                b_sel   = 1'b1;
                a_sel   = 1'b0;
                alu_sel = 4'b0000;
                wb_sel  = 2'b10;
            end

            OPCODE_LUI: begin
                imm_sel = 3'b011;
                reg_wen = 1'b1;
                b_sel   = 1'b1;
                alu_sel = 4'b1111;
                wb_sel  = 2'b01;
            end

            OPCODE_AUIPC: begin
                imm_sel = 3'b011;
                reg_wen = 1'b1;
                b_sel   = 1'b1;
                a_sel   = 1'b1;
                alu_sel = 4'b0000;
                wb_sel  = 2'b01;
            end

            default: begin
            end
        endcase
    end
endmodule