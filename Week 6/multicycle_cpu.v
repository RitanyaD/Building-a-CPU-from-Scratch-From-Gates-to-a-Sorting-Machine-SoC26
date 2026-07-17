module multicycle_cpu (
    input clk,
    input rst
);

    wire [5:0] pc_value;
    wire       pc_inc;
    wire       pc_load;
    wire [5:0] pc_load_value;

    pc pc_unit (
        .clk      (clk),
        .rst      (rst),
        .inc      (pc_inc),
        .load     (pc_load),
        .load_val (pc_load_value),
        .pc_out   (pc_value)
    );

    wire [15:0] code_instruction;

    code_memory instruction_memory (
        .addr        (pc_value),
        .instruction (code_instruction)
    );

    wire        ir_we;
    wire [15:0] instruction;

    internal_register #(.WIDTH(16)) ir_reg (
        .clk (clk),
        .rst (rst),
        .we  (ir_we),
        .d   (code_instruction),
        .q   (instruction)
    );

    wire [1:0] X;
    wire [1:0] Y;
    wire [7:0] immediate;

    assign X = instruction[11:10];
    assign Y = instruction[9:8];
    assign immediate = instruction[7:0];

    wire NOOP;
    wire INPUTC;
    wire INPUTCF;
    wire INPUTD;
    wire INPUTDF;
    wire MOVE;
    wire LOADI;
    wire SHIFTL;
    wire SHIFTR;
    wire CMP;
    wire JUMP;
    wire BRE;
    wire BRNE;
    wire BRG;
    wire BRGE;
    wire ADD;
    wire ADDI;
    wire SUB;
    wire SUBI;
    wire LOAD;
    wire LOADF;
    wire STORE;
    wire STOREF;
    wire x1, x0, y1, y0;

    opcode_decoder decoder (
        .instr       (instruction[15:8]),
        .NOOP        (NOOP),
        .INPUTC      (INPUTC),
        .INPUTCF     (INPUTCF),
        .INPUTD      (INPUTD),
        .INPUTDF     (INPUTDF),
        .MOVE        (MOVE),
        .LOADI       (LOADI),
        .SHIFTL      (SHIFTL),
        .SHIFTR      (SHIFTR),
        .CMP         (CMP),
        .JUMP        (JUMP),
        .BRE_BRZ     (BRE),
        .BRNE_BRNZ   (BRNE),
        .BRG         (BRG),
        .BRGE        (BRGE),
        .ADD         (ADD),
        .ADDI        (ADDI),
        .SUB         (SUB),
        .SUBI        (SUBI),
        .LOAD        (LOAD),
        .LOADF       (LOADF),
        .STORE       (STORE),
        .STOREF      (STOREF),
        .x1          (x1),
        .x0          (x0),
        .y1          (y1),
        .y0          (y0)
    );

    reg [1:0] read_addr0;
    reg [1:0] read_addr1;
    wire [1:0] write_addr;

    always @(*) begin
        if (MOVE || LOADF || STOREF)
            read_addr0 = Y;
        else if (ADD || ADDI || SUB || SUBI || SHIFTL || SHIFTR || CMP)
            read_addr0 = X;
        else
            read_addr0 = 2'b00;

        if (STORE || STOREF)
            read_addr1 = X;
        else if (ADD || SUB || CMP)
            read_addr1 = Y;
        else
            read_addr1 = 2'b00;
    end

    assign write_addr = X;

    wire [7:0] reg_port0;
    wire [7:0] reg_port1;
    wire [7:0] reg_write_data;
    wire       reg_we;

    regfile registers (
        .clk    (clk),
        .we     (reg_we),
        .raddr0 (read_addr0),
        .raddr1 (read_addr1),
        .waddr  (write_addr),
        .wdata  (reg_write_data),
        .rst    (rst),
        .rdata0 (reg_port0),
        .rdata1 (reg_port1)
    );

    wire       a_we;
    wire       b_we;
    wire [7:0] operand_a;
    wire [7:0] operand_b;

    internal_register #(.WIDTH(8)) operand_a_reg (
        .clk (clk),
        .rst (rst),
        .we  (a_we),
        .d   (reg_port0),
        .q   (operand_a)
    );

    internal_register #(.WIDTH(8)) operand_b_reg (
        .clk (clk),
        .rst (rst),
        .we  (b_we),
        .d   (reg_port1),
        .q   (operand_b)
    );

    wire       alu_a_zero;
    wire       alu_b_immediate;
    wire [1:0] alu_op;
    wire [7:0] alu_input_a;
    wire [7:0] alu_input_b;
    wire [7:0] alu_result;
    wire       alu_zero;
    wire       alu_negative;
    wire       alu_overflow;

    assign alu_input_a = alu_a_zero ? 8'b0 : operand_a;
    assign alu_input_b = alu_b_immediate ? immediate : operand_b;

    alu arithmetic_logic_unit (
        .a        (alu_input_a),
        .b        (alu_input_b),
        .op       (alu_op),
        .result   (alu_result),
        .zero     (alu_zero),
        .negative (alu_negative),
        .overflow (alu_overflow)
    );

    wire       aluout_we;
    wire [7:0] alu_out;

    internal_register #(.WIDTH(8)) aluout_reg (
        .clk (clk),
        .rst (rst),
        .we  (aluout_we),
        .d   (alu_result),
        .q   (alu_out)
    );

    wire flags_we;
    wire ZF;
    wire NF;
    wire OF;

    flags_register flags (
        .clk  (clk),
        .rst  (rst),
        .we   (flags_we),
        .z_in (alu_zero),
        .n_in (alu_negative),
        .o_in (alu_overflow),
        .zf   (ZF),
        .nf   (NF),
        .of   (OF)
    );

    wire       dmem_we;
    wire [3:0] dmem_addr;
    wire [7:0] dmem_read_data;

    assign dmem_addr = alu_out[3:0];

    data_memory data_mem (
        .clk   (clk),
        .we    (dmem_we),
        .addr  (dmem_addr),
        .wdata (operand_b),
        .rdata (dmem_read_data)
    );

    wire       mdr_we;
    wire [7:0] mdr;

    internal_register #(.WIDTH(8)) mdr_reg (
        .clk (clk),
        .rst (rst),
        .we  (mdr_we),
        .d   (dmem_read_data),
        .q   (mdr)
    );

    wire [1:0] writeback_sel;

    reg [7:0] writeback_mux;
    always @(*) begin
        case (writeback_sel)
            2'b00: writeback_mux = alu_out;
            2'b01: writeback_mux = mdr;
            2'b10: writeback_mux = immediate;
            2'b11: writeback_mux = operand_a;
            default: writeback_mux = 8'b0;
        endcase
    end

    assign reg_write_data = writeback_mux;

    assign pc_load_value = pc_value + instruction[5:0];

    wire [4:0] state_debug;

    multicycle_control controller (
        .clk             (clk),
        .rst             (rst),
        .NOOP            (NOOP),
        .MOVE            (MOVE),
        .LOADI           (LOADI),
        .ADD             (ADD),
        .ADDI            (ADDI),
        .SUB             (SUB),
        .SUBI            (SUBI),
        .LOAD            (LOAD),
        .LOADF           (LOADF),
        .STORE           (STORE),
        .STOREF          (STOREF),
        .SHIFTL          (SHIFTL),
        .SHIFTR          (SHIFTR),
        .CMP             (CMP),
        .JUMP            (JUMP),
        .BRE             (BRE),
        .BRNE            (BRNE),
        .BRG             (BRG),
        .BRGE            (BRGE),
        .ZF              (ZF),
        .NF              (NF),
        .OF              (OF),
        .ir_we           (ir_we),
        .pc_inc          (pc_inc),
        .pc_load         (pc_load),
        .a_we            (a_we),
        .b_we            (b_we),
        .aluout_we       (aluout_we),
        .mdr_we          (mdr_we),
        .reg_we          (reg_we),
        .flags_we        (flags_we),
        .dmem_we         (dmem_we),
        .alu_a_zero      (alu_a_zero),
        .alu_b_immediate (alu_b_immediate),
        .alu_op          (alu_op),
        .writeback_sel   (writeback_sel),
        .state_debug     (state_debug)
    );

endmodule
