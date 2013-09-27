`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   01:06:34 11/29/2012
// Design Name:   system
// Module Name:   Z:/shared/Documents/College/2012-2013/CS3710/System/test_uart_app.v
// Project Name:  System
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: system
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_uart_app;

	// Inputs
	reg osc_clk;
	reg clr;
	reg RxD;

	// Outputs
	wire TxD;

	// Bidirs
	wire [15:0] mem_data;

	// Instantiate the Unit Under Test (UUT)
	system uut (
		.osc_clk(osc_clk), 
		.clr(clr), 
		.RxD(RxD), 
		.TxD(TxD)
	);
	
	always
		#5 osc_clk = !osc_clk;

	initial begin
		// Initialize Inputs
		osc_clk = 0;
		clr = 1;
		RxD = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		clr = 0;
	end
      
endmodule

