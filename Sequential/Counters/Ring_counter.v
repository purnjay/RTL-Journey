`timescale 1ns / 1ps
`include "../Shift Registers/SISO.v"
`default_nettype none

module ring_counter #(parameter N = 4)(
    input wire preset,
    input wire clk,
    input wire rst,
    output reg [N-1:0] q
);

// To assign one to the first flip-flop when preset is high,
// otherwise take the value from the last flip-flop

always @(posedge clk) begin
    if (rst) begin
        q <= 0;
    end else if (preset) begin
        q[0] <= 1;
    end else begin
        q <= {q[N-2:0], q[N-1]};
    end
end
endmodule

`default_nettype wire
