module laundrycombo(state, reset, clk, card_in, door_closed, done_washing1, done_washing2, done_drying, prewash_en, double_wash, dry_en, maintenance_mode, wash, ready, dry, door_unlocked, do_not_reset, can_accept_more_credit, pre_w_double_w_dry_selected);

input logic reset, clk, card_in, door_closed, done_washing1, done_washing2, done_drying, prewash_en, double_wash, dry_en, maintenance_mode;
output logic wash, ready, dry, door_unlocked, do_not_reset, can_accept_more_credit, pre_w_double_w_dry_selected;

output logic [8:0] state;
// ready, door_unlocked, wash, dry, do_not_reset, can_accept_more_credit
parameter [8:0] IDLE            = 9'b110000_000; // Laundry is waiting for card (and laundry) to be inserted
parameter [8:0] CARD_IN         = 9'b010000_001; // Card is inserted, it waits for user input and setting (power, temperature, double wash, dry)
parameter [8:0] WAIT_DOOR_CLOSE = 9'b010000_010; // Setting is saved, check if door is locked.
parameter [8:0] WAIT_CARD_OUT   = 9'b000000_011; // Money is deducted, check if card is pulled.
parameter [8:0] SOAKING		= 9'b001010_101; // Soak 
parameter [8:0] ADD_PREWASH	= 9'b001010_100; // Mix soap in etc
parameter [8:0] WASHING         = 9'b001010_000; // Wash
parameter [8:0] CHECK_IF_DOUBLE = 9'b001001_001; // Check if double wash is enabled.
parameter [8:0] SECOND_WASH     = 9'b001010_010; // 2nd round of washing
parameter [8:0] RINSING		= 9'b001010_111; // Rinse the soap off
parameter [8:0] CHECK_IF_DRY    = 9'b001001_011; // Check if drying is enabled.
parameter [8:0] DRYING          = 9'b001110_000; // Dry clothes
parameter [8:0] DONE            = 9'b110000_001; // Waiting for door to be opened.
parameter [8:0] MAINTENANCE	= 9'b000000_000; // Maintenance mode (created to reach 100 cell)

always_ff @(posedge clk) begin
    if (reset) state <= IDLE;
    else begin
        case(state)
            IDLE: 
                if (card_in) state <= CARD_IN;
                else state <= IDLE;
            CARD_IN:
                if (card_in & !door_closed) state <= WAIT_DOOR_CLOSE;
		else if (maintenance_mode) state <= MAINTENANCE;
                else state <= CARD_IN;
            WAIT_DOOR_CLOSE:
                if (door_closed & card_in) state <= WAIT_CARD_OUT;
		else if (maintenance_mode) state <= MAINTENANCE;
                else state <= WAIT_DOOR_CLOSE;
            WAIT_CARD_OUT:
                if (card_in & door_closed) state <= WAIT_CARD_OUT;
		else if (maintenance_mode) state <= MAINTENANCE;
                else if (!card_in & door_closed) state <= SOAKING;
                else state <= WAIT_DOOR_CLOSE;
	    SOAKING:
		if (door_closed & prewash_en) state <= ADD_PREWASH;
		else if (door_closed) state <= WASHING;
		else state <= SOAKING;
	    ADD_PREWASH:
		state <= WASHING;
            WASHING:
                if (door_closed & done_washing1) state <= CHECK_IF_DOUBLE;
                else state <= WASHING;
            CHECK_IF_DOUBLE:
                if (door_closed & card_in) state <= SECOND_WASH;
                else if (door_closed & double_wash) state <= SECOND_WASH;
                else state <= CHECK_IF_DRY;
            SECOND_WASH:
                if (door_closed & done_washing2 & done_washing1) state <= RINSING;
                else state <= SECOND_WASH;
	    RINSING:
		state <= CHECK_IF_DRY;
            CHECK_IF_DRY:
                if (door_closed & card_in) state <= DRYING;
                else if (door_closed & dry_en) state <= DRYING;
                else state <= DONE;
            DRYING:
                if (door_closed & done_drying) state <= DONE;
                else state <= DRYING;
            DONE:
                if (door_closed) state <= DONE;
		else if (maintenance_mode) state <= MAINTENANCE;
                else state <= IDLE;
	    MAINTENANCE:
		if (!maintenance_mode) state <= IDLE;
		else state <= MAINTENANCE;
            default: state <= IDLE;
        endcase
    end
end

always_comb begin 
    ready = state[8];
    door_unlocked = state[7];
    wash = state[6];
    dry = state[5];
    do_not_reset = state[4];
    can_accept_more_credit = state[3];
    pre_w_double_w_dry_selected = prewash_en | double_wash | dry_en;
end

endmodule

