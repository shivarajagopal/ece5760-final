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

	
	always @(*) begin
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
			default: out <= out;
		endcase
	end
endmodule