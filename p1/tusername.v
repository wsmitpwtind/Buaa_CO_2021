`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:13:04 10/27/2021
// Design Name:   username
// Module Name:   C:/Users/zhangke/Desktop/CO/p1/tusername.v
// Project Name:  p1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: username
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tusername;

	// Inputs
	reg [7:0] name;
	reg clk;
	reg reset;

	// Outputs
	wire out;

	// Instantiate the Unit Under Test (UUT)
	username uut (
		.name(name), 
		.clk(clk), 
		.reset(reset), 
		.out(out)
	);

	initial begin
		// Initialize Inputs
		name = 0;
		clk = 0;
		reset = 1;

		// Wait 100 ns for global reset to finish
		#100;
		#2 reset = 0;
		#2 name = "2";
		#2 name = "s";
		#2 name = " ";
		#2 name = ".";
		#2 name = "t";
		#2 name = "r";
		#2 name = "z";
		#2 name = ".";
		#2 name = "s";
		#2 name = "2";
		#2 name = "s";
		#2 name = ".";
		#2 name = "2";
		#2 name = "2";
		#2 name = "w";
        
		// Add stimulus here

	end
	
	always #1 clk = ~clk;
      
endmodule

