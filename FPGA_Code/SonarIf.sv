module SonarIf(	input logic clk, reset,
					output logic trigger,
					input logic echo,
					output logic [31:0] distance);

	// Logic definition
	
	// Global Counter --- Cycle period, T = 100ms
	logic [31:0] counter = 0;
	
	logic [31:0] counter_echo;
	logic [31:0] distance_cons;
	
	// Outputs
	assign trigger = (counter < 600); // 600 normalement
	assign distance = distance_cons;
	
	always_ff @(posedge clk) begin
	
		
		counter <= (counter < 5000000) ? counter + 1 : 0;
		
		if ((echo) & (counter < 3500000)) counter_echo <= counter_echo + 1;
		
		else if ((~echo) & (counter_echo != 0) & (counter < 5000000)) begin 
			distance_cons <= counter_echo;
			counter_echo <= 0;
		end
		
		else counter_echo <= 0;
		
	end

endmodule
