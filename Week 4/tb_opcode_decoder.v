`timescale 1ns/1ps

module tb_opcode_decoder;

reg [15:8] instr;

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
wire BRE_BRZ;
wire BRNE_BRNZ;
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

wire x1,x0,y1,y0;

opcode_decoder dut (
    .instr(instr),

    .NOOP(NOOP),
    .INPUTC(INPUTC),
    .INPUTCF(INPUTCF),
    .INPUTD(INPUTD),
    .INPUTDF(INPUTDF),
    .MOVE(MOVE),
    .LOADI(LOADI),
    .SHIFTL(SHIFTL),
    .SHIFTR(SHIFTR),
    .CMP(CMP),
    .JUMP(JUMP),
    .BRE_BRZ(BRE_BRZ),
    .BRNE_BRNZ(BRNE_BRNZ),
    .BRG(BRG),
    .BRGE(BRGE),
    .ADD(ADD),
    .ADDI(ADDI),
    .SUB(SUB),
    .SUBI(SUBI),
    .LOAD(LOAD),
    .LOADF(LOADF),
    .STORE(STORE),
    .STOREF(STOREF),
    .x1(x1),
    .x0(x0),
    .y1(y1),
    .y0(y0)
);

initial begin

    $display("Starting decoder test");

    $monitor(
      "t=%0t instr=%b x1=%b x0=%b y1=%b y0=%b | NOOP=%b MOVE=%b ADD=%b SUB=%b LOAD=%b STORE=%b",
       $time, instr, x1,x0,y1,y0,
       NOOP, MOVE, ADD, SUB, LOAD, STORE
    );

    // NOOP
    instr = 8'b0000_0000;
    #10;

    // INPUTC
    instr = 8'b0001_0000;
    #10;

    // INPUTCF
    instr = 8'b0001_0001;
    #10;

    // INPUTD
    instr = 8'b0001_0010;
    #10;

    // INPUTDF
    instr = 8'b0001_0011;
    #10;

    // MOVE
    instr = 8'b0010_0000;
    #10;

    // LOADI
    instr = 8'b0011_0000;
    #10;

    // SHIFTL
    instr = 8'b0100_0000;
    #10;

    // SHIFTR
    instr = 8'b0100_1000;
    #10;

    // CMP
    instr = 8'b0101_0000;
    #10;

    // JUMP
    instr = 8'b0110_0000;
    #10;

    // BRE/BRZ
    instr = 8'b0111_0000;
    #10;

    // BRNE/BRNZ
    instr = 8'b0111_0100;
    #10;

    // BRG
    instr = 8'b0111_1000;
    #10;

    // BRGE
    instr = 8'b0111_1100;
    #10;

    // ADD
    instr = 8'b1000_0000;
    #10;

    // ADDI
    instr = 8'b1001_0000;
    #10;

    // SUB
    instr = 8'b1010_0000;
    #10;

    // SUBI
    instr = 8'b1011_0000;
    #10;

    // LOAD
    instr = 8'b1100_0000;
    #10;

    // LOADF
    instr = 8'b1101_0000;
    #10;

    // STORE
    instr = 8'b1110_0000;
    #10;

    // STOREF
    instr = 8'b1111_0000;
    #10;

    $display("Test complete");
    $finish;

end

endmodule