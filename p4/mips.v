`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:01:29 11/12/2021 
// Design Name: 
// Module Name:    mips 
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
module mips(
    input clk,
    input reset
    );
	
	
   wire[31:0]	Instr, PC, ReadGF1, ReadGF2, ReadDM, ALUresult, JumpAddr, WriteGFdata, WriteDMadd, WriteDMdata, readDMadd, ALUinput1, ALUinput2;
	wire[4:0]	WriteGFadd, readGFadd1, readGFadd2;
	wire[3:0]	ALUopcode;
	wire			Jumpsign, WEgf, WEdm;



	datapath dp (
	 .clk(clk),
	 .reset(reset),
//���
	 //ָ��洢��
    .Instr(Instr),				//����ָ��洢��ָ��
	 .PC(PC),						//��ǰPC
	 
	 //�Ĵ�����
	 .ReadGF1(ReadGF1),			//���ļĴ���1����
	 .ReadGF2(ReadGF2),			//���ļĴ���2����
	 
	 //���ݴ洢��
	 .ReadDM(ReadDM),				//�������ݴ洢������
	 
	 //ALU
	 .ALUresult(ALUresult),		//Alu������
	 
//����
	 //ָ��洢��
	 .Jumpsign(Jumpsign),		//���з�PC+4��ת
	 .JumpAddr(JumpAddr),		//��ת������
	 
	 //�Ĵ�����
	 .WEgf(WEgf),					//�Ĵ�����дʹ��
	 .WriteGFadd(WriteGFadd),	//д�ļĴ�����ַ
	 .WriteGFdata(WriteGFdata),//д�ļĴ�������
	 .readGFadd1(readGFadd1),	//���ļĴ���1��ַ
	 .readGFadd2(readGFadd2),	//���ļĴ���2��ַ
	 
	 //���ݴ洢��
	 .WEdm(WEdm),					//���ݴ洢��дʹ��
	 .WriteDMadd(WriteDMadd),	//д�����ݴ洢����ַ
	 .WriteDMdata(WriteDMdata),//д�����ݴ洢������
	 .readDMadd(readDMadd),		//�������ݴ洢����ַ
	 
	 //ALU
	 .ALUopcode(ALUopcode),		//Alu�����
	 .ALUinput1(ALUinput1),		//Alu��������1
	 .ALUinput2(ALUinput2)		//Alu��������2
    );
	
	control ctrl (
//����
	 //ָ��洢��
    .Instr(Instr),				//����ָ��洢��ָ��
	 .PC(PC),						//��ǰPC
	 
	 //�Ĵ�����
	 .ReadGF1(ReadGF1),			//���ļĴ���1����
	 .ReadGF2(ReadGF2),			//���ļĴ���2����
	 
	 //���ݴ洢��
	 .ReadDM(ReadDM),				//�������ݴ洢������
	 
	 //ALU
	 .ALUresult(ALUresult),		//Alu������
	 
//���
	 //ָ��洢��
	 .Jumpsign(Jumpsign),		//���з�PC+4��ת
	 .JumpAddr(JumpAddr),		//��ת������
	 
	 //�Ĵ�����
	 .WEgf(WEgf),					//�Ĵ�����дʹ��
	 .WriteGFadd(WriteGFadd),	//д�ļĴ�����ַ
	 .WriteGFdata(WriteGFdata),//д�ļĴ�������
	 .readGFadd1(readGFadd1),	//���ļĴ���1��ַ
	 .readGFadd2(readGFadd2),	//���ļĴ���2��ַ
	 
	 //���ݴ洢��
	 .WEdm(WEdm),					//���ݴ洢��дʹ��
	 .WriteDMadd(WriteDMadd),	//д�����ݴ洢����ַ
	 .WriteDMdata(WriteDMdata),//д�����ݴ洢������
	 .readDMadd(readDMadd),		//�������ݴ洢����ַ
	 
	 //ALU
	 .ALUopcode(ALUopcode),		//Alu�����
	 .ALUinput1(ALUinput1),		//Alu��������1
	 .ALUinput2(ALUinput2)		//Alu��������2
    );
	

endmodule
