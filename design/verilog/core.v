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
    output                       ofifo_valid,
    input   [bw*row-1:0]        D_xmem,
    input   [49:0]              inst,
    output  [psum_bw*col-1:0]   sfp_out
);

//***********************************************
//        Instruction Mapping
//***********************************************
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

//*************************************************************
//                          Wires
//*************************************************************
wire [psum_bw*col-1:0] ofifo_rdata;
wire [bw*row-1:0] Q0_xmem;
wire [bw*row-1:0] Q1_xmem;

wire [psum_bw*col-1:0] sfu_i_data;

//*************************************************************
//                          Misc Logic
//*************************************************************

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
    .l0_wdata           (Q0_xmem),
    // IFIFO Ports
    .ififo_rd           (inst[5]),
    .ififo_wr           (inst[6]),
    .ififo_wdata        (Q1_xmem),
    // SFP Ports
    .sfp_acc_i          (inst[49]),
    .sfp_psum_i         (sfu_i_data),
    .sfp_out            (sfp_out)
);

//*************************************************************
//                      XMEM Instance
//*************************************************************
xmem_2048x32 xmem_inst (
    .CLK    (clk),        
    .WEN0    (inst[19]),
    .CEN0    (inst[20]),
    .D0      (D_xmem),  
    .A0      (inst[18:8]),  
    .Q0      (Q0_xmem),
    .WEN1    (1'b1),    // Tied high so that Port1 can be used only for reading
    .CEN1    (inst[32]),
    .D1      (32'b0),  
    .A1      (inst[31:21]),  
    .Q1      (Q1_xmem)
);
//*************************************************************
//                      PMEM Instance
//*************************************************************
pmem_16384x128 pmem_inst (
    .CLK    (clk),        
    .WEN    (inst[47]),
    .CEN    (inst[48]),
    .D      (ofifo_rdata),  
    .A      (inst[46:33]),  
    .Q      (sfu_i_data)     
);

endmodule
