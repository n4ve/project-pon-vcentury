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
	
	reg memEnable;
	reg memWrite;
	reg [15:0] memAddr;
	wire [15:0] memDataR;
	wire [15:0] memDataW;

	wire ramEnable;
	wire ramWrite;
	wire [15:0] ramAddr;
	wire [15:0] ramDataR;
	wire [15:0] ramDataW;
	
	wire vramEnable;
	wire vramWrite;
	wire [15:0] vramAddr;
	wire [15:0] vramDataR;
	wire [15:0] vramDataW;

	MEMController memc(memEnable, memWrite, memAddr, memDataR, memDataW,
		ramEnable, ramWrite, ramAddr, ramDataR, ramDataW,
		vramEnable, vramWrite, vramAddr, vramDataR, vramDataW);

	RAM ram(CLK, ramEnable, ramWrite, ramAddr, ramDataR, ramDataW);
	
	wire gpuReady;
	reg gpuDraw;
	
	GFXController gfxc(CLK, RESET, vramEnable, vramWrite, vramAddr, vramDataR, vramDataW,
		gpuReady, gpuDraw, OUT_SERIAL_TX);
	
	wire [1:0] irq;
	reg iack;
	reg iend;
	wire [0:1] pIrq;
	wire [0:1] pIack;
	wire [0:1] pIend;
	
	INTController intc(CLK, RESET, irq, iack, iend, pIrq, pIack, pIend);
	SystemTimer systim(CLK, RESET, pIrq[0], pIack[0], pIend[0]);
		
	wire [7:0] kbd;
	KBDController kbdc(CLK, RESET, kbd, pIrq[1], pIack[1], pIend[1], IN_SERIAL_RX);
		
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
	
	reg [7:0] kBuffer;
	reg resetKBuffer;
	reg loadKBuffer;
	
	always @(posedge CLK) begin
		if (resetKBuffer)
			kBuffer <= 0;
		else if (loadKBuffer)
			kBuffer <= kbd;
	end
	
	reg resetMemAddr;
	reg incMemAddr;
	reg setMemAddrFrame1;
	reg setMemAddrFrame2;
	reg toggleMemRegion;
	
	always @(posedge CLK) begin
		if (resetMemAddr)
			memAddr <= 0;
		else if (incMemAddr)
			memAddr <= memAddr + 1;
		else if (setMemAddrFrame1)
			memAddr <= 16'h0000;
		else if (setMemAddrFrame2)
			memAddr <= 16'h0800;
		else if (toggleMemRegion)
			memAddr <= memAddr ^ 16'hA000;
	end
	
	reg [7:0] state;
	reg [7:0] nextState;
	
	always @(posedge CLK) begin
		if (RESET)
			state <= 0;
		else 
			state <= nextState;
	end
	
	wire recentFrame;
	assign recentFrame = memAddr[11] - 1;
	
	always @(*) begin
		memEnable = 0;
		memWrite = 0;
		resetBuffer = 0;
		loadBuffer = 0;
		resetKBuffer = 0;
		loadKBuffer = 0;
		resetMemAddr = 0;
		incMemAddr = 0;
		setMemAddrFrame1 = 0;
		setMemAddrFrame2 = 0;
		toggleMemRegion = 0;
		nextState = 0;
		
		gpuDraw = 0;
		
		iack = 0;
		iend = 0;
		
		case (state)
			0: begin
				resetBuffer = 1;
				resetKBuffer = 1;
				resetMemAddr = 1;
				nextState = 1;
			end
			
			1: begin
				setMemAddrFrame1 = 1;
				nextState = 128;
			end
			
			2: begin
				setMemAddrFrame2 = 1;
				nextState = 128;
			end
			
			128: begin
				if (irq == 0)
					nextState = 129;
				else if (irq == 1)
					nextState = 200;
				else
					nextState = 128;
			end
			
			129: begin
				iack = 1;
				if (gpuReady)
					nextState = 130;
				else
					nextState = 135;
			end
			
			130: begin
				memEnable = 1;
				memWrite = 0;
				nextState = 131;
			end
			
			131: begin
				loadBuffer = 1;
				nextState = 136;
			end
			
			136: begin
				toggleMemRegion = 1;
				nextState = 132;
			end
			
			132: begin
				memEnable = 1;
				memWrite = 1;
				nextState = 137;
			end
			
			137: begin
				toggleMemRegion = 1;
				nextState = 133;
			end
			
			133: begin
				incMemAddr = 1;
				if (memAddr[10:0] < 11'b11111_111111)
					nextState = 130;
				else
					nextState = 134;
			end
			
			134: begin
				iend = 1;
				gpuDraw = 1;
				nextState = recentFrame + 1;
			end
			
			135: begin
				iend = 1;
				nextState = 128;
			end
			
			200: begin
				iack = 1;
				nextState = 202;
			end
			
			202: begin
				loadKBuffer = 1;
				nextState = 203;
			end
			
			203: begin
				iend = 1;
				if (kBuffer == 16'h00_31)
					nextState = 1;
				else if (kBuffer == 16'h00_32)
					nextState = 2;
				else
					nextState = 128;
			end
		endcase
	end
		
endmodule
