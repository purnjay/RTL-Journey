// DATA MEMORY

// the memory address is 32 bits and the data size is also 32 bits

module data_mem #(parameter width = 32, parameter depth = 16)(
    input clk,                          // clk
    input mem_rw,                       // read -> 0, write -> 1
    input [width-1:0] addr,     // address to write/read to/from
    input [width-1:0] w_data,

    output [width-1:0] o_rData          // the data read 
);

//the data loaded from the reg file
reg [width-1:0] mem_reg[0:depth-1];

// loop for writes
always @(posedge clk) begin
    if(mem_rw)
        mem_reg[addr[$clog2(depth)+1:2]] <= w_data; 
end

// assign the data read from the addr
assign o_rData = mem_reg[addr[$clog2(depth)+1:2]]; 

endmodule