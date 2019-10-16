module laundrycombo_tb;
logic clk, card_in, door_closed, double_wash, dry_en;
logic wash, dry, door_unlocked, state;
 
laundrycombo L1(state, clk, card_in, door_closed, double_wash, dry_en, wash, dry, door_unlocked);
 
initial begin
clk=0;
door_closed=0;
card_in=0;
double_wash=1;
dry_en=1;
end

initial begin
#10 card_in = 1;
#20 door_closed = 1;
#40 card_in = 0;
#200 door_closed = 0;
end

always 
begin 
#10 clk = ~clk;
end

endmodule

