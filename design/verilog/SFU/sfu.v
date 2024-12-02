module sfu #( 
    parameter bw = 4,
    parameter psum_bw = 16,
    parameter col = 8,
    parameter row = 8
    ) (
    input clk,
    input reset,
    input acc_i, // 0 -> O.S 1 -> W.S

    input psum_bypass_i,

    input [col*psum_bw-1:0] psum_in,
    output [col*psum_bw-1:0] psum_out
    );

    reg acc_q;
    //reg valid_q;
    reg acc_out_q;

    reg signed [col*psum_bw-1:0] psum_q;

    wire [col*psum_bw-1:0] temp_psum_w;
    wire [col*psum_bw-1:0] temp_relu_psum_w;
    wire [col*psum_bw-1:0] temp_relu_only_psum_w;
    wire [col*psum_bw-1:0] temp_out_psum_w;

    

    genvar k;
    generate
        for (k=0;k<=col-1;k=k+1) begin : sfp_out_assign
        
            // ReLU
            assign temp_relu_psum_w[((k+1)*psum_bw)-1:k*psum_bw] = psum_q[((k+1)*psum_bw)-1] ? 0 : psum_q[((k+1)*psum_bw)-1:k*psum_bw];         
            assign temp_relu_only_psum_w[((k+1)*psum_bw)-1:k*psum_bw] =  psum_in[((k+1)*psum_bw)-1] ? 0 : psum_in[((k+1)*psum_bw)-1:k*psum_bw];
            
            assign temp_out_psum_w[(k+1)*psum_bw-1:k*psum_bw] = acc_out_q ? temp_relu_psum_w[((k+1)*psum_bw)-1:k*psum_bw] : temp_relu_only_psum_w[((k+1)*psum_bw)-1:k*psum_bw];

            // Psum bypass
            assign psum_out[(k+1)*psum_bw-1:k*psum_bw] = psum_bypass_i ? psum_in[((k+1)*psum_bw)-1:k*psum_bw] : temp_out_psum_w[(k+1)*psum_bw-1:k*psum_bw];

        end
    endgenerate
    

    integer j;
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            acc_q <= 0;
            psum_q <= 0;
            acc_out_q <= 0;
        end
        else begin
            acc_q <= acc_i;
            if(~acc_q && acc_i) begin
                psum_q <= psum_in; 
                acc_out_q <= 1'b0;
            end
            else if(acc_q && acc_i) begin
                // Accumulate
                psum_q <= psum_q + psum_in; 
                acc_out_q <= 1'b0;
            end
            else if(acc_q && ~acc_i) begin
                acc_out_q <= 1'b1;
            end
            else if(~acc_q) begin
                acc_out_q <= 1'b0;
            end 
        end
    end

endmodule