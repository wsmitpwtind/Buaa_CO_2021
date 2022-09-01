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
//输出
	 //指令存储器
    output [31:0] Instr,				//读的指令存储器指令
	 output [31:0] PC,					//当前PC
	 
	 //寄存器堆
	 output [31:0] ReadGF1,				//读的寄存器1数据
	 output [31:0] ReadGF2,				//读的寄存器2数据
	 
	 //数据存储器
	 output [31:0] ReadDM,				//读的数据存储器数据
	 
	 //ALU
	 output [31:0] ALUresult,			//Alu计算结果
	 
//输入
	 //指令存储器 
	 input Jumpsign,						//进行非PC+4跳转
	 input [31:0] JumpAddr,				//跳转到的数
	 
	 //寄存器堆
	 input WEgf,							//寄存器堆写使能
	 input [4:0] WriteGFadd,			//写的寄存器地址
	 input [31:0] WriteGFdata,			//写的寄存器数据
	 input [4:0] readGFadd1,			//读的寄存器1地址
	 input [4:0] readGFadd2,			//读的寄存器2地址
	 
	 //数据存储器
	 input WEdm,							//数据存储器写使能
	 input [31:0] WriteDMadd,			//写的数据存储器地址
	 input [31:0] WriteDMdata,			//写的数据存储器数据
	 input [31:0] readDMadd,			//读的数据存储器地址
	 
	 //ALU
	 input [3:0] ALUopcode,				//Alu运算符
	 input [31:0] ALUinput1,			//Alu读入数据1
	 input [31:0] ALUinput2				//Alu读入数据2
	
    );
	
	
	PC pc (
    .clk(clk), 
    .reset(reset), 
    .Jumpsign(Jumpsign), 
    .JumpAddr(JumpAddr),
	 .PC(PC)
    );
	
	IM im (
    .PC(PC), 
    .instr(Instr)
    );

	GRF grf (
    .clk(clk), 
    .reset(reset), 
    .WE(WEgf), 
    .A1(readGFadd1), 
    .A2(readGFadd2), 
    .A3(WriteGFadd), 
    .WD(WriteGFdata), 
    .RD1(ReadGF1), 
    .RD2(ReadGF2),
	 .PC(PC)
    );
	 
	DM dm (
    .clk(clk), 
    .reset(reset), 
    .WE(WEdm), 
	 .MemAddrWrite(WriteDMadd), 
    .WD(WriteDMdata), 
	 .MemAddrRead(readDMadd), 
    .RD(ReadDM),
	 .PC(PC)
    );
	 
	ALU alu (
    .A(ALUinput1), 
    .B(ALUinput2), 
    .AluOp(ALUopcode), 
    .res(ALUresult)
    );





endmodule

