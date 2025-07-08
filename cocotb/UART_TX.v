// verilog_lint: waive-start explicit-parameter-storage-type
// verilog_lint: waive-start case-missing-default

module UART_TX (
    input wire clk,
    input wire reset,
    input wire [7:0] P_DATA,
    input wire PAR_EN,
    input wire PAR_TYP,
    input wire DATA_VALID,
    output reg TX_OUT,
    output reg Busy
);

    parameter IDLE = 0, START = 1, DATA = 2, PARITY = 3, STOP = 4;

    reg [3:0] state = IDLE;
    reg [3:0] counter = 0;
    reg [7:0] data_reg;
    reg parity_bit;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            state <= IDLE;
            TX_OUT <= 1'b1;
            Busy <= 1'b0;
            counter <= 0;
        end else begin
            case (state)
                IDLE: begin
                    TX_OUT <= 1'b1;
                    Busy <= 1'b0;
                    counter <= 0;
                    if (DATA_VALID) begin
                        data_reg <= P_DATA;
                        parity_bit <= (PAR_TYP == 0) ? ~^P_DATA : ^P_DATA;
                        state <= START;
                        Busy <= 1'b1;
                    end
                end
                START: begin
                    TX_OUT <= 1'b0;
                    state <= DATA;
                    counter <= 0;
                end
                DATA: begin
                    TX_OUT <= data_reg[counter];
                    counter <= counter + 1;
                    if (counter == 7)
                        state <= (PAR_EN) ? PARITY : STOP;
                end
                PARITY: begin
                    TX_OUT <= parity_bit;
                    state <= STOP;
                end
                STOP: begin
                    TX_OUT <= 1'b1;
                    state <= IDLE;
                end
            endcase
        end
    end

initial begin
    $dumpfile("UART_TX.vcd");
    $dumpvars(0, UART_TX);
end

endmodule
