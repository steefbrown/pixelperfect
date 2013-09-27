module write_mux (
input sel,
input[31:0] rd_data,
input write,
input read,
input mem_stall,
input uart_stall,
output stall,
output [7:0] uart_data,
output [31:0] mem_data,
output uart_write,
output uart_read,
output mem_write,
output mem_read
);
// assign uart lines based on select
assign uart_data = sel ? rd_data[7:0]: 0;
assign {uart_write,uart_read} = sel ? {write, read} : 2'b00;
// assign mem lines based on select
assign mem_data = sel ? 0 : rd_data;
assign {mem_write,mem_read} = sel ? 2'b00 : {write, read};

assign stall = sel ? uart_stall : mem_stall;
endmodule

