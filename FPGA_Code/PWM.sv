module PWM(input clk,
			input reset,
			input[31:0] duty,
			output pwm);

	logic[31:0] counter = 0;
	//   0 < duty < 100 000 

	always_ff @(posedge clk) begin
		if (counter < 1000000) counter <= counter + 1;
		else counter = 0;
	end

	assign pwm = (counter < duty);

endmodule