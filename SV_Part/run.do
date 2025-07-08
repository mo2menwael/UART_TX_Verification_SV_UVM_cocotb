vlib work
vlog UART_TX_if.sv UART_TX_top.sv UART_TX.sv UART_TX_PKG.sv UART_TX_SVA.sv UART_TX_TB.sv UART_TX_monitor.sv +cover -covercells
vsim -voptargs=+acc work.UART_TX_top -cover

add wave /UART_TX_top/TEST/UART_TX_IF/*
add wave /UART_TX_top/DUT/state
add wave /UART_TX_top/DUT/counter
add wave /UART_TX_top/DUT/data_reg
add wave /UART_TX_top/DUT/parity_bit
add wave /UART_TX_top/DUT/UART_TX_SVA_inst/state

coverage save UART_TX_combined.ucdb -onexit
run -all

## Code Coverage Exclusions
coverage exclude -du UART_TX -ftrans state START->IDLE
coverage exclude -du UART_TX -ftrans state DATA->IDLE
coverage exclude -du UART_TX -ftrans state PARITY->IDLE
coverage exclude -du UART_TX -togglenode {state[3]}

##quit -sim
##vcover report UART_TX_combined.ucdb -details -all -du UART_TX -codeAll -output code_coverage_rpt.txt
##vcover report UART_TX_combined.ucdb -details -all -cvg -output func_coverage_rpt.txt
##vcover report UART_TX_combined.ucdb -details -all -byfile -assert -directive -output assertions_report.txt
