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
	output GPU_REQUEST,
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
	reg gpuRequest;
	
	assign gpuReady = GPU_READY;
	assign GPU_DRAW = gpuDraw;
	assign GPU_REQUEST = gpuRequest;
	
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
	* Object ID counter
	*/
	reg [3:0] objectId;
	reg resetObjectId;
	reg incObjectId;
	reg decObjectId;
	
	always @(posedge CLK) begin
		if (resetObjectId)
			objectId <= 0;
		else if (incObjectId)
			objectId <= objectId + 1;
		else if (decObjectId)
			objectId <= objectId - 1;
	end
	
	/*
	* Keystroke queue
	*/
	reg [3:0] keyQueueFront;
	reg [3:0] keyQueueBack;
	
	reg resetKeyQueue;
	reg pushKeyQueue;
	reg popKeyQueue;
	
	always @(posedge CLK) begin
		if (resetKeyQueue) begin
			keyQueueFront <= 0;
			keyQueueBack <= 0;
		end
		else if (pushKeyQueue) begin
			keyQueueBack <= keyQueueBack + 1;
		end
		else if (popKeyQueue) begin
			keyQueueFront <= keyQueueFront + 1;
		end
	end
	
	parameter KEYQUEUE_ADDR = 16'h0000;
	
	/*
	* Left paddle
	*/
	reg [7:0] leftPaddlePos;
	reg leftPaddleReset;
	reg leftPaddleUp;
	reg leftPaddleDown;
	
	wire [7:0] leftPaddleUpper;
	wire [7:0] leftPaddleLower;
	
	always @(posedge CLK) begin
		if (leftPaddleReset)
			leftPaddlePos <= 9;
		else if (leftPaddleUp) begin
			if (leftPaddlePos > 2)
				leftPaddlePos <= leftPaddlePos - 1;
		end
		else if (leftPaddleDown) begin
			if (leftPaddlePos < 16)
				leftPaddlePos <= leftPaddlePos + 1;
		end
	end
	
	assign leftPaddleUpper = leftPaddlePos - 2;
	assign leftPaddleLower = leftPaddlePos + 2;
	
	/*
	* Right paddle
	*/
	reg [7:0] rightPaddlePos;
	reg rightPaddleReset;
	reg rightPaddleUp;
	reg rightPaddleDown;
	
	wire [7:0] rightPaddleUpper;
	wire [7:0] rightPaddleLower;
	
	always @(posedge CLK) begin
		if (rightPaddleReset)
			rightPaddlePos <= 9;
		else if (rightPaddleUp) begin
			if (rightPaddlePos > 2)
				rightPaddlePos <= rightPaddlePos - 1;
		end
		else if (rightPaddleDown) begin
			if (rightPaddlePos < 16)
				rightPaddlePos <= rightPaddlePos + 1;
		end
	end
	
	assign rightPaddleUpper = rightPaddlePos - 2;
	assign rightPaddleLower = rightPaddlePos + 2;
	
	/*
	* Score counter
	*/
	reg [3:0] scoreLeft;
	reg [3:0] scoreRight;
	
	reg resetScore;
	reg addScoreLeft;
	reg addScoreRight;
	
	always @(posedge CLK) begin
		if (resetScore) begin
			scoreLeft <= 0;
			scoreRight <= 0;
		end
		else if (addScoreLeft)
			scoreLeft <= scoreLeft + 1;
		else if (addScoreRight)
			scoreRight <= scoreRight + 1;
	end
	
	/*
	* Flags
	*/
	reg [1:0] winnerFlag;
	reg pauseFlag;
	
	reg resetWinner;
	reg setLeftWin;
	reg setRightWin;
	
	always @(posedge CLK) begin
		if (resetWinner)
			winnerFlag <= 2'b00;
		else if (setLeftWin)
			winnerFlag <= 2'b01;
		else if (setRightWin)
			winnerFlag <= 2'b10;
	end
	
	reg resetPause;
	reg setPause;
	
	always @(posedge CLK) begin
		if (resetPause)
			pauseFlag <= 0;
		else if (setPause)
			pauseFlag <= 1;
	end
	
	wire gameFreeze;
	assign gameFreeze = (winnerFlag[0] | winnerFlag[1] | pauseFlag);
	
	/*
	* FSM
	*/
	reg [15:0] state;
	reg [15:0] nextState;
	
	always @(posedge CLK) begin
		if (RESET || !ENABLE)
			state <= 16'h0000;
		else
			state <= nextState;
	end
	
	/*
	* State ID
	*
	* 0000: Reset
	* 0001: Wait for interrupt
	* 0010: Keyboard interrupt handler
	* 0020: System timer interrupt handler
	* 00FF: EOI
	*
	* 0xxx: Event loop
	* 1xxx: Left paddle event handler
	* 2xxx: Right paddle event handler
	* 3xxx: Ball event handler
	* 4xxx: Scorebar event handler
	* 5xxx: Helpbar event handler
	* Fxxx: System event handler
	*
	* x1xx: Pre-update-event handler
	* x2xx: Update-event handler
	* x3xx: Post-update-event handler
	* x4xx: Draw-event handler
	*
	* xxFF: End of event group
	* 0xEF: Event return pointer
	*/
	
	always @(*) begin
		addrLine = 16'h0000;
		dataLine = 16'h0000;
		
		memEnable = 0;
		memWrite = 0;
		
		gpuDraw = 0;
		gpuRequest = 0;
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
		
		resetObjectId = 0;
		incObjectId = 0;
		decObjectId = 0;
		
		resetKeyQueue = 0;
		pushKeyQueue = 0;
		popKeyQueue = 0;
		
		leftPaddleReset = 0;
		leftPaddleUp = 0;
		leftPaddleDown = 0;
		
		rightPaddleReset = 0;
		rightPaddleUp = 0;
		rightPaddleDown = 0;
		
		resetScore = 0;
		addScoreLeft = 0;
		addScoreRight = 0;
		
		resetWinner = 0;
		setLeftWin = 0;
		setRightWin = 0;
		
		resetPause = 0;
		setPause = 0;
		
		nextState = 16'hFFFF;
		
		case (state)
			/*
			* Reset state
			*/
			16'h0000: begin
				resetCounter = 1;
				resetObjectId = 1;
				resetKeyQueue = 1;
				leftPaddleReset = 1;
				rightPaddleReset = 1;
				resetScore = 1;
				resetWinner = 1;
				resetPause = 1;
				nextState = 16'h0001;
			end
			
			/*
			* Wait for interrupt state
			*/
			16'h0001: begin
				if (irq == 0)
					nextState = 16'h0020;
				else if (irq == 1)
					nextState = 16'h0010;
				else
					nextState = 16'h0001;
			end
			
			/**
			* System timer interrupt handler
			*/
			16'h0020: begin
				iack = 1;
				nextState = 16'h0100;
			end
			
			/*
			* Keyboard event handler (pre-object-update)
			*/
			16'h0100: begin
				if (keyQueueFront == keyQueueBack)
					nextState = 16'h01FF;
				else
					nextState = 16'h0101;
			end
			
			16'h0101: begin
				addrLine = KEYQUEUE_ADDR + keyQueueFront;
				loadAddr = 1;
				nextState = 16'h0102;
			end
			
			16'h0102: begin
				memEnable = 1;
				memWrite = 0;
				popKeyQueue = 1;
				nextState = 16'h0103;
			end
			
			16'h0103: begin
				loadBufferMem = 1;
				nextState = 16'h0104;
			end
			
			16'h0104: begin
				if ((buffer[7:0] == 8'h77 || buffer[7:0] == 8'h73) && !gameFreeze)
					nextState = 16'h1100; // GOTO: left paddle pre-update-event handler
				else if ((buffer[7:0] == 8'h69 || buffer[7:0] == 8'h6B) && !gameFreeze)
					nextState = 16'h2100; // GOTO: right paddle pre-update-event handler
				else if ((buffer[7:0] == 8'h20) && !gameFreeze)
					nextState = 16'h3100; // GOTO: ball pre-update-event handler (launch)
				else
					nextState = 16'h01EF;
			end
			
			16'h01EF: begin
				nextState = 16'h0100;
			end
			
			16'h01FF: begin
				nextState = 16'h0200;
			end
			
			/*
			* Update-event
			*/
			16'h0200: begin
				nextState = 16'h02FF;
			end
			
			16'h02EF: begin
				nextState = 16'h0200;
			end
			
			16'h02FF: begin
				nextState = 16'h0300;
			end
			
			/*
			* Post-update-event
			*/
			16'h0300: begin
				nextState = 16'h03FF;
			end
			
			16'h03EF: begin
				nextState = 16'h0300;
			end
			
			16'h03FF: begin
				nextState = 16'h0400;
			end
			
			/*
			* Draw-event
			*/
			16'h0400: begin
				gpuRequest = 1;
				if (gpuReady)
					nextState = 16'h0401;
				else
					nextState = 16'h0400;
			end
			
			16'h0401: begin
				addrLine = 16'hA000;
				dataLine = 0;
				resetCounter = 1;
				loadAddr = 1;
				loadBufferLine = 1;
				nextState = 16'h0402;
			end
			
			16'h0402: begin
				addrLine = 16'hA000 + counter;
				loadAddr = 1;
				if (counter < 16'h0500)
					nextState = 16'h0403;
				else
					nextState = 16'h0410;
			end
			
			16'h0403: begin
				memEnable = 1;
				memWrite = 1;
				incCounter = 1;
				nextState = 16'h0402;
			end
			
			16'h0410: begin
				resetObjectId = 1;
				nextState = 16'h0411;
			end
			
			16'h0411: begin
				if (objectId == 0)
					nextState = 16'h1400; // GOTO: left paddle draw-event handler
				else if (objectId == 1)
					nextState = 16'h2400; // GOTO: right paddle draw-event handler
				else
					nextState = 16'h04DF;
			end
			
			16'h04EF: begin
				incObjectId = 1;
				nextState = 16'h0411;
			end
			
			16'h04DF: begin
				gpuDraw = 1;
				nextState = 16'h04FF;
			end
			
			16'h04FF: begin
				nextState = 16'h00FF;
			end
			
			/*
			* Left paddle event handler
			*/
			
			// Pre-update-event
			16'h1100: begin
				if (buffer[7:0] == 8'h77)
					nextState = 16'h1101;
				else if (buffer[7:0] == 8'h73)
					nextState = 16'h1102;
				else
					nextState = 16'h01EF;
			end
			
			16'h1101: begin
				leftPaddleUp = 1;
				nextState = 16'h01EF;
			end
			
			16'h1102: begin
				leftPaddleDown = 1;
				nextState = 16'h01EF;
			end
			
			// Draw-event
			16'h1400: begin
				resetCounter = 1;
				dataLine = 16'h3F00;
				loadBufferLine = 1;
				nextState = 16'h1401;
			end
			
			16'h1401: begin
				addrLine = 16'hA000 + (counter << 6) + 16'h0002;
				loadAddr = 1;
				if (counter < 18)
					nextState = 16'h1402;
				else
					nextState = 16'h04EF;
			end
			
			16'h1402: begin
				if (counter >= leftPaddleUpper && counter < leftPaddleLower)
					nextState = 16'h1403;
				else
					nextState = 16'h1404;
			end
			
			16'h1403: begin
				memEnable = 1;
				memWrite = 1;
				nextState = 16'h1404;
			end
			
			16'h1404: begin
				incCounter = 1;
				nextState = 16'h1401;
			end
			
			/*
			* Right paddle event handler
			*/
			
			// Pre-update-event
			16'h2100: begin
				if (buffer[7:0] == 8'h69)
					nextState = 16'h2101;
				else if (buffer[7:0] == 8'h6B)
					nextState = 16'h2102;
				else
					nextState = 16'h01EF;
			end
			
			16'h2101: begin
				rightPaddleUp = 1;
				nextState = 16'h01EF;
			end
			
			16'h2102: begin
				rightPaddleDown = 1;
				nextState = 16'h01EF;
			end
			
			// Draw-event
			16'h2400: begin
				resetCounter = 1;
				dataLine = 16'h3F00;
				loadBufferLine = 1;
				nextState = 16'h2401;
			end
			
			16'h2401: begin
				addrLine = 16'hA000 + (counter << 6) + 16'h003D;
				loadAddr = 1;
				if (counter < 18)
					nextState = 16'h2402;
				else
					nextState = 16'h04EF;
			end
			
			16'h2402: begin
				if (counter >= rightPaddleUpper && counter < rightPaddleLower)
					nextState = 16'h2403;
				else
					nextState = 16'h2404;
			end
			
			16'h2403: begin
				memEnable = 1;
				memWrite = 1;
				nextState = 16'h2404;
			end
			
			16'h2404: begin
				incCounter = 1;
				nextState = 16'h2401;
			end
			
			/*
			* Keyboard interrupt handler
			*/
			16'h0010: begin
				iack = 1;
				nextState = 16'h0011;
			end
			
			16'h0011: begin
				loadKeyBuffer = 1;
				nextState = 16'h0012;
			end
			
			16'h0012: begin
				dataLine[7:0] = keyBuffer;
				addrLine = KEYQUEUE_ADDR + keyQueueBack;
				loadBufferLine = 1;
				loadAddr = 1;
				nextState = 16'h0013;
			end
			
			16'h0013: begin
				memEnable = 1;
				memWrite = 1;
				pushKeyQueue = 1;
				nextState = 16'h00FF;
			end
			
			/*
			* End of interrupt
			*/
			16'h00FF: begin
				iend = 1;
				nextState = 16'h0001;
			end
			
			/*
			* Error state
			*/
			16'hFFFF: begin
				error = 1;
				nextState = 16'hFFFF;
			end
		endcase
	end

endmodule
