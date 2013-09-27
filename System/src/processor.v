`timescale 1ns / 1ps
//
// Wires all of the processor's internal modules together.
// Contains basically no logic asside from instantiations.
//
// Create Date:    15:37:27 10/16/2012
//
module processor (
	input  clk, // 100MHz
	input  clr,
	input  pulse_en,
	input  stall,
	input  [15:0] mem_read_data,
	output 		  mem_read_enable,
	output		  mem_write_enable,
	output [15:0] mem_write_data,
	output [31:0] mem_write_addr
);

// PC reg wires
wire [31:0] pc, pcNext, pcPlus1;

// Instruction memory wires
wire [31:0] inst;

// Reg file wires
wire [3:0] 		reg_a 	= 	inst[27:24];  // dst
wire [3:0] 		reg_b 	= 	inst[19:16];  // src
wire [23:0] 	imm   	= 	inst[23:0];

// Control Wires
wire 			control_regWrite;
wire 			control_memWrite;
wire			control_muxA_sel;
wire 			control_muxB_sel;
wire [1:0]		control_muxWB_sel;
wire [4:0]		control_aluOp;
wire [1:0]		control_psrOp;
wire [3:0]		control_condType;
wire [4:0]		control_psrCont;

wire [31:0] reg_aData, reg_bData, immExt;
wire [31:0] alu_aData, alu_bData, alu_result;
wire [4:0]	alu_psrOut, cond_psrOut;

// PSR Wires
wire [31:0] cond_scond;
wire [31:0] writeback_data;

assign mem_write_data = reg_aData[15:0];
assign mem_write_addr = alu_result;

///////////////////////////
// Inst Memory Module
instruction_mem  instruction_mem_inst
(
	// inputs
	.clk		(clk),
	.clr 		(clr),
	.pulse_en 	(pulse_en),
	.pcNext		(pcNext),
	.stall 		(stall),
	//outputs
	.inst		(inst),
	.pc			(pc)
);

///////////////////////////
// Controller Module
controller  controller_inst
(
	// inputs
	.inst 		(inst),
	// outputs
	.regWrite 	(control_regWrite),
	.memWrite	(mem_write_enable),
	.memRead 	(mem_read_enable),
	.muxA		(control_muxA_sel),
	.muxB		(control_muxB_sel),
	.muxWB		(control_muxWB_sel),
	.aluOp		(control_aluOp),
	.psrOp		(control_psrOp),
	.condType	(control_condType),
	.psrCont	(control_psrCont)
);

///////////////////////////
// Reg File Module
regfile regfile_inst
(
	// inputs
	.clk		(clk),
	.pulse_en 	(pulse_en),
	.pc			(pc),
	.rsrc		(reg_b),
	.rdest		(reg_a),
	.write		(control_regWrite),
	.write_data (writeback_data),
	//outputs
	.dsrc		(reg_bData),
	.ddest		(reg_aData)

);

///////////////////////////
// Sign Extend Module
sign_ext  sign_ext_inst
(
	// inputs
	.imm		(imm),
	//outputs
	.immExt	(immExt)
);

///////////////////////////
// Mux_2 A Module
mux_2  mux_A_inst
(
	// inputs
	.a  	(reg_aData),
	.b		(pc),
	.sel	(control_muxA_sel),
	//outputs
	.out	(alu_aData)
);

///////////////////////////
// Mux_2 B Module
mux_2  mux_B_inst
(
	// inputs
	.a  	(reg_bData),
	.b		(immExt),
	.sel	(control_muxB_sel),
	//outputs
	.out	(alu_bData)
);


///////////////////////////
// ALU Module
alu alu_inst
(
	// inputs
	.rSrc	(alu_bData),
	.rDst	(alu_aData),
	.opCode	(control_aluOp),
	// outputs
	.psrOut	(alu_psrOut),
	.result	(alu_result)
);

///////////////////////////
// PC Increment Module
pc_incr  pc_incr_inst
(
	// inputs
	.pc	(pc),
	//outputs
	.out	(pcPlus1)
);

///////////////////////////
// Conditional (PSR) Module
conditional  conditional_inst
(
	// inputs
	.clk		(clk),
	.pulse_en 	(pulse_en),
	.clr		(clr),
	.pcPlus1	(pcPlus1),
	.opCode		(control_psrOp),
	.condType	(control_condType),
	.psrCont 	(control_psrCont),
	.psr		(alu_psrOut),
	.branchAddr	(alu_result),
	//outputs
	.scond	   	(cond_scond),
	.pcOut		(pcNext)
);

///////////////////////////
// Writeback mux
mux_4	mux_WB_inst
(
	// inputs
	.a		(pc),
	.b		(cond_scond),
	.c		({16'b0, mem_read_data}),
	.d		(alu_result),
	.sel	(control_muxWB_sel),
	// outputs
	.out	(writeback_data)
);


endmodule










