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
  
  wire  [(row+1)*bw-1:0] temp;
  wire  [(row+1)*(col)*psum_bw-1:0] temp_out_s;
  wire  [row*col-1:0] temp_valid;
  	
  wire [(row*2)-1:0] ins_w_temp;
  reg [(row*2)-1:0] ins_w_r;

  assign temp[bw-1:0]   = in_w;
  assign temp_out_s[(col*psum_bw)-1:0]   = in_n;

  genvar i;
  generate
  
  for (i=1; i < row+1 ; i=i+1) begin : array_row_num
      mac_row #(.bw(bw), .psum_bw(psum_bw), .col(col)) mac_row_instance (
	    .clk(clk), 
	    .reset(reset),
	    .out_s(temp_out_s[(i+1)*psum_bw*col-1:(i)*psum_bw*col]),
	    .in_w(in_w[(i*bw)-1:(i-1)*bw]), 
    	.inst_w(ins_w_temp[(2*i)-1:2*(i-1)]), 
	    .valid(temp_valid[row*i-1:row*(i-1)]),  
    	.in_n(temp_out_s[i*psum_bw*col-1:(i-1)*psum_bw*col])
      );
  end

  endgenerate

  assign out_s = temp_out_s[(row)*psum_bw*col-1:(row-1)*psum_bw*col];
  assign valid = temp_valid[row*col-1:row*(col-1)];

   // inst_w flows to row0 to row7
   // Assigning wires to reg outputs to connect to row
  genvar k;
  for(k=1;k<row+1;k=k+1) begin
	assign ins_w_temp[(2*k)-1:2*(k-1)] = ins_w_r[(2*k)-1:2*(k-1)];			
  end

   // Propogating down the flops
  integer j;
  always @ (posedge clk) begin
	  if(reset) begin
		ins_w_r <= 0;
	  end
	  else begin
		ins_w_r[1:0] <= inst_w;		
		for(j=0;j<=row-2;j=j+1) begin
			ins_w_r[(j*2)+3] <= ins_w_r[(j*2)+1];			
			ins_w_r[(j*2)+2] <= ins_w_r[j*2];			
		end
	  end
  end


endmodule
