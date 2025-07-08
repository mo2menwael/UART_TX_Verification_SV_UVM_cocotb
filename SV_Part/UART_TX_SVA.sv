// verilog_lint: waive-start explicit-parameter-storage-type
// verilog_lint: waive-start unpacked-dimensions-range-ordering
// verilog_lint: waive-start line-length
// verilog_lint: waive-start enum-name-style
// verilog_lint: waive-start typedef-enums

module UART_TX_SVA (UART_TX_if.SVA UART_TX_IF);

typedef enum bit [2:0] {
        IDLE   = 3'b000,
        START  = 3'b001,
        DATA   = 3'b011,
        PARITY = 3'b010,
        STOP   = 3'b110
} STATE;

STATE state;
reg [3:0] counter = 0;

// Golden Model for FSM of UART_TX
always @(posedge UART_TX_IF.clk or negedge UART_TX_IF.reset) begin
    if (!UART_TX_IF.reset) begin
        state <= IDLE;
        counter <= 0;
    end
    else begin
        case (state)
            IDLE: begin
                counter <= 0;
                if (UART_TX_IF.DATA_VALID) begin
                    state <= START;
                end
            end
            START: begin
                state <= DATA;
                counter <= 0;
            end
            DATA: begin
                counter <= counter + 1;
                if (counter == 7)
                    state <= (UART_TX_IF.PAR_EN) ? PARITY : STOP;
            end
            PARITY: begin
                state <= STOP;
            end
            STOP: begin
                state <= IDLE;
            end
            default: begin
                state <= IDLE;
            end
        endcase
    end
end


always_comb begin
    if (!UART_TX_IF.reset) begin
        Reset_a: assert final (UART_TX_IF.TX_OUT && ~UART_TX_IF.Busy) else $error("Reset Violation detected!");
        Reset_c: cover  final (UART_TX_IF.TX_OUT && ~UART_TX_IF.Busy);
    end
end

property start_bit_p;
    @(posedge UART_TX_IF.clk) disable iff (!UART_TX_IF.reset)
    ((UART_TX_IF.P_DATA != $past(UART_TX_IF.P_DATA)) && UART_TX_IF.DATA_VALID) |=> ##1 (~UART_TX_IF.TX_OUT);
endproperty

property Data_Bits_p;
    @(posedge UART_TX_IF.clk) disable iff (!UART_TX_IF.reset)
    ((UART_TX_IF.P_DATA != $past(UART_TX_IF.P_DATA)) && UART_TX_IF.DATA_VALID)
    |=> ##2 (UART_TX_IF.TX_OUT == UART_TX_IF.P_DATA[0])
    ##1 (UART_TX_IF.TX_OUT == UART_TX_IF.P_DATA[1])
    ##1 (UART_TX_IF.TX_OUT == UART_TX_IF.P_DATA[2])
    ##1 (UART_TX_IF.TX_OUT == UART_TX_IF.P_DATA[3])
    ##1 (UART_TX_IF.TX_OUT == UART_TX_IF.P_DATA[4])
    ##1 (UART_TX_IF.TX_OUT == UART_TX_IF.P_DATA[5])
    ##1 (UART_TX_IF.TX_OUT == UART_TX_IF.P_DATA[6])
    ##1 (UART_TX_IF.TX_OUT == UART_TX_IF.P_DATA[7]);
endproperty

property odd_parity_p;
    @(posedge UART_TX_IF.clk) disable iff (!UART_TX_IF.reset)
    ((UART_TX_IF.P_DATA != $past(UART_TX_IF.P_DATA)) && UART_TX_IF.PAR_EN && UART_TX_IF.PAR_TYP && UART_TX_IF.DATA_VALID) |=> ##10 (UART_TX_IF.TX_OUT == ^UART_TX_IF.P_DATA);
endproperty

property even_parity_p;
    @(posedge UART_TX_IF.clk) disable iff (!UART_TX_IF.reset)
    ((UART_TX_IF.P_DATA != $past(UART_TX_IF.P_DATA)) && UART_TX_IF.PAR_EN && ~UART_TX_IF.PAR_TYP && UART_TX_IF.DATA_VALID) |=> ##10 (UART_TX_IF.TX_OUT == ~^UART_TX_IF.P_DATA);
endproperty

property stop_bit_WithParity_p;
    @(posedge UART_TX_IF.clk) disable iff (!UART_TX_IF.reset)
    ((UART_TX_IF.P_DATA != $past(UART_TX_IF.P_DATA)) && UART_TX_IF.PAR_EN && UART_TX_IF.DATA_VALID) |=> ##11 (UART_TX_IF.TX_OUT);
endproperty

property stop_bit_WithoutParity_p;
    @(posedge UART_TX_IF.clk) disable iff (!UART_TX_IF.reset)
    ((UART_TX_IF.P_DATA != $past(UART_TX_IF.P_DATA)) && ~UART_TX_IF.PAR_EN && UART_TX_IF.DATA_VALID) |=> ##10 (UART_TX_IF.TX_OUT);
endproperty

property busy_WithParity_p;
    @(posedge UART_TX_IF.clk) disable iff (!UART_TX_IF.reset)
    ((UART_TX_IF.P_DATA != $past(UART_TX_IF.P_DATA)) && UART_TX_IF.PAR_EN && UART_TX_IF.DATA_VALID) |=> (UART_TX_IF.Busy[*11]);
endproperty

property busy_WithoutParity_p;
    @(posedge UART_TX_IF.clk) disable iff (!UART_TX_IF.reset)
    ((UART_TX_IF.P_DATA != $past(UART_TX_IF.P_DATA)) && ~UART_TX_IF.PAR_EN && UART_TX_IF.DATA_VALID) |=> (UART_TX_IF.Busy[*10]);
endproperty

property idle_when_not_busy_p;
  @(posedge UART_TX_IF.clk) disable iff (!UART_TX_IF.reset)
  (!UART_TX_IF.Busy) |-> (UART_TX_IF.TX_OUT);
endproperty

property idle_state_txout_p;
  @(posedge UART_TX_IF.clk) disable iff (!UART_TX_IF.reset)
  (state == IDLE && ~UART_TX_IF.DATA_VALID) |=> (UART_TX_IF.TX_OUT && ~UART_TX_IF.Busy);
endproperty

property reset_counter_IDLE_or_START_or_RESET_p;
  @(posedge UART_TX_IF.clk)
  (state == IDLE || state == START || !UART_TX_IF.reset) |=> (counter == 0);
endproperty

property illegal_transitions_p;
  @(posedge UART_TX_IF.clk) disable iff (!UART_TX_IF.reset)
  1 |-> (
    ($past(state) == IDLE)   -> !(state inside {DATA, PARITY, STOP}) &&
    ($past(state) == START)  -> !(state inside {IDLE, PARITY, STOP}) &&
    ($past(state) == DATA)   -> !(state inside {IDLE, START})        &&
    ($past(state) == PARITY) -> !(state inside {IDLE, START, DATA})  &&
    ($past(state) == STOP)   -> !(state inside {START, DATA, PARITY})
  );
endproperty


Odd_Parity_a: assert property (odd_parity_p) else $error("Odd Parity Violation detected!");
Odd_Parity_c: cover property (odd_parity_p);

Even_Parity_a: assert property (even_parity_p) else $error("Even Parity Violation detected!");
Even_Parity_c: cover property (even_parity_p);

Start_Bit_a: assert property (start_bit_p) else $error("Start Bit Violation detected!");
Start_Bit_c: cover property (start_bit_p);

Stop_Bit_With_Parity_a: assert property (stop_bit_WithParity_p) else $error("Stop Bit With Parity Violation detected!");
Stop_Bit_With_Parity_c: cover property (stop_bit_WithParity_p);

Stop_Bit_Without_Parity_a: assert property (stop_bit_WithoutParity_p) else $error("Stop Bit Without Parity Violation detected!");
Stop_Bit_Without_Parity_c: cover property (stop_bit_WithoutParity_p);

Busy_WithParity_a: assert property (busy_WithParity_p) else $error("Busy With Parity Violation detected!");
Busy_WithParity_c: cover property (busy_WithParity_p);

Busy_WithoutParity_a: assert property (busy_WithoutParity_p) else $error("Busy Without Parity Violation detected!");
Busy_WithoutParity_c: cover property (busy_WithoutParity_p);

Data_Bits_a: assert property (Data_Bits_p) else $error("Data Bits Violation detected!");
Data_Bits_c: cover property (Data_Bits_p);

Idle_When_Not_Busy_a: assert property (idle_when_not_busy_p) else $error("Idle When Not Busy Violation detected!");
Idle_When_Not_Busy_c: cover property (idle_when_not_busy_p);

idle_state_txout_a: assert property (idle_state_txout_p) else $error("Idle State TX_OUT Violation detected!");
idle_state_txout_c: cover property (idle_state_txout_p);

reset_counter_IDLE_or_START_or_RESET_a: assert property (reset_counter_IDLE_or_START_or_RESET_p) else $error("Reset Counter in IDLE or START or RESET State Violation detected!");
reset_counter_IDLE_or_START_or_RESET_c: cover property (reset_counter_IDLE_or_START_or_RESET_p);

illegal_transitions_a: assert property (illegal_transitions_p) else $error("Illegal Transitions Violation detected!");
illegal_transitions_c: cover property (illegal_transitions_p);

endmodule
