module laundrycombo(state, clk, card_in, door_closed, double_wash, dry_en, wash, dry, door_unlocked);

input logic clk, card_in, door_closed, double_wash, dry_en;
output logic wash, dry, door_unlocked;

output logic [4:0] state;

parameter [4:0] IDLE            = 5'b1_00_00; // Laundry is waiting for card (and laundry) to be inserted
parameter [4:0] CARD_IN         = 5'b1_00_01; // Card is inserted, it waits for user input and setting (power, temperature, double wash, dry)
parameter [4:0] WAIT_DOOR_CLOSE = 5'b1_00_10; // Setting is saved, check if door is locked.
parameter [4:0] WAIT_CARD_OUT   = 5'b0_00_00; // Money is deducted, check if card is pulled.
parameter [4:0] WASHING         = 5'b0_10_00; // Mix soap in, and wash the clothes, rinses it
parameter [4:0] CHECK_IF_DOUBLE = 5'b0_10_01; // Check if double wash is enabled.
parameter [4:0] SECOND_WASH     = 5'b0_10_10; // 2nd round of washing
parameter [4:0] CHECK_IF_DRY    = 5'b0_10_11; // Check if drying is enabled.
parameter [4:0] DRYING          = 5'b0_11_01; // Dry clothes
parameter [4:0] DONE            = 5'b1_00_11; // Waiting for door to be opened.

always_ff @(posedge clk) begin
    case(state)
        IDLE: if (card_in) state <= CARD_IN;
            else state <= IDLE;
        CARD_IN:
            state <= WAIT_DOOR_CLOSE;
        WAIT_DOOR_CLOSE:
            if (door_closed) state <= WAIT_CARD_OUT;
            else state <= WAIT_DOOR_CLOSE;
        WAIT_CARD_OUT:
            if (card_in) state <= WAIT_CARD_OUT;
            else if (door_closed) state <= WASHING;
        WASHING:
            state <= CHECK_IF_DOUBLE;
        CHECK_IF_DOUBLE:
            if (double_wash) state <= SECOND_WASH;
            else state <= CHECK_IF_DRY;
        SECOND_WASH:
            state <= CHECK_IF_DRY;
        CHECK_IF_DRY:
            if (dry_en) state <= DRYING;
            else state <= DONE;
        DRYING:
            state <= DONE;
        DONE:
            if (door_closed) state <= DONE;
            else state <= IDLE;
        default: state <= IDLE;
    endcase
end

always_comb begin 
    door_unlocked = state[4];
    wash = state[3];
    dry = state[2];
end

endmodule

