module flags_register(
    input      clk,
    input      rst,
    input      we,
    input      z_in,
    input      n_in,
    input      o_in,
    output reg zf,
    output reg nf,
    output reg of
);

always @(posedge clk) begin
    if (rst) begin
        zf <= 1'b0;
        nf <= 1'b0;
        of <= 1'b0;
    end
    else if (we) begin
        zf <= z_in;
        nf <= n_in;
        of <= o_in;
    end
end

endmodule