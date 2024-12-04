// Created by k-furthest-neighbors
// Please do not spread this code without permission 
`timescale 1ns/1ps

module core_tb;

parameter bw = 4;
parameter psum_bw = 16;
parameter len_kij = 9;
parameter len_onij = 16;
parameter col = 8;
parameter row = 8;
parameter len_nij = 27;

reg clk = 1;
reg reset = 1;

reg [1:0]  inst_w_q = 0; 
reg [bw*row-1:0] D_xmem_q = 0;
reg CEN0_xmem = 1;
reg WEN0_xmem = 1;
reg [7:0] A0_xmem = 0;
reg CEN1_xmem = 1;
reg [7:0] A1_xmem = 0;
reg CEN0_xmem_q = 1;
reg WEN0_xmem_q = 1;
reg [7:0] A0_xmem_q = 0;
reg CEN1_xmem_q = 1;
reg [7:0] A1_xmem_q = 0;
reg CEN_pmem = 1;
reg WEN_pmem = 1;
reg [8:0] A_pmem = 0;
reg CEN_pmem_q = 1;
reg WEN_pmem_q = 1;
reg [8:0] A_pmem_q = 0;
reg ofifo_rd_q = 0;
reg ififo_wr_q = 0;
reg ififo_rd_q = 0;
reg l0_rd_q = 0;
reg l0_wr_q = 0;
reg execute_q = 0;
reg execute_s1_q = 0;
reg execute_s2_q = 0;
reg load_q = 0;
reg load_s1_q = 0;
reg load_s2_q = 0;
reg mode_q = 0;
reg mode_s1_q = 0;
reg mode_s2_q = 0;
reg acc_q = 0;
reg acc = 0;
reg psum_bypass_q =0;
reg psum_bypass =0;
reg max_pool_en =0;
reg max_pool_en_q =0;
reg [1:0]  inst_w; 
reg [bw*row-1:0] D_xmem;
reg [psum_bw*col-1:0] answer;
reg ofifo_rd = 0;
reg ififo_wr;
reg ififo_rd;
reg l0_rd;
reg l0_wr;
reg mode;
reg execute;
reg load;
reg [8*30:1] stringvar;
reg [8*30:1] w_file_name;

wire [40:0] inst_q;
wire ofifo_valid;
wire [col*psum_bw-1:0] sfp_out;
wire l0_ready;
wire ififo_ready;

integer x_file, x_scan_file ; // file_handler
integer w_file, w_scan_file ; // file_handler
integer acc_file, acc_scan_file ; // file_handler
integer out_file, out_scan_file ; // file_handler
integer captured_data; 
integer t, i, j, k, kij, m, n;
integer error;


// ----------------------------------- Instruction Mapping ------------------------------------------ //

assign inst_q[40]     = max_pool_en_q;
assign inst_q[39] 	  = psum_bypass_q;
assign inst_q[38] 	  = acc_q;
assign inst_q[37] 	  = CEN_pmem_q;
assign inst_q[36] 	  = WEN_pmem_q;
assign inst_q[35:27] 	= A_pmem_q;
assign inst_q[26] 	  = CEN1_xmem_q;
assign inst_q[25:18] 	= A1_xmem_q;
assign inst_q[17]   	= CEN0_xmem_q;
assign inst_q[16] 	  = WEN0_xmem_q;
assign inst_q[15:8]  	= A0_xmem_q;
assign inst_q[7]  	  = ofifo_rd_q;
assign inst_q[6]  	  = ififo_wr_q;
assign inst_q[5]  	  = ififo_rd_q;
assign inst_q[4]  	  = l0_rd_q;
assign inst_q[3]  	  = l0_wr_q;
assign inst_q[2]  	  = mode_q; 
assign inst_q[1]  	  = execute_q; 
assign inst_q[0]  	  = load_q; 

core  #(.bw(bw), .col(col), .row(row)) core_instance (
	.clk(clk), 
	.inst(inst_q),
	.ofifo_valid(ofifo_valid),
        .D_xmem(D_xmem_q), 
        .sfp_out(sfp_out),
        .l0_ready (l0_ready),
        .ififo_ready  (ififo_ready), 
	.reset(reset));

always #0.5 clk = ~clk;

initial begin 

  inst_w   = 0; 
  D_xmem   = 0;
  CEN0_xmem = 1;
  WEN0_xmem = 1;
  A0_xmem   = 0;
  CEN1_xmem = 1;
  A1_xmem   = 0;
  ififo_wr = 0;
  ififo_rd = 0;
  l0_rd    = 0;
  l0_wr    = 0;
  mode     = 0;
  execute  = 0;
  load     = 0;

  $dumpfile("core_tb.vcd");
  $dumpvars(0,core_tb);


  //x_file = $fopen("output_stationary_activation.txt", "r");
  x_file = $fopen("OS_activation.txt", "r");
  // Following three lines are to remove the first three comment lines of the file
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);

  // -------------- Reset -------------- //
  #0.5 
  reset = 1;
  #10
  reset = 0;
  #2 
  //-----------------------------------

  // ----------------------------------- Activation data writing to memory ------------------------------------------ //
  for (t=0; t<len_nij; t=t+1) begin  
    #1 x_scan_file = $fscanf(x_file,"%32b", D_xmem); WEN0_xmem = 0; CEN0_xmem = 0; if (t>0) A0_xmem = A0_xmem + 1;   
  end

  #1 WEN0_xmem = 1;  CEN0_xmem = 1; A0_xmem = 0;
  #5 

  $fclose(x_file);
  //-----------------------------------------------------------------------------------------------------------------
  //End of Activation loading to SRAM



//The following would get consumed vertically by output columns:		 oc=7	   oc=6      oc=5      oc=4	 oc=3	   oc=2	     oc=1      oc=0
//1st  file_write of weights should be kij=0, ic=0(row) for all oc(col) values 	[col7row0, col6row0, col5row0, col4row0, col3row0, col2row0, col1row0, col0row0]
//2nd  file_write of weights should be kij=1, ic=0(row) for all oc(col) values	[col7row0, col6row0, col5row0, col4row0, col3row0, col2row0, col1row0, col0row0]
//...
//9th  file_write of weights should be kij=8, ic=0(row) for all oc(col) values	[col7row0, col6row0, col5row0, col4row0, col3row0, col2row0, col1row0, col0row0]
//10th file_write of weights should be kij=0, ic=1(row) for all oc(col) values	[col7row1, col6row1, col5row1, col4row1, col3row1, col2row1, col1row1, col0row1]
//11th file_write of weights should be kij=1, ic=1(row) for all oc(col) values	[col7row1, col6row1, col5row1, col4row1, col3row1, col2row1, col1row1, col0row1]
//...
//18th file_write of weights should be kij=8, ic=1(row) for all oc(col) values	[col7row1, col6row1, col5row1, col4row1, col3row1, col2row1, col1row1, col0row1]
//19th file_write of weights should be kij=0, ic=2(row) for all oc(col) values	[col7row2, col6row2, col5row2, col4row2, col3row2, col2row2, col1row2, col0row2]
//20th file_write of weights should be kij=1, ic=2(row) for all oc(col) values	[col7row2, col6row2, col5row2, col4row2, col3row2, col2row2, col1row2, col0row2]
//...
//27nd file_write of weights should be kij=8, ic=2(row) for all oc(col) values	[col7row2, col6row2, col5row2, col4row2, col3row2, col2row2, col1row2, col0row2]

  //w_file = $fopen("output_stationary_weight.txt", "r");
  w_file = $fopen("OS_weight.txt", "r");
  // Following three lines are to remove the first three comment lines of the file
  w_scan_file = $fscanf(w_file,"%s", captured_data);
  w_scan_file = $fscanf(w_file,"%s", captured_data);
  w_scan_file = $fscanf(w_file,"%s", captured_data);

  //---------------------------------- Kernel data writing to memory ------------------------------------------------- //
  A0_xmem = 8'b10000000;
  for (t=0; t<len_nij; t=t+1) begin
    #1 w_scan_file = $fscanf(w_file,"%32b", D_xmem); WEN0_xmem = 0; CEN0_xmem = 0; if (t>0) A0_xmem = A0_xmem + 1;  //WEN1_xmem is always 1
  end
  //------------------------------------------------------------------------------------------------------------------ //

  #1 WEN0_xmem = 1;  CEN0_xmem = 1; A0_xmem = 0;
  #1

  //End of Weight loading to SRAM


  // -------------------------------------------- Load and Execute --------------------------------------------------- //
  t = len_nij;
  A0_xmem = 8'h0;
  A1_xmem = 8'h80;

  while (t > 0) begin
    if(l0_ready & ififo_ready) begin
      #1;
      CEN0_xmem = 0;
      WEN0_xmem = 1;
      CEN1_xmem = 0;
	//WEN1_xmem is always 1
	//Enter Instruction for o_exec
      mode = 1;
      execute = 1;
      load = 0;
      if (t < len_nij) begin
        A0_xmem = A0_xmem + 1;
        A1_xmem = A1_xmem + 1;
      end
      t = t - 1;
    end
    else begin
    #1
      CEN0_xmem = 1;
      WEN0_xmem = 1;
    end
  end


  t = 16;
  while (t > 0) begin
    #1;
    //Enter shifting sequence
    mode = 1;
    execute = 0;
    load = 1;
    CEN0_xmem = 1;
    WEN0_xmem = 1;
    CEN1_xmem = 1;
    //WEN1_xmem is always 1
    
    t = t - 1;
  end
  
  #1;
  mode = 0;
  execute = 0;
  load = 0;
  
  //End of loading and execution
  
  // ------------------------------------- Comparing output pixels ---------------------------------------- //
  // -------------------------- Output pixels are rendered from bottom first ------------------------------ //

  //out_file = $fopen("output_stationary_out.txt", "r");  
  out_file = $fopen("OS_out.txt", "r");  
  out_scan_file = $fscanf(out_file,"%s", answer); 
  out_scan_file = $fscanf(out_file,"%s", answer); 
  out_scan_file = $fscanf(out_file,"%s", answer); 
  error = 0;
  $display("############ Verification Start during accumulation #############"); 

  n = 8+1;
  while (n>0) begin
    fork

      begin
	if (ofifo_valid & (n>1)) begin
	  #1;
	  $display("found ofifo_valid high. reading now");
      	  ofifo_rd = 1;
          max_pool_en = 1;
	end
	else if (ofifo_valid & (n==1)) begin
	  #1;
	  ofifo_rd = 0;
    max_pool_en = 0;
	end
      end

      begin
	if (ofifo_valid & (n<9)) begin
	  #1;
	  out_scan_file = $fscanf(out_file,"%128b", answer);
	  if (sfp_out == answer) begin
	    $display("%2d-th output featuremap Data matched! :D", n);
	    //$display("sfpout: %128b", sfp_out);
	    //$display("answer: %128b", answer);
	  end
	  else begin
	    $display("%2d-th output featuremap Data ERROR!!", n); 
	    $display("sfpout: %128b", sfp_out);
	    $display("answer: %128b", answer);
	    error = 1;
	  end
	end
      end

      begin
	if (ofifo_valid) begin
	  #1;
	  n = n-1;
	end
	else
	  #1;
      end

    join

  end

  #1;
  if (error == 0) begin
  	$display("############ No error detected ##############"); 
  	$display("########### Project Completed !! ############"); 
  end


#100 $finish;

end


always @ (posedge clk) begin
   inst_w_q   <= inst_w; 
   D_xmem_q   <= D_xmem;
   A0_xmem_q   <= A0_xmem;
   CEN0_xmem_q <= CEN0_xmem;
   WEN0_xmem_q <= WEN0_xmem;
   A1_xmem_q   <= A1_xmem;
   CEN1_xmem_q <= CEN1_xmem;
   A_pmem_q   <= A_pmem;
   CEN_pmem_q <= CEN_pmem;
   WEN_pmem_q <= WEN_pmem;
   ofifo_rd_q <= ofifo_rd;
   acc_q      <= acc;
   ififo_wr_q <= ififo_wr;
   ififo_rd_q <= ififo_rd;
   l0_rd_q    <= l0_rd;
   l0_wr_q    <= l0_wr ;
   psum_bypass_q <= psum_bypass;
   max_pool_en_q <= max_pool_en;

   mode_s1_q  <= mode;
   mode_s2_q  <= mode_s1_q;
   load_s1_q  <= load;
   load_s2_q  <= load_s1_q;
   execute_s1_q  <= execute;
   execute_s2_q  <= execute_s1_q;

   mode_q     <= mode_s2_q;
   execute_q  <= execute_s2_q;
   load_q     <= load_s2_q;
end

always @(negedge clk ) begin
  l0_wr <= ~CEN0_xmem_q && WEN0_xmem_q;
  ififo_wr <= ~CEN1_xmem_q;
  l0_rd <= l0_wr;
  ififo_rd <= ififo_wr;
end

endmodule
