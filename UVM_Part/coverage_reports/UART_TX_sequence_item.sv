// verilog_lint: waive-start package-filename
// verilog_lint: waive-start explicit-parameter-storage-type
// verilog_lint: waive-start line-length
// verilog_lint: waive-start constraint-name-style

package seq_item_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class UART_TX_sequence_item extends uvm_sequence_item;
        `uvm_object_utils(UART_TX_sequence_item)

        rand  logic reset;
        rand  logic [7:0] P_DATA;
        rand  logic PAR_EN;
        randc logic PAR_TYP;    // Using randc to ensure alternating parity type with duty 50%
        rand  logic DATA_VALID;
        logic TX_OUT;
        logic Busy;
        logic [10:0] tx_out_combined;

        function new(string name = "UART_TX_sequence_item");
            super.new(name);
        endfunction

        function string convert2string();
            return $sformatf("%s Monitor Output: reset=%1b | P_DATA=%8b | PAR_EN=%1b | PAR_TYP=%1b | DATA_VALID=%1b | TX_OUT=%1b | Busy=%1b", super.convert2string(), reset, P_DATA, PAR_EN, PAR_TYP, DATA_VALID, TX_OUT, Busy);
        endfunction

        function string convert2string_stimulus();
            return $sformatf("Stimulus in Driver: reset=%1b | P_DATA=%8b | PAR_EN=%1b | PAR_TYP=%1b | DATA_VALID=%1b", reset, P_DATA, PAR_EN, PAR_TYP, DATA_VALID);
        endfunction

        // Constraints
        constraint reset_c {
            soft reset dist {1:= 97, 0:= 3};
        }

        constraint PAR_EN_c {
            PAR_EN dist {1:= 25, 0:= 75};
        }

        constraint DATA_VALID_c {
            DATA_VALID dist {1:= 90, 0:= 10};
        }

        constraint P_DATA_1_c {
            P_DATA[0] dist {1:= 80, 0:= 20};
        }

        constraint P_DATA_2_c {
            {P_DATA inside {8'hFF, 8'h00, 8'hAA}} dist {1:= 4, 0:= 96};
        }
    endclass
endpackage
