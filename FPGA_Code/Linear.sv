module Linear(input logic clk, reset,
	      input logic [1:0] status,
	      output logic [1:0] out);

	// State Register
	always_ff @(posedge clk, posedge reset) begin
	
		if (reset) begin 
			out <= 2'b00;
		end
		
		else begin 
			out <= status;
		end
	end

endmodule
