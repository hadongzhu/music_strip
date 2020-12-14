# Audio Reactive LED Strip (FPGA)
Real-time LED strip music visualization using Verilog and SystemVerilog with EGO1 and WS2812B. It is mainly based on the [scottlawsonbc/audio-reactive-led-strip](https://github.com/scottlawsonbc/audio-reactive-led-strip "scottlawsonbc/audio-reactive-led-strip") which implements spectrum mode and scroll mode and total process including ADC, mel filter bank (based on [fpga_mel_filter_bank](https://github.com/lxschwalb/fpga_mel_filter_bank "fpga_mel_filter_bank")) and driver of WS2812B.

the spectrum mode is default and if you want to use scroll mode, you need to change component name  `visualization` into `visualization_scroll`.

The scroll mode id writen by OneDog.