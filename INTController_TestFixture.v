`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:00:34 04/10/2015
// Design Name:   INTController
// Module Name:   /home/xerodotc/ISE Projects/ProjectPon_VCentury/INTController_TestFixture.v
// Project Name:  ProjectPon_VCentury
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: INTController
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module INTController_TestFixture;

	// Inputs
	reg CLK;
	reg RESET;
	reg C_IACK;
	reg C_IEND;
	reg [0:1] IRQ;

	// Outputs
	wire [1:0] C_IRQ;
	wire [0:1] IACK;
	wire [0:1] IEND;

	// Instantiate the Unit Under Test (UUT)
	INTController uut (
		.CLK(CLK), 
		.RESET(RESET), 
		.C_IRQ(C_IRQ), 
		.C_IACK(C_IACK), 
		.C_IEND(C_IEND), 
		.IRQ(IRQ), 
		.IACK(IACK), 
		.IEND(IEND)
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
		RESET = 1;
		C_IACK = 0;
		C_IEND = 0;
		IRQ = 0;

		// Wait 100 ns for global reset to finish
		#100;
		RESET = 0;
		#20;
        
		// Add stimulus here
		#40; IRQ = 2'b10;
		#80; C_IACK = 1;
		#40; C_IACK = 0; IRQ = 2'b00;
		#80; C_IEND = 1;
		#40; C_IEND = 0;
		
		#120; IRQ = 2'b01;
		#80; C_IACK = 1;
		#40; C_IACK = 0; IRQ = 2'b00;
		#80; C_IEND = 1;
		#40; C_IEND = 0;
		
		#120; IRQ = 2'b11;
		#80; C_IACK = 1;
		#40; C_IACK = 0; IRQ = 2'b01;
		#80; C_IEND = 1;
		#40; C_IEND = 0;
		
		#120; C_IACK = 1;
		#40; C_IACK = 0; IRQ = 2'b00;
		#80; C_IEND = 1;
		#40; C_IEND = 0;
		
		#120; $stop;
	end
      
endmodule

