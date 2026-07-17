module multicycle_control (
    input             clk,
    input             rst,

    input             NOOP,
    input             MOVE,
    input             LOADI,
    input             ADD,
    input             ADDI,
    input             SUB,
    input             SUBI,
    input             LOAD,
    input             LOADF,
    input             STORE,
    input             STOREF,
    input             SHIFTL,
    input             SHIFTR,
    input             CMP,
    input             JUMP,
    input             BRE,
    input             BRNE,
    input             BRG,
    input             BRGE,

    input             ZF,
    input             NF,
    input             OF,

    output reg        ir_we,
    output reg        pc_inc,
    output reg        pc_load,
    output reg        a_we,
    output reg        b_we,
    output reg        aluout_we,
    output reg        mdr_we,
    output reg        reg_we,
    output reg        flags_we,
    output reg        dmem_we,

    output reg        alu_a_zero,
    output reg        alu_b_immediate,
    output reg [1:0]  alu_op,
    output reg [1:0]  writeback_sel,
    output     [4:0]  state_debug
);

    localparam FETCH       = 5'd0;
    localparam DECODE      = 5'd1;
    localparam EXEC_R      = 5'd2;
    localparam EXEC_I      = 5'd3;
    localparam SHIFT_EXEC  = 5'd4;
    localparam ALU_WB      = 5'd5;
    localparam LOAD_ADDR   = 5'd6;
    localparam LOAD_MEM    = 5'd7;
    localparam LOAD_WB     = 5'd8;
    localparam STORE_ADDR  = 5'd9;
    localparam STORE_MEM   = 5'd10;
    localparam CMP_EXEC    = 5'd11;
    localparam BRANCH_EXEC = 5'd12;
    localparam JUMP_EXEC   = 5'd13;
    localparam MOVE_WB     = 5'd14;
    localparam LOADI_WB    = 5'd15;

    localparam WB_ALUOUT   = 2'b00;
    localparam WB_MDR      = 2'b01;
    localparam WB_IMM      = 2'b10;
    localparam WB_OPERAND_A= 2'b11;

    reg [4:0] state;
    reg [4:0] next_state;

    wire signed_greater;
    assign signed_greater = (NF == OF);
    assign state_debug = state;

    always @(posedge clk) begin
        if (rst)
            state <= FETCH;
        else
            state <= next_state;
    end

    always @(*) begin
        next_state       = FETCH;

        ir_we            = 1'b0;
        pc_inc           = 1'b0;
        pc_load          = 1'b0;
        a_we             = 1'b0;
        b_we             = 1'b0;
        aluout_we        = 1'b0;
        mdr_we           = 1'b0;
        reg_we           = 1'b0;
        flags_we         = 1'b0;
        dmem_we          = 1'b0;

        alu_a_zero       = 1'b0;
        alu_b_immediate  = 1'b0;
        alu_op           = 2'b00;
        writeback_sel    = WB_ALUOUT;

        case (state)
            FETCH: begin
                ir_we      = 1'b1;
                pc_inc     = 1'b1;
                next_state = DECODE;
            end

            DECODE: begin
                a_we = 1'b1;
                b_we = 1'b1;

                if (NOOP)
                    next_state = FETCH;
                else if (LOADI)
                    next_state = LOADI_WB;
                else if (MOVE)
                    next_state = MOVE_WB;
                else if (ADD || SUB)
                    next_state = EXEC_R;
                else if (ADDI || SUBI)
                    next_state = EXEC_I;
                else if (SHIFTL || SHIFTR)
                    next_state = SHIFT_EXEC;
                else if (LOAD || LOADF)
                    next_state = LOAD_ADDR;
                else if (STORE || STOREF)
                    next_state = STORE_ADDR;
                else if (CMP)
                    next_state = CMP_EXEC;
                else if (JUMP)
                    next_state = JUMP_EXEC;
                else if (BRE || BRNE || BRG || BRGE)
                    next_state = BRANCH_EXEC;
                else
                    next_state = FETCH;
            end

            EXEC_R: begin
                alu_a_zero      = 1'b0;
                alu_b_immediate = 1'b0;
                alu_op          = SUB ? 2'b01 : 2'b00;
                aluout_we       = 1'b1;
                flags_we        = 1'b1;
                next_state      = ALU_WB;
            end

            EXEC_I: begin
                alu_a_zero      = 1'b0;
                alu_b_immediate = 1'b1;
                alu_op          = SUBI ? 2'b01 : 2'b00;
                aluout_we       = 1'b1;
                flags_we        = 1'b1;
                next_state      = ALU_WB;
            end

            SHIFT_EXEC: begin
                alu_a_zero      = 1'b0;
                alu_b_immediate = 1'b0;
                alu_op          = SHIFTR ? 2'b11 : 2'b10;
                aluout_we       = 1'b1;
                flags_we        = 1'b1;
                next_state      = ALU_WB;
            end

            ALU_WB: begin
                reg_we        = 1'b1;
                writeback_sel = WB_ALUOUT;
                next_state    = FETCH;
            end

            LOAD_ADDR: begin
                alu_a_zero      = LOAD;
                alu_b_immediate = 1'b1;
                alu_op          = 2'b00;
                aluout_we       = 1'b1;
                next_state      = LOAD_MEM;
            end

            LOAD_MEM: begin
                mdr_we      = 1'b1;
                next_state  = LOAD_WB;
            end

            LOAD_WB: begin
                reg_we        = 1'b1;
                writeback_sel = WB_MDR;
                next_state    = FETCH;
            end

            STORE_ADDR: begin
                alu_a_zero      = STORE;
                alu_b_immediate = 1'b1;
                alu_op          = 2'b00;
                aluout_we       = 1'b1;
                next_state      = STORE_MEM;
            end

            STORE_MEM: begin
                dmem_we     = 1'b1;
                next_state  = FETCH;
            end

            CMP_EXEC: begin
                alu_a_zero      = 1'b0;
                alu_b_immediate = 1'b0;
                alu_op          = 2'b01;
                flags_we        = 1'b1;
                next_state      = FETCH;
            end

            BRANCH_EXEC: begin
                if ((BRE  &&  ZF) ||
                    (BRNE && ~ZF) ||
                    (BRG  && ~ZF && signed_greater) ||
                    (BRGE && signed_greater))
                    pc_load = 1'b1;

                next_state = FETCH;
            end

            JUMP_EXEC: begin
                pc_load     = 1'b1;
                next_state  = FETCH;
            end

            MOVE_WB: begin
                reg_we        = 1'b1;
                writeback_sel = WB_OPERAND_A;
                next_state    = FETCH;
            end

            LOADI_WB: begin
                reg_we        = 1'b1;
                writeback_sel = WB_IMM;
                next_state    = FETCH;
            end

            default: begin
                next_state = FETCH;
            end
        endcase
    end

endmodule
