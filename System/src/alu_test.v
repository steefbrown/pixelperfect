`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:16:25 10/16/2012
// Design Name:   alu
// Module Name:   U:/cs3710/Checkpoint1/alu_test.v
// Project Name:  Checkpoint1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: alu
// 
////////////////////////////////////////////////////////////////////////////////

module alu_test;

	`include "defines.v"

	// Inputs
	reg signed [31:0] rSrc;
	reg signed [31:0] rDst;
	reg [4:0] opCode;
	reg [4:0] psrIn;

	// Outputs
	wire [4:0] psrOut;
	wire signed [31:0] result;

	// Instantiate the Unit Under Test (UUT)
	alu uut (
		.rSrc(rSrc), 
		.rDst(rDst), 
		.opCode(opCode),
		.psrOut(psrOut), 
		.result(result)
	);

	initial begin
		// Initialize Inputs
		rSrc = 0;
		rDst = 0;
		opCode = 0;
		psrIn = 0;

		// Wait 100 ns for global reset to finish
		#100;
		$display("Beginning ALU Tests...");
      
		rSrc = 2;
		rDst = 2;
		opCode = `ALUOp_ADD;
		# 20
		if (result != 4)
			$display("2 + 2 = %d", result);
		
		rSrc = 6;
		rDst = 6;
		opCode = `ALUOp_MUL;
		# 20
		if (result != 36)
			$display("6 * 6 = %d", result);
		
		rSrc = 7;
		rDst = 5;
		opCode = `ALUOp_SLL;
		# 20
		if (result != 640)
			$display("5 << 7 = %d", result);
			
		rSrc = 7;
		rDst = 40132;
		opCode = `ALUOp_SRL;
		# 20
		if (result != 313)
			$display("40132 >> 7 = %d", result);
			
		rSrc = 3;
		rDst = 20;
		opCode = `ALUOp_SRA; // requires negative immediate
		# 20
		if (result != 2)
			$display("20 >>> 3 = %d", result);
		
		//Test Code for Arthimetic Shift
		rSrc = 7;
		rDst = -20132;
		opCode = `ALUOp_SRA;
		# 20
		if (result != -158)
			$display("-20132 >>> 7 = %d", result);
	end
       
endmodule

