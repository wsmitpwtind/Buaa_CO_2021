`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:34:50 10/23/2021
// Design Name:   gray
// Module Name:   C:/Users/zhangke/Desktop/CO/p1/t.v
// Project Name:  p1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: gray
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module t;

	// Inputs
	reg Clk; 
	reg Reset;
	reg En;

	// Outputs
	wire [2:0] Output;
	wire Overflow;

	// Instantiate the Unit Under Test (UUT)
	gray uut (
		.Clk(Clk), 
		.Reset(Reset), 
		.En(En), 
		.Output(Output), 
		.Overflow(Overflow)
	);

	initial begin
		// Initialize Inputs
		Clk = 0;
		Reset = 1;
		En = 0;
 
		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		#2 Reset = 0;
		#2 En = 1;
	end
    always #1 Clk = ~Clk;      
endmodule

