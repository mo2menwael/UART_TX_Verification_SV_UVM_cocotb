
# 🔧 UART Transmitter Verification

## 📘 Description

This project focuses on the **functional and formal verification** of a simplified **UART Transmitter** design module using **SystemVerilog**, **UVM**, and **Cocotb** methodologies. The design implements a basic UART transmission protocol with optional parity support and busy indication.

The verification process includes:
- **SystemVerilog testbench with assertions and coverage**.
- **Full UVM environment** to test constrained-random stimulus and comprehensive checking.
- **Cocotb-based verification** for a modern Python-based test environment with reusable test logic.
- Detailed reports for **code coverage**, **functional coverage**, and **assertion coverage**.

## 📁 Repository Structure

```
.
├── RTL/
│   └── uart_tx.sv                 # UART Transmitter RTL design
├── SV_Part/
│   ├── tb_top.sv                 # Top testbench module
│   ├── uart_tx_if.sv            # Interface
│   ├── uart_tx_sva.sv           # SVA assertions
│   ├── monitor.sv               # Testbench monitor
│   ├── golden_model.sv          # Optional model for reference
│   ├── dofile.tcl               # QuestaSim script
│   └── coverage_reports/        # Code + functional coverage
├── UVM_Part/
│   ├── test/                    # UVM test
│   ├── env/                     # Environment files
│   ├── agent/                   # Agent + Driver + Monitor
│   ├── scoreboard/              # Scoreboard and functional checking
│   ├── sequences/               # Sequence and sequence items
│   ├── coverage/                # Coverage collector
│   ├── config/                  # UVM configuration object
│   └── transcript.log           # UVM simulation output
├── cocotb/                      # Cocotb Python-based verification
│   ├── test_uart_tx.py          # Cocotb testbench
│   └── Makefile                 # Cocotb makefile
├── Verification_of_UART_Transmitter.pdf  # Project documentation
└── README.md
```

## 🛠️ UART Transmitter Design

- **Inputs**: `clk`, `reset`, `P_DATA[7:0]`, `PAR_EN`, `PAR_TYP`, `DATA_VALID`
- **Outputs**: `TX_OUT`, `Busy`
- **Features**:
  - Frame format: Start Bit → 8-bit Data → Optional Parity Bit → Stop Bit
  - Parity selection: Even or Odd based on `PAR_TYP`
  - `Busy` signal to prevent accepting new data mid-transmission

## ✅ Verification Overview

### 1. **SystemVerilog Part**
- **Directed tests** using interface and monitors
- **Assertions** for protocol checks (≥12 assertions)
- **100% coverage**: condition, toggle, statement, branch (with exclusion justifications)
- Functional coverage on:
  - Signal values (PAR_EN, PAR_TYP, DATA_VALID)
  - Cross coverages (e.g., `PAR_EN` × `PAR_TYP`, `TX_OUT` × `Busy`)
- **QuestaSim** used for simulation and coverage

### 2. **UVM Part**
- Structured UVM environment with:
  - Agent, Driver, Monitor
  - Scoreboard, Sequences, Config object
- Constrained-random stimulus + functional coverage
- Reset and Main sequences
- Optional Golden model comparison
- **Assertion Binding** in top

### 3. **Cocotb Part**
- Python-based verification using Cocotb
- Test scenarios written in Python
- Easy waveform generation and self-checking using `assert` statements
- Useful for integration with CI/CD systems

## 📊 Coverage Highlights

| Type              | Goal       | Achieved |
|-------------------|------------|----------|
| Code Coverage     | 100%       | ✅        |
| Functional Coverage | 100%     | ✅        |
| Assertion Coverage | ≥12 Checks | ✅        |

## 🚀 How to Run

### SystemVerilog (QuestaSim)
```bash
cd SV_Part/
vsim -do dofile.tcl
```

### UVM Simulation
```bash
cd UVM_Part/
vsim -do dofile.tcl
```

### Cocotb
```bash
cd cocotb/
make
```
