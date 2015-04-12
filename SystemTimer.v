`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:08:53 04/10/2015 
// Design Name: 
// Module Name:    SystemTimer 
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
module SystemTimer(
    input CLK,
    input RESET,
    output INTC_IRQ,
    input INTC_IACK,
    input INTC_IEND
    );
	
	parameter [31:0] CLOCKS_TIMER = 500000;
	//parameter [31:0] CLOCKS_TIMER = 50000;
	
	reg irq;
	wire iack, iend;
	
	assign INTC_IRQ = irq;
	assign iack = INTC_IACK;
	assign iend = INTC_IEND;
	
	reg [31:0] counter;
	always @(posedge CLK) begin
		if (RESET) begin
			counter <= 0;
		end
		else if (counter < (CLOCKS_TIMER - 1)) begin
			counter <= counter + 1;
		end
		else begin
			counter <= 0;
		end
	end
	
	reg [1:0] state;
	reg [1:0] nextState;
	
	always @(posedge CLK) begin
		if (RESET)
			state <= 0;
		else
			state <= nextState;
	end
	
	always @(*) begin
		irq = 0;
		nextState = 0;
		
		case (state)
			0:
				nextState = 1;
				
			1: begin
				irq = 1;
				if (iack)
					nextState = 2;
				else
					nextState = 1;
			end
			
			2: begin
				if (iend)
					nextState = 3;
				else
					nextState = 2;
			end
			
			3: begin
				if (counter == 0)
					nextState = 1;
				else
					nextState = 3;
			end
		endcase
	end

endmodule
