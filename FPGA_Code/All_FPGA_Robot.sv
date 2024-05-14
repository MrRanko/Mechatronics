
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module All_FPGA_Robot(

	//////////// CLOCK //////////
	CLOCK_50,

	//////////// LED //////////
	LED,

	//////////// KEY //////////
	KEY,

	//////////// SDRAM //////////
	DRAM_ADDR,
	DRAM_BA,
	DRAM_CAS_N,
	DRAM_CKE,
	DRAM_CLK,
	DRAM_CS_N,
	DRAM_DQ,
	DRAM_DQM,
	DRAM_RAS_N,
	DRAM_WE_N,

	//////////// EEPROM //////////
	I2C_SCLK,
	I2C_SDAT,

	//////////// ADC //////////
	ADC_CS_N,
	ADC_SADDR,
	ADC_SCLK,
	ADC_SDAT,

	//////////// 2x13 GPIO Header //////////
	GPIO_2,
	GPIO_2_IN,

	//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	GPIO0,
	GPIO0_IN,

	//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
	GPIO1,
	GPIO1_IN 
);

//=======================================================
//  PARAMETER declarations
//=======================================================

logic clk;
logic reset;

//=======================================================
//  PORT declarations
//=======================================================

//////////// CLOCK //////////
input 		          		CLOCK_50;

//////////// LED //////////
output		     [7:0]		LED;

//////////// KEY //////////
input 		     [1:0]		KEY;

//////////// SDRAM //////////
output		    [12:0]		DRAM_ADDR;
output		     [1:0]		DRAM_BA;
output		          		DRAM_CAS_N;
output		          		DRAM_CKE;
output		          		DRAM_CLK;
output		          		DRAM_CS_N;
inout 		    [15:0]		DRAM_DQ;
output		     [1:0]		DRAM_DQM;
output		          		DRAM_RAS_N;
output		          		DRAM_WE_N;

//////////// EEPROM //////////
output		          		I2C_SCLK;
inout 		          		I2C_SDAT;

//////////// ADC //////////
output		          		ADC_CS_N;
output		          		ADC_SADDR;
output		          		ADC_SCLK;
input 		          		ADC_SDAT;

//////////// 2x13 GPIO Header //////////
inout 		    [12:0]		GPIO_2;
input 		     [2:0]		GPIO_2_IN;

//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
inout 		    [33:0]		GPIO0;
input 		     [1:0]		GPIO0_IN;

//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
inout 		    [33:0]		GPIO1;
input 		     [1:0]		GPIO1_IN;


//=======================================================
//  REG/WIRE declarations
//=======================================================

	assign clk = CLOCK_50;
	assign reset = ~KEY[0];
	
//=======================================================
//  Actuators Declaration
//=======================================================

	// Motor control singals --------------
	
	//PWM 
	logic [31:0] duty_DSS_F, duty_DSS_p, duty_Para, duty_tapis; //logic [31:0] duty_FS, duty_Micro_p, duty_Micro_ent;
	
	//FS
	logic [1:0] FS_command;
	
	// Micro_ent
	logic [1:0] Micro_ent_command;
	
	//Micro_p
	logic [1:0] Micro_p_command;
	
	//Linear
	logic [1:0] status;

	
	
	// Motor functions --------------

	PWM pwm_Dss_F(
		.clk			(clk), 
		.reset		(reset), 
		.duty			(duty_DSS_F), 
		.pwm			(GPIO1[11])
		);
	
	PWM pwm_Dss_p(
		.clk			(clk), 
		.reset		(reset), 
		.duty			(duty_DSS_p), 
		.pwm			(GPIO1[15])
		);
		
	PWM pwm_Parallax(
		.clk			(clk), 
		.reset		(reset), 
		.duty			(duty_Para), 
		.pwm			(GPIO1[13])
		);
	
	Feetech pwm_FS(
		.clk			(clk), 
		.reset		(reset), 
		.command		(FS_command), 
		.FS_pin		(GPIO1[10])
		);
	
	Micro_pannel pwm_Micro_p(
		.clk					(clk), 
		.reset				(reset), 
		.command				(Micro_p_command), 
		.Micro_pannel_pin	(GPIO1[12])
		);
	
	Micro_ent pwm_Micro_ent(
		.clk				(clk), 
		.reset			(reset), 
		.command			(Micro_ent_command), 
		.Micro_ent_pin	(GPIO1[22])
		);
	
	Linear linear(
		.clk			(clk), 
		.reset		(reset), 
		.status		(status), 
		.out			({GPIO1[27], GPIO1[29]})
		);
		
	PWM pwm_Tapis(
		.clk			(clk), 
		.reset		(reset), 
		.duty			(duty_tapis), 
		.pwm			(GPIO1[18])  // 18 ou 19
		);


	//Control Logic
	always_comb begin

		//=======================================================
		// For information
		//=======================================================
	
		// pwm for motors in µs
		
		// DSS-M15-S :  		// 500µs <= duty <= 2500µs : 500µs = 0°, 1500µs = 90°, 2500µs = 270°
		// FeetechR; 			// 900µs <= duty <= 2100µs : 900µs = -max, 1500µs = 0, 2500µs = +max
		// Parallax; 			// 1280µs <= duty <= 1720µs : 1280µs = -max, 1500µs = 0, 1720µs = +max
		// Micro_motor; 		// 1000µs <= duty <= 2000µs : 1000µs = -max, 1500µs = 0, 2000µs = +max
		
		// How to convert:
		//
		// t (µs) = 800 000 * 20 * 10^(-3)
		//
		// Exemple : duty_cycle = 80/1000 = 8% = 1600µs = 1.6 ms
		
		//=======================================================
		// Bloc Fourche
		//=======================================================
		
		// Parralax ------------------------------
		case(ReadDataM[1:0])
			2'b01: 	duty_Para = (GPIO0[25]) ? 75000 : 67000;  // sortir le bloc
			2'b10: 	duty_Para = (GPIO0[5]) ? 75000 : 83000; // rentrer le bloc
			default: duty_Para = 75000;
		endcase
		
		// DSS_Fourche ---------------------------
		case(ReadDataM[3:2])
			2'b01: 	duty_DSS_F = 62000; // position haute
			2'b10: 	duty_DSS_F = 85000; // position intermédiare
			default: duty_DSS_F = 110000; // position basse
		endcase
		
		// FS_Fourche ----------------------------
		case(ReadDataM[5:4])
			2'b01: 	FS_command = 2'b01; //avancer
			2'b10: 	FS_command = 2'b10; //reculer
			default: FS_command = 2'b00;
		endcase
		
		//=======================================================
		// Bloc entonnoir
		//=======================================================
		
		// Linear ----------------------------
		case(ReadDataM[7:6])
			2'b01: 	status = 2'b01; //avancer
			2'b10: 	status = 2'b10; //reculer
			default: status = 2'b00;
		endcase
		
		// Micro_Entonnoir -------------------------
		case(ReadDataM[9:8])
			2'b01: 	Micro_ent_command = 2'b01; //intérieur
			2'b10: 	Micro_ent_command = 2'b10; //extérieur
			2'b11:	Micro_ent_command = 2'b11; //aller-retour
			default: Micro_ent_command = 0; //aligné
		endcase
		
		//=======================================================
		// Bloc Solar Pannel
		//=======================================================

		// DSS_Pannel ---------------------------
		case(ReadDataM[11:10])
			2'b01: 	duty_DSS_p = 77000; // position basse
			2'b10: 	duty_DSS_p = 69000; // position basse - intermédiaire
			default: duty_DSS_p = 43000; // position haute
		endcase
		
		// Micro_Pannel -------------------------
		case(ReadDataM[13:12])
			2'b01: 	Micro_p_command = 2'b01;
			2'b10: 	Micro_p_command = 2'b10;
			default: Micro_p_command = 2'b00;
		endcase
		
		//=======================================================
		// Tapis
		//=======================================================
		
		// Tapis -------------------------
		case(ReadDataM[15:14])
			2'b01: 	duty_tapis = 115000;
			2'b10: 	duty_tapis = 90000;
			2'b11: 	duty_tapis = 50000;
			
			default: duty_tapis = 75000;
		endcase
		
	end
	
//=======================================================
//  Sonars declaration
//=======================================================
		
	logic [31:0] DataFromSonar0,  DataFromSonar1,  DataFromSonar2,  DataFromSonar3;
	logic [31:0] DataAdrM_Sonar0, DataAdrM_Sonar1, DataAdrM_Sonar2, DataAdrM_Sonar3;
	
	assign DataAdrM_Sonar0 = 32'b000100;
	assign DataAdrM_Sonar1 = 32'b001000;
	assign DataAdrM_Sonar2 = 32'b001100;
	assign DataAdrM_Sonar3 = 32'b010000;

//=======================================================
//  Structural coding SPI
//=======================================================

   logic [31:0] 	WriteDataM, DataAdrM;
	logic 		 	MemWriteM;
	logic [31:0] 	ReadDataM, ReadData_dmem, ReadData_spi;
	
	logic  			cs_dmem, cs_led, cs_spi;
	logic [7:0] 	led_reg;
	logic [31:0]	spi_data;
	
	// Set spi inputs
	assign MemWriteM = 1;
	
	// SPI Data	
	always_ff @(posedge clk) begin
		if ((state == S0) | (state == S3)) ReadDataM <= spi_data;
	end
	
	//LED
	assign LED = ReadDataM[7:0];	

//=======================================================
//  SPI
//=======================================================

	logic 			spi_clk, spi_cs, spi_mosi, spi_miso;

	spi_slave spi_slave_instance(
		.SPI_CLK    (spi_clk),
		.SPI_CS     (spi_cs),
		.SPI_MOSI   (spi_mosi),
		.SPI_MISO   (spi_miso),
		.Data_WE    (MemWriteM),
		.Data_Addr  (DataAdrM),
		.Data_Write (WriteDataM),
		.Data_Read  (spi_data),
		.Clk        (clk)
	);
	
	assign spi_clk  		= GPIO0[3];	// SCLK = pin 16 = GPIO_11 (Digital)				| (Mecatro) SCLK = pin 6 = GPIO[3]
	assign spi_cs   		= GPIO0[2];	// CE0  = pin 14 = GPIO_9  (Digital)				| (Mecatro) CE0  = pin 5 = GPIO[2]
	assign spi_mosi     	= GPIO0[0];	// MOSI = pin 20 = GPIO_15 (Digital)				| (Mecatro) MOSI = pin 2 = GPIO[0]
	
	assign GPIO0[1] = spi_cs ? 1'bz : spi_miso;  // MISO = pin 18 = GPIO_13 (Digital) | (Mecatro) MISO = pin 4 = GPIO[1]	

	logic new_clock;
	
	Baudrate_Generator BAUD(
							.CLOCK(clk),
							.reset(reset),
							.new_clock(new_clock));
	
	logic [31:0] DataToSend_cons;
	logic [31:0] DataAdrM_cons;
	
	typedef enum logic[2:0] {S0,S1,S2,S3,S4,S5} statetype;
	statetype state, nextstate;
	
	always_ff @(posedge new_clock) begin
		if (reset) state <= S0;
		else state <= nextstate;
	end
		
	always_comb begin
		case(state)
			S0: begin
					DataToSend_cons <= 0;
					DataAdrM_cons <= 0;
					nextstate <= S1;
				 end
			S1: begin
					DataToSend_cons <= DataFromSonar0;
					DataAdrM_cons <= DataAdrM_Sonar0;
					nextstate <= S2;
				 end
			S2: begin
					DataToSend_cons <= DataFromSonar1;
					DataAdrM_cons <= DataAdrM_Sonar1;
					nextstate <= S3;
				 end
			S3: begin
					DataToSend_cons <= 0;
					DataAdrM_cons <= 0;
					nextstate <= S4;
				 end
			S4: begin
					DataToSend_cons <= DataFromSonar2;
					DataAdrM_cons <= DataAdrM_Sonar2;
					nextstate <= S5;
				 end
			S5: begin
					DataToSend_cons <= DataFromSonar3;
					DataAdrM_cons <= DataAdrM_Sonar3;
					nextstate <= S0;
				 end
			default: nextstate <= S0;
		endcase
	end
	
	assign WriteDataM = DataToSend_cons;
	assign DataAdrM   = DataAdrM_cons;

	//assign DataToSend = DataFromSonar0;
	//assign DataAdrM   = DataAdrM_Sonar0;

	// Sonar
	// Trigger : GPIO[17]; Echo : GPIO[16]

	SonarIf Sonar0(clk, reset, GPIO0[10], GPIO0[11], DataFromSonar0);  // GPIO0[10], GPIO0[11]
	SonarIf Sonar1(clk, reset, GPIO0[12], GPIO0[13], DataFromSonar1);  // GPIO0[12], GPIO0[13]
   SonarIf Sonar2(clk, reset, GPIO0[16], GPIO0[17], DataFromSonar2);  // GPIO0[16], GPIO0[17]
	SonarIf Sonar3(clk, reset, GPIO0[18], GPIO0[19], DataFromSonar3);  // GPIO0[18], GPIO0[19]

endmodule



module Baudrate_Generator(input CLOCK,
						input reset,
						output new_clock);

	logic [9:0] counter = 10'b0;
	
	always_ff @(posedge CLOCK) begin
		if (reset) counter = 0;
		else if (counter == 10'd1000) counter = 0;
		else counter = counter + 1;
	end
	
	assign new_clock = (counter == 10'd0);
endmodule
