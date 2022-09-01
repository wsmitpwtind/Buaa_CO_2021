`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:01:17 11/22/2021 
// Design Name: 
// Module Name:    haltGF 
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
module haltGF(
	input clk,
   input reset,
	input [31:0] GFadd1_D,
	input [31:0] GFadd2_D,
	input [31:0] GFadd1_E,
	input [31:0] GFadd2_E,
	
	output reg [31:0] askdata1_E,
	output reg [31:0] askdata2_E,
	output reg [31:0] askdata1_M,
	output reg [31:0] askdata2_M
    );
	
	initial begin
			askdata1_E <= 32'b0;
					askdata2_E <= 32'b0;
					askdata1_M <= 32'b0;
					askdata2_M <= 32'b0;
			
	end
	 always @(posedge clk)
		begin
			if(reset)
				begin
					askdata1_E <= 32'b0;
					askdata2_E <= 32'b0;
					askdata1_M <= 32'b0;
					askdata2_M <= 32'b0;
				end
			else
				begin
					askdata1_E <= GFadd1_D;
					askdata2_E <= GFadd2_D;
					askdata1_M <= GFadd1_E;
					askdata2_M <= GFadd2_E;
				end
		end


endmodule
