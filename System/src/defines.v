//
// This file defines all our constants used throughout
// the processor's hardware modules.
//


//////////////////////////
// Conditional Types
`define EQ 4'b0000 // equal
`define CS 4'b0001 // carry set
`define HI 4'b0010 // higher than (unsigned)
`define GT 4'b0011 // greater than (signed)
`define FS 4'b0100 // overflow
`define HS 4'b0101 // higher than or same as (unsigned)
`define GE 4'b0110 // greater than or equal (signed)

`define NE 4'b1000 // not equal
`define CC 4'b1001 // carry clear
`define LS 4'b1010 // lower than or same as (unsigned)
`define LE 4'b1011 // less than or equal (signed)
`define FC 4'b1100 // no overflow
`define LO 4'b1101 // lower than (unsigned)
`define LT 4'b1110 // less than (signed)

`define UC 4'b0111 // branch unconditionally

`define CondType_Ig 4'b1111

//////////////////////////
// Conditional Op codes
`define CondOp_JAL 	2'b01
`define CondOp_BJ	2'b10
`define CondOp_Ig 	2'b00

//////////////////////////
// PSR indexes
`define psrN 4
`define psrZ 3
`define psrF 2
`define psrL 1
`define psrC 0

//////////////////////////
// Op codes (bits 15-12)
`define ADDI 	4'b0101
`define ADDUI 	4'b0110
`define MULI 	4'b1110
`define SUBI 	4'b1001
`define CMPI 	4'b1011
`define ANDI 	4'b0001
`define ORI 	4'b0010
`define XORI 	4'b0011
`define MOVI 	4'b1101
`define LUI 	4'b1111
`define BCOND 	4'b1100
`define RTYPE	4'b0000
`define STYPE	4'b1000
`define OTYPE	4'b0100

//////////////////////////
// Ext Op codes (bits 7-4)
// top op code is 4'b0000 == RTYPE
	`define ADD 	4'b0101
	`define ADDU 	4'b0110
	`define MUL 	4'b1110
	`define SUB 	4'b1001
	`define CMP 	4'b1011
	`define AND 	4'b0001
	`define OR 		4'b0010
	`define XOR 	4'b0011
	`define MOV 	4'b1101
// top op code is 4'b1000 == ShiftTYPE
	`define SLL 	4'b0001
	`define SLLI 	4'b1001
	`define SRL 	4'b0010
	`define SRLI 	4'b1010
	`define SRA		4'b0011
	`define SRAI	4'b1011
// top op code is 4'b0100 == OtherType
	`define LOAD 	4'b0000
	`define STOR 	4'b0100
	`define SCOND 	4'b1101
	`define JCOND 	4'b1100
	`define JAL 	4'b1000

//////////////////////////
// ALO Op codes
`define ALUOp_ADD	5'b00101
`define ALUOp_ADDU	5'b00110
`define ALUOp_SUB	5'b01001
`define ALUOp_MUL	5'b01110
`define ALUOp_AND	5'b00001
`define ALUOp_OR	5'b00010
`define ALUOp_XOR	5'b00011
`define ALUOp_MOV	5'b01101
`define ALUOp_LUI	5'b01111
`define ALUOp_SLL	5'b10100
`define ALUOp_SRL	5'b10001
`define ALUOp_SRA	5'b10011



//////////////////////////
// Datapath configurations {regWrite, memWrite, memRead, muxA, muxB, muxWB}
`define DP_ITYPE	7'b1_0_0_0_1_11
`define DP_BCOND	7'b0_0_0_1_1_11
`define DP_RTYPE	7'b1_0_0_0_0_11
`define DP_CMP		7'b0_0_0_0_0_11
`define DP_CMPI		7'b0_0_0_0_1_11
`define DP_LOAD		7'b1_0_1_0_0_10
`define DP_STOR		7'b0_1_0_0_0_10
`define DP_SCOND	7'b1_0_0_0_0_01
`define DP_JCOND	7'b0_0_0_0_0_01
`define DP_JAL		7'b1_0_0_0_0_00


// VGA 800x600 60Hz
// h* is in clocks
// `define hdisplay 	800
// `define hfrontporch 840		// +40
// `define hpulse		968		// +128
// `define hbackporch 	1056	// +88
`define hdisplay 	640
`define hfrontporch 656		// +16
`define hpulse		752		// +96
`define hbackporch 	800 	// +48
// v* is in lines (relative to h)
// `define vdisplay 	600
// `define vfrontporch 601		// +1
// `define vpulse 		605		// +4
// `define vbackporch 	628		// +23
`define vdisplay 	480
`define vfrontporch 490		// +10
`define vpulse 		492		// +2
`define vbackporch 	525		// +33

// VGA timing generator
`define HLINES 	640
`define VLINES 	480
`define HMAX 	800
`define VMAX 	525
`define HFP 	656
`define HSP 	752
`define VFP 	490
`define VSP 	492

// `define HLINES 800
// `define VLINES 600
// `define HMAX 1056
// `define VMAX 628
// `define HFP 840
// `define HSP 968
// `define VFP 601
// `define VSP 605

// PSRAM configuration word
`define psram_config_word 23'b000_10_00_0_1_011_1_0_0_0_0_01_1_111

// FSM state codes (not forcing)
`define init_state 0

`define conf_1_state 1
`define conf_2_state 2
`define conf_3_state 3
`define conf_4_state 4
`define conf_5_state 5
`define conf_6_state 6
`define conf_7_state 7

`define idle_state 8

`define wr_0_state 9
`define wr_1_state 10
`define wr_2_state 11
`define wr_3_state 12
`define wr_4_state 13
`define wr_5_state 14
`define wr_6_state 15
`define wr_7_state 16
`define wr_8_state 17
`define wr_9_state 18
`define wr_10_state 19

`define rd_0_state 20
`define rd_1_state 21
`define rd_2_state 22
`define rd_3_state 23
`define rd_4_state 24
`define rd_5_state 25
`define rd_6_state 26
`define rd_7_state 27
`define rd_8_state 28
`define rd_9_state 29
`define rd_10_state 30






