set_property PACKAGE_PIN P17 [get_ports clk]
set_property PACKAGE_PIN P15 [get_ports rst_n]
set_property PACKAGE_PIN H17 [get_ports RZ_data]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports RZ_data]
set_property IOSTANDARD LVCMOS33 [get_ports vauxn]
set_property IOSTANDARD LVCMOS33 [get_ports vauxp]

set_property PACKAGE_PIN C14 [get_ports vauxn]

create_clock -period 10.000 -name clk_1 -waveform {0.000 5.000} [get_ports clk]
