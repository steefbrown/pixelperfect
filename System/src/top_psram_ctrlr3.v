`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:20:02 11/11/2012 
//
//////////////////////////////////////////////////////////////////////////////////
module top_psram_ctrlr3(
		input osc_clk,					// 100MHz
		input clr,
		input [7:0] switches, 		//select address from BRAM
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
reg 				burst;
reg	[22:0]	addr_counter;
reg 				counter_en;
reg				counter_clr;
wire				data_ok;
reg 	[22:0]	addr;
wire 	[15:0]	wr_data;
wire	[15:0]	rd_data;
reg 	wr, rd;
wire 	[15:0]	data_latch;
reg				latch_flag;
reg				init;
reg				clear_init;
reg				inc_wait;
reg	[1:0]		passes;  //4 passes of 128 bursts to fill 512 BRAM
reg				pass;
reg				we_a;
wire	[8:0]		bram_addr;
assign Led = {rd_data != 0, passes, 0, cur_state};
assign wr_data = addr_counter[15:0];
assign bram_addr = switches + 8'b10000000;
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
	.mem_clk			(mem_clk),
	.mem_ce			(mem_ce_n),
	.mem_cre			(mem_cre),
	.mem_oe			(mem_oe_n),
	.mem_we			(mem_we_n),
	.mem_adv			(mem_adv_n),
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

bram_dual bram_dual_inst
(
	// port A - from memory
	.clk_a			(app_clk),
	.data_in_a		(rd_data),
	.addr_a			(addr_counter),
	.we_a				(we_a),
	.en_a				(1'b1),
	.data_out_a		(),
	// port B - to screen
	.clk_b			(app_clk),
	.data_in_b		(16'b0),
	.addr_b			(bram_addr),  //0 on switches gives address 128
	.we_b				(1'b0),
	.en_b				(1'b1),
	.data_out_b		(data_latch)
);

led_hex	led_hex_inst
(
	// inputs
    .clk		(app_clk),
	 .clr		(clr),
    .write_en 	(addr_counter == 255 && pass > 0),
    .val 		(rd_data),
	 // outputs
    .AN			(AN),
    .C			(C),
    .DP			(DP)
 );

always@(posedge app_clk or posedge clr)
begin
	if(clr)
		passes <= 0;
	else if(pass && (!inc_wait))
		passes <= passes + 1'b1;
end

always@(posedge app_clk or posedge clr)
begin
	if(clr)
		addr_counter <= 0;
	else if ((counter_en) && (!inc_wait))
		addr_counter <= addr_counter + 1'b1;
end

always @ (posedge app_clk or posedge clr)
	begin
		if (clr)
			inc_wait <= 0;
		else if (counter_en)
			inc_wait <= ~inc_wait;
	end

always @ (posedge app_clk or posedge clr)
begin
	if (clr) 
		cur_state <= 0;
	else 
		cur_state <= next_state;
end

always @ (*)
begin
	rd <= 0;
	wr <= 0;
	next_state <= cur_state;
	addr <= 0;
	counter_clr <= 0;
	burst <= 0;
	counter_en <= 0;
	latch_flag <= 0;
	clear_init <= 0;
	we_a <= 0;
	case (cur_state)
		0: begin
				if (ctrlr_good)
					next_state <= cur_state + 1'b1;
			end
		1: begin
				wr <= 1'b1;
				addr <= addr_counter;
				if (op_begun)
					next_state <= cur_state + 1'b1;
			end
		2: begin
				addr <= addr_counter;
				if (op_finished) begin
					if(addr_counter[8:0] == 9'b111111111) begin
						next_state <= cur_state + 1'b1;
						counter_clr <= 1;
					end
					else begin
						counter_en <= 1;
						next_state <= 4'b0001;
					end
				end
			end
			//burst read
		3: begin
				rd <= 1;
				addr <= addr_counter;
				if (op_begun)
					next_state <= cur_state + 1'b1;
				else
					next_state <= cur_state;
			end
		4:	begin
				addr <= addr_counter;
				if (data_ok)
					next_state <= cur_state + 1'b1;
				else
					next_state <= cur_state;
			end
		5: begin
				addr <= addr_counter;
				burst <= 1;
				counter_en <= 1;
				we_a <= 1;
				if (addr_counter[6:0] == 7'b111_1111)  //127
					next_state <= cur_state + 1'b1;
				else
					next_state <= cur_state;
			end
		6:	begin
				addr <= addr_counter;
				if(passes == 2'b11) begin
					next_state <= cur_state + 1'b1;
				end
				else begin
					pass <= 1;
					next_state <= 3;
				end
			end
		7:	begin
				// sit
			end
		endcase
end

endmodule
