

# UART Receiver with State Machine

A Verilog implementation of a serial-to-parallel UART receiver. This module uses a Finite State Machine (FSM) to detect a start bit, sample 8 data bits, verify a stop bit, and handle framing errors via a specialized `WAIT` state.

## 🚀 Features

  * **8-N-1 Support**: Designed for 1 start bit, 8 data bits, and 1 stop bit.
  * **Robust Error Handling**: If a stop bit is missing, the FSM enters a `WAIT` state until the line returns to IDLE (1), preventing false start-bit detection.
  * **One-Cycle Done Pulse**: Provides a clean `done` signal exactly when a valid byte is registered.
  * **GTKWave Integration**: Testbench included with `$dump` commands for waveform analysis.

-----

## 📂 File Structure

  * `top_module.v`: The core FSM and UART logic.
  * `top_module_tb.v`: The testbench containing simulation tasks and GTKWave hooks.

-----

## 🛠️ How to Run

### 1\. Prerequisites

Ensure you have **Icarus Verilog** (`iverilog`) and **GTKWave** installed on your system.

  * **Ubuntu/Debian**: `sudo apt-get install iverilog gtkwave`
  * **macOS**: `brew install icarus-verilog gtkwave`
  * **Windows**: Download installers for [Icarus Verilog](https://www.google.com/search?q=http://bleyer.org/icarus/) (includes GTKWave).

### 2\. Compile and Simulate

Open your terminal in the project directory and run:

```bash
# Compile the design and testbench
iverilog -o uart_sim top_module.v top_module_tb.v

# Run the simulation (this generates uart_sim.vcd)
vvp uart_sim
```

### 3\. View Waveforms

To see the timing diagrams and state transitions:

```bash
gtkwave uart_sim.vcd
```

-----

## 🔍 FSM Logic Overview

The receiver operates using 5 distinct states:

1.  **IDLE**: Waits for the input `in` to drop to `0` (Start Bit).
2.  **READ**: Samples 8 bits of data over 8 clock cycles.
3.  **STOP**: Samples the 9th bit to ensure it is `1`.
4.  **DONE**: Asserted for one cycle if the stop bit was valid.
5.  **WAIT**: Entered if the stop bit was `0` (Framing Error). Stays here until `in` returns to `1`.

-----

## 📝 Testbench Scenarios

The included testbench (`top_module_tb.v`) automatically verifies:

  * **Successful Transmission**: Sends `0xA5` and checks for the `done` pulse.
  * **Framing Error**: Sends a byte with a missing stop bit to verify the FSM doesn't falsely trigger `done` and correctly recovers via the `WAIT` state.
  * **Reset Logic**: Ensures the FSM returns to `IDLE` regardless of current state.

