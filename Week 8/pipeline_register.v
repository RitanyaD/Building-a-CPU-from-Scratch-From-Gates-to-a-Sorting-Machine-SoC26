module pipeline_register #(
    parameter WIDTH = 8
)(
    input                  clk,
    input                  rst,
    input                  enable,
    input                  flush,
    input      [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
);

always @(posedge clk) begin
    if (rst || flush)
        q <= {WIDTH{1'b0}};
    else if (enable)
        q <= d;
end

endmodule