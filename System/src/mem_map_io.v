
//
// Provides access to switches, leds, uart, and memory based on addr.
// Handles muxing the proc_rd and proc_wr lines so as to avoid
// inducing a memory stall when not actually accessing memory.
//
// If addr[23] is low, normal access to memory. Else:
// 0xXX800000 => uart rd/wr
// 0xXX800001 => read from switches
// 0xXX800002 => number of items in uart transmit fifo
// 0xXX800003 => number of items in uart receive fifo
// 0xXX800004 => write to leds
//

module mem_map_io
(
	input [31:0] addr,
	input [15:0] proc_wr_data,
	input proc_rd,
	input proc_wr,

	input [7:0] uart_rd_data, 	// 8 bits
	input [15:0] mem_rd_data, 	// 16 bits

	input [2:0] switches,

	input [10:0] uart_tx_count,
	input [10:0] uart_rx_count,

	//outputs
	output reg mem_rd,
	output reg mem_wr,
	output reg uart_rd,
	output reg uart_wr,

	output reg [15:0] proc_rd_data, 	// 16 bits

	output reg led_wr,
	output reg [7:0] led_wr_data
);

	wire [22:0] io_num;
	assign io_num = addr[22:0];

	always @(*)
	begin

		// defaults
		mem_wr <= 0;
		mem_rd <= 0;
		uart_wr <= 0;
		uart_rd <= 0;
		proc_rd_data <= 16'b0;
		led_wr <= 0;
		led_wr_data <= 8'b0;

		if (addr[23]) begin
			if (io_num == 0) begin
				// uart
				uart_wr <= proc_wr;
				uart_rd <= proc_rd;
				proc_rd_data <= {8'b0, uart_rd_data};
			end
			else if (io_num == 1) begin
				// read switches
				proc_rd_data <= {13'b0, switches};
			end
			else if (io_num == 2) begin
				// read uart_tx_count
				proc_rd_data <= {5'b0, uart_tx_count};
			end
			else if (io_num == 3) begin
				// read uart_rx_count
				proc_rd_data <= {5'b0, uart_rx_count};
			end
			else if (io_num == 4 && proc_wr) begin
				// write to leds
				led_wr <= 1'b1;
				led_wr_data <= proc_wr_data[7:0];
			end
		end
		else begin
			// memory
			mem_wr <= proc_wr;
			mem_rd <= proc_rd;
			proc_rd_data <= mem_rd_data;
		end
	end

endmodule