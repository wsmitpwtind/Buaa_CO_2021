`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:49:53 10/23/2021 
// Design Name: 
// Module Name:    ext 
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
module ext(
    input [15:0] imm,
    input [1:0] EOp,
    output [31:0] ext
    );

assign ext = (EOp == 2'b00 && imm[15] == 1) ? {16'hffff,imm}:
				 (EOp == 2'b00 && imm[15] == 0) ? {16'h0,imm}:
				 (EOp == 2'b01) ? {16'h0,imm}:
				 (EOp == 2'b10) ? {imm,16'h0}:
				 (EOp == 2'b11 && imm[15] == 1) ? {14'b11111111111111,imm,2'b11}:
				 (EOp == 2'b11 && imm[15] == 0) ? {14'b0,imm,2'b0}: 32'b0;
endmodule
