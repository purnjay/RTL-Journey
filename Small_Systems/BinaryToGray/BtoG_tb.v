`timescale 1ns/1ps
`include "BtoG.v"

module BtoG_tb;

//input 
reg [3:0] b_data;

//output
wire [3:0] g_data;

//instantiate the module
BtoG bg0(.b_data(b_data), .g_data(g_data));

//test loop
initial begin
    
    //waveform dumping 
    $dumpfile("BtoG.vcd");
    $dumpvars(0, BtoG_tb);

    $display("Binary to Gray Convertor");
    $monitor("Binary:%b, Decimal:%d, Gray:%b", b_data, b_data, g_data);

    // the whole table for 4 bit to verify if the correct gray conversion occurs 
    b_data = 4'b0001; #5;
    b_data = 4'b0010; #5;
    b_data = 4'b0011; #5;
    b_data = 4'b0100; #5;
    b_data = 4'b0101; #5;
    b_data = 4'b0110; #5;
    b_data = 4'b0111; #5;
    b_data = 4'b1000; #5;
    b_data = 4'b1001; #5;
    b_data = 4'b1010; #5;
    b_data = 4'b1011; #5;
    b_data = 4'b1100; #5;
    b_data = 4'b1101; #5;
    b_data = 4'b1110; #5;
    b_data = 4'b1111; #5;

    $finish;
end

endmodule