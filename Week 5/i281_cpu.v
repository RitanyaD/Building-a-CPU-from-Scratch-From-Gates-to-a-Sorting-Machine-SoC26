module i281_cpu(
    input clk,
    input rst
);

    // ============================================================
    // 1. PROGRAM COUNTER
    // ============================================================

    wire [5:0] pc_value;
    wire       pc_load;
    wire [5:0] pc_load_val;

    pc pc_unit(
        .clk      (clk),
        .rst      (rst),
        .inc      (1'b1),
        .load     (pc_load),
        .load_val (pc_load_val),
        .pc_out   (pc_value)
    );


    // ============================================================
    // 2. CODE MEMORY
    // ============================================================

    wire [15:0] instruction;

    code_memory instruction_memory(
        .addr        (pc_value),
        .instruction (instruction)
    );


    // Instruction fields

    wire [1:0] X;
    wire [1:0] Y;

    assign X = instruction[11:10];
    assign Y = instruction[9:8];

    wire [7:0] immediate;
    assign immediate = instruction[7:0];


    // ============================================================
    // 3. OPCODE DECODER
    // ============================================================

    wire NOOP;
    wire INPUTC;
    wire INPUTCF;
    wire INPUTD;
    wire INPUTDF;
    wire MOVE;
    wire LOADI;
    wire ADD;
    wire ADDI;
    wire SUB;
    wire SUBI;
    wire LOAD;
    wire LOADF;
    wire STORE;
    wire STOREF;
    wire SHIFTL;
    wire SHIFTR;
    wire CMP;
    wire JUMP;
    wire BRE;
    wire BRNE;
    wire BRG;
    wire BRGE;

    wire x1, x0, y1, y0;

    opcode_decoder decoder(
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


    // ============================================================
    // 4. PACK DECODER OUTPUTS FOR CONTROL UNIT
    // ============================================================

    wire [22:0] inst_decoded;

    /*
       This ordering must exactly match control_unit.v:

       bit 0  = NOOP
       bit 1  = INPUTC
       bit 2  = INPUTCF
       bit 3  = INPUTD
       bit 4  = INPUTDF
       bit 5  = MOVE
       bit 6  = LOADI
       bit 7  = ADD
       bit 8  = ADDI
       bit 9  = SUB
       bit 10 = SUBI
       bit 11 = LOAD
       bit 12 = LOADF
       bit 13 = STORE
       bit 14 = STOREF
       bit 15 = SHIFTL
       bit 16 = SHIFTR
       bit 17 = CMP
       bit 18 = JUMP
       bit 19 = BRE
       bit 20 = BRNE
       bit 21 = BRG
       bit 22 = BRGE
    */

    assign inst_decoded[0]  = NOOP;
    assign inst_decoded[1]  = INPUTC;
    assign inst_decoded[2]  = INPUTCF;
    assign inst_decoded[3]  = INPUTD;
    assign inst_decoded[4]  = INPUTDF;
    assign inst_decoded[5]  = MOVE;
    assign inst_decoded[6]  = LOADI;
    assign inst_decoded[7]  = ADD;
    assign inst_decoded[8]  = ADDI;
    assign inst_decoded[9]  = SUB;
    assign inst_decoded[10] = SUBI;
    assign inst_decoded[11] = LOAD;
    assign inst_decoded[12] = LOADF;
    assign inst_decoded[13] = STORE;
    assign inst_decoded[14] = STOREF;
    assign inst_decoded[15] = SHIFTL;
    assign inst_decoded[16] = SHIFTR;
    assign inst_decoded[17] = CMP;
    assign inst_decoded[18] = JUMP;
    assign inst_decoded[19] = BRE;
    assign inst_decoded[20] = BRNE;
    assign inst_decoded[21] = BRG;
    assign inst_decoded[22] = BRGE;


    // ============================================================
    // 5. FLAGS
    // ============================================================

    wire ZF;
    wire NF;
    wire OF;

    wire alu_zero;
    wire alu_negative;
    wire alu_overflow;

    wire flags_we;


    // ============================================================
    // 6. CONTROL UNIT
    // ============================================================

    wire c1;
    wire take_branch;     // c2
    wire c3;

    wire [1:0] port0_sel;
    wire [1:0] port1_sel;
    wire [1:0] write_sel;

    wire reg_we;          // c10
    wire alu_src_sel;     // c11
    wire [1:0] alu_sel;   // c12, c13
    wire alu_result_sel;  // c15
    wire dmem_input_sel;  // c16
    wire dmem_we;         // c17
    wire reg_wb_sel;      // c18

    control_unit control(
        .inst_decoded (inst_decoded),
        .X            (X),
        .Y            (Y),

        .ZF           (ZF),
        .NF           (NF),
        .OF           (OF),

        .c1           (c1),
        .c2           (take_branch),
        .c3           (c3),

        .port0_sel    (port0_sel),
        .port1_sel    (port1_sel),
        .write_sel    (write_sel),

        .c10          (reg_we),
        .c11          (alu_src_sel),
        .alu_sel      (alu_sel),

        .c14          (flags_we),
        .c15          (alu_result_sel),
        .c16          (dmem_input_sel),
        .c17          (dmem_we),
        .c18          (reg_wb_sel)
    );


    // ============================================================
    // 7. REGISTER FILE
    // ============================================================

    wire [7:0] reg_port0;
    wire [7:0] reg_port1;
    wire [7:0] reg_write_data;

    regfile registers(
        .clk    (clk),
		  .rst    (rst),
        .we     (reg_we),

        .raddr0 (port0_sel),
        .raddr1 (port1_sel),
        .waddr  (write_sel),

        .wdata  (reg_write_data),

        .rdata0 (reg_port0),
        .rdata1 (reg_port1)
    );


    // ============================================================
    // 8. ALU INPUT MUX
    // ============================================================

    wire [7:0] alu_b;

    /*
       c11 = 0: second register value
       c11 = 1: immediate value
    */

    assign alu_b =
        alu_src_sel ? immediate : reg_port1;


    // ============================================================
    // 9. ALU
    // ============================================================

    wire [7:0] alu_result;

    alu arithmetic_logic_unit(
        .a        (reg_port0),
        .b        (alu_b),
        .op       (alu_sel),

        .result   (alu_result),
        .zero     (alu_zero),
        .negative (alu_negative),
        .overflow (alu_overflow)
    );


    // ============================================================
    // 10. FLAGS REGISTER
    // ============================================================

    flags_register flags(
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


    // ============================================================
    // 11. DATA MEMORY ADDRESS
    // ============================================================

    wire [7:0] effective_address;

    /*
       LOAD / STORE:
           address = immediate

       LOADF / STOREF:
           address = immediate + selected register
    */

    assign effective_address =
        (LOADF || STOREF)
        ? immediate + reg_port0
        : immediate;

    wire [3:0] dmem_addr;

    assign dmem_addr = effective_address[3:0];


    // ============================================================
    // 12. DATA MEMORY
    // ============================================================

    wire [7:0] dmem_read_data;

    data_memory data_mem(
        .clk   (clk),
        .we    (dmem_we),
        .addr  (dmem_addr),

        .wdata (reg_port1),
        .rdata (dmem_read_data)
    );


    // ============================================================
    // 13. REGISTER WRITEBACK
    // ============================================================

    /*
       LOADI writes immediate.
       MOVE writes reg_port0.
       ALU instructions write alu_result.
       LOAD/LOADF write data-memory output.
    */

    reg [7:0] normal_result;

    always @(*) begin
        if (LOADI)
            normal_result = immediate;

        else if (MOVE)
            normal_result = reg_port0;

        else
            normal_result = alu_result;
    end

    assign reg_write_data =
        reg_wb_sel ? dmem_read_data : normal_result;


    // ============================================================
    // 14. PC UPDATE LOGIC
    // ============================================================

    pc_update_logic pc_logic(
        .current_pc  (pc_value),
        .pc_offset   (immediate),
        .take_branch (take_branch),

        .pc_load     (pc_load),
        .pc_load_val (pc_load_val)
    );

endmodule