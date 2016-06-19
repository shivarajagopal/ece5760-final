`timescale 1ns/1ns

module testbench();
	
	reg clk_50, clk_25, reset;
	reg [7:0] R,G,B;
	wire [8:0] H;
	wire [17:0] S, L;
	//Initialize clocks and index
	initial begin
		clk_50 = 1'b0;
		clk_25 = 1'b0;
	end
	
	//Toggle the clocks
	always begin
		#10
		clk_50  = !clk_50;
	end
	
	always begin
		#20
		clk_25  = !clk_25;
	end
	
	//Intialize and drive signals
	initial begin
		reset  = 1'b0;
		#10 
		reset  = 1'b1;
		#30
		reset  = 1'b0;
		R = 8'd128;
		G = 8'd128;
		B = 8'd128;
		reset = 1'b1;
		#50;
		$stop;
	end
	

	// Instantiate DUT
	rgb2hsl DUT(
		.R(R),
		.G(G),
		.B(B),
		.hue(H),
		.sat(S),
		.lum(L)
	);
endmodule


