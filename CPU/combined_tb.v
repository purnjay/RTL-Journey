`include "inst_mem.v"
`include "pc.v"

module combined_tb;

// inputs 
reg [31:0] start_addr = 0;
reg [31:0] branch_step = 0;
reg rst = 0;
reg clk = 0;

//outputs
wire [31:0] o_inst;
wire [31:0] o_addr;

//clk generation
always #5 clk = ~clk;

//instantiate the modules
prog_counter pc0(.clk(clk), .rst(rst), .start_addr(start_addr), .branch_step(branch_step), .out_addr(o_addr));

inst_mem im0(.inst_addr(o_addr), .o_inst(o_inst));

// loop for testing
initial begin

    //dump the waveform
    $dumpfile("PC_IM.vcd");
    $dumpvars(0, combined_tb);

    //logs
    $display("===============================================");
    $display("PROGRAM COUNTER + INSTRUCTION MEMORY COMBINED TB");
    $display("===============================================");
    $monitor("Instruction: %h -> Address: %h", o_inst, o_addr);

    //reset the program counter
    rst = 1; #10;
    rst = 0; #50;

    //add the branch step 4 is the default
    branch_step = 4; #100;

    $finish;
end

endmodule