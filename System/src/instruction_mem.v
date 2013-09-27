`timescale 1ns / 1ps
//
// Fetches the instruction at pcNext. Will not advance to pcNext
// if stall is high.
//
module instruction_mem
	(input clk,
	 input clr,
	 input pulse_en,
	 input stall,
	 input [31:0] pcNext,
	 output reg [31:0] pc,
     output reg [31:0] inst
    );

   	reg [31:0] mem_block [8191:0]; // 8KB

   	// initialize the memory to the app.dat file in the Application directory
	initial $readmemh("../Application/app.dat", mem_block);

	always @(posedge clk or posedge clr)
		if (clr) begin
			// start at instruction number -1 (DNE)
			inst <= 32'bx;
			pc <= 32'hFFFFFFFF;
		end
		else if(pulse_en && !stall) begin
			inst <= mem_block[pcNext];
			pc <= pcNext;
		end

endmodule
