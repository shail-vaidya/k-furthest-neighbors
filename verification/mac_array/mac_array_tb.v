module mac_array_tb;
parameter bw = 4;
parameter psum_bw = 16;
parameter row = 8;
parameter col = 1;


wire [psum_bw*col-1:0] out_s;
reg  [row*bw-1:0] in_w;
reg  [2:0] inst_w;  	// inst[1]:execute, inst[0]: kernel loading
wire [col-1:0] valid;

reg clk = 0;
reg reset = 1;
reg[psum_bw*col-1:0] in_n;


wire [2:0] inst_e;
wire [bw-1:0] out_e; 

mac_array mac_array_inst(clk, reset, out_s, in_w, in_n, inst_w, valid);

initial #300 $finish;

initial begin
	forever begin
		#5 clk = ~clk;
	end
end


initial begin
	$dumpfile("mac_array_tb.vcd");
	$dumpvars(0,mac_array_tb);

	$display("-------------------- Computation start --------------------");
	@(negedge clk);
	inst_w = 3'b000;
	in_w = 4'hF;
	in_n = 2;
	reset = 0;

	@(negedge clk);
	in_w = 4'hF;
	in_n = 3;
	inst_w = 3'b001;

	@(negedge clk);
	in_w = 4'h1;
	in_n = 1;
	inst_w = 3'b010;
	@(negedge clk);
	in_w = 4'hC;

	@(negedge clk);
	in_w = 4'hD;
	@(negedge clk);
	in_w = 4'h9;
	in_n = 0;

	@(negedge clk);
	in_w = 4'hF;
	@(negedge clk);
	in_w = 4'h1;
	$display("-------------------- Computation completed --------------------");
end
endmodule
