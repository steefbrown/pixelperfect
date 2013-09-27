
module switch_handler
(
	input clk,
	input clr,
	input pulse_en,
	input [31:0] addr,
	input [2:0] switches,	// the switch pins
	output reg [1:0] switch_val // registered switch value
);

reg [1:0] cur_state, next_state;
reg [2:0] switch_reg;

// register the switches
always @(posedge clk or posedge clr)
	if (clr)
		cur_state <= 0;
	else if (pulse_en)
		cur_state <= next_state;

always @(*)
	case (cur_state)
		0:	begin
				// allow switch_reg to be set to the last switch press
				if (switches)
					switch_reg = switches;

				if (addr[23] && (addr[2:0] == 3'b001))
					next_state = cur_state + 1'b1;
			end
		1:	begin
				// old switch_val high for one more cycle, so the processor can read it
				next_state = cur_state + 1'b1;
			end
		2:	begin
				// unset the switch_reg when processor reads it's value
				switch_reg = 0;
				next_state = 0;
			end
	endcase

// map switches to values 1-3, or 0 if none pressed
always @(*)
	case (switch_reg)
		3'b001: 	switch_val = 2'b01;
		3'b010: 	switch_val = 2'b10;
		3'b100: 	switch_val = 2'b11;
		default: 	switch_val = 2'b00;
	endcase

endmodule

