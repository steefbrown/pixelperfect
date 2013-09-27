`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:47:40 10/18/2012 
// Design Name: 
// Module Name:    data_mem 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module data_mem #(parameter WIDTH = 16)
   (input clk,
	 input write_en,
    input [WIDTH-1:0] write_data,
    input [WIDTH-1:0] addr,
    output [WIDTH-1:0] read_data
    );
	 
//	reg [WIDTH-1:0] mem_block [255:0];
//	
//	//initial $readmemh("fib.dat", mips_ram);
//
//   always @(posedge clk)
//      if (write_en) 
//			mem_block[addr] <= write_data;
//		
//	assign read_data = mem_block[addr];


endmodule

