module pipelined_cpu(
    input clk,
    input rst
);

    // IF stage
      
    wire [5:0]  pc_value;
    wire [15:0] if_instruction;
    wire [5:0]  if_pc_plus_1=pc_value + 6'd1;

    wire data_stall;
    wire  control_transfer_ex;
    wire [5:0]  branch_target_ex;

    pc pc_reg (
        .clk (clk),
        .rst (rst),
        .enable (!data_stall),
        .load (control_transfer_ex),
        .load_val(branch_target_ex),
        .pc_out (pc_value)
    );

    code_memory code_mem (
        .addr (pc_value),
        .instruction (if_instruction)
    );

      
    // IF/ID pipeline register
      
    reg [15:0] IF_ID_instruction;
    reg [5:0]  IF_ID_pc_plus_1;

      
    // ID stage: decode and register-file read
      
    wire NOOP, INPUTC, INPUTCF, INPUTD, INPUTDF;
    wire MOVE, LOADI, SHIFTL, SHIFTR, CMP, JUMP;
    wire BRE, BRNE, BRG, BRGE;
    wire ADD, ADDI, SUB, SUBI, LOAD, LOADF, STORE, STOREF;
    wire x1, x0, y1, y0;

    opcode_decoder decoder (
        .instr (IF_ID_instruction[15:8]),
        .NOOP (NOOP),
        .INPUTC (INPUTC),
        .INPUTCF (INPUTCF),
        .INPUTD  (INPUTD),
        .INPUTDF (INPUTDF),
        .MOVE (MOVE),
        .LOADI (LOADI),
        .SHIFTL (SHIFTL),
        .SHIFTR (SHIFTR),
        .CMP (CMP),
        .JUMP (JUMP),
        .BRE_BRZ  (BRE),
        .BRNE_BRNZ (BRNE),
        .BRG (BRG),
        .BRGE(BRGE),
        .ADD (ADD),
        .ADDI (ADDI),
        .SUB (SUB),
        .SUBI(SUBI),
        .LOAD (LOAD),
        .LOADF (LOADF),
        .STORE (STORE),
        .STOREF (STOREF),
        .x1 (x1),
        .x0(x0),
        .y1(y1),
        .y0(y0)
    );

    wire [22:0] inst_decoded={
        BRGE, BRG, BRNE, BRE, JUMP, CMP, SHIFTR, SHIFTL,
        STOREF, STORE, LOADF, LOAD, SUBI, SUB, ADDI, ADD,
        LOADI, MOVE, INPUTDF, INPUTD, INPUTCF, INPUTC, NOOP
    };

    wire [1:0] id_rx_addr=IF_ID_instruction[11:10];
    wire [1:0] id_ry_addr=IF_ID_instruction[9:8];

    wire [7:0] id_rx_data;
    wire [7:0] id_ry_data;

    wire [7:0] wb_write_data;
    reg MEM_WB_reg_write;
    reg  [1:0] MEM_WB_write_addr;

    regfile registers (
        .clk(clk),
        .we(MEM_WB_reg_write),
        .raddr0 (id_rx_addr),
        .raddr1 (id_ry_addr),
        .waddr  (MEM_WB_write_addr),
        .wdata  (wb_write_data),
        .rst(rst),
        .rdata0 (id_rx_data),
        .rdata1 (id_ry_data)
    );

    wire flag_zf, flag_nf, flag_of;
    wire ex_zero, ex_negative, ex_overflow;
    reg  ID_EX_flags_write;

    flags_register flags (
        .clk(clk),
        .rst(rst),
        .we(ID_EX_flags_write),
        .z_in (ex_zero),
        .n_in (ex_negative),
        .o_in (ex_overflow),
        .zf(flag_zf),
        .nf(flag_nf),
        .of(flag_of)
    );

    wire id_reg_write;
    wire id_mem_write;
    wire id_mem_to_reg;
    wire [1:0] id_alu_op;
    wire id_flags_write;
    wire id_is_load;
    wire id_is_branch;
    wire id_branch_taken;
    wire id_swap_en;
    wire [1:0] id_write_addr;
    wire id_use_rx;
    wire id_use_ry;

    control_unit controller (
        .inst_decoded (inst_decoded),
        .X(id_rx_addr),
        .Y(id_ry_addr),
        .ZF(flag_zf),
        .NF (flag_nf),
        .OF (flag_of),
        .reg_write (id_reg_write),
        .mem_write (id_mem_write),
        .mem_to_reg(id_mem_to_reg),
        .alu_op(id_alu_op),
        .flags_write(id_flags_write),
        .is_load (id_is_load),
        .is_branch(id_is_branch),
        .branch_taken (id_branch_taken),
        .swap_en (id_swap_en),
        .write_addr(id_write_addr),
        .use_rx(id_use_rx),
        .use_ry(id_use_ry)
    );

      
    // ID/EX pipeline register
      
    reg [15:0] ID_EX_instruction;
    reg [5:0]  ID_EX_pc_plus_1;
    reg [7:0]  ID_EX_rx_data;
    reg [7:0]  ID_EX_ry_data;
    reg [1:0]  ID_EX_rx_addr;
    reg [1:0]  ID_EX_ry_addr;
    reg [1:0]  ID_EX_write_addr;
    reg [1:0]  ID_EX_alu_op;
    reg ID_EX_reg_write;
    reg ID_EX_mem_write;
    reg ID_EX_mem_to_reg;
    reg ID_EX_is_load;
    reg ID_EX_is_branch;
    reg ID_EX_branch_taken;
    reg ID_EX_swap_en;
    reg ID_EX_use_rx;
    reg ID_EX_use_ry;

    wire load_use_stall;
    wire flag_use_stall;

    hazard_unit hazards (
        .id_ex_is_load     (ID_EX_is_load),
        .id_ex_write_addr  (ID_EX_write_addr),
        .id_ex_flags_write (ID_EX_flags_write),
        .if_id_rx_addr     (id_rx_addr),
        .if_id_ry_addr     (id_ry_addr),
        .if_id_use_rx      (id_use_rx),
        .if_id_use_ry      (id_use_ry),
        .if_id_is_branch   (id_is_branch),
        .load_use_stall    (load_use_stall),
        .flag_use_stall    (flag_use_stall),
        .data_stall        (data_stall)
    );
  
    // EX stage: forwarding, swap, ALU/address and branch target
      
    reg EX_MEM_reg_write;
    reg EX_MEM_mem_write;
    reg EX_MEM_mem_to_reg;
    reg [1:0]  EX_MEM_write_addr;
    reg [7:0]  EX_MEM_result;
    reg [7:0]  EX_MEM_store_data;
    reg [15:0] EX_MEM_instruction;

    reg MEM_WB_mem_to_reg;
    reg [7:0]  MEM_WB_alu_result;
    reg [7:0]  MEM_WB_memory_data;
    reg [15:0] MEM_WB_instruction;

    assign wb_write_data=MEM_WB_mem_to_reg ? MEM_WB_memory_data
                                               : MEM_WB_alu_result;

    wire [7:0] rx_forwarded;
    wire [7:0] ry_forwarded;
    wire [1:0] forward_rx_sel;
    wire [1:0] forward_ry_sel;

    forwarding_unit forwarding (
        .id_ex_rx_data(ID_EX_rx_data),
        .id_ex_ry_data(ID_EX_ry_data),
        .id_ex_rx_addr(ID_EX_rx_addr),
        .id_ex_ry_addr(ID_EX_ry_addr),
        .id_ex_use_rx(ID_EX_use_rx),
        .id_ex_use_ry(ID_EX_use_ry),
        .ex_mem_reg_write(EX_MEM_reg_write),
        .ex_mem_mem_to_reg(EX_MEM_mem_to_reg),
        .ex_mem_write_addr(EX_MEM_write_addr),
        .ex_mem_result(EX_MEM_result),
        .mem_wb_reg_write(MEM_WB_reg_write),
        .mem_wb_write_addr(MEM_WB_write_addr),
        .mem_wb_write_data(wb_write_data),
        .rx_forwarded(rx_forwarded),
        .ry_forwarded(ry_forwarded),
        .forward_rx_sel(forward_rx_sel),
        .forward_ry_sel(forward_ry_sel)
    );

    wire [7:0] swapped_first;
    wire [7:0] swapped_second;

    swap_inputs swap_block (
        .in_rx(rx_forwarded),
        .in_ry(ry_forwarded),
        .swap_en(ID_EX_swap_en),
        .out_first  (swapped_first),
        .out_second (swapped_second)
    );

    wire [3:0] ex_opcode=ID_EX_instruction[15:12];
    wire [7:0] ex_immediate=ID_EX_instruction[7:0];

    reg [7:0] ex_alu_a;
    reg [7:0] ex_alu_b;
    reg [7:0] ex_store_data;

    always @(*) begin
        ex_alu_a= swapped_first;
        ex_alu_b= swapped_second;
        ex_store_data=swapped_second;

        case (ex_opcode)
            4'b0010: begin // MOVE X,Y
                ex_alu_a=swapped_first;
                ex_alu_b=8'd0;
            end
            4'b0011: begin // LOADI X,imm
                ex_alu_a=8'd0;
                ex_alu_b=ex_immediate;
            end
            4'b0100: begin // ADD X,Y
                ex_alu_a=swapped_first;
                ex_alu_b=swapped_second;
            end
            4'b0101: begin // ADDI X,imm
                ex_alu_a=swapped_first;
                ex_alu_b=ex_immediate;
            end
            4'b0110: begin // SUB X,Y
                ex_alu_a=swapped_first;
                ex_alu_b=swapped_second;
            end
            4'b0111: begin // SUBI X,imm
                ex_alu_a=swapped_first;
                ex_alu_b=ex_immediate;
            end
            4'b1000: begin // LOAD X,[imm]
                ex_alu_a=8'd0;
                ex_alu_b=ex_immediate;
            end
            4'b1001: begin // LOADF X,[Y+imm]
                ex_alu_a=ry_forwarded;
                ex_alu_b=ex_immediate;
            end
            4'b1010: begin // STORE [imm],X
                ex_alu_a     =8'd0;
                ex_alu_b     =ex_immediate;
                ex_store_data=swapped_second;
            end
            4'b1011: begin // STOREF [Y+imm],X
                ex_alu_a     =swapped_first;
                ex_alu_b     =ex_immediate;
                ex_store_data=swapped_second;
            end
            4'b1100: begin // shift X
                ex_alu_a=swapped_first;
                ex_alu_b=8'd0;
            end
            4'b1101: begin // CMP X,Y
                ex_alu_a=swapped_first;
                ex_alu_b=swapped_second;
            end
            default: begin
                ex_alu_a=8'd0;
                ex_alu_b=8'd0;
            end
        endcase
    end

    wire [7:0] ex_alu_result;

    alu execute_alu (
        .a(ex_alu_a),
        .b(ex_alu_b),
        .op(ID_EX_alu_op),
        .result(ex_alu_result),
        .zero(ex_zero),
        .negative (ex_negative),
        .overflow (ex_overflow)
    );

    wire signed [8:0] branch_sum =
        $signed({1'b0, ID_EX_pc_plus_1}) +
        $signed({ID_EX_instruction[7], ID_EX_instruction[7:0]});

    assign branch_target_ex  =branch_sum[5:0];
    assign control_transfer_ex=ID_EX_is_branch && ID_EX_branch_taken;

      
    // MEM stage
      
    wire [7:0] mem_read_data;

    data_memory data_mem (
        .clk(clk),
        .we(EX_MEM_mem_write),
        .addr(EX_MEM_result[3:0]),
        .wdata (EX_MEM_store_data),
        .rdata (mem_read_data)
    );

      
    // Pipeline register updates
      
    always @(posedge clk) begin
        if (rst) begin
            IF_ID_instruction<= 16'd0;
            IF_ID_pc_plus_1<= 6'd0;

            ID_EX_instruction<= 16'd0;
            ID_EX_pc_plus_1<= 6'd0;
            ID_EX_rx_data<= 8'd0;
            ID_EX_ry_data<= 8'd0;
            ID_EX_rx_addr<= 2'd0;
            ID_EX_ry_addr<= 2'd0;
            ID_EX_write_addr<= 2'd0;
            ID_EX_alu_op<= 2'd0;
            ID_EX_reg_write<= 1'b0;
            ID_EX_mem_write<= 1'b0;
            ID_EX_mem_to_reg<= 1'b0;
            ID_EX_flags_write<= 1'b0;
            ID_EX_is_load<= 1'b0;
            ID_EX_is_branch<= 1'b0;
            ID_EX_branch_taken <= 1'b0;
            ID_EX_swap_en<= 1'b0;
            ID_EX_use_rx<= 1'b0;
            ID_EX_use_ry<= 1'b0;

            EX_MEM_instruction <= 16'd0;
            EX_MEM_reg_write<= 1'b0;
            EX_MEM_mem_write<= 1'b0;
            EX_MEM_mem_to_reg<= 1'b0;
            EX_MEM_write_addr<= 2'd0;
            EX_MEM_result<= 8'd0;
            EX_MEM_store_data<= 8'd0;

            MEM_WB_instruction<= 16'd0;
            MEM_WB_reg_write<= 1'b0;
            MEM_WB_mem_to_reg<= 1'b0;
            MEM_WB_write_addr<= 2'd0;
            MEM_WB_alu_result<= 8'd0;
            MEM_WB_memory_data <= 8'd0;
        end
        else begin
            // Older instructions always advance.
            MEM_WB_instruction <= EX_MEM_instruction;
            MEM_WB_reg_write<= EX_MEM_reg_write;
            MEM_WB_mem_to_reg  <= EX_MEM_mem_to_reg;
            MEM_WB_write_addr<= EX_MEM_write_addr;
            MEM_WB_alu_result<= EX_MEM_result;
            MEM_WB_memory_data <= mem_read_data;

            EX_MEM_instruction <= ID_EX_instruction;
            EX_MEM_reg_write<= ID_EX_reg_write;
            EX_MEM_mem_write<= ID_EX_mem_write;
            EX_MEM_mem_to_reg  <= ID_EX_mem_to_reg;
            EX_MEM_write_addr  <= ID_EX_write_addr;
            EX_MEM_result<= ex_alu_result;
            EX_MEM_store_data  <= ex_store_data;

            if (control_transfer_ex) begin
                // Taken branch/jump: flush IF/ID and ID/EX.
                IF_ID_instruction <= 16'd0;
                IF_ID_pc_plus_1   <= 6'd0;

                ID_EX_instruction  <= 16'd0;
                ID_EX_pc_plus_1<= 6'd0;
                ID_EX_rx_data<= 8'd0;
                ID_EX_ry_data<= 8'd0;
                ID_EX_rx_addr<= 2'd0;
                ID_EX_ry_addr<= 2'd0;
                ID_EX_write_addr   <= 2'd0;
                ID_EX_alu_op<= 2'd0;
                ID_EX_reg_write<= 1'b0;
                ID_EX_mem_write<= 1'b0;
                ID_EX_mem_to_reg<= 1'b0;
                ID_EX_flags_write  <= 1'b0;
                ID_EX_is_load<= 1'b0;
                ID_EX_is_branch<= 1'b0;
                ID_EX_branch_taken <= 1'b0;
                ID_EX_swap_en<= 1'b0;
                ID_EX_use_rx<= 1'b0;
                ID_EX_use_ry<= 1'b0;
            end
            else if (data_stall) begin
                // Hold PC and IF/ID. Insert a bubble into ID/EX.
                ID_EX_instruction  <= 16'd0;
                ID_EX_pc_plus_1<= 6'd0;
                ID_EX_rx_data<= 8'd0;
                ID_EX_ry_data<= 8'd0;
                ID_EX_rx_addr<= 2'd0;
                ID_EX_ry_addr<= 2'd0;
                ID_EX_write_addr   <= 2'd0;
                ID_EX_alu_op<= 2'd0;
                ID_EX_reg_write<= 1'b0;
                ID_EX_mem_write<= 1'b0;
                ID_EX_mem_to_reg   <= 1'b0;
                ID_EX_flags_write  <= 1'b0;
                ID_EX_is_load<= 1'b0;
                ID_EX_is_branch<= 1'b0;
                ID_EX_branch_taken <= 1'b0;
                ID_EX_swap_en<= 1'b0;
                ID_EX_use_rx<= 1'b0;
                ID_EX_use_ry<= 1'b0;
            end
            else begin
                IF_ID_instruction <= if_instruction;
                IF_ID_pc_plus_1<= if_pc_plus_1;

                ID_EX_instruction  <= IF_ID_instruction;
                ID_EX_pc_plus_1<= IF_ID_pc_plus_1;
                ID_EX_rx_data<= id_rx_data;
                ID_EX_ry_data<= id_ry_data;
                ID_EX_rx_addr<= id_rx_addr;
                ID_EX_ry_addr<= id_ry_addr;
                ID_EX_write_addr   <= id_write_addr;
                ID_EX_alu_op<= id_alu_op;
                ID_EX_reg_write<= id_reg_write;
                ID_EX_mem_write<= id_mem_write;
                ID_EX_mem_to_reg<= id_mem_to_reg;
                ID_EX_flags_write  <= id_flags_write;
                ID_EX_is_load<= id_is_load;
                ID_EX_is_branch<= id_is_branch;
                ID_EX_branch_taken <= id_branch_taken;
                ID_EX_swap_en<= id_swap_en;
                ID_EX_use_rx<= id_use_rx;
                ID_EX_use_ry<= id_use_ry;
            end
        end
    end

endmodule
