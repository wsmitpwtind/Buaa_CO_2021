`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:04:54 10/24/2021
// Design Name:   top_module
// Module Name:   C:/Users/zhangke/Desktop/CO/p1/tt.v
// Project Name:  p1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top_module
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tt;

	// Inputs
	reg clk;
	reg reset;
	reg data;

	// Outputs
	wire start_shifting;

	// Instantiate the Unit Under Test (UUT)
	top_module uut (
		.clk(clk), 
		.reset(reset), 
		.data(data), 
		.start_shifting(start_shifting)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		data = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		#2 reset = 1;
		#2 reset = 0;
		#2 data = 0;
		#2 data = 1;
		#2 data = 1;
		#2 data = 1;
		#2 data = 0;
		#2 data = 1;
		

	end
     always #1 clk = ~clk;
endmodule

