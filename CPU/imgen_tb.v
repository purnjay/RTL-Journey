`timescale 1ns/1ps
`include "imm_gen.v"

module immgen_tb;
//inputs
reg [31:0] inst;

//output
wire [31:0] immData;

//instantiate the module
imm_gen ig0(.inst(inst), .o_immData(immData));

//testing loop
initial begin
    
    //dump the waveform
    $dumpfile("immGen.vcd");
    $dumpvars(0, immgen_tb);

    //logs
    $display("===============================================");
    $display("==============IMMEDIATE DECODER================");
    $display("===============================================");
    $monitor("Instruction: %h -> Immediate: %h", inst, immData);

    //test cases
    inst = 32'h00500093; #5;
    inst = 32'hFFF00093; #5;
    inst = 32'h0080A103; #5;
    inst = 32'hFFC0A103; #5;
    inst = 32'h00512623; #5;
    inst = 32'hFE512E23; #5;
    inst = 32'h00208463; #5;
    inst = 32'hFE208CE3; #5;
    inst = 32'h123451B7; #5;
    inst = 32'hFFFFF1B7; #5;
    inst = 32'h010000EF; #5;
    inst = 32'hFF1FF0EF; #5;
    inst = 32'h002081B3; #5;
    $finish;
end

endmodule