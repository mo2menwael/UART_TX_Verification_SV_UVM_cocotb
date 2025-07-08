// verilog_lint: waive-start package-filename

package main_sequence_pkg;
    import uvm_pkg::*;
    import seq_item_pkg::*;
    `include "uvm_macros.svh"

    class UART_TX_main_sequence extends uvm_sequence #(UART_TX_sequence_item);
        `uvm_object_utils(UART_TX_main_sequence)

        UART_TX_sequence_item seq_item;

        function new(string name = "UART_TX_main_sequence");
            super.new(name);
        endfunction

        task body();
            repeat(5000) begin
                seq_item = UART_TX_sequence_item::type_id::create("seq_item");
                start_item(seq_item);
                assert(seq_item.randomize());
                finish_item(seq_item);
            end
        endtask
    endclass
endpackage
