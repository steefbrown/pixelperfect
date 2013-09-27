`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:20:02 11/11/2012 
//
//////////////////////////////////////////////////////////////////////////////////
module top_psram_ctrlr2(
		input osc_clk,					// 100MHz
		input clr,
		// leds
		output [7:0] Led,
		// output to 7-seg leds
		output [3:0] AN,
		output [6:0] C,
		output DP,
		// memory
		output	[22:0]	mem_addr,		// memory address
		output			mem_clk,		// memory clock (50MHz)
		output			mem_ce_n,		// memory chip enable
		output			mem_oe_n,		// memory output enable
		output			mem_we_n,		// memory write enable
		output			mem_adv_n,		// memory address valid
		output			mem_ub_n,		// memory upper byte enable
		output			mem_lb_n,		// memory lower byte enable
		output			mem_cre,		// memory control register enable
		inout	[15:0]	mem_data		// memory data
    );


reg [3:0] cur_state, next_state;

reg 	[22:0]	addr;
reg 	[15:0]	wr_data;
wire	[15:0]	rd_data;
reg 	wr, rd;

assign Led = {4'b0, cur_state};

IBUFG clkin1_buf
(
	.I (osc_clk),
    .O (osc_clk_bufd)
);

// Cellular RAM (PSRAM) controller
psram_ctrlr psram_ctrlr_inst
(
	//inputs
	.osc_clk_100_bufd 	(osc_clk_bufd),
	.reset			(clr),
	.app_data_in	(wr_data),			// data to memory
	.app_addr		(addr),				// memory address
	.app_wr			(wr),					// write strobe
	.app_rd			(rd),					// read strobe
	.app_burst_op	(burst),				// burst operation issued by application
	//outputs
	.mem_addr		(mem_addr),
	.mem_clk		(mem_clk),
	.mem_ce			(mem_ce_n),
	.mem_cre		(mem_cre),
	.mem_oe			(mem_oe_n),
	.mem_we			(mem_we_n),
	.mem_adv		(mem_adv_n),
	.mem_ub			(mem_ub_n),
	.mem_lb			(mem_lb_n),
	.app_data_ok	(data_ok),			// data ready / OK to fetch data (on next clock)
	.app_op_begun	(op_begun),			// read/write operation has initiated
	.op_finished	(op_finished),		// read/write operation has finished
	.app_data_out	(rd_data),			// data from memory
	.app_ctrlr_good	(ctrlr_good),	// controller is ready for operation
	.app_clk 		(app_clk),
	//input-outputs
	.mem_data		(mem_data)
);

led_hex	led_hex_inst
(
	// inputs
    .clk		(app_clk),
	 .clr		(clr),
    .write_en 	(data_ok),
    .val 		(rd_data),
	 // outputs
    .AN			(AN),
    .C			(C),
    .DP			(DP)
 );

always @ (posedge app_clk or posedge clr)
begin
	if (clr) 
		cur_state <= 0;
	else 
		cur_state <= next_state;
end

always @ (*)
begin

	rd = 0;
	wr = 0;
	next_state = cur_state;
	case (cur_state)
		0: 	begin
				if (ctrlr_good)
					next_state = cur_state + 1'b1;
			end
		1: 	begin

				wr_data = 16'hBAB1;
				wr = 1'b1;
				addr = 127;

				if (op_finished)
					next_state = cur_state + 1'b1;
			end
		2: 	begin

				wr_data = 16'hBAB2;
				wr = 1'b1;
				addr = 128;

				if (op_finished)
					next_state = cur_state + 1'b1;
			end
		3: 	begin
				rd = 1'b1;
				addr = 128;

				if (op_finished)
					next_state = cur_state + 1'b1;
			end
		default:	begin
				// sit
			end
		endcase
end

endmodule
