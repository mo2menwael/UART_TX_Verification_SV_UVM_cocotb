// verilog_lint: waive-start package-filename

package config_obj_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

class UART_TX_config extends uvm_object;
    `uvm_object_utils(UART_TX_config)

    virtual UART_TX_if uart_tx_vif;

    function new(string name = "UART_TX_config");
        super.new(name);
    endfunction
endclass

endpackage
