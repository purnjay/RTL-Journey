`timescale 1ps/1ps
`default_nettype none
module SR_Latch(
    input wire set, // the set input for the latch
    input wire reset, // the reset input for the latch 
    
    output wire Q,    // the output value for the latch
    output wire Qn    // the output value for the latch
);

nor(Q, reset, Qn); // Q here is the result of NOR of reset and Qbar
nor(Qn, set, Q); // Qn here is the result of NOR of set and Q


endmodule

`default_nettype wire
