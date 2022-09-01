`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:19:40 11/12/2021 
// Design Name: 
// Module Name:    DM 
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
module DM(
    input clk,
    input reset,
    input WE,
    input [31:0] MemAddrRead,
	 input [31:0] MemAddrWrite,
    input [31:0] WD,
    output [31:0] RD,
	
	 input [31:0] PC		// the pre-test requires
	
    );
	wire[31:0] MemAddr;
	assign MemAddr = (WE == 1'b1)? MemAddrWrite : MemAddrRead;
	
	reg [31:0] DM[1023:0];
	integer i;
	
	initial begin
		for (i = 0; i < 1024; i = i + 1)
			DM[i] = 0;
	end
	
	assign RD = DM[MemAddr[11:2]];
	
	always@(posedge clk) begin
		if(reset == 1) begin
			for (i = 0; i < 1024; i = i + 1)
				DM[i] = 0;
		end
		else begin
			if(WE == 1) begin
				DM[MemAddr[11:2]] = WD;
				$display("@%h: *%h <= %h", PC, MemAddr, WD);		// the pre-test requires
			end
		end
	end

endmodule

