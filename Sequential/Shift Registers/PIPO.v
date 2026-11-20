`default_nettype none
// PARALLEL IN PARALLEL OUT SHIFT REGISTER

module PIPO #(parameter N = 4) (
    input wire clk,
    input wire rst,
    input wire [N-1:0] d,
    output reg [N-1:0] q
);

always @(posedge clk) begin
    if(rst)
        q <= {N{1'b0}};
    else
        q <= d;
end

endmodule

`default_nettype wire
