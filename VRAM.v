`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:49:56 03/24/2015 
// Design Name: 
// Module Name:    VRAM 
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
module VRAM(
	input CLK,
	input RAM_ENABLE,
	input RAM_WRITE,
	input [9:0] RAM_ADDR,
	output [15:0] RAM_DATA_OUT,
	input [15:0] RAM_DATA_IN
    );

	parameter RAM_WIDTH = 16;
	parameter RAM_ADDR_BITS = 10;
	
	(* RAM_STYLE="{AUTO | BLOCK |  BLOCK_POWER1 | BLOCK_POWER2}" *)
	reg [RAM_WIDTH-1:0] vram [(2**RAM_ADDR_BITS)-1:0];
	reg [RAM_WIDTH-1:0] vramDataOut;

	wire [RAM_ADDR_BITS-1:0] vramAddr;
	wire [RAM_WIDTH-1:0] vramDataIn;

	//  The following code is only necessary if you wish to initialize the RAM 
	//  contents via an external file (use $readmemb for binary data)
	//initial
	//	$readmemh("<data_file_name>", <rom_name>, <begin_address>, <end_address>);

	always @(posedge CLK)
		if (RAM_ENABLE) begin
			if (RAM_WRITE) begin
				vram[vramAddr] <= vramDataIn;
				vramDataOut <= vramDataIn;
			end
			else
				vramDataOut <= vram[vramAddr];
		end

	assign vramAddr = RAM_ADDR;
	assign vramDataIn = RAM_DATA_IN;
	assign RAM_DATA_OUT = vramDataOut;

endmodule
