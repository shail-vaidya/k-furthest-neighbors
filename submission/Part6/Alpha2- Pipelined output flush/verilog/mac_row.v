// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_row (clk, out_s, in_w, in_n, valid, inst_w, in_w_zero, in_n_zero, out_s_zero, reset);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;

  input  clk, reset;
  output [psum_bw*col-1:0] out_s;
  output [col-1:0] valid;
  input  [bw-1:0] in_w; 
  input  [2:0] inst_w;	// inst[1]:execute, inst[0]: kernel loading
  input  in_w_zero;
  input  [col-1:0] in_n_zero;
  output [col-1:0] out_s_zero;
  input  [psum_bw*col-1:0] in_n;

  wire  [(col+1)*bw-1:0] temp;
  wire  [(col+1)*3-1:0] temp_inst;
  wire  [col:0] temp_w_zero;
  wire  [col:0] temp_n_zero;

  assign temp[bw-1:0]   = in_w;
  assign temp_inst[2:0]   = inst_w;
  assign temp_w_zero[0] = in_w_zero;

  genvar i;
  generate
    for (i=1; i < col+1 ; i=i+1) begin : mac_row_col_num
      mac_tile #(.bw(bw), .psum_bw(psum_bw)) mac_tile_instance (
         .clk(clk),
         .reset(reset),
	       .in_w(temp[bw*i-1:bw*(i-1)]),
	       .out_e(temp[bw*(i+1)-1:bw*i]),
	       .inst_w(temp_inst[3*i-1:3*(i-1)]),
	       .inst_e(temp_inst[3*(i+1)-1:3*i]),
	       .in_n(in_n[psum_bw*i-1:psum_bw*(i-1)]),
	       .out_s(out_s[psum_bw*i-1:psum_bw*(i-1)]),
         .in_w_zero(temp_w_zero[i-1]),
         .out_e_zero(temp_w_zero[i]),
         .in_n_zero(in_n_zero[i-1]),
         .out_s_zero(out_s_zero[i-1])
    	);
      // temp_inst[5:3] --> 101 or 0101
	    assign valid[i-1] = (temp_inst[3*(i+1) - 1] && !(temp_inst[3*(i+1) - 2]) && temp_inst[3*(i+1) - 3]) || ((!temp_inst[3*(i+1) - 1]) && temp_inst[3*(i+1) - 2] && (!temp_inst[3*(i+1) - 3]));
    end
  endgenerate

endmodule
