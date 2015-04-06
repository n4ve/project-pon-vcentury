`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:14:31 03/30/2015 
// Design Name: 
// Module Name:    GFXController_TestSuite 
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
module GFXController_TestSuite(
    input CLK,
    input IN_PB_RESET,
    output OUT_SERIAL_TX
    );
	
	wire RESET;
	assign RESET = ~IN_PB_RESET;
	
	reg ramEnable;
	reg ramWrite;
	
	parameter RAM_WIDTH = 16;
	parameter RAM_ADDR_BITS = 12;

	(* RAM_STYLE="{AUTO | BLOCK |  BLOCK_POWER1 | BLOCK_POWER2}" *)
	reg [RAM_WIDTH-1:0] ram [(2**RAM_ADDR_BITS)-1:0];
	reg [RAM_WIDTH-1:0] ramDataOut;

	reg [RAM_ADDR_BITS-1:0] ramAddr;
	reg [RAM_WIDTH-1:0] ramDataIn;

	//  The following code is only necessary if you wish to initialize the RAM 
	//  contents via an external file (use $readmemb for binary data)
	initial
		$readmemh("/home/xerodotc/NepgearRam.txt", ram, 12'h000, 12'hFFF);

	always @(posedge CLK)
		if (ramEnable) begin
			if (ramWrite) begin
				ram[ramAddr] <= ramDataIn;
				ramDataOut <= ramDataIn;
			end
			else
				ramDataOut <= ram[ramAddr];
		end
	
	reg vramEnable;
	reg vramWrite;
	wire [15:0] vramAddr;
	wire [15:0] vramDataR;
	wire [15:0] vramDataW;
	
	wire irq;
	reg iack;
	reg iend;
	
	GFXController gfxc(CLK, RESET, vramEnable, vramWrite, vramAddr, vramDataR, vramDataW,
		irq, iack, iend, OUT_SERIAL_TX);
		
	assign vramAddr[15:10] = 0;
	assign vramAddr[9:0] = ramAddr[9:0];
		
	reg [15:0] buffer;
	reg resetBuffer;
	reg loadBuffer;
	
	always @(posedge CLK) begin
		if (resetBuffer)
			buffer <= 0;
		else if (loadBuffer)
			buffer <= ramDataOut;
	end
	
	assign vramDataW = buffer;
	
	reg [31:0] counter;
	reg resetCounter;
	reg forceCounter;
	
	always @(posedge CLK) begin
		if (resetCounter)
			counter <= 0;
		else if (forceCounter)
			counter <= 25000000;
		else
			counter <= counter + 1;
	end
	
	reg reverse;
	reg resetReverse;
	reg setReverse;
	reg toggleReverse;
	
	always @(posedge CLK) begin
		if (resetReverse)
			reverse <= 0;
		else if (setReverse)
			reverse <= 1;
		else if (toggleReverse)
			reverse <= ~reverse;
	end
	
	reg resetRamAddr;
	reg incRamAddr;
	reg setRamAddrFrame1;
	reg setRamAddrFrame2;
	reg setRamAddrFrame3;
	reg setRamAddrFrame4;
	
	always @(posedge CLK) begin
		if (resetRamAddr)
			ramAddr <= 0;
		else if (incRamAddr)
			ramAddr <= ramAddr + 1;
		else if (setRamAddrFrame1)
			ramAddr <= 12'b00_00000_00000;
		else if (setRamAddrFrame2)
			ramAddr <= 12'b01_00000_00000;
		else if (setRamAddrFrame3)
			ramAddr <= 12'b10_00000_00000;
		else if (setRamAddrFrame4)
			ramAddr <= 12'b11_00000_00000;
	end
	
	reg [7:0] state;
	reg [7:0] nextState;
	
	always @(posedge CLK) begin
		if (RESET)
			state <= 0;
		else 
			state <= nextState;
	end
	
	wire [1:0] recentFrame;
	assign recentFrame = (ramAddr[11:10] - 1);
	
	always @(*) begin
		ramEnable = 0;
		ramWrite = 0;
		ramDataIn = 0;
		vramEnable = 0;
		vramWrite = 0;
		resetBuffer = 0;
		loadBuffer = 0;
		resetCounter = 0;
		forceCounter = 0;
		resetReverse = 0;
		setReverse = 0;
		toggleReverse = 0;
		resetRamAddr = 0;
		incRamAddr = 0;
		setRamAddrFrame1 = 0;
		setRamAddrFrame2 = 0;
		setRamAddrFrame3 = 0;
		setRamAddrFrame4 = 0;
		nextState = 0;
		
		iack = 0;
		iend = 0;
		
		case (state)
			0: begin
				resetBuffer = 1;
				forceCounter = 1;
				resetReverse = 1;
				nextState = 1;
			end
			
			1: begin
				resetReverse = 1;
				setRamAddrFrame1 = 1;
				nextState = 100;
			end
			
			2: begin
				setRamAddrFrame2 = 1;
				nextState = 100;
			end
			
			3: begin
				setRamAddrFrame3 = 1;
				nextState = 100;
			end
			
			4: begin
				setReverse = 1;
				setRamAddrFrame4 = 1;
				nextState = 100;
			end
			
			100: begin
				if (counter < 3125000)
					nextState = 100;
				else
					nextState = 101;
			end
			
			101: begin
				resetCounter = 1;
				nextState = 128;
			end
			
			128: begin
				if (irq)
					nextState = 129;
				else
					nextState = 128;
			end
			
			129: begin
				iack = 1;
				nextState = 130;
			end
			
			130: begin
				ramEnable = 1;
				ramWrite = 0;
				nextState = 131;
			end
			
			131: begin
				loadBuffer = 1;
				nextState = 132;
			end
			
			132: begin
				vramEnable = 1;
				vramWrite = 1;
				nextState = 133;
			end
			
			133: begin
				incRamAddr = 1;
				if (ramAddr[9:0] < 10'b11111_11111)
					nextState = 130;
				else
					nextState = 134;
			end
			
			134: begin
				iend = 1;
				if (reverse)
					nextState = 136;
				else
					nextState = 135;
			end
			
			135: begin
				if (recentFrame == 0)
					nextState = 2;
				else if (recentFrame == 1)
					nextState = 3;
				else if (recentFrame == 2)
					nextState = 4;
				else
					nextState = 1;
			end
			
			136: begin
				if (recentFrame == 3)
					nextState = 3;
				else if (recentFrame == 2)
					nextState = 2;
				else if (recentFrame == 1)
					nextState = 1;
				else
					nextState = 4;
			end
		endcase
	end
		
endmodule
