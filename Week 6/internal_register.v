module internal_register #(
    parameter WIDTH = 8
)(
    input                  clk,
    input                  rst,
    input                  we,
    input      [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
);

always @(posedge clk) begin
    if (rst)
        q <= {WIDTH{1'b0}};
    else if (we)
        q <= d;
end

endmodule