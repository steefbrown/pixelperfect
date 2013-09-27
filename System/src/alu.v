

//
// 32-bit Arithmetic Logic Unit
// Assigns all PSR flags on every operation (it's up to the next guy to latch the desired flags).
//
module alu
	(input	 		[31:0] rSrc, rDst,
	 input  		[4:0]  opCode,
	 output 		[4:0]  psrOut,
	 output signed	[31:0] result
	);

	`include "defines.v"

	reg [32:0] temp;

	wire signed [31:0] srcSigned = rSrc; // also acts as immediate
	wire signed [31:0] dstSigned = rDst;

	assign psrOut[`psrZ] = rSrc == rDst;
	assign psrOut[`psrL] = rDst < rSrc;
	assign psrOut[`psrN] = dstSigned < srcSigned;
	assign psrOut[`psrF] = (srcSigned < 0 && dstSigned < 0 && result > 0) || (srcSigned > 0 && dstSigned > 0 && result < 0);
	assign psrOut[`psrC] = temp[32];
	assign result = temp[31:0];


	always @(*)
		case(opCode)
			`ALUOp_ADD: 	temp <= dstSigned + srcSigned;
			`ALUOp_ADDU: 	temp <= rDst + rSrc;
			`ALUOp_SUB:		temp <= dstSigned - srcSigned;
			`ALUOp_MUL: 	temp <= rDst[7:0] * rSrc[7:0];
			`ALUOp_AND: 	temp <= rSrc & rDst;
			`ALUOp_OR: 		temp <= rSrc | rDst;
			`ALUOp_XOR: 	temp <= rSrc ^ rDst;
			`ALUOp_SLL:		temp <= rDst << rSrc[15:0];
			`ALUOp_SRL:		temp <= rDst >> rSrc[15:0];
			`ALUOp_SRA:		temp <= dstSigned >>> rSrc;
			`ALUOp_LUI:		temp <= {rSrc[15:0], rDst[15:0]};
			`ALUOp_MOV:		temp <= rSrc;
			 default:		temp <= 0;
		  endcase

endmodule

