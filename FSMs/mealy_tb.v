`timescale 1ns/1ps
`include "MealySeqDetect.v"

module mealy_tb;

// inputs
reg seq_bit = 0;
reg clk = 0;
reg rst = 0;

//outputs
wire out;

//clock generation
always #5 clk = ~clk;

// instantiate the module
mealy_seq_detect m0(.clk(clk), .rst(rst), .seq(seq_bit), .detection(out));

initial begin

    //Dump Waveform
    $dumpfile("MealySeqTB.vcd");
    $dumpvars(0, mealy_tb);

    // Log
    $display("Mealy seq_bit Detector");
    $monitor("rst=%b in=%b out=%b", rst, seq_bit, out);

    rst = 1; #20;
    rst = 0; #20;

    // Test cases
    seq_bit = 0; #10;
    seq_bit = 0; #10;
    seq_bit = 0; #10;
    seq_bit = 0; #10;
    seq_bit = 1; #10;
    seq_bit = 1; #10;
    seq_bit = 1; #10; // Correct seq start
    seq_bit = 0; #10;
    seq_bit = 1; #10;
    seq_bit = 0; #10; // Correct seq end
    seq_bit = 1; #10; // Overlap start
    seq_bit = 0; #10; // Overlap end (detect #2)
    seq_bit = 0; #10;
    seq_bit = 1; #10;
    seq_bit = 1; #10;
    seq_bit = 1; #10;
    seq_bit = 0; #10;

    $finish;

end

endmodule