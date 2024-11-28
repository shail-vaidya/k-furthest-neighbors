// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_array (clk, reset, out_s, in_w, in_n, inst_w, valid);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;

  input  clk, reset;
  output [psum_bw*col-1:0] out_s;
  input  [row*bw-1:0] in_w;
  input  [2:0] inst_w;  	// inst[2]:mode, inst[1]:execute, inst[0]: kernel loading
  input  [psum_bw*col-1:0] in_n;
  output [col-1:0] valid;

  wire [row*col-1:0] temp_valid;	// Wires for connecting the valid signals of each row
  wire [psum_bw*col*(row+1)-1:0] temp;
  wire [3*row-1:0] temp_inst_in; 	// Wires to connect to input of temp_inst_q registers
  wire [3*row-1:0] temp_inst_out;	// Wires to connect to output of temp_inst_q registers
  genvar i;
  for (i=1; i < row+1 ; i=i+1) begin : row_num
      mac_row #(.bw(bw), .psum_bw(psum_bw)) mac_row_instance (
      	.clk (clk),
      	.reset (reset),
	      .inst_w(temp_inst_out[3*i-1:3*(i-1)]),
	      .in_w(in_w[bw*i-1:bw*(i-1)]),
	      .in_n(temp[psum_bw*col*i-1:psum_bw*col*(i-1)]),
	      .out_s(temp[psum_bw*col*(i+1)-1:psum_bw*col*i]),
	      .valid(temp_valid[col*i-1:col*(i-1)])
      );
  end


  assign out_s = temp[psum_bw*col*(row+1)-1:psum_bw*col*(row)];	// Taking out_s of the last row as the final outputs of the mac_array 

  assign temp[psum_bw*col*1-1:psum_bw*col*0] = in_n[15:0];
  assign valid = temp_valid[row*col-1:(row-1)*col];		// Taking valids of the last row as the final valids for the columns of mac_array


  // ------------------------------------------------------------------------------------------------------------------------------------------------
  // Note: The below code might look complicated but is implemented in
  // order to maintain the parameterization of mac_array and not hard_code any
  // of the rows/column numbers

  reg  [3*row-1:0] temp_inst_q;		// Registers to pipe intructions from north to south for rows 	
  					// Note: temp_inst_q[1:0] not used as first row gets direct instruction
					


  always @ (posedge clk) begin
   // inst_w flows to row0 to row7
  	if(reset) begin
		temp_inst_q <= {3*(row-1){1'b0}};		// Initialing all the instruction pipe registers to 0.
	end
	else begin
		temp_inst_q <= temp_inst_in;			// Connecting all the input wires to temp_inst_q
	end
  end

  assign temp_inst_out[2:0] = inst_w[2:0];		// Connecting first row instruction directly.	
  assign temp_inst_out[3*row-1:2] = temp_inst_q[3*row-1:2];	// Connecting all the outputs of temp_inst_q to wires. All except [1:0] as the first row gets direct instr.
  
  genvar j;
  for (j=1; j < row ; j=j+1) begin
	  assign temp_inst_in[3*(j+1)-1:3*j] = temp_inst_out[3*j-1:3*(j-1)];	//Connecting output wire of temp_inst_q to next pipe's input wire
  end


endmodule
