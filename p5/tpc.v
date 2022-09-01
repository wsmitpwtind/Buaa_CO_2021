`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:15:33 11/12/2021
// Design Name:   PC
// Module Name:   C:/Users/zhangke/Desktop/CO/p4/tpc.v
// Project Name:  p4
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: PC
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tpc;

	// Inputs
	reg clk;
	reg reset;
	reg Jumpsign;
	reg [31:0] JumpAddr;

	// Outputs
	wire [31:0] PC;

	// Instantiate the Unit Under Test (UUT)
	PC uut (
		.clk(clk), 
		.reset(reset), 
		.Jumpsign(Jumpsign), 
		.JumpAddr(JumpAddr), 
		.PC(PC)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		Jumpsign = 0;
		JumpAddr = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
 always #1 clk = ~clk;
      
endmodule

