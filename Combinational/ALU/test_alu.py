import cocotb
import random
from cocotb.triggers import Timer
from cocotb_coverage.coverage import CoverPoint, CoverCross, coverage_db

# edge cases for the constrained random stimulus
EDGE_CASES = [0, 1, 127, 128, 255]

# cover points for cocotb coverage -> functional coverage
@CoverPoint("alu.op", xf=lambda a, b, op, z, n, c, v: op, bins=[0, 1, 2, 3, 4, 5])
@CoverPoint("alu.edges", xf=lambda a, b, op, z, n, c, v: a, bins=EDGE_CASES)
@CoverPoint("alu.zero", xf=lambda a, b, op, z, n, c, v: z, bins=[0, 1])
@CoverPoint("alu.neg", xf=lambda a, b, op, z, n, c, v: n, bins=[0, 1])
@CoverPoint("alu.carry", xf=lambda a, b, op, z, n, c, v: c, bins=[0, 1])
@CoverPoint("alu.overf", xf=lambda a, b, op, z, n, c, v: v, bins=[0, 1])

# now we find where it crosses
@CoverCross("alu.op_x_zero", items=["alu.op", "alu.zero"])
@CoverCross("alu.op_x_carry", items=["alu.op", "alu.carry"], ign_bins=[(2, 1), (3, 1), (4, 1), (5, 1)])
@CoverCross("alu.op_x_overf", items=["alu.op", "alu.overf"], ign_bins=[(2, 1), (3, 1), (4, 1), (5, 1)])
def sample(a, b, op, z, n, c, v):
    pass

# function to emulate the self check from the testbench 
def model(a, b, op):
    
    # operations 
    if op == 0: res = (a + b) & 0xFF
    elif op == 1: res = (a - b) & 0xFF
    elif op == 2: res = (a & b) & 0xFF
    elif op == 3: res = (a | b) & 0xFF
    elif op == 4: res = (a ^ b) & 0xFF
    elif op == 5: res = (~a) & 0xFF
    else: res = 0
    
    # for the flags
    zero = int(res == 0)
    neg = (res >> 7) & 1
    
    # Carry and overflow for add and sub 
    if op == 0:
        carry = int(a + b > 255)
        overflow = int((a >> 7) == (b >> 7) and (res >> 7) != (a >> 7))
    elif op == 1:
        carry = int(a >= b)
        overflow = int((a >> 7) != (b >> 7) and (res >> 7) != (a >> 7))
    else:
        carry = 0
        overflow = 0
    
    # return the values 
    return res, zero, neg, carry, overflow

# function for picking EDGE CASES randomly 30% of the time 
def pickrand_stim():
    if random.random() < 0.3:
        return random.choice(EDGE_CASES)
    return random.randint(0, 255)

@cocotb.test()
async def alu_test(dut):
    
    # loop for 1000 checks with random
    for i in range(1000):
        
        # select the opcode
        op = random.randint(0, 5)  
        
        # get the values from random stimulus
        # to catch the edge case of not having the 0 == 0 bin checked
        # steering the edge case for this -> zero flag when a = 0, b = 0
        
        if op == 3 and random.random() < 0.1: # make sure you get this 10% of the time by force
            a, b = 0, 0
        else:
            a, b = pickrand_stim(), pickrand_stim()
        
        # now send these to the ALU
        dut.a.value, dut.b.value, dut.op.value = a, b, op
        
        # let the values settle
        await Timer(1, "ns")
        
        # get the values back from the function 
        res, zero, neg, carry, overflow = model(a, b, op)
        
        # now to call the coverpoint function
        sample(a, b, op, zero, neg, carry, overflow)
        
        # assert the result and flags
        assert int(dut.result.value) == res, f"[{i}] a={a} b={b} op={op}: expected{res}, got{int(dut.result.value)}"
        assert int(dut.zero.value) == zero, f"[{i}] expected{zero}, got{int(dut.zero.value)}"
        assert int(dut.carry.value) == carry, f"[{i}] expected{carry}, got{int(dut.carry.value)}"
        assert int(dut.overflow.value) == overflow, f"[{i}] expected{overflow}, got{int(dut.overflow.value)}"
        assert int(dut.negative.value) == neg, f"[{i}] expected{neg}, got{int(dut.negative.value)}"

    # to make sure that we enforce the coverage
    assert coverage_db["alu"].coverage == coverage_db["alu"].size
    # now we print the coverage report 
    coverage_db.report_coverage(dut._log.info, bins=True)
