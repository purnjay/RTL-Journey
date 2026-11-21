`timescale 1ns/1ps
`include "ALU.v"

module sc_ALU_tb;

//inputs 
reg clk = 0;
reg [7:0] a;
reg [7:0] b;
reg [2:0] opcode;

//output 
wire [7:0] result;

// wires to handle -> Overflow, Zero, Negative, Carry 
wire o, z_, n, c;

// instantiate the ALU 
ALU a0(.a(a), .b(b), .op(opcode), .result(result), .overflow(o), .zero(z_), .negative(n), .carry(c));

//clock generation
always #5 clk = ~clk;

//self checking vars
integer i; 
integer pass_checks;
integer fail_checks;
reg [11:0] expected_val; // 12 bits since it will check against result and the flags
reg [11:0] actual_value; // from the ALU

//testing loop
initial begin
    
    //dump the waveforms
    $dumpfile("sc_tb_ALU.vcd");
    $dumpvars(0, sc_ALU_tb);

    // initialize the vars
    $display("Initialise Random Values\n");

    pass_checks = 0;
    fail_checks = 0;
    a = 0;
    b = 0;

    #5;

    //loop
    for (i = 0; i < 1000; i = i + 1) begin
        
        // now apply random stimulus
        a = $random;
        b = $random;
        opcode = {$random} % 6; //limiting it to 0 to 5 with brackkets makking it unsigned

        #5; //let values settle

        // now we can call the function to get the expected value and the actual
        expected_val = exp_result(a, b, opcode);
        actual_value = {result, o, z_, n, c};

        if(actual_value !== expected_val) begin
            $display("CHECK FAIL [%0d], Expected:%b | Actual:%b", i, expected_val, actual_value);
            fail_checks = fail_checks + 1;
        end else begin
            pass_checks = pass_checks + 1;
        end

    end // for loop end

    // final display statement
    $display("-------------------------------------");
    $display("FAILED CHECKS:%d", fail_checks);
    $display("PASSED CHECKS:%d", pass_checks);
    $display("-------------------------------------");
    
    if (fail_checks > 0) begin
        $display( "CHECKS FAILED -> %d errors found", fail_checks);
    end else begin
        $display("ALL TESTS PASSED SUCCESSFULLY!!");
    end

    $finish;
end

// function to calculate the values
function [11:0] exp_result;
    input [7:0] a, b;
    input [2:0] opcode;
    reg [7:0] result_f;
    reg overflow, zero, negative, carry;

        begin

            //intialise
            overflow = 0;
            zero = 0;
            negative = 0;
            carry = 0;

            //case
            case(opcode)
                3'b000: result_f = a + b; //add
                3'b001: result_f = a - b; //sub
                3'b010: result_f = a & b; //and
                3'b011: result_f = a | b; //or
                3'b100: result_f = a ^ b; //xor
                3'b101: result_f = ~a;    //not
                default: result_f = 8'b0; //default
            endcase

            // other flags
            zero = (result_f == 0); //zero flag
            negative = result_f[7]; //negative flag

            // for addition
            if(opcode == 3'd0) begin
                carry = (a + b > 255); // if the result is bigger than what 8 bit numbers can handle
                overflow = (a[7] == b[7]) && (result_f[7] != a[7]); // compare signs at input and output
            end

            // for subtraction
            if(opcode == 3'd1) begin
                carry = (a >= b); // if a is greater than or equal to b
                overflow = (a[7] != b[7]) && (result_f[7] != a[7]); // compare signs at input and output
            end

            // join the array at the end
            exp_result = {result_f, overflow, zero, negative, carry};
        end
endfunction
endmodule