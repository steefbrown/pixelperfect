

module vga_controller2
(
	//inputs
	clk,
	reset,
	hold,
	//outputs
	hs,
	vs,
	blank
);

`include "defines.v"

input			clk;
input			reset;		// asyncronous reset
input			hold;		// wait for buffer memory to be filled
output			hs;			// horisontal sync signal
output			vs;			// vertical sync signal
output			blank;		// "beam" is out of visible area

wire			hs;
wire			vs;
reg		[10:0]	h_counter = 0;
reg		[10:0]	v_counter = 0;
wire			blank;
wire			video_enable;

// if using 800x600 with 40MHz clk:
// timing diagram for the horizontal synch signal (HS)
// 0                       840    968              1056 (pixels) @ 60Hz
// 0                       856    976              1040 (pixels) @ 72Hz
// _________________________|------|_________________
// timing diagram for the vertical synch signal (VS)
// 0                                601    605     628 (lines) @ 60Hz
// 0                                637    643     666 (lines) @ 72Hz
// __________________________________|------|________

// horisontal counter
always @ (posedge clk or posedge reset)
	begin
		if (reset)
			h_counter <= 0;
		else if (h_counter == `HMAX)
			h_counter <= 0;
		else if (hold == 0)
			h_counter <= h_counter + 1'b1;
	end
//

// vertical counter
always @ (posedge clk or posedge reset)
	begin
		if (reset)
			v_counter <= 0;
		else if (h_counter == `HMAX)
			begin
				if (v_counter == `VMAX)
					v_counter <= 0;
				else if (hold == 0)
					v_counter <= v_counter + 1'b1;
			end
	end
//

// sync signals
assign hs = ((h_counter >= `HFP) && (h_counter < `HSP));
assign vs = ((v_counter >= `VFP) && (v_counter < `VSP));

// blank indicator
assign video_enable = ((h_counter < `HLINES) && (v_counter < `VLINES) && (!hold));
assign blank = ~video_enable;

endmodule
