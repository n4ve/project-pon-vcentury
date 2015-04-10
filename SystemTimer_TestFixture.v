`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:29:42 04/10/2015
// Design Name:   SystemTimer
// Module Name:   /home/xerodotc/ISE Projects/ProjectPon_VCentury/SystemTimer_TestFixture.v
// Project Name:  ProjectPon_VCentury
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: SystemTimer
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module SystemTimer_TestFixture;

	// Inputs
	reg CLK;
	reg RESET;
	reg INTC_IACK;
	reg INTC_IEND;

	// Outputs
	wire INTC_IRQ;

	// Instantiate the Unit Under Test (UUT)
	SystemTimer uut (
		.CLK(CLK), 
		.RESET(RESET), 
		.INTC_IRQ(INTC_IRQ), 
		.INTC_IACK(INTC_IACK), 
		.INTC_IEND(INTC_IEND)
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
		INTC_IACK = 0;
		INTC_IEND = 0;

		// Wait 100 ns for global reset to finish
		#100; RESET = 0;
        
		// Add stimulus here
		#40; INTC_IACK = 1;
		#40; INTC_IACK = 0;
		#80; INTC_IEND = 1;
		#40; INTC_IEND = 0;
		
		#20000120; INTC_IACK = 1;
		#40; INTC_IACK = 0;
		#80; INTC_IEND = 1;
		#40; INTC_IEND = 0;
		
		#20000120; INTC_IACK = 1;
		#40; INTC_IACK = 0;
		#80; INTC_IEND = 1;
		#40; INTC_IEND = 0;
	end
      
endmodule

