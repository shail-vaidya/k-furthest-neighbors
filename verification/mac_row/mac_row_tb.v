module mac_row_tb;
	parameter bw = 4;
	parameter psum_bw = 16;
	parameter col = 8;
	
	reg clk = 0;
	reg reset = 1;
	
	reg [bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
	reg [2:0] inst_w;
	//For now setting in_n to 0
	reg [psum_bw*col-1:0] in_n = 0;
	
	wire [psum_bw*col-1:0] out_s;
	wire [col-1:0] valid;
	
	mac_row #(.bw(bw), .psum_bw(psum_bw)) mac_row_inst (clk, out_s, in_w, in_n, valid, inst_w, reset);
	
	initial #500 $finish;
	
	initial begin
		forever begin
			#5 clk = ~clk;
		end
	end
	
	
	initial begin
		$dumpfile("mac_row_tb.vcd");
		$dumpvars(0,mac_row_tb);
	
		$display("-------------------- Computation start --------------------");
		@(negedge clk);
		inst_w = 3'b00;
		in_w = 4'hF;
		reset = 0;
	
		@(negedge clk);
		in_w = 4'hF;
		inst_w = 3'b01;

		@(negedge clk);
		in_w = 4'hE;
		inst_w = 3'b01;
	
		@(negedge clk);
		in_w = 4'hD;
		inst_w = 3'b01;
	
		@(negedge clk);
		in_w = 4'hC;
		inst_w = 3'b01;

		@(negedge clk);
		in_w = 4'hB;
		inst_w = 3'b01;

		@(negedge clk);
		in_w = 4'hA;
		inst_w = 3'b01;
	
		@(negedge clk);
		in_w = 4'h9;
		inst_w = 3'b01;

		@(negedge clk);
		in_w = 4'h8;
		inst_w = 3'b01;
	
		@(negedge clk);
		in_w = 4'h1;
		inst_w = 3'b10;

		@(negedge clk);
		in_w = 4'h2;
		inst_w = 3'b00;
	
		@(negedge clk);
		in_w = 4'h3;

		@(negedge clk);
		in_w = 4'h4;
	
		@(negedge clk);
		in_w = 4'h5;

		@(negedge clk);
		in_w = 4'h6;

		@(negedge clk);
		in_w = 4'h7;

		@(negedge clk);
		in_w = 4'h8;

		@(negedge clk);
		in_w = 4'h9;

		$display("-------------------- Computation completed --------------------");
	end
endmodule
