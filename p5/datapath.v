`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:03:50 11/12/2021 
// Design Name: 
// Module Name:    datapath 
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
module datapath(
    input clk,
    input reset,
 
//周期 Ⅰ		 -> 指令

	//左 -> 送出
	input Jumpsign,				//进行非PC+4跳转
	input [31:0] JumpAddr,	//跳转到的数
	input freeze,
	
	//右 -> 接收
	output [31:0] Instr,				//读的指令存储器指令
	output [31:0] PC,					//当前PC
	
//周期 Ⅱ	指令 -> 读寄存器

	//左 -> 送出
	input [4:0] readGFadd1,	//读的寄存器1地址
	input [4:0] readGFadd2,	//读的寄存器2地址
	
	//右 -> 接收
	output [31:0] ReadGF1,			//读的寄存器1数据
	output [31:0] ReadGF2,			//读的寄存器2数据
	 
//周期 Ⅲ	读寄存器 -> ALU

	//左 -> 送出
	input [3:0] ALUopcode,	//Alu运算符
	input [31:0] ALUinput1,	//Alu读入数据1
	input [31:0] ALUinput2,	//Alu读入数据2
	 
	//右 -> 接收
	output [31:0] ALUresult,			//Alu计算结果
	

//周期 Ⅳ	ALU -> 数据存储器

	//左 -> 送出
	input [3:0]  WEdm,					//数据存储器写使能
	input [31:0] WriteDMadd,	//写的数据存储器地址
	input [31:0] WriteDMdata,//写的数据存储器数据
	input [31:0] readDMadd,	//读的数据存储器地址
	
	//右 -> 接收
	output [31:0] ReadDM,				//读的数据存储器数据
	
//周期 Ⅴ 数据存储器 -> 写寄存器

	//左 -> 送出
	input WEgf,					//寄存器堆写使能
	input [4:0] WriteGFadd,	//写的寄存器地址
	input [31:0] WriteGFdata,	//写的寄存器数据
	//右 -> 接收
	 
	input [31:0] DM_PC,
	input [31:0] GF_PC,
	 
	 
	 
	 input [4:0] Careadd1_D,
	 input [4:0] Careadd2_D,
	 
	 output [31:0] askdata1_D,
	 output [31:0] askdata2_D
	 
	 
    );
	
	
	IFU ifu (
    .clk(clk), 
    .reset(reset), 
    .Jumpsign(Jumpsign), 
    .JumpAddr(JumpAddr),
	 .PC(PC),
	 .freeze(freeze)
    );
	
	IM im (
    .PC(PC), 
    .instr(Instr)
    );

	GRF grf (
    .clk(clk), 
    .reset(reset), 
    .WE(WEgf), 
    .A1(Careadd1_D), 
    .A2(Careadd2_D), 
    .A3(WriteGFadd), 
    .WD(WriteGFdata), 
    .RD1(askdata1_D), 
    .RD2(askdata2_D),
	 .PC(GF_PC)
    );
	 
	DM dm (
    .clk(clk), 
    .reset(reset), 
    .WE(WEdm), 
	 .MemAddrWrite(WriteDMadd), 
    .WD(WriteDMdata), 
	 .MemAddrRead(readDMadd), 
    .RD(ReadDM),
	 .PC(DM_PC)
	 
	 
    );
	 
	ALU alu (
    .A(ALUinput1), 
    .B(ALUinput2), 
    .AluOp(ALUopcode), 
    .res(ALUresult)
    );





endmodule

