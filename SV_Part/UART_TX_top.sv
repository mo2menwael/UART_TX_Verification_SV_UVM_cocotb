// verilog_lint: waive-start line-length

module UART_TX_top();
    bit clk;

    always #5 clk = ~clk;

    UART_TX_if UART_TX_IF (clk);

    UART_TX DUT (UART_TX_IF);

    UART_TX_TB TEST (UART_TX_IF);

    UART_TX_monitor MONITOR (UART_TX_IF);

    bind UART_TX UART_TX_SVA UART_TX_SVA_inst (UART_TX_IF);
endmodule
