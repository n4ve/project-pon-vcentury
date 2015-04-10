`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:05:08 04/10/2015 
// Design Name: 
// Module Name:    ProjectPon_VCentury 
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
module ProjectPon_VCentury(
    input CLK,
    input IN_PB_RESET,
    input IN_SERIAL_RX,
    output OUT_SERIAL_TX
    );
	
	wire RESET;
	assign RESET = ~IN_PB_RESET;
	
	/*
	* Memory controller
	*/
	wire memEnable;
	wire memWrite;
	wire [15:0] memAddr;
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

	/*
	* RAM
	*/
	RAM ram(CLK, ramEnable, ramWrite, ramAddr, ramDataR, ramDataW);
	
	/*
	* Graphic controller and GPU
	*/
	wire gpuReady;
	wire gpuDraw;
	
	GFXController gfxc(CLK, RESET, vramEnable, vramWrite, vramAddr, vramDataR, vramDataW,
		gpuReady, gpuDraw, OUT_SERIAL_TX);
	
	/*
	* Interrupt controller
	*/
	wire [1:0] irq;
	wire iack;
	wire iend;
	wire [0:1] pIrq;
	wire [0:1] pIack;
	wire [0:1] pIend;
	
	INTController intc(CLK, RESET, irq, iack, iend, pIrq, pIack, pIend);
	
	/*
	* System timer
	*/
	SystemTimer systim(CLK, RESET, pIrq[0], pIack[0], pIend[0]);
	
	/*
	* Keyboard controller
	*/
	wire [7:0] kbd;
	KBDController kbdc(CLK, RESET, kbd, pIrq[1], pIack[1], pIend[1], IN_SERIAL_RX);

endmodule
