`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// The motherboard.
//
// Create Date:    14:52:01 10/23/2012
//
//////////////////////////////////////////////////////////////////////////////////
module system(
	input osc_clk,					// 100MHz
	input clr,
	//input [7:0] JA,
	// leds
	output [7:0] Led,
	// switches
	input sw_left,
	input sw_center,
	input sw_right,
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
	inout	[15:0]	mem_data,		// memory data
	// vga
	output			hs,				// horisontal sync signal
	output			vs,				// vertical sync signal
	output			r2,r1,r0,		// red
	output			g2,g1,g0,		// green
	output			b2,b1,			// blue, b0 tied to 0 on PCB
	//UART
	input 			RxD,			//receiving line to uart
	output 			TxD				//transmit line from uart out
);

wire	[22:0]	addr;
wire	[15:0]	wr_data;
wire	[15:0]	rd_data;
wire 	[15:0]  proc_reg_data;
wire			burst;
wire			ctrlr_good;
wire			app_1_rd;
wire			app_1_burst;
wire	[22:0]	app_1_addr;
wire			app_1_op_begun;
wire			wr;
wire			rd;
wire	[15:0]	proc_rd_data, proc_wr_data;
wire	[31:0]	proc_addr;
wire	[7:0]	rgb;
wire	[7:0]	uart_data;

wire [10:0] uart_tx_count, uart_rx_count;


// For slowing down the processor frequency by powers of 2
reg [1:0] slow_count;
assign pulse_en = &slow_count;

always @(posedge clk_100 or posedge clr)
	if (clr)
		slow_count <= 0;
	else
		slow_count <= slow_count + 1'b1;


wire [7:0] led_wr_data;
reg [7:0] led_reg;
assign Led = led_reg;

always @(posedge clk_100 or posedge clr)
	if (clr)
		led_reg <= 0;
	else if (led_wr != 0)
		led_reg <= led_wr_data;


assign {r2,r1,r0,g2,g1,g0,b2,b1} = rgb;

IBUFG clkin1_buf
(
	.I (osc_clk),
    .O (osc_clk_bufd)
);

dcm_25 dcm_25_inst
   (// Clock in ports
    .CLK_IN1	(osc_clk_bufd),// IN
    // Clock out ports
    //.CLK_100	(clk_100),    // OUT
    .CLK_25		(clk_25),     // OUT
    // Status and control signals
    .RESET		(clr)
);


processor  processor_inst
(
	// inputs
	.clk				(clk_100),
	.clr 				(clr),
	.pulse_en 			(pulse_en),
	.stall 				(mem_stall),
	.mem_read_data		(proc_rd_data),
	// outputs
	.mem_read_enable	(proc_rd),
	.mem_write_enable	(proc_wr),
	.mem_write_data		(proc_wr_data),
	.mem_write_addr		(proc_addr)
);

// Cellular RAM (PSRAM) controller
psram_ctrlr psram_ctrlr_inst
(
	//inputs
	.osc_clk_100_bufd 	(osc_clk_bufd),
	.reset			(clr),
	.app_data_in	(wr_data),		// data to memory
	.app_addr		(addr),			// memory address
	.app_wr			(wr),			// write strobe
	.app_rd			(rd),			// read strobe
	.app_burst_op	(burst),		// burst operation issued by application
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
	.app_data_ok	(data_ok),		// data ready / OK to fetch data (on next clock)
	.app_op_begun	(op_begun),		// read/write operation has initiated
	.op_finished	(op_finished),	// read/write operation has finished
	.app_data_out	(rd_data),		// data from memory
	.app_ctrlr_good	(ctrlr_good),	// controller is ready for operation
	.app_clk_100 	(clk_100),
	//input-outputs
	.mem_data		(mem_data)
);

// dualport front-end for memory controller
dualport_frontend dualport_frontend_inst
(
	// general inputs
	.clk				(clk_100),
	.reset				(clr),
	// input from application 1
	.app_1_data_wr		(16'b0),
	.app_1_addr			(app_1_addr),
	.app_1_wr			(1'b0),
	.app_1_rd			(app_1_rd),
	.app_1_burst		(app_1_burst),
	.app_1_req_access	(app_1_req_access),
	// output to application 1
	.app_1_op_begun		(app_1_op_begun),
	.app_1_data_ok		(app_1_data_ok),
	// input from application 2
	.app_2_data_wr		(proc_wr_data),
	.app_2_addr			(proc_addr[22:0]),
	.app_2_wr			(app_2_wr),
	.app_2_rd			(app_2_rd),
	.app_2_data_out   	(proc_reg_data),
	// output to application 2
	.app_2_stall		(mem_stall),
	// input from memory controller
	.op_begun			(op_begun),
	.data_ok			(data_ok),
	.op_finished		(op_finished),
	.rd_data 			(rd_data),
	.ctrl_good          (ctrlr_good),
	// output to memory controller
	.app_data_out		(wr_data),
	.app_addr			(addr),
	.app_wr				(wr),
	.app_rd				(rd),
	.app_burst			(burst)
);

// application 1 - video pipeline
video_pipeline video_pipeline_isnt
(
	// inputs
	.clk			(clk_100),
	.pixel_clk		(clk_25),
	.reset			(clr),
	.data			(rd_data),
	.op_begun		(app_1_op_begun),
	.data_ok		(app_1_data_ok),
	.ctrlr_good		(ctrlr_good),
	// outputs
	.req_access		(app_1_req_access),
	.rd				(app_1_rd),
	.burst			(app_1_burst),
	.addr			(app_1_addr),
	.hs				(hs),
	.vs				(vs),
	.rgb			(rgb)
);

mem_map_io 	mem_map_io_inst
(
	.addr 			(proc_addr),
	.proc_wr_data 	(proc_wr_data),
	.proc_rd 		(proc_rd),
	.proc_wr 		(proc_wr),

	.uart_rd_data 	(uart_data), // 8 bits
	.mem_rd_data 	(proc_reg_data), 	// 16 bits

	.switches	 	({sw_right, sw_center, sw_left}), // left is 1, center 2, right 4

	.uart_tx_count 	(uart_tx_count),
	.uart_rx_count 	(uart_rx_count),

	//outputs
	.mem_wr 		(app_2_wr),
	.mem_rd 		(app_2_rd),
	.uart_wr 		(uart_wr),
	.uart_rd 		(uart_rd),

	.proc_rd_data 	(proc_rd_data), // 16 bits
	.led_wr 		(led_wr),
	.led_wr_data 	(led_wr_data)
);


uart_min uart_min_isnt
(
	//inputs
	.clock		(clk_100),
	.reset		(clr),
	.pulse_en 	(pulse_en),
	.read		(uart_rd),
	.write		(uart_wr),
	.data_in	(proc_wr_data[7:0]),
	.RxD		(RxD),
	// outputs
	.TxD		(TxD),
	.data_out	(uart_data),
	.tx_count 	(uart_tx_count),
	.rx_count 	(uart_rx_count)
);

endmodule



