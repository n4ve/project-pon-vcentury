`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:30:39 04/10/2015 
// Design Name: 
// Module Name:    INTController 
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
module INTController(
    input CLK,
    input RESET,
	// Processor unit
	output reg [1:0] C_IRQ,
	input C_IACK,
	input C_IEND,
	// Peripheral units
	input [0:1] IRQ,
	output [0:1] IACK,
	output [0:1] IEND
    );
	
	reg [1:0] intId;
	
	reg [3:0] state;
	reg [3:0] nextState;
	
	always @(posedge CLK) begin
		if (RESET)
			state <= 0;
		else
			state <= nextState;
	end
	
	always @(*) begin
		C_IRQ = 2'b11;
		intId = 2'b11;
		nextState = 0;
		
		case (state)
			0: begin
				nextState = 1;
			end
			
			1: begin
				if (IRQ[0])
					nextState = 2;
				else if (IRQ[1])
					nextState = 4;
				else
					nextState = 1;
			end
			
			2: begin
				C_IRQ = (IRQ[0]) ? 2'b00 : 2'b11;
				intId = 2'b00;
				if (~IRQ[0])
					nextState = 1;
				else if (C_IACK)
					nextState = 3;
				else
					nextState = 2;
			end
			
			3: begin
				intId = 2'b00;
				if (C_IEND)
					nextState = 6;
				else
					nextState = 3;
			end
			
			6: begin // persist IEND signal
				intId = 2'b00;
				if (~C_IEND)
					nextState = 1;
				else
					nextState = 6;
			end
			
			4: begin
				C_IRQ = (IRQ[1]) ? 2'b01 : 2'b11;
				intId = 2'b01;
				if (~IRQ[1])
					nextState = 1;
				else if (C_IACK)
					nextState = 5;
				else
					nextState = 4;
			end
			
			5: begin
				intId = 2'b01;
				if (C_IEND)
					nextState = 7;
				else
					nextState = 5;
			end
			
			7: begin // persist IEND signal
				intId = 2'b01;
				if (~C_IEND)
					nextState = 1;
				else
					nextState = 7;
			end
		endcase
	end
	
	assign IACK[0] = (intId == 2'b00) ? C_IACK : 0;
	assign IACK[1] = (intId == 2'b01) ? C_IACK : 0;
	assign IEND[0] = (intId == 2'b00) ? C_IEND : 0;
	assign IEND[1] = (intId == 2'b01) ? C_IEND : 0;

endmodule
