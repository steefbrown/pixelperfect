`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:28:41 11/06/2012
// Design Name:   processor
// Module Name:   Z:/Documents/College/2012-2013/CS3710/System/test_paint_vert_stripes.v
// Project Name:  System
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: processor
// 
////////////////////////////////////////////////////////////////////////////////

module test_paint_vert_stripes;

	// Inputs
	reg clk;
	reg clr;
	reg stall;
	reg [15:0] mem_read_data;
	
	reg [15:0] values [799:0];
	integer i = 0;
	integer j = 0;

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
		.mem_read_data(mem_read_data), 
		.mem_read_enable(mem_read_enable), 
		.mem_write_enable(mem_write_enable), 
		.mem_write_data(mem_write_data), 
		.mem_write_addr(mem_write_addr)
	);

	always
		#5 clk = !clk;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		clr = 1;
		stall = 0;
		mem_read_data = 0;
		
		#20;
		clr = 0;
		$display("Starting test");

		#100000 // Wait for a col to be populated
		for (i=0; i < 400; i = i + 8)
			for (j=0; j < 8; j = j+1)
				$display("Color %d: %x", i+j, values[i+j]);
//				if (j < 4 && values[i+j] != 16'h8080)
//					$display("error red");
//				else if (j > 4 && values[i+j] != 16'b1010)
//					$display("error green");

		$display("Done!");
	end
	
	always @(posedge clk) begin

		if (mem_write_enable && i < 400) begin
			values[i] = mem_write_data;
			i = i + 1;
		end
	end
      
endmodule

