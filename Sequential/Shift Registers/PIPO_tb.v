`timescale 1ns/1ps
`include "PIPO.v"
module PIPO_tb;

//inputs
reg [3:0] d = 0; //intial value
reg clk = 0;
reg rst = 0;

//output, testing for 4 bit case
wire [3:0] q;

//clock generation
always #10 clk = ~clk;

//Instantiate the PIPO module
PIPO #(.N(4)) pipo_inst(.clk(clk), .rst(rst), .d(d), .q(q));

initial begin

    // Dumping the waveform
    $dumpfile("PIPO.vcd");
    $dumpvars(0, PIPO_tb);

    $display("PIPO Testbench");
    $monitor("d = %b, rst = %b, q = %b", d, rst, q);

    // The reset block
    rst = 1; #20;
    rst = 0; #20;

    //test cases, q should take all of d on every clock
    d = 4'b1010; #20;
    d = 4'b0101; #20;
    d = 4'b1111; #20;
    d = 4'b0011; #20;

    // reset with d still set, q should go to 0
    rst = 1; #20;
    rst = 0; #20;

    d = 4'b1001; #20;
    $finish;
end

endmodule
