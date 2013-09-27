///////////////////////////////////////////////////////////////////////////////
// Company:			Tallinn University of Technology, Dept. of Comp. Eng.
// Engineer:		vadsonen
// 
// Create Date:		15:54:22 2012/02/16
// Design Name:		Digilent Nexys-3 Micron CellularRAM controller
// Module Name:		psram_ctrlr
// Target Devices:	Spartan-6 FPGA
// Tool versions:	Xilinx ISE 12.3
// Language:		Verilog 2001
// Description:		This is a simple CellularRAM memory controller. It provides
//					a simple interface for synchronous single and burst reads 
// 					and writes with a fixed latency access.
//					Operating conditions:
//						- 100MHz controller clock
//						- 50MHz memory clock
//						- Fixed access latency for both read and write
//						- Continuous burst length (up to 128 words)
//
// Revision: 		0.01 - 2012.02.16 - File Created
// 					1.0 - 2012.03.02 - V1.0
// 
// Comments:		- In source code 1xTAB = 4xSPACE.
//					- Signals beginning with "app_" are related to the
//					  application interface, and those beginning with "mem_" -
//					  to the memory interface.
// 					- Please report bugs to vadim.pesonen@ati.ttu.ee. Although
// 					  i would rather prefer fixes.
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
`include "./defines.v"

module psram_ctrlr
(
	// inputs
	osc_clk_100_bufd,
	reset,
	app_data_in,
	app_addr,
	app_wr,
	app_rd,
	app_ub,
	app_lb,
	app_burst_op,
	// outputs
	mem_addr,
	mem_clk,
	mem_ce,
	mem_cre,
	mem_oe,
	mem_we,
	mem_adv,
	mem_ub,
	mem_lb,
	app_data_ok,
	app_op_begun,
	op_finished,
	app_data_out,
	app_ctrlr_good,
	app_clk_100,
	app_clk_50,
	// input-outputs
	mem_data
);

input			osc_clk_100_bufd;		// oscillator clock (100MHz)
input			reset;			// reset (asynchronous)
input	[22:0]	app_addr;		// address issued by application
input	[15:0]	app_data_in;	// data issued by application
input			app_wr;			// write strobe issued by application
input			app_rd;			// read strobe issued by application
input			app_ub;			// upper byte enable issued by application
input			app_lb;			// lower byte enable issued by application
input			app_burst_op;	// burst operation issued by application (compared to single read/write)
output	[22:0]	mem_addr;		// memory address
output			mem_clk;		// memory clock (50MHz)
output			mem_ce;			// memory chip enable
output			mem_cre;		// memory control register enable
output			mem_oe;			// memory output enable
output			mem_we;			// memory write enable
output			mem_adv;		// memory address valid
output			mem_ub;			// memory upper byte enable
output			mem_lb;			// memory lower byte enable
output	[15:0]	app_data_out;	// data for application
output			app_ctrlr_good;	// controller ready for operation
output			app_op_begun;	// read/write operation has begun
output			op_finished;	// operation has finished
output			app_data_ok;	// data ready / ready to receive data
output			app_clk_100;	// syncronized 100MHz clock
output 			app_clk_50;
inout	[15:0]	mem_data;		// memory data


// signal declaration
reg		[22:0]	addr = `psram_config_word;		// address register and counter
reg		[15:0]	data = 0;		// data register
reg				ub = 0;			// upper byte enable
reg				lb = 0;			// lower byte enable
reg		[4:0]	cur_state = 0;	// FSM state register
reg		[4:0]	next_state;		// FSM next state signal
reg				data_out;		// data bus tristate control
wire			clk_good;		// DCMed clocks are good
wire			clk_10;			// 10MHz, DCMed
wire			clk_50;			// 50MHz clock, DCMed
wire			clk_50_inv;		// 50MHz clock with 180deg phase shift, DCMed
wire			clk_100;		// 100MHz, DCMed
reg				mem_clk_en;		// enable output of ODDR register
reg		[10:0]	mem_init_cntr;	// memory initialization delay counter, assumes 10MHz clock
reg				mem_oe;			//
reg				mem_ce;			//
reg				mem_cre;		//
reg				mem_adv;		//
reg				mem_we;			//
reg				op_begun;		//
reg				app_ctrlr_good;	//
reg				app_data_ok;	//
reg				op_finished;	//
reg				app_op_begun;	//
reg				r1;				// auxilary register for clock level detection
reg				r2;				// auxilary register for clock level detection
wire			clk_50_high;	// clk_50 level is HIGH
reg				reg_app_data;	// register application data and byte enable signals
reg				reg_app_addr;	// register application address
reg				addr_inc;		// ok to increment address register/counter

assign mem_addr = addr;
assign mem_data = data_out ? data : 16'bZ;
assign mem_ub = ub;
assign mem_lb = lb;
assign app_data_out = mem_data;
assign app_clk_100 = clk_100;
assign app_clk_50 = clk_50;

// clock conditioning with DCM
dcm_50_50i_10 dcm_50_50i_10_inst
(
	// Clock in ports
	.CLK_IN1		(osc_clk_100_bufd),	// 100MHz oscillator clock
	// Clock out ports
	.CLK_50 		(clk_50),			// 50MHz clock
	.CLK_50_inv		(clk_50_inv),		// 50MHz clock with 180deg phase shift
	.CLK_10 		(clk_10),			// 10MHz clock
	.CLK_100		(clk_100),			// 100MHz clock
	// Status and control signals
	.RESET			(reset),			// reset
	.CLK_VALID 		(clk_good)			// clocks are good
);

// clock forwarding using ODDR2 component
ODDR2
#(
	.DDR_ALIGNMENT	("NONE"),		// Sets output alignment to "NONE", "C0" or "C1" 
	.INIT			(1'b0), 		// Sets initial state of the Q output to 1'b0 or 1'b1
	.SRTYPE			("ASYNC")		// Specifies "SYNC" or "ASYNC" set/reset
)
ODDR2_inst
(
	.Q				(mem_clk),		// DDR'ed clock output, synchronized with C0
	.C0				(clk_50),		// clock input 1
	.C1				(clk_50_inv),	// clock input 2
	.CE				(mem_clk_en),	// clock enable input
	.D0				(1'b1),			// constant (associated with C0)
	.D1				(1'b0),			// constant (associated with C1)
	.R				(reset),		// reset
	.S				(1'b0)			// set (always inactive)
);

// memory initialization delay counter
always @ (posedge clk_10 or posedge reset)
	begin
		if (reset)
			mem_init_cntr <= 0;
		else if (cur_state == 0)
			mem_init_cntr <= mem_init_cntr + 1'b1;
	end
//

// clk_50 level detection registers
always @ (posedge clk_50 or posedge reset)
	begin
		if (reset)
			r1 <= 0;
		else if (clk_good)
			r1 <= ~r1;
	end
//
always @ (posedge clk_50_inv or posedge reset)
	begin
		if (reset)
			r2 <= 0;
		else if (clk_good)
			r2 <= ~r2;
	end
//
assign clk_50_high = r1 != r2;

// controller good register
always @ (posedge clk_100 or posedge reset)
	begin
		if (reset)
			app_ctrlr_good <= 0;
		else if (cur_state == `idle_state)
			app_ctrlr_good <= 1'b1;
	end
//

// address register and counter (counts to determine end of row)
always @ (posedge clk_100 or posedge reset)
	begin
		if (reset)
			addr <= `psram_config_word;
		else if (reg_app_addr)
			addr <= app_addr;
		else if (addr_inc)
			addr <= addr + 1'b1;
	end
//

// data and byte enable registers
always @ (posedge clk_100 or posedge reset)
	begin
		if (reset)
			begin
				data <= 0;
				lb <= 0;
				ub <= 0;
			end
		else if (reg_app_data)
			begin
				data <= app_data_in;
				lb <= app_lb;
				ub <= app_ub;
			end
	end
//

// state register
always @ (posedge clk_100 or posedge reset)
	begin
		if (reset)
			cur_state <= 0;
		else
			cur_state <= next_state;
	end
//

// next state and output functions
always @ (cur_state,clk_50_high,mem_init_cntr,clk_good,app_rd,app_wr,app_burst_op)
	begin
		// all disabled by default
		mem_oe = 1;
		mem_ce = 1;
		mem_we = 1;
		mem_adv = 1;
		mem_cre = 0;
		data_out = 0;
		next_state = `init_state;
		mem_clk_en = 0;
		addr_inc = 0;
		app_data_ok = 0;
		reg_app_addr = 0;
		reg_app_data = 0;
		app_op_begun = 0;
		op_finished = 0;
		case (cur_state)
			//
			// INITIALIZE MEMORY
			//
			// wait for clocks to lock with osc_clk and for PSRAM initialization delay
			`init_state:
				begin
					if ((clk_good) && (mem_init_cntr == 1501))
						next_state = cur_state + 1'b1;
					else
						next_state = cur_state;
				end
			//
			// CONFIGURE MEMORY FOR:	- synchronous operation
			//							- fixed latency
			//							- latency counter code 3
			//							- wait active high
			//							- wait asserted during delay
			//							- drive strength 1/2
			//							- burst no wrap
			//							- burst length continuous
			//
			// async write 1
			`conf_1_state:
				begin
					mem_cre = 1;
					mem_ce = 0;
					mem_adv = 0;
					next_state = cur_state + 1'b1;
				end
			// async write 2
			`conf_2_state:
				begin
					mem_cre = 1;
					mem_ce = 0;
					next_state = cur_state + 1'b1;
				end
			// async write 3
			`conf_3_state:
				begin
					mem_ce = 0;
					mem_we = 0;
					next_state = cur_state + 1'b1;
				end
			// async write 4
			`conf_4_state:
				begin
					mem_ce = 0;
					mem_we = 0;
					next_state = cur_state + 1'b1;
				end
			// async write 5
			`conf_5_state:
				begin
					mem_ce = 0;
					mem_we = 0;
					next_state = cur_state + 1'b1;
				end
			// async write 6
			`conf_6_state:
				begin
					mem_ce = 0;
					mem_we = 0;
					next_state = cur_state + 1'b1;
				end
			// async write 7
			`conf_7_state:
				begin
					mem_ce = 0;
					mem_we = 0;
					op_finished = 1;
					next_state = cur_state + 1'b1;
				end
			//
			// IDLE STATE
			//
			`idle_state:
				begin
					if (app_rd)
						begin
							reg_app_addr = 1;
							app_op_begun = 1;
							next_state = `rd_0_state;
						end
					else if (app_wr)
						begin
							reg_app_addr = 1;
							reg_app_data = 1;
							app_op_begun = 1;
							next_state = `wr_0_state;
						end
					else
						next_state = cur_state;
				end
			//
			// SYNCHRONOUS WRITE
			//
			// wait for proper clock level
			`wr_0_state:
				begin
					if (clk_50_high)
						next_state = cur_state + 1'b1;
					else
						next_state = cur_state;
				end
			// sync write 1
			`wr_1_state:
				begin
					mem_clk_en = 1;
					mem_ce = 0;
					mem_adv = 0;
					mem_we = 0;
					next_state = cur_state + 1'b1;
				end
			// sync write 2
			`wr_2_state:
				begin
					mem_clk_en = 1;
					mem_ce = 0;
					mem_adv = 0;
					mem_we = 0;
					next_state = cur_state + 1'b1;
				end
			// sync write 3
			`wr_3_state:
				begin
					mem_clk_en = 1;
					mem_ce = 0;
					next_state = cur_state + 1'b1;
				end
			// sync write 4,5,6,7,8
			`wr_4_state,`wr_5_state,`wr_6_state,`wr_7_state,`wr_8_state:
				begin
					mem_clk_en = 1;
					mem_ce = 0;
					next_state = cur_state + 1'b1;
				end
			// sync write 9
			`wr_9_state:
				begin
					mem_clk_en = 1;
					mem_ce = 0;
					data_out = 1;
					app_data_ok = 1;
					next_state = cur_state + 1'b1;
				end
			// sync write 10
			`wr_10_state:
				begin
					mem_clk_en = 1;
					mem_ce = 0;
					data_out = 1;
					if (app_burst_op)
						begin
							addr_inc = 1;
							app_data_ok = 1;
							next_state = `wr_9_state;
						end
					else
						begin
							op_finished = 1;
							next_state = `idle_state;
						end
				end
			//
			// SYNCHRONOUS READ
			//
			// wait for proper clock level
			`rd_0_state:
				begin
					if (clk_50_high)
						next_state = cur_state + 1'b1;
					else
						next_state = cur_state;
				end
			// sync read 1
			`rd_1_state:
				begin
					mem_clk_en = 1;
					mem_ce = 0;
					mem_adv = 0;
					next_state = cur_state + 1'b1;
				end
			// sync read 2
			`rd_2_state:
				begin
					mem_clk_en = 1;
					mem_ce = 0;
					mem_adv = 0;
					next_state = cur_state + 1'b1;
				end
			// sync read 3
			`rd_3_state:
				begin
					mem_clk_en = 1;
					mem_ce = 0;
					next_state = cur_state + 1'b1;
				end
			// sync read 4,5,6,7
			`rd_4_state,`rd_5_state,`rd_6_state,`rd_7_state:
				begin
					mem_clk_en = 1;
					mem_ce = 0;
					next_state = cur_state + 1'b1;
				end
			// sync read 8
			`rd_8_state:
				begin
					mem_clk_en = 1;
					mem_ce = 0;
					mem_oe = 0;
					next_state = cur_state + 1'b1;
				end
			// sync read 9
			`rd_9_state:
				begin
					mem_clk_en = 1;
					mem_ce = 0;
					mem_oe = 0;
					app_data_ok = 1;
					next_state = cur_state + 1'b1;
				end
			// sync read 10
			`rd_10_state:
				begin
					mem_clk_en = 1;
					mem_ce = 0;
					mem_oe = 0;
					if (app_burst_op)
						begin
							addr_inc = 1;
							app_data_ok = 1;
							next_state = `rd_9_state;
						end
					else
						begin
							op_finished = 1;
							next_state = `idle_state;
						end
				end
			default:
				begin
					next_state = `idle_state;
				end
		endcase
	end
//

///////////////////////////////////////////////////////////////////////////////
// End of Main FSM
///////////////////////////////////////////////////////////////////////////////

endmodule
