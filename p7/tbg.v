`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:47:55 12/25/2021
// Design Name:   Bridge
// Module Name:   C:/Users/zhangke/Desktop/CO/p7/tbg.v
// Project Name:  p7
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Bridge
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tbg;

	// Inputs
	reg [31:0] PrAddr;
	reg [31:0] PrWD;
	reg [3:0] Prbyteen;
	reg [31:0] DM_RD;
	reg [31:0] TM0_RD;
	reg [31:0] TM1_RD;

	// Outputs
	wire [31:0] PrRD;
	wire [31:0] DM_Addr;
	wire [31:0] DM_WD;
	wire [3:0] DM_byteen;
	wire [31:0] TM0_Addr;
	wire [31:0] TM0_WD;
	wire TM0_we;
	wire [31:0] TM1_Addr;
	wire [31:0] TM1_WD;
	wire TM1_we;

	// Instantiate the Unit Under Test (UUT)
	Bridge uut (
		.PrAddr(PrAddr), 
		.PrRD(PrRD), 
		.PrWD(PrWD), 
		.Prbyteen(Prbyteen), 
		.DM_Addr(DM_Addr), 
		.DM_RD(DM_RD), 
		.DM_WD(DM_WD), 
		.DM_byteen(DM_byteen), 
		.TM0_Addr(TM0_Addr), 
		.TM0_RD(TM0_RD), 
		.TM0_WD(TM0_WD), 
		.TM0_we(TM0_we), 
		.TM1_Addr(TM1_Addr), 
		.TM1_RD(TM1_RD), 
		.TM1_WD(TM1_WD), 
		.TM1_we(TM1_we)
	);

	initial begin
		// Initialize Inputs
		PrAddr = 32'h0000_0000;
		PrWD = 32'd7;
		Prbyteen = 4'b1111;
		DM_RD = 32'd6;
		TM0_RD = 0;
		TM1_RD = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

