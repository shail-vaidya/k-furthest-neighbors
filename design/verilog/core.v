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
    input                   clk,
    input                   reset,
    input                   ofifo_valid,
    input   [bw*row-1:0]    D_xmem,
    input   [33:0]          inst,
    output                  sfp_out
);

//***********************************************
//        Instruction Mapping
//***********************************************
//  inst[33]      = acc_q;
//  inst[32]      = CEN_pmem_q;
//  inst[31]      = WEN_pmem_q;
//  inst[30:20]   = A_pmem_q;
//  inst[19]      = CEN_xmem_q;
//  inst[18]      = WEN_xmem_q;
//  inst[17:7]    = A_xmem_q;
//  inst[6]       = ofifo_rd_q;
//  inst[5]       = ififo_wr_q;
//  inst[4]       = ififo_rd_q;
//  inst[3]       = l0_rd_q;
//  inst[2]       = l0_wr_q;
//  inst[1]       = execute_q; 
//  inst[0]       = load_q; 

//*************************************************************
//                          Wires
//*************************************************************
wire [psum_bw*col-1:0] ofifo_rdata;
wire [bw*row-1:0] l0_rdata;
wire [bw*col-1:0] ififo_rdata;

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
    .inst_w             (inst[1:0]),
    // OFIFO Ports
    .ofifo_rd           (inst[6]),
    .ofifo_valid        (ofifo_valid),
    .ofifo_rdata        (ofifo_rdata),
    // L0 Ports
    .l0_rd              (inst[3]),
    .l0_wr              (inst[2]),
    .l0_wdata           (),
    // IFIFO Ports
    .ififo_rd           (inst[4]),
    .ififo_wr           (inst[5]),
    .ififo_wdata        (),
    // SFP Ports
    .sfp_out            (sfp_out)
);

//*************************************************************
//                      SRAM0 Instance
//*************************************************************
SRAM0 SRAM0_inst (
    .CLK    (clk),        
    .WEN    (inst[18]),
    .CEN    (inst[19]),
    .D      (D_xmem),  
    .A      (inst[17:7]),  
    .Q      (l0_rdata)     //TODO muxing both IFIFO and L0 to SRAM0
);
//*************************************************************
//                      SRAM1 Instance
//*************************************************************
SRAM1 SRAM1_inst (
    .CLK    (clk),        
    .WEN    (inst[31]),
    .CEN    (inst[32]),
    .D      (ofifo_rdata),  
    .A      (inst[30:20]),  
    .Q      ()     //TODO connecting SRAM1 to SFP
);

endmodule
