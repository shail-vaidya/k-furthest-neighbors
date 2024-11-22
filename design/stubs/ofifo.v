module ofifo (clk, in, out, rd, wr, o_full, reset, o_ready, o_valid);

  parameter col  = 8;
  parameter bw = 4;

  input  clk;
  input  [col-1:0] wr;
  input  rd;
  input  reset;
  input  [col*bw-1:0] in;
  output [col*bw-1:0] out;
  output o_full;
  output o_ready;
  output o_valid;

  assign out = {col*bw{1'b0}};
  assign o_full = 1'b0;
  assign o_ready = 1'b1;    
  assign o_valid = 1'b0;


endmodule