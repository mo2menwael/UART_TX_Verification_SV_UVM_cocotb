// verilog_lint: waive-start package-filename

package env_pkg;

import uvm_pkg::*;
import agent_pkg::*;
import scoreboard_pkg::*;
import coverage_pkg::*;
`include "uvm_macros.svh"

class UART_TX_env extends uvm_env;
    `uvm_component_utils(UART_TX_env)

    UART_TX_agent agt;
    UART_TX_scoreboard sb;
    UART_TX_coverage cov;

    function new(string name = "UART_TX_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = UART_TX_agent::type_id::create("agt", this);
        sb = UART_TX_scoreboard::type_id::create("sb", this);
        cov = UART_TX_coverage::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.agt_ap_scoreboard.connect(sb.sc_export);
        agt.agt_ap_coverage.connect(cov.cov_export);
    endfunction
endclass

endpackage
