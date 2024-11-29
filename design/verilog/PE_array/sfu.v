module sfu #( 
    parameter bw = 4,
    parameter psum_bw = 16,
    parameter col = 8,
    parameter row = 8
    ) (
    input clk,
    input reset,
    input acc,
    input [col*psum_bw-1:0] psum_in,
    output valid,
    output [col*psum_bw-1:0] psum_out
    );

    reg acc_q;
    reg valid_q;
    reg [col*psum_bw-1:0] psum_q;

    wire temp_psum_w;

    integer j;
    always @(posedge clk, negedge reset) begin
        if(!reset) begin
            acc_q <= 0;
            psum_q <= 0;
        end
        
        if(acc) begin
            for(j=0;j<col-1;j=j+1) begin
                psum_q[(j+1)*psum_bw-1:j*psum_bw] <= psum_q[(j+1)*psum_bw-1:j*psum_bw] + psum_in[(j+1)*psum_bw-1:j*psum_bw];
            end

            valid_q <= 1'b0;

        else begin
        end

        end
    end
    


endmodule