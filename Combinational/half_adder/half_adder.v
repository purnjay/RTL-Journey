`default_nettype none
module half_adder(
    input wire a, // The input A
    input wire b, // The input B
    output wire sum, // The output in which the sum will be calculated
    output wire carry // The carry bit 
);

// Now we implement the half adder logic
assign sum = a ^ b; // The Sum is the exclusive OR of the inputs, 
assign carry = a & b; // The carry is the and of the inputs

endmodule

`default_nettype wire
