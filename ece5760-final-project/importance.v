module importance (
	input [17:0] saturation,
	input [17:0] luminance,
	input [17:0] constant,
	output [47:0] importance
);

	wire [17:0] Lminushalf, absLminushalf, Lminushalfx2, oneminusLterm, multLS;
	wire [17:0] importanceResult;


	assign Lminushalf = luminance - 18'h8000;
	assign absLminushalf = (Lminushalf[17] == 1'b1) ? (~Lminushalf) + 1 : Lminushalf;
	assign Lminushalfx2  = absLminushalf >> 1;
	assign oneminusLterm = 18'h10000 - Lminushalfx2;

	signed_mult LxS (
		.a(oneminusLterm),
		.b(saturation),
		.out(multLS)
	);

	assign importanceResult = multLS + constant;
	assign importance = {30'h0, importanceResult};
endmodule

//////////////////////////////////////////////////
// 2.16 fixed point signed multiplier
//////////////////////////////////////////////////
module signed_mult (out, a, b);

	output 		[17:0]	out;
	input 	signed	[17:0] 	a;
	input 	signed	[17:0] 	b;
	
	wire	signed	[17:0]	out;
	wire 	signed	[35:0]	mult_out;

	assign mult_out = a * b;
	//assign out = mult_out[33:17];
	assign out = {mult_out[35], mult_out[32:16]};
endmodule