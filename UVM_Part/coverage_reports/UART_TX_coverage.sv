// verilog_lint: waive-start package-filename
// verilog_lint: waive-start line-length

package coverage_pkg;
    import uvm_pkg::*;
    import seq_item_pkg::*;
    `include "uvm_macros.svh"

    class UART_TX_coverage extends uvm_component;
        `uvm_component_utils(UART_TX_coverage)

        uvm_analysis_export #(UART_TX_sequence_item) cov_export;
        uvm_tlm_analysis_fifo #(UART_TX_sequence_item) cov_fifo;
        UART_TX_sequence_item cov_item;

        covergroup cvr_gp;
            Reset_Coverage: coverpoint cov_item.reset {
                bins reset_active = {0};
                bins no_reset = {1};
            }

            PAR_EN_Coverage: coverpoint cov_item.PAR_EN iff(cov_item.reset) {
                bins parity_enabled = {1};
                bins parity_disabled = {0};
            }

            PAR_TYP_Coverage: coverpoint cov_item.PAR_TYP iff(cov_item.reset) {
                bins odd_parity = {1};
                bins even_parity = {0};
            }

            DATA_VALID_Coverage: coverpoint cov_item.DATA_VALID iff(cov_item.reset) {
                bins valid_data = {1};
                bins invalid_data = {0};
            }

            P_DATA_Coverage: coverpoint cov_item.P_DATA iff(cov_item.reset) {
                bins min_value = {8'b00000000};
                bins max_value = {8'b11111111};
                bins alternating_value = {8'b10101010};
                bins default_bins = default;
            }

            TX_OUT_Coverage: coverpoint cov_item.TX_OUT iff(cov_item.reset) {
                bins one = {1};
                bins zero = {0};
            }

            Busy_Coverage: coverpoint cov_item.Busy iff(cov_item.reset) {
                bins one = {1};
                bins zero = {0};
            }

            PAR_EN__PAR_TYP_CROSS: cross PAR_EN_Coverage, PAR_TYP_Coverage;
            P_DATA__DATA_VALID_CROSS: cross P_DATA_Coverage, DATA_VALID_Coverage;

            TX_OUT__Busy_CROSS: cross TX_OUT_Coverage, Busy_Coverage {
                bins one_one = binsof(TX_OUT_Coverage.one) && binsof(Busy_Coverage.one);
                bins one_zero = binsof(TX_OUT_Coverage.one) && binsof(Busy_Coverage.zero);
                bins zero_one = binsof(TX_OUT_Coverage.zero) && binsof(Busy_Coverage.one);
                illegal_bins NO_zero_zero = binsof(TX_OUT_Coverage.zero) && binsof(Busy_Coverage.zero);
            }
        endgroup

        function new(string name = "UART_TX_coverage", uvm_component parent = null);
            super.new(name, parent);
            cvr_gp = new();
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            cov_export = new("cov_export", this);
            cov_fifo = new("cov_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            cov_export.connect(cov_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                cov_fifo.get(cov_item);
                cvr_gp.sample();
            end
        endtask

    endclass
endpackage
