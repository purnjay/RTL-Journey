/*
INSTRUCTION MEMORY

this block loads in the instructions from the hex file and outputs 
the intruction at a specific address.

*/
`default_nettype none
module inst_mem #(parameter depth = 16)(
    input wire [31:0] inst_addr,    // the address for the instruction
    output wire [31:0]  o_inst   // the instruction
);

//the instructions loaded from the hex file
reg [31:0] mem_hex[0:depth-1];

initial begin
    $readmemh("iData.hex", mem_hex); //get data from the file
end

//load the instruction from the hex file with the addr
assign o_inst = mem_hex[inst_addr[$clog2(depth)+1:2]]; // clog2 since the address has to be limited by the word

endmodule
`default_nettype wire
