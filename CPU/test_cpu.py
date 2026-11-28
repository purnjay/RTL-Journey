import cocotb
import random
import logging
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb_coverage.coverage import CoverPoint, CoverCross, coverage_db

# function to get the instructions
def fetch():
    # to hold the instructions
    instructions = []
    
    # open the hexfile and get the data
    with open("iData.hex","r") as f:
        page = f.read().splitlines()
        
    #instructions are vertically lined break with space
    for i in range(len(page)):
        if page[i].strip() == "":             # skip blank lines
            continue
        raw_hex = page[i].split()[0]           # get the raw string 
        val_b = int(raw_hex, 16)               # convert to int with base 16 
        instructions.append(val_b)             # append to the instructions array
        
    # return the instructions
    return instructions
    
def decode(instruction):    
    
    # dictionary to decode the opcode
    inst_type = {
        0b0110011 : "R",
        0b0010011 : "I",
        0b0000011 : "I2",
        0b0100011 : "S",
        0b1100011 : "B"
    }
    
    opcode = instruction & 0x7F          # Get the opcode
    rd = (instruction >> 7) & 0x1F       # Get the rd
    funct3 = (instruction >> 12) & 0x7   # Get the funct3
    rs1 = (instruction >> 15) & 0x1F     # Get the rs1
    rs2 = (instruction >> 20) & 0x1F     # Get the rs2
    funct7 = (instruction >> 25) & 0x7F  # Get the funct7
    imm_gen = 0

    # case statement to match instruction and perform opration
    match inst_type.get(opcode):
        case "R":
            pass                         # no immediate
               
        case "I" | "I2":    #[31:11 -> sign: inst[31], 11:0 -> inst[31:20]]
            imm = (instruction >> 20) & 0xFFF   # get the immediate
            if (imm >> 11) & 1:                 # check if bit 11 is 1 
                imm = imm | 0xFFFFF000          # fill upper 20 bits with 1s
            imm_gen = imm
            
        case "S":           #[31:11 -> sign: inst[31], 11:7 -> inst[31:25], 5:0 -> inst[11:7]]
            imm = (instruction >> 25) & 0x7F    # get the first immediate
            imm2 = (instruction >> 7) & 0x1F    # get the second immediate 
            imm = (imm << 5) | imm2             # fill the second immediate 
            if (imm >> 11) & 1:                 # check if bit 11 is 1 
                imm = imm | 0xFFFFF000          # fill upper 20 bits with 1 
            imm_gen = imm     
              
        case "B": 
            imm = (instruction >> 25) & 0x3F   
            imm2 = (instruction >> 8) & 0xF
            imm = ((((((instruction >> 7) & 0x1) << 6) | imm) << 4) | imm2) << 1 # build the immediate
            if (instruction >> 31) & 1:         # check if bit 31 is 1 
                imm = imm | 0xFFFFF000          # fill upper 20 bits with 1 
            imm_gen = imm     
                        
        case _:
            print("Invalid Opcode")   
        
    # return the variables
    return inst_type.get(opcode), rd, funct3, rs1, rs2, funct7, imm_gen

def execute(instructions, reg, data_mem, pc):
    
    # get the instruction at the program counter
    inst32 = instructions[pc // 4]
    
    # decode the instruction and get everything
    inst_type, rd, funct3, rs1, rs2, funct7, imm_gen = decode(inst32)
    
    # what should get written back -> reg write, rd, write data
    reg_write, wdata = 0, 0
    next_pc = (pc + 4) & 0xFFFFFFFF
    
    match inst_type:
        case "R":
            match (funct3, funct7):
                case (0x0, 0x00): wdata = reg[rs1] + reg[rs2]   # ADD
                case (0x0, 0x20): wdata = reg[rs1] - reg[rs2]   # SUB
                case (0x7, 0x00): wdata = reg[rs1] & reg[rs2]   # AND
                case (0x6, 0x00): wdata = reg[rs1] | reg[rs2]   # OR
                case (0x4, 0x00): wdata = reg[rs1] ^ reg[rs2]   # XOR
            reg_write = 1
            
        case "I":
            match funct3:
                case 0x0:   wdata = reg[rs1] + imm_gen # ADDI
            reg_write = 1
                
        case "I2": # LW
            addr = (reg[rs1] + imm_gen) & 0xFFFFFFFF
            wdata = data_mem.get(addr, 0)
            reg_write = 1
            
        case "S": # SW
            addr = (reg[rs1] + imm_gen) & 0xFFFFFFFF
            data_mem[addr] = reg[rs2]
        
        case "B":
          if reg[rs1] == reg[rs2]:
              next_pc = (pc + imm_gen) & 0xFFFFFFFF
    
    # now the data has to be 32 bits
    wdata = wdata & 0xFFFFFFFF
    
    # now we write to the register
    if (reg_write == 1) and (rd != 0):
        reg[rd] = wdata
    
    # now return the value cpu has to output and move to next pc
    return reg_write, rd, wdata, next_pc        

# reset function    
async def reset(dut):
    dut.rst.value = 1; 
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    dut.rst.value = 0

@cocotb.test()
async def cpu_test(dut):
    
    # get the instructions
    instruct = fetch()
    
    # set initial values
    reg = [0] * 32
    data_mem = {}
    pc = 0
    
    # clock start
    clk = Clock(dut.clk, 5, "ns")
    clk.start() 
    await reset(dut)
    
    # start the for loop
    for i in range(15):
        # get the expected values from the model
        reg_write, rd, wdata, next_pc = execute(instruct, reg, data_mem, pc)
        
        # get the debug values from the dut 
        dpc, dreg_write, drd, dwdata = dut.dbg_pc.value, dut.dbg_reg_write.value, dut.dbg_write_addr.value, dut.dbg_write_data.value
        
        # assert the values to find errors
        assert int(dpc) == pc, f"[{i}] PC -> Model:{pc} | CPU:{int(dpc)}"
        assert int(dreg_write) == reg_write, f"[{i}] Register write enable -> Model:{reg_write} | CPU:{int(dreg_write)}"
        if reg_write == 1:
            assert int(drd) == rd, f"[{i}] Register Destination Addr -> Model:{rd} | CPU:{int(drd)}"
            assert int(dwdata) == wdata, f"[{i}] Write Data -> Model:{wdata} | CPU:{int(dwdata)}"

        # set pc = next pc
        pc = next_pc

        # wait till the falling edge        
        await FallingEdge(dut.clk)
           
    
        
     
        
 