`default_nettype none
// FIRST IN FIRST OUT PARAMETRIZED

module fifo #(parameter N = 8, width = 8)(
    input wire clk,      // clock
    input wire rst,      // reset
    input wire w_en,     // write enable
    input wire r_en,     // read enable
    input wire [width-1:0] i_data,     // incoming data

    output reg [width-1:0] o_data,   // out going data
    output wire w_full,    // to indicate if full or not
    output wire w_empty    // same as above, to tell if empty or not

);

reg [$clog2(N)-1:0] w_ptr;
reg [$clog2(N)-1:0] r_ptr;
reg [$clog2(N):0] count;

// the main "array" to store values
reg [width-1:0] store[N-1:0];

always @(posedge clk) begin
    
    //reset all the values
    if(rst) begin
        w_ptr <= 0;
        r_ptr <= 0;
        count <= 0;
        o_data <= 0;
    end

    // only store data and increment the write pointer if write enabled and fifo is not full
    if(w_en && !w_full) begin
        store[w_ptr] <= i_data;
        w_ptr <= w_ptr + 1;
        count <= count + 1;
    end

    // only read store data and increment the read pointer if read enabled and fifo is not empty
    if(r_en && !w_empty) begin
        o_data <= store[r_ptr];
        r_ptr <= r_ptr + 1;
        count <= count - 1;
    end
end

assign w_full = (count == N); // full is true when the count has reached the depth of the fifo
assign w_empty = (count == 0); // empty is true when the count has reached the start of the fifo

endmodule

`default_nettype wire
