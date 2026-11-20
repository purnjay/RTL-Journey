`default_nettype none
// Implementing a 2 to 1 mux 
module mux_2to1(
    input wire a,
    input wire b, // normal inputs
    input wire sel, // the selection input
    output wire out // output 
);

 // if sel is 1 then output will be b else output will be a
assign out = sel ? b : a; 

endmodule

`default_nettype wire
