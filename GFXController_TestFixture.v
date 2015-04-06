`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:30:01 03/29/2015
// Design Name:   GFXController
// Module Name:   /home/xerodotc/ISE Projects/ProjectPon_VCentury/GFXController_TestFixture.v
// Project Name:  ProjectPon_VCentury
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: GFXController
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module GFXController_TestFixture;

	// Inputs
	reg CLK;
	reg RESET;
	reg MEMC_RAM_ENABLE;
	reg MEMC_RAM_WRITE;
	reg [15:0] MEMC_RAM_ADDR;
	reg [15:0] MEMC_RAM_DATA_W;
	reg INTC_IACK;
	reg INTC_IEND;

	// Outputs
	wire [15:0] MEMC_RAM_DATA_R;
	wire INTC_IRQ;
	wire OUT_SERIAL_TX;

	// Instantiate the Unit Under Test (UUT)
	GFXController uut (
		.CLK(CLK), 
		.RESET(RESET), 
		.MEMC_RAM_ENABLE(MEMC_RAM_ENABLE), 
		.MEMC_RAM_WRITE(MEMC_RAM_WRITE), 
		.MEMC_RAM_ADDR(MEMC_RAM_ADDR), 
		.MEMC_RAM_DATA_R(MEMC_RAM_DATA_R), 
		.MEMC_RAM_DATA_W(MEMC_RAM_DATA_W), 
		.INTC_IRQ(INTC_IRQ), 
		.INTC_IACK(INTC_IACK), 
		.INTC_IEND(INTC_IEND), 
		.OUT_SERIAL_TX(OUT_SERIAL_TX)
	);
	
	// Note: CLK must be defined as a wire when using this method

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
		MEMC_RAM_ENABLE = 0;
		MEMC_RAM_WRITE = 0;
		MEMC_RAM_ADDR = 0;
		MEMC_RAM_DATA_W = 0;
		INTC_IACK = 0;
		INTC_IEND = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		RESET = 0;
	end
	
	reg [3:0] state;
	reg [3:0] nextState;
	
	reg vramAddrReset;
	reg vramAddrInc;
	always @(posedge CLK) begin
		if (vramAddrReset)
			MEMC_RAM_ADDR <= 0;
		else if (vramAddrInc)
			MEMC_RAM_ADDR <= MEMC_RAM_ADDR + 1;
	end
	
	reg [3:0] counter;
	reg resetCounter;
	reg incCounter;
	always @(posedge CLK) begin
		if (resetCounter)
			counter <= 0;
		else if (incCounter)
			counter <= counter + 1;
	end
	
	always @(posedge CLK) begin
		if (RESET)
			state <= 0;
		else
			state <= nextState;
	end
	
	always @(*) begin
		vramAddrReset = 0;
		vramAddrInc = 0;
		resetCounter = 0;
		incCounter = 0;
		INTC_IACK = 0;
		INTC_IEND = 0;
		MEMC_RAM_ENABLE = 0;
		MEMC_RAM_WRITE = 0;
		MEMC_RAM_DATA_W = 0;
	
		case (state)
			0: begin
				vramAddrReset = 1;
				resetCounter = 1;
				nextState = 1;
			end
			
			1: begin
				if (INTC_IRQ)
					nextState = 2;
				else
					nextState = 1;
			end
			
			2: begin
				INTC_IACK = 1;
				nextState = 3;
			end
			
			3: begin
				MEMC_RAM_ENABLE = 1;
				MEMC_RAM_WRITE = 1;
				if (MEMC_RAM_ADDR[9:0] == 10'b0000_000000 ||
					MEMC_RAM_ADDR[9:0] == 10'b0000_111111 ||
					MEMC_RAM_ADDR[9:0] == 10'b1111_000000 ||
					MEMC_RAM_ADDR[9:0] == 10'b1111_111111)
					MEMC_RAM_DATA_W = (16'h0741 + counter);
				else
					MEMC_RAM_DATA_W = 16'h00;
				nextState = 4;
			end
			
			4: begin
				vramAddrInc = 1;
				if (MEMC_RAM_ADDR < 10'b11111_11111)
					nextState = 3;
				else
					nextState = 5;
			end
			
			5: begin
				INTC_IEND = 1;
				vramAddrReset = 1;
				incCounter = 1;
				nextState = 1;
			end
		endcase
	end
	
	TerminalWriter twrt(CLK, RESET, OUT_SERIAL_TX);
endmodule

