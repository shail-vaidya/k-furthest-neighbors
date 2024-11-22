//********************************************************************
// The corelet module is the synthesizable component of the project
//
// Has 5 main components
// 1. 2D PE Array
// 2. L0
// 3. IFIFO
// 4. OFIFO
// 5. SFP
//*********************************************************************

module corelet #(
    parameter bw = 4,
    parameter psum_bw = 16,
    parameter col = 8,
    parameter row = 8
) (
    // Common Ports
    input   clk,
    input   reset,
    // PE Array Ports
    input   in_n,
    input   in_w,
    input   inst_w,
    // OFIFO Ports
    input   ofifo_rd,
    output  ofifo_valid,
    // L0 Ports
    input   l0_rd,
    input   l0_wr,
    // IFIFO Ports
    input   ififo_rd,
    input   ififo_wr,
    // SFP Ports
    output  sfu_out
);

//*************************************************************
//                  PE Array Instance
//*************************************************************
mac_array #(
    .bw (bw),
    .psum_bw (psum_bw),
    .col (col),
    .row (row)
) mac_array_inst (
    .clk    (),     //TODO     
    .reset  (),     //TODO
    .out_s  (),     //TODO
    .in_n   (),     //TODO
    .in_w   (),     //TODO
    .inst_w (),     //TODO
    .valid  ()      //TODO
);

//*************************************************************
//                  L0 Instance
//*************************************************************
l0 #(
    .bw     (bw),
    .row    (row)
) l0_inst (
    .clk        (clk),
    .reset      (reset),
    .wr         (l0_wr),
    .rd         (l0_rd),
    .in         (),     //TODO
    .out        (),     //TODO
    .o_full     (),     //TODO
    .o_ready    ()      //TODO
);

//*************************************************************
//                  IFIFO Instance
//*************************************************************
l0 #(
    .bw     (bw),
    .row    (col)
) ififo_inst (
    .clk        (clk),
    .reset      (reset),
    .wr         (ififo_wr),
    .rd         (ififo_rd),
    .in         (),     //TODO
    .out        (),     //TODO
    .o_full     (),     //TODO
    .o_ready    ()      //TODO
);

//*************************************************************
//                  OFIFO Instance
//*************************************************************
ofifo #(
    .bw     (bw),
    .col    (col)
) ofifo_inst (
    .clk        (clk),
    .reset      (reset),
    .wr         (),         //TODO
    .rd         (ofifo_rd),
    .in         (),         //TODO
    .out        (),         //TODO
    .o_full     (),         //TODO
    .o_ready    (),         //TODO
    .o_valid    (ofifo_valid)
);


endmodule

