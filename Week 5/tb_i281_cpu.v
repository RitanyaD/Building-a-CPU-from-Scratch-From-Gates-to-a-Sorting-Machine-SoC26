`timescale 1ns/1ps

module tb_i281_cpu;

    reg clk;
    reg rst;

    // Instantiate the CPU
    i281_cpu dut (
        .clk(clk),
        .rst(rst)
    );

    // Generate clock: 10 ns period
    always #5 clk = ~clk;

initial begin
    clk = 1'b0;
    rst = 1'b1;

    #20;
    rst = 1'b0;

    // Allow bubble sort to finish
    #2000;

    $display("PC = %d", dut.pc_value);

    $display("Final data memory:");
    $display("mem[0] = %d", dut.data_mem.mem[0]);
    $display("mem[1] = %d", dut.data_mem.mem[1]);
    $display("mem[2] = %d", dut.data_mem.mem[2]);
    $display("mem[3] = %d", dut.data_mem.mem[3]);
    $display("mem[4] = %d", dut.data_mem.mem[4]);

    if (
        dut.data_mem.mem[0] == 8'd2  &&
        dut.data_mem.mem[1] == 8'd4  &&
        dut.data_mem.mem[2] == 8'd6  &&
        dut.data_mem.mem[3] == 8'd13 &&
        dut.data_mem.mem[4] == 8'd21
    )
        $display("BUBBLE SORT TEST PASSED");
    else
        $display("BUBBLE SORT TEST FAILED");

    $stop;
end

endmodule