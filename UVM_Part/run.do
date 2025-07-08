vlib work
vlog -f UART_TX.list +cover -covercells
vsim -voptargs=+acc work.UART_TX_top -classdebug -uvmcontrol=all -cover
add wave /UART_TX_top/UART_TX_IF/*
add wave /UART_TX_top/DUT/*
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