module xmem_256x32 (CLK, D0, D1, Q0, Q1, CEN0, CEN1, WEN0, WEN1, A0, A1);

  input  CLK;
  input  WEN0;
  input  WEN1;
  input  CEN0;
  input  CEN1;
  input  [31:0] D0;
  input  [31:0] D1;
  input  [7:0] A0;
  input  [7:0] A1;
  output [31:0] Q0;
  output [31:0] Q1;
  parameter num = 256;

  reg [31:0] memory [num-1:0];
  reg [7:0] add0_q;
  reg [7:0] add1_q;

  assign Q0 = memory[add0_q];
  assign Q1 = memory[add1_q];

  always @ (posedge CLK) begin

   if (!CEN0 && WEN0) // read port0
      add0_q <= A0;
   if (!CEN0 && !WEN0) // write port0
      memory[A0] <= D0; 

   if (!CEN1 && WEN1) // read port0
      add1_q <= A1;
   if (!CEN1 && !WEN1) // write port0
      memory[A1] <= D1; 

  end

endmodule