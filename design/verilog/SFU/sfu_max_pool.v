module sfu_max_pool #( 
    parameter bw = 4,
    parameter psum_bw = 16,
    parameter col = 8,
    parameter row = 8
    ) (
    input clk,
    input reset, 
    input acc_i, // 0 -> O.S 1 -> W.S

    input psum_bypass_i,

    input max_pool_en_i,

    input [col*psum_bw-1:0] psum_in,
    output [col*psum_bw-1:0] psum_out
    );

    reg acc_q;
    //reg valid_q;
    wire acc_out_w;

    reg [col*psum_bw-1:0] psum_q;
    reg [col*psum_bw-1:0] max_pool_q;
    reg max_pool_en_q;

    wire [col*psum_bw-1:0] temp_psum_w;
    wire [col*psum_bw-1:0] temp_psum_acc_w;
    wire [col*psum_bw-1:0] temp_relu_psum_w;
    wire [col*psum_bw-1:0] temp_relu_only_psum_w;
    wire [col*psum_bw-1:0] temp_out_psum_w;

    // 4 for MaxPool 2,2
    wire [(col)*psum_bw-1:0] temp_max_psum_w;

    wire max_pool_out_w;
   
    assign acc_out_w = acc_q && ~acc_i;
    assign max_pool_out_w = max_pool_en_q && ~max_pool_en_i;

    genvar k;

    generate
        for (k=0;k<=col-1;k=k+1) begin : sfp_out_assign
            //Acc only
            //Doing here for carry issue
            assign temp_psum_acc_w[((k+1)*psum_bw)-1:k*psum_bw] = psum_in[((k+1)*psum_bw)-1:k*psum_bw] + psum_q[((k+1)*psum_bw)-1:k*psum_bw];         

            // ReLU
            assign temp_relu_psum_w[((k+1)*psum_bw)-1:k*psum_bw] = psum_q[((k+1)*psum_bw)-1] ? 0 : psum_q[((k+1)*psum_bw)-1:k*psum_bw];         
            assign temp_relu_only_psum_w[((k+1)*psum_bw)-1:k*psum_bw] =  psum_in[((k+1)*psum_bw)-1] ? 0 : psum_in[((k+1)*psum_bw)-1:k*psum_bw];
            
            assign temp_out_psum_w[((k+1)*psum_bw)-1:k*psum_bw] = acc_out_w ? temp_relu_psum_w[((k+1)*psum_bw)-1:k*psum_bw] : temp_relu_only_psum_w[((k+1)*psum_bw)-1:k*psum_bw];

            //  Max Pool + ReLU
            assign temp_max_psum_w[((k+1)*psum_bw)-1:k*psum_bw] = max_pool_q[((k+1)*psum_bw)-1:k*psum_bw] > temp_relu_only_psum_w[((k+1)*psum_bw)-1:k*psum_bw] ? max_pool_q[((k+1)*psum_bw)-1:k*psum_bw] : temp_relu_only_psum_w[((k+1)*psum_bw)-1:k*psum_bw];

            // Psum bypass
            assign psum_out[((k+1)*psum_bw)-1:k*psum_bw] = psum_bypass_i ? psum_in[((k+1)*psum_bw)-1:k*psum_bw] : (max_pool_out_w ?  temp_max_psum_w[((k+1)*psum_bw)-1:k*psum_bw] : temp_out_psum_w[(k+1)*psum_bw-1:k*psum_bw]);

        end

    endgenerate
    

    integer j;
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            acc_q <= 0;
            max_pool_en_q <= 0;
            psum_q <= 0;
            max_pool_q <= 0;
        end
        else begin
            acc_q <= acc_i;
            max_pool_en_q <= max_pool_en_i;

            if(~acc_q && acc_i) begin
                psum_q <= psum_in; 
                max_pool_q <= psum_in;
            end
            else if(acc_q && acc_i) begin
                // Accumulate
                psum_q <= temp_psum_acc_w; 
            end

            if(max_pool_en_i && ~max_pool_en_q) begin
                max_pool_q <= temp_relu_only_psum_w;
            end
            else if(max_pool_en_i && max_pool_en_q) begin
                max_pool_q <= temp_max_psum_w;
            end
        end
    end

endmodule