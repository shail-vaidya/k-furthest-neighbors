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
    input   [bw*row-1:0]        D_xmem,
    input   [39:0]              inst,
    output                      ofifo_valid,
    output                      l0_ready,
    output                      ififo_ready,
    output  [psum_bw*col-1:0]   sfp_out
);

//***********************************************
//        Instruction Mapping
//***********************************************
//  inst[39]      = psum_bypass_q;
//  inst[38]      = acc_q;
//  inst[37]      = CEN_pmem_q;
//  inst[36]      = WEN_pmem_q;
//  inst[35:27]   = A_pmem_q;
//  inst[26]      = CEN1_xmem_q;
//  inst[25:18]    = A1_xmem_q;
//  inst[17]      = CEN0_xmem_q;
//  inst[16]      = WEN0_xmem_q;
//  inst[15:8]    = A0_xmem_q;
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
    .l0_ready           (l0_ready),
    // IFIFO Ports
    .ififo_rd           (inst[5]),
    .ififo_wr           (inst[6]),
    .ififo_wdata        (Q1_xmem),
    .ififo_ready        (ififo_ready),
    // SFP Ports
    .sfp_acc_i          (inst[38]),
    .sfp_psum_bypass    (inst[39]),
    .sfp_psum_i         (sfu_i_data),
    .sfp_out            (sfp_out)
);

//*************************************************************
//                      XMEM Instance
//*************************************************************
xmem_256x32 xmem_inst (
    .CLK    (clk),        
    .WEN0    (inst[16]),
    .CEN0    (inst[17]),
    .D0      (D_xmem),  
    .A0      (inst[15:8]),  
    .Q0      (Q0_xmem),
    .WEN1    (1'b1),    // Tied high so that Port1 can be used only for reading
    .CEN1    (inst[26]),
    .D1      (32'b0),  
    .A1      (inst[25:18]),  
    .Q1      (Q1_xmem)
);
//*************************************************************
//                      PMEM Instance
//*************************************************************
pmem_512x128 pmem_inst (
    .CLK    (clk),        
    .WEN    (inst[36]),
    .CEN    (inst[37]),
    .D      (ofifo_rdata),  
    .A      (inst[35:27]),  
    .Q      (sfu_i_data)     
);

endmodule
