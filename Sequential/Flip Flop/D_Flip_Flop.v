// to build off of D Latch
`include "../D/D_latch.v"
`default_nettype none

module d_flip_flop(
    input wire D,        // input data
    input wire clk,      // the clock
    output wire Q,       // the output
    output wire Qbar     // the opposite of output 
);

wire Q_carry; // this will carry the Q from Master D latch to slave d latch

D_latch d0(.D(D), .enable(~clk), .Q(Q_carry)); // Master D latch

D_latch d1(.D(Q_carry), .enable(clk), .Q(Q), .Qbar(Qbar)); // Slave D latch

endmodule

`default_nettype wire
