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
	input IN_SERIAL_RX,
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
		$readmemh("/home/xerodotc/Documents/NepgearRam.txt", ram, 12'h000, 12'hFFF);

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
	
	wire gpuReady;
	reg gpuDraw;
	
	GFXController gfxc(CLK, RESET, vramEnable, vramWrite, vramAddr, vramDataR, vramDataW,
		gpuReady, gpuDraw, OUT_SERIAL_TX);
		
	assign vramAddr[15:10] = 0;
	assign vramAddr[9:0] = ramAddr[9:0];
	
	wire stIrq;
	reg stIack;
	reg stIend;
	SystemTimer systim(CLK, RESET, stIrq, stIack, stIend);
		
	wire [7:0] kbdBuffer;
	
	wire kIrq;
	reg kIack;
	reg kIend;
	
	KBDController kbdc(CLK, RESET, kbdBuffer, kIrq, kIack, kIend, IN_SERIAL_RX);
		
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
	
	reg [7:0] kBuffer;
	reg resetKBuffer;
	reg loadKBuffer;
	
	always @(posedge CLK) begin
		if (resetKBuffer)
			kBuffer <= 0;
		else if (loadKBuffer)
			kBuffer <= kbdBuffer;
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
		resetKBuffer = 0;
		loadKBuffer = 0;
		resetRamAddr = 0;
		incRamAddr = 0;
		setRamAddrFrame1 = 0;
		setRamAddrFrame2 = 0;
		setRamAddrFrame3 = 0;
		setRamAddrFrame4 = 0;
		nextState = 0;
		
		gpuDraw = 0;
		
		stIack = 0;
		stIend = 0;
		kIack = 0;
		kIend = 0;
		
		case (state)
			0: begin
				resetBuffer = 1;
				resetKBuffer = 1;
				resetRamAddr = 1;
				nextState = 1;
			end
			
			1: begin
				setRamAddrFrame1 = 1;
				nextState = 128;
			end
			
			2: begin
				setRamAddrFrame2 = 1;
				nextState = 128;
			end
			
			3: begin
				setRamAddrFrame3 = 1;
				nextState = 128;
			end
			
			4: begin
				setRamAddrFrame4 = 1;
				nextState = 128;
			end
			
			128: begin
				if (stIrq)
					nextState = 129;
				else if (kIrq)
					nextState = 200;
				else
					nextState = 128;
			end
			
			129: begin
				stIack = 1;
				if (gpuReady)
					nextState = 130;
				else
					nextState = 135;
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
				stIend = 1;
				gpuDraw = 1;
				nextState = recentFrame + 1;
			end
			
			135: begin
				stIend = 1;
				nextState = 128;
			end
			
			200: begin
				kIack = 1;
				nextState = 202;
			end
			
			202: begin
				loadKBuffer = 1;
				nextState = 203;
			end
			
			203: begin
				kIend = 1;
				if (kBuffer == 16'h00_31)
					nextState = 1;
				else if (kBuffer == 16'h00_32)
					nextState = 2;
				else if (kBuffer == 16'h00_33)
					nextState = 3;
				else if (kBuffer == 16'h00_34)
					nextState = 4;
				else
					nextState = 128;
			end
		endcase
	end
		
endmodule
