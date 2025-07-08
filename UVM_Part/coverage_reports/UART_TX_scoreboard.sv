// verilog_lint: waive-start package-filename
// verilog_lint: waive-start explicit-parameter-storage-type
// verilog_lint: waive-start line-length
// verilog_lint: waive-start unpacked-dimensions-range-ordering

package scoreboard_pkg;
    import uvm_pkg::*;
    import seq_item_pkg::*;
    `include "uvm_macros.svh"

    class UART_TX_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(UART_TX_scoreboard)

        uvm_analysis_export #(UART_TX_sequence_item) sc_export;
        uvm_tlm_analysis_fifo #(UART_TX_sequence_item) sc_fifo;
        UART_TX_sequence_item seq_item;

        static int correct_count = 0;
        static int error_count = 0;

        static logic [10:0] tx_out_combined_expected;
        static bit parity_bit;

        function new(string name = "UART_TX_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sc_export = new("sc_export", this);
            sc_fifo = new("sc_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            sc_export.connect(sc_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                seq_item = UART_TX_sequence_item::type_id::create("seq_item");
                sc_fifo.get(seq_item);

                if (~seq_item.reset || ~seq_item.DATA_VALID) begin
                    check_idle(seq_item);
                end
                else if (seq_item.DATA_VALID) begin
                    if (seq_item.PAR_EN) begin
                        parity_bit = seq_item.PAR_TYP ? ^seq_item.P_DATA : ~^seq_item.P_DATA;
                        tx_out_combined_expected = {1'b0, seq_item.P_DATA, parity_bit, 1'b1};
                    end
                    else begin
                        tx_out_combined_expected = {1'b0, seq_item.P_DATA, 1'b1};
                    end

                Data_Valid_Check(seq_item);
                end
            end
        endtask

        task Data_Valid_Check(UART_TX_sequence_item seq_item);
            if (seq_item.tx_out_combined == tx_out_combined_expected && seq_item.Busy) begin
                correct_count = correct_count + 1;
            end
            else begin
                error_count = error_count + 1;
                `uvm_error("run_phase", $sformatf("Data mismatch: TX_OUT_Combined = %10b, P_DATA = %0b, Busy = %1b, time = %0t", seq_item.tx_out_combined, seq_item.P_DATA, seq_item.Busy, $time));
            end
        endtask

        task check_idle(UART_TX_sequence_item seq_item);
            if (seq_item.TX_OUT && ~seq_item.Busy) begin
                correct_count = correct_count + 1;
            end
            else begin
                error_count = error_count + 1;
                `uvm_error("run_phase", $sformatf("Reset failed: TX_OUT = %b, Busy = %b, time = %0t", seq_item.TX_OUT, seq_item.Busy, $time));
            end
        endtask

        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("report_phase", $sformatf("Correct count = %0d", correct_count), UVM_MEDIUM);
            `uvm_info("report_phase", $sformatf("Error count = %0d", error_count), UVM_MEDIUM);
        endfunction


    endclass
endpackage
