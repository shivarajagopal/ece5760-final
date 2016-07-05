# ece5760-final
## A Quartus Prime 15.1 Project written in Verilog to find the dominant color of NTSC video frames and output to an RGB LED

This project is made for the Terasic DE2-115 board, and is based on Terasic's DE2-115 TV sample project to interface with the NTSC input on the board.

The main project file is ``DE2_115_TV.qpf``. 

## Subprojects
There are two subprojects that were built during the development of this project, both located in the ''subproj/'' directory, and both developed for a DE2_115 board using Quartus Prime 15.1.

#### LEDPWM
This project uses an Altera IP Phase-locked loop to control 3 GPIO outputs as PWMs, and allow the switches onboard the DE2-115 board to control the duty cycle of all three GPIO pins. This can be used to test and debug GPIO pins on the board.

#### rgb2hsl
This project uses multiple modules to convert an RGB triplet to Hue, Saturation, and Lightness values using entirely custom-built Verilog modules. The module expects 8-bit RGB values as inputs, and outputs a 9-bit Hue value (values 0-360), and 18-bit values for Saturation and Lightness in 2:16 fixed point format. This project can be instantiated in any other Verilog project easily.
