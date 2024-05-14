module Micro_ent(
			input clk,
			input reset,
			input[1:0] command,
			output Micro_ent_pin
			);
	
	// Logic definition
	logic[31:0] duty_Micro_ent;
	
	logic[31:0] current_duty_Micro_ent;
	logic pwm;
	
	// Output definition
	assign Micro_ent_pin = pwm;

	PWM_Generator pwm_Micro_ent(
		.clk				(clk), 
		.reset			(reset), 
		.duty				(duty_Micro_ent),
		.current_duty	(current_duty_Micro_ent),
		.pwm				(pwm)
		);
	
	// Control logic
	always_ff @(posedge clk) begin
	
		case(command)
			2'b01: 	duty_Micro_ent = 60000; //intérieur
			
			2'b10: 	duty_Micro_ent = 100000; //extérieur
			
			2'b11:	begin
							if (current_duty_Micro_ent == 80000) duty_Micro_ent = 100000;
							
							else if (current_duty_Micro_ent == 100000) duty_Micro_ent = 80000;
			
						end
			
			
			default: duty_Micro_ent = 80000; //aligné
		endcase
	end

endmodule
