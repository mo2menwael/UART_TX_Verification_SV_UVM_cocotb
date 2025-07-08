import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles, FallingEdge, RisingEdge

tx_out_combined = [None] * 11
tx_out_combined_expected = [None] * 11
correct_count = 0
error_count = 0

async def check_idle(dut):
    global correct_count, error_count
    await FallingEdge(dut.clk)
    if dut.TX_OUT.value and ~dut.Busy.value:
        correct_count += 1
    else:
        error_count += 1
        print(f"Reset failed: TX_OUT = {dut.TX_OUT.value}, Busy = {dut.Busy.value}")

async def Data_Valid_Check(dut):
    global tx_out_combined, tx_out_combined_expected, correct_count, error_count
    tx_out_combined = [None] * 11

    if dut.PAR_EN.value:
        # Start Bit
        await ClockCycles(dut.clk, 2, rising=False)
        tx_out_combined[0] = dut.TX_OUT.value

        # Data Bits
        for i in range(8, 0, -1):
            await FallingEdge(dut.clk)
            tx_out_combined[i] = dut.TX_OUT.value

        # Parity Bit
        await FallingEdge(dut.clk)
        tx_out_combined[9] = dut.TX_OUT.value

        # Stop Bit
        await FallingEdge(dut.clk)
        tx_out_combined[10] = dut.TX_OUT.value
    else:
        # Start Bit
        await ClockCycles(dut.clk, 2, rising=False)
        tx_out_combined[0] = dut.TX_OUT.value

        # Data Bits
        for i in range(8, 0, -1):
            await FallingEdge(dut.clk)
            tx_out_combined[i] = dut.TX_OUT.value

        # Stop Bit
        await FallingEdge(dut.clk)
        tx_out_combined[9] = dut.TX_OUT.value

    if (tx_out_combined == tx_out_combined_expected and dut.Busy.value):
        correct_count += 1
    else:
        error_count += 1
        print(f"Data mismatch: TX_OUT_Combined = {tx_out_combined}, TX_OUT_Combined_expected = {tx_out_combined_expected}, P_DATA = {dut.P_DATA.value}, Busy = {dut.Busy.value}, PAR_EN = {dut.PAR_EN.value}")


@cocotb.test()
async def test_task(dut):
    cocotb.start_soon(Clock(dut.clk, 2, units="ns").start())

    await FallingEdge(dut.clk)
    for i in range(10000):
        dut.reset.value = 1 if random.random() < 0.98 else 0
        dut.P_DATA.value = random.randint(0, 0xFF)
        dut.PAR_EN.value = random.randint(0, 1)
        dut.PAR_TYP.value = random.randint(0, 1)
        dut.DATA_VALID.value = 1 if random.random() < 0.98 else 0

        # Add some delay to ensure the inputs are stable
        await RisingEdge(dut.clk)

        if not dut.reset.value or not dut.DATA_VALID.value:
            await cocotb.start_soon(check_idle(dut))
        else:
            global tx_out_combined_expected
            if dut.PAR_EN.value:
                parity_bit = int((bin(dut.P_DATA.value).count('1') % 2) if dut.PAR_TYP.value else not(bin(dut.P_DATA.value).count('1') % 2))
                tx_out_combined_expected = [0] + [int(b) for b in format(int(dut.P_DATA.value), '08b')] + [parity_bit, 1]
            else:
                tx_out_combined_expected = [0] + [int(b) for b in format(int(dut.P_DATA.value), '08b')] + [1, None]

            await cocotb.start_soon(Data_Valid_Check(dut))


    print(f"Number of correct test cases = {correct_count}")
    print(f"Number of failed test cases = {error_count}")