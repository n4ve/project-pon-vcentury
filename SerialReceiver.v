`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:59:08 03/28/2015 
// Design Name: 
// Module Name:    SerialReceiver 
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
module SerialReceiver(
    input CLK,
	input RESET,
    input IN_SERIAL_RX,
    output [7:0] OUT_DATA,
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
	reg sampleTemp;
	always @(posedge CLK) begin
		if (resetTemp)
			temp <= 0;
		else if (sampleTemp)
			temp <= (temp >> 1) | (IN_SERIAL_RX << 7);
	end
	
	reg [7:0] data;
	reg resetData;
	reg loadData;
	always @(posedge CLK) begin
		if (resetData)
			data <= 0;
		else if (loadData)
			data <= temp;
	end
	
	reg ready;
	
	reg [3:0] state = 0;
	reg [3:0] nextState = 0;
	
	always @(posedge CLK) begin
		if (RESET)
			state <= 0;
		else
			state <= nextState;
	end
	
	always @(*) begin
		resetCounterCW = 0;
		incCounterCW = 0;
		resetCounterDB = 0;
		incCounterDB = 0;
		resetTemp = 0;
		sampleTemp = 0;
		resetData = 0;
		loadData = 0;
		ready = 0;
		nextState = 0;
		
		case (state)
			0: begin
				resetCounterCW = 1;
				resetCounterDB = 1;
				resetTemp = 1;
				resetData = 1;
				nextState = 1;
			end
			
			1: begin
				resetCounterCW = 1;
				resetCounterDB = 1;
				resetTemp = 1;
				ready = 1;
				if (IN_SERIAL_RX)
					nextState = 1;
				else
					nextState = 2;
			end
			
			2: begin
				incCounterCW = 1;
				if (counterDB >= 8)
					nextState = 4;
				else if (counterCW < CLOCKS_WAIT)
					nextState = 2;
				else
					nextState = 3;
			end
			
			3: begin
				sampleTemp = 1;
				incCounterDB = 1;
				resetCounterCW = 1;
				nextState = 2;
			end
			
			4: begin
				loadData = 1;
				nextState = 1;
			end
		endcase
	end
	
	assign OUT_DATA = data;
	assign OUT_STATUS_READY = ready;

endmodule
