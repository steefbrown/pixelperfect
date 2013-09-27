`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:53:16 10/24/2012 
// Design Name: 
// Module Name:    arbiter 
//
//////////////////////////////////////////////////////////////////////////////////
module arbiter(
	input				clk,
	input				reset,
	input	 [15:0]	mem_rd_data,	//data to read from memory
		//output -> Mem
	output 	 [22:0]		addr,
	output 	 [15:0]		mem_wr_data,  	//data to write to memory
		//input priority 1 <- VGA..
	input				vga_req,
	input	 [22:0]	vga_addr,
	input				vga_app_burst,
	input				vga_rd,
		//output -> VGA
	output 	 [15:0]	vga_data_out,
	output				vga_ack,
	//output				vga_data_ok,  
	//output				vga_op_begun,
	//output				vga_ctrl_good,
		//input priority 2 <- CPU
	input	 [15:0]	cpu_data_in,
	input	 [22:0]	cpu_addr,
	input			cpu_req_access,
		//output -> CPU
	output			cpu_stall_pc,
	output [15:0]	cpu_data_out,
		//input priority 3 <- Camera
	input				cam_req_access,
	input  [15:0]	cam_data,
	input  [22:0]	cam_addr,
		//PSRAM control lines
	input				mem_data_ok,
	input				mem_opp_begun,
	input				mem_ctrl_good,
	input				mem_op_finish,
	output			mem_rd,
	output			mem_wr,
	output			mem_burst_op
    );
	//states
	parameter 	idle = 0, 
					vga  = 1, 
					cpu  = 2, 
					cam  = 3;
	reg	[1:0] cur_state = idle;
	reg	[1:0] next_state;
	reg 	cpu_rd;
	
	//is the cpu reading or writing?
	assign cpu_rd = cpu_data_in ? 1'b1 : 1'b0;
	
	//assign appropriate addr and mem_rd_data
	always@(cur_state) begin
		addr 			 	<= 0;
		vga_data_out 	<= 0;
		cpu_data_out 	<= 0;
		mem_wr_data	 	<= 0;
		mem_burst_op 	<= 0;
		mem_rd		 	<= 0;
		mem_wr		 	<= 0;
		vga_data_ok  	<= 0;
		vga_op_begun	<= 0;
		vga_ctrl_good	<= 0;
		vga_ack			<= 0;
		case(cur_state)
			idle:
				vga_ctrl_good 	<= app_ctrl_good;   //init case in pipeline needed? assign statement?
			vga: begin
				addr 				<= vga_addr;
				vga_data_out 	<= mem_rd_data;
				mem_burst_op	<= vga_app_burst;
				mem_rd 			<= vga_rd;
				vga_ack			<= mem_data_ok;
				vga_op_begun	<= mem_op_bugun;
				end
			cpu: begin   //cpu: additional control logic needed
				addr 				<= cpu_addr;
				cpu_data_out	<= mem_rd_data;
				mem_wr_data 	<= cpu_data_in;
				app_rd			<= cpu_rd;
				app_wr			<= !cpu_rd;
				end
			cam: begin	//cam: additional control logic needed
				addr 				<= cam_addr;
				mem_wr_data		<= cam_data;
				app_wr			<= 1'b1;
				end
			default: begin
				addr 			 <= 0;
				vga_data_out <= 0;
				cpu_data_out <= 0;
				mem_wr_data	 <= 0;
			end
		endcase
	end
	
	always @ (posedge clk or posedge reset) 
	begin
		if (reset)
			cur_state <= 0;
		else
			cur_state <= next_state;
	end



	always @ (cur_state, vga_req, cpu_req, cam_req) 
	begin
			case(cur_state)		
				idle:	
					begin		//access available
						if(vga_req)
							next_state = vga;
						else if(cpu_req)
							next_state = cpu;
						else
							next_state = cam;
					end
				vga:	
					begin		//VGA is using memory
						if(!vga_req)
							next_state = idle;
						else
							next_state = cur_state;
					end
				cpu: 
					begin		//CPU using memory
						if(!cpu_req)
							next_state = idle;
						else
							next_state = cur_state;
					end
				cam: 
					begin		//Camera using memory
						if(!cam_req)
							next_state = 0;
						else
							next_state = cur_state;
					end
			endcase
	end
endmodule
