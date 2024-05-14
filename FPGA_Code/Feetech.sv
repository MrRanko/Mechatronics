module Feetech(
			input clk,
			input reset,
			input[1:0] command,
			output FS_pin
			);
	
	// Logic definition
	logic[31:0] counter = 0;
	logic[31:0] duty_FS;
	logic MEM = 0;
	
	logic pwm;
	
	// Output definition
	assign FS_pin = pwm;

	PWM pwm_FS(
		.clk			(clk), 
		.reset		(reset), 
		.duty			(duty_FS), 
		.pwm			(pwm)
		);	
	
	// Control logic
	always_ff @(posedge clk) begin
	
		case(command)
			2'b01: 	begin														// avancer
							if ((counter < 100000000) & (~MEM)) begin
								duty_FS <= 60000;
								counter <= counter + 1;
							end
							else if (counter == 100000000) begin 
								MEM <= ~MEM;
								counter <= 0;
								duty_FS <= 75000;
							end
							else begin
								counter <= 0;
								duty_FS <= 75000;
							end
						end
			2'b10: 	begin														// reculer
							if ((counter < 100000000) & (MEM)) begin
								duty_FS <= 90000;
								counter <= counter + 1;
							end
							else if (counter == 100000000) begin 
								MEM <= ~MEM;
								counter <= 0;
								duty_FS <= 75000;
							end
							else begin
								counter <= 0;
								duty_FS <= 75000;
							end
						end
			default: duty_FS = 75000;
		endcase
	end

endmodule
