`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:14:17 11/10/2012
// Design Name:   video_pipeline
// Module Name:   Z:/Documents/College/2012-2013/CS3710/System/test_video_pipeline.v
// Project Name:  System
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: video_pipeline
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_video_pipeline;

	// Inputs
	reg clk;
	reg pixel_clk;
	reg reset;
	reg [15:0] data;
	reg op_begun;
	reg data_ok;
	reg ctrlr_good;

	// Outputs
	wire req_access;
	wire rd;
	wire burst;
	wire [22:0] addr;
	wire hs;
	wire vs;
	wire [7:0] rgb;

	// Instantiate the Unit Under Test (UUT)
	video_pipeline uut (
		.clk(clk), 
		.pixel_clk(pixel_clk), 
		.reset(reset), 
		.data(data), 
		.op_begun(op_begun), 
		.op_finished(1'b1),
		.data_ok(data_ok), 
		.ctrlr_good(ctrlr_good), 
		.req_access(req_access), 
		.rd(rd), 
		.burst(burst), 
		.addr(addr), 
		.hs(hs), 
		.vs(vs), 
		.rgb(rgb)
	);
	
	always
	begin
		#5 clk = !clk;
		#5 clk = !clk;
		#5 clk = !clk;
		#5 clk = !clk;
		pixel_clk = !pixel_clk;
	end

	initial begin
		// Initialize Inputs
		clk = 0;
		pixel_clk = 0; 
		reset = 0;
		data = 0;
		op_begun = 1;
		data_ok = 1;
		ctrlr_good = 1;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

