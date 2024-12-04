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
    output [col*psum_bw-1:0] psum_out,
    output [(col/4)*psum_bw-1:0] max_pool_out
    );

    reg acc_q;
    //reg valid_q;
    wire acc_out_w;

    reg [col*psum_bw-1:0] psum_q;

    wire [col*psum_bw-1:0] temp_psum_w;
    wire [col*psum_bw-1:0] temp_psum_acc_w;
    wire [col*psum_bw-1:0] temp_relu_psum_w;
    wire [col*psum_bw-1:0] temp_relu_only_psum_w;
    wire [col*psum_bw-1:0] temp_out_psum_w;

    // 4 for MaxPool 2,2
    wire [(col/4)*psum_bw-1:0] temp_out_max_pool1;
    wire [(col/4)*psum_bw-1:0] temp_out_max_pool2; 
    wire [(col/4)*psum_bw-1:0] temp_out_max_pool3; 
    wire [(col/4)*psum_bw-1:0] a,b,c,d;

    assign acc_out_w = acc_q && ~acc_i;

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

            // Psum bypass
            assign psum_out[((k+1)*psum_bw)-1:k*psum_bw] = psum_bypass_i ? psum_in[((k+1)*psum_bw)-1:k*psum_bw] : temp_out_psum_w[(k+1)*psum_bw-1:k*psum_bw];

        end

        for (k=0;k<=(col/2);k=k+4) begin : sfp_max_pool_assign
            assign a[(((k/4)+1)*psum_bw)-1:(k/4)*psum_bw] = psum_in[((k+1)*psum_bw)-1:k*psum_bw]; // 15:0
            assign b[(((k/4)+1)*psum_bw)-1:(k/4)*psum_bw] = psum_in[((k+2)*psum_bw)-1:(k+1)*psum_bw]; //  31:16
            assign c[(((k/4)+1)*psum_bw)-1:(k/4)*psum_bw] = psum_in[((k+3)*psum_bw)-1:(k+2)*psum_bw]; //  47:32
            assign d[(((k/4)+1)*psum_bw)-1:(k/4)*psum_bw] = psum_in[((k+4)*psum_bw)-1:(k+3)*psum_bw]; //  63:48            

            assign temp_out_max_pool1[(((k/4)+1)*psum_bw)-1:(k/4)*psum_bw] = (a[(((k/4)+1)*psum_bw)-1:(k/4)*psum_bw] > b[(((k/4)+1)*psum_bw)-1:(k/4)*psum_bw]) ? a[(((k/4)+1)*psum_bw)-1:(k/4)*psum_bw] : b[(((k/4)+1)*psum_bw)-1:(k/4)*psum_bw];
            assign temp_out_max_pool2[(((k/4)+1)*psum_bw)-1:(k/4)*psum_bw] = (c[(((k/4)+1)*psum_bw)-1:(k/4)*psum_bw] > d[(((k/4)+1)*psum_bw)-1:(k/4)*psum_bw]) ? c[(((k/4)+1)*psum_bw)-1:(k/4)*psum_bw] : d[(((k/4)+1)*psum_bw)-1:(k/4)*psum_bw];

            assign temp_out_max_pool3[(((k/4)+1)*psum_bw)-1:(k/4)*psum_bw] = (temp_out_max_pool1[(((k/4)+1)*psum_bw)-1:(k/4)*psum_bw] > temp_out_max_pool2[(((k/4)+1)*psum_bw)-1:(k/4)*psum_bw]) ? temp_out_max_pool1[(((k/4)+1)*psum_bw)-1:(k/4)*psum_bw] : temp_out_max_pool2[(((k/4)+1)*psum_bw)-1:(k/4)*psum_bw];

            assign max_pool_out[(((k/4)+1)*psum_bw)-1:(k/4)*psum_bw] = temp_out_max_pool3[(((k/4)+1)*psum_bw)-1:(k/4)*psum_bw];
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
            end
            else if(acc_q && acc_i) begin
                // Accumulate
                psum_q <= temp_psum_acc_w; 
            end
        end
    end

endmodule