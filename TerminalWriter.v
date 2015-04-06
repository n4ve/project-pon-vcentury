`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:22:43 03/28/2015 
// Design Name: 
// Module Name:    TerminalWriter 
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
module TerminalWriter(
    input CLK,
    input RESET,
	input IN_SERIAL_RX
    );
	
	parameter filename = "/dev/pts/10";
	
	wire [7:0] data;
	wire ready;
	integer fd;
	SerialReceiver srx(CLK, RESET, IN_SERIAL_RX, data, ready);
	
	reg [3:0] state = 0;
	reg [3:0] nextState = 0;
	
	initial
		fd = $fopen(filename, "wb");
	
	always @(posedge CLK) begin
		if (RESET)
			state <= 0;
		else
			state <= nextState;
	end
	
	reg writeToFile;
	
	always @(posedge CLK) begin
		if (writeToFile) begin
			$fwrite(fd, "%c", data);
			$fflush(fd);
		end
	end
	
	always @(*) begin
		writeToFile = 0;
		nextState = 0;
	
		case (state)
			0: begin
				nextState = 1;
			end
			
			1: begin
				if (ready)
					nextState = 2;
				else
					nextState = 1;
			end
			
			2: begin
				if (~ready)
					nextState = 3;
				else
					nextState = 2;
			end
			
			3: begin
				if (ready)
					nextState = 4;
				else
					nextState = 3;
			end
			
			4: begin
				writeToFile = 1;
				nextState = 1;
			end
		endcase
	end

endmodule
