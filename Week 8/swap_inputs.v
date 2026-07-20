module swap_inputs (
    input      [7:0] in_rx,
    input      [7:0] in_ry,
    input            swap_en,
    output     [7:0] out_first,
    output     [7:0] out_second
);

    assign out_first  = swap_en ? in_ry : in_rx;
    assign out_second = swap_en ? in_rx : in_ry;

endmodule
