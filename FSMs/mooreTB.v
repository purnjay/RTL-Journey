`timescale 1ns/1ps
`include "MooreSeqDetect.v"

module moore_tb;

// inputs 
reg seq_bit = 0;
reg [3:0] correct = 4'b0101;
reg clk = 0;
reg rst = 0;

//outputs
wire out;

//clock generation
always #5 clk = ~clk;

// instantiate the module
moore_seqdetect m0(.clk(clk), .rst(rst), .seq_in(seq_bit), .correct_seq(correct), .detection(out));

initial begin

    //Dump Waveform
    $dumpfile("MooreSeqTB.vcd");
    $dumpvars(0, moore_tb);

    // Log
    $display("Moore seq_bit Detector");
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
    seq_bit = 1; #10; //Correct seq start
    seq_bit = 0; #10;
    seq_bit = 1; #10;
    seq_bit = 0; #10; // Correct seq end
    seq_bit = 0; #10; // Overlap end
    seq_bit = 1; #10;
    seq_bit = 1; #10;
    seq_bit = 1; #10;
    seq_bit = 0; #10;

    $finish;

end

endmodule