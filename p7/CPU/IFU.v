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

module IFU(
    input clk,
    input reset,
    input Jumpsign,
	 input [31:0] JumpAddr,
	 input freeze,
	 input CP0_IntReq,
    output [31:0] PC,
	 
	 input eret,
	 input [31:0] eretadd
    );

	reg [31:0] PCin;
	
	assign PC = PCin; 
	
	initial begin
		PCin = `PC_DEFAULT;
	end
	
	always@(posedge clk) begin
		if(reset) begin
			PCin = `PC_DEFAULT;
		end
		else begin
			if(CP0_IntReq == 1'b1)
				begin
					PCin = 32'h0000_4180;
				end
			else if(eret == 1'b1)
				begin
					PCin = eretadd;
				end
			else if(Jumpsign == 1'b1)
				begin
					PCin = JumpAddr;
				end
			else
				begin
					if (freeze == 1'b1)
						begin
							PCin = PCin;
						end
					else
						begin
							PCin = PCin + 4;
						end
				end
		end
	end


endmodule