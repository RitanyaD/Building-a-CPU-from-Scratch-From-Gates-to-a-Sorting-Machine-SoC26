module opcode_decoder(
    input  [15:8] instr,

    output reg NOOP,
    output reg INPUTC,
    output reg INPUTCF,
    output reg INPUTD,
    output reg INPUTDF,
    output reg MOVE,
    output reg LOADI,
    output reg SHIFTL,
    output reg SHIFTR,	
    output reg CMP,
    output reg JUMP,
    output reg BRE_BRZ,
    output reg BRNE_BRNZ,
    output reg BRG,
    output reg BRGE,
    output reg ADD,
    output reg ADDI,
    output reg SUB,
    output reg SUBI,
    output reg LOAD,
    output reg LOADF,
    output reg STORE,
    output reg STOREF,
	 output x1,x0,y1,y0
);
assign x1 = instr[11];   
assign x0 = instr[10];   
assign y1 = instr[9];
assign y0 = instr[8];  

always @(*) begin

    {
    NOOP,
    INPUTC,
    INPUTCF,
    INPUTD,
    INPUTDF,
    MOVE,
    LOADI,
    SHIFTL,
    SHIFTR,
    CMP,
    JUMP,
    BRE_BRZ,
    BRNE_BRNZ,
    BRG,
    BRGE,
    ADD,
    ADDI,
    SUB,
    SUBI,
    LOAD,
    LOADF,
    STORE,
    STOREF
    } = 23'b0;

    case (instr[15:12])

        4'b0000: NOOP = 1'b1;

        4'b0001: begin
            case (instr[9:8])
                2'b00: INPUTC  = 1'b1;
                2'b01: INPUTCF = 1'b1;
                2'b10: INPUTD  = 1'b1;
                2'b11: INPUTDF = 1'b1;
            endcase
        end

        4'b0010: MOVE  = 1'b1;
        4'b0011: LOADI = 1'b1;

        4'b0100: begin
            if (instr[11])
                SHIFTR = 1'b1;
            else
                SHIFTL = 1'b1;
        end

        4'b0101: CMP  = 1'b1;
        4'b0110: JUMP = 1'b1;

        4'b0111: begin
            case (instr[11:10])
                2'b00: BRE_BRZ    = 1'b1;
                2'b01: BRNE_BRNZ  = 1'b1;
                2'b10: BRG        = 1'b1;
                2'b11: BRGE       = 1'b1;
            endcase
        end

        4'b1000: ADD   = 1'b1;
        4'b1001: ADDI  = 1'b1;
        4'b1010: SUB   = 1'b1;
        4'b1011: SUBI  = 1'b1;
        4'b1100: LOAD  = 1'b1;
        4'b1101: LOADF = 1'b1;
        4'b1110: STORE = 1'b1;
        4'b1111: STOREF= 1'b1;

    endcase
end

endmodule