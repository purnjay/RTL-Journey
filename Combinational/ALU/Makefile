# The sim to run tests with
SIM = icarus

# The top level language used for design
TOPLEVEL_LANG = verilog

# List of verilog source files
VERILOG_SOURCES = ALU.v

# Name of the top level module in the design
COCOTB_TOPLEVEL = ALU 

# The python test module for the file
COCOTB_TEST_MODULES = test_alu 

# Enable wave generation
WAVES = 1

# Includes cocotb's Makefiles which define the build and simulation flows for each supported simulator.
# This must be included *after* all of the variables above are defined.
include $(shell cocotb-config --makefiles)/Makefile.sim