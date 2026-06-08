//q1
//How many states does your FSM have? 2
//What does each state represent? state of walking left and right respectively
module lemmings_1(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
    output walk_left,
    output walk_right); //  

     parameter LEFT=0, RIGHT=1;
    reg state, next_state;

    always @(*) begin
               case (state)
            LEFT:next_state=(bump_left)?RIGHT:LEFT;
            RIGHT:next_state=(bump_right)?LEFT:RIGHT;
            default: next_state=LEFT;
        endcase   
            
    end

    always @(posedge clk, posedge areset) begin
        if (areset) begin
            state <= LEFT; // Resets to state B
        end else begin
            state <= next_state;
        end
    end

    assign walk_left = (state ==LEFT );
    assign walk_right = (state == RIGHT);

endmodule

//q2
//How many states does your FSM have? 4
//What does each state represent? state of walking left and right. fall_l/r represents the state of falling and 
//the direction it will move after reaching ground.

module lemmings_2(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
    input ground,
    output walk_left,
    output walk_right,
    output aaah ); 
 

parameter LEFT=2'd0, RIGHT=2'd1, FALL_L=2'd2, FALL_R=2'd3;
    reg [1:0]state, next_state;

    always @(*) begin
        case (state)
            LEFT:begin
                if (!ground) next_state=FALL_L;
                
                else if (bump_left) next_state=RIGHT;
                else next_state=LEFT;
            end
            RIGHT:begin
                if (!ground) next_state=FALL_R;
                else if (bump_right)next_state=LEFT;
                else  next_state=RIGHT;
            end
             FALL_L:begin
                 if (ground) next_state=LEFT;
                 else next_state=FALL_L;
             end
            FALL_R:begin
                if (ground) next_state=RIGHT;
                 else next_state=FALL_R;
             end
            default: next_state=LEFT;
        endcase   
            
    end

    always @(posedge clk, posedge areset) begin
        if (areset) begin
            state <= LEFT; 
        end else begin
            state <= next_state;
        end
    end

    assign walk_left = (state ==LEFT );
    assign walk_right = (state == RIGHT);
    assign aaah=(state==FALL_L || state==FALL_R);



endmodule


//q3
//How many states does your FSM have? 6
//What does each state represent? state of walking left and right. fall_l/r represents the state of falling and 
//the direction it will move after reaching ground. dig_l/r represents the state of digging, and which fall_l/r 
//state it will lead to when it finishes digging
module lemmings_3(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
    input ground,
    input dig,
    output walk_left,
    output walk_right,
    output aaah,
    output digging ); 
parameter LEFT=3'd0, RIGHT=3'd1, FALL_L=3'd2, FALL_R=3'd3,dig_l=3'd4,dig_r=3'd5;
    reg [2:0]state, next_state;

    always @(*) begin
        case (state)
            LEFT:begin
                if (dig==1 &ground==1) next_state=dig_l;
                else if (!ground) next_state=FALL_L;
                
                else if (bump_left) next_state=RIGHT;
                else next_state=LEFT;
            end
            RIGHT:begin
                if(dig==1 &ground==1) next_state=dig_r;
                else if (!ground) next_state=FALL_R;
                else if (bump_right)next_state=LEFT;
                else  next_state=RIGHT;
            end
             FALL_L:begin
                 if (ground) next_state=LEFT;
                 else next_state=FALL_L;
             end
            FALL_R:begin
                if (ground) next_state=RIGHT;
                 else next_state=FALL_R;
             end
            dig_l:begin
                if (!ground) next_state=FALL_L;
                else next_state=dig_l;
            end
            dig_r:begin
                if (!ground) next_state=FALL_R;
                else next_state=dig_r;
            end
            default: next_state=LEFT;
        endcase   
            
    end

    always @(posedge clk, posedge areset) begin
        if (areset) begin
            state <= LEFT; 
        end else begin
            state <= next_state;
        end
    end

    assign walk_left = (state ==LEFT );
    assign walk_right = (state == RIGHT);
    assign aaah=(state==FALL_L || state==FALL_R);
    assign digging=(state==dig_l||state==dig_r);
endmodule


//q4
//How many states does your FSM have? 7
//What does each state represent? state of walking left and right. fall_l/r represents the state of falling and 
//the direction it will move after reaching ground. dig_l/r represents the state of digging, and which fall_l/r 
//state it will lead to when it finishes digging. splat represents the state of dying, all outputs become 0 forever. 

module lemmings_4(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
    input ground,
    input dig,
    output walk_left,
    output walk_right,
    output aaah,
    output digging ); 
parameter LEFT=3'd0, RIGHT=3'd1, FALL_L=3'd2, FALL_R=3'd3,dig_l=3'd4,dig_r=3'd5,splat=3'd6;
    reg [2:0]state, next_state;
    reg[4:0] count;
    always @(*) begin
        case (state)
            LEFT:begin
                if (dig==1 &ground==1) next_state=dig_l;
                else if (!ground) next_state=FALL_L;
                
                else if (bump_left) next_state=RIGHT;
                else next_state=LEFT;
            end
            RIGHT:begin
                if(dig==1 &ground==1) next_state=dig_r;
                else if (!ground) next_state=FALL_R;
                else if (bump_right)next_state=LEFT;
                else  next_state=RIGHT;
            end
             FALL_L:begin
                 if (ground==1 && count>20) next_state=splat;
                 else if (ground)
                     next_state=LEFT;
                
                 else next_state=FALL_L;
             end
            FALL_R:begin
                if (ground==1 && count>20) next_state=splat;
                else if (ground) 
                    next_state=RIGHT;
        
                 else next_state=FALL_R;
             end
            dig_l:begin
                if (!ground) next_state=FALL_L;
                else next_state=dig_l;
            end
            dig_r:begin
                if (!ground) next_state=FALL_R;
                else next_state=dig_r;
            end
            splat: next_state=splat;
            default: next_state=LEFT;
        endcase   
            
    end

    always @(posedge clk or posedge areset) begin
        if (areset) begin
            state <= LEFT;
            count <= 5'd0;
        end else begin
            state <= next_state;
            
            if (next_state == FALL_L || next_state == FALL_R) begin
                if (count < 5'd25) begin 
                    count <= count + 5'b1;
                end
            end else begin
                count <= 5'd0;
            end
        end
    end

    assign walk_left = (state ==LEFT );
    assign walk_right = (state == RIGHT);
    assign aaah=(state==FALL_L || state==FALL_R);
    assign digging=(state==dig_l||state==dig_r);
    
endmodule