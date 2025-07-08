// verilog_lint: waive-start package-filename
// verilog_lint: waive-start line-length

package test_pkg;

import uvm_pkg::*;
import env_pkg::*;
import config_obj_pkg::*;
import main_sequence_pkg::*;
import reset_sequence_pkg::*;
`include "uvm_macros.svh"

class UART_TX_test extends uvm_test;
    `uvm_component_utils(UART_TX_test)

    UART_TX_env env;
    UART_TX_config cfg_obj;

    UART_TX_main_sequence main_seq;
    UART_TX_reset_sequence reset_seq;

    function new(string name = "UART_TX_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = UART_TX_env::type_id::create("env", this);
        cfg_obj = UART_TX_config::type_id::create("cfg_obj");
        main_seq = UART_TX_main_sequence::type_id::create("main_seq", this);
        reset_seq = UART_TX_reset_sequence::type_id::create("reset_seq", this);

        if (~uvm_config_db#(virtual UART_TX_if)::get(this, "", "UART_TX_IF", cfg_obj.uart_tx_vif)) begin
            `uvm_fatal("build_phase", "In Test, Failed to get V_IF from config db")
        end

        uvm_config_db#(UART_TX_config)::set(this, "*", "CFG", cfg_obj);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        phase.raise_objection(this);
            `uvm_info("run_phase","Main Sequence Started", UVM_MEDIUM)
            main_seq.start(env.agt.sqr);
            `uvm_info("run_phase","Main Sequence Finished", UVM_MEDIUM)

            `uvm_info("run_phase","Reset Sequence Started", UVM_MEDIUM)
            reset_seq.start(env.agt.sqr);
            `uvm_info("run_phase","Reset Sequence Finished", UVM_MEDIUM)
        phase.drop_objection(this);
    endtask
endclass

endpackage
