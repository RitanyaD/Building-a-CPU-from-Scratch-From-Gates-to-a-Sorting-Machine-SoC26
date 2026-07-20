module control_unit (
    input  [22:0] inst_decoded,
    input  [1:0]  X,
    input  [1:0]  Y,
    input         ZF,
    input         NF,
    input         OF,

    output reg        reg_write,
    output reg        mem_write,
    output reg        mem_to_reg,
    output reg [1:0]  alu_op,
    output reg        flags_write,
    output reg        is_load,
    output reg        is_branch,
    output reg        branch_taken,
    output reg        swap_en,
    output reg [1:0]  write_addr,
    output reg        use_rx,
    output reg        use_ry
);

    wire NOOP    = inst_decoded[0];
    wire INPUTC  = inst_decoded[1];
    wire INPUTCF = inst_decoded[2];
    wire INPUTD  = inst_decoded[3];
    wire INPUTDF = inst_decoded[4];
    wire MOVE    = inst_decoded[5];
    wire LOADI   = inst_decoded[6];
    wire ADD     = inst_decoded[7];
    wire ADDI    = inst_decoded[8];
    wire SUB     = inst_decoded[9];
    wire SUBI    = inst_decoded[10];
    wire LOAD    = inst_decoded[11];
    wire LOADF   = inst_decoded[12];
    wire STORE   = inst_decoded[13];
    wire STOREF  = inst_decoded[14];
    wire SHIFTL  = inst_decoded[15];
    wire SHIFTR  = inst_decoded[16];
    wire CMP     = inst_decoded[17];
    wire JUMP    = inst_decoded[18];
    wire BRE     = inst_decoded[19];
    wire BRNE    = inst_decoded[20];
    wire BRG     = inst_decoded[21];
    wire BRGE    = inst_decoded[22];

    wire signed_ge = (NF == OF);

    always @(*) begin
        reg_write    = 1'b0;
        mem_write    = 1'b0;
        mem_to_reg   = 1'b0;
        alu_op       = 2'b00;
        flags_write  = 1'b0;
        is_load      = 1'b0;
        is_branch    = 1'b0;
        branch_taken = 1'b0;
        swap_en      = 1'b0;
        write_addr   = X;
        use_rx       = 1'b0;
        use_ry       = 1'b0;

        if (MOVE) begin
            reg_write  = 1'b1;
            swap_en    = 1'b1;
            use_ry     = 1'b1;
        end
        else if (LOADI) begin
            reg_write  = 1'b1;
        end
        else if (ADD) begin
            reg_write   = 1'b1;
            alu_op      = 2'b00;
            flags_write = 1'b1;
            use_rx      = 1'b1;
            use_ry      = 1'b1;
        end
        else if (ADDI) begin
            reg_write   = 1'b1;
            alu_op      = 2'b00;
            flags_write = 1'b1;
            use_rx      = 1'b1;
        end
        else if (SUB) begin
            reg_write   = 1'b1;
            alu_op      = 2'b01;
            flags_write = 1'b1;
            use_rx      = 1'b1;
            use_ry      = 1'b1;
        end
        else if (SUBI) begin
            reg_write   = 1'b1;
            alu_op      = 2'b01;
            flags_write = 1'b1;
            use_rx      = 1'b1;
        end
        else if (LOAD) begin
            reg_write  = 1'b1;
            mem_to_reg = 1'b1;
            is_load    = 1'b1;
            swap_en    = 1'b1;
        end
        else if (LOADF) begin
            reg_write  = 1'b1;
            mem_to_reg = 1'b1;
            is_load    = 1'b1;
            use_ry     = 1'b1;
        end
        else if (STORE) begin
            mem_write = 1'b1;
            swap_en   = 1'b1;
            use_rx    = 1'b1;
        end
        else if (STOREF) begin
            mem_write = 1'b1;
            swap_en   = 1'b1;
            use_rx    = 1'b1;
            use_ry    = 1'b1;
        end
        else if (SHIFTL) begin
            reg_write   = 1'b1;
            alu_op      = 2'b10;
            flags_write = 1'b1;
            use_rx      = 1'b1;
        end
        else if (SHIFTR) begin
            reg_write   = 1'b1;
            alu_op      = 2'b11;
            flags_write = 1'b1;
            use_rx      = 1'b1;
        end
        else if (CMP) begin
            alu_op      = 2'b01;
            flags_write = 1'b1;
            use_rx      = 1'b1;
            use_ry      = 1'b1;
        end
        else if (JUMP) begin
            is_branch    = 1'b1;
            branch_taken = 1'b1;
        end
        else if (BRE) begin
            is_branch    = 1'b1;
            branch_taken = ZF;
        end
        else if (BRNE) begin
            is_branch    = 1'b1;
            branch_taken = ~ZF;
        end
        else if (BRG) begin
            is_branch    = 1'b1;
            branch_taken = (~ZF) & signed_ge;
        end
        else if (BRGE) begin
            is_branch    = 1'b1;
            branch_taken = signed_ge;
        end
        else if (NOOP || INPUTC || INPUTCF || INPUTD || INPUTDF) begin
            // Unsupported external-input instructions behave as NOPs here.
        end
    end

endmodule
