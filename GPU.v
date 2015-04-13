`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:47:30 03/29/2015 
// Design Name: 
// Module Name:    GPU 
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
module GPU(
    input CLK,
    input RESET,
	// VRAM (master)
	output VRAM_ENABLE,
	output VRAM_WRITE,
	output [10:0] VRAM_ADDR,
	input [15:0] VRAM_DATA_R,
	output [15:0] VRAM_DATA_W,
	output VRAM_LOCK,
	// GPU Signals
	output SIG_READY,
	input SIG_DRAW,
	input SIG_REQUEST,
	// Serial frontend
	output [7:0] STX_DATA,
	output STX_SEND,
	input STX_READY
    );
	
	/*
	* VRAM (Master)
	*/
	reg vramMstCs;
	reg vramMstWr;
	wire [10:0] vramMstAddr;
	wire [15:0] vramMstDataR;
	reg [15:0] vramMstDataW;
	wire vramMstLock;
	
	assign VRAM_ENABLE = vramMstCs;
	assign VRAM_WRITE = vramMstWr;
	assign VRAM_ADDR = vramMstAddr;
	assign VRAM_DATA_W = vramMstDataW;
	assign VRAM_LOCK = vramMstLock;
	assign vramMstDataR = VRAM_DATA_R;
	
	/*
	* VRAM (Slave)
	*/
	reg vramSlvCs;
	reg vramSlvWr;
	wire [10:0] vramSlvAddr;
	wire [15:0] vramSlvDataR;
	reg [15:0] vramSlvDataW;
	
	VRAM vramSlave(CLK, vramSlvCs, vramSlvWr, vramSlvAddr, vramSlvDataR, vramSlvDataW);
	
	/*
	* GPU Signals
	*/
	reg gpuReady;
	wire gpuDraw;
	wire gpuRequest;
	
	assign SIG_READY = gpuReady;
	assign gpuDraw = SIG_DRAW;
	assign gpuRequest = SIG_REQUEST;
	
	/*
	* Serial transmitter
	*/
	reg [7:0] txData;
	reg txSend;
	wire txReady;
	
	assign STX_DATA = txData;
	assign STX_SEND = txSend;
	assign txReady = STX_READY;
	
	/*
	* Address
	*/
	reg [10:0] vramAddr;
	reg resetVramAddr;
	reg incVramAddr;
	
	always @(posedge CLK) begin
		if (resetVramAddr)
			vramAddr <= 0;
		else if (incVramAddr)
			vramAddr <= vramAddr + 1;
	end
	
	assign vramMstAddr = vramAddr;
	assign vramSlvAddr = vramAddr;
	
	/*
	* Position cursor
	*/
	reg [3:0] cursorY1;
	reg [3:0] cursorY0;
	reg [3:0] cursorX1;
	reg [3:0] cursorX0;
	reg resetCursorX;
	reg resetCursorY;
	reg incCursorX;
	reg incCursorY;
	
	parameter [3:0] OFFSET_Y = 1;
	parameter [3:0] OFFSET_X = 1;
	
	always @(posedge CLK) begin
		if (resetCursorX) begin
			cursorX1 <= 0;
			cursorX0 <= 0;
		end
		else if (incCursorX) begin
			if (cursorX0 < 9)
				cursorX0 <= cursorX0 + 1;
			else begin
				cursorX0 <= 0;
				cursorX1 <= cursorX1 + 1;
			end
		end
	end
	
	always @(posedge CLK) begin
		if (resetCursorY) begin
			cursorY1 <= 0;
			cursorY0 <= 0;
		end
		else if (incCursorY) begin
			if (cursorY0 < 9)
				cursorY0 <= cursorY0 + 1;
			else begin
				cursorY0 <= 0;
				cursorY1 <= cursorY1 + 1;
			end
		end
	end
	
	/*
	* VRAM data buffer
	*/
	reg [15:0] vramMstBuff;
	reg [15:0] vramSlvBuff;
	reg resetVramMstBuff;
	reg resetVramSlvBuff;
	reg loadVramMstBuff;
	reg loadVramSlvBuff;
	
	always @(posedge CLK) begin
		if (resetVramMstBuff)
			vramMstBuff <= 0;
		else if (loadVramMstBuff)
			vramMstBuff <= vramMstDataR;
	end
	
	always @(posedge CLK) begin
		if (resetVramSlvBuff)
			vramSlvBuff <= 0;
		else if (loadVramSlvBuff)
			vramSlvBuff <= vramSlvDataR;
	end
	
	/*
	* Force redraw flag
	*/
	reg forceRedraw;
	reg resetForceRedraw;
	reg setForceRedraw;
	
	always @(posedge CLK) begin
		if (resetForceRedraw)
			forceRedraw <= 0;
		else if (setForceRedraw)
			forceRedraw <= 1;
	end
	
	/*
	* VRAM lock flag
	*/
	reg vramLock;
	reg resetVramLock;
	reg setVramLock;
	
	always @(posedge CLK) begin
		if (resetVramLock)
			vramLock <= 0;
		else if (setVramLock)
			vramLock <= 1;
	end
	
	assign vramMstLock = vramLock;
	
	/*
	* FSM
	*/
	reg [7:0] state;
	reg [7:0] nextState;
	
	always @(posedge CLK) begin
		if (RESET)
			state <= 0;
		else
			state <= nextState;
	end
	
	always @(*) begin
		vramMstCs = 0;
		vramMstWr = 0;
		vramMstDataW = 0;
		vramSlvCs = 0;
		vramSlvWr = 0;
		vramSlvDataW = 0;
		
		gpuReady = 0;
		
		txData = 0;
		txSend = 0;
		
		resetVramAddr = 0;
		incVramAddr = 0;
		resetCursorX = 0;
		resetCursorY = 0;
		incCursorX = 0;
		incCursorY = 0;
		resetVramMstBuff = 0;
		resetVramSlvBuff = 0;
		loadVramMstBuff = 0;
		loadVramSlvBuff = 0;
		resetForceRedraw = 0;
		setForceRedraw = 0;
		resetVramLock = 0;
		setVramLock = 0;
		
		nextState = 0;
	
		case (state)
			0: begin
				resetVramAddr = 1;
				resetCursorX = 1;
				resetCursorY = 1;
				resetVramMstBuff = 1;
				resetVramSlvBuff = 1;
				setForceRedraw = 1;
				resetVramLock = 1;
				nextState = 1;
			end
				
			1: begin // Wait for draw signal
				gpuReady = 1;
				if (gpuDraw)
					nextState = 5;
				else
					nextState = 1;
			end
			
			5: begin // Acquire VRAM lock
				setVramLock = 1;
				nextState = 128;
			end
			
			/*
			* Hide terminal cursor
			* CSI ?25l
			*/
			
			128: begin // Send ESC
				if (txReady)
					nextState = 129;
				else
					nextState = 128;
			end
			
			129: begin // Send ESC
				txData = 8'h1B;
				txSend = 1;
				nextState = 130;
			end
			
			130: begin // Send [
				if (txReady)
					nextState = 131;
				else
					nextState = 130;
			end
			
			131: begin // Send [
				txData = 8'h5B;
				txSend = 1;
				nextState = 132;
			end
			
			132: begin // Send ?
				if (txReady)
					nextState = 133;
				else
					nextState = 132;
			end
			
			133: begin // Send ?
				txData = 8'h3F;
				txSend = 1;
				nextState = 134;
			end
			
			134: begin // Send 2
				if (txReady)
					nextState = 135;
				else
					nextState = 134;
			end
			
			135: begin // Send 2
				txData = 8'h32;
				txSend = 1;
				nextState = 136;
			end
			
			136: begin // Send 5
				if (txReady)
					nextState = 137;
				else
					nextState = 136;
			end
			
			137: begin // Send 5
				txData = 8'h35;
				txSend = 1;
				nextState = 138;
			end
			
			138: begin // Send l
				if (txReady)
					nextState = 139;
				else
					nextState = 138;
			end
			
			139: begin // Send l
				txData = 8'h6C;
				txSend = 1;
				nextState = 140;
			end
			
			/**
			* Clear entire screen on force redraw
			* CSI 37;40 m CSI 2 J
			*/
			
			140: begin // Send ESC
				if (~forceRedraw)
					nextState = 6;
				else if (txReady)
					nextState = 141;
				else
					nextState = 140;
			end
			
			141: begin // Send ESC
				txData = 8'h1B;
				txSend = 1;
				nextState = 142;
			end
			
			142: begin // Send [
				if (txReady)
					nextState = 143;
				else
					nextState = 142;
			end
			
			143: begin // Send [
				txData = 8'h5B;
				txSend = 1;
				nextState = 192;
			end
			
			192: begin // Send 3
				if (txReady)
					nextState = 193;
				else
					nextState = 192;
			end
			
			193: begin // Send 3
				txData = 8'h33;
				txSend = 1;
				nextState = 194;
			end
			
			194: begin // Send 7
				if (txReady)
					nextState = 195;
				else
					nextState = 194;
			end
			
			195: begin // Send 7
				txData = 8'h37;
				txSend = 1;
				nextState = 196;
			end
			
			196: begin // Send ;
				if (txReady)
					nextState = 197;
				else
					nextState = 196;
			end
			
			197: begin // Send ;
				txData = 8'h3B;
				txSend = 1;
				nextState = 198;
			end
			
			198: begin // Send 4
				if (txReady)
					nextState = 199;
				else
					nextState = 198;
			end
			
			199: begin // Send 4
				txData = 8'h34;
				txSend = 1;
				nextState = 200;
			end
			
			200: begin // Send 0
				if (txReady)
					nextState = 201;
				else
					nextState = 200;
			end
			
			201: begin // Send 0
				txData = 8'h30;
				txSend = 1;
				nextState = 202;
			end
			
			202: begin // Send m
				if (txReady)
					nextState = 203;
				else
					nextState = 202;
			end
			
			203: begin // Send m
				txData = 8'h6D;
				txSend = 1;
				nextState = 204;
			end
			
			204: begin // Send ESC
				if (txReady)
					nextState = 205;
				else
					nextState = 204;
			end
			
			205: begin // Send ESC
				txData = 8'h1B;
				txSend = 1;
				nextState = 206;
			end
			
			206: begin // Send [
				if (txReady)
					nextState = 207;
				else
					nextState = 206;
			end
			
			207: begin // Send [
				txData = 8'h5B;
				txSend = 1;
				nextState = 144;
			end
			
			144: begin // Send 2
				if (txReady)
					nextState = 145;
				else
					nextState = 144;
			end
			
			145: begin // Send 2
				txData = 8'h32;
				txSend = 1;
				nextState = 146;
			end
			
			146: begin // Send J
				if (txReady)
					nextState = 147;
				else
					nextState = 146;
			end
			
			147: begin // Send J
				txData = 8'h4A;
				txSend = 1;
				nextState = 6;
			end
			
			/*
			* Initialize cursor
			*/
			
			6: begin // Start drawing
				resetVramAddr = 1;
				resetCursorY = 1;
				resetCursorX = 1;
				nextState = 7;
			end
			
			7: begin // Position cursor at offset row
				if (cursorY1 == 0 && cursorY0 == (OFFSET_Y - 1))
					nextState = 9;
				else
					nextState = 8;
			end
			
			8: begin // Move cursor
				incCursorY = 1;
				nextState = 7;
			end
			
			9: begin // Move column cursor or reset
				incCursorX = 1;
				if (vramAddr[5:0] == 6'b000000)
					nextState = 10;
				else
					nextState = 13;
			end
			
			10: begin // Reset column cursor and increase row cursor
				incCursorY = 1;
				resetCursorX = 1;
				nextState = 11;
			end
			
			11: begin // Position cursor at offset column
				if (cursorX1 == 0 && cursorX0 == OFFSET_X)
					nextState = 13;
				else
					nextState = 12;
			end
			
			12: begin // Move cursor
				incCursorX = 1;
				nextState = 11;
			end
			
			/*
			* Compare data; cursor should be moved to desired position now
			*/
			
			13: begin // Read data from both VRAM
				vramMstCs = 1;
				vramMstWr = 0;
				vramSlvCs = 1;
				vramSlvWr = 0;
				nextState = 14;
			end
			
			14: begin // Store to buffer
				loadVramMstBuff = 1;
				loadVramSlvBuff = 1;
				nextState = 15;
			end
			
			15: begin // Compare data
				if (forceRedraw)
					nextState = 16;
				else if (vramMstBuff == vramSlvBuff)
					nextState = 63;
				else
					nextState = 16;
			end
			
			/*
			* Save to slave VRAM
			*/
			16: begin
				vramSlvCs = 1;
				vramSlvWr = 1;
				vramSlvDataW = vramMstBuff;
				nextState = 17;
			end
			
			/*
			* Data transmission
			*/
			17: begin // Send ESC
				if (forceRedraw && vramMstBuff == 16'h00)
					nextState = 63;
				else if (txReady)
					nextState = 18;
				else
					nextState = 17;
			end
			
			18: begin // Send ESC
				txData = 8'h1B;
				txSend = 1;
				nextState = 19;
			end
			
			19: begin // Send [
				if (txReady)
					nextState = 20;
				else
					nextState = 19;
			end
			
			20: begin // Send [
				txData = 8'h5B;
				txSend = 1;
				nextState = 21;
			end
			
			21: begin // Send <Y1>
				if (cursorY1 == 0)
					nextState = 23;
				else if (txReady)
					nextState = 22;
				else
					nextState = 21;
			end
			
			22: begin // Send <Y1>
				txData = 8'h30 + cursorY1;
				txSend = 1;
				nextState = 23;
			end
			
			23: begin // Send <Y0>
				if (txReady)
					nextState = 24;
				else
					nextState = 23;
			end
			
			24: begin // Send <Y0>
				txData = 8'h30 + cursorY0;
				txSend = 1;
				nextState = 25;
			end
			
			25: begin // Send ;
				if (txReady)
					nextState = 26;
				else
					nextState = 25;
			end
			
			26: begin // Send ;
				txData = 8'h3B;
				txSend = 1;
				nextState = 27;
			end
			
			27: begin // Send <X1>
				if (cursorX1 == 0)
					nextState = 29;
				else if (txReady)
					nextState = 28;
				else
					nextState = 27;
			end
			
			28: begin // Send <X1>
				txData = 8'h30 + cursorX1;
				txSend = 1;
				nextState = 29;
			end
			
			29: begin // Send <X0>
				if (txReady)
					nextState = 30;
				else
					nextState = 29;
			end
			
			30: begin // Send <X0>
				txData = 8'h30 + cursorX0;
				txSend = 1;
				nextState = 31;
			end
			
			31: begin // Send H
				if (txReady)
					nextState = 32;
				else
					nextState = 31;
			end
			
			32: begin // Send H
				txData = 8'h48;
				txSend = 1;
				nextState = 33;
			end
			
			33: begin // Send ESC
				if (txReady)
					nextState = 34;
				else
					nextState = 33;
			end
			
			34: begin // Send ESC
				txData = 8'h1B;
				txSend = 1;
				nextState = 35;
			end
			
			35: begin // Send [
				if (txReady)
					nextState = 36;
				else
					nextState = 35;
			end
			
			36: begin // Send [
				txData = 8'h5B;
				txSend = 1;
				nextState = 37;
			end
			
			37: begin // Send 0 (reset)
				if (txReady)
					nextState = 38;
				else
					nextState = 37;
			end
			
			38: begin // Send 0 (reset)
				txData = 8'h30;
				txSend = 1;
				nextState = 39;
			end
			
			39: begin // Send ;
				if (txReady)
					nextState = 40;
				else
					nextState = 39;
			end
			
			40: begin // Send ;
				txData = 8'h3B;
				txSend = 1;
				nextState = 41;
			end
			
			41: begin // Send 1 (bold)
				if (~vramMstBuff[15])
					nextState = 45;
				else if (txReady)
					nextState = 42;
				else
					nextState = 41;
			end
			
			42: begin // Send 1 (bold)
				txData = 8'h31;
				txSend = 1;
				nextState = 43;
			end
			
			43: begin // Send ;
				if (txReady)
					nextState = 44;
				else
					nextState = 43;
			end
			
			44: begin // Send ;
				txData = 8'h3B;
				txSend = 1;
				nextState = 45;
			end
			
			45: begin // Send 4 (underline)
				if (~vramMstBuff[14])
					nextState = 49;
				else if (txReady)
					nextState = 46;
				else
					nextState = 45;
			end
			
			46: begin // Send 4 (underline)
				txData = 8'h34;
				txSend = 1;
				nextState = 47;
			end
			
			47: begin // Send ;
				if (txReady)
					nextState = 48;
				else
					nextState = 47;
			end
			
			48: begin // Send ;
				txData = 8'h3B;
				txSend = 1;
				nextState = 49;
			end
			
			49: begin // Send 3x (foreground)
				if (txReady)
					nextState = 50;
				else
					nextState = 49;
			end
			
			50: begin // Send 3x (foreground)
				txData = 8'h33;
				txSend = 1;
				nextState = 51;
			end
			
			51: begin // Send 3x (foreground)
				if (txReady)
					nextState = 52;
				else
					nextState = 51;
			end
			
			52: begin // Send 3x (foreground)
				txData = 8'h30 + vramMstBuff[13:11];
				txSend = 1;
				nextState = 53;
			end
			
			53: begin // Send ;
				if (txReady)
					nextState = 54;
				else
					nextState = 53;
			end
			
			54: begin // Send ;
				txData = 8'h3B;
				txSend = 1;
				nextState = 55;
			end
			
			55: begin // Send 4x (background)
				if (txReady)
					nextState = 56;
				else
					nextState = 55;
			end
			
			56: begin // Send 4x (background)
				txData = 8'h34;
				txSend = 1;
				nextState = 57;
			end
			
			57: begin // Send 4x (background)
				if (txReady)
					nextState = 58;
				else
					nextState = 57;
			end
			
			58: begin // Send 4x (background)
				txData = 8'h30 + vramMstBuff[10:8];
				txSend = 1;
				nextState = 59;
			end
			
			59: begin // Send m
				if (txReady)
					nextState = 60;
				else
					nextState = 59;
			end
			
			60: begin // Send m
				txData = 8'h6D;
				txSend = 1;
				nextState = 61;
			end
			
			61: begin // Send ASCII character
				if (txReady)
					nextState = 62;
				else
					nextState = 61;
			end
			
			62: begin // Send ASCII character
				txData = (vramMstBuff[7:0] == 8'h00) ? 8'h20 : vramMstBuff[7:0];
				txSend = 1;
				nextState = 63;
			end
			
			/*
			* Check finished
			*/
			63: begin
				incVramAddr = 1;
				if (vramAddr < 11'h4FF && !gpuRequest)
					nextState = 9;
				else
					nextState = 64;
			end
			
			64: begin
				resetForceRedraw = 1;
				resetVramLock = 1;
				nextState = 1;
			end
		endcase
	end

endmodule
