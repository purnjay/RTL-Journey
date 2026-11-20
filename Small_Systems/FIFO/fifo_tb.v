`timescale 1ns/1ps
`include "FIFO.v"

module fifo_tb;

//inputs
reg clk = 0;
reg rst = 0;
reg w_en = 0;
reg r_en = 0;
reg [7:0] data;

//outputs
wire [7:0] result;
wire full;
wire empty;

//clk generation
always #5 clk = ~clk;

//instantiate the module
fifo f0(.clk(clk), .rst(rst), .w_en(w_en), .r_en(r_en), .i_data(data), .o_data(result), .w_full(full), .w_empty(empty));

//loop for testing
initial begin

    //dump the waveform
    $dumpfile("FIFO.vcd");
    $dumpvars(0, fifo_tb);

    $display("\nFirst in First out Test bench\n");
    $monitor("Rst:%b, w_en:%b, r_en:%b, data:%d, result:%d, full:%b, empty:%b, count:%d", rst, w_en, r_en, data, result, full, empty, f0.count);
    
    //reset 
    rst = 1; #10;
    rst = 0; #10;

    //make input data 0
    data = 8'd0; #10;

    //write 
    w_en = 1; data = 8'd12; #10;
    data = 8'd13; #10;
    data = 8'd14; #10;
    data = 8'd15; #10;
    data = 8'd16; #10;
    w_en = 0; #10;
    
    //read
    r_en = 1; #50;
    r_en = 0;

    //another write to fill the FIFO completely
    w_en = 1;
    data = 8'd1;  #10;
    data = 8'd2;  #10;
    data = 8'd3;  #10;
    data = 8'd4;  #10;
    data = 8'd5;  #10;
    data = 8'd6;  #10;
    data = 8'd7;  #10;
    data = 8'd8;  #10;   
    w_en = 0; #10;

    // to see if write gets protected after 8th value, since fifo has 8 bit depth
    w_en = 1; data = 8'd9;  #10;
    w_en = 0;  

    $finish;
end



endmodule