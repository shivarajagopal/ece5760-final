module example1(
	input					clk, 
	input					clk2,
	input    			reset,
	input					play_me,
	
	output reg [15:0] out
);

reg [7:0] R,G,B;
	wire [8:0] hue;
	wire [17:0] sat, lum;
	

//State Machine
always @ (posedge clk) begin
	if (reset) begin
		out 			<= sat;
	end
	else if (play_me) begin
		out 			<= sat + 16'd1;
	end
	else begin
		out 			<= sat;
	end
end

rgb2hsl DUT(
		.R(R),
		.G(G),
		.B(B),
		.hue(hue),
		.sat(sat),
		.lum(lum)
	);

endmodule
