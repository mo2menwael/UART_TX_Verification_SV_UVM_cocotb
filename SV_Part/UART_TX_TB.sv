// verilog_lint: waive-start explicit-parameter-storage-type
// verilog_lint: waive-start explicit-task-lifetime
// verilog_lint: waive-start explicit-function-task-parameter-type
// verilog_lint: waive-start line-length

import UART_TX_PKG::*;

//----------------------------------------------------------------------------------//

module UART_TX_TB (UART_TX_if.TEST UART_TX_IF);

int correct_count, error_count;
logic [10:0] tx_out_combined, tx_out_combined_expected;
bit parity_bit;

UART_TX_class my_UART_TX = new();

//----------------------------------------------------------------------------------//

initial begin
    forever begin
        my_UART_TX.clk = UART_TX_IF.clk;
        my_UART_TX.TX_OUT = UART_TX_IF.TX_OUT;
        my_UART_TX.Busy = UART_TX_IF.Busy;

        @(posedge UART_TX_IF.clk);
        my_UART_TX.cvr_gp.sample();
    end
end

initial begin
    @(negedge UART_TX_IF.clk);
    repeat(8000) begin
        Randomization_assertion: assert(my_UART_TX.randomize());

        UART_TX_IF.reset = my_UART_TX.reset;
        UART_TX_IF.P_DATA = my_UART_TX.P_DATA;
        UART_TX_IF.PAR_EN = my_UART_TX.PAR_EN;
        UART_TX_IF.PAR_TYP = my_UART_TX.PAR_TYP;
        UART_TX_IF.DATA_VALID = my_UART_TX.DATA_VALID;

        if (~UART_TX_IF.reset || ~UART_TX_IF.DATA_VALID) begin
            check_idle();
        end
        else begin
            if (UART_TX_IF.PAR_EN) begin
                parity_bit = UART_TX_IF.PAR_TYP ? ^UART_TX_IF.P_DATA : ~^UART_TX_IF.P_DATA;
                tx_out_combined_expected = {1'b0, UART_TX_IF.P_DATA, parity_bit, 1'b1};
            end
            else begin
                tx_out_combined_expected = {1'b0, UART_TX_IF.P_DATA, 1'b1};
            end

            Data_Valid_Check();
        end
    end

    // Display counters
    $display("\nNumber of correct test cases = %0d\n", correct_count);
    $display("Number of failed test cases  = %0d\n", error_count);

    #20;
    $stop;
end

//----------------------------------------------------------------------------------//

task Data_Valid_Check();
    tx_out_combined = 0;

    if (UART_TX_IF.PAR_EN) begin
        // Start Bit
        repeat(2) @(negedge UART_TX_IF.clk);
        tx_out_combined[10] = UART_TX_IF.TX_OUT;

        // Data Bits
        for (int i = 2; i < 10; i = i + 1) begin
            @(negedge UART_TX_IF.clk);
            tx_out_combined[i] = UART_TX_IF.TX_OUT;
        end

        // Parity Bit
        @(negedge UART_TX_IF.clk);
        tx_out_combined[1] = UART_TX_IF.TX_OUT;

        // Stop Bit
        @(negedge UART_TX_IF.clk);
        tx_out_combined[0] = UART_TX_IF.TX_OUT;
    end
    else begin
        // Start Bit
        repeat(2) @(negedge UART_TX_IF.clk);
        tx_out_combined[9] = UART_TX_IF.TX_OUT;

        // Data Bits
        for (int i = 1; i < 9; i = i + 1) begin
            @(negedge UART_TX_IF.clk);
            tx_out_combined[i] = UART_TX_IF.TX_OUT;
        end

        // Stop Bit
        @(negedge UART_TX_IF.clk);
        tx_out_combined[0] = UART_TX_IF.TX_OUT;
    end

    if (tx_out_combined == tx_out_combined_expected && UART_TX_IF.Busy) begin
        correct_count = correct_count + 1;
    end
    else begin
        error_count = error_count + 1;
        $display("Data mismatch: TX_OUT_Combined = %10b, P_DATA = %0b, Busy = %1b, time = %0t", tx_out_combined, UART_TX_IF.P_DATA, UART_TX_IF.Busy, $time);
    end
endtask

task check_idle();
    @(negedge UART_TX_IF.clk);

    if (UART_TX_IF.TX_OUT && ~UART_TX_IF.Busy) begin
        correct_count = correct_count + 1;
    end
    else begin
        error_count = error_count + 1;
        $display("Reset failed: TX_OUT = %b, Busy = %b, time = %0t", UART_TX_IF.TX_OUT, UART_TX_IF.Busy, $time);
    end
endtask

endmodule
