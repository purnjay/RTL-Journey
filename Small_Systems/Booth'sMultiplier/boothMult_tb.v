`timescale 1ns/1ps
`include "boothMultiplication.v"

module booth_tb;

//bit width
localparam width = 4;

//inputs
reg clk = 0;
reg rst = 0;
reg start = 0;
reg signed [width-1:0] M;     //Multiplicand
reg signed [width-1:0] Q;    // Multiplier

//outputs
wire done;
wire signed [(2*width)-1:0] result_m;

// instantiate the module
boothMult #(.N(width)) b0(.clk(clk), .rst(rst), .start(start), .M(M), .Q(Q), .done(done), .result(result_m));

//clk pulse
always #5 clk = ~clk;

// loop for testing
initial begin

    //dump the waveform
    $dumpfile("booth_tb.vcd");
    $dumpvars(0, booth_tb);

    //logs
    $display("Booth Multiplier");
    $monitor("M:%d, Q:%d | Result:%d, done:%b", M, Q, result_m, done);

    //reset
    rst = 1; #10;
    rst = 0; #10;

    //first multiply: 3 x -5
    M = 4'b0011; Q = 4'b1011;
    start = 1; #10; start = 0;   // pulse start
    wait(done);                   // wait until finished
    #10;

    //second multiply: 3 x -7  
    M = 4'b0011; Q = 4'b1001;
    start = 1; #10; start = 0;   // pulse start
    wait(done);
    #10;

    $finish;
end

endmodule