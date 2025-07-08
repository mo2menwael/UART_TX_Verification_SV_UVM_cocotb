
# UART Transmitter Verification

## Description

This project focuses on the **functional verification** of a simplified **UART Transmitter** design module using **SystemVerilog**, **UVM**, and **cocotb** (a Python-based verification framework) methodologies. The design implements a basic UART transmission protocol with optional parity support and busy indication.

The verification process includes:
- **SystemVerilog testbench with assertions and coverage**.
- **Full UVM environment** to test constrained-random stimulus and comprehensive checking.
- **cocotb-based verification** for a modern Python-based test environment.
- Detailed reports for **code coverage**, **functional coverage**, and **assertion coverage**.

## Repository Structure

```
.
├── SV_Part/
│   ├── UART_TX.sv                  # UART Transmitter RTL design
│   ├── UART_TX_top.sv              # Top testbench module
│   ├── UART_TX_if.sv               # Interface
│   ├── UART_TX_SVA.sv              # SVA assertions
│   ├── UART_TX_monitor.sv          # Signals monitor
│   ├── UART_TX_PKG.sv              # Class for randomization and covergroups
│   ├── UART_TX_TB.sv               # Testbench
│   ├── run.do                      # Simulation run script
│   └── coverage_reports/           # Code, functional, and assertions coverage
├── UVM_Part/
│   ├── UART_TX.sv                  # UART Transmitter RTL design
│   ├── UART_TX_top.sv              # Top module for testbench
│   ├── UART_TX_agent.sv            # UVM Agent
│   ├── UART_TX_driver.sv           # Driver component
│   ├── UART_TX_monitor.sv          # Monitor component
│   ├── UART_TX_env.sv              # UVM Environment
│   ├── UART_TX_scoreboard.sv       # Scoreboard for checking output
│   ├── UART_TX_test.sv             # UVM Test
│   ├── UART_TX_sequence_item.sv    # UVM Sequence item
│   ├── UART_TX_main_sequence.sv    # Main sequence logic
│   ├── UART_TX_sequencer.sv        # Sequencer
│   ├── UART_TX_if.sv               # Virtual interface
│   ├── UART_TX_coverage.sv         # Functional coverage
│   ├── UART_TX_reset_sequence.sv   # Reset sequence
│   ├── UART_TX_SVA.sv              # SystemVerilog Assertions
│   ├── Config_obj.sv               # UVM Configuration object
│   ├── run.do                      # Simulation run script
│   └── coverage_reports/           # Code, functional, and assertions coverage
├── cocotb/
│   ├── UART_TX.v                   # UART Transmitter RTL design
│   ├── testbench.py                # cocotb testbench
│   ├── Makefile                    # cocotb makefile
│   └── cleanall.mk                 # Additional cleanup Makefile (removes generated files)
└── README.md
```

## UART Transmitter Design

- **Inputs**: `clk`, `reset`, `P_DATA[7:0]`, `PAR_EN`, `PAR_TYP`, `DATA_VALID`
- **Outputs**: `TX_OUT`, `Busy`
- **Features**:
  - Frame format: Start Bit → 8-bit Data → Optional Parity Bit → Stop Bit
  - Parity selection: Even or Odd based on `PAR_TYP`

## Verification Overview

### 1. **SystemVerilog Part**
- **Random tests** using interface and monitor
- **Assertions** for protocol checks
- **100% coverage**: condition, toggle, statement, branch (with exclusion justifications)
- Functional coverage on:
  - Signal values (PAR_EN, PAR_TYP, DATA_VALID)
  - Cross coverages (e.g., `PAR_EN` × `PAR_TYP`, `TX_OUT` × `Busy`)
- **QuestaSim or ModelSim** used for simulation and coverage

### 2. **UVM Part**
- Structured UVM environment with:
  - Agent, Driver, Monitor
  - Scoreboard, Sequences, Config object
- Constrained-random stimulus + functional coverage
- Reset and Main sequences
- **QuestaSim** used for simulation and coverage as **ModelSim doesn't support UVM**

### 3. **cocotb Part**
- Python-based verification using cocotb
- Test scenarios written in Python
- Useful for integration with CI/CD systems

## 📊 Coverage Highlights

| Type                | Goal       | Achieved |
|---------------------|------------|----------|
| Code Coverage       | 100%       | ✅      |
| Functional Coverage | 100%       | ✅      |
| Assertion Coverage  | 100%       | ✅      |

## 🚀 How to Run

### SystemVerilog
create a new project in QuestaSim or ModelSim for the SV part and add all existing files in SV_Part

```bash
cd SV_Part/
vsim -do run.do
```

### UVM Simulation
create a new project in QuestaSim for the UVM part and add all existing files in UVM_Part

```bash
cd UVM_Part/
vsim -do run.do
```

### cocotb
#### Install cocotb library in your python environment
```bash
pip install cocotb
```
#### Run using makefile
```bash
cd cocotb/
make
```
