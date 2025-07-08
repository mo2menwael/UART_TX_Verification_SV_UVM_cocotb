// verilog_lint: waive-start package-filename
// verilog_lint: waive-start line-length

package monitor_pkg;
    import uvm_pkg::*;
    import seq_item_pkg::*;
    `include "uvm_macros.svh"

    class UART_TX_monitor extends uvm_monitor;
        `uvm_component_utils(UART_TX_monitor)

        virtual UART_TX_if uart_tx_vif;
        UART_TX_sequence_item sc_seq_item, cov_seq_item;
        uvm_analysis_port #(UART_TX_sequence_item) mtr_ap_scoreboard;
        uvm_analysis_port #(UART_TX_sequence_item) mtr_ap_coverage;

        function new(string name = "UART_TX_monitor", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            mtr_ap_scoreboard = new("mtr_ap_scoreboard", this);
            mtr_ap_coverage = new("mtr_ap_coverage", this);
        endfunction

        logic [10:0] tx_out_combined;

        task run_phase(uvm_phase phase);
            super.run_phase(phase);

            @(posedge uart_tx_vif.clk);

            fork
                forever begin
                    @(posedge uart_tx_vif.clk);

                    if (!uart_tx_vif.reset || !uart_tx_vif.DATA_VALID) begin
                        @(negedge uart_tx_vif.clk);

                        sc_seq_item = UART_TX_sequence_item::type_id::create("sc_seq_item");
                        sc_seq_item.reset = uart_tx_vif.reset;
                        sc_seq_item.P_DATA = uart_tx_vif.P_DATA;
                        sc_seq_item.PAR_EN = uart_tx_vif.PAR_EN;
                        sc_seq_item.PAR_TYP = uart_tx_vif.PAR_TYP;
                        sc_seq_item.DATA_VALID = uart_tx_vif.DATA_VALID;
                        sc_seq_item.TX_OUT = uart_tx_vif.TX_OUT;
                        sc_seq_item.Busy = uart_tx_vif.Busy;
                        sc_seq_item.tx_out_combined = tx_out_combined;
                    end
                    else begin
                        tx_out_combined = 0;

                        sc_seq_item = UART_TX_sequence_item::type_id::create("sc_seq_item");
                        sc_seq_item.reset = uart_tx_vif.reset;
                        sc_seq_item.P_DATA = uart_tx_vif.P_DATA;
                        sc_seq_item.PAR_EN = uart_tx_vif.PAR_EN;
                        sc_seq_item.PAR_TYP = uart_tx_vif.PAR_TYP;
                        sc_seq_item.DATA_VALID = uart_tx_vif.DATA_VALID;

                        if (uart_tx_vif.PAR_EN) begin
                            // Start Bit
                            repeat(2) @(negedge uart_tx_vif.clk);
                            tx_out_combined[10] = uart_tx_vif.TX_OUT;

                            // Data Bits
                            for (int i = 2; i < 10; i = i + 1) begin
                                @(negedge uart_tx_vif.clk);
                                tx_out_combined[i] = uart_tx_vif.TX_OUT;
                            end

                            // Parity Bit
                            @(negedge uart_tx_vif.clk);
                            tx_out_combined[1] = uart_tx_vif.TX_OUT;

                            // Stop Bit
                            @(negedge uart_tx_vif.clk);
                            tx_out_combined[0] = uart_tx_vif.TX_OUT;
                        end
                        else begin
                            // Start Bit
                            repeat(2) @(negedge uart_tx_vif.clk);
                            tx_out_combined[9] = uart_tx_vif.TX_OUT;

                            // Data Bits
                            for (int i = 1; i < 9; i = i + 1) begin
                                @(negedge uart_tx_vif.clk);
                                tx_out_combined[i] = uart_tx_vif.TX_OUT;
                            end

                            // Stop Bit
                            @(negedge uart_tx_vif.clk);
                            tx_out_combined[0] = uart_tx_vif.TX_OUT;
                        end

                        sc_seq_item.TX_OUT = uart_tx_vif.TX_OUT;
                        sc_seq_item.Busy = uart_tx_vif.Busy;
                        sc_seq_item.tx_out_combined = tx_out_combined;
                    end

                    mtr_ap_scoreboard.write(sc_seq_item);
                    `uvm_info("run_phase", sc_seq_item.convert2string(), UVM_MEDIUM);
                end

                forever begin
                    @(posedge uart_tx_vif.clk);
                    cov_seq_item = UART_TX_sequence_item::type_id::create("cov_seq_item");
                    cov_seq_item.reset = uart_tx_vif.reset;
                    cov_seq_item.P_DATA = uart_tx_vif.P_DATA;
                    cov_seq_item.PAR_EN = uart_tx_vif.PAR_EN;
                    cov_seq_item.PAR_TYP = uart_tx_vif.PAR_TYP;
                    cov_seq_item.DATA_VALID = uart_tx_vif.DATA_VALID;
                    cov_seq_item.TX_OUT = uart_tx_vif.TX_OUT;
                    cov_seq_item.Busy = uart_tx_vif.Busy;
                    cov_seq_item.tx_out_combined = tx_out_combined;

                    mtr_ap_coverage.write(cov_seq_item);
                    `uvm_info("run_phase", cov_seq_item.convert2string(), UVM_MEDIUM);
                end
            join
        endtask
    endclass
endpackage
