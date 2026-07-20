module hazard_unit (
    input            id_ex_is_load,
    input      [1:0] id_ex_write_addr,
    input            id_ex_flags_write,

    input      [1:0] if_id_rx_addr,
    input      [1:0] if_id_ry_addr,
    input            if_id_use_rx,
    input            if_id_use_ry,
    input            if_id_is_branch,

    output           load_use_stall,
    output           flag_use_stall,
    output           data_stall
);

    assign load_use_stall = id_ex_is_load &&
                            ((if_id_use_rx && (id_ex_write_addr == if_id_rx_addr)) ||
                             (if_id_use_ry && (id_ex_write_addr == if_id_ry_addr)));

    assign flag_use_stall = if_id_is_branch && id_ex_flags_write;

    assign data_stall = load_use_stall | flag_use_stall;

endmodule
