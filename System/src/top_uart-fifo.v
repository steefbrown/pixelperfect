`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:23:14 11/15/2012 
// Design Name: 
// Module Name:    top_uart-fifo 
// Project Name: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module top_uart_fifo(
	input clk, 
	input clr,
	input rx,
	output tx,
	output [7:0] LED
   );

reg 	[2:0] 	cur_state, next_state;
reg 	[7:0]	wr_data;
//wire	[7:0]	rd_data;
reg transmit;

reg [8:0] counter;
reg [20:0] count2;

assign LED = cur_state;

always @ (posedge clk or posedge clr)	
begin
		if(clr) begin
			cur_state = 0;
			counter = 0;
			count2 = 0;
			end			
		else begin
			count2 = count2 + 1;
			if(cur_state == 1) begin				
				counter = counter + 1;
			end			
			if(count2[20]) begin
				cur_state = next_state;
			end
		end
end

always @ (*)
begin

	wr_data = 8'b10011011;
	transmit = 0;
	
	case (cur_state)
		0:		begin
			if(counter <= 250) begin			
				next_state = cur_state + 1;			
				end
			else
				next_state = cur_state;
			end
		1:		begin
				transmit = 1;
				next_state = 2;
			end
		2:		begin
				next_state = 0;
				end
	endcase
end

uart_min uart_min_inst(
	//inputs
	.clock					(clk),
	.reset					(clr),
	.RxD					(rx),	
	.write					(transmit),
	.data_in				(wr_data),
	.read					(),
	// outputs
	.data_ready				(),
	.TxD					(tx),
	.data_out				(),
	.rx_count				()
);


endmodule
