module Micro_pannel(
			input clk,
			input reset,
			input[1:0] command,
			output Micro_pannel_pin
			);
	
	// Logic definition
	logic[31:0] counter = 0;
	logic[31:0] duty_Micro_p;
	
	logic pwm;
	
	// Output definition
	assign Micro_pannel_pin = pwm;

	PWM pwm_FS(
		.clk			(clk), 
		.reset		(reset), 
		.duty			(duty_Micro_p), 
		.pwm			(pwm)
		);	
	
	// Control logic
	always_ff @(posedge clk) begin
	
		case(command)
			2'b01: 	begin														// avancer
							if (counter < 30000000) begin
								duty_Micro_p <= 60000;
								counter <= counter + 1;
							end
							else begin
								duty_Micro_p <= 75000;
							end
						end
			2'b10: 	begin														// reculer
							if (counter < 30000000) begin
								duty_Micro_p <= 90000;
								counter <= counter + 1;
							end
							else begin
								duty_Micro_p <= 75000;
							end
						end
			default: begin 
							duty_Micro_p = 75000;
							counter <= 0;
						end
		endcase
	end

endmodule
