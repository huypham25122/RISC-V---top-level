module DMEM (
    input wire clk,
    input wire we,
    input wire [2:0] funct3,
    input wire [31:0] addr,
    input wire [31:0] data_w,
    output reg [31:0] data_r
);
    reg [31:0] ram [0:255];

    wire [31:0] word_data;
    wire [1:0] byte_offset;

    assign word_data   = ram[addr[9:2]];
    assign byte_offset = addr[1:0];

    always @(*) begin
        case (funct3)
            3'b000: begin
                case (byte_offset)
                    2'b00: data_r = {{24{word_data[7]}},  word_data[7:0]};
                    2'b01: data_r = {{24{word_data[15]}}, word_data[15:8]};
                    2'b10: data_r = {{24{word_data[23]}}, word_data[23:16]};
                    2'b11: data_r = {{24{word_data[31]}}, word_data[31:24]};
                    default: data_r = 32'b0;
                endcase
            end

            3'b001: begin
                case (byte_offset[1])
                    1'b0: data_r = {{16{word_data[15]}}, word_data[15:0]};
                    1'b1: data_r = {{16{word_data[31]}}, word_data[31:16]};
                    default: data_r = 32'b0;
                endcase
            end

            3'b010:
                data_r = word_data;

            3'b100: begin
                case (byte_offset)
                    2'b00: data_r = {24'b0, word_data[7:0]};
                    2'b01: data_r = {24'b0, word_data[15:8]};
                    2'b10: data_r = {24'b0, word_data[23:16]};
                    2'b11: data_r = {24'b0, word_data[31:24]};
                    default: data_r = 32'b0;
                endcase
            end

            3'b101: begin
                case (byte_offset[1])
                    1'b0: data_r = {16'b0, word_data[15:0]};
                    1'b1: data_r = {16'b0, word_data[31:16]};
                    default: data_r = 32'b0;
                endcase
            end

            default: data_r = word_data;
        endcase
    end

    always @(posedge clk) begin
        if (we) begin
            case (funct3)
                3'b000: begin
                    case (byte_offset)
                        2'b00: ram[addr[9:2]] <= {word_data[31:8],  data_w[7:0]};
                        2'b01: ram[addr[9:2]] <= {word_data[31:16], data_w[7:0], word_data[7:0]};
                        2'b10: ram[addr[9:2]] <= {word_data[31:24], data_w[7:0], word_data[15:0]};
                        2'b11: ram[addr[9:2]] <= {data_w[7:0], word_data[23:0]};
                    endcase
                end

                3'b001: begin
                    case (byte_offset[1])
                        1'b0: ram[addr[9:2]] <= {word_data[31:16], data_w[15:0]};
                        1'b1: ram[addr[9:2]] <= {data_w[15:0], word_data[15:0]};
                    endcase
                end

                3'b010:
                    ram[addr[9:2]] <= data_w;

                default: ram[addr[9:2]] <= data_w;
            endcase
        end
    end
endmodule