
//
// Handles burst reading from memory and drawing to the VGA.
//
// It uses a dual ported block ram buffer that holds 4 lines of
// RAM data (each line is 128 16-bit cells). It is dual ported
// so that lines can be bursted out of ram into the buffer at
// a frequency of 50MHz, and at the same time pixel data can be
// read out and drawn to the screen at a frequency of 25MHz.
//
// This is based on the work of vadsonen (Tallinn University)
// but modified for resolution 640x480.
//
module video_pipeline
(
	// inputs
	input			clk,			// 100MHz
	input			pixel_clk,		// pixel clock, 25MHz
	input			reset,			// asyncronous
	input	[15:0]	data,			// data from PSRAM
	input			op_begun,		// PSRAM controller has initiated the read operation
	input			data_ok,		// data ready
	input			ctrlr_good,		// PSRAM controller ready for operation
	// outputs
	output			req_access,		// request memory access
	output reg		rd,				// read strobe
	output reg		burst,			// burst operation
	output [22:0]	addr,			// PSRAM address
	output			hs,				// horisontal sync pulse
	output			vs,				// vertical sync pulse
	output [7:0]	rgb				// pixel color value
);


reg		[3:0]	cur_state = 0;	// FSM current state register
reg		[3:0]	next_state;		// FSM next state signal
reg		[15:0]	pixel_data;		// 16-bit BRAM word
wire	[15:0]	data_out_b;		// BRAM port B data output
reg		[18:0]	addr_mem = 0;	// linear memory address counter
reg				addr_mem_en;	// enable memory address counter
reg		[9:0]	addr_vga = 0;	// BRAM vga address counter
reg		[8:0]	addr_mem_b = 0;	// BRAM memory address counter
reg				we_a;			//
reg				vga_wait = 1;	// wait signal for VGA timing generator
reg				inc_wait = 0;	// address should increment every second cycle to match 50MHz memory
reg				init = 1;		// we perform 4 read operations for the first time
reg				clear_init;		// clear init register

assign addr = {4'b0000,addr_mem};
assign req_access = ((cur_state >= 1) && (cur_state <= 7));

// VGA timing generator
//vga_controller	vga_controller_inst
vga_controller2 vga_controller2_inst
(
	// inputs
	.clk		(pixel_clk),	// pixel clock
	.reset		(reset),		// reset
	.hold		(vga_wait),		// wait for buffer memory to be filled
	// outputs
	.hs			(hs),			// horisontal sync signal
	.vs			(vs),			// vertical sync signal
	.blank		(blank)			// do not draw
);

// 512 x 16-bit
bram_dual bram_dual_inst
(
	// port A - from memory
	.clk_a			(clk),
	.data_in_a		(data),
	.addr_a			(addr_mem_b),
	.we_a			(we_a),
	.en_a			(1'b1),
	.data_out_a		(),
	// port B - to screen
	.clk_b			(pixel_clk),
	.data_in_b		(16'b0),
	.addr_b			(addr_vga[9:1]),
	.we_b			(1'b0),
	.en_b			(1'b1),
	.data_out_b		(data_out_b)
);


// vga wait register
always @ (posedge clk or posedge reset)
	begin
		if (reset)
			vga_wait <= 1;
		else if (cur_state == 9)
			vga_wait <= 0;
	end
//

// inc_wait register
always @ (posedge clk or posedge reset)
	begin
		if (reset)
			inc_wait <= 0;
		else if (addr_mem_en)
			inc_wait <= ~inc_wait;
	end
//

// linear memory address counter
always @ (posedge clk or posedge reset)
	begin
		if (reset)
			addr_mem <= 0;
		else if ((addr_mem_en) && (!inc_wait))
			if (addr_mem == 153599)
				addr_mem <= 0;
			else
				addr_mem <= addr_mem + 1'b1;
	end
//

// BRAM memory address counter
always @ (posedge clk or posedge reset)
	begin
		if (reset)
			addr_mem_b <= 0;
		else if ((addr_mem_en) && (!inc_wait))
			addr_mem_b <= addr_mem_b + 1'b1;
	end
//

// BRAM address counter
always @ (posedge pixel_clk or posedge reset)
	begin
		if (reset)
			addr_vga <= 0;
		else if ((!vga_wait) && (!blank))
			addr_vga <= addr_vga + 1'b1;
	end
//

// init register
always @ (posedge clk or posedge reset)
	begin
		if (reset)
			init <= 1;
		else if (clear_init)
			init <= 0;
	end
//

// state register
always @ (posedge clk or posedge reset)
	begin
		if (reset)
			cur_state <= 0;
		else
			cur_state <= next_state;
	end
//

// transition and output functions
always @ (*)
	begin
		rd = 0;					// default inactive
		burst = 0;				// default inavtive
		next_state = cur_state;	// default same state
		we_a = 0;				// default inactive
		addr_mem_en = 0;		// default inactive
		clear_init = 0;			// default inactive
		case (cur_state)
			//
			// INITIALIZATION
			//
			0:	begin
					if (ctrlr_good)
						next_state = cur_state + 1'b1;
					else
						next_state = cur_state;
				end
			//
			// INITIALLY FILL BLOCK 1
			//
			// initiate read 1
			1:	begin
					rd = 1;
					if (op_begun)
						next_state = cur_state + 1'b1;
					else
						next_state = cur_state;
				end
			// wait for data ready
			2:	begin
					if (data_ok)
						next_state = cur_state + 1'b1;
					else
						next_state = cur_state;
				end
			// burst read
			3:	begin
					burst = 1;
					we_a = 1;
					addr_mem_en = 1;
					if (addr_mem[6:0] == 7'b111_1111)  //127
					begin
						next_state = cur_state + 1'b1;
					end
					else
						next_state = cur_state;
				end
			// increase linear address register
			4:	begin
					addr_mem_en = 1;
					next_state = cur_state + 1'b1;
				end
			// initiate read 2
			5:	begin
					rd = 1;
					if (op_begun)
						next_state = cur_state + 1'b1;
					else
						next_state = cur_state;
				end
			// wait for data ready
			6:	begin
					if (data_ok)
						next_state = cur_state + 1'b1;
					else
						next_state = cur_state;
				end
			// burst read
			7:	begin
					burst = 1;
					we_a = 1;
					addr_mem_en = 1;
					if (addr_mem[6:0] == 7'b111_1111) //127
					begin
						//we_a = 0;
						next_state = cur_state + 1'b1;
					end
					else
						next_state = cur_state;
				end
			// increase linear address register
			8:	begin
					addr_mem_en = 1;
					clear_init = 1;
					if (init)
						next_state = 1;
					else
						next_state = cur_state + 1'b1;
				end
			9:	begin
					if (addr_vga[8:1] == 8'b1111_1111) // if addr_vga reached end of bram, repeat
						next_state = 1;
					else
						next_state = cur_state;
				end
		endcase
	end
	//

	// register data from BRAM memory (hm, not sure if it is needed...)
	always @ (posedge pixel_clk or posedge reset)
		begin
			if (reset)
				pixel_data <= 0;
			else
				pixel_data <= data_out_b;
		end
	//

	assign rgb = blank ? 8'b000_000_00 : (addr_vga[0] ? pixel_data[7:0] : pixel_data[15:8]);
	//assign rgb = blank ? 8'b000_000_00 : (addr_vga[0] ? data_out_b[7:0] : data_out_b[15:8]);

endmodule

