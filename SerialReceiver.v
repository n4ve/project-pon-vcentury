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
	
	wire BCLK;
	BaudClockGenerator bcg(CLK, RESET, BCLK);
	
	reg [7:0] temp;
	reg resetTemp;
	reg sampleTemp;
	always @(posedge BCLK) begin
		if (resetTemp)
			temp <= 0;
		else if (sampleTemp)
			temp <= (temp >> 1) | (IN_SERIAL_RX << 7);
	end
	
	reg [7:0] data;
	reg resetData;
	reg loadData;
	always @(posedge BCLK) begin
		if (resetData)
			data <= 0;
		else if (loadData)
			data <= temp;
	end
	
	reg ready;
	
	reg [3:0] state = 0;
	reg [3:0] nextState = 0;
	
	always @(posedge BCLK) begin
		if (RESET)
			state <= 0;
		else
			state <= nextState;
	end
	
	always @(*) begin
		resetTemp = 0;
		sampleTemp = 0;
		resetData = 0;
		loadData = 0;
		ready = 0;
		nextState = 0;
		
		case (state)
			0: begin
				resetTemp = 1;
				resetData = 1;
				nextState = 1;
			end
			
			1: begin
				resetTemp = 1;
				ready = 1;
				if (IN_SERIAL_RX)
					nextState = 1;
				else
					nextState = 2;
			end
			
			2: begin
				sampleTemp = 1;
				nextState = 3;
			end
			
			3: begin
				sampleTemp = 1;
				nextState = 4;
			end
			
			4: begin
				sampleTemp = 1;
				nextState = 5;
			end
			
			5: begin
				sampleTemp = 1;
				nextState = 6;
			end
			
			6: begin
				sampleTemp = 1;
				nextState = 7;
			end
			
			7: begin
				sampleTemp = 1;
				nextState = 8;
			end
			
			8: begin
				sampleTemp = 1;
				nextState = 9;
			end
			
			9: begin
				sampleTemp = 1;
				nextState = 10;
			end
			
			10: begin
				loadData = 1;
				nextState = 1;
			end
		endcase
	end
	
	assign OUT_DATA = data;
	assign OUT_STATUS_READY = ready;

endmodule
