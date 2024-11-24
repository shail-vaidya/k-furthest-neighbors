// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_row (clk, out_s, in_w, in_n, valid, inst_w, reset);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;

  input  clk, reset;
  output [psum_bw*col-1:0] out_s;
  output [col-1:0] valid;
  input  [bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
  input  [1:0] inst_w;
  input  [psum_bw*col-1:0] in_n;

  wire  [(col+1)*bw-1:0] temp;

  //My code
  wire	[(col+1)*2-1:0] inst_temp;

  assign temp[bw-1:0]   = in_w;
  assign inst_temp[1:0] = inst_w;

  genvar i;
  for (i=1; i < col+1 ; i=i+1) begin : col_num
      mac_tile #(.bw(bw), .psum_bw(psum_bw)) mac_tile_instance (
         .clk(clk),
         .reset(reset),
	 //bits[3:0] of W/X temp and keeps incrementing by 4 each tile
	 .in_w(temp[bw*i-1:bw*(i-1)]),
	 //bits[7:4] of W/X temp and keeps incrementing by 4 each tile
	 .out_e(temp[bw*(i+1)-1:bw*i]),
	 //bits[1:0] of inst_temp and keeps incrementing by 2 each tile
	 .inst_w(inst_temp[2*i-1:2*(i-1)]),
	 //bits[3:2] of inst_temp and keeps incrementing by 2 each tile
	 .inst_e(inst_temp[2*(i+1)-1:2*i]),
	 //block input given to row module, divided for each column/tile
	 .in_n(in_n[psum_bw*i-1:psum_bw*(i-1)]),
	 //block output of each row module, divided for each colummn/tile
	 .out_s(out_s[psum_bw*i-1:psum_bw*(i-1)])
 	);
	//Valid is indexed by column number
 	assign valid[i-1] = inst_temp[2*(i+1)-1];
  end

endmodule
