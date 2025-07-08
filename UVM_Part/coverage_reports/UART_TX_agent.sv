// verilog_lint: waive-start package-filename

package agent_pkg;
    import uvm_pkg::*;
    import driver_pkg::*;
    import monitor_pkg::*;
    import config_obj_pkg::*;
    import sequencer_pkg::*;
    import seq_item_pkg::*;
    `include "uvm_macros.svh"

    class UART_TX_agent extends uvm_agent;
        `uvm_component_utils(UART_TX_agent)

        UART_TX_driver drv;
        UART_TX_monitor mtr;
        UART_TX_sequencer sqr;
        UART_TX_config cfg_obj;
        uvm_analysis_port #(UART_TX_sequence_item) agt_ap_scoreboard;
        uvm_analysis_port #(UART_TX_sequence_item) agt_ap_coverage;

        function new(string name = "UART_TX_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            if (~uvm_config_db#(UART_TX_config)::get(this, "", "CFG", cfg_obj)) begin
                `uvm_fatal("build_phase", "In Agent, Failed to get CFG from config db")
            end

            drv = UART_TX_driver::type_id::create("drv", this);
            mtr = UART_TX_monitor::type_id::create("mtr", this);
            sqr = UART_TX_sequencer::type_id::create("sqr", this);
            agt_ap_scoreboard = new("agt_ap_scoreboard", this);
            agt_ap_coverage = new("agt_ap_coverage", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            drv.uart_tx_vif = cfg_obj.uart_tx_vif;
            mtr.uart_tx_vif = cfg_obj.uart_tx_vif;
            drv.seq_item_port.connect(sqr.seq_item_export);
            mtr.mtr_ap_scoreboard.connect(agt_ap_scoreboard);
            mtr.mtr_ap_coverage.connect(agt_ap_coverage);
        endfunction
    endclass
endpackage
