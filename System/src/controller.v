
//
// Sets the datapath controls based on instruction
//
module controller(
	input 		[31:0] 	inst,
	output reg 			regWrite,
	output reg 			memRead,
	output reg 			memWrite,
	output reg 			muxA,
	output reg 			muxB,
	output reg [1:0] 	muxWB,
	output reg [4:0] 	aluOp,
	output reg [1:0]	psrOp,
	output reg [3:0] 	condType,
	output reg [4:0] 	psrCont
);

	`include "defines.v"

	wire [3:0] opCode		= inst[31:28];
	wire [3:0] rDst 		= inst[27:24];
	wire [3:0] opCodeExt 	= inst[23:20];
	wire [3:0] rSrc 		= inst[19:16];

	reg [22:0] datapath;

	always @(datapath)
		{regWrite, memWrite, memRead, muxA, muxB, muxWB, aluOp, psrOp, psrCont, condType} <= datapath;

	always @(*)
		case(opCode)
		 `ADDI  : datapath <= {`DP_ITYPE, `ALUOp_ADD, `CondOp_Ig, 5'b00101, `CondType_Ig};
		 `ADDUI : datapath <= {`DP_ITYPE, `ALUOp_ADDU,`CondOp_Ig, 5'b00000, `CondType_Ig};
         `MULI  : datapath <= {`DP_ITYPE, `ALUOp_MUL, `CondOp_Ig, 5'b00000, `CondType_Ig};
         `SUBI  : datapath <= {`DP_ITYPE, `ALUOp_SUB, `CondOp_Ig, 5'b00101, `CondType_Ig};
         `CMPI  : datapath <= {`DP_CMPI,  `ALUOp_SUB, `CondOp_Ig, 5'b11010, `CondType_Ig};
         `ANDI  : datapath <= {`DP_ITYPE, `ALUOp_AND, `CondOp_Ig, 5'b00000, `CondType_Ig};
         `ORI   : datapath <= {`DP_ITYPE, `ALUOp_OR,  `CondOp_Ig, 5'b00000, `CondType_Ig};
         `XORI  : datapath <= {`DP_ITYPE, `ALUOp_XOR, `CondOp_Ig, 5'b00000, `CondType_Ig};
         `MOVI  : datapath <= {`DP_ITYPE, `ALUOp_MOV, `CondOp_Ig, 5'b00000, `CondType_Ig};
         `LUI   : datapath <= {`DP_ITYPE, `ALUOp_LUI, `CondOp_Ig, 5'b00000, `CondType_Ig};
         `BCOND : datapath <= {`DP_BCOND, `ALUOp_ADD, `CondOp_BJ, 5'b00000, rDst};
         `RTYPE : begin
						case(opCodeExt)
							`ADD   : datapath <= {`DP_RTYPE, `ALUOp_ADD, `CondOp_Ig, 5'b00101, `CondType_Ig};
							`ADDU  : datapath <= {`DP_RTYPE, `ALUOp_ADDU,`CondOp_Ig, 5'b00000, `CondType_Ig};
							`MUL   : datapath <= {`DP_RTYPE, `ALUOp_MUL, `CondOp_Ig, 5'b00000, `CondType_Ig};
							`SUB   : datapath <= {`DP_RTYPE, `ALUOp_SUB, `CondOp_Ig, 5'b00101, `CondType_Ig};
							`CMP   : datapath <= {`DP_CMP,   `ALUOp_SUB, `CondOp_Ig, 5'b11010, `CondType_Ig};
							`AND   : datapath <= {`DP_RTYPE, `ALUOp_AND, `CondOp_Ig, 5'b00000, `CondType_Ig};
							`OR    : datapath <= {`DP_RTYPE, `ALUOp_OR,  `CondOp_Ig, 5'b00000, `CondType_Ig};
							`XOR   : datapath <= {`DP_RTYPE, `ALUOp_XOR, `CondOp_Ig, 5'b00000, `CondType_Ig};
							`MOV   : datapath <= {`DP_RTYPE, `ALUOp_MOV, `CondOp_Ig, 5'b00000, `CondType_Ig};
							default: datapath <= 0;
						endcase
					   end
         `STYPE : begin
						case(opCodeExt)
							`SLL   : datapath <= {`DP_RTYPE, `ALUOp_SLL, `CondOp_Ig, 5'b00000, `CondType_Ig};
							`SLLI  : datapath <= {`DP_ITYPE, `ALUOp_SLL, `CondOp_Ig, 5'b00000, `CondType_Ig};
							`SRL   : datapath <= {`DP_RTYPE, `ALUOp_SRL, `CondOp_Ig, 5'b00000, `CondType_Ig};
							`SRLI  : datapath <= {`DP_ITYPE, `ALUOp_SRL, `CondOp_Ig, 5'b00000, `CondType_Ig};
							`SRA   : datapath <= {`DP_RTYPE, `ALUOp_SRA, `CondOp_Ig, 5'b00000, `CondType_Ig};
							`SRAI  : datapath <= {`DP_ITYPE, `ALUOp_SRA, `CondOp_Ig, 5'b00000, `CondType_Ig};
							default: datapath <= 0;
						endcase
					   end
         `OTYPE : begin
						case(opCodeExt)
							`LOAD  : datapath <= {`DP_LOAD,  `ALUOp_MOV, `CondOp_Ig, 5'b00000, `CondType_Ig};
							`STOR  : datapath <= {`DP_STOR,  `ALUOp_MOV, `CondOp_Ig, 5'b00000, `CondType_Ig};
							`SCOND : datapath <= {`DP_SCOND, `ALUOp_MOV, `CondOp_Ig, 5'b00000, rSrc};
							`JCOND : datapath <= {`DP_JCOND, `ALUOp_MOV, `CondOp_BJ, 5'b00000, rDst};
							`JAL   : datapath <= {`DP_JAL,   `ALUOp_MOV, `CondOp_JAL,5'b00000, `CondType_Ig};
							default: datapath <= 0;
						endcase
					   end
			default: datapath <= 0;
		endcase
endmodule

