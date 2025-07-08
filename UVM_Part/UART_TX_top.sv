// verilog_lint: waive-start line-length

import uvm_pkg::*;
import test_pkg::*;
`include "uvm_macros.svh"

module UART_TX_top();
    bit clk;
    always #5 clk = ~clk;

    UART_TX_if UART_TX_IF (clk);

    UART_TX DUT (UART_TX_IF);

    initial begin
        uvm_config_db#(virtual UART_TX_if)::set(null, "uvm_test_top", "UART_TX_IF", UART_TX_IF);
        run_test("UART_TX_test");
    end

    bind UART_TX UART_TX_SVA UART_TX_SVA_inst (UART_TX_IF);
endmodule
