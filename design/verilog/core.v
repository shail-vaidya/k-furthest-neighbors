//***************************************************************************
// Top Level Design Module to be connected to Testbench as DUT

// Consists of three main components
// 1. Corelet.v (All the synthesizable logic)
// 2. SRAM0 (For activation and weights)
// 3. SRAM1 (For psum storing)
//***************************************************************************
module core #(
    parameter bw = 4,
    parameter psum_bw = 16,
    parameter col = 8,
    parameter row = 8
) (
    input                       clk,
    input                       reset,
    input                       ofifo_valid,
    input   [bw*row-1:0]        D_xmem,
    input   [34:0]              inst,
    output  [psum_bw*col-1:0]   sfp_out
);

//***********************************************
//        Instruction Mapping
//***********************************************
//  inst[34]      = acc_q;
//  inst[33]      = CEN_pmem_q;
//  inst[32]      = WEN_pmem_q;
//  inst[31:21]   = A_pmem_q;
//  inst[20]      = CEN_xmem_q;
//  inst[19]      = WEN_xmem_q;
//  inst[18:8]    = A_xmem_q;
//  inst[7]       = ofifo_rd_q;
//  inst[6]       = ififo_wr_q;
//  inst[5]       = ififo_rd_q;
//  inst[4]       = l0_rd_q;
//  inst[3]       = l0_wr_q;
//  inst[2]       = mode_q
//  inst[1]       = execute_q; 
//  inst[0]       = load_q; 

//*************************************************************
//                          Wires
//*************************************************************
wire [psum_bw*col-1:0] ofifo_rdata;
wire [bw*row-1:0] l0_wdata;
wire [bw*row-1:0] ififo_wdata;
wire [bw*row-1:0] Q_xmem;

//*************************************************************
//                          Misc Logic
//*************************************************************

// Muxing for SRAM0 to L0/IFIFO
assign l0_wdata     = inst[2] ? {bw*row{1'b0}} : Q_xmem;
assign ififo_wdata  = inst[2] ? Q_xmem : {bw*row{1'b0}};

//*************************************************************
//                      Corelet Instance
//*************************************************************
corelet #(
    .bw (bw),
    .psum_bw (psum_bw),
    .col (col),
    .row (row)
) corelet_inst (
    // Common Ports
    .clk                (clk),
    .reset              (reset),
    // PE Array Ports
    .inst_w             (inst[2:0]),
    // OFIFO Ports
    .ofifo_rd           (inst[7]),
    .ofifo_valid        (ofifo_valid),
    .ofifo_rdata        (ofifo_rdata),
    // L0 Ports
    .l0_rd              (inst[4]),
    .l0_wr              (inst[3]),
    .l0_wdata           (l0_wdata),
    // IFIFO Ports
    .ififo_rd           (inst[5]),
    .ififo_wr           (inst[6]),
    .ififo_wdata        (ififo_wdata),
    // SFP Ports
    .sfp_out            (sfp_out)
);

//*************************************************************
//                      SRAM0 Instance
//*************************************************************
sram0_2048x32 SRAM0_inst (
    .CLK    (clk),        
    .WEN    (inst[19]),
    .CEN    (inst[20]),
    .D      (D_xmem),  
    .A      (inst[17:7]),  
    .Q      (Q_xmem)
);
//*************************************************************
//                      SRAM1 Instance
//*************************************************************
sram1_2048x128 SRAM1_inst (
    .CLK    (clk),        
    .WEN    (inst[32]),
    .CEN    (inst[33]),
    .D      (ofifo_rdata),  
    .A      (inst[31:21]),  
    .Q      ()     //TODO connecting SRAM1 to SFP
);

endmodule
