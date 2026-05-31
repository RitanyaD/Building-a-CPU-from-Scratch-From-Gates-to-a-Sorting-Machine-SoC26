// Week 2 — Program Counter (6-bit)
// Priority: rst > load > inc > hold
// Run: iverilog -o sim ../testbenches/tb_pc.v pc.v && vvp sim

module pc(
    input            clk, rst, inc, load,
    input      [5:0] load_val,
    output reg [5:0] pc_out
);
   always @(posedge clk) begin
        if (rst) begin
            pc_out = 6'b000000;
        end
        else if (load) begin
            pc_out <= load_val;
        end
        else if (inc) begin
            pc_out <= pc_out + 1'b1;
        end
    end


endmodule
