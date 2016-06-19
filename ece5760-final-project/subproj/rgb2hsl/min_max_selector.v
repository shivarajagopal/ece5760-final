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