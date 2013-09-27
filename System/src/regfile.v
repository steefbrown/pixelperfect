
//
// Provides 16 32-bit registers
//
module regfile
	 (input  			clk,
	  input 			pulse_en,
	  input  [31:0]		pc,				// program counter
	  input           	write, 			// signal to write ddest to rdest
	  input  [3:0] 		rsrc, rdest, 	// src and dest register locations
	  input  [31:0]   	write_data, 	// write back data
	  output [31:0]   	dsrc, ddest);	// src and dest register data

	reg  [31:0] mem_block [15:0];

	// no use in clearing the registers
	always @(posedge clk)
      if (pulse_en && write) mem_block[rdest] <= write_data;

	// pc is read only at register address 15
	assign dsrc = &rsrc ? pc : mem_block[rsrc];
	assign ddest = &rdest ? pc : mem_block[rdest];

endmodule
