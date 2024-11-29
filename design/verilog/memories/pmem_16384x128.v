module pmem_16384x128 (CLK, D, Q, CEN, WEN, A);

  input  CLK;
  input  WEN;
  input  CEN;
  input  [127:0] D;
  input  [13:0] A;
  output [127:0] Q;
  parameter num = 16384;

  reg [127:0] memory [num-1:0];
  reg [13:0] add_q;
  assign Q = memory[add_q];

  always @ (posedge CLK) begin

   if (!CEN && WEN) // read 
      add_q <= A;
   if (!CEN && !WEN) // write
      memory[A] <= D; 

  end

endmodule