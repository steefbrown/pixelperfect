`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 		 Trevor Hill && Kevin Avery
//
// Create Date:    09/21/2012
// Module Name:    vga_controller
// Description:	 Generates VGA signals
//////////////////////////////////////////////////////////////////////////////////
module vga_controller(
	 input clk,
	 input reset,
	 input hold,		// pause drawing
    output reg hs,	// H-Sync signal
    output reg vs,	// V-Sync signal
	 output blank		// high if not drawing
   );

	`include "defines.v"

	reg [11:0] hscount;
	reg [10:0] vscount;
	reg display;

	always @(posedge clk or posedge reset)
		if (reset) begin
			hscount <= 0;
			vscount <= 0;
		end else if (!hold) begin
			display <= 1'b0;

			// increment hscount every clock
			hscount <= hscount + 1'b1;
			hs <= 1'b1;

			if (hscount < `hdisplay)
				display <= vscount < `vdisplay; // if both hscount and vscount in display
			else if (hscount >= `hfrontporch && hscount < `hpulse)
				hs <= 1'b0;
			else if (hscount >= `hbackporch) begin
				// reached the end of the line, reset hscount
				hscount <= 0;
				// increment vscount every line
				vscount <= vscount + 1'b1;
				vs <= 1'b1;

				if (vscount >= `vfrontporch && vscount < `vpulse)
					vs <= 1'b0;
				else if (vscount >= `vbackporch)
					vscount <= 0; // reached the end of the frame
			end
		end

	// blank is high if we're not in the display range or if we're holding
	assign blank = !display || hold;

endmodule
