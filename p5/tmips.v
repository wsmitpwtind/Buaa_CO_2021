`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:58:51 11/12/2021
// Design Name:   mips
// Module Name:   C:/Users/zhangke/Desktop/CO/p4/tmips.v
// Project Name:  p4
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mips
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tmips;
 
	// Inputs
	reg clk; 
	reg reset;

	// Instantiate the Unit Under Test (UUT)
	mips uut (
		.clk(clk), 
		.reset(reset)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;  

		// Wait 100 ns for global reset to finish
		# 100
		reset = 0;
        
		// Add stimulus here
	end
 always #1 clk = ~clk;
endmodule

