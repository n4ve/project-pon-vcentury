`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   00:11:12 04/11/2015
// Design Name:   ProjectPon_VCentury
// Module Name:   /home/xerodotc/ISE Projects/ProjectPon_VCentury/ProjectPon_VCentury_TestFixture.v
// Project Name:  ProjectPon_VCentury
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ProjectPon_VCentury
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ProjectPon_VCentury_TestFixture;

	// Inputs
	reg CLK;
	reg IN_PB_RESET;
	wire IN_SERIAL_RX;

	// Outputs
	wire OUT_SERIAL_TX;
	wire OUT_LED;
	wire OUT_BUZZER;

	// Instantiate the Unit Under Test (UUT)
	ProjectPon_VCentury uut (
		.CLK(CLK), 
		.IN_PB_RESET(IN_PB_RESET), 
		.IN_SERIAL_RX(IN_SERIAL_RX), 
		.OUT_SERIAL_TX(OUT_SERIAL_TX),
		.OUT_LED(OUT_LED),
		.OUT_BUZZER(OUT_BUZZER)
	);
	
	parameter PERIOD = 40;

	initial begin
		CLK = 1'b0;
		#(PERIOD/2);
		forever
			#(PERIOD/2) CLK = ~CLK;
	end

	initial begin
		// Initialize Inputs
		CLK = 0;
		IN_PB_RESET = 0;

		// Wait 100 ns for global reset to finish
		#100;
		IN_PB_RESET = 1;
        
		// Add stimulus here

	end
	
	TerminalWriter twrt(CLK, ~IN_PB_RESET, OUT_SERIAL_TX);
	//assign IN_SERIAL_RX = 1;
	TerminalReader trdr(CLK, ~IN_PB_RESET, IN_SERIAL_RX);
      
endmodule

