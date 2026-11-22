import cocotb
import random
from cocotb.triggers import Timer

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

@cocotb.test()
async def alu_test(dut):
    # loop for 1000 checks with random
    for i in range(1000):
        # get the values from random stimulus
        a, b, op = random.randint(0, 255), random.randint(0, 255), random.randint(0, 5)  
        # now send these to the ALU
        dut.a.value, dut.b.value, dut.op.value = a, b, op
        # let the values settle
        await Timer(1, "ns")
        # get the values back from the function 
        res, zero, neg, carry, overflow = model(a, b, op)
        # assert the result and flags
        assert int(dut.result.value) == res, f"[{i}] a={a} b={b} op={op}: expected{res}, got{int(dut.result.value)}"
        assert int(dut.zero.value) == zero, f"[{i}] expected{zero}, got{int(dut.zero.value)}"
        assert int(dut.carry.value) == carry, f"[{i}] expected{carry}, got{int(dut.carry.value)}"
        assert int(dut.overflow.value) == overflow, f"[{i}] expected{overflow}, got{int(dut.overflow.value)}"
        assert int(dut.negative.value) == neg, f"[{i}] expected{neg}, got{int(dut.negative.value)}"