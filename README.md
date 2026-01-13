**RTL Elevator Controller (VHDL)**

This repository contains a fully synthesizable RTL design of an elevator controller, implemented in VHDL and verified using ModelSim and Vivado. The design models realistic elevator behavior using a finite state machine, request queuing, direction awareness, and timed door operation.

**Features**

1) FSM-based elevator control

2) States: IDLE, MOVING_UP, MOVING_DOWN, DOOR

3) Dynamic request handling

4) Accepts new floor requests at any time

5) Requests are stored and serviced correctly

6) Direction-aware servicing

7) Continues in the current direction when possible

8) Changes direction only when required

9) Door timing logic

10) Door remains open for a programmable duration

11) Models real elevator motion timing

12) Successfully synthesized and implemented in Vivado


** Design Philosophy**

This design intentionally mirrors real-world elevator behavior:

-> Requests do not need to arrive all at once

-> New requests can arrive while the elevator is moving

-> Floors are served based on current direction and availability

-> Repeated requests to the same floor are handled correctly if issued later

The testbench reflects realistic user behavior, avoiding unrealistic assumptions such as all requests being asserted simultaneously at time zero.

 **RTL Architecture**

1) **lift.vhdl**

->  Core elevator FSM

-> Request queue (pending_req)

-> Direction tracking (last_dir)

-> Door timing and floor movement logic

**clock_divider.vhdl**

-> Generates slow enable pulses for realistic motion

**top.vhdl**

Wrapper connecting all modules

**Testbench**

-> Applies staggered and overlapping floor requests

-> Verifies:

    Elevator stops only at requested floors

    No duplicate servicing of a request

    Re-servicing is allowed when the same floor is requested again later

    Uses assertions and logs for clear pass/fail feedback

The testbench focuses on stimulus + verification, not duplicating design logic.

**Timing & Synthesis**

Tool: Vivado 2024.2

Target FPGA: Xilinx

Worst Negative Slack (WNS): +7.656 ns

No timing violations

**📂 Repository Structure**
├── lift.vhdl
├── clock_divider.vhdl
├── top.vhdl
├── top_tb.vhdl
├── README.md

 
 **Future Enhancements**

-> Multi-elevator coordination

-> Emergency handling

-> Priority-based servicing

-> Parameterized number of floors


