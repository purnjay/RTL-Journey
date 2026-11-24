// Program Counter holds the address of the current instruction being read

module prog_counter(
    input [31:0] start_addr,     //addr the program counter starts at 
    input [31:0] branch_step,
    input clk,
    input rst,
    output reg [31:0] out_addr
);

always @(posedge clk) begin
    if(rst) 
        //if reset then start at the hardware implemented address
        out_addr <= start_addr;      
    else
        // if not reset then jump by a defined branch step which can be +4 or arbitary
        out_addr <= out_addr + branch_step;      
end
endmodule
