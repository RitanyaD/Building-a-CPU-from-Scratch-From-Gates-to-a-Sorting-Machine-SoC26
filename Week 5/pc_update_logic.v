module pc_update_logic(
    input      [5:0] current_pc,
    input      [7:0] pc_offset,
    input            take_branch,

    output            pc_load,
    output     [5:0]  pc_load_val
);

    // Only the lower 6 offset bits are used by the 64-word code memory.
    // The addition automatically wraps around modulo 64.
    wire [5:0] offset_6;

    assign offset_6 = pc_offset[5:0];

    // Your pc.v loads pc_load_val when pc_load = 1.
    assign pc_load = take_branch;

    // Branch/jump target:
    // current instruction + 1 + signed offset
    assign pc_load_val = current_pc + 6'd1 + offset_6;

endmodule