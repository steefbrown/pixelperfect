module bram_dual
(
	// port A
	clk_a,
	data_in_a,
	addr_a,
	we_a,
	en_a,
	data_out_a,
	// port B
	clk_b,
	data_in_b,
	addr_b,
	we_b,
	en_b,
	data_out_b
);

input				clk_a;
input	[15:0]	data_in_a;
input	[8:0]		addr_a;
input				we_a;
input				en_a;
input				clk_b;
input	[15:0]	data_in_b;
input	[8:0]		addr_b;
input				we_b;
input				en_b;
output [15:0]	data_out_a;
output [15:0]	data_out_b;

parameter RAM_WIDTH = 16;
parameter RAM_ADDR_BITS = 9;

//(* RAM_STYLE="{AUTO | BLOCK |  BLOCK_POWER1 | BLOCK_POWER2}" *)
reg [RAM_WIDTH-1:0] bram [(2**RAM_ADDR_BITS)-1:0];
reg [RAM_WIDTH-1:0] data_out_a, data_out_b;

wire [RAM_ADDR_BITS-1:0] addr_a, addr_b;
wire [RAM_WIDTH-1:0] data_in_a, data_in_b;

always @ (posedge clk_a)
	if (en_a) begin
		if (we_a)
			bram[addr_a] <= data_in_a;
		data_out_a <= bram[addr_a];
	end
//
  
always @ (posedge clk_b)
	if (en_b) begin
		if (we_b)
			bram[addr_b] <= data_in_b;
		data_out_b <= bram[addr_b];
	end
//

endmodule
