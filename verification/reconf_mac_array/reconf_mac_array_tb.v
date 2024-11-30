module reconf_mac_array_tb;

parameter bw = 4;
parameter psum_bw = 16;
parameter col = 8;
parameter row = 8;

reg clk = 0;
reg reset = 1;
reg [2:0] inst_w;
reg [bw*row-1:0] in_w;
reg [psum_bw*col-1:0] in_n;
wire [psum_bw*col-1:0] out_s;
wire [col-1:0] valid;
reg [2:0] inst;
reg [bw*row-1:0] in_west;
reg [psum_bw*col-1:0] in_north;
integer inst_file, in_w_file, in_n_file;
integer inst_result, in_w_result, in_n_result;

mac_array #(
    .bw     (bw),
    .psum_bw(psum_bw),
    .row    (row),
    .col    (col)
) mac_array_inst (
    .clk        (clk),
    .reset      (reset),
    .out_s      (out_s),
    .in_w       (in_w),
    .inst_w     (inst_w),
    .in_n       (in_n),
    .valid      (valid)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("reconf_mac_array_tb.vcd");
    $dumpvars(0,reconf_mac_array_tb);

    clk = 0;
    in_n = {psum_bw*col{1'b0}};
    in_w = {bw*col{1'b0}};
    inst_w = 3'b000;
    #20
    reset = 1'b0;

    inst_file = $fopen("inst.txt", "r");
    if (inst_file == 0) begin
        $display("Error opening inst.txt");
        $finish;
    end

    in_w_file = $fopen("in_w.txt", "r");
    if (in_w_file == 0) begin
        $display("Error opening in_w.txt");
        $finish;
    end

    in_n_file = $fopen("in_n.txt", "r");
    if (in_n_file == 0) begin
        $display("Error opening in_n.txt");
        $finish;
    end

    while (!$feof(inst_file) && !$feof(in_w_file) && !$feof(in_n_file)) begin
            // Read the next value from each file
            inst_result = $fscanf(inst_file, "%b,", inst); 
            in_w_result = $fscanf(in_w_file, "%h,", in_west);
            in_n_result = $fscanf(in_n_file, "%h,", in_north);

            if (inst_result == 1 && in_w_result == 1 && in_n_result == 1) begin
                inst_w = inst;  
                in_w = in_west;  
                in_n = in_north;  
                #10;  // Wait for 10 time units
            end
        end
    $fclose(inst_file);
    $fclose(in_w_file);
    $fclose(in_n_file);
    #300
    $finish;
end

endmodule