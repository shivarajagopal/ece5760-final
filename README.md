# ece5760-final
An FPGA project to take an incoming NTSC signal and output its dominant color to an RGB LED. This project targets a Terasic DE2-115 board using an Altera Cyclone IV FPGA.

The method used in this project is based on Erwin Zwart's writeup, located [here](https://hue-camera.com/2015/03/17/how-hue-camera-algorithm-works/)

For a full writeup of this project, including a description of the surrounding hardware, visit the website [here](https://people.ece.cornell.edu/land/courses/ece5760/FinalProjects/s2016/svr24/svr24/index.html). Note: the website is slightly out of date.

### ece5760-final-project
This directory contains all Quartus files (based on Quartus Prime 15.1) for this project. It also contains two subprojects that were used during development. One is the converter from RGB space to HSL space, also as a Quartus project. The other is an experimental implementation to control the brightness of the RGB LED components using the onboard switches.

### ece5760-report
This is the source code for the website found [here](https://people.ece.cornell.edu/land/courses/ece5760/FinalProjects/s2016/svr24/svr24/index.html). Note: the published website is out of date with the source code here, based on updates made after publishing. Please clone here to see the most recent website.

### MATLAB
This contains the proof of concept for this project as a MATLAB function. The function takes in a picture and outputs its dominant color. There are two methods, one using a hard coded number of fixed colors to output, and the other using a more complex, weighted average method.
