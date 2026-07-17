`timescale 1ns/1ps

module tb_multicycle_cpu;

    reg clk;
    reg rst;
    integer i;

    multicycle_cpu dut (
        .clk (clk),
        .rst (rst)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst = 1'b1;

        for (i = 0; i < 16; i = i + 1)
            dut.data_mem.mem[i] = 8'd0;

        dut.data_mem.mem[0] = 8'd13;
        dut.data_mem.mem[1] = 8'd2;
        dut.data_mem.mem[2] = 8'd21;
        dut.data_mem.mem[3] = 8'd6;
        dut.data_mem.mem[4] = 8'd4;

        #20;
        rst = 1'b0;

        // Multi-cycle execution needs many more clocks than the single-cycle CPU.
        repeat (800) @(posedge clk);

        $display("----------------------------------------");
        $display("MULTI-CYCLE BUBBLE SORT RESULT");
        $display("PC      = %0d", dut.pc_value);
        $display("State   = %0d", dut.state_debug);
        $display("A       = %0d", dut.registers.regs[0]);
        $display("B       = %0d", dut.registers.regs[1]);
        $display("C       = %0d", dut.registers.regs[2]);
        $display("D       = %0d", dut.registers.regs[3]);
        $display("mem[0]  = %0d", dut.data_mem.mem[0]);
        $display("mem[1]  = %0d", dut.data_mem.mem[1]);
        $display("mem[2]  = %0d", dut.data_mem.mem[2]);
        $display("mem[3]  = %0d", dut.data_mem.mem[3]);
        $display("mem[4]  = %0d", dut.data_mem.mem[4]);

        if ((dut.data_mem.mem[0] == 8'd2)  &&
            (dut.data_mem.mem[1] == 8'd4)  &&
            (dut.data_mem.mem[2] == 8'd6)  &&
            (dut.data_mem.mem[3] == 8'd13) &&
            (dut.data_mem.mem[4] == 8'd21))
            $display("MULTI-CYCLE BUBBLE SORT TEST PASSED");
        else
            $display("MULTI-CYCLE BUBBLE SORT TEST FAILED");

        $display("----------------------------------------");
        $stop;
    end

endmodule
