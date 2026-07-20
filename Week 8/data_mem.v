module data_memory(
    input            clk,
    input            we,
    input      [3:0] addr,
    input      [7:0] wdata,
    output     [7:0] rdata
);

	reg [7:0] mem [0:15];

    integer i;

initial begin
    for (i = 0; i < 16; i = i + 1)
        mem[i] = 8'd0;

    // Unsorted array
    mem[0] = 8'd13;
    mem[1] = 8'd2;
    mem[2] = 8'd21;
    mem[3] = 8'd6;
    mem[4] = 8'd4;
end

  

assign rdata = mem[addr];

always @(posedge clk) begin
    if (we)
        mem[addr] <= wdata;
end

endmodule