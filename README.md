# Design of a Bluetooth SIG-Aligned LED Control Subsystem for IoT Applications

This repository consists of the verilog implementation of the LED-control subsystem project done in Vivado 2024.2

The folder BLE_led_ctrl consists of the simulation testbench and waveform showcasing how the LEDs are controlled to blink, beathe and pulse according to the information coming in from the packet.

The BLE_led_ctrl_fpga on the other hand consists of the code to implement the same on the Nexys 4 Artix 7 fpga board. The packet size has been reduced to fit the requirement of avilable switches on the board. The color control signals have been removed and a few modifications have been made to ensure smooth execution which can be seen on the board.

The Project_Demo video shows the vairous modes being tested on the board along with an active-low reset input as well as brightness control functionalities.
