`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// This module wraps up the work needed to draw val onto the 7-seg LEDs in
// in Hex when write_en goes high. When write_en is low, the previous value
// remains drawn. Initial value is "BEEF" on LEDs.
//
//////////////////////////////////////////////////////////////////////////////////
module led_hex(
    input clk,
	 input clr,
	 input write_en,
	 input [15:0] val,
	 output [3:0] AN,
    output [6:0] C,
    output DP
    );

reg  [15:0] disp_data_reg;
wire [7:0] seg0, seg1, seg2, seg3;

// latch val when write goes high
always @(posedge clk or posedge clr)
	if (clr)
		disp_data_reg <= 16'hBEEF;
	else if (write_en)
		disp_data_reg <= val;

decoder	decoder_inst
(
	// inputs
   .clk		(clk),
   .val		(disp_data_reg),
	// outputs
	.seg0	(seg0),
   .seg1	(seg1),
   .seg2	(seg2),
   .seg3	(seg3)
);


led_driver	led_driver_inst
(
	// inputs
   .clk		(clk),
	.reset	(clr),
   .in0		(seg0),
	.in1		(seg1),
	.in2		(seg2),
	.in3		(seg3),
	// outputs
   .AN		(AN),
   .C			(C),
   .DP		(DP)
 );

endmodule
