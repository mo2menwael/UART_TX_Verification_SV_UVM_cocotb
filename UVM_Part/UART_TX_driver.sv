// verilog_lint: waive-start package-filename
// verilog_lint: waive-start invalid-system-task-function

package driver_pkg;

import uvm_pkg::*;
import config_obj_pkg::*;
import seq_item_pkg::*;
`include "uvm_macros.svh";

class UART_TX_driver extends uvm_driver #(UART_TX_sequence_item);
    `uvm_component_utils(UART_TX_driver)

    virtual UART_TX_if uart_tx_vif;
    UART_TX_sequence_item seq_item;

    function new(string name = "UART_TX_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        @(negedge uart_tx_vif.clk);
        forever begin
            seq_item = UART_TX_sequence_item::type_id::create("seq_item", this);
            seq_item_port.get_next_item(seq_item);

            uart_tx_vif.reset = seq_item.reset;
            uart_tx_vif.P_DATA = seq_item.P_DATA;
            uart_tx_vif.PAR_EN = seq_item.PAR_EN;
            uart_tx_vif.PAR_TYP = seq_item.PAR_TYP;
            uart_tx_vif.DATA_VALID = seq_item.DATA_VALID;

            `uvm_info("run_phase", seq_item.convert2string_stimulus(), UVM_MEDIUM);

            if (~uart_tx_vif.reset || ~uart_tx_vif.DATA_VALID) begin
                @(negedge uart_tx_vif.clk);
            end
            else begin
                if (uart_tx_vif.PAR_EN) begin
                    @(negedge uart_tx_vif.clk);
                    uart_tx_vif.DATA_VALID = 1'b0;
                    repeat(11) @(negedge uart_tx_vif.clk);
                end
                else begin
                    @(negedge uart_tx_vif.clk);
                    uart_tx_vif.DATA_VALID = 1'b0;
                    repeat(10) @(negedge uart_tx_vif.clk);
                end
            end

            seq_item_port.item_done();
        end
    endtask

endclass

endpackage
