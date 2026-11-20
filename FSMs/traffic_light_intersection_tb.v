`timescale 1ps/1ps
`include "traffic_light.v"

module tl_tb;

// inputs 
reg NScar = 0;
reg EWcar = 0;
reg clk = 0;
reg rst = 0;

// outputs
wire NSlite;
wire EWlite;

always #5 clk = ~clk;

//instantiate the module
traffic_light_intersection t0(.clk(clk), .rst(rst), .NScar(NScar), .EWcar(EWcar), .NSlite(NSlite), .EWlite(EWlite));

//Loop for running tests
initial begin
    
    // dump the waveform
    $dumpfile("Traffic_Light_Intersection.vcd");
    $dumpvars(0, tl_tb);

    $display("Traffic_light");
    $monitor("NScar=%b EWcar=%b | NSlite=%b EWlite=%b | state=%b", NScar, EWcar, NSlite, EWlite, t0.curr_state);
    // for intial start
    #5;

    //reset the values
    rst = 1; #10;
    rst = 0; #10;

    // first set
    NScar = 0; EWcar = 0; #10;
    NScar = 0; EWcar = 1; #10;
    NScar = 1; EWcar = 0; #10;
    NScar = 1; EWcar = 1; #10;

    // second set
    NScar = 0; EWcar = 0; #10;
    NScar = 0; EWcar = 1; #10;
    NScar = 1; EWcar = 0; #10;
    NScar = 1; EWcar = 1; #10;

    $finish;

end

endmodule