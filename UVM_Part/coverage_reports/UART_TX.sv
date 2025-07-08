// verilog_lint: waive-start case-missing-default
// verilog_lint: waive-start explicit-parameter-storage-type
// verilog_lint: waive-start line-length

module UART_TX (UART_TX_if.DUT UART_TX_IF);

parameter IDLE = 0, START = 1, DATA = 2, PARITY = 3, STOP = 4;

reg [3:0] state = IDLE;
reg [3:0] counter = 0;
reg [7:0] data_reg;
reg parity_bit;

always @(posedge UART_TX_IF.clk or negedge UART_TX_IF.reset) begin
    if (!UART_TX_IF.reset) begin
        state <= IDLE;
        UART_TX_IF.TX_OUT <= 1'b1;
        UART_TX_IF.Busy <= 1'b0;
        counter <= 0;
    end else begin
        case (state)
            IDLE: begin
                UART_TX_IF.TX_OUT <= 1'b1;
                UART_TX_IF.Busy <= 1'b0;
                counter <= 0;
                if (UART_TX_IF.DATA_VALID) begin
                    data_reg <= UART_TX_IF.P_DATA;
                    parity_bit <= (UART_TX_IF.PAR_TYP == 0) ? ~^UART_TX_IF.P_DATA : ^UART_TX_IF.P_DATA;
                    state <= START;
                    UART_TX_IF.Busy <= 1'b1;
                end
            end

            START: begin
                UART_TX_IF.TX_OUT <= 1'b0;
                state <= DATA;
                counter <= 0;
            end

            DATA: begin
                UART_TX_IF.TX_OUT <= data_reg[counter];
                counter <= counter + 1;
                if (counter == 7)
                    state <= (UART_TX_IF.PAR_EN) ? PARITY : STOP;
            end

            PARITY: begin
                UART_TX_IF.TX_OUT <= parity_bit;
                state <= STOP;
            end

            STOP: begin
                UART_TX_IF.TX_OUT <= 1'b1;
                state <= IDLE;
            end
        endcase
    end
end

endmodule
