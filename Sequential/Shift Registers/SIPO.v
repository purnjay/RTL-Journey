// SERIAL IN PARALLEL OUT SHIFT REGISTER
`include "SISO.v"
`default_nettype none

module SIPO #(parameter N = 4)
(
    input wire d,
    input wire clk,
    input wire rst,
    output wire [N-1:0] q
);

// Instiantiate the SISO module
SISO #(N) siso_inst(.d(d), .clk(clk), .rst(rst), .shift_reg_out(q));

endmodule

`default_nettype wire
