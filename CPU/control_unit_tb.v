`timescale 1ns/1ps
`include "controlUnit.v"

module control_unit_tb;

//input
reg [31:0] inst;

//outputs
wire [2:0] aluOP; // opcode for ALU
wire mem_rw;      // read or write for data mem  
wire alu_src;     // which register goes into alu -> 0 = imm, 1 = rs2
wire mem_reg;      // what gets to rd, result of alu or Datamem
wire reg_write;    // register enable signal
wire branch_step;   // step for branch that goes into PC.v

//instantiate the module
control_unit cu0(.inst(inst), .aluOP(aluOP), .mem_rw(mem_rw), .alu_src(alu_src), .mem_reg(mem_reg), .reg_write(reg_write), .branch_step(branch_step));

//loop
initial begin
    //dump the waveform
    $dumpfile("Control-Unit.vcd");
    $dumpvars(0, control_unit_tb);

    //logs
    $display("===============================================");
    $display("================CONTROL UNIT===================");
    $display("===============================================");
    $monitor("Instruction: %h | ALU:%b, MEM_RW:%b, ALU_src:%b, MEM_REG:%b, REG_WRITE:%b, BRANCH:%b", inst, aluOP, mem_rw, alu_src, mem_reg, reg_write, branch_step);

    // test cases
    inst = 32'h002081B3; #5;   // add  x3, x1, x2
    inst = 32'h40208233; #5;   // sub  x4, x1, x2
    inst = 32'h0020F2B3; #5;   // and  x5, x1, x2
    inst = 32'h0020E333; #5;   // or   x6, x1, x2
    inst = 32'h0020C3B3; #5;   // xor  x7, x1, x2
    inst = 32'h00500093; #5;   // addi x1, x0, 5
    inst = 32'h0080A103; #5;   // lw   x2, 8(x1)
    inst = 32'h00512623; #5;   // sw   x5, 12(x2)
    inst = 32'h00208463; #5;   // beq  x1, x2, 8
    inst = 32'h123451B7; #5;   // lui  x3, 0x12345 (defaults)
    $finish;
end
endmodule