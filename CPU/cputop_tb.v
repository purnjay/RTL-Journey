/*
======================================
RV32-SINGLE CYCLE CORE
======================================
*/
`timescale 1ns/1ps
`include "cpu_top.v"

module cputop_tv();

//inputs
reg clk = 0;
reg rst = 0;

//outputs -> debug ports
wire [31:0] dbg_pc;
wire dbg_reg_write;
wire [4:0] dbg_write_addr;
wire [31:0] dbg_write_data;

//instantiate the module
cpu_top core(.clk(clk), .rst(rst), .dbg_pc(dbg_pc), .dbg_reg_write(dbg_reg_write),
    .dbg_write_addr(dbg_write_addr), .dbg_write_data(dbg_write_data));

//clock generation
always #5 clk = ~clk;

//loop for testing
initial begin
    
    //dump the waveform
    $dumpfile("rv32_core.vcd");
    $dumpvars(0, cputop_tv);

    //logs
    $display("\n===============================================");
    $display("==================CPU CORE TB==================");
    $display("===============================================\n");
    
    rst = 1; #10;
    rst = 0; 

    //do 15 cycles since there are 14 instructions 
    repeat(15) @(posedge clk);

    $finish;
end

//every negedge
always @(negedge clk) begin      
    $display("=============Instruction:%h=============", core.o_inst);
    $display("Prog_Count:%0d      |  Register_Write:%b", dbg_pc, dbg_reg_write);
    $display("Write_Addr(RD):x%0d |  Write_Data:%0d", dbg_write_addr, dbg_write_data);
    $display("DATA_MEM_RW:%b      |  DATA_MEM_ADDR:%0d", core.mem_rw, core.addr);
    $display("DATA_MEM_DATA:%0d   |  PROG_COUNT_BRANCH:%b", core.w_data, core.branchStep_logic);
    $display("ALU_ZERO:%b\n", core.z_);
end
endmodule