`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:43:00 04/10/2015 
// Design Name: 
// Module Name:    TitleProcessor 
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
module TitleProcessor(
    input CLK,
    input RESET,
	input ENABLE,
	output SWITCH_REQUEST,
	output FATAL_ERROR,
	// Memory controller
	output MEM_ENABLE,
	output MEM_WRITE,
	output [15:0] MEM_ADDR,
	input [15:0] MEM_DATA_R,
	output [15:0] MEM_DATA_W,
	// Graphic controller
	input GPU_READY,
	output GPU_DRAW,
	output GPU_REQUEST,
	// Keyboard controller
	input [7:0] KBD_KEY,
	// Interrupt controller
	input [1:0] INT_IRQ,
	output INT_IACK,
	output INT_IEND
    );
	
	/*
	* Memory mechanism
	*/
	reg memEnable;
	reg memWrite;
	reg [15:0] memAddr;
	wire [15:0] memDataR;
	wire [15:0] memDataW;
	
	assign MEM_ENABLE = memEnable;
	assign MEM_WRITE = memWrite;
	assign MEM_ADDR = memAddr;
	assign memDataR = MEM_DATA_R;
	assign MEM_DATA_W = memDataW;
	
	reg resetMemAddr;
	reg incMemAddr;
	reg setFrameMemAddr;
	reg toggleMemRegion;
	
	always @(posedge CLK) begin
		if (resetMemAddr)
			memAddr <= 16'h0000;
		else if (incMemAddr)
			memAddr <= memAddr + 1;
		else if (setFrameMemAddr)
			memAddr <= 16'h0800;
		else if (toggleMemRegion)
			memAddr <= memAddr ^ 16'hA800;
	end
	
	/*
	* Graphic mechanism
	*/
	wire gpuReady;
	reg gpuDraw;
	reg gpuRequest;
	
	assign gpuReady = GPU_READY;
	assign GPU_DRAW = gpuDraw;
	assign GPU_REQUEST = gpuRequest;
	
	/*
	* Keyboard mechanism
	*/
	reg [7:0] kBuffer;
	reg loadKBuffer;
	
	always @(posedge CLK) begin
		if (loadKBuffer)
			kBuffer <= KBD_KEY;
	end
	
	/*
	* Interrupt mechanism
	*/
	wire [1:0] irq;
	reg iack;
	reg iend;
	
	assign irq = INT_IRQ;
	assign INT_IACK = iack;
	assign INT_IEND = iend;
	
	/*
	* Processor switch mechanism
	*/
	reg pSwitch;
	
	assign SWITCH_REQUEST = pSwitch;
	
	/*
	* Error handler
	*/
	reg error;
	
	assign FATAL_ERROR = error;
	
	/*
	* Buffer
	*/
	reg [15:0] buffer;
	reg resetBuffer;
	reg loadBuffer;
	
	always @(posedge CLK) begin
		if (resetBuffer)
			buffer <= 0;
		else if (loadBuffer)
			buffer <= memDataR;
	end
	
	assign memDataW = buffer;
	
	/*
	* Blink counter
	*/
	reg [7:0] counter;
	reg resetCounter;
	reg incCounter;
	
	always @(posedge CLK) begin
		if (resetCounter)
			counter <= 0;
		else if (incCounter)
			counter <= counter + 1;
	end
	
	/*
	* Text visible state
	*/
	reg textVisible;
	reg resetTextVisible;
	reg toggleTextVisible;
	
	always @(posedge CLK) begin
		if (resetTextVisible)
			textVisible <= 0;
		else if (toggleTextVisible)
			textVisible <= ~textVisible;
	end
	
	/*
	* FSM
	*/
	reg [4:0] state;
	reg [4:0] nextState;
	
	always @(posedge CLK) begin
		if (RESET || !ENABLE)
			state <= 0;
		else
			state <= nextState;
	end
	
	always @(*) begin
		memEnable = 0;
		memWrite = 0;
		resetMemAddr = 0;
		incMemAddr = 0;
		setFrameMemAddr = 0;
		toggleMemRegion = 0;
		gpuDraw = 0;
		gpuRequest = 0;
		loadKBuffer = 0;
		iack = 0;
		iend = 0;
		pSwitch = 0;
		error = 0;
		resetBuffer = 0;
		loadBuffer = 0;
		resetCounter = 0;
		incCounter = 0;
		resetTextVisible = 0;
		toggleTextVisible = 0;
		
		nextState = 31;
		
		case (state)
			0: begin
				resetBuffer = 1;
				resetCounter = 1;
				resetMemAddr = 1;
				resetTextVisible = 1;
				nextState = 1;
			end
			
			1: begin
				setFrameMemAddr = 1;
				nextState = 2;
			end
			
			2: begin
				if (irq == 0)
					nextState = 3;
				else if (irq == 1)
					nextState = 24;
				else
					nextState = 2;
			end
			
			3: begin
				iack = 1;
				nextState = 16;
			end
			
			16: begin
				incCounter = 1;
				if (counter == 0)
					nextState = 17;
				else if (counter < 24)
					nextState = 4;
				else
					nextState = 18;
			end
			
			17: begin
				toggleTextVisible = 1;
				nextState = 4;
			end
			
			18: begin
				resetCounter = 1;
				nextState = 4;
			end
			
			4: begin
				gpuRequest = 1;
				if (gpuReady)
					nextState = 5;
				else
					nextState = 4;
			end
			
			5: begin
				memEnable = 1;
				memWrite = 0;
				nextState = 6;
			end
			
			6: begin
				loadBuffer = 1;
				nextState = 7;
			end
			
			7: begin
				toggleMemRegion = 1;
				nextState = 13;
			end
			
			13: begin
				if (buffer[10:8] == 3'b001 && !textVisible)
					resetBuffer = 1;
				nextState = 8;
			end
			
			8: begin
				memEnable = 1;
				memWrite = 1;
				nextState = 9;
			end
			
			9: begin
				toggleMemRegion = 1;
				nextState = 10;
			end
			
			10: begin
				incMemAddr = 1;
				if (memAddr < 16'h0CFF)
					nextState = 5;
				else
					nextState = 11;
			end
			
			11: begin
				gpuDraw = 1;
				nextState = 12;
			end
			
			12: begin
				iend = 1;
				nextState = 1;
			end
			
			24: begin
				iack = 1;
				loadKBuffer = 1;
				nextState = 25;
			end
			
			25: begin
				iend = 1;
				if (kBuffer == 8'h20)
					nextState = 26;
				else
					nextState = 1;
			end
			
			26: begin
				pSwitch = 1;
				nextState = 26;
			end
			
			31: begin
				error = 1;
				nextState = 31;
			end
		endcase
	end

endmodule
