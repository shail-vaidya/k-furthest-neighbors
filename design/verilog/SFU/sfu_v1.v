module sfu_v1 #( 
    parameter bw = 4,
    parameter psum_bw = 16,
    parameter col = 8,
    parameter row = 8
    ) (
    input clk,
    input reset,
    input acc_i,
    input mode_i, // 1 -> O.S 0 -> W.S
    input [col*psum_bw-1:0] psum_in,
    output [col*psum_bw-1:0] psum_out
    );

    reg acc_q;
    //reg valid_q;
    reg new_acc_q;

    reg [col*psum_bw-1:0] psum_q;

    reg mode_q; // Needed?

    wire [col*psum_bw-1:0] temp_psum_w;
    wire [col*psum_bw-1:0] temp_relu_psum_w;
    wire [col*psum_bw-1:0] temp_relu_only_psum_w;


    //assign valid_o = acc_q && ~acc_i;
    //assign valid_o = (acc_q || valid_q) && ~acc_i;
    //assign valid_o = valid_q;
    

    genvar k;
    generate
        for (k=0;k<=col-1;k=k+1) begin : sfp_out_assign
        
        // Accumulate
        assign temp_psum_w[((k+1)*psum_bw)-1:k*psum_bw] = new_acc_q ? psum_q[((k+1)*psum_bw)-1:k*psum_bw] : (psum_q[((k+1)*psum_bw)-1:k*psum_bw] + psum_in[((k+1)*psum_bw)-1:k*psum_bw]);
       
        // ReLU
        assign temp_relu_psum_w[((k+1)*psum_bw)-1:k*psum_bw] = psum_q[((k+1)*psum_bw)-1] ? 0 : psum_q[((k+1)*psum_bw)-1:k*psum_bw];         
        
        assign temp_relu_only_psum_w[((k+1)*psum_bw)-1:k*psum_bw] =  psum_in[((k+1)*psum_bw)-1] ? 0 : psum_in[((k+1)*psum_bw)-1:k*psum_bw];

        assign psum_out[(k+1)*psum_bw-1:k*psum_bw] = mode_q ? temp_relu_only_psum_w[((k+1)*psum_bw)-1:k*psum_bw] : temp_relu_psum_w[((k+1)*psum_bw)-1:k*psum_bw];
        
        end
    endgenerate
    

    integer j;
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            acc_q <= 0;
            psum_q <= 0;
            mode_q <= 0;
            new_acc_q <= 0;
        end
        else begin
            acc_q <= acc_i;
            mode_q <= mode_i;
            if(acc_i && !new_acc_q) begin
                psum_q <= temp_psum_w;
                new_acc_q <= 0;
            end
            else if(acc_i && new_acc_q) begin
                psum_q <= temp_relu_only_psum_w;
                new_acc_q <= 0;
            end
            else begin
                if(acc_q) begin
                    new_acc_q <= 1;
                    psum_q <= temp_psum_w; 
                end
                else begin
                    psum_q <= 0; 
                end
            end
        end
    end

endmodule