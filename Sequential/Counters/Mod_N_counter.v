`default_nettype none
module mod_n_counter #(parameter N = 2)(
    input wire clk,
    input wire rst,
    output reg [$clog2(N)-1:0] count
);

always @(posedge clk) begin
    if(rst) begin
        count <= 0;
    end else begin
        if(count == N-1) begin
            count <= 0;
        end else begin
            count <= count + 1;
        end
    end
end
endmodule

`default_nettype wire
