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
    output OUT_SERIAL_TX,
	output OUT_LED,
	output OUT_BUZZER
    );
	
	wire RESET;
	assign RESET = ~IN_PB_RESET;
	
	/*
	* Memory controller
	*/
	wire memEnable; // Processor's signal
	wire memWrite; // Processor's signal
	wire [15:0] memAddr; // Processor's signal
	wire [15:0] memDataR;
	wire [15:0] memDataW; // Processor's signal

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
	wire gpuDraw; // Processor's signal
	
	GFXController gfxc(CLK, RESET, vramEnable, vramWrite, vramAddr, vramDataR, vramDataW,
		gpuReady, gpuDraw, OUT_SERIAL_TX);
	
	/*
	* Interrupt controller
	*/
	wire [1:0] irq;
	wire iack; // Processor's signal
	wire iend; // Processor's signal
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
	
	/*
	* Processors mechanism
	*/
	reg processorId;
	reg processor0Enable;
	reg processor1Enable;
	
	wire processor0SwitchRequest;
	wire processor1SwitchRequest;
	
	wire processor0FatalError;
	wire processor1FatalError;
	
	/*
	* Processor 0 (title processor)
	*/
	wire p0memEnable;
	wire p0memWrite;
	wire [15:0] p0memAddr;
	wire [15:0] p0memDataW;
	wire p0gpuDraw;
	wire p0iack;
	wire p0iend;
	
	TitleProcessor processor0(CLK, RESET,
		processor0Enable, processor0SwitchRequest, processor0FatalError,
		p0memEnable, p0memWrite, p0memAddr, memDataR, p0memDataW,
		gpuReady, p0gpuDraw, kbd, irq, p0iack, p0iend);
	
	/*
	* Processor 1 (game processor)
	*/
	wire p1memEnable;
	wire p1memWrite;
	wire [15:0] p1memAddr;
	wire [15:0] p1memDataW;
	wire p1gpuDraw;
	wire p1iack;
	wire p1iend;
	
	GameProcessor processor1(CLK, RESET,
		processor1Enable, processor1SwitchRequest, processor1FatalError,
		p1memEnable, p1memWrite, p1memAddr, memDataR, p1memDataW,
		gpuReady, p1gpuDraw, kbd, irq, p1iack, p1iend);
	
	/*
	* Assignment
	*/
	assign memEnable = (processorId == 1) ? p1memEnable : p0memEnable;
	assign memWrite = (processorId == 1) ? p1memWrite : p0memWrite;
	assign memAddr = (processorId == 1) ? p1memAddr : p0memAddr;
	assign memDataW = (processorId == 1) ? p1memDataW : p0memDataW;
	assign gpuDraw = (processorId == 1) ? p1gpuDraw : p0gpuDraw;
	assign iack = (processorId == 1) ? p1iack : p0iack;
	assign iend = (processorId == 1) ? p1iend : p0iend;
	
	/*
	* Error handling
	*/
	reg error;
	
	/*
	* FSM
	*/
	reg [1:0] state;
	reg [1:0] nextState;
	
	always @(posedge CLK) begin
		if (RESET)
			state <= 0;
		else
			state <= nextState;
	end
	
	always @(*) begin
		processorId = 0;
		processor0Enable = 0;
		processor1Enable = 0;
		error = 0;
		
		case (state)
			0:
				nextState = 1;
			
			1: begin
				processorId = 0;
				processor0Enable = 1;
				if (processor0FatalError)
					nextState = 3;
				else if (processor0SwitchRequest)
					nextState = 2;
				else
					nextState = 1;
			end
					
			2: begin
				processorId = 1;
				processor1Enable = 1;
				if (processor1FatalError)
					nextState = 3;
				else if (processor1SwitchRequest)
					nextState = 1;
				else
					nextState = 2;
			end
			
			3: begin
				error = 1;
				nextState = 3;
			end
		endcase
	end
	
	assign OUT_BUZZER = error;
	assign OUT_LED = error;

endmodule
