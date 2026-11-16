module traffic_light_intersection(
    input clk,  // clock signal
    input rst,  // reset signal
    input NScar, // input for the NS
    input EWcar,  // input for the EW
    output NSlite, // output for NSlite 
    output EWlite  // output for EWlite
);
// defined states
localparam NSgreen = 1'b0, EWgreen = 1'b1;

// To consolodate the values for cleaner code
wire [1:0] traffic_code = {NScar, EWcar};

//state counter
reg curr_state, next_state;

// loop for positive clock edge 
always @(posedge clk) begin
    if(rst)
        curr_state <= NSgreen;
    else
        curr_state <= next_state;
end

//case statement for the traffic logic 
always @(*) begin
    case(curr_state)
    NSgreen : 
        case (traffic_code)
                2'b00 : next_state = NSgreen;
                2'b01 : next_state = EWgreen;
                2'b10 : next_state = NSgreen;
                2'b11 : next_state = EWgreen;
        endcase
    EWgreen :
        case (traffic_code)
                2'b00 : next_state = EWgreen;
                2'b01 : next_state = EWgreen;
                2'b10 : next_state = NSgreen;
                2'b11 : next_state = NSgreen;
        endcase
    endcase
end

    // Assign the output based on the state

assign NSlite = (curr_state == NSgreen) ? 1'b1 : 1'b0;
assign EWlite = (curr_state == NSgreen) ? 1'b0 : 1'b1;

endmodule