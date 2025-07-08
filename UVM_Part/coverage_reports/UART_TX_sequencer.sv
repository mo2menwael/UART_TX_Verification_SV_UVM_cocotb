// verilog_lint: waive-start package-filename

package sequencer_pkg;
    import uvm_pkg::*;
    import seq_item_pkg::*;
    `include "uvm_macros.svh"

    class UART_TX_sequencer extends uvm_sequencer #(UART_TX_sequence_item);
        `uvm_component_utils(UART_TX_sequencer)

        function new(string name = "UART_TX_sequencer", uvm_component parent = null);
            super.new(name, parent);
        endfunction
    endclass
endpackage
