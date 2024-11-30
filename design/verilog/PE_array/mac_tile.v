// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_tile (clk, out_s, in_w, out_e, in_n, inst_w, inst_e, reset);

parameter bw = 4;
parameter psum_bw = 16;

output [psum_bw-1:0] out_s;
input  [bw-1:0] in_w; 
output [bw-1:0] out_e; 
input  [2:0] inst_w;	// inst[2]:mode, inst[1]:execute, inst[0]: kernel loading
output [2:0] inst_e;
input  [psum_bw-1:0] in_n;
input  clk;
input  reset;

reg [2:0] inst_q;
reg [bw-1:0] a_q;
reg [bw-1:0] b_q;
reg [psum_bw-1:0] c_q;
reg load_ready_q;
wire [psum_bw-1:0] mac_out;

always @ (posedge clk  or negedge reset) begin
	if(!reset) begin
		a_q <= {bw{1'b0}};
		b_q <= {bw{1'b0}};
		inst_q <= 3'b000;
		c_q <= {psum_bw{1'b0}};
		load_ready_q <= 1'b1;
	end
	else begin
		inst_q[2:1] <= inst_w[2:1];

		if(inst_w[0] || inst_w[1]) begin
			a_q <= in_w;
		end

		if(inst_w[0] && load_ready_q) begin
			b_q <= in_w;
			load_ready_q <= 1'b0;
		end

		if(~load_ready_q) begin
			inst_q[0] <= inst_w;
		end

		if(inst_w[1]) begin
			c_q <= in_n;
		end
	end


end

assign inst_e = inst_q;
assign out_e = a_q;
assign out_s = mac_out;




mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
        .a(a_q), 
        .b(b_q),
        .c(c_q),
	.out(mac_out)
); 

endmodule
