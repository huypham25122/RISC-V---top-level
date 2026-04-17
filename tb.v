`timescale 1ns / 1ps

module tb_riscv();
    reg clk;
    reg rst;

    // Khởi tạo CPU
    riscv_single_cycle dut (
        .clk(clk),
        .rst(rst)
    );

    // Tạo xung clock chu kỳ 10ns (100MHz)
    always #5 clk = ~clk;

    initial begin
        // Khởi tạo ban đầu
        clk = 0;
        rst = 1;

        // Thả reset sau 2 chu kỳ clock
        #20 rst = 0;

        // Chạy trong 1000ns để quan sát các lệnh thực thi
        #1000;
        
        $display("Simulation finished.");
        $stop;
    end

    // Gợi ý: Bạn có thể thêm các lệnh $monitor để theo dõi các thanh ghi quan trọng
    initial begin
        $monitor("Time=%0t | PC=%h | Instr=%h | ALU_Out=%h", $time, dut.pc_current, dut.instr, dut.alu_out);
    end

endmodule