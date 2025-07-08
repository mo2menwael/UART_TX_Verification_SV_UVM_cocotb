// verilog_lint: waive-start interface-name-style
// verilog_lint: waive-start explicit-parameter-storage-type
// verilog_lint: waive-start line-length

interface UART_TX_if (input bit clk);
    logic reset;
    logic [7:0] P_DATA;
    logic PAR_EN;
    logic PAR_TYP;
    logic DATA_VALID;
    logic TX_OUT;
    logic Busy;

    modport DUT (
    input clk, reset, P_DATA, PAR_EN, PAR_TYP, DATA_VALID,
    output TX_OUT, Busy
    );

    modport TEST (
    input clk, TX_OUT, Busy,
    output reset, P_DATA, PAR_EN, PAR_TYP, DATA_VALID
    );

    modport MONITOR (
    input clk, reset, P_DATA, PAR_EN, PAR_TYP, DATA_VALID, TX_OUT, Busy
    );

    modport SVA (
    input clk, reset, P_DATA, PAR_EN, PAR_TYP, DATA_VALID, TX_OUT, Busy
    );
endinterface
