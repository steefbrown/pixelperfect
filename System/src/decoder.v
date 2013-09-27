`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Create Date:    15:57:39 09/15/2012 
//
//	Description:	 Decodes a binary-encoded-decimal number on led input into
//						 4 led segments: thousands, hundreds, tens, and ones.
//
//////////////////////////////////////////////////////////////////////////////////
module decoder(
    input clk,
    input [15:0] val,	  // binary-encoded-decimal value
	 output [7:0] seg0, // left most segment
    output [7:0] seg1, // 
    output [7:0] seg2, // 
    output [7:0] seg3  // right most segment
    );
	 
	 decToSeg a (val[15:12], seg0);
	 decToSeg b (val[11:8], seg1);
	 decToSeg c (val[7:4], seg2);
	 decToSeg d (val[3:0], seg3);
	 
endmodule

// module to convert single binary-encoded-digit to the 7-segment led
module decToSeg(
	input [3:0] in,
	output reg [7:0] seg
	);
	
	always @(*)
		case (in)
			4'h0  : seg = 8'b00111111; // 0 (seg[7] is decimal point)
			4'h1  : seg = 8'b00000110; // 1
			4'h2  : seg = 8'b01011011; // ...
			4'h3  : seg = 8'b01001111; 
			4'h4  : seg = 8'b01100110; 
			4'h5  : seg = 8'b01101101; 
			4'h6  : seg = 8'b01111101; 
			4'h7  : seg = 8'b00000111; 
			4'h8  : seg = 8'b01111111; 
			4'h9  : seg = 8'b01101111; 
			4'hA  : seg = 8'b01110111; 
			4'hB  : seg = 8'b01111100; 
			4'hC  : seg = 8'b00111001; 
			4'hD  : seg = 8'b01011110; 
			4'hE  : seg = 8'b01111001; 
			4'hF  : seg = 8'b01110001; 
			default : seg = 8'b0;
		endcase
	
endmodule


