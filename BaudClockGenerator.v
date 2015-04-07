`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:55:46 04/07/2015 
// Design Name: 
// Module Name:    BaudClockGenerator 
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
module BaudClockGenerator(
    input CLK,
    input RESET,
    output reg BCLK
    );
	
	parameter BAUD_RATE = 57600; // actual hardware baud rate
	parameter BAUD_RATE_MULTIPLIER = 1;
	//parameter BAUD_RATE_MULTIPLIER = 200; // <-- baud rate multiplier for simulation
	parameter CLOCK_RATE = 25000000;
	parameter CLOCKS_WAIT = (CLOCK_RATE / (BAUD_RATE * BAUD_RATE_MULTIPLIER)) / 2;
	
	reg [15:0] counter;
	
	always @(posedge CLK) begin
		if (RESET) begin
			BCLK <= 0;
			counter <= 0;
		end
		else if (counter == 0) begin
			BCLK <= ~BCLK;
			counter <= counter + 1;
		end
		else if (counter >= (CLOCKS_WAIT - 1)) begin
			counter <= 0;
		end
		else begin
			counter <= counter + 1;
		end
	end

endmodule
