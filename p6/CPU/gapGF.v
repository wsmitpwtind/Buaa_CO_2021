`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:51:16 11/18/2021 
// Design Name: 
// Module Name:    gapGF 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`define PC_DEFAULT	32'h0000_3000

module gapGF(

   input clk,
   input reset,
	 
//周期 Ⅰ->Ⅱ		IF/ID
	input [31:0] I_Instr_out,
	input [31:0] I_PC_out,
	
	output reg [31:0] D_Instr_in,
	output reg [31:0] D_PC_in,

//周期 Ⅱ->Ⅲ		ID/EX
	input [31:0] D_Instr_out,
	input [31:0] D_PC_out,
	input [31:0] D_Num1_out, //GPR[base],GPR[rs]
	input [31:0] D_Num2_out, //GPR[rt],unsign_ext(imm16)
	input [3:0]  D_ALUopcode_out,
	input D_WEGF_out,
	input [3:0]  D_WEDM_out,
	
	output reg [31:0] E_Instr_in,
	output reg [31:0] E_PC_in,
	output reg [31:0] E_Num1_in, //GPR[base],GPR[rs]
	output reg [31:0] E_Num2_in, //GPR[rt],unsign_ext(imm16)
	output reg [3:0]	E_ALUopcode_in,
	output reg E_WEGF_in,
	output reg [3:0]  E_WEDM_in,
	
//周期 Ⅲ->Ⅳ		EX/MEM
	input [31:0] E_Instr_out,
	input [31:0] E_PC_out,
	input [31:0] E_ALUresult_out,
	input E_WEGF_out,
	input [3:0]  E_WEDM_out,
	
	output reg [31:0] M_Instr_in,
	output reg [31:0] M_PC_in,
	output reg [31:0] M_ALUresult_in,
	output reg M_WEGF_in,
	output reg [3:0]  M_WEDM_in,
	
//周期 Ⅳ->Ⅴ		MEM/WB
	input [31:0] M_Instr_out,
	input [31:0] M_PC_out,
	input [31:0] M_ALUresult_out,
	input [31:0] M_DMdata_out,
	input M_WEGF_out,
	
	input [4:0] M_add_write_out,
	input [4:0] M_add_write_plus_out,
	
	
	output reg [4:0] W_add_write_in,
	output reg [4:0] W_add_write_plus_in,
	
	output reg [31:0] W_Instr_in,
	output reg [31:0] W_PC_in,
	output reg [31:0] W_ALUresult_in,
	output reg [31:0] W_DMdata_in,
	output reg W_WEGF_in
    );

initial begin
			D_Instr_in 		=	32'b0;
			D_PC_in			=	`PC_DEFAULT;
			
			E_Instr_in		=	32'b0;
			E_PC_in			=	`PC_DEFAULT;
			E_Num1_in		=	32'b0;
			E_Num2_in		=	32'b0;
			E_ALUopcode_in	=	4'b0;
			E_WEGF_in		=	1'b0;
			E_WEDM_in		=	4'b0;
			
			M_Instr_in		=	32'b0;
			M_PC_in			=	`PC_DEFAULT;
			M_ALUresult_in	=	32'b0;
			M_WEGF_in		=	1'b0;
			M_WEDM_in		=	4'b0;
			
			W_add_write_in =  5'b0;
			W_add_write_plus_in = 5'b0;
			
			W_Instr_in		=	32'b0;
			W_PC_in			=	`PC_DEFAULT;
			W_ALUresult_in	=	32'b0;
			W_DMdata_in		=	32'b0;
			W_WEGF_in		=	1'b0;
			
	end
	

always@(posedge clk) begin
		if(reset) begin
			D_Instr_in 		=	32'b0;
			D_PC_in			=	`PC_DEFAULT;
			
			E_Instr_in		=	32'b0;
			E_PC_in			=	`PC_DEFAULT;
			E_Num1_in		=	32'b0;
			E_Num2_in		=	32'b0;
			E_ALUopcode_in	=	4'b0;
			E_WEGF_in		=	1'b0;
			E_WEDM_in		=	4'b0;
			
			M_Instr_in		=	32'b0;
			M_PC_in			=	`PC_DEFAULT;
			M_ALUresult_in	=	32'b0;
			M_WEGF_in		=	1'b0;
			M_WEDM_in		=	4'b0;
			
			W_add_write_in =  5'b0;
			W_add_write_plus_in = 5'b0;
			
			W_Instr_in		=	32'b0;
			W_PC_in			=	`PC_DEFAULT;
			W_ALUresult_in	=	32'b0;
			W_DMdata_in		=	32'b0;
			W_WEGF_in		=	1'b0;

			
		end
		else begin
			D_Instr_in 		=	I_Instr_out;
			D_PC_in			=	I_PC_out; 
			
			E_Instr_in		=	D_Instr_out;
			E_PC_in			=	D_PC_out;
			E_Num1_in		=	D_Num1_out;
			E_Num2_in		=	D_Num2_out;
			E_ALUopcode_in	=	D_ALUopcode_out;
			E_WEGF_in		=	D_WEGF_out;
			E_WEDM_in		=	D_WEDM_out;
			
			M_Instr_in		=	E_Instr_out;
			M_PC_in			=	E_PC_out;
			M_ALUresult_in	=	E_ALUresult_out;
			M_WEGF_in		=	E_WEGF_out;
			M_WEDM_in		=	E_WEDM_out;
			
			W_add_write_in =  M_add_write_out;
			W_add_write_plus_in = M_add_write_plus_out;
			
			W_Instr_in		=	M_Instr_out;
			W_PC_in			=	M_PC_out;
			W_ALUresult_in	=	M_ALUresult_out;
			W_DMdata_in		=	M_DMdata_out;
			W_WEGF_in		=	M_WEGF_out;
			
		end
	end

endmodule