// verilog_lint: waive-start explicit-parameter-storage-type
// verilog_lint: waive-start explicit-task-lifetime
// verilog_lint: waive-start explicit-function-task-parameter-type
// verilog_lint: waive-start line-length
// verilog_lint: waive-start constraint-name-style

package UART_TX_PKG;
    class UART_TX_class;
        bit        clk;
        rand  logic reset;
        rand  logic [7:0] P_DATA;
        rand  logic PAR_EN;
        randc logic PAR_TYP;    // Using randc to ensure alternating parity type with duty 50%
        rand  logic DATA_VALID;
        logic TX_OUT;
        logic Busy;

        constraint reset_c {
            reset dist {1:= 97, 0:= 3};
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
            {P_DATA inside {8'h00, 8'hFF, 8'hAA}} dist {1:= 4, 0:= 96};
        }

        covergroup cvr_gp;
            Reset_Coverage: coverpoint reset {
                bins reset_active = {0};
                bins no_reset = {1};
            }

            PAR_EN_Coverage: coverpoint PAR_EN iff(reset) {
                bins parity_enabled = {1};
                bins parity_disabled = {0};
            }

            PAR_TYP_Coverage: coverpoint PAR_TYP iff(reset) {
                bins odd_parity = {1};
                bins even_parity = {0};
            }

            DATA_VALID_Coverage: coverpoint DATA_VALID iff(reset) {
                bins valid_data = {1};
                bins invalid_data = {0};
            }

            P_DATA_Coverage: coverpoint P_DATA iff(reset) {
                bins min_value = {8'b00000000};
                bins max_value = {8'b11111111};
                bins alternating_value = {8'b10101010};
                bins default_bins = default;
            }

            TX_OUT_Coverage: coverpoint TX_OUT iff(reset) {
                bins one = {1};
                bins zero = {0};
            }

            Busy_Coverage: coverpoint Busy iff(reset) {
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

        function new();
            cvr_gp = new();
        endfunction
    endclass
endpackage
