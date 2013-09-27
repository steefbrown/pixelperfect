

module camera_buffer
(
	input			mem_clk,
	input			cam_clk,
	input 			reset,
	input 	[7:0]	cam_data,
	input 			cam_fv,
	input 			cam_lv,

	input 			op_begun,
	input			data_ok,
	input 			ctrlr_good,

	output reg			mem_wr,
	output reg			mem_burst,
	output		[15:0] 	mem_data,
	output reg 	[22:0] 	mem_addr
);

reg		[3:0]	cur_state = 0;	// FSM current state register
reg		[3:0]	next_state;		// FSM next state signal

reg [7:0] pixel;
reg pixel_select;

reg[15:0] double_pixel;
reg double_pixel_select;

reg [1:0] pixel_state;

reg [17:0] cam_mem_addr;

reg cam_mem_we;

reg mem_addr_incr;
reg mem_addr_reset;

// extract the current 8-bit pixel from the 16-bit cam_data
always @(posedge cam_clk or negedge reset) begin
	if(reset) begin
		pixel <= 0;
	end
	else begin
		if (!pixel_select)
			pixel[7:3] <= {cam_data[7:5], cam_data[1:0]}; //{cam_data[14:12], cam_data[9:8]};
		else
			pixel[2:0] <= {cam_data[7], cam_data[4:3]};
	end
end

// pack the correct pixel into the current double pixel
always @(posedge cam_clk or negedge reset) begin
	if(reset) begin
		double_pixel <= 0;
	end
	else begin
		if (!double_pixel_select)
			double_pixel[15:8] <= pixel;
		else
			double_pixel[7:0] <= pixel;
	end
end

// set pixel select bits
always @(posedge cam_clk or negedge reset) begin
	if(reset || !cam_lv) begin
		pixel_state <= 2'b00;
		pixel_select <= 0;
		double_pixel_select <= 0;
	end
	else begin
		// each state alternates pixel_select, every two alternates double_pixel_select
		{double_pixel_select, pixel_select} <= pixel_state;	
		pixel_state <= pixel_state + 1'b1;
	end
end

// increment camera pixel address
always @(posedge cam_clk or negedge reset) begin
	if(reset || !cam_fv) begin
		cam_mem_addr <= -1;
	end
	else if (cam_lv && pixel_state == 2'b11) begin
		cam_mem_addr <= cam_mem_addr + 1'b1;
	end
end

// assign camera mem write enable
always @(posedge cam_clk or negedge reset) begin
	if(reset || !cam_fv) 
		cam_mem_we <= 0;
	else if (cam_lv && pixel_state == 2'b11)
		cam_mem_we <= 1'b1;
	else
		cam_mem_we <= 0;
end


// 512 x 16-bit
bram_dual bram_dual_inst
(
	// port A - from camera
	.clk_a			(cam_clk),
	.data_in_a		(double_pixel),
	.addr_a			(cam_mem_addr[8:0]),
	.we_a			(cam_mem_we),
	.en_a			(1'b1),
	.data_out_a		(),
	// port B - to ram
	.clk_b			(mem_clk),
	.data_in_b		(16'b0),
	.addr_b			(mem_addr[8:0]),
	.we_b			(1'b0),
	.en_b			(1'b1),
	.data_out_b		(mem_data)
);



always @ (posedge mem_clk or posedge reset)
	begin
		if (reset || mem_addr_reset)
			mem_addr <= 0;
		else if (mem_addr_incr)
			mem_addr <= mem_addr + 1'b1;
	end


always @ (posedge mem_clk or posedge reset)
	begin
		if (reset)
			cur_state <= 0;
		else
			cur_state <= next_state;
	end

always @(*) begin

	mem_wr = 0;
	mem_burst = 0;
	mem_addr_incr = 0;
	mem_addr_reset = 0;

	next_state = cur_state;

	case (cur_state)
		0:	begin
				if (ctrlr_good)
					next_state = cur_state + 1'b1;
			end
		1:	begin
				if (cam_mem_addr[7:0] == 8'b1111_1111) //255
					next_state = cur_state + 1'b1;
			end
		// begin write
		2,6:begin
				mem_wr = 1'b1;
				if (op_begun)
					next_state = cur_state + 1'b1;
			end
		3,7:begin
				if (data_ok)
					next_state = cur_state + 1'b1;
			end
		4,8:begin
				mem_burst = 1'b1;
				mem_addr_incr = 1'b1;
				if (mem_addr[6:0] == 7'b111_1111) //127
					next_state = cur_state + 1'b1;
			end
		5,9:begin
				mem_addr_incr = 1'b1;
				next_state = cur_state + 1'b1;
			end
		10:	begin
				if (cam_mem_addr < mem_addr)
					mem_addr_reset = 1'b1;
				next_state = 1;
			end
	endcase
end





endmodule



