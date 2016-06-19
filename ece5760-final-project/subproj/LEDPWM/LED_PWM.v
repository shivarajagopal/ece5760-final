module LED_PWM(
	input       clk,
	input [7:0] R,
	input [7:0] G,
	input [7:0] B,
	output      PWM_R,
	output      PWM_G,
	output      PWM_B
);

	reg [7:0] counter;
	reg out_r, out_g, out_b;
	
	assign PWM_R = out_r;
	assign PWM_G = out_g;
	assign PWM_B = out_b;
	
	always@(posedge clk) begin
		counter <= counter+8'd1;
		
		if (counter < R) begin
			out_r <= 1'b1;
		end
		else begin
			out_r <= 1'b0;
		end
		
		if (counter < G) begin
			out_g <= 1'b1;
		end
		else begin
			out_g <= 1'b0;
		end
		
		if (counter < B) begin
			out_b <= 1'b1;
		end
		else begin
			out_b <= 1'b0;
		end
	end


endmodule