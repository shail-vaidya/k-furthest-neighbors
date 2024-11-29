module sfu #( 
    parameter bw = 4,
    parameter psum_bw = 16,
    parameter col = 8,
    parameter row = 8
    ) (
    input clk,
    input reset,
    input acc_i,
    input [col*psum_bw-1:0] psum_in,
    output valid_i,
    output [col*psum_bw-1:0] psum_out
    );

    reg acc_q;
    reg valid_q;
    reg [col*psum_bw-1:0] psum_q;

    wire [col*psum_bw-1:0] temp_psum_w;
    wire [col*psum_bw-1:0] temp_relu_psum_w;



    assign psum_out = psum_q;

    genvar k;
    for (k=0;k<=col-1;k=k+1) begin
        // ReLU
        assign temp_psum_w[((k+1)*psum_bw)-1:k*psum_bw] = psum_q[((k+1)*psum_bw)-1:k*psum_bw] + psum_in[((k+1)*psum_bw)-1:k*psum_bw];
        //assign temp_psum_w = psum_q[(k+1)*psum_bw-1:k*psum_bw];
        assign temp_relu_psum_w[((k+1)*psum_bw)-1:k*psum_bw] = temp_psum_w[((k+1)*psum_bw)-1] ? 0 : temp_psum_w[((k+1)*psum_bw)-1:k*psum_bw];         
        assign psum_out[(k+1)*psum_bw-1:k*psum_bw] = temp_relu_psum_w[((k+1)*psum_bw)-1:k*psum_bw];
    end

    integer j;
    always @(posedge clk, negedge reset) begin
        if(!reset) begin
            acc_q <= 0;
            psum_q <= 0;
            valid_q <= 0;
        end
        else begin
            if(acc_q) begin
                //for(j=0;j<=col-1;j=j+1) begin
                    //psum_q[((j+1)*psum_bw)-1:j*psum_bw] <= psum_q[((j+1)*psum_bw)-1:j*psum_bw] + psum_in[((j+1)*psum_bw)-1:j*psum_bw];
                //end
                psum_q <= temp_psum_w;
                valid_q <= 1'b0;
            end
            else if (acc_q && ~acc_i) begin
                valid_q <= 1'b1;
            end
            else begin
                acc_q <= acc_i;
            end
        end
    end

endmodule