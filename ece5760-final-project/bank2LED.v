module bank2LED (
	input  [4:0] bestBank,
	output reg [7:0] R,
	output reg [7:0] G,
	output reg [7:0] B
);

always @(*) begin
	case (bestBank)
		5'd0:    begin R <= 8'd255; G <= 8'd47 ; B <= 8'd0  ; end
		5'd1:    begin R <= 8'd255; G <= 8'd145; B <= 8'd0  ; end
		5'd2:    begin R <= 8'd255; G <= 8'd238; B <= 8'd0  ; end
		5'd3:    begin R <= 8'd174; G <= 8'd255; B <= 8'd0  ; end
		5'd4:    begin R <= 8'd81 ; G <= 8'd255; B <= 8'd0  ; end
		5'd5:    begin R <= 8'd0  ; G <= 8'd255; B <= 8'd17 ; end
		5'd6:    begin R <= 8'd0  ; G <= 8'd255; B <= 8'd111; end
		5'd7:    begin R <= 8'd0  ; G <= 8'd255; B <= 8'd208; end
		5'd8:    begin R <= 8'd0  ; G <= 8'd208; B <= 8'd255; end
		5'd9:    begin R <= 8'd0  ; G <= 8'd110; B <= 8'd255; end
		5'd10:   begin R <= 8'd0  ; G <= 8'd17 ; B <= 8'd255; end
		5'd11:   begin R <= 8'd81 ; G <= 8'd0  ; B <= 8'd255; end
		5'd12:   begin R <= 8'd179; G <= 8'd0  ; B <= 8'd255; end
		5'd13:   begin R <= 8'd255; G <= 8'd0  ; B <= 8'd238; end
		5'd14:   begin R <= 8'd255; G <= 8'd0  ; B <= 8'd145; end
		5'd15:   begin R <= 8'd255; G <= 8'd0  ; B <= 8'd47 ; end
		default: begin R <= 8'd0  ; G <= 8'd0  ; B <= 8'd0  ; end
	endcase
end

endmodule