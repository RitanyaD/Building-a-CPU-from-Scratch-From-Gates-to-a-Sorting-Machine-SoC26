module forwarding_unit (
    input      [7:0] id_ex_rx_data,
    input      [7:0] id_ex_ry_data,
    input      [1:0] id_ex_rx_addr,
    input      [1:0] id_ex_ry_addr,
    input            id_ex_use_rx,
    input            id_ex_use_ry,

    input            ex_mem_reg_write,
    input            ex_mem_mem_to_reg,
    input      [1:0] ex_mem_write_addr,
    input      [7:0] ex_mem_result,

    input            mem_wb_reg_write,
    input      [1:0] mem_wb_write_addr,
    input      [7:0] mem_wb_write_data,

    output reg [7:0] rx_forwarded,
    output reg [7:0] ry_forwarded,
    output reg [1:0] forward_rx_sel,
    output reg [1:0] forward_ry_sel
);

    wire ex_can_forward = ex_mem_reg_write && !ex_mem_mem_to_reg;

    always @(*) begin
        rx_forwarded  = id_ex_rx_data;
        ry_forwarded  = id_ex_ry_data;
        forward_rx_sel = 2'b00;
        forward_ry_sel = 2'b00;

        if (id_ex_use_rx && ex_can_forward &&
            (ex_mem_write_addr == id_ex_rx_addr)) begin
            rx_forwarded   = ex_mem_result;
            forward_rx_sel = 2'b01;
        end
        else if (id_ex_use_rx && mem_wb_reg_write &&
                 (mem_wb_write_addr == id_ex_rx_addr)) begin
            rx_forwarded   = mem_wb_write_data;
            forward_rx_sel = 2'b10;
        end

        if (id_ex_use_ry && ex_can_forward &&
            (ex_mem_write_addr == id_ex_ry_addr)) begin
            ry_forwarded   = ex_mem_result;
            forward_ry_sel = 2'b01;
        end
        else if (id_ex_use_ry && mem_wb_reg_write &&
                 (mem_wb_write_addr == id_ex_ry_addr)) begin
            ry_forwarded   = mem_wb_write_data;
            forward_ry_sel = 2'b10;
        end
    end

endmodule
