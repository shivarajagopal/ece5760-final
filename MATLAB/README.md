# MATLAB
## A MATLAB test bench for finding the dominant color of a given image using different algorithms.

This contains the proof of concept for this project as a MATLAB function. The function takes in a picture and outputs its dominant color. There are two methods, one using a hard coded number of fixed colors to output, and the other using a more complex, weighted average method.

## getHue.m
This file contains a simple algorithm for finding the dominant color using a heuristic to make FPGA-based calculation easier. After calculating the importance of each pixel and finding the most dominant hue range, this algorithm uses a pre-calculated set of colors for each hue range and outputs it directly.

## getHue_weightedSum.m
This file does a similar process to ``getHue.m``, except that after determining the most important hue range in the picture, the algorithm then determines the most dominant hue by multiplying the hue of each pixel in the range by its relative importance and sums together this weighted average. This provides more accuracy, but is not very feasible for an FPGA-based implementation

## getHue_tb.m
