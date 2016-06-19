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
	assign hue = (hueMux[15:0] > 16'h8000) ? hueMux[24:16] + 1 : hueMux[24:16];

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