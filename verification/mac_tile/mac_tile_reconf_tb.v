module mac_tile_reconf_tb;

parameter bw = 4;
parameter col = 8;
parameter row = 8;
parameter psum_bw = 16;

reg clk = 0;
reg reset = 0;
reg  [psum_bw*col-1:0] psum;

reg  [bw-1:0] a_in;
reg  [bw-1:0] a_data;

reg  [bw-1:0] b_in;
reg  [bw-1:0] b_data;

reg [2:0] inst_i;
wire [psum_bw-1:0] psum_out;
wire [bw-1:0] a_out;
wire [2:0] inst_out;

integer a_file, b_file;
integer a_result, b_result;

mac_tile #(
    .bw     (bw),
    .psum_bw(psum_bw)
) mac_tile_reconf_inst (
    .clk(clk),
    .reset(reset),
    .in_w(a_in),
    .in_n({{12{b_in[bw-1]}},b_in}),
    .inst_w(inst_i),	
    
    .out_s(psum_out),
    .out_e(a_out), 
    .inst_e(inst_out)


);

always #5 clk = ~clk;

initial begin
    $dumpfile("mac_tile_reconf_tb.vcd");
    $dumpvars(0,mac_tile_reconf_tb);

    clk = 0;
    b_in = 0;
    a_in = 0;
    inst_i = 3'b100;

    #10
    reset = 1'b1;

    #10
    inst_i = 3'b110;

    a_file = $fopen("a.txt", "r");
    if (a_file == 0) begin
        $display("Error opening a.txt");
        $finish;
    end

    b_file = $fopen("b.txt", "r");
    if (b_file == 0) begin
        $display("Error opening b.txt");
        $finish;
    end

    while (!$feof(a_file) && !$feof(b_file)) begin
            // Read the next value from each file
            a_result = $fscanf(a_file, "%d,", a_data); 
            b_result = $fscanf(b_file, "%d,", b_data);

            if (a_result == 1 && b_result == 1) begin
                a_in = a_data;  // Apply the stimulus to stim_in1
                b_in = b_data;  // Apply the stimulus to stim_in2
                #10;  // Wait for 10 time units
            end
        end
    $fclose(a_file);
    $fclose(b_file);
    
    // Shifting

    
    inst_i = 3'b101;
    #20

    inst_i = 3'b111;

    #20

    
    
    $finish;


end

endmodule