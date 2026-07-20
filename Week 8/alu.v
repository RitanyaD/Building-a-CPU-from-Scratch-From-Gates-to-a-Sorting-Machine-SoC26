module alu(
    input      [7:0] a,
    input      [7:0] b,
    input      [1:0] op,
    output reg [7:0] result,
    output            zero,
    output          negative,
    output reg         overflow
);

always @(*) begin
    result   = 8'b0;
    overflow = 1'b0;

    case (op)
        2'b00: begin
            result = a + b;

            overflow =
                (~a[7] & ~b[7] &  result[7]) |
                ( a[7] &  b[7] & ~result[7]);
        end

        2'b01: begin
            result = a - b;

            overflow =
                (~a[7] &  b[7] &  result[7]) |
                ( a[7] & ~b[7] & ~result[7]);
        end

        2'b10: begin
            result = a << 1;
        end

        2'b11: begin
            result = a >> 1;
        end
		  default: begin
				result   = 8'b0;
				overflow = 1'b0;
			end
    endcase
end

assign zero     = (result == 8'b0);
assign negative = result[7];

endmodule