# UART Transceiver in VHDL

A UART transmitter and receiver written in VHDL, simulated and verified in ModelSim.
Built as a portfolio project while preparing for a role in defence electronics.

---

## What it does

Sends and receives serial data in the standard 8N1 UART format — 8 data bits, no parity, 1 stop bit.
You give it a byte, it sends it down a wire one bit at a time at 115200 baud, and the receiver on the other end rebuilds the original byte.

---

## Files

```
rtl/
    baud_gen.vhd   — generates timing pulses for TX and RX
    uart_tx.vhd    — transmitter state machine
    uart_rx.vhd    — receiver state machine
    uart_top.vhd   — connects everything together
tb/
    uart_tb.vhd    — self-checking testbench
sim/
    sim.do         — ModelSim run script
```

---

## How the timing works

The FPGA runs at 100 MHz. At 115200 baud each bit lasts 868 clock cycles.

Rather than creating a separate baud clock, the baud generator produces a single-cycle pulse every 868 cycles. The TX and RX run on the main clock and only advance their state when that pulse fires. This keeps everything in one clock domain.

The RX also gets a faster pulse — 16 times per bit period — so it can sample each incoming bit at its centre rather than near the edges where the signal is least stable.

---

## Simulation results

The testbench connects TX directly back to RX (loopback) and sends four bytes, checking that what comes out matches what went in.

```
# ** Note: PASS test 1: 0x55
# ** Note: PASS test 2: 0x00
# ** Note: PASS test 3: 0xFF
# ** Note: PASS test 4: 0xA3
# ** Note: ALL TESTS PASSED
```

![ModelSim waveform](docs/waveform.png)

---

## Running it yourself

Open ModelSim, navigate to the project folder, and type:

```tcl
do sim/sim.do
```

That compiles everything, loads the testbench, adds the signals to the wave window, and runs the simulation.

---

## Tools used

- ModelSim Intel FPGA Edition 2020.1
- VHDL-2008


