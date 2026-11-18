// Binary to Gray convertor

module BtoG #(parameter N = 4)(
    //input
    input [N-1:0] b_data,
    
    //output
    output [N-1:0] g_data
);

// loop to xor the binary bits to convert them to gray ones
genvar i;
generate 
    for (i = 0; i < N-1; i = i + 1) begin
        assign g_data[i] = (b_data[i] ^ b_data[i+1]); // xoring the current and the next binary bit to produce the current gray bit
    end
endgenerate

// the last gray bit is the same as the last binary bit
assign g_data[N-1] = b_data[N-1];

endmodule
