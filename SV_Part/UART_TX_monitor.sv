// verilog_lint: waive-start line-length

module UART_TX_monitor (UART_TX_if.MONITOR UART_TX_IF);

always @(posedge UART_TX_IF.clk) begin
    $display("At time %0t: reset = %1b | P_DATA = %8b | PAR_EN = %1b | PAR_TYP = %1b | DATA_VALID = %1b | TX_OUT = %1b | Busy = %1b",
              $time, UART_TX_IF.reset, UART_TX_IF.P_DATA, UART_TX_IF.PAR_EN, UART_TX_IF.PAR_TYP, UART_TX_IF.DATA_VALID, UART_TX_IF.TX_OUT, UART_TX_IF.Busy);
end

endmodule
