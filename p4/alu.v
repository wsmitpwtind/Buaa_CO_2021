`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:26:03 11/12/2021 
// Design Name: 
// Module Name:    alu 
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
`define ADDU	4'b0000
`define SUBU	4'b0001
`define AND		4'b0010
`define	OR		4'b0011
`define XOR		4'b0100

module ALU(
    input [31:0] A,
    input [31:0] B,
    input [3:0] AluOp,
    output reg [31:0] res
    );
	always@(*) begin
		case(AluOp)
			`ADDU :
				res = A + B;
			`SUBU :
				res = A - B;
			`AND 	:
				res = A & B;
			`OR 	:
				res = A | B;
			`XOR	:
				res = A ^ B;
			default:
				res = 0;
		endcase
	end
endmodule
