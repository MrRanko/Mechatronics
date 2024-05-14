module PWM_Generator(input clk,
			input reset,
			input[31:0] duty,
			output[31:0] current_duty,
			output pwm);
			
	logic[31:0] LAST_POS_MEM = 80000; // make parameter

	logic[31:0] period_counter = 0;

	always_ff @(posedge clk) begin
	
		if (period_counter < 1000000) period_counter <= period_counter + 1; // 20ms period counter 
		
		else begin 
		
			period_counter = 0;
			
			if ((LAST_POS_MEM >= duty + 750) | (LAST_POS_MEM <= duty - 750)) begin 
				LAST_POS_MEM <= (duty < LAST_POS_MEM) ? LAST_POS_MEM - 350 : LAST_POS_MEM + 350;
 			end
			else LAST_POS_MEM <= duty;
		end
	end
	
	// Output
	assign current_duty = LAST_POS_MEM;
	assign pwm = (period_counter < LAST_POS_MEM);
	

endmodule
