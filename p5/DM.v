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

`define DMSIZE 4096

module DM(
    input clk,
    input reset,
    input [3:0] WE,
    input [31:0] MemAddrRead,
	 input [31:0] MemAddrWrite,
    input [31:0] WD,
    output [31:0] RD,
	
	 input [31:0] PC		// the pre-test requires
	 
    );
	wire[31:0] MemAddr;
	assign MemAddr = (WE != 4'b0)? MemAddrWrite : MemAddrRead;
	
	reg [31:0] DM[`DMSIZE-1:0];
	integer i;
	
	initial begin
		for (i = 0; i < `DMSIZE; i = i + 1)
			DM[i] = 0;
	end
	
	assign RD = DM[MemAddr[13:2]];
	
	reg [31:0] fixed_addr;
   reg [31:0] fixed_wdata;
	 
	always @(*) begin
        fixed_wdata = DM[MemAddr >> 2];
        fixed_addr = MemAddr & 32'hfffffffc;
        if (WE[3]) fixed_wdata[31:24] = WD[31:24];
        if (WE[2]) fixed_wdata[23:16] = WD[23:16];
        if (WE[1]) fixed_wdata[15: 8] = WD[15: 8];
        if (WE[0]) fixed_wdata[7 : 0] = WD[7 : 0];
    end

    always @(posedge clk) begin
        if (reset) for (i = 0; i < 4096; i = i + 1) DM[i] <= 0;
        else if (|WE) begin
            DM[fixed_addr >> 2] <= fixed_wdata;
				$display("%d@%h: *%h <= %h", $time, PC, fixed_addr, fixed_wdata);
        end
    end


//	always@(posedge clk) begin
//		if(reset == 1) begin
//			for (i = 0; i < `DMSIZE; i = i + 1)
//				DM[i] <= 0;
//		end
//		else begin
//			if(WE == 4'b1111) begin
//				DM[MemAddr[13:2]] <= WD;
//				$display("%d@%h: *%h <= %h", $time, PC, MemAddr, WD);		// the pre-test requires
//				//$display("@%h: *%h <= %h", PC, MemAddr, WD);		// the pre-test requires
//			end
//		end
//	end

endmodule

