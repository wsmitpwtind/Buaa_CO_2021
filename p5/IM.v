`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:18:44 11/12/2021 
// Design Name: 
// Module Name:    IM 
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
`define IMSIZE 4096

module IM(
    input [31:0] PC,
    output [31:0] instr
    );
	reg[31:0] ImMem[ `IMSIZE -1:0];
	wire [31:0] wordid;
	integer i;
	initial begin
		for (i = 0; i < `IMSIZE; i = i + 1) begin
			ImMem[i] = 32'h0;
		end
		$readmemh("code.txt", ImMem);
	end
	assign wordid = (PC - 32'h0000_3000) >> 2;

	assign instr = ImMem[wordid];


endmodule
