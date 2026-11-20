`default_nettype none

module n_bit_register #(parameter N = 4)
(
    input wire [N-1:0] d,
    input wire clk,
    input wire rst,
    input wire en,
    output reg [N-1:0] q
);

always @(posedge clk) begin
    if(rst)
        q <= 0;
    else if (en)
        q <= d;
end
endmodule

`default_nettype wire
