module step(input logic clk, reset,
	    input logic reverse_rot,
	    input logic on,
	    output logic a,
	    output logic b,
	    output logic c,
	    output logic d);

// Logic definition

	logic [31:0] clock_counter = 1;
	logic [31:0] delay = 100000; // delay = 2 ms = 10^5 clocks (one clock = 20 ns) // delay = 100 only for rapid test

// FSM definition

	typedef enum logic[2:0] {S0, S1, S2, S3, S4} statetype;
	statetype state, nextstate;

	// State Register
	always_ff @(posedge clk, posedge reset) begin
		if (reset) state <= S0;
		else state <= nextstate;
	end
	
	// State Operation
	always_ff @(posedge clk) begin

		if (state == S1 | state == S2 | state == S3 | state == S4) clock_counter <= (clock_counter < delay) ? clock_counter + 1 : 1;
		
		else clock_counter <= 1;
		
	end

	// Next State Logic
	always_comb begin
		case(state)
			S0:	if (on) nextstate = S1;
				else nextstate = S0;

			S1:	if (clock_counter == delay) nextstate = S2;
				else nextstate = S1;

			S2:	if (clock_counter == delay) nextstate = S3;
				else nextstate = S2;
			
			S3:	if (clock_counter == delay) nextstate = S4;
				else nextstate = S3;

			S4:	if ((clock_counter == delay) & (~on)) nextstate = S0;
					else if (clock_counter == delay) nextstate = S1;
				else nextstate = S4;

			default: nextstate = S0;
		endcase
	end
	
	// Output Logic
	assign a = (~reverse_rot) ? (state == S4) : (state == S1);
	assign b = (~reverse_rot) ? (state == S3) : (state == S2);
	assign c = (~reverse_rot) ? (state == S2) : (state == S3);
	assign d = (~reverse_rot) ? (state == S1) : (state == S4);

endmodule
