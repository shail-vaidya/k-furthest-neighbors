module sfu_tb;

parameter bw = 4;
parameter col = 8;
parameter row = 8;
parameter psum_bw = 16;

reg clk = 0;
reg reset = 1;  
reg  [psum_bw*col-1:0] psum;
reg  [psum_bw*col-1:0] psum_in;
reg acc;
reg acc_i;
reg pbp_i;
reg psum_bypass_i;
reg mp_i;
reg max_pool_en_i;
wire [psum_bw*col-1:0] sfu_out;
wire [psum_bw*col-1:0] max_pool_out;

integer psum_file, acc_file, pbp_file, mp_file;
integer psum_result, acc_result, pbp_result, mp_result;


sfu_max_pool #(
    .bw     (bw),
    .col    (col),
    .row    (row),
    .psum_bw(psum_bw)
) sfu_inst (
    .clk        (clk),
    .reset      (reset),
    .acc_i      (acc_i),
    .psum_bypass_i (psum_bypass_i),
    .max_pool_en_i  (max_pool_en_i),
    .psum_in    (psum_in),
    .psum_out   (sfu_out)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("sfu_tb.vcd");
    $dumpvars(0,sfu_tb);

    clk = 1;
    psum_in = {psum_bw*col{1'b0}};
    acc_i = 0;
    #15
    reset = 1'b0;

    mp_file = $fopen("max_pool_en.txt", "r");
    if (mp_file == 0) begin
        $display("Error opening psum.txt");
        $finish;
    end


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

    pbp_file = $fopen("psum_bypass.txt", "r");
    if (pbp_file == 0) begin
        $display("Error opening pbp_file.txt");
        $finish;
    end

    while (!$feof(psum_file) && !$feof(acc_file) &&  !$feof(pbp_file) &&  !$feof(mp_file)) begin
            // Read the next value from each file
            psum_result = $fscanf(psum_file, "%h,", psum); 
            acc_result = $fscanf(acc_file, "%b,", acc);
            pbp_result = $fscanf(pbp_file, "%b,", pbp_i);
            mp_result =  $fscanf(mp_file, "%b,", mp_i);

            if (psum_result == 1 && acc_result == 1 && pbp_result == 1) begin
                psum_in = psum;  
                acc_i = acc;  
                psum_bypass_i = pbp_i;
                max_pool_en_i = mp_i;
                #10;  // Wait for 10 time units
            end
        end
    $fclose(psum_file);
    $fclose(acc_file);
    $fclose(pbp_file);
    $fclose(mp_file);


    #20
    $finish;
end

endmodule