// IMMEDIATE GENERATOR

module imm_gen(
    input [31:0] inst,
    output reg [31:0] o_immData
);

// derive the opcodes from the instructions 
wire [6:0] opcodes = inst[6:0];

// local parameter for instructions and their varities for case statement
localparam I_type = 7'b0010011,
           I_type2 = 7'b0000011,
           I_type3 = 7'b1100111,
           S_type = 7'b0100011,
           B_type = 7'b1100011,
           J_type = 7'b1101111,
           U_type = 7'b0110111,
           U_type2 = 7'b0010111;
           
// always loop for case statment to be combinational
always @(*) begin
    //building the generator from the instruction tables
    case (opcodes)
        I_type, I_type2, I_type3: o_immData = {{20{inst[31]}}, inst[31:20]};
        S_type: o_immData = {{20{inst[31]}}, inst[31:25], inst[11:7]};
        B_type: o_immData = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
        U_type, U_type2: o_immData = {inst[31:12], {12{1'b0}}};
        J_type: o_immData = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
        default: o_immData = {32{1'b0}};  // R-type doesn't have an immediate 
    endcase
end

endmodule