`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:27:51 11/29/2012
// Design Name:   processor
// Module Name:   Z:/shared/Documents/College/2012-2013/CS3710/System/src/test_processor.v
// Project Name:  System
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: processor
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_processor;

	// Inputs
	reg clk;
	reg clr;
	reg stall;
	reg pulse_en;
	reg [15:0] mem_read_data;

	// Outputs
	wire mem_read_enable;
	wire mem_write_enable;
	wire [15:0] mem_write_data;
	wire [31:0] mem_write_addr;

	// Instantiate the Unit Under Test (UUT)
	processor uut (
		.clk(clk), 
		.clr(clr), 
		.stall(stall), 
		.pulse_en(pulse_en),
		.mem_read_data(mem_read_data), 
		.mem_read_enable(mem_read_enable), 
		.mem_write_enable(mem_write_enable), 
		.mem_write_data(mem_write_data), 
		.mem_write_addr(mem_write_addr)
	);
	
	always
		#5 clk = ~clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		clr = 1;
		pulse_en = 1;
		stall = 0;
		mem_read_data = 16'hBEEF;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		clr = 0;

	end
      
endmodule

