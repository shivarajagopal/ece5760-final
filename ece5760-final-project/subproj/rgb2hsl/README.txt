RGB to HSL converter
Shiva Rajagopal, ECE 5760, Spring 2016

This set of modules enables easy conversion of RGB to HSL in Verilog. The implementation is roughly based on the design given in this document:
http://link.springer.com/chapter/10.1007%2F978-3-319-24584-3_109

The modules are in separate files for ease of editability, should you feel the need, but if you just want to trust me that it works and want to modularize your code a bit more, rgb2hsl_sf.v contains everything you'll need to pop this into your Quartus project.

The main feature of this converter is its lack of need for a divider. All divisions and complicated multiplications have been simplified using look-up tables for the values. Since we know all possibilities for the inputs, we can easily convert the divisions into multiplications by the reciprocals of the divisors that are stored in the look-up tables. This minimizes the complexity of the system, without using the nuclear option of a straight look-up table conversion from RGB to HSL.

The R, G, and B inputs are all 8-bit values, and the outputs are as follows:
Hue:        9 bits  (decimal, range 0-360)
Saturation: 18 bits (2:16 fixed point, range 0-1)
Luminance:  18 bits (2:16 fixed point, range 0-1)

The use of fixed point mathematics means we get some error in our calculation, but not enough to matter in general use. 