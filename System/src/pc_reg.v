`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:56:45 10/16/2012 
// Design Name: 
// Module Name:    pc_reg 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////
module pc_reg(
	input 			  clk,
	input 			  clr,
	input 	   [15:0] pc_next, 
	output reg [15:0] pc
    );

always @(posedge clk or posedge clr)
begin
	if(clr)
		pc <= 0;
	else
		pc <= pc_next;
end

endmodule
