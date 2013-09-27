`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Create Date:    14:52:01 10/23/2012 
//
//////////////////////////////////////////////////////////////////////////////////
module top_video_pipeline( 
		input osc_clk,					// 100MHz
		input clr,
		// vga
		output			hs,				// horisontal sync signal
		output			vs,				// vertical sync signal
		output			r2,r1,r0,		// red
		output			g2,g1,g0,		// green
		output			b2,b1			// blue, b0 tied to 0 on PCB
    );

wire	[22:0]	addr;
reg		[15:0]	rd_data;
wire	[7:0]	rgb;

reg [7:0] color;

assign {r2,r1,r0,g2,g1,g0,b2,b1} = rgb;

IBUFG clkin1_buf
   (.O (osc_clk_b),
    .I (osc_clk));

dcm_25 dcm_25_inst
  (// Clock in ports
    .CLK_IN1(osc_clk_b),   // IN
    // Clock out ports
    .CLK_100(clk_100),   // OUT
    .CLK_25(clk_25),     // OUT
    // Status and control signals
    .RESET(clr)// IN
);

dcm_50_50i_10 dcm_50_50i_10_inst
  (// Clock in ports
    .CLK_IN1(osc_clk_b),   // IN
    // Clock out ports
    .CLK_50(clk_50),     // OUT
    // Status and control signals
    .RESET(clr)// IN
);

// vga_controller vga_controller2_inst
// (
// 	// inputs
// 	.clk		(clk_25),	// pixel clock
// 	.reset		(1'b0),		// reset
// 	.hold		(1'b0),		// wait for buffer memory to be filled
// 	// outputs
// 	.hs			(hs),			// horisontal sync signal
// 	.vs			(vs),			// vertical sync signal
// 	.blank		(blank)			// do not draw
// );

// vga_controller vga_controller_inst
// (
// 	// inputs
// 	.clk		(count[2]),	// pixel clock
// 	.reset		(clr),		// reset
// 	.hold		(1'b0),		// wait for buffer memory to be filled
// 	// outputs
// 	.hs			(hs),			// horisontal sync signal
// 	.vs			(vs),			// vertical sync signal
// 	.blank		(blank)			// do not draw
// );

// reg [5:0] count;

// always @(posedge clk_50)
// begin
// 	count <= count + 1;
	
// 	if (count[5])
// 		color <= 8'h80;
// 	else
// 		color <= 8'h10;
// end

// assign rgb = blank ? 8'h00 : color;

always @(posedge clk_100)
begin
	if (clr)
		rd_data <= 16'h0;
	//else if (addr[6:0] == 7'b111_1110)
	//	rd_data <= 16'hFFFF;
	else if (addr[3])
		rd_data <= 16'h8080;
	else
		rd_data <= 16'h1010;
end



video_pipeline video_pipeline_isnt
(
	// inputs
	.clk			(clk_100),
	.pixel_clk		(clk_25),
	.reset			(clr),
	.data			(rd_data),
	.op_begun		(1'b1),
	.data_ok		(1'b1),
	.ctrlr_good		(1'b1),
	// outputs
	.req_access		(),
	.rd				(),
	.burst			(),
	.addr			(addr),
	.hs				(hs),
	.vs				(vs),
	.rgb			(rgb)
);

	
endmodule



