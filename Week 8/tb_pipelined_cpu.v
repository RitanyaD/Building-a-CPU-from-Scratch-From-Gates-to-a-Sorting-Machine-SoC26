`timescale 1ns/1ps

module tb_pipelined_cpu;

    reg clk;
    reg rst;
    integer failures;

    pipelined_cpu dut (
        .clk (clk),
        .rst (rst)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        failures = 0;
        rst = 1'b1;
        repeat (3) @(posedge clk);
        rst = 1'b0;

        // Generous runtime for the complete bubble-sort routine.
        repeat (500) @(posedge clk);

        $display("Final data memory:");
        $display("mem[0] = %0d", dut.data_mem.mem[0]);
        $display("mem[1] = %0d", dut.data_mem.mem[1]);
        $display("mem[2] = %0d", dut.data_mem.mem[2]);
        $display("mem[3] = %0d", dut.data_mem.mem[3]);
        $display("mem[4] = %0d", dut.data_mem.mem[4]);

        if (dut.data_mem.mem[0] !== 8'd2)  failures = failures + 1;
        if (dut.data_mem.mem[1] !== 8'd4)  failures = failures + 1;
        if (dut.data_mem.mem[2] !== 8'd6)  failures = failures + 1;
        if (dut.data_mem.mem[3] !== 8'd13) failures = failures + 1;
        if (dut.data_mem.mem[4] !== 8'd21) failures = failures + 1;

        if (failures == 0)
            $display("PIPELINED BUBBLE SORT TEST PASSED");
        else
            $display("PIPELINED BUBBLE SORT TEST FAILED: %0d mismatches", failures);

        $finish;
    end

endmodule
