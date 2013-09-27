`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date:    15:21:20 11/13/2012 
//////////////////////////////////////////////////////////////////////////////////
module array(
	 input clk,
	 input wr_en,
	 input [7:0] index,
	 input [15:0] wr_val,
	 output reg [15:0] rd_val
    );

   reg [15:0] mem_block [255:0];
	
	always @(posedge clk)
		if (wr_en) begin
			mem_block[index] <= wr_val;
		end
		else begin
			rd_val <= mem_block[index];
		end
						
endmodule

