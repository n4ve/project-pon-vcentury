`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:47:41 04/11/2015 
// Design Name: 
// Module Name:    GameProcessor 
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
module GameProcessor(
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
	// Keyboard controller
	input [7:0] KBD_KEY,
	// Interrupt controller
	input [1:0] INT_IRQ,
	output INT_IACK,
	output INT_IEND
    );
	
	/*
	* Address and data line
	*/
	reg [15:0] addrLine;
	reg [15:0] dataLine;
	
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
	
	/*
	* Memory Address Buffer
	*/
	reg loadAddr;
	
	always @(posedge CLK) begin
		if (loadAddr)
			memAddr <= addrLine;
	end
	
	/*
	* Memory Data Buffer
	*/
	reg [15:0] buffer;
	reg loadBufferMem;
	reg loadBufferLine;
	
	always @(posedge CLK) begin
		if (loadBufferMem)
			buffer <= memDataR;
		else if (loadBufferLine)
			buffer <= dataLine;
	end
	
	assign memDataW = buffer;
	
	/*
	* Graphic mechanism
	*/
	wire gpuReady;
	reg gpuDraw;
	
	assign gpuReady = GPU_READY;
	assign GPU_DRAW = gpuDraw;
	
	/*
	* Keyboard mechanism
	*/
	reg [7:0] keyBuffer;
	reg loadKeyBuffer;
	
	always @(posedge CLK) begin
		if (loadKeyBuffer)
			keyBuffer <= KBD_KEY;
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
	* General purpose counter
	*/
	reg [15:0] counter;
	reg resetCounter;
	reg incCounter;
	reg decCounter;
	
	always @(posedge CLK) begin
		if (resetCounter)
			counter <= 0;
		else if (incCounter)
			counter <= counter + 1;
		else if (decCounter)
			counter <= counter - 1;
	end
	
	/*
	* FSM
	*/
	reg [15:0] state;
	reg [15:0] nextState;
	
	always @(posedge CLK) begin
		if (RESET || !ENABLE)
			state <= 0;
		else
			state <= nextState;
	end
	
	always @(*) begin
		addrLine = 16'h0000;
		dataLine = 16'h0000;
		
		memEnable = 0;
		memWrite = 0;
		
		gpuDraw = 0;
		loadKeyBuffer = 0;
		iack = 0;
		iend = 0;
		pSwitch = 0;
		error = 0;
		
		loadAddr = 0;
		loadBufferMem = 0;
		loadBufferLine = 0;
		
		resetCounter = 0;
		incCounter = 0;
		decCounter = 0;
		
		nextState = 16'h0000;
		
		case (state)
			16'h0000: begin
				resetCounter = 1;
				nextState = 16'h0001;
			end
			
			16'h0001: begin
				error = 1;
				nextState = 16'h0001;
			end
		endcase
	end

endmodule
