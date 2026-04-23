`timescale 1ns / 1ps

module ALU (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0] alu_sel,
    output reg [31:0] alu_out
);

    always @(*) begin
        alu_out = 32'b0;

        case (alu_sel)
            4'b0000: alu_out = a + b;
            4'b0001: alu_out = a - b;

            4'b0010: alu_out = a << b[4:0];
            4'b0110: alu_out = a >> b[4:0];
            4'b0111: alu_out = $signed(a) >>> b[4:0];

            4'b0011: alu_out = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
            4'b0100: alu_out = (a < b) ? 32'b1 : 32'b0;

            4'b0101: alu_out = a ^ b;
            4'b1000: alu_out = a | b;
            4'b1001: alu_out = a & b;

            4'b1111: alu_out = b;

            default: alu_out = 32'b0;
        endcase
    end

endmodule