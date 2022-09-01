`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:20:34 11/12/2021
// Design Name:   control
// Module Name:   C:/Users/zhangke/Desktop/CO/p4/tcontrol.v
// Project Name:  p4
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: control
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tcontrol;

	// Inputs
	reg [31:0] Instr;
	reg [31:0] PC;
	reg [31:0] ReadGF1;
	reg [31:0] ReadGF2;
	reg [31:0] ReadDM;
	reg [31:0] ALUresult;

	// Outputs
	wire Jumpsign;
	wire [31:0] JumpAddr;
	wire WEgf;
	wire [4:0] WriteGFadd;
	wire [31:0] WriteGFdata;
	wire [4:0] readGFadd1;
	wire [4:0] readGFadd2;
	wire WEdm;
	wire [31:0] WriteDMadd;
	wire [31:0] WriteDMdata;
	wire [31:0] readDMadd;
	wire [3:0] ALUopcode;
	wire [31:0] ALUinput1;
	wire [31:0] ALUinput2;

	// Instantiate the Unit Under Test (UUT)
	control uut (
		.Instr(Instr), 
		.PC(PC), 
		.ReadGF1(ReadGF1), 
		.ReadGF2(ReadGF2), 
		.ReadDM(ReadDM), 
		.ALUresult(ALUresult), 
		.Jumpsign(Jumpsign), 
		.JumpAddr(JumpAddr), 
		.WEgf(WEgf), 
		.WriteGFadd(WriteGFadd), 
		.WriteGFdata(WriteGFdata), 
		.readGFadd1(readGFadd1), 
		.readGFadd2(readGFadd2), 
		.WEdm(WEdm), 
		.WriteDMadd(WriteDMadd), 
		.WriteDMdata(WriteDMdata), 
		.readDMadd(readDMadd), 
		.ALUopcode(ALUopcode), 
		.ALUinput1(ALUinput1), 
		.ALUinput2(ALUinput2)
	);

	initial begin
		// Initialize Inputs
		Instr = 0;
		PC = 0;
		ReadGF1 = 0;
		ReadGF2 = 0;
		ReadDM = 0;
		ALUresult = 0;

		// Wait 100 ns for global reset to finish
		#100;
		Instr = 32'b100001;
        
		// Add stimulus here

	end
      
endmodule

