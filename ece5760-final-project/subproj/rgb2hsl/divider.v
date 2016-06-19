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