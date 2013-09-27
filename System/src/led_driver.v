`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Create Date:    17:32:18 09/15/2012
//
//	Description:	 Displays pre-formatted 7-segment LED arrays on the Nexys3.
//						 Takes 4 8-bit input buses, where in0 maps to AN[0], and so on.
//
//////////////////////////////////////////////////////////////////////////////////
module led_driver(
    input clk,					// 100MHz
	 input reset,
    input [7:0] in0, in1, in2, in3,
    output reg [3:0] AN,	// Denotes which segment is active (1-hot encoded)
    output reg [6:0] C,		// Signals to which LEDs are active (G:A)
    output reg DP				// Decimal point
    );

	// We must cycle over each of the 4 7-segment LEDs at a rate
	// between 1kHz and 60Hz, refreshing the current segment.
	reg [15:0] count;

	always @(posedge clk or posedge reset)
		if (reset) begin
			// Reset count, draw "- - - -"
			count = 0;
			AN = 4'b0;
			C = 7'b0111111;
			DP = 1'b1;
		end else begin
			count = count + 1'b1;
			case (count[15:14])
				3:			begin AN = 4'b1110; {DP,C} = ~in3; end	// active low
				2:			begin AN = 4'b1101; {DP,C} = ~in2; end
				1:			begin AN = 4'b1011; {DP,C} = ~in1; end
				default: begin AN = 4'b0111; {DP,C} = ~in0; end
			endcase
		end

endmodule
