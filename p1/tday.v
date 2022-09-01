`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:53:19 10/26/2021
// Design Name:   day
// Module Name:   C:/Users/zhangke/Desktop/CO/p1/tday.v
// Project Name:  p1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: day
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tday;

	// Inputs
	reg [7:0] Input;
	reg clk;
	reg reset;

	// Outputs
	wire Output;

	// Instantiate the Unit Under Test (UUT)
	day uut (
		.Input(Input), 
		.clk(clk), 
		.reset(reset), 
		.Output(Output)
	);

	initial begin
		// Initialize Inputs
		Input = 0;
		clk = 0;
		reset = 1;

		// Wait 100 ns for global reset to finish
		#100;
      #2 reset = 0;
		#2 Input = "0";
		#2 Input = "0";
		#2 Input = "0";
		#2 Input = "0";
		#2 Input = "/";
		#2 Input = "1";
		#2 Input = "0";
		#2 Input = "/";
		#2 Input = "2";
		#2 Input = "3";
		#2 Input = "/";
		#2 Input = "1";
		#2 Input = "2";
		#2 Input = "/";
		#2 Input = "2";
		#2 Input = "3";
		// Add stimulus here

	end

always #1 clk = ~clk;
endmodule

