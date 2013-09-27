module read_mux(
input sel,
input ram_data_ready,
input uart_data_ready,
input [31:0] mem_data,
input [7:0] uart_data,
output [31:0] data_out,
output data_ready
);
assign data_ready = sel ? uart_data_ready : ram_data_ready;
assign data_out = sel ? {24'b0,uart_data} : mem_data;

endmodule