`timescale 1ns / 1ps
//
// Sign extends a 24-bit immediate to 32-bits
//
module sign_ext(
	input  [23:0]  imm,
	output [31:0] immExt
);

	assign immExt = {{8{imm[23]}}, imm};

endmodule
