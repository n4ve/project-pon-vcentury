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
	input BCLK,
    input RESET,
    input [7:0] IN_DATA,
    input IN_SEND,
    output OUT_SERIAL_TX,
	output OUT_STATUS_READY
    );
	
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
	
	always @(posedge BCLK) begin
		if (RESET)
			state <= 0;
		else
			state <= nextState;
	end
	
	reg serialTx;
	reg ready;
	reg send;
	
	always @(*) begin
		serialTx = 1;
		nextState = 0;
		
		case (state)
			0: begin
				nextState = 1;
			end
			
			1: begin
				if (send)
					nextState = 2;
				else
					nextState = 1;
			end
			
			2: begin
				serialTx = 0;
				nextState = 4;
			end
			
			4: begin
				serialTx = temp[0];
				nextState = 5;
			end
			
			5: begin
				serialTx = temp[1];
				nextState = 6;
			end
			
			6: begin
				serialTx = temp[2];
				nextState = 7;
			end
			
			7: begin
				serialTx = temp[3];
				nextState = 8;
			end
			
			8: begin
				serialTx = temp[4];
				nextState = 9;
			end
			
			9: begin
				serialTx = temp[5];
				nextState = 10;
			end
			
			10: begin
				serialTx = temp[6];
				nextState = 11;
			end
			
			11: begin
				serialTx = temp[7];
				nextState = 12;
			end
			
			12: begin
				serialTx = 1;
				nextState = 1;
			end
		endcase
	end
	
	reg [3:0] state2;
	reg [3:0] nextState2;
	
	always @(posedge CLK) begin
		if (RESET)
			state2 <= 0;
		else
			state2 <= nextState2;
	end
	
	always @(*) begin
		resetTemp = 0;
		loadTemp = 0;
		ready = 0;
		send = 0;
		
		case (state2)
			0: begin
				resetTemp = 1;
				nextState2 = 1;
			end
			
			1: begin
				if (state == 1) begin
					loadTemp = 1;
					ready = 1;
				end
				
				if (state == 1 && IN_SEND)
					nextState2 = 2;
				else
					nextState2 = 1;
			end
			
			2: begin
				send = 1;
				if (state == 1)
					nextState2 = 2;
				else
					nextState2 = 1;
			end
		endcase
	end
	
	assign OUT_SERIAL_TX = serialTx;
	assign OUT_STATUS_READY = ready;

endmodule
