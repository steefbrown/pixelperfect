`timescale 1ns / 1ps
//
// The most important piece of hardware: increment's the program counter by 1.
//
module pc_incr(
	input  [31:0] pc,
	output [31:0] out
   );

assign out = pc + 1;

endmodule
