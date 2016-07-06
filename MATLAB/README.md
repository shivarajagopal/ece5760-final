# MATLAB
## A MATLAB test bench for finding the dominant color of a given image using different algorithms.

This contains the proof of concept for this project as a MATLAB function. The function takes in a picture and outputs its dominant color. There are two methods, one using a hard coded number of fixed colors to output, and the other using a more complex, weighted average method.

## getHue.m
This file contains a simple algorithm for finding the dominant color using a heuristic to make FPGA-based calculation easier. After calculating the importance of each pixel and finding the most dominant hue range, this algorithm uses a pre-calculated set of colors for each hue range and outputs it directly.

## getHue_weightedSum.m
This file does a similar process to ``getHue.m``, except that after determining the most important hue range in the picture, the algorithm then determines the most dominant hue by multiplying the hue of each pixel in the range by its relative importance and sums together this weighted average. This provides more accuracy, but is not very feasible for an FPGA-based implementation

## getHue_tb.m
This is a test bench file that runs both the weighted sum and heuristic algorithm on the pictures in the folder, and displays the result for each picture in order. The test bench will operate on all pictures named with the convention ``testX.jpg`` where X is any integer.

## hsl2rgb.m, rgb2hsl.m, hsltest.m
A set of MATLAB scripts created by Vladimir Bychkovsky for converting RGB to HSL and back, used in the getHue algorithms.

## pic2msim.m
When testing the verilog implementation of finding the most important hue range, ModelSim was used to verify that the hardware implementation matched that of MATLAB. This script takes a given picture and outputs a ModelSim-compatible script that sends in a new set of RGB values on each cycle. This is simply to aid in the speed of hardware development.
