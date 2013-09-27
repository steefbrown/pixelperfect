`timescale 1ns / 1ps
//
// For way mux, can't argue with that.
//
module mux_4(
    input [31:0] a, b, c, d,
	input [1:0]  sel,
	output reg [31:0] out
);

always @(*)
	case(sel)
		2'b00: out <= a;
		2'b01: out <= b;
		2'b10: out <= c;
		2'b11: out <= d;
	endcase


endmodule
