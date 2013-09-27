
//
// This module handles latching the PSR flags from the ALU and
// satisfying any conditional instructions. Since Bcond and Jcond
// involve the program counter, this module also controls the next pc.
//
module conditional
	(input              clk,
	 input				clr,
	 input 				pulse_en,
	 input  [31:0]		pcPlus1,	// current pc plus 1 for next inst.
	 input  [1:0]		opCode,		// specifies Ignore, Bcond/Jcond, or JAL
	 input  [3:0]		condType,	// selected conditional flag
	 input  [4:0]       psrCont, 	// specifies which psr flags should be latched
	 input  [4:0]       psr, 		// psr data from alu, waiting to be latched
	 input  [31:0]   	branchAddr,// the address for the next Jump/Branch
	 output [31:0]   	scond,     // store coditional as boolean into reg
	 output reg [31:0] 	pcOut);		// new program counter value

	`include "defines.v"

	wire condVal;
	reg  condTemp;
	reg [4:0] psrlatch; 	// currently latched psr data

	// psr = {N, Z, F, L, C}
	// only latch the new psr flag if specified by psrCont
	always @(posedge clk)
		if (clr)
			psrlatch <= 5'b0;
		else if (pulse_en) begin
			psrlatch[`psrN] <= psrCont[`psrN] ? psr[`psrN] : psrlatch[`psrN];
			psrlatch[`psrZ] <= psrCont[`psrZ] ? psr[`psrZ] : psrlatch[`psrZ];
			psrlatch[`psrF] <= psrCont[`psrF] ? psr[`psrF] : psrlatch[`psrF];
			psrlatch[`psrL] <= psrCont[`psrL] ? psr[`psrL] : psrlatch[`psrL];
			psrlatch[`psrC] <= psrCont[`psrC] ? psr[`psrC] : psrlatch[`psrC];
		end

	// determine if the conditional is set in PSR
	always@(*)
		case(condType[2:0])
			`EQ: condTemp <= psrlatch[`psrZ];
			`CS: condTemp <= psrlatch[`psrC];
			`HI: condTemp <= psrlatch[`psrL];
			`GT: condTemp <= psrlatch[`psrN];
			`FS: condTemp <= psrlatch[`psrF];
			`HS: condTemp <= psrlatch[`psrZ] | psrlatch[`psrL];
			`GE: condTemp <= psrlatch[`psrZ] | psrlatch[`psrN];
			`UC: condTemp <= 1'b1;
			default condTemp <= 1'b0;
		endcase

	// condVal should be high if the condType is satisfied by current psrlatch
	assign condVal = condType[3] ^ condTemp;

	// the register boolean value with padded zeros
	assign scond = {31'b0, condVal};

	// decide what the next pc value will be
	always @(*)
	begin
		if (opCode == `CondOp_JAL)
			pcOut <= branchAddr;
		else if (condVal && (opCode == `CondOp_BJ))
			pcOut <= branchAddr; // Bcond or Jcond instruction, assign PC to branchAddr
		else
			pcOut <= pcPlus1;	 // Do not branch, go to next PC value
	end

endmodule
