module histogram (
	input        clk,
	input        reset,
	input [8:0]  hue,
	input [47:0] importance,
	output [4:0] bestBank
);

reg [47:0] bank0,bank1,bank2,bank3,bank4,bank5,bank6,bank7,bank8,bank9,bank10,bank11,bank12,bank13,bank14,bank15;
reg [47:0] maxVal;
reg [4:0]  bankReg;

assign bestBank = bankReg;

always @(posedge clk) begin
	if (reset) begin
		bank0  <= 48'd0;
		bank1  <= 48'd0;
		bank2  <= 48'd0;
		bank3  <= 48'd0;
		bank4  <= 48'd0;
		bank5  <= 48'd0;
		bank6  <= 48'd0;
		bank7  <= 48'd0;
		bank8  <= 48'd0;
		bank9  <= 48'd0;
		bank10 <= 48'd0;
		bank11 <= 48'd0;
		bank12 <= 48'd0;
		bank13 <= 48'd0;
		bank14 <= 48'd0;
		bank15 <= 48'd0;
		maxVal <= 48'd0;
		bankReg <= 5'd0;
	end
	else begin 
		if (hue < 9'd23) begin
			bank0 = bank0 + importance;
			if (bank0 > maxVal) begin
				maxVal <= bank0;
				bankReg <= 5'd0;
			end
		end
		else if (hue < 9'd45) begin
			bank1 = bank1 + importance;
			if (bank1 > maxVal) begin
				maxVal <= bank1;
				bankReg <= 5'd1;
			end
		end
		else if (hue < 9'd68) begin
			bank2 = bank2 + importance;
			if (bank2 > maxVal) begin
				maxVal <= bank2;
				bankReg <= 5'd2;
			end
		end
		else if (hue < 9'd90) begin
			bank3 = bank3 + importance;
			if (bank3 > maxVal) begin
				maxVal <= bank3;
				bankReg <= 5'd3;
			end
		end
		else if (hue < 9'd113) begin
			bank4 = bank4 + importance;
			if (bank4 > maxVal) begin
				maxVal <= bank4;
				bankReg <= 5'd4;
			end
		end
		else if (hue < 9'd135) begin
			bank5 = bank5 + importance;
			if (bank5 > maxVal) begin
				maxVal <= bank5;
				bankReg <= 5'd5;
			end
		end
		else if (hue < 9'd158) begin
			bank6 = bank6 + importance;
			if (bank6 > maxVal) begin
				maxVal <= bank6;
				bankReg <= 5'd6;
			end
		end
		else if (hue < 9'd180) begin
			bank7 = bank7 + importance;
			if (bank7 > maxVal) begin
				maxVal <= bank7;
				bankReg <= 5'd7;
			end
		end
		else if (hue < 9'd203) begin
			bank8 = bank8 + importance;
			if (bank8 > maxVal) begin
				maxVal <= bank8;
				bankReg <= 5'd8;
			end
		end
		else if (hue < 9'd225) begin
			bank9 = bank9 + importance;
			if (bank9 > maxVal) begin
				maxVal <= bank9;
				bankReg <= 5'd9;
			end
		end
		else if (hue < 9'd248) begin
			bank10 = bank10 + importance;
			if (bank10 > maxVal) begin
				maxVal <= bank10;
				bankReg <= 5'd10;
			end
		end
		else if (hue < 9'd270) begin
			bank11 = bank11 + importance;
			if (bank11 > maxVal) begin
				maxVal <= bank11;
				bankReg <= 5'd11;
			end
		end
		else if (hue < 9'd293) begin
			bank12 = bank12 + importance;
			if (bank12 > maxVal) begin
				maxVal <= bank12;
				bankReg <= 5'd12;
			end
		end
		else if (hue < 9'd315) begin
			bank13 = bank13 + importance;
			if (bank13 > maxVal) begin
				maxVal <= bank13;
				bankReg <= 5'd13;
			end
		end
		else if (hue < 9'd338) begin
			bank14 = bank14 + importance;
			if (bank14 > maxVal) begin
				maxVal <= bank14;
				bankReg <= 5'd14;
			end
		end
		else begin
			bank15 = bank15 + importance;
			if (bank15 > maxVal) begin
				maxVal <= bank15;
				bankReg <= 5'd15;
			end
		end
	end
end

endmodule