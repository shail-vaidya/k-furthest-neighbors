// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_tile (clk, out_s, in_w, out_e, in_n, inst_w, inst_e, reset);

parameter bw = 4;
parameter psum_bw = 16;

input  [bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
input  [1:0] inst_w;
input  [psum_bw-1:0] in_n;

output [bw-1:0] out_e; 
output [psum_bw-1:0] out_s;
output [1:0] inst_e;

input  clk;
input  reset;


reg [bw-1:0] a_q,b_q;
reg [psum_bw-1:0] c_q;
reg [1:0] inst_q;
reg load_ready_q;

wire [psum_bw-1:0] mac_out;

always @(posedge clk or posedge reset) begin
	if(reset) begin
		inst_q <= 2'b0;
		load_ready_q <= 1'b1;
		a_q <= 0;
		b_q <= 0;
		c_q <= 0;

	end
	else begin
		inst_q[1] <= inst_w[1];
		c_q <= in_n; //Psum

		if (inst_w[0] == 1 && load_ready_q==1'b1)begin
			b_q <= in_w; // Weight
			load_ready_q <= 1'b0;
		end
		else if(inst_w[0] == 1 && load_ready_q==1'b0) begin
			inst_q[0] <= inst_w[0]; // Passing weight, if kernel loading is occuring
			a_q <= in_w;
		end

		else if((inst_w[0] == 1 || inst_w[1] ==1) && load_ready_q==0)begin
			a_q <= in_w; // Activation 
		end

	end
end



mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
        .a(a_q), 
        .b(b_q),
        .c(c_q),
	.out(mac_out)
); 

assign out_e = a_q; // Transfer activation/weight to west tile
assign inst_e = inst_q;  // Transfer instr to west tile
assign out_s = mac_out;

endmodule
