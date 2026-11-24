`include "../ripple_carry_adder_N/ripple_carry_N_adder.v"
`default_nettype none


module add_sub #(parameter N = 8)(

    // inputs for the add_sub unit
    input wire [N-1:0] a,
    input wire [N-1:0] b,
    input wire sel, // we use 0 for adding, 1 for subtracting 

    // output the result
    output wire [N-1:0] result,
    output wire overflow,
    output wire cout
);

// wire to cary xor'ed b input 
wire [N-1:0] b_sub = b ^ {N{sel}};

// carry bits for the last and the second last 
wire carry0, carry1; 

// instantiate the ripple carry adder as 8 bit
rcN_adder #(.N(N)) r0(.a(a), .b(b_sub), .cin(sel), .sum(result), .cout(carry1));

// second last carry = carry into the top bit, derived from the sign bits
assign carry0 = a[N-1] ^ b_sub[N-1] ^ result[N-1];

// the overflow is calculated by xoring the second last carry and last carry 
assign overflow = carry0 ^ carry1;

//send the carry out for the ALU
assign cout = carry1;

endmodule

`default_nettype wire
