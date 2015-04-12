`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:31:42 03/29/2015 
// Design Name: 
// Module Name:    GFXController 
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
module GFXController(
    input CLK,
    input RESET,
	// Memory controller
	input MEMC_RAM_ENABLE,
	input MEMC_RAM_WRITE,
	input [15:0] MEMC_RAM_ADDR,
	output [15:0] MEMC_RAM_DATA_R,
	input [15:0] MEMC_RAM_DATA_W,
	// GPU Signals
	output SIG_READY,
	input SIG_DRAW,
	input SIG_REQUEST,
	// Frontend
	output OUT_SERIAL_TX
    );
	
	wire gpuVramEnable;
	wire gpuVramWrite;
	wire [10:0] gpuVramAddr;
	wire [15:0] gpuVramDataR;
	wire [15:0] gpuVramDataW;
	wire gpuVramLock;
	
	GPU gpu(CLK, RESET, gpuVramEnable, gpuVramWrite, gpuVramAddr,
		gpuVramDataR, gpuVramDataW, gpuVramLock,
		SIG_READY, SIG_DRAW, SIG_REQUEST, OUT_SERIAL_TX);
	
	wire vramEnable;
	wire vramWrite;
	wire [10:0] vramAddr;
	wire [15:0] vramDataR;
	wire [15:0] vramDataW;
	
	assign vramEnable = (gpuVramLock) ? gpuVramEnable : MEMC_RAM_ENABLE;
	assign vramWrite = (gpuVramLock) ? gpuVramWrite : MEMC_RAM_WRITE;
	assign vramAddr = (gpuVramLock) ? gpuVramAddr : MEMC_RAM_ADDR[10:0];
	assign vramDataW = (gpuVramLock) ? gpuVramDataW : MEMC_RAM_DATA_W;
	
	assign gpuVramDataR = (gpuVramLock) ? vramDataR : 16'bz;
	assign MEMC_RAM_DATA_R = (~gpuVramLock) ? vramDataR : 16'bz;
	
	VRAM vramMaster(CLK, vramEnable, vramWrite, vramAddr, vramDataR, vramDataW);

endmodule
