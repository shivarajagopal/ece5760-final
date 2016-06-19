// LUMINANCE MODULE
// Inputs:
// 	maxplusmin = [0..2] in 2.16 fixed point
// Outputs:
//    luminance  = [0..1] in 2.16 fixed point

module luminance (
	input  [17:0] maxplusmin,
	output [17:0] luminance
);
	// Simply shift max+min right by one
	assign luminance = maxplusmin >> 1;
endmodule