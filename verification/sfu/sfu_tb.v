module sfu_tb;

parameter bw = 4;
parameter col = 8;
parameter row = 8;
parameter psum_bw = 16;

reg clk = 0;
reg reset = 0;
reg  [psum_bw*col-1:0] psum;
reg  [psum_bw*col-1:0] psum_in;
reg acc;
reg acc_i;
wire [psum_bw*col-1:0] sfu_out;
integer psum_file, acc_file;
integer psum_result, acc_result;

sfu #(
    .bw     (bw),
    .col    (col),
    .row    (row),
    .psum_bw(psum_bw)
) sfu_inst (
    .clk        (clk),
    .reset      (reset),
    .acc_i      (acc_i),
    .psum_in    (psum_in),
    .valid_o    (valid_o),
    .psum_out   (sfu_out)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("sfu_tb.vcd");
    $dumpvars(0,sfu_tb);

    clk = 0;
    psum_in = {psum_bw*col{1'b0}};
    acc_i = 0;
    #20
    reset = 1'b1;


    psum_file = $fopen("psum.txt", "r");
    if (psum_file == 0) begin
        $display("Error opening psum.txt");
        $finish;
    end

    acc_file = $fopen("acc.txt", "r");
    if (acc_file == 0) begin
        $display("Error opening acc.txt");
        $finish;
    end

    while (!$feof(psum_file) && !$feof(acc_file)) begin
            // Read the next value from each file
            psum_result = $fscanf(psum_file, "%h,", psum); 
            acc_result = $fscanf(acc_file, "%b,", acc);

            if (psum_result == 1 && acc_result == 1) begin
                psum_in = psum;  // Apply the stimulus to stim_in1
                acc_i = acc;  // Apply the stimulus to stim_in2
                #10;  // Wait for 10 time units
            end
        end
    $fclose(psum_file);
    $fclose(acc_file);
    $finish;
end

endmodule