`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:59:07 11/14/2012 
//
//////////////////////////////////////////////////////////////////////////////////
module top_camera(
	input 			osc_clk,
	input 			clr,
	// Camera interface
	inout 			CAMA_SDA,
	inout 			CAMA_SCL,
	input 	[7:0] 	CAMA_D_I,
	inout 			CAMA_PCLK_I,
	output 			CAMA_MCLK_O,		
	input 			CAMA_LV_I,
	input 			CAMA_FV_I,
	output 			CAMA_RST_O, 	
	output 			CAMA_PWDN_O, 	
	output 			CAMX_VDDEN_O,	
	// Memory interface
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
	output			b2,b1			// blue, b0 tied to 0 on PCB
    );

wire	[22:0]	addr;
wire	[15:0]	wr_data;
wire	[15:0]	rd_data;
wire	[22:0]	app_1_addr;
wire	[15:0]	app_3_data;
wire	[22:0]	app_3_addr;
wire	[7:0]	rgb;

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
    .CLK_100	(clk_100),    // OUT
    .CLK_25		(clk_25),     // OUT
    // Status and control signals
    .RESET		(clr)
);

// application 3 - camera
camera_ctrlr camera_ctrlr_inst 
(
	.osc_clk_100_bufd	(osc_clk_bufd),
	.clk_50				(app_clk_50),
	.reset				(clr),
	.CAMA_SDA			(CAMA_SDA),
	.CAMA_SCL			(CAMA_SCL),
	.CAMA_D_I			(CAMA_D_I),
	.CAMA_PCLK_I		(CAMA_PCLK_I),
	.CAMA_MCLK_O		(CAMA_MCLK_O),
	.CAMA_LV_I			(CAMA_LV_I),
	.CAMA_FV_I			(CAMA_FV_I),
	.CAMA_RST_O			(CAMA_RST_O),
	.CAMA_PWDN_O		(CAMA_PWDN_O),
	.CAMX_VDDEN_O		(CAMX_VDDEN_O),
	.ctrlr_good			(ctrlr_good),
	.op_begun			(app_3_op_begun),
	.data_ok			(app_3_data_ok),
	.mem_wr				(app_3_wr),
	.mem_burst			(app_3_burst),
	.mem_data			(app_3_data),
	.mem_addr			(app_3_addr)
);

// dualport front-end for memory controller
dualport_frontend dualport_frontend_inst
(
	// general inputs
	.clk				(app_clk_100),
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
	// input from application 3
	.app_3_data_wr		(app_3_data),
	.app_3_addr			(app_3_addr),
	.app_3_wr			(app_3_wr),
	.app_3_burst		(app_3_burst),
	// output to application 3
	.app_3_op_begun		(app_3_op_begun),
	.app_3_data_ok		(app_3_data_ok),
	// input from memory controller
	.op_begun			(op_begun),
	.data_ok			(data_ok),
	.op_finished		(op_finished),
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
	.clk			(app_clk_100),
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
	.app_clk_100 	(app_clk_100),
	.app_clk_50 	(app_clk_50),
	//input-outputs
	.mem_data		(mem_data)
);



endmodule
