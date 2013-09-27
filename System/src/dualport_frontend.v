
//
// Also referred to as the "arbiter", this module handles interleaving
// memory operations between the video pipeline and the processor (app_1 & app_2).
//
// There is a notion of priority: if the video pipeline and the processor
// request access at the same time, the video pipeline gets control and the
// processor gets stalled until the memory says that the operation is
// complete. Then the processor will get serviced.
//
// This is based on the work of vadsonen (Tallinn University) with the
// addition of app_2_stall logic.
//
module dualport_frontend
(
	// general inputs
	clk,
	reset,
	// input 1
	app_1_data_wr,
	app_1_addr,
	app_1_wr,
	app_1_rd,
	app_1_ub,
	app_1_lb,
	app_1_burst,
	app_1_req_access,
	// output 1
	app_1_data_ok,
	app_1_op_begun,
	// input 2
	app_2_data_wr,
	app_2_addr,
	app_2_wr,
	app_2_rd,
	app_2_ub,
	app_2_lb,
	app_2_burst,
	// output 2
	app_2_data_ok,
	app_2_op_finished,
	app_2_op_begun,
	app_2_stall,
	app_2_data_out,
	// input mem
	data_ok,
	op_finished,
	op_begun,
	rd_data,
	ctrl_good,
	// output mem
	app_data_out,
	app_addr,
	app_wr,
	app_rd,
	app_ub,
	app_lb,
	app_burst
);

input			clk;
input			reset;
// input 1
input 	[15:0]	app_1_data_wr;
input 	[22:0]	app_1_addr;
input			app_1_wr;
input			app_1_rd;
input			app_1_ub;
input			app_1_lb;
input			app_1_burst;
input			app_1_req_access;
// output 1
output			app_1_data_ok;
output			app_1_op_begun;
// input 2
input 	[15:0]	app_2_data_wr;
input 	[22:0]	app_2_addr;
input			app_2_wr;
input			app_2_rd;
input			app_2_ub;
input			app_2_lb;
input			app_2_burst;
// output 2
output			app_2_data_ok;
output			app_2_op_finished;
output			app_2_op_begun;
output reg   	app_2_stall;
output reg [15:0] app_2_data_out;
// input mem
input			op_begun;
input			op_finished;
input			data_ok;
input   [15:0]	rd_data;
input 			ctrl_good;
// output mem
output	[15:0]	app_data_out;
output	[22:0]	app_addr;
output			app_wr;
output			app_rd;
output			app_ub;
output			app_lb;
output			app_burst;

wire			app_sel;				// application selector: 0 = app_1, 1 = app_2
reg		[2:0]	cur_state = 0;			// FSM stat register
reg		[2:0]	next_state;				// next state signal
reg				op_finished_reg = 0;	// registering op_finished signal to avoid combinational loopbacks

reg 			app_2_rd_reg;

assign app_data_out = app_sel ? app_2_data_wr : app_1_data_wr;
assign app_addr =  app_sel ? app_2_addr : app_1_addr;
assign app_ub =  app_sel ? app_2_ub : app_1_ub;
assign app_lb =  app_sel ? app_2_lb : app_1_lb;
assign app_wr =  app_sel ? app_2_wr : app_1_wr;
assign app_rd =  app_sel ? app_2_rd_reg : app_1_rd;
assign app_burst =  app_sel ? app_2_burst : app_1_burst;
assign app_2_data_ok = app_sel ? data_ok : 1'b0;
assign app_2_op_begun = app_sel ? op_begun : 1'b0;
assign app_2_op_finished = app_sel ? op_finished : 1'b0;
assign app_1_data_ok = app_sel ? 1'b0 : data_ok;
assign app_1_op_begun = app_sel ? 1'b0 : op_begun;

assign app_sel = ((cur_state == 2)|(next_state == 2));

assign app_2_req_access = app_2_wr | app_2_rd;

always @(posedge clk or posedge reset)
    begin
	    if (reset)
	        app_2_data_out <= 0;
	    else if (data_ok)
	        app_2_data_out <= rd_data;
    end

always @ (posedge clk or posedge reset)
	begin
		if (reset)
			cur_state <= 0;
		else
			cur_state <= next_state;
	end
//

// registering op_finished to avoid a combinational loopback which otherwise appear
always @ (posedge clk or posedge reset)
	begin
		if (reset)
			op_finished_reg <= 0;
		else
			op_finished_reg <= op_finished;
	end

always @ (*)
	begin
		app_2_stall = 0;
		app_2_rd_reg = 0;
		next_state = cur_state;

		case (cur_state)
			// access available
			0:	begin
					if (app_1_req_access)
						next_state = 1;
					else if (app_2_req_access)
						next_state = 2;
				end
			// application 1 is using memory
			1:	begin
					app_2_stall = app_2_req_access;

					if (op_finished_reg)
						next_state = 0;
				end
			// application 2 is using memory
			2:	begin
					app_2_stall = 1;
					app_2_rd_reg = 1;
					if (op_finished_reg) begin
						app_2_rd_reg = 0;
						next_state = cur_state + 1'b1;
					end
				end
            // extra state to avoid reentering state 2 when processor stalled
	 		3:	begin
					if (app_2_req_access == 0)
						next_state = 0;
				end
		endcase
	end

endmodule
