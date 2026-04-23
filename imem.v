module IMEM (
    input wire [31:0] address,
    output wire [31:0] inst
);
    reg [31:0] rom [0:255];

    initial begin
        $readmemh("imem.hex", rom);
    end

    assign inst = rom[address[9:2]];
endmodule