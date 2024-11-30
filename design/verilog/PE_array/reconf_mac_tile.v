// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_tile (clk, out_s, in_w, out_e, in_n, inst_w, inst_e, reset);

parameter bw = 4;
parameter psum_bw = 16;

output [psum_bw-1:0] out_s;
input  [bw-1:0] in_w; 
output [bw-1:0] out_e; 
input  [2:0] inst_w;	// inst[1]:execute, inst[0]: kernel loading
output [2:0] inst_e;
input  [psum_bw-1:0] in_n;
input  clk;
input  reset;

reg [2:0] inst_q;
reg [bw-1:0] a_q;
reg [bw-1:0] b_q;
reg [psum_bw-1:0] c_q;
reg [psum_bw-1:0] c_pipe_q;
reg load_ready_q;
reg shift_ready_q;
wire [psum_bw-1:0] mac_out;

// ---------------------------------
//       Instruction Mapping
// ---------------------------------
// Value	|	Description
// 3'b000	|	W_IDLE
// 3'b001	|	W_LOAD
// 3'b010	|	W_EXEC
// 3'b011	|	NOT_USED
// 3'b100	|	IDLE
// 3'b101	|	O_SHIFT
// 3'b110	|	O_EXEC
// 3'b111	|	RESET
// ----------------------------------
always @ (posedge clk or negedge reset) begin
	if(!reset) begin
		a_q 			<= {bw{1'b0}};
		b_q 			<= {bw{1'b0}};
		inst_q 			<= 3'b000;
		c_q 			<= {psum_bw{1'b0}};
		c_pipe_q 		<= {psum_bw{1'b0}};
		load_ready_q 	<= 1'b1;
		shift_ready_q 	<= 1'b1;
	end
	else begin
		inst_q[2:1] <= inst_w[2:1]; // Always flop the lower 2bits of the instruction

		if (~inst_w[2]) begin	// Weight Stationary
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
		else begin	// Output Stationary
			inst_q[0] <= inst_w[0];
			if(inst_w[1:0] == 2'b10) begin // O_EXEC
				a_q <= in_w;
				b_q <= in_n[3:0];
			end
			else if(inst_w[1:0] == 2'b01) begin // O_SHIFT
				c_pipe_q <= in_n;
				if (shift_ready_q) begin
					shift_ready_q <= 1'b0;
				end
				else begin
					c_q <= c_pipe_q;
				end
			end
			else if (inst_w[1:0] == 2'b11) begin // RESET
				a_q 		<= {bw{1'b0}};
				b_q 		<= {bw{1'b0}};
				c_q 		<= {psum_bw{1'b0}};
				c_pipe_q 	<= {psum_bw{1'b0}};
				load_ready_q <= 1'b1;
				shift_ready_q <= 1'b1;
			end

		end
		if (inst_q == 3'b110) begin
			c_q <= mac_out;
		end
	end


end

assign inst_e = inst_q;
assign out_e = a_q;

//     out_s = Output_Stationary ? (O_SHIFT ? c_q : b_q with padding) : mac_out (weight stationary)
assign out_s = inst_q[2] ? ((inst_q[1:0]==2'b01) ? c_q : {{(psum_bw-bw){1'b0}},b_q}) : mac_out;	
											
mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
        .a(a_q), 
        .b(b_q),
        .c(c_q),
	.out(mac_out)
); 

endmodule
