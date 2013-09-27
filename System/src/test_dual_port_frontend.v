`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:02:36 11/13/2012
// Design Name:   dualport_frontend
// Module Name:   U:/School/cs3710/System/src/test_dual_port_frontend.v
// Project Name:  System
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: dualport_frontend
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_dual_port_frontend;

	// Inputs
	reg clk;
	reg reset;
	reg [15:0] app_1_data_wr;
	reg [22:0] app_1_addr;
	reg app_1_wr;
	reg app_1_rd;
	reg app_1_burst;
	reg app_1_req_access;
	reg [15:0] app_2_data_wr;
	reg [22:0] app_2_addr;
	reg app_2_wr;
	reg app_2_rd;
	reg app_2_burst;
	reg [15:0] app_3_data_wr;
	reg [22:0] app_3_addr;
	reg app_3_wr;
	reg app_3_rd;
	reg app_3_burst;
	reg data_ok;
	reg op_finished;
	reg op_begun;

	// Outputs
	wire app_1_data_ok;
	wire app_1_op_begun;
	wire app_2_data_ok;
	wire app_2_op_finished;
	wire app_2_op_begun;
	wire app_2_stall;
	wire [15:0] app_data_out;
	wire [22:0] app_addr;
	wire app_wr;
	wire app_rd;
	wire app_burst;

	// Instantiate the Unit Under Test (UUT)
	dualport_frontend uut (
		.clk(clk), 
		.reset(reset), 
		.app_1_data_wr(app_1_data_wr), 
		.app_1_addr(app_1_addr), 
		.app_1_wr(app_1_wr), 
		.app_1_rd(app_1_rd), 
		.app_1_burst(app_1_burst), 
		.app_1_req_access(app_1_req_access), 
		.app_1_data_ok(app_1_data_ok), 
		.app_1_op_begun(app_1_op_begun), 
		.app_2_data_wr(app_2_data_wr), 
		.app_2_addr(app_2_addr), 
		.app_2_wr(app_2_wr), 
		.app_2_rd(app_2_rd), 
		.app_2_burst(app_2_burst), 
		.app_2_data_ok(app_2_data_ok), 
		.app_2_op_finished(app_2_op_finished), 
		.app_2_op_begun(app_2_op_begun), 
		.app_2_stall(app_2_stall), 
		.app_3_data_wr(app_3_data_wr), 
		.app_3_addr(app_3_addr), 
		.app_3_wr(app_3_wr), 
		.app_3_rd(app_3_rd), 
		.app_3_burst(app_3_burst), 
		.data_ok(data_ok), 
		.op_finished(op_finished), 
		.op_begun(op_begun), 
		.app_data_out(app_data_out), 
		.app_addr(app_addr), 
		.app_wr(app_wr), 
		.app_rd(app_rd), 
		.app_burst(app_burst)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		app_1_data_wr = 0;
		app_1_addr = 0;
		app_1_wr = 0;
		app_1_rd = 0;
		app_1_burst = 0;
		app_1_req_access = 0;
		app_2_data_wr = 0;
		app_2_addr = 0;
		app_2_wr = 0;
		app_2_rd = 0;
		app_2_burst = 0;
		app_3_data_wr = 0;
		app_3_addr = 0;
		app_3_wr = 0;
		app_3_rd = 0;
		app_3_burst = 0;
		data_ok = 0;
		op_finished = 0;
		op_begun = 0;

		// Wait 100 ns for global reset to finish
		#100;
		app_1_addr = 23'h555555;
      app_1_req_access = 1;
		#10;
		app_1_req_access = 0;
		op_finished = 1;
		#10;
		op_finished = 0;
		#10;
		app_2_addr = 23'h70F0F0;
		app_2_wr = 1;
		#10;
		app_2_wr = 0;
		op_finished = 1;
		#10;
		op_finished = 0;
		#10;
		app_3_addr = 23'h0F0F0F;
		app_3_wr = 1;
		#10;
		op_finished = 1;
		app_3_addr = 0;
		app_3_wr = 0;
		#10;
		op_finished = 0;
		app_2_wr = 1;
		app_2_addr = 23'h222222;
		#10;
		app_1_req_access = 1;
		app_1_addr = 23'h111111;
		#10;
		op_finished = 1;
		#10;
		op_finished = 0;
		app_2_wr = 0;
		#10;
		app_3_wr = 1;
		app_3_addr = 23'h333333;
		#10;
		app_1_req_access = 0;
		op_finished = 1;
		#10;
		op_finished = 0;
		app_2_wr = 1;
		#10;
		op_finished = 1;
		#10;
		op_finished = 0;
		app_1_req_access = 1;
		#10;
		
		// Add stimulus here
		
		
	end
   always begin
		#2;
		clk = ~clk;
	end
endmodule

