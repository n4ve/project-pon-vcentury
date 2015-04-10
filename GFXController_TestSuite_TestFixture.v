`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:58:56 03/30/2015
// Design Name:   GFXController_TestSuite
// Module Name:   /home/xerodotc/ISE Projects/ProjectPon_VCentury/GFXController_TestSuite_TestFixture.v
// Project Name:  ProjectPon_VCentury
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: GFXController_TestSuite
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module GFXController_TestSuite_TestFixture;

	// Inputs
	reg CLK;
	reg IN_PB_RESET;
	//reg IN_SERIAL_RX;
	wire IN_SERIAL_RX;

	// Outputs
	wire OUT_SERIAL_TX;
	wire BCLK;

	// Instantiate the Unit Under Test (UUT)
	GFXController_TestSuite uut (
		.CLK(CLK), 
		.IN_PB_RESET(IN_PB_RESET), 
		.IN_SERIAL_RX(IN_SERIAL_RX),
		.OUT_SERIAL_TX(OUT_SERIAL_TX)
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
		//IN_SERIAL_RX = 1;
		IN_PB_RESET = 0;

		// Wait 100 ns for global reset to finish
		#100;
		IN_PB_RESET = 1;
        
		// Add stimulus here

	end
	
	BaudClockGenerator bcg(CLK, ~IN_PB_RESET, BCLK);
	
	TerminalWriter twrt(CLK, ~IN_PB_RESET, OUT_SERIAL_TX);
	//assign IN_SERIAL_RX = 1;
	TerminalReader trdr(CLK, ~IN_PB_RESET, IN_SERIAL_RX);
endmodule

