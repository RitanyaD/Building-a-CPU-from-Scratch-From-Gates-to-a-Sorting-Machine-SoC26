module regfile(
    input        clk, we,
    input  [1:0] raddr0, raddr1, waddr,
    input  [7:0] wdata,
	 input rst,
    output [7:0] rdata0, rdata1
	 
	 
);

	reg [7:0] regs [3:0]; 
	
	integer i;
	always @(posedge clk) begin
		if (rst) begin
			for (i = 0; i < 4; i = i + 1)
				regs[i] <= 8'b0;
		end
		else if (we) begin
			regs[waddr] <= wdata;
		end
	end
	assign rdata0 = regs[raddr0];
   assign rdata1 = regs[raddr1];

endmodule