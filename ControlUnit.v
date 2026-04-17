module ControlUnit (
    input wire [31:0] inst,
    input wire br_eq,           // Cờ bằng nhau từ BranchComp
    input wire br_lt,           // Cờ nhỏ hơn từ BranchComp
    
    output reg pc_sel,          // 0: PC+4, 1: ALU (Branch/Jump)
    output reg [2:0] imm_sel,   // Dạng Immediate
    output reg reg_wen,         // Write Enable cho RegFile
    output reg br_un,           // 1: Unsigned Branch
    output reg b_sel,           // 0: RegB, 1: Imm
    output reg a_sel,           // 0: RegA, 1: PC
    output reg [3:0] alu_sel,   // Mã phép toán cho ALU
    output reg mem_rw,          // Write Enable cho DMEM
    output reg [1:0] wb_sel     // Write-Back MUX (00: Mem, 01: ALU, 10: PC+4)
);

    // Tách các trường giải mã từ lệnh [cite: 1, 4, 5]
    wire [6:0] opcode = inst[6:0];
    wire [2:0] funct3 = inst[14:12];
    wire [6:0] funct7 = inst[31:25];

    // Định nghĩa các mã Opcode chuẩn của RISC-V (RV32I) 
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
        // -------------------------------------------------------------
        // 1. GIÁ TRỊ MẶC ĐỊNH (Phòng ngừa Inferred Latch trên FPGA)
        // -------------------------------------------------------------
        pc_sel  = 1'b0;
        imm_sel = 3'b000;
        reg_wen = 1'b0;
        br_un   = 1'b0;
        b_sel   = 1'b0;
        a_sel   = 1'b0;
        alu_sel = 4'b0000;
        mem_rw  = 1'b0;
        wb_sel  = 2'b01; // Mặc định lấy từ ALU

        // -------------------------------------------------------------
        // 2. GIẢI MÃ DỰA TRÊN OPCODE
        // -------------------------------------------------------------
        case (opcode)
            OPCODE_R: begin // Lệnh R-Type (add, sub, and, or...) [cite: 1]
                reg_wen = 1'b1;
                b_sel   = 1'b0; // ALU lấy RegB
                a_sel   = 1'b0; // ALU lấy RegA
                wb_sel  = 2'b01; // Ghi kết quả ALU vào Reg
                
                // Giải mã ALU_SEL dựa trên Funct3 và bit 5 của Funct7 [cite: 1]
                case (funct3)
                    3'b000: alu_sel = (funct7[5]) ? 4'b0001 : 4'b0000; // SUB (nếu funct7[5]=1) hoặc ADD [cite: 1]
                    3'b001: alu_sel = 4'b0010; // SLL [cite: 1]
                    3'b010: alu_sel = 4'b0011; // SLT [cite: 1]
                    3'b011: alu_sel = 4'b0100; // SLTU [cite: 1]
                    3'b100: alu_sel = 4'b0101; // XOR [cite: 1]
                    3'b101: alu_sel = (funct7[5]) ? 4'b0111 : 4'b0110; // SRA hoặc SRL [cite: 1]
                    3'b110: alu_sel = 4'b1000; // OR [cite: 1]
                    3'b111: alu_sel = 4'b1001; // AND [cite: 1]
                endcase
            end

            OPCODE_I_ARI: begin // Lệnh I-Type Số học (addi, andi, ori...) [cite: 1]
                imm_sel = 3'b000; // I-Type [cite: 1]
                reg_wen = 1'b1;
                b_sel   = 1'b1; // ALU lấy Imm
                a_sel   = 1'b0; // ALU lấy RegA
                wb_sel  = 2'b01;
                
                case (funct3)
                    3'b000: alu_sel = 4'b0000; // ADDI [cite: 1]
                    3'b001: alu_sel = 4'b0010; // SLLI [cite: 1]
                    3'b010: alu_sel = 4'b0011; // SLTI [cite: 1]
                    3'b011: alu_sel = 4'b0100; // SLTIU [cite: 1]
                    3'b100: alu_sel = 4'b0101; // XORI [cite: 1]
                    3'b101: alu_sel = (funct7[5]) ? 4'b0111 : 4'b0110; // SRAI hoặc SRLI [cite: 1]
                    3'b110: alu_sel = 4'b1000; // ORI [cite: 1]
                    3'b111: alu_sel = 4'b1001; // ANDI [cite: 1]
                endcase
            end

            OPCODE_LOAD: begin // Lệnh Load (lw) [cite: 1]
                imm_sel = 3'b000; // I-Type cho Load [cite: 1]
                reg_wen = 1'b1;
                b_sel   = 1'b1; // Imm
                a_sel   = 1'b0; // RegA
                alu_sel = 4'b0000; // ADD (Tính địa chỉ: rs1 + imm) [cite: 1]
                wb_sel  = 2'b00; // MUX chọn dữ liệu từ Mem 
            end

            OPCODE_STORE: begin // Lệnh Store (sw) [cite: 1]
                imm_sel = 3'b001; // S-Type [cite: 1, 5]
                mem_rw  = 1'b1; // Bật ghi bộ nhớ
                b_sel   = 1'b1; // Imm
                a_sel   = 1'b0; // RegA
                alu_sel = 4'b0000; // ADD (Tính địa chỉ: rs1 + imm) [cite: 1]
            end

            OPCODE_BRANCH: begin // Lệnh rẽ nhánh (beq, bne, blt...) 
                imm_sel = 3'b010; // B-Type [cite: 4, 5]
                b_sel   = 1'b1; // ALU tính địa chỉ nhảy: B = Imm
                a_sel   = 1'b1; // ALU tính địa chỉ nhảy: A = PC
                alu_sel = 4'b0000; // ADD (PC + Imm)
                
                // Cấu hình cờ Unsigned cho BranchComp 
                br_un = (funct3 == 3'b110 || funct3 == 3'b111); // BLTU, BGEU 
                
                // Giải mã điều kiện rẽ nhánh 
                case (funct3)
                    3'b000: pc_sel = br_eq;           // BEQ 
                    3'b001: pc_sel = ~br_eq;          // BNE 
                    3'b100: pc_sel = br_lt;           // BLT 
                    3'b101: pc_sel = ~br_lt;          // BGE 
                    3'b110: pc_sel = br_lt;           // BLTU 
                    3'b111: pc_sel = ~br_lt;          // BGEU 
                    default: pc_sel = 1'b0;
                endcase
            end

            OPCODE_JAL: begin // Jump and Link 
                imm_sel = 3'b100; // J-Type [cite: 4, 5]
                reg_wen = 1'b1;
                pc_sel  = 1'b1; // Chắc chắn rẽ nhánh
                b_sel   = 1'b1; // Imm
                a_sel   = 1'b1; // PC
                alu_sel = 4'b0000; // ADD (PC + Imm) -> Địa chỉ nhảy 
                wb_sel  = 2'b10; // Lưu PC+4 vào rd (Thường là x1) 
            end

            OPCODE_JALR: begin // Jump and Link Register 
                imm_sel = 3'b000; // I-Type 
                reg_wen = 1'b1;
                pc_sel  = 1'b1;
                b_sel   = 1'b1; // Imm
                a_sel   = 1'b0; // Lấy rs1
                alu_sel = 4'b0000; // ADD (rs1 + Imm) -> Địa chỉ nhảy 
                wb_sel  = 2'b10; // Lưu PC+4 vào rd 
            end

            OPCODE_LUI: begin // Load Upper Immediate 
                imm_sel = 3'b011; // U-Type [cite: 4, 5]
                reg_wen = 1'b1;
                b_sel   = 1'b1; // B = Imm
                // Lưu ý: LUI chỉ lưu Imm vào Reg. Ta dùng ALU để Pass B xuyên qua
                alu_sel = 4'b1111; // Cần thêm tính năng PASS_B trong khối ALU
                wb_sel  = 2'b01; 
            end

            OPCODE_AUIPC: begin // Add Upper Immediate to PC 
                imm_sel = 3'b011; // U-Type [cite: 4, 5]
                reg_wen = 1'b1;
                b_sel   = 1'b1; // B = Imm
                a_sel   = 1'b1; // A = PC
                alu_sel = 4'b0000; // ADD (PC + Imm) 
                wb_sel  = 2'b01; // Lưu kết quả vào Reg
            end

            default: begin
                // Không làm gì nếu mã lệnh không hợp lệ
            end
        endcase
    end
endmodule