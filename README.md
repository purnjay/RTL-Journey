# Learning FPGA Dev

RTL building blocks I am writing from scratch in Verilog, on the way to a single cycle processor
core running RV32I, the base 32 bit RISC-V instruction set. Combinational/ has the blocks that are just logic and Sequential/ has
the ones that hold state. Each folder inside them is one piece of the datapath with its design
file, a testbench for it, and usually a waveform dump. FSMs/ has the state machines, which aren't
part of the datapath but the control unit is going to be one. Small_Systems/ has small blocks
that stand on their own, like the FIFO.

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

Next is verifying the ALU properly, first with a self-checking testbench and then in cocotb, and
after that the single cycle RV32I core. Both are in What is next at the bottom.

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
module it tests, `<module>_tb.v`. The Flip Flop folder has a space in it,
so put quotes around it when you cd in.

Every module sits at the same depth on purpose, so the .. in the includes always points at the
folder holding all of them and the same two commands work everywhere, ALU included.

The .v.out and .vcd files sitting in the folders are just compiler and simulation output, the
commands above make them again.

## The ALU

`Combinational/ALU/ALU.v`, 8 bits wide, and this is where phase 1 ends up. A 3 bit op picks the
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

carry and overflow both come off the add_sub path, so they only really mean anything on ADD and
SUB. The logic ops leave whatever the adder happened to produce sitting on them.

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
| add_sub | `add_sub` | `add_sub_tb.v` | 8 bit adder/subtractor using the ripple carry adder. sel = 0 adds, sel = 1 XORs b and sets the carry in to 1 to subtract. Also outputs overflow and carry out. |
| barrel_shifter | `barrel_shifter` | `barrel_shifter_tb.v` | 8 bit left shift by 0 to 7, done in three stages that shift by 1, 2 and 4. |
| ALU | `ALU` | `ALU_tb.v` | Puts everything above together, the opcodes are in the ALU section. |

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
| Shift Registers | `PIPO` | none yet | Parallel in parallel out, q takes all of d every clock. Same as the register without en. |
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

## Notes to self

The testbenches mostly don't check themselves. They print with $monitor or $display and I compare
it to the truth table by eye. The barrel shifter one is the exception, it prints the expected
value next to the actual one so I am not working it out in my head every time, and that is the
direction I want the rest of them to go. Most of them dump a vcd too so I can open it in GTKWave
and confirm it there instead of only trusting the terminal. Once the blocks get bigger than a
truth table I want to move the checking into cocotb so the tests actually pass or fail on their
own.

Where the width is the interesting part (adder, decoder, comparator) the module is written with a
parameter N and the testbench picks the actual width when it instantiates it. Keeping them
parameterized means I can pull the same modules into the datapath without rewriting them, which
is what add_sub does when it instantiates the ripple carry adder at N = 8. The units that are
part of the datapath itself are fixed at 8 bits for now, they need to go up to 32 bits for the
RISC-V core.

The latches and the D flip flop don't have a reset, so Q sits at x in simulation until something
actually gets written into it. The JK and T ones do, both synchronous, so the reset only takes
effect on a clock edge. The T flip flop is where this actually mattered, without the reset it
never gets out of x. The register has one too, so once the register file is built out of it the
core starts up in a known state.

## What is next

Before the core, the ALU needs real verification. First a self-checking testbench that works out
the expected result and flags for every op and reports a pass or fail on its own, then the same
checks moved into cocotb.

The core is going to be a single cycle RV32I, so the ALU and the barrel shifter have to go from
8 bits up to 32. The ALU also needs a 4 bit op since RV32I has ADD, SUB, AND, OR, XOR, SLL, SRL,
SRA, SLT and SLTU. The barrel shifter needs to shift by 0 to 31 and shift right too, both logical
and arithmetic, and then it goes into the ALU. RISC-V has no flags, branches compare two
registers directly, so the comparator turns into the branch unit.

The register file already matches, 32 registers of 32 bits with x0 always reading 0. What is left
to build is the program counter, the immediate generator, instruction and data memory, the
control unit and the next PC logic for branches and jumps. I am going to get R type instructions
working first, then I type, then loads and stores, then branches and jumps.

Since it is standard RISC-V I can compile real programs with the RISC-V GCC toolchain and check
the core against the official riscv-tests. Then cocotb testbenches, and Yosys and nextpnr to get
it synthesized and placed and routed.
