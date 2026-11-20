`include "../SR_Latch/SR_Latch.v"
`default_nettype none

// Modelling a D latch
module D_latch(
    input wire D,        //input variable 
    input wire enable,   // enable input for the latch
    output wire Qbar,    // output bar value
    output wire Q       // output value
);

//inputs that will go into a SR_latch
wire set = D & enable;
wire reset = ~D & enable; //This ensures that the S and R input are always opposite 

//instantiate the SR latch so we can connect it 
SR_Latch s0(.set(set), .reset(reset), .Q(Q), .Qn(Qbar));

endmodule

`default_nettype wire
