`timescale 1ns / 1ps
//
// This is just what it looks like.
//
module mux_2(
	input [31:0] a, b,
	input sel,
	output [31:0] out
);

	assign out = sel ? b : a;

endmodule
