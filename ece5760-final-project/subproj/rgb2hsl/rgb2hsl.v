/////////////////////////////////////////////////////
// RGB to HSL converter - top level                //
/////////////////////////////////////////////////////

// RGB to HSL converter
// Based on implementation described in http://link.springer.com/chapter/10.1007%2F978-3-319-24584-3_109
// Inputs:
//		[R,G,B] = [0..255] in 8 bits
// Outputs [H,S,L]:
// 	H    = [0..360] in 9 bits
//  S, L = [0..1]   in 2.16 Fixed Point

module rgb2hsl (
	input [7:0] R,
	input [7:0] G,
	input [7:0] B,
	output [8:0] hue,
	output [17:0] sat,
	output [17:0] lum
);

	wire [1:0]  cMax;
	wire [17:0] r,g,b;
	wire [17:0]  maxplusmin;
	wire [8:0] MAXPLUSMIN;
	wire [17:0] maxminusmin;
	wire [7:0]  D;

	saturation satconv(
		.MAXPLUSMIN(MAXPLUSMIN),
		.maxminusmin(maxminusmin),
		.luminance(lum),
		.saturation(sat)
	);
	
	luminance lumconv(
		.maxplusmin(maxplusmin),
		.luminance(lum)
	);
	
	hue hueconv(
		.D(D),
		.colorMax(cMax),
		.r(r),
		.g(g),
		.b(b),
		.hue(hue)
	);
	
	min_max_selector mms (
		.R(R),
		.G(G),
		.B(B),
		.r(r),
		.g(g),
		.b(b),
		.MAXPLUSMIN(MAXPLUSMIN),
		.maxplusmin(maxplusmin),
		.maxminusmin(maxminusmin),
		.D(D),
		.colorMax(cMax)
	);
	
	divider div(
		.R(R),
		.G(G),
		.B(B),
		.r(r),
		.g(g),
		.b(b)
	);
	
endmodule
