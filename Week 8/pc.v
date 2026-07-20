module pc (
    input            clk,
    input            rst,
    input            enable,
    input            load,
    input      [5:0] load_val,
    output reg [5:0] pc_out
);

    always @(posedge clk) begin
        if (rst)
            pc_out <= 6'd0;
        else if (load)
            pc_out <= load_val;
        else if (enable)
            pc_out <= pc_out + 6'd1;
    end

endmodule
