// Week 2 — 8-bit ALU
// op: 000=ADD 001=SUB 010=AND 011=OR 100=XOR 101=SHIFTL 110=SHIFTR
// Run: iverilog -o sim ../testbenches/tb_alu.v alu.v && vvp sim

module alu(
    input  [7:0]     a, b,
    input  [2:0]     op,
    output reg [7:0] result,
    output           zero,
    output reg       carry,
    output reg       overflow
);


always @(*) begin
    result   = 8'b0;
    carry    = 1'b0;
    overflow = 1'b0;

    case (op)
        3'b000: begin // ADD
            {carry, result} = a + b;
            overflow = (~a[7] & ~b[7] & result[7]) |
                       ( a[7] &  b[7] & ~result[7]);
        end

        3'b001: begin // SUB
            {carry, result} = a - b;
            overflow = (~a[7] &  b[7] & result[7]) |
                       ( a[7] & ~b[7] & ~result[7]);
        end

        3'b010: begin // AND
            result = a & b;
        end

        3'b011: begin // OR
            result = a | b;
        end

        3'b100: begin // XOR
            result = a ^ b;
        end

        3'b101: begin // SHIFTL
            result = a << 1;
            carry = a[7];
        end

        3'b110: begin // SHIFTR
            result = a >> 1;
            carry = a[0];
        end

        default: begin
            result = 8'b0;
        end
    endcase
end

assign zero = (result == 8'b0);


endmodule
