# Learning FPGA Dev

RTL building blocks I am writing from scratch in Verilog, on the way to a single cycle processor
core running a subset of RV32I, the base 32 bit RISC-V instruction set: ADD, SUB, AND, OR, XOR,
ADDI, LW, SW and BEQ. Combinational/ has the blocks that are just logic and Sequential/ has
the ones that hold state. Each folder inside them is one piece of the datapath with its design
file, a testbench for it, and usually a waveform dump. FSMs/ has the state machines, which aren't
part of the datapath but the control unit is going to be one. Small_Systems/ has small blocks
that stand on their own, like the FIFO. CPU/ is the core itself, as it gets built.

Everything is simulated with Icarus Verilog and viewed in GTKWave out of the OSS CAD Suite. Once
the core is together the plan is to take it through logic synthesis and place and route with
Yosys and nextpnr.

Phases 1 to 4 are done.

Phase 1 is combinational. All the combinational blocks are built, they come together in the ALU,
and the ALU has a testbench of its own.

Phase 2 is sequential. The latches, the D, JK and T flip flops, an N bit register, the SISO, SIPO,
PISO and PIPO shift registers, a bi-directional shift register, up/down, ring, Johnson and mod N
counters, and it ends with the register file.

Phase 3 is FSMs. A Mealy and a Moore sequence detector and a traffic light.

Phase 4 is small systems. A binary to Gray converter, a FIFO and a Booth multiplier with a
start/done handshake.

The ALU is verified now, with a self-checking testbench and a cocotb test.

Phase 5 is the single cycle core and it runs. All the blocks are built and wired together in
cpu_top.v, and it runs all nine instructions it is meant to: add, sub, and, or, xor, addi, lw, sw
and beq. What is left is in What is next at the bottom.

## Running a testbench

The testbenches include the design files with relative paths, so cd into the folder first, then
compile and run it:

```
cd Combinational/decoders
iverilog -o n_decoder_tb.out n_decoder_tb.v
vvp n_decoder_tb.out
gtkwave n_decoder_tb.vcd
```

You only pass the testbench to iverilog, it already includes the design file it needs. Same thing
for every other folder, just swap in that testbench name. Every testbench is named after the
module it tests, `<module>_tb.v`, and a self-checking one gets selfcheck_ in front. The Flip Flop folder has a space in it,
so put quotes around it when you cd in.

Every module sits at the same depth on purpose, so the .. in the includes always points at the
folder holding all of them and the same two commands work everywhere, ALU included.

The .out and .vcd files are just compiler and simulation output, so they are in .gitignore and
not committed. The commands above make them again.

## Running the cocotb test

The ALU folder also has a cocotb test, test_alu.py, with a Makefile that runs it on Icarus. cd in
and run make:

```
cd Combinational/ALU
make
```

It needs cocotb (pip install cocotb) and GNU make. cocotb's Makefiles also use sh and uname, so on
Windows make has to see Git's Unix tools in C:\Program Files\Git\usr\bin, either from a Git Bash
terminal or with that folder added to the end of PATH. VERILOG_SOURCES in the Makefile is a
relative path on purpose, make splits paths at spaces and this repo's folder names have them.
sim_build/ and results.xml are output and are in .gitignore too.

## The ALU

`Combinational/ALU/ALU.v`, and this is where phase 1 ends up. The width is a parameter, 8 bits by
default, and it passes the width down to add_sub so the whole thing can go up to 32 bits for the
core. A 3 bit op picks the
operation, add and sub go through the add_sub unit and the logic ops are done right there in the
case.

| op | operation |
| --- | --- |
| 000 | ADD |
| 001 | SUB |
| 010 | AND |
| 011 | OR |
| 100 | XOR |
| 101 | NOT a |
| 110, 111 | unused, result is 0 |

Four flags come out with the result:

| flag | how it is worked out |
| --- | --- |
| zero | `~\|result`, or every bit in the result and then inverted |
| negative | just the MSB of the result |
| carry | the carry out of the top of the ripple carry adder |
| overflow | from add_sub, signed overflow |

carry and overflow both come off the add_sub path, so they only mean anything on ADD and SUB. On
every other op they are forced to 0 so the logic ops don't leave whatever the adder produced
sitting on them.

### Verification

There are three testbenches for the ALU. ALU_tb.v just prints the outputs and I check them by
eye. selfcheck_ALU_tb.v runs 1000 random checks against a Verilog function and counts passes and
fails. test_alu.py is the cocotb one and the most complete, it is run with make (see Running the
cocotb test).

**Reference model.** model() in test_alu.py works out the expected result and all four flags for
any a, b and op. Every check compares the ALU's outputs to it with asserts, so if the result or
any flag is wrong the test fails right there and says which check it was.

**Constrained-random stimulus.** One cocotb test does 1000 checks. Each check picks a random op from 0 to 5, and a
and b are random from 0 to 255, but each of them has a 30% chance of being an edge case instead:
0, 1, 127, 128 or 255. That steers the random values towards the boundaries where carry, overflow
and the sign bit flip, which plain random would rarely land on. On OR there is also a 10% chance
of forcing a = b = 0, because otherwise OR almost never gives a zero result.

**Functional coverage.** cocotb-coverage samples every check and reports what got hit: every op,
a landing on each edge value, each flag at both 0 and 1, and the op crossed with zero, carry and
overflow. For the logic ops, carry = 1 and overflow = 1 are left out of the crosses since they are
forced to 0 and can't happen. The report shows whether the random stimulus actually reached the
cases the asserts are meant to check, and every run so far has hit all 47 bins.

To confirm the checks can actually fail, a deliberate bug was put in the model (an extra +1 on
ADD), and the test failed on the first ADD check, then passed again once it was removed.

## Combinational blocks

All of these live in Combinational/. In the order I did them, since most of them build on the
one before it.

| Folder | Module | Testbench | What it does |
| --- | --- | --- | --- |
| half_adder | `half_adder` | `half_adder_tb.v` | Sum is a XOR b, carry is a AND b. Simplest place to start. |
| full_adder | `full_adder` | `full_adder_tb.v` | Made out of two half adders, the two carries get OR'd for the carry out. |
| ripple_carry_adder_N | `rcN_adder` | `rcN_adder_tb.v` | N bit adder. A generate loop makes N full adders and the carry from each one goes into the next. Change N to change the width. |
| muxes | `mux_2to1`, `mux_4to1`, `mux_8to1` | `mux_tb.v` | 2 to 1 uses a ternary, 4 to 1 and 8 to 1 use a case statement. |
| demuxes | `dmux_1to2`, `dmux_1to4`, `dmux_1to8` | `dmux_tb.v` | 1 to 4 is made from three 1 to 2 demuxes, 1 to 8 is a 1 to 2 and two 1 to 4s. Needed ifndef guards so the files don't get included twice. |
| decoders | `n_decoder` | `n_decoder_tb.v` | N to 2^N decoder, the output is just 1 << in. |
| encoders | `_encoder8to3` | `_encoder8to3_tb.v` | 8 to 3 encoder using OR gates. Only works with one hot inputs, an input of 0 and an input of 1 both give 000. |
| encoders | `priorityEn8_3` | `priorityEn8_3_tb.v` | Priority encoder using casez, outputs the index of the highest bit that is set. |
| comparator | `mag_comp_N` | `mag_comp_N_tb.v` | N bit comparator with outputs for a < b, a == b and a > b. |
| add_sub | `add_sub` | `add_sub_tb.v` | N bit adder/subtractor using the ripple carry adder, 8 bits by default. sel = 0 adds, sel = 1 XORs b and sets the carry in to 1 to subtract. Also outputs overflow and carry out. |
| barrel_shifter | `barrel_shifter` | `barrel_shifter_tb.v` | 8 bit left shift by 0 to 7, done in three stages that shift by 1, 2 and 4. |
| ALU | `ALU` | `ALU_tb.v`, `selfcheck_ALU_tb.v`, `test_alu.py` | Puts everything above together. The opcodes and how it is verified are in the ALU section. |

## Sequential blocks

All of these live in Sequential/. Same idea as the combinational ones, most of them are built
out of the one before it. All three flip flops are in the Flip Flop folder.

| Folder | Module | Testbench | What it does |
| --- | --- | --- | --- |
| SR_Latch | `SR_Latch` | `SR_Latch_tb.v` | Two NOR gates feeding into each other. s = r = 1 isn't allowed. |
| D | `D_latch` | `D_latch_tb.v` | SR latch with set = D & enable and reset = ~D & enable, so S and R are always opposite. |
| Flip Flop | `d_flip_flop` | `d_flip_flop_tb.v` | Two D latches as master and slave, the master is enabled on ~clk and the slave on clk. |
| Flip Flop | `jk_ff` | `jk_ff_tb.v` | Case on {J, K}, 00 holds, 01 resets, 10 sets and 11 toggles. Has a synchronous reset. |
| Flip Flop | `t_flip_flop` | `t_flip_flop_tb.v` | D flip flop with D = T ^ Q. Needed a reset or Q stays stuck at x. |
| Register | `n_bit_register` | `n_bit_register_tb.v` | N bit register with rst and en. If rst is high q goes to 0, if en is high q takes d, otherwise it holds. |
| Shift Registers | `SISO` | `SISO_tb.v` | Serial in serial out shift register, shifts d in every clock and q is the last bit. At N = 1 it is just a D flip flop. |
| Shift Registers | `SIPO` | `SIPO_tb.v` | Serial in parallel out, uses the SISO module but outputs all N bits at once. |
| Shift Registers | `PISO` | `PISO_tb.v` | Parallel in serial out, made from 1 bit registers. SH_LD = 0 loads d, SH_LD = 1 shifts it out of q one bit at a time. |
| Shift Registers | `PIPO` | `PIPO_tb.v` | Parallel in parallel out, q takes all of d every clock. Same as the register without en. |
| Bi_directionalShiftReg | `BDSR` | `BDSR_tb.v` | Bi-directional shift register, R_Lshift = 0 shifts left and 1 shifts right. q is the bit at whichever end it is shifting towards. |
| Counters | `counter_up_down` | `counter_up_down_tb.v` | N bit up/down counter, dir = 1 counts up and dir = 0 counts down. |
| Counters | `ring_counter` | `ring_counter_tb.v` | Ring counter, preset puts a 1 in the first flip flop and then it goes around, 0001, 0010, 0100, 1000 and back. |
| Counters | `johnson_counter` | `johnson_counter_tb.v` | Johnson counter, same as the ring counter but the last bit gets inverted when it goes back to the start. 4 bits gives 8 states. |
| Counters | `mod_n_counter` | `mod_n_counter_tb.v` | Counts from 0 up to N-1 and then goes back to 0. The width is $clog2(N) so it is only as wide as it needs to be. |
| Capstone_Register | `REGISTER` | `REGISTER_tb.v` | Register file, 8 registers of 8 bits made from the N bit register, the decoder picks which one gets written and there are two read ports. Reading address 0 always gives 0. The testbench runs it at 32 registers of 32 bits. |

## State machines

All of these live in FSMs/. They all have a clocked always block for the state with a synchronous
reset and a combinational one for the next state.

| Folder | Module | Testbench | What it does |
| --- | --- | --- | --- |
| FSMs | `mealy_seq_detect` | `mealy_seq_detect_tb.v` | Mealy sequence detector for 1011 with overlap. The output depends on the state and the input, so it only needs 4 states. |
| FSMs | `moore_seqdetect` | `moore_seqdetect_tb.v` | Moore sequence detector, the 4 bit sequence comes in on correct_seq. The output only depends on the state so it needs 5, and any wrong bit goes back to S0. |
| FSMs | `traffic_light_intersection` | `traffic_light_intersection_tb.v` | Traffic light for an intersection with two states, NS green and EW green. The light switches when a car is waiting on the red side, so with cars on both sides it flips every clock. |

## Small systems

All of these live in Small_Systems/, each in its own folder.

| Folder | Module | Testbench | What it does |
| --- | --- | --- | --- |
| BinaryToGray | `BtoG` | `BtoG_tb.v` | N bit binary to Gray converter. A generate loop XORs each bit with the one above it, and the top bit stays the same. |
| FIFO | `fifo` | `fifo_tb.v` | FIFO with depth N and data width set by parameters. Read and write pointers go around an array and a count drives full and empty, writes are ignored when full and reads when empty. |
| Booth'sMultiplier | `boothMult` | `boothMult_tb.v` | N bit signed multiplier using Booth's algorithm, one add/sub and shift per clock so it takes N clocks. It has a start/done handshake, pulse start while it isn't busy to load M and Q, and done goes high when the 2N bit result is ready and stays high until the next start. |

## CPU

The single cycle core lives in CPU/. It only implements nine RV32I instructions, ADD, SUB, AND, OR,
XOR, ADDI, LW, SW and BEQ, which is enough for arithmetic, logic, memory and a branch. Everything
here is 32 bits.

| File | Module | Testbench | What it does |
| --- | --- | --- | --- |
| pc.v | `prog_counter` | `combined_tb.v` | Program counter, holds the address of the current instruction. Reset loads start_addr, otherwise it adds branch_step every clock, which is 4 to go to the next instruction. |
| inst_mem.v | `inst_mem` | `combined_tb.v` | Instruction memory, depth words loaded from iData.hex with $readmemh. The address is a byte address, so it drops the bottom two bits to pick the word. |
| iData.hex | | | The test program, 14 instructions with a comment on each one. It uses all nine: addi x1 = 5 and x2 = 3, then add, sub, and, or into x3 to x6, sw x3 to address 0 and lw it back into x7, a beq on x3 and x7 that is taken and skips an addi to x8, addi x9 = 9, an addi to x0 to check it stays 0, xor into x10, and a beq x0, x0, 0 at the end that keeps the PC parked there. |
| data_mem.v | `data_mem` | `datamem_tb.v` | Data memory, depth words of width bits (32 by default). Writes happen on the clock edge when mem_rw = 1, reads are combinational. Like the instruction memory it drops the bottom two bits of the byte address to pick the word. |
| imm_gen.v | `imm_gen` | `imgen_tb.v` | Immediate generator. Looks at the opcode and pulls the immediate out of the instruction for I, S, B, U and J type, sign extended to 32 bits. B and J get a 0 added at the bottom since their offsets are always even. R type has no immediate so it gives 0. |
| controlUnit.v | `control_unit` | `control_unit_tb.v` | Control unit. Decodes the opcode, funct3 and funct7 into the ALU op and the control signals: alu_src (rs2 or the immediate into the ALU), mem_rw (write data memory), mem_reg (ALU result or data memory into rd), reg_write and branch_step. Handles the nine instructions, any other opcode gets the defaults and writes nothing. |
| cpu_top.v | `cpu_top` | `cputop_tb.v` | The whole single cycle datapath. The PC feeds the instruction memory, the instruction goes to the control unit, immediate generator and register file, the ALU runs at 32 bits on rs1 and either rs2 or the immediate, and the result goes to the data memory address or back to rd. For beq the ALU subtracts and if zero is set the PC adds the immediate instead of 4. |

combined_tb.v connects the program counter to the instruction memory, steps the PC by 4 and prints
the address and the instruction fetched from it, so it checks the fetch part of the datapath. It
has to be run from CPU/ since $readmemh looks for iData.hex in the folder it is run from.

datamem_tb.v writes five words to addresses 0 to 16 and then reads them all back. imgen_tb.v feeds
the immediate generator a positive and a negative example of each instruction type (addi, lw, sw,
beq, lui, jal) plus an add, which should give 0. control_unit_tb.v feeds the control unit one of
each supported instruction plus a lui to check it falls back to the defaults.

cputop_tb.v resets the core, runs it for 15 clocks and on every falling edge prints the
instruction, the PC, what is being written to which register, the data memory signals and the
branch and zero signals, so each instruction can be followed through the datapath.

cpu_top.v pulls in the ALU and the register file from Combinational/ and Sequential/, and CPU/ sits
one folder higher than those, so their own includes only resolve with -grelative-include:

```
cd CPU
iverilog -grelative-include -o cputop_tb.vvp cputop_tb.v
vvp cputop_tb.vvp
```

## Notes to self

The testbenches mostly don't check themselves. They print with $monitor or $display and I compare
it to the truth table by eye. The barrel shifter one prints the expected value next to the actual
one so I am not working it out in my head every time. The ALU is the first one that really checks
itself, the self-checking testbench and the cocotb test both pass or fail on their own, and that is
the direction I want the rest of them to go. Most of them dump a vcd too so I can open it in
GTKWave and confirm it there instead of only trusting the terminal. Once the blocks get bigger than
a truth table the checking goes into cocotb, the same way it did for the ALU.

Where the width is the interesting part (adder, decoder, comparator) the module is written with a
parameter N and the testbench picks the actual width when it instantiates it. Keeping them
parameterized means I can pull the same modules into the datapath without rewriting them. The ALU
and add_sub work that way now too, the ALU takes a width and passes it to add_sub, which passes it
to the ripple carry adder. They default to 8 bits and go to 32 for the RISC-V core just by setting
the parameter.

The latches and the D flip flop don't have a reset, so Q sits at x in simulation until something
actually gets written into it. The JK and T ones do, both synchronous, so the reset only takes
effect on a clock edge. The T flip flop is where this actually mattered, without the reset it
never gets out of x. The register has one too, so once the register file is built out of it the
core starts up in a known state.

## What is next

The ALU verification is done. The self-checking testbench works out the expected result and flags
for every op and reports a pass or fail on its own, and the cocotb test runs the same checks
against a Python model.

The core is wired together in cpu_top.v and runs all nine instructions: add, sub, and, or, xor,
addi, lw, sw and beq. The ALU's existing 3 bit op already covers everything they need, add for
addi, lw and sw, and sub for beq, which branches when the zero flag is set.

cputop_tb.v runs a program that uses all nine and prints every cycle, and the registers and data
memory end up with the right values. Next is making it check itself, comparing the registers and
data memory at the end against the expected values instead of reading the printout, then the same
checks in cocotb. After that Yosys and nextpnr to get it synthesized and placed and routed.
