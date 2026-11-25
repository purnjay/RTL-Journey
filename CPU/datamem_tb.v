`timescale 1ns/1ps
`include "data_mem.v"

module datamem_tb;
// inputs 
reg [31:0] addr = 0;
reg [31:0] w_data = 0;
reg en_sig = 0;
reg clk = 0;

//outputs
wire [31:0] o_data;

//clk generation
always #5 clk = ~clk;

// instantiate module
data_mem d0(.clk(clk), .mem_rw(en_sig), .addr(addr), .w_data(w_data), .o_rData(o_data));

// testing loop
initial begin
    //dump the waveform
    $dumpfile("data_mem.vcd");
    $dumpvars(0, datamem_tb);

    //logs
    $display("===============================================");
    $display("===============DATA MEMORY TB==================");
    $display("===============================================");
    $monitor("Write En:%b, Address:%h, Data-Written:%h | Data-Read: %h", en_sig, addr, w_data, o_data);

    //write data and read it 
    en_sig = 1; 
    addr = 32'd0; w_data = 32'd55; #10;    
    addr = 32'd4; w_data = 32'd53; #10;
    addr = 32'd8; w_data = 32'd54; #10;
    addr = 32'd12; w_data = 32'd59; #10;
    addr = 32'd16; w_data = 32'd52; #10;
 
    $display("===============================================");

    //read address
    en_sig = 0; 
    addr = 32'd0; #10; 
    addr = 32'd4; #10; 
    addr = 32'd8; #10; 
    addr = 32'd12; #10; 
    addr = 32'd16; #10; 

    $finish;

end

endmodule