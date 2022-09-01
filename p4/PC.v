`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:25:33 11/12/2021 
// Design Name: 
// Module Name:    PC 
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
`define PC_DEFAULT	32'h0000_3000

module PC(
    input clk,
    input reset,
    input Jumpsign,
	 input [31:0] JumpAddr,
    output [31:0] PC
    );
	
	assign PC = PCin;
	reg [31:0] PCin;
	
	initial begin
		PCin = `PC_DEFAULT;
	end
	
	always@(posedge clk) begin
		if(reset) begin
			PCin = `PC_DEFAULT;
		end
		else begin
			if(Jumpsign == 1'b1)
				begin
					PCin = JumpAddr;
				end
			else
				begin
					PCin = PCin + 4;
				end
		end
	end


endmodule