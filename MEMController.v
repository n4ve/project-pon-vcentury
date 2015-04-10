`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:23:44 04/10/2015 
// Design Name: 
// Module Name:    MEMController 
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
module MEMController(
	// Memory controller frontend
    input MEM_ENABLE,
	input MEM_WRITE,
	input [15:0] MEM_ADDR,
	output [15:0] MEM_DATA_R,
	input [15:0] MEM_DATA_W,
	// RAM
	output RAM_MEM_ENABLE,
	output RAM_MEM_WRITE,
	output [15:0] RAM_MEM_ADDR,
	input [15:0] RAM_MEM_DATA_R,
	output [15:0] RAM_MEM_DATA_W,
	// Graphic controller
	output GFXC_MEM_ENABLE,
	output GFXC_MEM_WRITE,
	output [15:0] GFXC_MEM_ADDR,
	input [15:0] GFXC_MEM_DATA_R,
	output [15:0] GFXC_MEM_DATA_W
    );
	
	wire ramEnable;
	wire vramEnable;
	
	assign ramEnable = (MEM_ADDR[15:12] == 4'h0);
	assign vramEnable = (MEM_ADDR[15:12] == 4'hA);
	
	assign RAM_MEM_ENABLE = ramEnable & MEM_ENABLE;
	assign GFXC_MEM_ENABLE = vramEnable & MEM_ENABLE;
	
	assign RAM_MEM_WRITE = ramEnable & MEM_WRITE;
	assign GFXC_MEM_WRITE = vramEnable & MEM_WRITE;
	
	assign RAM_MEM_ADDR = MEM_ADDR;
	assign GFXC_MEM_ADDR = MEM_ADDR;
	
	assign RAM_MEM_DATA_W = (ramEnable) ? MEM_DATA_W : 16'bz;
	assign GFXC_MEM_DATA_W = (vramEnable) ? MEM_DATA_W : 16'bz;
	
	assign MEM_DATA_R = (ramEnable) ? RAM_MEM_DATA_R : (
		(vramEnable) ? GFXC_MEM_DATA_R : 16'bz
		);

endmodule
