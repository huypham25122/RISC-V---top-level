`timescale 1ns / 1ps

module tb_riscv();

    reg clk;
    reg rst;
    integer i;
    integer pass_count;
    integer fail_count;

    integer expected_fib [0:9];

    riscv_single_cycle dut (
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;

    initial begin
        expected_fib[0] = 0;
        expected_fib[1] = 1;
        expected_fib[2] = 1;
        expected_fib[3] = 2;
        expected_fib[4] = 3;
        expected_fib[5] = 5;
        expected_fib[6] = 8;
        expected_fib[7] = 13;
        expected_fib[8] = 21;
        expected_fib[9] = 34;

        pass_count = 0;
        fail_count = 0;

        clk = 0;
        rst = 1;

        #20 rst = 0;

        #1500;

        $display("");
        $display("╔══════════════════════════════════════════════════════════════╗");
        $display("║     KIEM TRA BO XU LY RISC-V SINGLE-CYCLE                  ║");
        $display("║     Chuong trinh: Tinh day Fibonacci va Tong               ║");
        $display("╠══════════════════════════════════════════════════════════════╣");

        $display("║                                                            ║");
        $display("║  [PHAN 1] Day Fibonacci trong bo nho (DMEM)                ║");
        $display("║  Dia chi bat dau: 0x80 (128), moi phan tu cach 4 byte      ║");
        $display("║                                                            ║");

        for (i = 0; i < 10; i = i + 1) begin
            if (dut.dmem_inst.ram[32 + i] == expected_fib[i]) begin
                $display("║    F(%0d) = %3d    [PASS]  (ram[%0d], addr=0x%02h)      ",
                         i, dut.dmem_inst.ram[32 + i], 32+i, 128 + i*4);
                pass_count = pass_count + 1;
            end else begin
                $display("║    F(%0d) = %3d    [FAIL]  Mong doi: %0d                ",
                         i, dut.dmem_inst.ram[32 + i], expected_fib[i]);
                fail_count = fail_count + 1;
            end
        end

        $display("║                                                            ║");
        $display("║  [PHAN 2] Tong day Fibonacci                               ║");
        $display("║  Sum = F(0) + F(1) + ... + F(9) = 88                       ║");
        $display("║                                                            ║");

        if (dut.rf_inst.registers[10] == 88) begin
            $display("║    x10 (sum) = %0d   [PASS]                                ",
                     dut.rf_inst.registers[10]);
            pass_count = pass_count + 1;
        end else begin
            $display("║    x10 (sum) = %0d   [FAIL]  Mong doi: 88                  ",
                     dut.rf_inst.registers[10]);
            fail_count = fail_count + 1;
        end

        $display("║                                                            ║");
        $display("║  [PHAN 3] Trang thai thanh ghi cuoi cung                   ║");
        $display("║                                                            ║");

        $display("║    x1  = %4d  (F(8), gia tri 'a' cuoi)                    ", dut.rf_inst.registers[1]);
        $display("║    x2  = %4d  (F(9), gia tri 'b' cuoi)                    ", dut.rf_inst.registers[2]);
        $display("║    x3  = %4d  (temp cuoi = F(9))                          ", dut.rf_inst.registers[3]);
        $display("║    x4  = %4d  (bo dem vong lap = N)                       ", dut.rf_inst.registers[4]);
        $display("║    x5  = %4d  (N = 10)                                    ", dut.rf_inst.registers[5]);
        $display("║    x6  = %4d  (dia chi co so DMEM)                        ", dut.rf_inst.registers[6]);
        $display("║    x10 = %4d  (tong day Fibonacci)                        ", dut.rf_inst.registers[10]);

        if (dut.rf_inst.registers[1] == 21) pass_count = pass_count + 1;
        else fail_count = fail_count + 1;
        if (dut.rf_inst.registers[2] == 34) pass_count = pass_count + 1;
        else fail_count = fail_count + 1;
        if (dut.rf_inst.registers[4] == 10) pass_count = pass_count + 1;
        else fail_count = fail_count + 1;

        $display("║                                                            ║");
        $display("║  [PHAN 4] Trang thai dung chuong trinh                     ║");
        $display("║                                                            ║");

        if (dut.pc_current == 32'h00000060) begin
            $display("║    PC = 0x%08h  [PASS]  (halt tai jal x0, 0)       ", dut.pc_current);
            pass_count = pass_count + 1;
        end else begin
            $display("║    PC = 0x%08h  [FAIL]  Mong doi: 0x00000060       ", dut.pc_current);
            fail_count = fail_count + 1;
        end

        $display("║                                                            ║");
        $display("╠══════════════════════════════════════════════════════════════╣");
        if (fail_count == 0) begin
            $display("║  KET QUA: %2d/%2d PASS  -  BO XU LY HOAT DONG DUNG!       ║",
                     pass_count, pass_count + fail_count);
        end else begin
            $display("║  KET QUA: %2d PASS, %2d FAIL  -  CO LOI CAN SUA!           ║",
                     pass_count, fail_count);
        end
        $display("╚══════════════════════════════════════════════════════════════╝");
        $display("");

        $stop;
    end

    initial begin
        $monitor("Time=%0t | PC=0x%02h | Instr=%h | ALU=%h | x1=%0d x2=%0d x3=%0d x10=%0d",
                 $time, dut.pc_current, dut.instr, dut.alu_out,
                 dut.rf_inst.registers[1], dut.rf_inst.registers[2],
                 dut.rf_inst.registers[3], dut.rf_inst.registers[10]);
    end

endmodule