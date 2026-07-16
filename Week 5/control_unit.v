module control_unit (
    input [22:0] inst_decoded, 
    input [1:0] X,             
    input [1:0] Y,             
    input ZF, NF, OF,          
    output c1,
    output c2,
    output c3,
    output reg [1:0] port0_sel, // c4, c5
    output reg [1:0] port1_sel, // c6, c7
    output reg [1:0] write_sel, // c8, c9
    output c10, c11,
    output [1:0] alu_sel,      // c12, c13 
    output c14, c15, c16, c17, c18
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

   
    assign c1  = INPUTC | INPUTCF;
    assign c3  = 1'b1; 
    assign c10 = MOVE | LOADI | ADD | ADDI | SUB | SUBI | LOAD | LOADF | SHIFTL | SHIFTR;
    assign c11 = INPUTCF | INPUTDF | MOVE | ADDI | SUBI | LOADF | STOREF;
    assign c14 = ADD | ADDI | SUB | SUBI | SHIFTL | SHIFTR | CMP;
    assign c15 = INPUTC | INPUTD | LOADI | LOAD | STORE;
    assign c16 = INPUTD | INPUTDF;
    assign c17 = INPUTD | INPUTDF | STORE | STOREF;
    assign c18 = LOAD | LOADF;

    
    wire nf_xnor_of = (NF == OF);
    assign c2 = JUMP | 
                (BRE  & ZF) | 
                (BRNE & ~ZF) | 
                (BRG  & ~ZF & nf_xnor_of) | 
                (BRGE & nf_xnor_of);

    assign alu_sel[1] = SHIFTL | SHIFTR;
	 assign alu_sel[0] = SUB | SUBI | CMP | SHIFTR;

    
    always @(*) begin
        if (MOVE | LOADF | STOREF)
            port0_sel = Y;
        else if (INPUTCF | INPUTDF | ADD | ADDI | SUB | SUBI | SHIFTL | SHIFTR | CMP)
            port0_sel = X;
        else
            port0_sel = 2'b00;

        if (STORE | STOREF)
            port1_sel = X;
        else if (ADD | SUB | CMP)
            port1_sel = Y;
        else
            port1_sel = 2'b00;

        if (MOVE | LOADI | ADD | ADDI | SUB | SUBI | LOAD | LOADF | SHIFTL | SHIFTR)
            write_sel = X;
        else
            write_sel = 2'b00;
    end

endmodule