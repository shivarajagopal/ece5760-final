module system(
	input       clk,
	input       reset,
	input [7:0] R,
	input [7:0] G,
	input [7:0] B,
	output [4:0] bestBank
);


	wire [8:0] hue;
	wire [17:0] sat, lum;
	reg [8:0] hueReg1, hueReg2;
	reg [17:0] satReg, lumReg;
	wire [47:0] importance;
	reg  [47:0] importanceReg1, importanceReg2;
	reg         resetReg1, resetReg2;
	reg  [17:0] constantReg;

	always@(posedge clk) begin
		if (reset) begin
			hueReg1 <= 9'd0;
			satReg  <= 18'd0;
			lumReg  <= 18'd0;
			constantReg    <= 18'd0;
		end
		else begin
			hueReg1 <= hue;
			satReg  <= sat;
			lumReg  <= lum;
			constantReg    <= 18'h10000;
		end
		hueReg2 <= hueReg1;
		importanceReg1 <= importance;
		resetReg1 <= reset;
		resetReg2 <= resetReg1;
	end

	rgb2hsl rgb2hslConv(
		.R(R),
		.G(G),
		.B(B),
		.hue(hue),
		.sat(sat),
		.lum(lum)
	);
	
	importance importanceCalc(
		.constant(constantReg),
		.saturation(satReg),
		.luminance(lumReg),
		.importance(importance)
	);
	
	histogram hist(
		.clk(clk),
		.reset(resetReg2),
		.hue(hueReg2),
		.importance(importanceReg1),
		.bestBank(bestBank)
	);
	

endmodule
