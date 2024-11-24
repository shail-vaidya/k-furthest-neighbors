// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_array (clk, reset, out_s, in_w, in_n, inst_w, valid);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;

  input  clk, reset;
  output [psum_bw*col-1:0] out_s;
  input  [row*bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
  input  [1:0] inst_w;
  input  [psum_bw*col-1:0] in_n;
  output [col-1:0] valid;

  //My code begins
  reg [(row+1)*2-1:0] inst_temp;
  wire	[(row+1)*psum_bw*col-1:0] in_n_temp;

  //in_n gets populated from first psum_bw*col portion of temp register
  assign in_n_temp[psum_bw*col-1:0] = in_n;
  //out_s gets generated from last psum_bw*col portion of temp register
  assign out_s = in_n_temp[(row+1)*psum_bw*col-1:row*psum_bw*col];

  //Give a staggered input to each row
  always @ (posedge clk) begin
	  if (reset) begin
		  inst_temp <= 0;
	  end else begin
		  inst_temp <= inst_temp << 2 | inst_w;
	  end
  end
  
  genvar i;		
  for (i=1; i < row+1 ; i=i+1) begin : row_num
	if (i<row) begin
		mac_row #(.bw(bw), .psum_bw(psum_bw)) mac_row_instance (
	      	  .clk(clk),
		  //bits[31*col:16*col] of in_n_temp and increments by 16*col for each row
	      	  .out_s(in_n_temp[(i+1)*psum_bw*col-1:i*psum_bw*col]), 
		  //block in_w input given to array, divided for each row
	      	  .in_w(in_w[bw*i-1:bw*(i-1)]), 
		  //bits[16*col:0] of in_n_temp and increments by 16*col for each row
	     	  .in_n(in_n_temp[psum_bw*i*col-1:psum_bw*col*(i-1)]),
		  //Leave this output hanging for each non terminal row
	      	  .valid(), 
		  //bits[1:0] of inst_temp and increments by 2 each row
	      	  .inst_w(inst_temp[2*i-1:2*(i-1)]), 
	      	  .reset(reset)
      		);
	end
	if (i==row) begin
		mac_row #(.bw(bw), .psum_bw(psum_bw)) mac_row_instance (
	      	  .clk(clk),
		  //bits[31*col:16*col] of in_n_temp and increments by 16*col for each row
	      	  .out_s(in_n_temp[(i+1)*psum_bw*col-1:i*psum_bw*col]), 
		  //block in_w input given to array, divided for each row
	      	  .in_w(in_w[bw*i-1:bw*(i-1)]), 
		  //bits[16*col:0] of in_n_temp and increments by 16*col for each row
	     	  .in_n(in_n_temp[psum_bw*i*col-1:psum_bw*col*(i-1)]),
		  //Only connect this output of the terminal row to output valid
	      	  .valid(valid), 
		  //bits[1:0] of inst_temp and increments by 2 each row
	      	  .inst_w(inst_temp[2*i-1:2*(i-1)]), 
	      	  .reset(reset)
      		);
	end
  end


endmodule
