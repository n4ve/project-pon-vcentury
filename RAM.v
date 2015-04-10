`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:59:46 04/10/2015 
// Design Name: 
// Module Name:    RAM 
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
module RAM(
    input CLK,
	input RAM_ENABLE,
	input RAM_WRITE,
	input [11:0] RAM_ADDR,
	output [15:0] RAM_DATA_OUT,
	input [15:0] RAM_DATA_IN
    );

	parameter RAM_WIDTH = 16;
	parameter RAM_ADDR_BITS = 12;
	
	(* RAM_STYLE="{AUTO | BLOCK |  BLOCK_POWER1 | BLOCK_POWER2}" *)
	reg [RAM_WIDTH-1:0] ram [(2**RAM_ADDR_BITS)-1:0];
	reg [RAM_WIDTH-1:0] ramDataOut;

	wire [RAM_ADDR_BITS-1:0] ramAddr;
	wire [RAM_WIDTH-1:0] ramDataIn;

	//  The following code is only necessary if you wish to initialize the RAM 
	//  contents via an external file (use $readmemb for binary data)
	initial
		$readmemh("Data/RAM", ram, 12'h000, 12'hFFF);

	always @(posedge CLK)
		if (RAM_ENABLE) begin
			if (RAM_WRITE) begin
				ram[ramAddr] <= ramDataIn;
				ramDataOut <= ramDataIn;
			end
			else
				ramDataOut <= ram[ramAddr];
		end

	assign ramAddr = RAM_ADDR;
	assign ramDataIn = RAM_DATA_IN;
	assign RAM_DATA_OUT = ramDataOut;

endmodule
