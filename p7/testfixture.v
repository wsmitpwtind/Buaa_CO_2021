`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:10:06 12/26/2021
// Design Name:   mips
// Module Name:   C:/Users/zhangke/Desktop/CO/p7/testfixture.v
// Project Name:  p7
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

module testfixture;

	// Inputs
	reg clk;
	reg reset;
	reg interrupt;
	reg [31:0] i_inst_rdata;
	reg [31:0] m_data_rdata;

	// Outputs
	wire [31:0] macroscopic_pc;
	wire [31:0] i_inst_addr;
	wire [31:0] m_data_addr;
	wire [31:0] m_data_wdata;
	wire [3:0] m_data_byteen;
	wire [31:0] m_inst_addr;
	wire w_grf_we;
	wire [4:0] w_grf_addr;
	wire [31:0] w_grf_wdata;
	wire [31:0] w_inst_addr;

	// Instantiate the Unit Under Test (UUT)
	mips uut (
		.clk(clk), 
		.reset(reset), 
		.interrupt(interrupt), 
		.macroscopic_pc(macroscopic_pc), 
		.i_inst_rdata(i_inst_rdata), 
		.i_inst_addr(i_inst_addr), 
		.m_data_rdata(m_data_rdata), 
		.m_data_addr(m_data_addr), 
		.m_data_wdata(m_data_wdata), 
		.m_data_byteen(m_data_byteen), 
		.m_inst_addr(m_inst_addr), 
		.w_grf_we(w_grf_we), 
		.w_grf_addr(w_grf_addr), 
		.w_grf_wdata(w_grf_wdata), 
		.w_inst_addr(w_inst_addr)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		interrupt = 0;
		i_inst_rdata = 0;
		m_data_rdata = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
 always #2 clk = ~clk;
endmodule

