# ece5760-final
## An FPGA project to take an incoming NTSC signal and output its dominant color to an RGB LED. This project targets a Terasic DE2-115 board using an Altera Cyclone IV FPGA.

The method used in this project is based on Erwin Zwart's writeup, located [here](https://hue-camera.com/2015/03/17/how-hue-camera-algorithm-works/)

For a full writeup of this project, including a description of the surrounding hardware, visit the website [here](https://shivarajagopal.github.io/ece5760-final). Source code for the website is located in the ``gh-pages`` branch of this repo.

## ece5760-final-project
This directory contains all Quartus files (based on Quartus Prime 15.1) for this project. It also contains two subprojects that were used during development. One is the converter from RGB space to HSL space, also as a Quartus project. The other is an experimental implementation to control the brightness of the RGB LED components using the onboard switches.

## MATLAB
This contains the proof of concept for this project as a MATLAB function. The function takes in a picture and outputs its dominant color. There are two methods, one using a hard coded number of fixed colors to output, and the other using a more complex, weighted average method.
