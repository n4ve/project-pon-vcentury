`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:04:34 03/28/2015 
// Design Name: 
// Module Name:    SerialTransmitter 
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
module SerialTransmitter(
    input CLK,
    input RESET,
    input [7:0] IN_DATA,
    input IN_SEND,
    output OUT_SERIAL_TX,
	output OUT_STATUS_READY
    );

	parameter CLOCKS_WAIT = 434; // baud rate 57600
	
	reg [11:0] counterCW;
	reg resetCounterCW;
	reg incCounterCW;
	always @(posedge CLK) begin
		if (resetCounterCW)
			counterCW <= 0;
		else if (incCounterCW)
			counterCW <= counterCW + 1;
	end
	
	reg [3:0] counterDB;
	reg resetCounterDB;
	reg incCounterDB;
	always @(posedge CLK) begin
		if (resetCounterDB)
			counterDB <= 0;
		else if (incCounterDB)
			counterDB <= counterDB + 1;
	end
	
	reg [7:0] temp;
	reg resetTemp;
	reg loadTemp;
	always @(posedge CLK) begin
		if (resetTemp)
			temp <= 0;
		else if (loadTemp)
			temp <= IN_DATA;
	end
	
	reg [3:0] state = 0;
	reg [3:0] nextState = 0;
	
	always @(posedge CLK) begin
		if (RESET)
			state <= 0;
		else
			state <= nextState;
	end
	
	reg serialTx;
	reg ready;
	
	always @(*) begin
		resetCounterCW = 0;
		incCounterCW = 0;
		resetCounterDB = 0;
		incCounterDB = 0;
		resetTemp = 0;
		loadTemp = 0;
		serialTx = 1;
		ready = 0;
		nextState = 0;
		
		case (state)
			0: begin
				resetCounterCW = 1;
				resetCounterDB = 1;
				resetTemp = 1;
				nextState = 1;
			end
			
			1: begin
				resetCounterCW = 1;
				resetCounterDB = 1;
				loadTemp = 1;
				ready = 1;
				if (IN_SEND)
					nextState = 2;
				else
					nextState = 1;
			end
			
			2: begin
				serialTx = 0;
				incCounterCW = 1;
				if (counterCW < CLOCKS_WAIT)
					nextState = 2;
				else
					nextState = 3;
			end
			
			3: begin
				serialTx = 0;
				resetCounterCW = 1;
				nextState = 4;
			end
			
			4: begin
				serialTx = temp[counterDB];
				incCounterCW = 1;
				if (counterCW < CLOCKS_WAIT)
					nextState = 4;
				else
					nextState = 5;
			end
			
			5: begin
				serialTx = temp[counterDB];
				resetCounterCW = 1;
				incCounterDB = 1;
				if (counterDB < 7)
					nextState = 4;
				else
					nextState = 6;
			end
			
			6: begin
				serialTx = 1;
				incCounterCW = 1;
				if (counterCW < CLOCKS_WAIT)
					nextState = 6;
				else
					nextState = 1;
			end
		endcase
	end
	
	assign OUT_SERIAL_TX = serialTx;
	assign OUT_STATUS_READY = ready;

endmodule
