# defaults
COCOTB_REDUCED_LOG_FMT = True
SIM ?= questa
TOPLEVEL_LANG ?= verilog

# Add common Icarus Verilog or questa installation paths to PATH
export PATH := C:\questasim64_10.6c\win64:$(PATH)
#export PATH := C:\iverilog\bin:$(PATH)

# Adding Verilog sources
VERILOG_SOURCES += $(PWD)/UART_TX.v

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = UART_TX

# MODULE is the basename of the Python test file
MODULE = testbench

# set the HDL time unit and precision
COCOTB_HDL_TIMEUNIT = 1ns
COCOTB_HDL_TIMEPRECISION = 1ns

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
include cleanall.mk
