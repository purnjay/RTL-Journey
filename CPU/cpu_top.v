`default_nettype none

`include "pc.v"                                         // PROGRAM COUNTER
`include "imm_gen.v"                                    // IMMEDIATE GENERATOR    
`include "inst_mem.v"                                   // INSTRUCTION MEMORY
`include "data_mem.v"                                   // DATA MEMORY
`include "controlUnit.v"                                // CONTROL UNIT
`include "../Combinational/ALU/ALU.v"                   // ALU
`include "../Sequential/Capstone_Register/REGISTER.v"   //REGISTER

module cpu_top(
    input wire clk,      //clk
    input wire rst,      //reset

    // debug outputs -> what the CPU writes back each cycle, so synthesis has something to keep
    output wire [31:0] dbg_pc,          // the PC (out_addr)
    output wire dbg_reg_write,          // register write enable
    output wire [4:0] dbg_write_addr,   // rd being written
    output wire [31:0] dbg_write_data   // data going into rd
);

//from the program counter
wire [31:0] branch_step;
wire [31:0] out_addr;

//from the instruction memory
parameter ins_depth = 16;
wire [31:0] o_inst;

//from immediate generator
wire [31:0] imm_data;

//from data memory
parameter width_dm = 32;
parameter depth_dm = 16;
wire mem_rw;
wire [width_dm-1:0] o_rData; 

//from control unit
wire [2:0] aluOP; // opcode for ALU  
wire alu_src;     // which register goes into alu -> 0 = imm, 1 = rs2
wire mem_reg;      // what gets to rd, alu_result -> 0, data mem -> 1;
wire reg_write;    // register enable signal
wire branchStep_logic; // 0 for 4, 1 for imm

//from ALU
parameter width_alu = 32;
wire [width_alu-1:0] b;          // alu input 2 -> rs2
wire [width_alu-1:0] result_alu;
wire o, z_, n, c;

//from REGISTER
parameter WIDTH_reg = 32;        // Width of the registers
parameter noOfRegs = 32;     // Number of registers
// Write signals
wire [WIDTH_reg-1:0] write_data; // Data to be written to the register
wire [4:0] write_addr = o_inst[11:7];          // Address of the register to write to from instruction
//Read signals 
wire [4:0] read_addrA = o_inst[19:15];       // rs1 addr -> from instruction
wire [4:0] read_addrB = o_inst[24:20];       // rs2 addr -> from instruction
// Read data outputs
wire [WIDTH_reg-1:0] read_dataA;    // Read data from the rs1 data
wire [WIDTH_reg-1:0] read_dataB;    // Read data from the rs2 data

//from data memory 2
wire [width_dm-1:0] addr = result_alu;
wire [width_dm-1:0] w_data = read_dataB;

//===============ASSIGN STATEMENTS=================
assign write_data = (mem_reg) ? o_rData : result_alu; //rd ? alu_result -> 0, data mem -> 1;
assign b = (alu_src) ? read_dataB : imm_data; // alu input b ? -> 0 = imm, 1 = rs2
assign branch_step = (branchStep_logic && z_) ? imm_data : 32'd4; // branch step ? 0 for 4, 1 for imm

// debug outputs
assign dbg_pc = out_addr;
assign dbg_reg_write = reg_write;
assign dbg_write_addr = write_addr;
assign dbg_write_data = write_data;

//===============ASSIGN STATEMENTS=================

//instantiate the PROGRAM COUNTER at start addr = 0; SEQ
prog_counter pc0(.start_addr(32'd0), .branch_step(branch_step), .clk(clk), .rst(rst), .out_addr(out_addr));

//instruction memory
inst_mem #(.depth(ins_depth)) im0(.inst_addr(out_addr), .o_inst(o_inst));

//immediate generator
imm_gen ig0(.inst(o_inst), .o_immData(imm_data));

//data memory SEQ
data_mem #(.width(width_dm), .depth(depth_dm)) dm0(.clk(clk), .mem_rw(mem_rw), .addr(addr), .w_data(w_data), .o_rData(o_rData));

//control unit
control_unit cu0(.inst(o_inst), .aluOP(aluOP), .mem_rw(mem_rw), .alu_src(alu_src), .mem_reg(mem_reg), .reg_write(reg_write), .branch_step(branchStep_logic));

//ALU
ALU #(.width(width_alu)) a0(.a(read_dataA), .b(b), .op(aluOP), .result(result_alu), .overflow(o), .zero(z_), .negative(n), .carry(c));

//REGISTER SEQ
REGISTER #(WIDTH_reg, noOfRegs) r0(.clk(clk), .rst(rst), .write_en(reg_write),
    .data_in(write_data), .writeAddr(write_addr), .rDataA(read_dataA),
    .rAddrA(read_addrA), .rDataB(read_dataB), .rAddrB(read_addrB)
);

endmodule

`default_nettype wire
