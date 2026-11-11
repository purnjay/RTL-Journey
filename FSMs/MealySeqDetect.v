// MEALY SEQUENCE DETECTOR

module mealy_seq_detect(
    input clk,
    input rst,
    input seq,
    output detection
); 

localparam [2:0] S0 = 3'b000,
                S1 = 3'b001,
                S2 = 3'b010,
                S3 = 3'b011;

reg [1:0] curr_state, next_state;

always @(posedge clk) begin
    if(rst) 
        curr_state <= S0;
    else
        curr_state <= next_state;
end

// look for any changes 
always @(*) begin
     case (curr_state)
        S0: next_state = seq ? S1 : S0;
        S1: next_state = seq ? S1 : S2;
        S2: next_state = seq ? S3 : S0;
        S3: next_state = seq ? S1 : S2; // for overlapping detection
        default: next_state = S0;
     endcase   
end

// assign the detection based on current input and the current state 
assign detection = (curr_state == S3) && seq;

endmodule