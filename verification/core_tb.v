// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
`timescale 1ns/1ps

module core_tb;

parameter bw = 4;
parameter psum_bw = 16;
parameter len_kij = 9;
parameter len_onij = 16;
parameter col = 8;
parameter row = 8;
parameter len_nij = 1024;

reg clk = 1;
reg reset = 1;
//FIXME: Why was this updated to 50?
wire [49:0] inst_q; 
reg [1:0]  inst_w_q = 0; 
reg [bw*row-1:0] D_xmem_q = 0;
reg CEN0_xmem = 1;
reg WEN0_xmem = 1;
reg [10:0] A0_xmem = 0;
reg CEN1_xmem = 1;
reg [10:0] A1_xmem = 0;
reg CEN0_xmem_q = 1;
reg WEN0_xmem_q = 1;
reg [10:0] A0_xmem_q = 0;
reg CEN1_xmem_q = 1;
reg [10:0] A1_xmem_q = 0;
reg CEN_pmem = 1;
reg WEN_pmem = 1;
reg [10:0] A_pmem = 0;
reg CEN_pmem_q = 1;
reg WEN_pmem_q = 1;
reg [10:0] A_pmem_q = 0;
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

reg [1:0]  inst_w; 
reg [bw*row-1:0] D_xmem;
reg [psum_bw*col-1:0] answer;



reg ififo_wr;
reg ififo_rd;
reg l0_rd;
reg l0_wr;
reg mode;
reg execute;
reg load;
reg [8*30:1] stringvar;
reg [8*30:1] w_file_name;
wire ofifo_valid;
wire [col*psum_bw-1:0] sfp_out;
wire l0_ready;
wire ififo_ready;
wire ofifo_rd;

integer x_file, x_scan_file ; // file_handler
integer w_file, w_scan_file ; // file_handler
integer acc_file, acc_scan_file ; // file_handler
integer out_file, out_scan_file ; // file_handler
integer captured_data; 
integer t, i, j, k, kij, m;
integer error;

//  inst[49]      = acc_q;
//  inst[48]      = CEN_pmem_q;
//  inst[47]      = WEN_pmem_q;
//  inst[46:33]   = A_pmem_q;
//  inst[32]      = CEN1_xmem_q;
//  inst[31:21]    = A1_xmem_q;
//  inst[20]      = CEN0_xmem_q;
//  inst[19]      = WEN0_xmem_q;
//  inst[18:8]    = A0_xmem_q;
//  inst[7]       = ofifo_rd_q;
//  inst[6]       = ififo_wr_q;
//  inst[5]       = ififo_rd_q;
//  inst[4]       = l0_rd_q;
//  inst[3]       = l0_wr_q;
//  inst[2]       = mode_q
//  inst[1]       = execute_q; 
//  inst[0]       = load_q;

assign inst_q[49] 	  = acc_q;
assign inst_q[48] 	  = CEN_pmem_q;
assign inst_q[47] 	  = WEN_pmem_q;
assign inst_q[46:33] 	= A_pmem_q;
assign inst_q[32] 	  = CEN1_xmem_q;
assign inst_q[31:21] 	= A1_xmem_q;
assign inst_q[20]   	= CEN0_xmem_q;
assign inst_q[19]   	= WEN0_xmem_q;
assign inst_q[18:8] 	= A0_xmem_q;
assign inst_q[7]  	  = ofifo_rd_q;
assign inst_q[6]  	  = ififo_wr_q;
assign inst_q[5]  	  = ififo_rd_q;
assign inst_q[4]  	  = l0_rd_q;
assign inst_q[3]  	  = l0_wr_q;
assign inst_q[2]  	  = mode_q; 
assign inst_q[1]  	  = execute_q; 
assign inst_q[0]  	  = load_q;
assign ofifo_rd       = !CEN_pmem && !WEN_pmem;


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
  //ofifo_rd = 0;
  ififo_wr = 0;
  ififo_rd = 0;
  l0_rd    = 0;
  l0_wr    = 0;
  mode     = 0;
  execute  = 0;
  load     = 0;

  $dumpfile("core_tb.vcd");
  $dumpvars(0,core_tb);

  //x_file = $fopen("activation_tile0.txt", "r");
  x_file = $fopen("activation.txt", "r");
  // Following three lines are to remove the first three comment lines of the file
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);

  //-------------- Reset --------------
  #0.5 
  reset = 1;
  #10
  reset = 0;
  #2 
  //-----------------------------------

  //----------------------------------- Activation data writing to memory ------------------------------------------
  for (t=0; t<len_nij; t=t+1) begin  
    #1 x_scan_file = $fscanf(x_file,"%32b", D_xmem); WEN0_xmem = 0; CEN0_xmem = 0; if (t>0) A0_xmem = A0_xmem + 1;   
  end

  #1 WEN0_xmem = 1;  CEN0_xmem = 1; A0_xmem = 0;
  #5 

  $fclose(x_file);
  //-----------------------------------------------------------------------------------------------------------------


  for (kij=0; kij<2; kij=kij+1) begin  // Weight loading to SRAM loop

    case(kij)
     0: w_file_name = "weight.txt"; //all ic and oc; 32 bits = 4*(rows)
     1: w_file_name = "weight.txt"; //all ic and oc; 32 bits = 4*(rows)
  //   0: w_file_name = "weight_itile0_otile0_kij0.txt"; //all ic and oc; 32 bits = 4*(rows)
  //   1: w_file_name = "weight_itile0_otile0_kij1.txt";
  //   2: w_file_name = "weight_itile0_otile0_kij2.txt";
  //   3: w_file_name = "weight_itile0_otile0_kij3.txt";
  //   4: w_file_name = "weight_itile0_otile0_kij4.txt";
  //   5: w_file_name = "weight_itile0_otile0_kij5.txt";
  //   6: w_file_name = "weight_itile0_otile0_kij6.txt";
  //   7: w_file_name = "weight_itile0_otile0_kij7.txt";
  //   8: w_file_name = "weight_itile0_otile0_kij8.txt";
    endcase
    

    w_file = $fopen(w_file_name, "r");
    // Following three lines are to remove the first three comment lines of the file
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);

    //---------------------------------- Kernel data writing to memory --------------------------------------------------

    for (t=0; t<col; t=t+1) begin  //iterating over all cols (oc)
      #1 w_scan_file = $fscanf(w_file,"%32b", D_xmem); WEN0_xmem = 0; CEN0_xmem = 0; 
      if (t==0) begin 
        A0_xmem = 11'b10000000000 + kij*11'h8;
      end
      else if (t>0) A0_xmem = A0_xmem + 1;  
    end
    //------------------------------------------------------------------------------------------------------------------

  end // end of Weight loading to SRAM loop

  #1 WEN0_xmem = 1;  CEN0_xmem = 1;
  #1


  fork
    begin
      for (kij=0; kij<2; kij=kij+1) begin 
        t = col;
        while (t > 0) begin
          if(l0_ready) begin
            #1;
            CEN0_xmem = 0;
            WEN0_xmem = 1;
            if (t == col)
              A0_xmem = 11'h400 + kij*11'h8;
            else if (t < col) begin
              A0_xmem = A0_xmem + 1;
            end
            mode = 0;
            execute = 0;
            load = 1;
            t = t - 1;
          end
          else begin
            #1;
            CEN0_xmem = 1;
            WEN0_xmem = 1;
          end
        end
        t=len_nij;
        while (t > 0) begin
          if(l0_ready) begin
            #1;
            CEN0_xmem = 0;
            WEN0_xmem = 1;
            if (t == len_nij)
              A0_xmem = 11'h0;
            else if (t < len_nij) begin
              A0_xmem = A0_xmem + 1;
            end
            load = 0;
            execute = 1;
            t = t - 1;
          end
          else begin
            #1;
            CEN0_xmem = 1;
            WEN0_xmem = 1;
          end
        end
        #1;
        load = 1;
        execute = 1;
        mode = 1;
        CEN0_xmem = 1;
        WEN0_xmem = 1;
      end
      #1;
      load = 0;
      execute = 0;
      mode = 0; 
      end
    begin
        m=len_nij*2;
        //m=len_nij*len_kij; //1024*9
        while (m > 0) begin
          if(ofifo_valid) begin
            #1;
            CEN_pmem = 0;
            WEN_pmem = 0;
            if (m < len_nij * len_kij) begin
              A_pmem = A_pmem + 1;
            end
            m=m-1;
          end
          else begin
            #1;
            CEN_pmem = 1;
            WEN_pmem = 1; 
          end
        end 
    end
  join
  
        
    //////// OFIFO READ ////////
    // Ideally, OFIFO should be read while execution, but we have enough ofifo
    // depth so we can fetch out after execution.
    //...
    /////////////////////////////////////




//COMMENTING OUT BELOW TB FOR NOW//


//  ////////// Accumulation /////////
//  out_file = $fopen("out.txt", "r");  
//
//  // Following three lines are to remove the first three comment lines of the file
//  out_scan_file = $fscanf(out_file,"%s", answer); 
//  out_scan_file = $fscanf(out_file,"%s", answer); 
//  out_scan_file = $fscanf(out_file,"%s", answer); 
//
//  error = 0;
//
//
//
//  $display("############ Verification Start during accumulation #############"); 
//
//  for (i=0; i<len_onij+1; i=i+1) begin 
//
//    #0.5 clk = 1'b0; 
//    #0.5 clk = 1'b1; 
//
//    if (i>0) begin
//     out_scan_file = $fscanf(out_file,"%128b", answer); // reading from out file to answer
//       if (sfp_out == answer)
//         $display("%2d-th output featuremap Data matched! :D", i); 
//       else begin
//         $display("%2d-th output featuremap Data ERROR!!", i); 
//         $display("sfpout: %128b", sfp_out);
//         $display("answer: %128b", answer);
//         error = 1;
//       end
//    end
//   
// 
//    #0.5 clk = 1'b0; reset = 1;
//    #0.5 clk = 1'b1;  
//    #0.5 clk = 1'b0; reset = 0; 
//    #0.5 clk = 1'b1;  
//
//    for (j=0; j<len_kij+1; j=j+1) begin 
//
//      #0.5 clk = 1'b0;   
//        if (j<len_kij) begin CEN_pmem = 0; WEN_pmem = 1; acc_scan_file = $fscanf(acc_file,"%11b", A_pmem); end
//                       else  begin CEN_pmem = 1; WEN_pmem = 1; end
//
//        if (j>0)  acc = 1;  
//      #0.5 clk = 1'b1;   
//    end
//
//    #0.5 clk = 1'b0; acc = 0;
//    #0.5 clk = 1'b1; 
//  end
//
//
//  if (error == 0) begin
//  	$display("############ No error detected ##############"); 
//  	$display("########### Project Completed !! ############"); 
//
//  end
//
//  $fclose(acc_file);
//  //////////////////////////////////
//
//  for (t=0; t<10; t=t+1) begin  
//    #0.5 clk = 1'b0;  
//    #0.5 clk = 1'b1;  
//  end
//
#100 $finish;
//
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
