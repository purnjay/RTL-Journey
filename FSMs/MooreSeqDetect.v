// MOORE SEQUENCE DETECTOR MODULE

module moore_seqdetect(
    input clk,
    input rst,
    input seq_in,
    input [3:0] correct_seq,
    output reg detection
);

//ex seq = 1010

// state encoding for the sequence
localparam [2:0] S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100;

// keep track of states
reg [2:0] current_state, next_state;

// always sequential loop
always @(posedge clk) begin
    if (rst) begin
        current_state <= S0;
    end else begin
        current_state <= next_state;
    end
end

// always combinational logic
always @(*) begin
    next_state = S0; //default logic
    case (current_state)
        S0: next_state = (seq_in == correct_seq[0]) ? S1 : S0; // choose from state, if 1 then goto next, else loop
        S1: next_state = (seq_in == correct_seq[1]) ? S2 : S0;
        S2: next_state = (seq_in == correct_seq[2]) ? S3 : S0;
        S3: next_state = (seq_in == correct_seq[3]) ? S4 : S0;
        S4: next_state = (seq_in == correct_seq[0]) ? S1 : S0;
        default: next_state = S0;
    endcase
end

always @(*) begin
    detection = (current_state == S4) ? 1'b1 : 1'b0; // output 1 if the sequence is right, 0 if not.
end

endmodule