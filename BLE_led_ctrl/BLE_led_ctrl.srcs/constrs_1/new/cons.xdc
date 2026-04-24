## 100 MHz onboard clock (Nexys A7)
set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

create_clock -period 10.000 -name clk_100MHz [get_ports clk]