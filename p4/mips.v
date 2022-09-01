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
//输出
	 //指令存储器
    .Instr(Instr),				//读的指令存储器指令
	 .PC(PC),						//当前PC
	 
	 //寄存器堆
	 .ReadGF1(ReadGF1),			//读的寄存器1数据
	 .ReadGF2(ReadGF2),			//读的寄存器2数据
	 
	 //数据存储器
	 .ReadDM(ReadDM),				//读的数据存储器数据
	 
	 //ALU
	 .ALUresult(ALUresult),		//Alu计算结果
	 
//输入
	 //指令存储器
	 .Jumpsign(Jumpsign),		//进行非PC+4跳转
	 .JumpAddr(JumpAddr),		//跳转到的数
	 
	 //寄存器堆
	 .WEgf(WEgf),					//寄存器堆写使能
	 .WriteGFadd(WriteGFadd),	//写的寄存器地址
	 .WriteGFdata(WriteGFdata),//写的寄存器数据
	 .readGFadd1(readGFadd1),	//读的寄存器1地址
	 .readGFadd2(readGFadd2),	//读的寄存器2地址
	 
	 //数据存储器
	 .WEdm(WEdm),					//数据存储器写使能
	 .WriteDMadd(WriteDMadd),	//写的数据存储器地址
	 .WriteDMdata(WriteDMdata),//写的数据存储器数据
	 .readDMadd(readDMadd),		//读的数据存储器地址
	 
	 //ALU
	 .ALUopcode(ALUopcode),		//Alu运算符
	 .ALUinput1(ALUinput1),		//Alu读入数据1
	 .ALUinput2(ALUinput2)		//Alu读入数据2
    );
	
	control ctrl (
//输入
	 //指令存储器
    .Instr(Instr),				//读的指令存储器指令
	 .PC(PC),						//当前PC
	 
	 //寄存器堆
	 .ReadGF1(ReadGF1),			//读的寄存器1数据
	 .ReadGF2(ReadGF2),			//读的寄存器2数据
	 
	 //数据存储器
	 .ReadDM(ReadDM),				//读的数据存储器数据
	 
	 //ALU
	 .ALUresult(ALUresult),		//Alu计算结果
	 
//输出
	 //指令存储器
	 .Jumpsign(Jumpsign),		//进行非PC+4跳转
	 .JumpAddr(JumpAddr),		//跳转到的数
	 
	 //寄存器堆
	 .WEgf(WEgf),					//寄存器堆写使能
	 .WriteGFadd(WriteGFadd),	//写的寄存器地址
	 .WriteGFdata(WriteGFdata),//写的寄存器数据
	 .readGFadd1(readGFadd1),	//读的寄存器1地址
	 .readGFadd2(readGFadd2),	//读的寄存器2地址
	 
	 //数据存储器
	 .WEdm(WEdm),					//数据存储器写使能
	 .WriteDMadd(WriteDMadd),	//写的数据存储器地址
	 .WriteDMdata(WriteDMdata),//写的数据存储器数据
	 .readDMadd(readDMadd),		//读的数据存储器地址
	 
	 //ALU
	 .ALUopcode(ALUopcode),		//Alu运算符
	 .ALUinput1(ALUinput1),		//Alu读入数据1
	 .ALUinput2(ALUinput2)		//Alu读入数据2
    );
	

endmodule
