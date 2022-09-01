`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:55:46 10/25/2021
// Design Name:   vote
// Module Name:   C:/Users/zhangke/Desktop/CO/p1/tvote.v
// Project Name:  p1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: vote
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tvote;

	// Inputs
	reg [31:0] np;
	reg [7:0] vip;
	reg vvip;

	// Outputs
	wire res;

	// Instantiate the Unit Under Test (UUT)
	vote uut (
		.np(np), 
		.vip(vip), 
		.vvip(vvip), 
		.res(res)
	);

	initial begin
		// Initialize Inputs
		np = 32'hffff_ffff;
		vip = 8'b1010_1001;
		vvip = 1'b1; 

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

