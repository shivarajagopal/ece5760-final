/////////////////////////////////////////////////////
// RGB to HSL converter - combined file            //
// Contains top level module and all dependencies  //
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

// DIVIDER MODULE
// Inputs:
// 	[R,G,B] = [0..255] in 8 bits
// Outputs:
//    [r,g,b] = [0..1] in 2.16 fixed point

module divider (
	input [7:0] R,
	input [7:0] G,
	input [7:0] B,
	output [17:0] r,
	output [17:0] g,
	output [17:0] b
);

	// Look up the red value
	dividerLUT red (
		.in(R),
		.out(r)
	);

	// Look up the green value
	dividerLUT green (
		.in(G),
		.out(g)
	);

	// Look up the blue value
	dividerLUT blue (
		.in(B),
		.out(b)
	);

endmodule

// MIN-MAX-SELECTOR module
// Inputs:
// 	[R,G,B] = [0..255] in 8 bits
//    [r,g,b] = [0..1] in 2.16 fixed point
// Outputs:
// 	MAXPLUSMIN  = [0..510] in 9 bits
//    D           = [0.255] in 8 bits
//		maxplusmin  = [0..1] in 2.16 fixed point
// 	maxminusmin = [0..1] in 2.16 fixed point
//    colorMax		= [0,1,2] corresponding to [red, green, blue]

module min_max_selector (
	input  [7:0]  R,
	input  [7:0]  G,
	input  [7:0]  B,
	input  [17:0] r,
	input  [17:0] g,
	input  [17:0] b,
	output reg [8:0] MAXPLUSMIN,
	output reg [17:0] maxplusmin,
	output reg [17:0] maxminusmin,
	output reg [7:0]  D,
	output reg [1:0]  colorMax
);

	reg [17:0] max, min;
	reg [7:0]  MAX, MIN;
	always @(*) begin

		// Get max values
		if ((G > R) || (B > R)) begin
			if (G > B) begin
				max <= g;
				MAX <= G;
				colorMax <= 2'd1;
			end 
			else begin
				max <= b;
				MAX <= B;
				colorMax <= 2'd2;
			end
		end
		else begin
			max <= r;
			MAX <= R;
			colorMax <= 2'd0;
		end
		
		// Get min value
		if ((G < R) || (B < R)) begin
			if (G < B) begin
				min <= g;
				MIN <= G;
			end
			else begin
				min <= b;
				MIN <= B;
			end
		end 
		else begin
			min <= r;
			MIN <= R;
		end
		
		// Calculate Max + Min and Max - Min in both [0..255] and [0..1]
		MAXPLUSMIN  <= MAX + MIN;
		D <= MAX-MIN;
		maxplusmin  <= max + min;
		maxminusmin <= max - min;
		
	end
endmodule

// HUE MODULE
// Inputs:
// 	D        = MAX-MIN ([0..255]) in 8 bits
//    colorMAX = [0,1,2] (the color with the maximum value, respectively red, green, blue)
//    r, g, b  = [0..1] in 2.16 fixed point
// Outputs:
// 	hue      = [0..360] in 9 bits

module hue (
	input  [7:0]  D,
	input  [1:0]  colorMax,
	input  [17:0] r,
	input  [17:0] g,
	input  [17:0] b,
	output [8:0] hue
);

	wire [31:0] hueMux;
	reg [1:0]  maxColor;
	wire signed [31:0] divisor;
	wire [31:0] hueRmax, hueGmax, hueBmax;
	wire signed [17:0] gb, br, rg;
	wire signed [31:0] gb_sext, br_sext, rg_sext;
	wire signed [31:0] gbTrim, brTrim, rgTrim;
	wire [71:0] gbMult, brMult, rgMult;

	// Subtract the values
	assign gb = g-b;
	assign br = b-r;
	assign rg = r-g;

	// Sign extend the values for cleaner multiplication
	assign gb_sext = {{14{gb[17]}}, gb};
	assign br_sext = {{14{br[17]}}, br};
	assign rg_sext = {{14{rg[17]}}, rg};

	// Instantiate the LUT of (60/d) values
	reciprocalLUT divide (
		.in(D),
		.out(divisor)
	);

	// Multiply
	assign gbMult = gb_sext*divisor;
	assign brMult = br_sext*divisor;
	assign rgMult = rg_sext*divisor;

	// Trim out the extraneous bits from the multiplication
	assign gbTrim = {{9{gbMult[71]}}, gbMult[38:16]};
	assign brTrim = {{9{brMult[71]}}, brMult[38:16]};
	assign rgTrim = {{9{rgMult[71]}}, rgMult[38:16]};

	// Assign values for each max case
	assign hueRmax = (gbTrim[31] == 1) ? gbTrim + 32'h1680000 : gbTrim;
	assign hueGmax = brTrim+24'h780000;
	assign hueBmax = rgTrim+24'hf00000;

	// Mux out the value and round
	assign hueMux = (colorMax == 2'b0) ? hueRmax : (colorMax == 2'b1) ? hueGmax : hueBmax;
	assign hue = (hueMux[15:0] > 16'h8000) ? hueMux[24:16] + 9'd1 : hueMux[24:16];

endmodule

// SATURATION MODULE
// Inputs:
// 	MAXPLUSMIN  = [0..510] in 9 bits
//    maxminusmin = [0..1]   in 2.16 fixed point
//    luminance   = [0..1]   in 2.16 fixed point
// Outputs:
//		saturation  = [0..1]   in 2.16 fixed point		
module saturation (
	input [8:0] MAXPLUSMIN,
	input [17:0] maxminusmin,
	input [17:0] luminance,
	output [17:0] saturation
);

	wire [31:0] divisor, sat;
	wire [63:0] satMult;
	wire [17:0] LUTinput;

	// Determine which value to divide by based on Lum value
	assign LUTinput = (luminance < 18'h08000) ? MAXPLUSMIN : 9'd510-MAXPLUSMIN;

	// Instantiate LUT
	mpmLUT mpmLT (
		.in(LUTinput),
		.out(divisor)
	);

	// Multiply
	assign satMult  = {14'd0, maxminusmin}*divisor;
	
	// Trim out extraneous bits
	assign saturation = satMult[33:16];

endmodule

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

// DIVIDER LUT
// This LUT simply takes all values in [0..255] and scales down to a 2.16
// fixed point representation of the valeus normalized to [0..1]
module dividerLUT (
	input  [7:0] in,
	output reg [17:0] out
);

	always @(*) begin
		case (in)
			8'd0: out <= 18'h00000;
			8'd1: out <= 18'h00101;
			8'd2: out <= 18'h00202;
			8'd3: out <= 18'h00303;
			8'd4: out <= 18'h00404;
			8'd5: out <= 18'h00505;
			8'd6: out <= 18'h00606;
			8'd7: out <= 18'h00707;
			8'd8: out <= 18'h00808;
			8'd9: out <= 18'h00909;
			8'd10: out <= 18'h00a0a;
			8'd11: out <= 18'h00b0b;
			8'd12: out <= 18'h00c0c;
			8'd13: out <= 18'h00d0d;
			8'd14: out <= 18'h00e0e;
			8'd15: out <= 18'h00f0f;
			8'd16: out <= 18'h01010;
			8'd17: out <= 18'h01111;
			8'd18: out <= 18'h01212;
			8'd19: out <= 18'h01313;
			8'd20: out <= 18'h01414;
			8'd21: out <= 18'h01515;
			8'd22: out <= 18'h01616;
			8'd23: out <= 18'h01717;
			8'd24: out <= 18'h01818;
			8'd25: out <= 18'h01919;
			8'd26: out <= 18'h01a1a;
			8'd27: out <= 18'h01b1b;
			8'd28: out <= 18'h01c1c;
			8'd29: out <= 18'h01d1d;
			8'd30: out <= 18'h01e1e;
			8'd31: out <= 18'h01f1f;
			8'd32: out <= 18'h02020;
			8'd33: out <= 18'h02121;
			8'd34: out <= 18'h02222;
			8'd35: out <= 18'h02323;
			8'd36: out <= 18'h02424;
			8'd37: out <= 18'h02525;
			8'd38: out <= 18'h02626;
			8'd39: out <= 18'h02727;
			8'd40: out <= 18'h02828;
			8'd41: out <= 18'h02929;
			8'd42: out <= 18'h02a2a;
			8'd43: out <= 18'h02b2b;
			8'd44: out <= 18'h02c2c;
			8'd45: out <= 18'h02d2d;
			8'd46: out <= 18'h02e2e;
			8'd47: out <= 18'h02f2f;
			8'd48: out <= 18'h03030;
			8'd49: out <= 18'h03131;
			8'd50: out <= 18'h03232;
			8'd51: out <= 18'h03333;
			8'd52: out <= 18'h03434;
			8'd53: out <= 18'h03535;
			8'd54: out <= 18'h03636;
			8'd55: out <= 18'h03737;
			8'd56: out <= 18'h03838;
			8'd57: out <= 18'h03939;
			8'd58: out <= 18'h03a3a;
			8'd59: out <= 18'h03b3b;
			8'd60: out <= 18'h03c3c;
			8'd61: out <= 18'h03d3d;
			8'd62: out <= 18'h03e3e;
			8'd63: out <= 18'h03f3f;
			8'd64: out <= 18'h04040;
			8'd65: out <= 18'h04141;
			8'd66: out <= 18'h04242;
			8'd67: out <= 18'h04343;
			8'd68: out <= 18'h04444;
			8'd69: out <= 18'h04545;
			8'd70: out <= 18'h04646;
			8'd71: out <= 18'h04747;
			8'd72: out <= 18'h04848;
			8'd73: out <= 18'h04949;
			8'd74: out <= 18'h04a4a;
			8'd75: out <= 18'h04b4b;
			8'd76: out <= 18'h04c4c;
			8'd77: out <= 18'h04d4d;
			8'd78: out <= 18'h04e4e;
			8'd79: out <= 18'h04f4f;
			8'd80: out <= 18'h05050;
			8'd81: out <= 18'h05151;
			8'd82: out <= 18'h05252;
			8'd83: out <= 18'h05353;
			8'd84: out <= 18'h05454;
			8'd85: out <= 18'h05555;
			8'd86: out <= 18'h05656;
			8'd87: out <= 18'h05757;
			8'd88: out <= 18'h05858;
			8'd89: out <= 18'h05959;
			8'd90: out <= 18'h05a5a;
			8'd91: out <= 18'h05b5b;
			8'd92: out <= 18'h05c5c;
			8'd93: out <= 18'h05d5d;
			8'd94: out <= 18'h05e5e;
			8'd95: out <= 18'h05f5f;
			8'd96: out <= 18'h06060;
			8'd97: out <= 18'h06161;
			8'd98: out <= 18'h06262;
			8'd99: out <= 18'h06363;
			8'd100: out <= 18'h06464;
			8'd101: out <= 18'h06565;
			8'd102: out <= 18'h06666;
			8'd103: out <= 18'h06767;
			8'd104: out <= 18'h06868;
			8'd105: out <= 18'h06969;
			8'd106: out <= 18'h06a6a;
			8'd107: out <= 18'h06b6b;
			8'd108: out <= 18'h06c6c;
			8'd109: out <= 18'h06d6d;
			8'd110: out <= 18'h06e6e;
			8'd111: out <= 18'h06f6f;
			8'd112: out <= 18'h07070;
			8'd113: out <= 18'h07171;
			8'd114: out <= 18'h07272;
			8'd115: out <= 18'h07373;
			8'd116: out <= 18'h07474;
			8'd117: out <= 18'h07575;
			8'd118: out <= 18'h07676;
			8'd119: out <= 18'h07777;
			8'd120: out <= 18'h07878;
			8'd121: out <= 18'h07979;
			8'd122: out <= 18'h07a7a;
			8'd123: out <= 18'h07b7b;
			8'd124: out <= 18'h07c7c;
			8'd125: out <= 18'h07d7d;
			8'd126: out <= 18'h07e7e;
			8'd127: out <= 18'h07f7f;
			8'd128: out <= 18'h08080;
			8'd129: out <= 18'h08181;
			8'd130: out <= 18'h08282;
			8'd131: out <= 18'h08383;
			8'd132: out <= 18'h08484;
			8'd133: out <= 18'h08585;
			8'd134: out <= 18'h08686;
			8'd135: out <= 18'h08787;
			8'd136: out <= 18'h08888;
			8'd137: out <= 18'h08989;
			8'd138: out <= 18'h08a8a;
			8'd139: out <= 18'h08b8b;
			8'd140: out <= 18'h08c8c;
			8'd141: out <= 18'h08d8d;
			8'd142: out <= 18'h08e8e;
			8'd143: out <= 18'h08f8f;
			8'd144: out <= 18'h09090;
			8'd145: out <= 18'h09191;
			8'd146: out <= 18'h09292;
			8'd147: out <= 18'h09393;
			8'd148: out <= 18'h09494;
			8'd149: out <= 18'h09595;
			8'd150: out <= 18'h09696;
			8'd151: out <= 18'h09797;
			8'd152: out <= 18'h09898;
			8'd153: out <= 18'h09999;
			8'd154: out <= 18'h09a9a;
			8'd155: out <= 18'h09b9b;
			8'd156: out <= 18'h09c9c;
			8'd157: out <= 18'h09d9d;
			8'd158: out <= 18'h09e9e;
			8'd159: out <= 18'h09f9f;
			8'd160: out <= 18'h0a0a0;
			8'd161: out <= 18'h0a1a1;
			8'd162: out <= 18'h0a2a2;
			8'd163: out <= 18'h0a3a3;
			8'd164: out <= 18'h0a4a4;
			8'd165: out <= 18'h0a5a5;
			8'd166: out <= 18'h0a6a6;
			8'd167: out <= 18'h0a7a7;
			8'd168: out <= 18'h0a8a8;
			8'd169: out <= 18'h0a9a9;
			8'd170: out <= 18'h0aaaa;
			8'd171: out <= 18'h0abab;
			8'd172: out <= 18'h0acac;
			8'd173: out <= 18'h0adad;
			8'd174: out <= 18'h0aeae;
			8'd175: out <= 18'h0afaf;
			8'd176: out <= 18'h0b0b0;
			8'd177: out <= 18'h0b1b1;
			8'd178: out <= 18'h0b2b2;
			8'd179: out <= 18'h0b3b3;
			8'd180: out <= 18'h0b4b4;
			8'd181: out <= 18'h0b5b5;
			8'd182: out <= 18'h0b6b6;
			8'd183: out <= 18'h0b7b7;
			8'd184: out <= 18'h0b8b8;
			8'd185: out <= 18'h0b9b9;
			8'd186: out <= 18'h0baba;
			8'd187: out <= 18'h0bbbb;
			8'd188: out <= 18'h0bcbc;
			8'd189: out <= 18'h0bdbd;
			8'd190: out <= 18'h0bebe;
			8'd191: out <= 18'h0bfbf;
			8'd192: out <= 18'h0c0c0;
			8'd193: out <= 18'h0c1c1;
			8'd194: out <= 18'h0c2c2;
			8'd195: out <= 18'h0c3c3;
			8'd196: out <= 18'h0c4c4;
			8'd197: out <= 18'h0c5c5;
			8'd198: out <= 18'h0c6c6;
			8'd199: out <= 18'h0c7c7;
			8'd200: out <= 18'h0c8c8;
			8'd201: out <= 18'h0c9c9;
			8'd202: out <= 18'h0caca;
			8'd203: out <= 18'h0cbcb;
			8'd204: out <= 18'h0cccc;
			8'd205: out <= 18'h0cdcd;
			8'd206: out <= 18'h0cece;
			8'd207: out <= 18'h0cfcf;
			8'd208: out <= 18'h0d0d0;
			8'd209: out <= 18'h0d1d1;
			8'd210: out <= 18'h0d2d2;
			8'd211: out <= 18'h0d3d3;
			8'd212: out <= 18'h0d4d4;
			8'd213: out <= 18'h0d5d5;
			8'd214: out <= 18'h0d6d6;
			8'd215: out <= 18'h0d7d7;
			8'd216: out <= 18'h0d8d8;
			8'd217: out <= 18'h0d9d9;
			8'd218: out <= 18'h0dada;
			8'd219: out <= 18'h0dbdb;
			8'd220: out <= 18'h0dcdc;
			8'd221: out <= 18'h0dddd;
			8'd222: out <= 18'h0dede;
			8'd223: out <= 18'h0dfdf;
			8'd224: out <= 18'h0e0e0;
			8'd225: out <= 18'h0e1e1;
			8'd226: out <= 18'h0e2e2;
			8'd227: out <= 18'h0e3e3;
			8'd228: out <= 18'h0e4e4;
			8'd229: out <= 18'h0e5e5;
			8'd230: out <= 18'h0e6e6;
			8'd231: out <= 18'h0e7e7;
			8'd232: out <= 18'h0e8e8;
			8'd233: out <= 18'h0e9e9;
			8'd234: out <= 18'h0eaea;
			8'd235: out <= 18'h0ebeb;
			8'd236: out <= 18'h0ecec;
			8'd237: out <= 18'h0eded;
			8'd238: out <= 18'h0eeee;
			8'd239: out <= 18'h0efef;
			8'd240: out <= 18'h0f0f0;
			8'd241: out <= 18'h0f1f1;
			8'd242: out <= 18'h0f2f2;
			8'd243: out <= 18'h0f3f3;
			8'd244: out <= 18'h0f4f4;
			8'd245: out <= 18'h0f5f5;
			8'd246: out <= 18'h0f6f6;
			8'd247: out <= 18'h0f7f7;
			8'd248: out <= 18'h0f8f8;
			8'd249: out <= 18'h0f9f9;
			8'd250: out <= 18'h0fafa;
			8'd251: out <= 18'h0fbfb;
			8'd252: out <= 18'h0fcfc;
			8'd253: out <= 18'h0fdfd;
			8'd254: out <= 18'h0fefe;
			8'd255: out <= 18'h10000;


		endcase
	end
endmodule


// RECIPROCAL LUT
// This module takes in D = [0..255] and outputs a multiplier value equivalent
// to 60/d (d = [0..1]). This is because all 3 cases of the hue equation need to multiply the 
// value by 60/d, so we combine these terms, and add in 60*2 and 60*4 for the 
// green and blue cases, respectively, after this multiplication.
module reciprocalLUT (
	input  [7:0] in,
	output reg [31:0] out
);

always @(*) begin
		case (in)
			8'd0: out <= 32'h00000000;
			8'd1: out <= 32'h3bc40000;
			8'd2: out <= 32'h1de20000;
			8'd3: out <= 32'h13ec0000;
			8'd4: out <= 32'h0ef10000;
			8'd5: out <= 32'h0bf40000;
			8'd6: out <= 32'h09f60000;
			8'd7: out <= 32'h0889b6e0;
			8'd8: out <= 32'h07788000;
			8'd9: out <= 32'h06a40000;
			8'd10: out <= 32'h05fa0000;
			8'd11: out <= 32'h056ee8b8;
			8'd12: out <= 32'h04fb0000;
			8'd13: out <= 32'h0498ec50;
			8'd14: out <= 32'h0444db70;
			8'd15: out <= 32'h03fc0000;
			8'd16: out <= 32'h03bc4000;
			8'd17: out <= 32'h03840000;
			8'd18: out <= 32'h03520000;
			8'd19: out <= 32'h03254360;
			8'd20: out <= 32'h02fd0000;
			8'd21: out <= 32'h02d89248;
			8'd22: out <= 32'h02b7745c;
			8'd23: out <= 32'h029937a8;
			8'd24: out <= 32'h027d8000;
			8'd25: out <= 32'h02640000;
			8'd26: out <= 32'h024c7628;
			8'd27: out <= 32'h0236aaac;
			8'd28: out <= 32'h02226db8;
			8'd29: out <= 32'h020f9610;
			8'd30: out <= 32'h01fe0000;
			8'd31: out <= 32'h01ed8c64;
			8'd32: out <= 32'h01de2000;
			8'd33: out <= 32'h01cfa2e8;
			8'd34: out <= 32'h01c20000;
			8'd35: out <= 32'h01b52492;
			8'd36: out <= 32'h01a90000;
			8'd37: out <= 32'h019d8376;
			8'd38: out <= 32'h0192a1b0;
			8'd39: out <= 32'h01884ec4;
			8'd40: out <= 32'h017e8000;
			8'd41: out <= 32'h01752bb6;
			8'd42: out <= 32'h016c4924;
			8'd43: out <= 32'h0163d060;
			8'd44: out <= 32'h015bba2e;
			8'd45: out <= 32'h01540000;
			8'd46: out <= 32'h014c9bd4;
			8'd47: out <= 32'h0145882c;
			8'd48: out <= 32'h013ec000;
			8'd49: out <= 32'h01383eb2;
			8'd50: out <= 32'h01320000;
			8'd51: out <= 32'h012c0000;
			8'd52: out <= 32'h01263b14;
			8'd53: out <= 32'h0120ade4;
			8'd54: out <= 32'h011b5556;
			8'd55: out <= 32'h01162e8c;
			8'd56: out <= 32'h011136dc;
			8'd57: out <= 32'h010c6bca;
			8'd58: out <= 32'h0107cb08;
			8'd59: out <= 32'h01035270;
			8'd60: out <= 32'h00ff0000;
			8'd61: out <= 32'h00fad1d6;
			8'd62: out <= 32'h00f6c632;
			8'd63: out <= 32'h00f2db6e;
			8'd64: out <= 32'h00ef1000;
			8'd65: out <= 32'h00eb6276;
			8'd66: out <= 32'h00e7d174;
			8'd67: out <= 32'h00e45bb4;
			8'd68: out <= 32'h00e10000;
			8'd69: out <= 32'h00ddbd38;
			8'd70: out <= 32'h00da9249;
			8'd71: out <= 32'h00d77e32;
			8'd72: out <= 32'h00d48000;
			8'd73: out <= 32'h00d196cb;
			8'd74: out <= 32'h00cec1bb;
			8'd75: out <= 32'h00cc0000;
			8'd76: out <= 32'h00c950d8;
			8'd77: out <= 32'h00c6b388;
			8'd78: out <= 32'h00c42762;
			8'd79: out <= 32'h00c1abbf;
			8'd80: out <= 32'h00bf4000;
			8'd81: out <= 32'h00bce38e;
			8'd82: out <= 32'h00ba95db;
			8'd83: out <= 32'h00b8565d;
			8'd84: out <= 32'h00b62492;
			8'd85: out <= 32'h00b40000;
			8'd86: out <= 32'h00b1e830;
			8'd87: out <= 32'h00afdcb1;
			8'd88: out <= 32'h00addd17;
			8'd89: out <= 32'h00abe8fd;
			8'd90: out <= 32'h00aa0000;
			8'd91: out <= 32'h00a821c2;
			8'd92: out <= 32'h00a64dea;
			8'd93: out <= 32'h00a48421;
			8'd94: out <= 32'h00a2c416;
			8'd95: out <= 32'h00a10d79;
			8'd96: out <= 32'h009f6000;
			8'd97: out <= 32'h009dbb62;
			8'd98: out <= 32'h009c1f59;
			8'd99: out <= 32'h009a8ba3;
			8'd100: out <= 32'h00990000;
			8'd101: out <= 32'h00977c33;
			8'd102: out <= 32'h00960000;
			8'd103: out <= 32'h00948b2f;
			8'd104: out <= 32'h00931d8a;
			8'd105: out <= 32'h0091b6db;
			8'd106: out <= 32'h009056f2;
			8'd107: out <= 32'h008efd9c;
			8'd108: out <= 32'h008daaab;
			8'd109: out <= 32'h008c5df2;
			8'd110: out <= 32'h008b1746;
			8'd111: out <= 32'h0089d67d;
			8'd112: out <= 32'h00889b6e;
			8'd113: out <= 32'h008765f2;
			8'd114: out <= 32'h008635e5;
			8'd115: out <= 32'h00850b21;
			8'd116: out <= 32'h0083e584;
			8'd117: out <= 32'h0082c4ec;
			8'd118: out <= 32'h0081a938;
			8'd119: out <= 32'h00809249;
			8'd120: out <= 32'h007f8000;
			8'd121: out <= 32'h007e723f;
			8'd122: out <= 32'h007d68eb;
			8'd123: out <= 32'h007c63e7;
			8'd124: out <= 32'h007b6319;
			8'd125: out <= 32'h007a6666;
			8'd126: out <= 32'h00796db7;
			8'd127: out <= 32'h007878f2;
			8'd128: out <= 32'h00778800;
			8'd129: out <= 32'h00769aca;
			8'd130: out <= 32'h0075b13b;
			8'd131: out <= 32'h0074cb3c;
			8'd132: out <= 32'h0073e8ba;
			8'd133: out <= 32'h007309a0;
			8'd134: out <= 32'h00722dda;
			8'd135: out <= 32'h00715555;
			8'd136: out <= 32'h00708000;
			8'd137: out <= 32'h006fadc8;
			8'd138: out <= 32'h006ede9c;
			8'd139: out <= 32'h006e126b;
			8'd140: out <= 32'h006d4924;
			8'd141: out <= 32'h006c82b9;
			8'd142: out <= 32'h006bbf19;
			8'd143: out <= 32'h006afe35;
			8'd144: out <= 32'h006a4000;
			8'd145: out <= 32'h0069846a;
			8'd146: out <= 32'h0068cb65;
			8'd147: out <= 32'h006814e6;
			8'd148: out <= 32'h006760dd;
			8'd149: out <= 32'h0066af3f;
			8'd150: out <= 32'h00660000;
			8'd151: out <= 32'h00655312;
			8'd152: out <= 32'h0064a86c;
			8'd153: out <= 32'h00640000;
			8'd154: out <= 32'h006359c4;
			8'd155: out <= 32'h0062b5ad;
			8'd156: out <= 32'h006213b1;
			8'd157: out <= 32'h006173c5;
			8'd158: out <= 32'h0060d5df;
			8'd159: out <= 32'h006039f6;
			8'd160: out <= 32'h005fa000;
			8'd161: out <= 32'h005f07f3;
			8'd162: out <= 32'h005e71c7;
			8'd163: out <= 32'h005ddd72;
			8'd164: out <= 32'h005d4aed;
			8'd165: out <= 32'h005cba2e;
			8'd166: out <= 32'h005c2b2e;
			8'd167: out <= 32'h005b9de4;
			8'd168: out <= 32'h005b1249;
			8'd169: out <= 32'h005a8855;
			8'd170: out <= 32'h005a0000;
			8'd171: out <= 32'h00597943;
			8'd172: out <= 32'h0058f418;
			8'd173: out <= 32'h00587076;
			8'd174: out <= 32'h0057ee58;
			8'd175: out <= 32'h00576db7;
			8'd176: out <= 32'h0056ee8b;
			8'd177: out <= 32'h005670d0;
			8'd178: out <= 32'h0055f47e;
			8'd179: out <= 32'h00557990;
			8'd180: out <= 32'h00550000;
			8'd181: out <= 32'h005487c7;
			8'd182: out <= 32'h005410e1;
			8'd183: out <= 32'h00539b47;
			8'd184: out <= 32'h005326f5;
			8'd185: out <= 32'h0052b3e4;
			8'd186: out <= 32'h00524210;
			8'd187: out <= 32'h0051d174;
			8'd188: out <= 32'h0051620b;
			8'd189: out <= 32'h0050f3cf;
			8'd190: out <= 32'h005086bc;
			8'd191: out <= 32'h00501ace;
			8'd192: out <= 32'h004fb000;
			8'd193: out <= 32'h004f464d;
			8'd194: out <= 32'h004eddb1;
			8'd195: out <= 32'h004e7627;
			8'd196: out <= 32'h004e0fac;
			8'd197: out <= 32'h004daa3c;
			8'd198: out <= 32'h004d45d1;
			8'd199: out <= 32'h004ce269;
			8'd200: out <= 32'h004c8000;
			8'd201: out <= 32'h004c1e91;
			8'd202: out <= 32'h004bbe19;
			8'd203: out <= 32'h004b5e95;
			8'd204: out <= 32'h004b0000;
			8'd205: out <= 32'h004aa257;
			8'd206: out <= 32'h004a4597;
			8'd207: out <= 32'h0049e9bd;
			8'd208: out <= 32'h00498ec5;
			8'd209: out <= 32'h004934ab;
			8'd210: out <= 32'h0048db6d;
			8'd211: out <= 32'h00488308;
			8'd212: out <= 32'h00482b79;
			8'd213: out <= 32'h0047d4bb;
			8'd214: out <= 32'h00477ece;
			8'd215: out <= 32'h004729ac;
			8'd216: out <= 32'h0046d555;
			8'd217: out <= 32'h004681c5;
			8'd218: out <= 32'h00462ef9;
			8'd219: out <= 32'h0045dcee;
			8'd220: out <= 32'h00458ba3;
			8'd221: out <= 32'h00453b13;
			8'd222: out <= 32'h0044eb3e;
			8'd223: out <= 32'h00449c20;
			8'd224: out <= 32'h00444db7;
			8'd225: out <= 32'h00440000;
			8'd226: out <= 32'h0043b2f9;
			8'd227: out <= 32'h004366a0;
			8'd228: out <= 32'h00431af2;
			8'd229: out <= 32'h0042cfee;
			8'd230: out <= 32'h00428590;
			8'd231: out <= 32'h00423bd8;
			8'd232: out <= 32'h0041f2c2;
			8'd233: out <= 32'h0041aa4d;
			8'd234: out <= 32'h00416276;
			8'd235: out <= 32'h00411b3c;
			8'd236: out <= 32'h0040d49c;
			8'd237: out <= 32'h00408e95;
			8'd238: out <= 32'h00404924;
			8'd239: out <= 32'h00400449;
			8'd240: out <= 32'h003fc000;
			8'd241: out <= 32'h003f7c48;
			8'd242: out <= 32'h003f391f;
			8'd243: out <= 32'h003ef684;
			8'd244: out <= 32'h003eb475;
			8'd245: out <= 32'h003e72f0;
			8'd246: out <= 32'h003e31f3;
			8'd247: out <= 32'h003df17d;
			8'd248: out <= 32'h003db18c;
			8'd249: out <= 32'h003d721e;
			8'd250: out <= 32'h003d3333;
			8'd251: out <= 32'h003cf4c8;
			8'd252: out <= 32'h003cb6db;
			8'd253: out <= 32'h003c796c;
			8'd254: out <= 32'h003c3c79;
			8'd255: out <= 32'h003c0000;

		endcase
	end
endmodule

// MAXPLUSMIN LUT
// This module takes in the sum of MAX and MIN (both in [0..255]), thus
// MAXPLUSMIN = [0..510], and converts it to a multiplier value equivalent
// to 1/(max+min) (max, min = [0..1]). For saturation, depending on luminance, 
// the divisor will either be (max + min) or (2-(max+min)), so for the second
// case, we simply look up the value in reverse order.
module mpmLUT (
	input  [8:0] in,
	output reg [31:0] out
);

	
always @(in) begin
	case (in)
		9'd0: out <= 32'h00000000;
		9'd1: out <= 32'h00ff0000;
		9'd2: out <= 32'h007f8000;
		9'd3: out <= 32'h00550000;
		9'd4: out <= 32'h003fc000;
		9'd5: out <= 32'h00330000;
		9'd6: out <= 32'h002a8000;
		9'd7: out <= 32'h00246db6;
		9'd8: out <= 32'h001fe000;
		9'd9: out <= 32'h001c5555;
		9'd10: out <= 32'h00198000;
		9'd11: out <= 32'h00172e8b;
		9'd12: out <= 32'h00154000;
		9'd13: out <= 32'h00139d89;
		9'd14: out <= 32'h001236db;
		9'd15: out <= 32'h00110000;
		9'd16: out <= 32'h000ff000;
		9'd17: out <= 32'h000f0000;
		9'd18: out <= 32'h000e2aaa;
		9'd19: out <= 32'h000d6bca;
		9'd20: out <= 32'h000cc000;
		9'd21: out <= 32'h000c2492;
		9'd22: out <= 32'h000b9745;
		9'd23: out <= 32'h000b1642;
		9'd24: out <= 32'h000aa000;
		9'd25: out <= 32'h000a3333;
		9'd26: out <= 32'h0009cec4;
		9'd27: out <= 32'h000971c7;
		9'd28: out <= 32'h00091b6d;
		9'd29: out <= 32'h0008cb08;
		9'd30: out <= 32'h00088000;
		9'd31: out <= 32'h000839ce;
		9'd32: out <= 32'h0007f800;
		9'd33: out <= 32'h0007ba2e;
		9'd34: out <= 32'h00078000;
		9'd35: out <= 32'h00074924;
		9'd36: out <= 32'h00071555;
		9'd37: out <= 32'h0006e453;
		9'd38: out <= 32'h0006b5e5;
		9'd39: out <= 32'h000689d8;
		9'd40: out <= 32'h00066000;
		9'd41: out <= 32'h00063831;
		9'd42: out <= 32'h00061249;
		9'd43: out <= 32'h0005ee23;
		9'd44: out <= 32'h0005cba2;
		9'd45: out <= 32'h0005aaaa;
		9'd46: out <= 32'h00058b21;
		9'd47: out <= 32'h00056cef;
		9'd48: out <= 32'h00055000;
		9'd49: out <= 32'h0005343e;
		9'd50: out <= 32'h00051999;
		9'd51: out <= 32'h00050000;
		9'd52: out <= 32'h0004e762;
		9'd53: out <= 32'h0004cfb2;
		9'd54: out <= 32'h0004b8e3;
		9'd55: out <= 32'h0004a2e8;
		9'd56: out <= 32'h00048db6;
		9'd57: out <= 32'h00047943;
		9'd58: out <= 32'h00046584;
		9'd59: out <= 32'h00045270;
		9'd60: out <= 32'h00044000;
		9'd61: out <= 32'h00042e29;
		9'd62: out <= 32'h00041ce7;
		9'd63: out <= 32'h00040c30;
		9'd64: out <= 32'h0003fc00;
		9'd65: out <= 32'h0003ec4e;
		9'd66: out <= 32'h0003dd17;
		9'd67: out <= 32'h0003ce54;
		9'd68: out <= 32'h0003c000;
		9'd69: out <= 32'h0003b216;
		9'd70: out <= 32'h0003a492;
		9'd71: out <= 32'h0003976f;
		9'd72: out <= 32'h00038aaa;
		9'd73: out <= 32'h00037e3f;
		9'd74: out <= 32'h00037229;
		9'd75: out <= 32'h00036666;
		9'd76: out <= 32'h00035af2;
		9'd77: out <= 32'h00034fca;
		9'd78: out <= 32'h000344ec;
		9'd79: out <= 32'h00033a54;
		9'd80: out <= 32'h00033000;
		9'd81: out <= 32'h000325ed;
		9'd82: out <= 32'h00031c18;
		9'd83: out <= 32'h00031281;
		9'd84: out <= 32'h00030924;
		9'd85: out <= 32'h00030000;
		9'd86: out <= 32'h0002f711;
		9'd87: out <= 32'h0002ee58;
		9'd88: out <= 32'h0002e5d1;
		9'd89: out <= 32'h0002dd7b;
		9'd90: out <= 32'h0002d555;
		9'd91: out <= 32'h0002cd5c;
		9'd92: out <= 32'h0002c590;
		9'd93: out <= 32'h0002bdef;
		9'd94: out <= 32'h0002b677;
		9'd95: out <= 32'h0002af28;
		9'd96: out <= 32'h0002a800;
		9'd97: out <= 32'h0002a0fd;
		9'd98: out <= 32'h00029a1f;
		9'd99: out <= 32'h00029364;
		9'd100: out <= 32'h00028ccc;
		9'd101: out <= 32'h00028656;
		9'd102: out <= 32'h00028000;
		9'd103: out <= 32'h000279c9;
		9'd104: out <= 32'h000273b1;
		9'd105: out <= 32'h00026db6;
		9'd106: out <= 32'h000267d9;
		9'd107: out <= 32'h00026217;
		9'd108: out <= 32'h00025c71;
		9'd109: out <= 32'h000256e6;
		9'd110: out <= 32'h00025174;
		9'd111: out <= 32'h00024c1b;
		9'd112: out <= 32'h000246db;
		9'd113: out <= 32'h000241b2;
		9'd114: out <= 32'h00023ca1;
		9'd115: out <= 32'h000237a6;
		9'd116: out <= 32'h000232c2;
		9'd117: out <= 32'h00022df2;
		9'd118: out <= 32'h00022938;
		9'd119: out <= 32'h00022492;
		9'd120: out <= 32'h00022000;
		9'd121: out <= 32'h00021b81;
		9'd122: out <= 32'h00021714;
		9'd123: out <= 32'h000212bb;
		9'd124: out <= 32'h00020e73;
		9'd125: out <= 32'h00020a3d;
		9'd126: out <= 32'h00020618;
		9'd127: out <= 32'h00020204;
		9'd128: out <= 32'h0001fe00;
		9'd129: out <= 32'h0001fa0b;
		9'd130: out <= 32'h0001f627;
		9'd131: out <= 32'h0001f252;
		9'd132: out <= 32'h0001ee8b;
		9'd133: out <= 32'h0001ead3;
		9'd134: out <= 32'h0001e72a;
		9'd135: out <= 32'h0001e38e;
		9'd136: out <= 32'h0001e000;
		9'd137: out <= 32'h0001dc7f;
		9'd138: out <= 32'h0001d90b;
		9'd139: out <= 32'h0001d5a3;
		9'd140: out <= 32'h0001d249;
		9'd141: out <= 32'h0001cefa;
		9'd142: out <= 32'h0001cbb7;
		9'd143: out <= 32'h0001c880;
		9'd144: out <= 32'h0001c555;
		9'd145: out <= 32'h0001c234;
		9'd146: out <= 32'h0001bf1f;
		9'd147: out <= 32'h0001bc14;
		9'd148: out <= 32'h0001b914;
		9'd149: out <= 32'h0001b61e;
		9'd150: out <= 32'h0001b333;
		9'd151: out <= 32'h0001b051;
		9'd152: out <= 32'h0001ad79;
		9'd153: out <= 32'h0001aaaa;
		9'd154: out <= 32'h0001a7e5;
		9'd155: out <= 32'h0001a529;
		9'd156: out <= 32'h0001a276;
		9'd157: out <= 32'h00019fcb;
		9'd158: out <= 32'h00019d2a;
		9'd159: out <= 32'h00019a90;
		9'd160: out <= 32'h00019800;
		9'd161: out <= 32'h00019577;
		9'd162: out <= 32'h000192f6;
		9'd163: out <= 32'h0001907d;
		9'd164: out <= 32'h00018e0c;
		9'd165: out <= 32'h00018ba2;
		9'd166: out <= 32'h00018940;
		9'd167: out <= 32'h000186e5;
		9'd168: out <= 32'h00018492;
		9'd169: out <= 32'h00018245;
		9'd170: out <= 32'h00018000;
		9'd171: out <= 32'h00017dc1;
		9'd172: out <= 32'h00017b88;
		9'd173: out <= 32'h00017957;
		9'd174: out <= 32'h0001772c;
		9'd175: out <= 32'h00017507;
		9'd176: out <= 32'h000172e8;
		9'd177: out <= 32'h000170d0;
		9'd178: out <= 32'h00016ebd;
		9'd179: out <= 32'h00016cb1;
		9'd180: out <= 32'h00016aaa;
		9'd181: out <= 32'h000168a9;
		9'd182: out <= 32'h000166ae;
		9'd183: out <= 32'h000164b8;
		9'd184: out <= 32'h000162c8;
		9'd185: out <= 32'h000160dd;
		9'd186: out <= 32'h00015ef7;
		9'd187: out <= 32'h00015d17;
		9'd188: out <= 32'h00015b3b;
		9'd189: out <= 32'h00015965;
		9'd190: out <= 32'h00015794;
		9'd191: out <= 32'h000155c7;
		9'd192: out <= 32'h00015400;
		9'd193: out <= 32'h0001523d;
		9'd194: out <= 32'h0001507e;
		9'd195: out <= 32'h00014ec4;
		9'd196: out <= 32'h00014d0f;
		9'd197: out <= 32'h00014b5e;
		9'd198: out <= 32'h000149b2;
		9'd199: out <= 32'h0001480a;
		9'd200: out <= 32'h00014666;
		9'd201: out <= 32'h000144c6;
		9'd202: out <= 32'h0001432b;
		9'd203: out <= 32'h00014193;
		9'd204: out <= 32'h00014000;
		9'd205: out <= 32'h00013e70;
		9'd206: out <= 32'h00013ce4;
		9'd207: out <= 32'h00013b5c;
		9'd208: out <= 32'h000139d8;
		9'd209: out <= 32'h00013858;
		9'd210: out <= 32'h000136db;
		9'd211: out <= 32'h00013562;
		9'd212: out <= 32'h000133ec;
		9'd213: out <= 32'h0001327a;
		9'd214: out <= 32'h0001310b;
		9'd215: out <= 32'h00012fa0;
		9'd216: out <= 32'h00012e38;
		9'd217: out <= 32'h00012cd4;
		9'd218: out <= 32'h00012b73;
		9'd219: out <= 32'h00012a15;
		9'd220: out <= 32'h000128ba;
		9'd221: out <= 32'h00012762;
		9'd222: out <= 32'h0001260d;
		9'd223: out <= 32'h000124bc;
		9'd224: out <= 32'h0001236d;
		9'd225: out <= 32'h00012222;
		9'd226: out <= 32'h000120d9;
		9'd227: out <= 32'h00011f93;
		9'd228: out <= 32'h00011e50;
		9'd229: out <= 32'h00011d10;
		9'd230: out <= 32'h00011bd3;
		9'd231: out <= 32'h00011a98;
		9'd232: out <= 32'h00011961;
		9'd233: out <= 32'h0001182b;
		9'd234: out <= 32'h000116f9;
		9'd235: out <= 32'h000115c9;
		9'd236: out <= 32'h0001149c;
		9'd237: out <= 32'h00011371;
		9'd238: out <= 32'h00011249;
		9'd239: out <= 32'h00011123;
		9'd240: out <= 32'h00011000;
		9'd241: out <= 32'h00010edf;
		9'd242: out <= 32'h00010dc0;
		9'd243: out <= 32'h00010ca4;
		9'd244: out <= 32'h00010b8a;
		9'd245: out <= 32'h00010a72;
		9'd246: out <= 32'h0001095d;
		9'd247: out <= 32'h0001084a;
		9'd248: out <= 32'h00010739;
		9'd249: out <= 32'h0001062b;
		9'd250: out <= 32'h0001051e;
		9'd251: out <= 32'h00010414;
		9'd252: out <= 32'h0001030c;
		9'd253: out <= 32'h00010206;
		9'd254: out <= 32'h00010102;
		9'd255: out <= 32'h00010000;
		9'd256: out <= 32'h0000ff00;
		9'd257: out <= 32'h0000fe01;
		9'd258: out <= 32'h0000fd05;
		9'd259: out <= 32'h0000fc0b;
		9'd260: out <= 32'h0000fb13;
		9'd261: out <= 32'h0000fa1d;
		9'd262: out <= 32'h0000f929;
		9'd263: out <= 32'h0000f836;
		9'd264: out <= 32'h0000f745;
		9'd265: out <= 32'h0000f656;
		9'd266: out <= 32'h0000f569;
		9'd267: out <= 32'h0000f47e;
		9'd268: out <= 32'h0000f395;
		9'd269: out <= 32'h0000f2ad;
		9'd270: out <= 32'h0000f1c7;
		9'd271: out <= 32'h0000f0e2;
		9'd272: out <= 32'h0000f000;
		9'd273: out <= 32'h0000ef1e;
		9'd274: out <= 32'h0000ee3f;
		9'd275: out <= 32'h0000ed61;
		9'd276: out <= 32'h0000ec85;
		9'd277: out <= 32'h0000ebaa;
		9'd278: out <= 32'h0000ead1;
		9'd279: out <= 32'h0000e9fa;
		9'd280: out <= 32'h0000e924;
		9'd281: out <= 32'h0000e850;
		9'd282: out <= 32'h0000e77d;
		9'd283: out <= 32'h0000e6ab;
		9'd284: out <= 32'h0000e5db;
		9'd285: out <= 32'h0000e50d;
		9'd286: out <= 32'h0000e440;
		9'd287: out <= 32'h0000e374;
		9'd288: out <= 32'h0000e2aa;
		9'd289: out <= 32'h0000e1e1;
		9'd290: out <= 32'h0000e11a;
		9'd291: out <= 32'h0000e054;
		9'd292: out <= 32'h0000df8f;
		9'd293: out <= 32'h0000decc;
		9'd294: out <= 32'h0000de0a;
		9'd295: out <= 32'h0000dd49;
		9'd296: out <= 32'h0000dc8a;
		9'd297: out <= 32'h0000dbcc;
		9'd298: out <= 32'h0000db0f;
		9'd299: out <= 32'h0000da53;
		9'd300: out <= 32'h0000d999;
		9'd301: out <= 32'h0000d8e0;
		9'd302: out <= 32'h0000d828;
		9'd303: out <= 32'h0000d772;
		9'd304: out <= 32'h0000d6bc;
		9'd305: out <= 32'h0000d608;
		9'd306: out <= 32'h0000d555;
		9'd307: out <= 32'h0000d4a3;
		9'd308: out <= 32'h0000d3f2;
		9'd309: out <= 32'h0000d343;
		9'd310: out <= 32'h0000d294;
		9'd311: out <= 32'h0000d1e7;
		9'd312: out <= 32'h0000d13b;
		9'd313: out <= 32'h0000d08f;
		9'd314: out <= 32'h0000cfe5;
		9'd315: out <= 32'h0000cf3c;
		9'd316: out <= 32'h0000ce95;
		9'd317: out <= 32'h0000cdee;
		9'd318: out <= 32'h0000cd48;
		9'd319: out <= 32'h0000cca3;
		9'd320: out <= 32'h0000cc00;
		9'd321: out <= 32'h0000cb5d;
		9'd322: out <= 32'h0000cabb;
		9'd323: out <= 32'h0000ca1a;
		9'd324: out <= 32'h0000c97b;
		9'd325: out <= 32'h0000c8dc;
		9'd326: out <= 32'h0000c83e;
		9'd327: out <= 32'h0000c7a2;
		9'd328: out <= 32'h0000c706;
		9'd329: out <= 32'h0000c66b;
		9'd330: out <= 32'h0000c5d1;
		9'd331: out <= 32'h0000c538;
		9'd332: out <= 32'h0000c4a0;
		9'd333: out <= 32'h0000c409;
		9'd334: out <= 32'h0000c372;
		9'd335: out <= 32'h0000c2dd;
		9'd336: out <= 32'h0000c249;
		9'd337: out <= 32'h0000c1b5;
		9'd338: out <= 32'h0000c122;
		9'd339: out <= 32'h0000c090;
		9'd340: out <= 32'h0000c000;
		9'd341: out <= 32'h0000bf6f;
		9'd342: out <= 32'h0000bee0;
		9'd343: out <= 32'h0000be52;
		9'd344: out <= 32'h0000bdc4;
		9'd345: out <= 32'h0000bd37;
		9'd346: out <= 32'h0000bcab;
		9'd347: out <= 32'h0000bc20;
		9'd348: out <= 32'h0000bb96;
		9'd349: out <= 32'h0000bb0c;
		9'd350: out <= 32'h0000ba83;
		9'd351: out <= 32'h0000b9fb;
		9'd352: out <= 32'h0000b974;
		9'd353: out <= 32'h0000b8ed;
		9'd354: out <= 32'h0000b868;
		9'd355: out <= 32'h0000b7e3;
		9'd356: out <= 32'h0000b75e;
		9'd357: out <= 32'h0000b6db;
		9'd358: out <= 32'h0000b658;
		9'd359: out <= 32'h0000b5d6;
		9'd360: out <= 32'h0000b555;
		9'd361: out <= 32'h0000b4d4;
		9'd362: out <= 32'h0000b454;
		9'd363: out <= 32'h0000b3d5;
		9'd364: out <= 32'h0000b357;
		9'd365: out <= 32'h0000b2d9;
		9'd366: out <= 32'h0000b25c;
		9'd367: out <= 32'h0000b1df;
		9'd368: out <= 32'h0000b164;
		9'd369: out <= 32'h0000b0e9;
		9'd370: out <= 32'h0000b06e;
		9'd371: out <= 32'h0000aff4;
		9'd372: out <= 32'h0000af7b;
		9'd373: out <= 32'h0000af03;
		9'd374: out <= 32'h0000ae8b;
		9'd375: out <= 32'h0000ae14;
		9'd376: out <= 32'h0000ad9d;
		9'd377: out <= 32'h0000ad28;
		9'd378: out <= 32'h0000acb2;
		9'd379: out <= 32'h0000ac3e;
		9'd380: out <= 32'h0000abca;
		9'd381: out <= 32'h0000ab56;
		9'd382: out <= 32'h0000aae3;
		9'd383: out <= 32'h0000aa71;
		9'd384: out <= 32'h0000aa00;
		9'd385: out <= 32'h0000a98e;
		9'd386: out <= 32'h0000a91e;
		9'd387: out <= 32'h0000a8ae;
		9'd388: out <= 32'h0000a83f;
		9'd389: out <= 32'h0000a7d0;
		9'd390: out <= 32'h0000a762;
		9'd391: out <= 32'h0000a6f4;
		9'd392: out <= 32'h0000a687;
		9'd393: out <= 32'h0000a61b;
		9'd394: out <= 32'h0000a5af;
		9'd395: out <= 32'h0000a544;
		9'd396: out <= 32'h0000a4d9;
		9'd397: out <= 32'h0000a46e;
		9'd398: out <= 32'h0000a405;
		9'd399: out <= 32'h0000a39b;
		9'd400: out <= 32'h0000a333;
		9'd401: out <= 32'h0000a2cb;
		9'd402: out <= 32'h0000a263;
		9'd403: out <= 32'h0000a1fc;
		9'd404: out <= 32'h0000a195;
		9'd405: out <= 32'h0000a12f;
		9'd406: out <= 32'h0000a0c9;
		9'd407: out <= 32'h0000a064;
		9'd408: out <= 32'h0000a000;
		9'd409: out <= 32'h00009f9b;
		9'd410: out <= 32'h00009f38;
		9'd411: out <= 32'h00009ed5;
		9'd412: out <= 32'h00009e72;
		9'd413: out <= 32'h00009e10;
		9'd414: out <= 32'h00009dae;
		9'd415: out <= 32'h00009d4d;
		9'd416: out <= 32'h00009cec;
		9'd417: out <= 32'h00009c8b;
		9'd418: out <= 32'h00009c2c;
		9'd419: out <= 32'h00009bcc;
		9'd420: out <= 32'h00009b6d;
		9'd421: out <= 32'h00009b0f;
		9'd422: out <= 32'h00009ab1;
		9'd423: out <= 32'h00009a53;
		9'd424: out <= 32'h000099f6;
		9'd425: out <= 32'h00009999;
		9'd426: out <= 32'h0000993d;
		9'd427: out <= 32'h000098e1;
		9'd428: out <= 32'h00009885;
		9'd429: out <= 32'h0000982a;
		9'd430: out <= 32'h000097d0;
		9'd431: out <= 32'h00009776;
		9'd432: out <= 32'h0000971c;
		9'd433: out <= 32'h000096c3;
		9'd434: out <= 32'h0000966a;
		9'd435: out <= 32'h00009611;
		9'd436: out <= 32'h000095b9;
		9'd437: out <= 32'h00009561;
		9'd438: out <= 32'h0000950a;
		9'd439: out <= 32'h000094b3;
		9'd440: out <= 32'h0000945d;
		9'd441: out <= 32'h00009406;
		9'd442: out <= 32'h000093b1;
		9'd443: out <= 32'h0000935b;
		9'd444: out <= 32'h00009306;
		9'd445: out <= 32'h000092b2;
		9'd446: out <= 32'h0000925e;
		9'd447: out <= 32'h0000920a;
		9'd448: out <= 32'h000091b6;
		9'd449: out <= 32'h00009163;
		9'd450: out <= 32'h00009111;
		9'd451: out <= 32'h000090be;
		9'd452: out <= 32'h0000906c;
		9'd453: out <= 32'h0000901b;
		9'd454: out <= 32'h00008fc9;
		9'd455: out <= 32'h00008f78;
		9'd456: out <= 32'h00008f28;
		9'd457: out <= 32'h00008ed8;
		9'd458: out <= 32'h00008e88;
		9'd459: out <= 32'h00008e38;
		9'd460: out <= 32'h00008de9;
		9'd461: out <= 32'h00008d9a;
		9'd462: out <= 32'h00008d4c;
		9'd463: out <= 32'h00008cfe;
		9'd464: out <= 32'h00008cb0;
		9'd465: out <= 32'h00008c63;
		9'd466: out <= 32'h00008c15;
		9'd467: out <= 32'h00008bc9;
		9'd468: out <= 32'h00008b7c;
		9'd469: out <= 32'h00008b30;
		9'd470: out <= 32'h00008ae4;
		9'd471: out <= 32'h00008a99;
		9'd472: out <= 32'h00008a4e;
		9'd473: out <= 32'h00008a03;
		9'd474: out <= 32'h000089b8;
		9'd475: out <= 32'h0000896e;
		9'd476: out <= 32'h00008924;
		9'd477: out <= 32'h000088da;
		9'd478: out <= 32'h00008891;
		9'd479: out <= 32'h00008848;
		9'd480: out <= 32'h00008800;
		9'd481: out <= 32'h000087b7;
		9'd482: out <= 32'h0000876f;
		9'd483: out <= 32'h00008727;
		9'd484: out <= 32'h000086e0;
		9'd485: out <= 32'h00008699;
		9'd486: out <= 32'h00008652;
		9'd487: out <= 32'h0000860b;
		9'd488: out <= 32'h000085c5;
		9'd489: out <= 32'h0000857f;
		9'd490: out <= 32'h00008539;
		9'd491: out <= 32'h000084f4;
		9'd492: out <= 32'h000084ae;
		9'd493: out <= 32'h00008469;
		9'd494: out <= 32'h00008425;
		9'd495: out <= 32'h000083e0;
		9'd496: out <= 32'h0000839c;
		9'd497: out <= 32'h00008359;
		9'd498: out <= 32'h00008315;
		9'd499: out <= 32'h000082d2;
		9'd500: out <= 32'h0000828f;
		9'd501: out <= 32'h0000824c;
		9'd502: out <= 32'h0000820a;
		9'd503: out <= 32'h000081c8;
		9'd504: out <= 32'h00008186;
		9'd505: out <= 32'h00008144;
		9'd506: out <= 32'h00008103;
		9'd507: out <= 32'h000080c1;
		9'd508: out <= 32'h00008081;
		9'd509: out <= 32'h00008040;
		9'd510: out <= 32'h00008000;
		9'd511: out <= 32'h00000000;
	endcase
end
endmodule