`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:14:27 04/07/2015 
// Design Name: 
// Module Name:    KBDController 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module KBDController(
    input CLK,
    input RESET,
	// Memory controller
	input MEMC_RAM_ENABLE,
	input MEMC_RAM_WRITE,
	input [15:0] MEMC_RAM_ADDR,
	output [15:0] MEMC_RAM_DATA_R,
	input [15:0] MEMC_RAM_DATA_W,
	// Interrupt controller
	output INTC_IRQ,
	input INTC_IACK,
	input INTC_IEND,
	// Frontend
	input IN_SERIAL_RX
    );
	
	/*
	* Serial receiver
	*/
	wire [7:0] rxData;
	wire rxReady;
	SerialReceiver srx(CLK, RESET, IN_SERIAL_RX, rxData, rxReady);
	
	/*
	* Keybuffer
	*/
	reg [15:0] buffer;
	reg loadBuffer;
	reg resetBuffer;
	
	always @(posedge CLK) begin
		if (resetBuffer)
			buffer <= 0;
		else if (loadBuffer) begin
			buffer[15:8] <= 0;
			buffer[7:0] <= rxData;
		end
	end
	
	/*
	* Interrupt
	*/
	reg irq;
	wire iack;
	wire iend;
	
	assign INTC_IRQ = irq;
	assign iack = INTC_IACK;
	assign iend = INTC_IEND;
	
	/*
	* State machine
	*/
	reg [3:0] state;
	reg [3:0] nextState;
	
	always @(posedge CLK) begin
		if (RESET)
			state <= 0;
		else
			state <= nextState;
	end
	
	always @(*) begin
		loadBuffer = 0;
		resetBuffer = 0;
		
		irq = 0;
		
		nextState = 0;
		
		case (state)
			0: begin
				resetBuffer = 1;
				nextState = 1;
			end
			
			1: begin
				if (rxReady)
					nextState = 2;
				else
					nextState = 1;
			end
			
			2: begin
				if (~rxReady)
					nextState = 3;
				else
					nextState = 2;
			end
			
			3: begin
				if (rxReady)
					nextState = 4;
				else
					nextState = 3;
			end
			
			4: begin
				loadBuffer = 1;
				nextState = 5;
			end
			
			5: begin
				irq = 1;
				if (iack)
					nextState = 6;
				else
					nextState = 5;
			end
			
			6: begin
				if (iend)
					nextState = 1;
				else
					nextState = 6;
			end
		endcase
	end
	
	assign MEMC_RAM_DATA_R = (MEMC_RAM_ENABLE) ? buffer : 16'bz;

endmodule
