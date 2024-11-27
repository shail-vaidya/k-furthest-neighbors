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
    input                       clk,
    input                       reset,
    // PE Array Ports
    input   [2:0]               inst_w,
    // OFIFO Ports
    input                       ofifo_rd,
    output                      ofifo_valid,
    output  [psum_bw*col-1:0]   ofifo_rdata,
    // L0 Ports
    input                       l0_rd,
    input                       l0_wr,
    input   [bw*row-1:0]        l0_wdata,
    // IFIFO Ports
    input                       ififo_rd,
    input                       ififo_wr,
    input   [bw*row-1:0]        ififo_wdata,
    // SFP Ports
    output  [psum_bw*col-1:0]        sfp_out
);

//*************************************************************
//                             Wires
//*************************************************************
wire [col-1:0]          ofifo_wr;
wire [psum_bw*col-1:0]  ofifo_wdata;
wire [bw*col-1:0]       ififo_rdata;
wire [psum_bw*col-1:0]  in_n;
wire [bw*row-1:0]       l0_rdata;

//*************************************************************
//                      Stubbing (To be removed)
//*************************************************************
assign sfp_out = {psum_bw*col{1'b0}};

//*************************************************************
//                      Misc  Logic
//*************************************************************
genvar i;
    for (i=1; i < col ; i=i+1) begin
        assign in_n[psum_bw*i+bw-1:psum_bw*i] = ififo_rdata[bw*(i+1)-1:bw*i];
    end

//*************************************************************
//                      PE Array Instance
//*************************************************************
mac_array #(
    .bw (bw),
    .psum_bw (psum_bw),
    .col (col),
    .row (row)
) mac_array_inst (
    .clk    (clk),
    .reset  (reset),
    .out_s  (ofifo_wdata),
    .in_n   (in_n),
    .in_w   (l0_rdata),
    .inst_w (inst_w),
    .valid  (ofifo_wr)
);

//*************************************************************
//                  L0 Instance
//*************************************************************
l0 #(
    .bw         (bw),
    .row        (row)
) l0_inst (
    .clk        (clk),
    .reset      (reset),
    .wr         (l0_wr),
    .rd         (l0_rd),
    .in         (l0_wdata),
    .out        (l0_rdata),
    .o_full     (),             // Unused
    .o_ready    ()              // Unused
);

//*************************************************************
//                  IFIFO Instance
//*************************************************************
l0 #(
    .bw         (bw),
    .row        (col)
) ififo_inst (
    .clk        (clk),
    .reset      (reset),
    .wr         (ififo_wr),
    .rd         (ififo_rd),
    .in         (ififo_wdata),
    .out        (ififo_rdata),
    .o_full     (),             // Unused
    .o_ready    ()              // Unused
);

//*************************************************************
//                  OFIFO Instance
//*************************************************************
ofifo #(
    .bw     (psum_bw),
    .col    (col)
) ofifo_inst (
    .clk        (clk),
    .reset      (reset),
    .wr         (ofifo_wr),
    .rd         (ofifo_rd),
    .in         (ofifo_wdata),
    .out        (ofifo_rdata),
    .o_valid    (ofifo_valid),
    .o_full     (),             // Unused
    .o_ready    ()              // Unused
);

//*************************************************************
//                  Special Function Processor (To be added)
//*************************************************************

endmodule

