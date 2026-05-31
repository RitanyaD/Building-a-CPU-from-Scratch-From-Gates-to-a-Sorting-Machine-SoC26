module regfile(
    input        clk, we,
    input  [1:0] raddr0, raddr1, waddr,
    input  [7:0] wdata,
    output [7:0] rdata0, rdata1
);

    reg [7:0] regs [3:0]; 
    always @(posedge clk) begin
        if (we) begin
            regs[waddr] <= wdata;
        end
    end

    assign rdata0 = regs[raddr0];
    assign rdata1 = regs[raddr1];

endmodule