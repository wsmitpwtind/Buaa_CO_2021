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
//���
	 //ָ��洢��
    output [31:0] Instr,				//����ָ��洢��ָ��
	 output [31:0] PC,					//��ǰPC
	 
	 //�Ĵ�����
	 output [31:0] ReadGF1,				//���ļĴ���1����
	 output [31:0] ReadGF2,				//���ļĴ���2����
	 
	 //���ݴ洢��
	 output [31:0] ReadDM,				//�������ݴ洢������
	 
	 //ALU
	 output [31:0] ALUresult,			//Alu������
	 
//����
	 //ָ��洢�� 
	 input Jumpsign,						//���з�PC+4��ת
	 input [31:0] JumpAddr,				//��ת������
	 
	 //�Ĵ�����
	 input WEgf,							//�Ĵ�����дʹ��
	 input [4:0] WriteGFadd,			//д�ļĴ�����ַ
	 input [31:0] WriteGFdata,			//д�ļĴ�������
	 input [4:0] readGFadd1,			//���ļĴ���1��ַ
	 input [4:0] readGFadd2,			//���ļĴ���2��ַ
	 
	 //���ݴ洢��
	 input WEdm,							//���ݴ洢��дʹ��
	 input [31:0] WriteDMadd,			//д�����ݴ洢����ַ
	 input [31:0] WriteDMdata,			//д�����ݴ洢������
	 input [31:0] readDMadd,			//�������ݴ洢����ַ
	 
	 //ALU
	 input [3:0] ALUopcode,				//Alu�����
	 input [31:0] ALUinput1,			//Alu��������1
	 input [31:0] ALUinput2				//Alu��������2
	
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

