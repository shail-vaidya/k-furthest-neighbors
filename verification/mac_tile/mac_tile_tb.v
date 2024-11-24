module mac_tile_tb;
parameter bw = 4;
parameter psum_bw = 16;

reg clk = 0;
reg reset = 1;

reg [bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
reg [1:0] inst_w;
//For now setting in_n to 0
reg [psum_bw-1:0] in_n = 0;

wire [1:0] inst_e;
wire [bw-1:0] out_e; 
wire [psum_bw-1:0] out_s;

mac_tile #(.bw(bw), .psum_bw(psum_bw)) mac_tile_inst (clk, out_s, in_w, out_e, in_n, inst_w, inst_e, reset);

initial #100 $finish;

initial begin
	forever begin
		#5 clk = ~clk;
	end
end


initial begin
	$dumpfile("mac_tile_tb.vcd");
	$dumpvars(0,mac_tile_tb);

	$display("-------------------- Computation start --------------------");
	@(negedge clk);
	inst_w = 2'b00;
	in_w = 4'hF;
	reset = 0;

	@(negedge clk);
	in_w = 4'hF;
	inst_w = 2'b01;

	@(negedge clk);
	in_w = 4'h1;
	inst_w = 2'b10;
	@(negedge clk);
	in_w = 4'hC;

	@(negedge clk);
	in_w = 4'hD;
	@(negedge clk);
	in_w = 4'h9;

	@(negedge clk);
	in_w = 4'hF;
	@(negedge clk);
	in_w = 4'h1;
	$display("-------------------- Computation completed --------------------");
end
endmodule
