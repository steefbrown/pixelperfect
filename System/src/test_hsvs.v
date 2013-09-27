`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:00:13 11/08/2012
// Design Name:   vga_800x600
// Module Name:   Z:/Documents/College/2012-2013/CS3710/System/test_hsvs.v
// Project Name:  System
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: vga_800x600
// 
////////////////////////////////////////////////////////////////////////////////

module test_hsvs;

	// Inputs
	reg clk;
	reg reset;
	reg hold;

	// Outputs
	wire hs;
	wire vs;
	wire blank;

	// Instantiate the Unit Under Test (UUT)
	vga_800x600 uut (
		.clk(clk), 
		.reset(reset), 
		.hold(hold), 
		.hs(hs), 
		.vs(vs), 
		.blank(blank)
	);
	
	always
		#5 clk = !clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		hold = 0;

		// Wait 100 ns for global reset to finish
		#100;
	end
      
endmodule

