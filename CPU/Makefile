# The sim to run tests with
SIM = icarus

# The top level language used for design
TOPLEVEL_LANG = verilog

# List of verilog source files
VERILOG_SOURCES = cpu_top.v

# Name of the top level module in the design
COCOTB_TOPLEVEL = cpu_top

# The python test module for the file
COCOTB_TEST_MODULES = test_cpu

# Enable wave generation
WAVES = 1

# Compile Argument
COMPILE_ARGS += -grelative-include

# Includes cocotb's Makefiles which define the build and simulation flows for each supported simulator.
# This must be included *after* all of the variables above are defined.
include $(shell cocotb-config --makefiles)/Makefile.sim