`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:38:52 11/12/2021 
// Design Name: 
// Module Name:    control 
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


`define	Addu		4'd0
`define	Subu		4'd1
`define	Lui		4'd2
`define	Ori		4'd3
`define	Lw			4'd4
`define	Sw			4'd5
`define	Beq		4'd6
`define	Jal		4'd7
`define	Jr			4'd8
`define	J			4'd9
`define	Nop		4'd15


//`define	Bsoal		4'd10
//`define	Xor		4'd11
//`define	Swrr		4'd12

//`define	Bszeal	4'd13

module control(

//输入
	 //指令存储器
    input [31:0] Instr,				//读的指令存储器指令
	 input [31:0] PC,					//当前PC
	 
	 //寄存器堆
	 input [31:0] ReadGF1,			//读的寄存器1数据
	 input [31:0] ReadGF2,			//读的寄存器2数据
	 
	 //数据存储器
	 input [31:0] ReadDM,			//读的数据存储器数据
	 
	 //ALU
	 input [31:0] ALUresult,		//Alu计算结果
	 
//输出
	 //指令存储器
	 output reg Jumpsign,					//进行非PC+4跳转
	 output reg [31:0] JumpAddr,		//跳转到的数
	 
	 //寄存器堆
	 output reg WEgf,						//寄存器堆写使能
	 output reg [4:0] WriteGFadd,		//写的寄存器地址
	 output reg [31:0] WriteGFdata,	//写的寄存器数据
	 output reg [4:0] readGFadd1,		//读的寄存器1地址
	 output reg [4:0] readGFadd2,		//读的寄存器2地址
	 
	 //数据存储器
	 output reg WEdm,						//数据存储器写使能
	 output reg [31:0] WriteDMadd,		//写的数据存储器地址
	 output reg [31:0] WriteDMdata,	//写的数据存储器数据
	 output reg [31:0] readDMadd,		//读的数据存储器地址
	 
	 //ALU
	 output reg [3:0] ALUopcode,		//Alu运算符
	 output reg [31:0] ALUinput1,		//Alu读入数据1
	 output reg [31:0] ALUinput2		//Alu读入数据2
	 
    );
	 
	//支持指令
	wire addu, subu, lui, ori, lw, sw, beq, jal, jr, nop, j;
	
	//wire bsoal, xoR, swrr;
	//wire bszeal;
	
	//指令拆解
	wire [4:0]rs, rt, rd, base;
	wire [5:0]op, func;
	wire [15:0]imm16;
	wire [25:0]imm26;
	
	assign op 	= Instr[31:26];
	assign func = Instr[5:0];
	
	assign rs 	= Instr[25:21];
	assign rt 	= Instr[20:16];
	assign rd 	= Instr[15:11];
	
	assign base	= Instr[25:21];
	assign imm16= Instr[15:0];
	assign imm26= Instr[25:0];

	//临时变量
//	wire [31:0]temp;
//	assign temp={ReadGF1,{{16{imm16[15]}}, imm16}};
	
//	reg equalzero;//倒数是否相同zero
//	integer i;
//	always@(*) begin
//		equalzero = 1;
//		i = 0;
//		while ((i < 32)) begin
//			if (ReadGF1[i]^ReadGF2[i] == 0)
//				begin
//					if(ReadGF1[i] == 1'b1)
//						begin
//							equalzero = 1;
//							i = 32;
//						end
//					else
//						begin
//							i = i + 1;
//						end
//				end
//			else
//				begin
//					equalzero = 0;
//					i = 32;
//				end
//		end
//	end
	
	
	//指令描述
	assign addu = (op == 6'b000000)&(func == 6'b100001);
	assign subu = (op == 6'b000000)&(func == 6'b100011);
	
	assign lui 	= (op == 6'b001111);
	assign ori 	= (op == 6'b001101);
	
	assign lw 	= (op == 6'b100011);
	
	assign sw 	= (op == 6'b101011);
	
	assign beq 	= (op == 6'b000100);
	
	assign jal 	= (op == 6'b000011);
	assign jr 	= (op == 6'b000000)&(func == 6'b001000);
	assign j 	= (op == 6'b000010);
		
	assign nop	= (op == 6'b000000)&(func == 6'b000000);
	
	
	
	//assign bsoal= (op == 6'b000001);
	//assign xoR	= (op == 6'b000000)&(func == 6'b100110);
	//assign swrr	= (op == 6'b000001);
	
	//assign bszeal= (op == 6'b000111);

	
	//指令列表
	wire [3:0]Instrlist;
	assign Instrlist	=	(addu == 1'b1) ? `Addu:
								(subu == 1'b1) ? `Subu:
								(lui 	== 1'b1) ? `Lui:
								(ori 	== 1'b1) ? `Ori:
								(lw 	== 1'b1) ? `Lw:
								(sw 	== 1'b1) ? `Sw:
								(beq 	== 1'b1) ? `Beq:
								(jal 	== 1'b1) ? `Jal:
								(jr 	== 1'b1) ? `Jr:
								(j 	== 1'b1) ? `J:
								(nop 	== 1'b1) ? `Nop:
								
								
								//(bsoal== 1'b1) ? `Bsoal:
								//(xoR	== 1'b1) ? `Xor:
								//(swrr	== 1'b1) ? `Swrr:
								
								//(bszeal== 1'b1) ? `Bszeal:
								
															 4'd15;
	

always @(*) begin
    case(Instrlist)
			`Addu:
				begin
					//指令
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//寄存器堆
					WEgf 			= 1'b1;
					WriteGFadd 	= rd;
					WriteGFdata	= ALUresult;
					readGFadd1 	= rs;
					readGFadd2 	= rt;
					
					//数据存储器
					WEdm			= 1'b0;
					WriteDMadd	= 32'b0;
					WriteDMdata	= 32'b0;
					readDMadd	= 32'b0;
					
					//ALU
					ALUopcode	= 4'd0;
					ALUinput1	= ReadGF1;
					ALUinput2	= ReadGF2;
				end
			`Subu: 
				begin
					//指令
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//寄存器堆
					WEgf 			= 1'b1;
					WriteGFadd 	= rd;
					WriteGFdata	= ALUresult;
					readGFadd1 	= rs;
					readGFadd2 	= rt;
					
					//数据存储器
					WEdm			= 1'b0;
					WriteDMadd	= 32'b0;
					WriteDMdata	= 32'b0;
					readDMadd	= 32'b0;
					
					//ALU
					ALUopcode	= 4'd1;
					ALUinput1	= ReadGF1;
					ALUinput2	= ReadGF2;
				end
			`Lui: 
				begin
					//指令
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//寄存器堆
					WEgf 			= 1'b1;
					WriteGFadd 	= rt;
					WriteGFdata	= {imm16,16'b0};
					readGFadd1 	= 5'b0;
					readGFadd2 	= 5'b0;
					
					//数据存储器
					WEdm			= 1'b0;
					WriteDMadd	= 32'b0;
					WriteDMdata	= 32'b0;
					readDMadd	= 32'b0;
					
					//ALU
					ALUopcode	= 4'd0;
					ALUinput1	= 32'b0;
					ALUinput2	= 32'b0;
				end
			`Ori: 
				begin
					//指令
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//寄存器堆
					WEgf 			= 1'b1;
					WriteGFadd 	= rt;
					WriteGFdata	= ALUresult;
					readGFadd1 	= rs;
					readGFadd2 	= 5'b0;
					
					//数据存储器
					WEdm			= 1'b0;
					WriteDMadd	= 32'b0;
					WriteDMdata	= 32'b0;
					readDMadd	= 32'b0;
					
					//ALU
					ALUopcode	= 4'd3;
					ALUinput1	= ReadGF1;
					ALUinput2	= {16'b0,imm16};
				end
			`Lw:
				begin
					//指令
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//寄存器堆
					WEgf 			= 1'b1;
					WriteGFadd 	= rt;
					WriteGFdata	= ReadDM;
					readGFadd1 	= base;
					readGFadd2 	= 5'b0;
					
					//数据存储器
					WEdm			= 1'b0;
					WriteDMadd	= 32'b0;
					WriteDMdata	= 32'b0;
					readDMadd	= ReadGF1 + {{16{imm16[15]}}, imm16};
					
					//ALU 
					ALUopcode	= 4'd0;
					ALUinput1	= 32'b0;
					ALUinput2	= 32'b0;
				end
			`Sw: 
				begin
					//指令
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//寄存器堆
					WEgf 			= 1'b0;
					WriteGFadd 	= 5'b0;
					WriteGFdata	= 32'b0;
					readGFadd1 	= base;
					readGFadd2 	= rt;
					
					//数据存储器
					WEdm			= 1'b1;
					WriteDMadd	= ReadGF1 + {{16{imm16[15]}}, imm16};
					WriteDMdata	= ReadGF2;
					readDMadd	= 32'b0;
					
					//ALU 
					ALUopcode	= 4'd0;
					ALUinput1	= 32'b0;
					ALUinput2	= 32'b0;
				end
			`Beq: 
				begin
					//指令
					Jumpsign		= (ReadGF1 == ReadGF2) ? 1'b1 : 1'b0;
					JumpAddr		= PC + 4 + {{14{imm16[15]}}, imm16, 2'b0};
					
					//寄存器堆
					WEgf 			= 1'b0;
					WriteGFadd 	= 5'b0;
					WriteGFdata	= 32'b0;
					readGFadd1 	= rs;
					readGFadd2 	= rt;
					
					//数据存储器
					WEdm			= 1'b0;
					WriteDMadd	= 32'b0;
					WriteDMdata	= 32'b0;
					readDMadd	= 32'b0;
					
					//ALU 
					ALUopcode	= 4'd0;
					ALUinput1	= 32'b0;
					ALUinput2	= 32'b0;
				end
			`Jal: 
				begin
					//指令
					Jumpsign		= 1'b1;
					JumpAddr		= {PC[31:28], imm26, 2'b0};
					
					//寄存器堆
					WEgf 			= 1'b1;
					WriteGFadd 	= 5'd31;
					WriteGFdata	= PC + 4;
					readGFadd1 	= 32'b0;
					readGFadd2 	= 32'b0;
					
					//数据存储器
					WEdm			= 1'b0;
					WriteDMadd	= 32'b0;
					WriteDMdata	= 32'b0;
					readDMadd	= 32'b0;
					
					//ALU 
					ALUopcode	= 4'd0;
					ALUinput1	= 32'b0;
					ALUinput2	= 32'b0;
				end
			`Jr:
				begin
					//指令
					Jumpsign		= 1'b1;
					JumpAddr		= ReadGF1;
					
					//寄存器堆
					WEgf 			= 1'b0;
					WriteGFadd 	= 5'b0;
					WriteGFdata	= 32'b0;
					readGFadd1 	= rs;
					readGFadd2 	= 32'b0;
					
					//数据存储器
					WEdm			= 1'b0;
					WriteDMadd	= 32'b0;
					WriteDMdata	= 32'b0;
					readDMadd	= 32'b0;
					
					//ALU 
					ALUopcode	= 4'd0;
					ALUinput1	= 32'b0;
					ALUinput2	= 32'b0;
				end
			`J: 
				begin
					//指令
					Jumpsign		= 1'b1;
					JumpAddr		= {PC[31:28], imm26, 2'b0};
					
					//寄存器堆
					WEgf 			= 1'b0;
					WriteGFadd 	= 5'b0;
					WriteGFdata	= 32'b0;
					readGFadd1 	= 5'b0;
					readGFadd2 	= 5'b0;
					
					//数据存储器
					WEdm			= 1'b0;
					WriteDMadd	= 32'b0;
					WriteDMdata	= 32'b0;
					readDMadd	= 32'b0;
					
					//ALU 
					ALUopcode	= 4'd0;
					ALUinput1	= 32'b0;
					ALUinput2	= 32'b0;
				end
			`Nop: 
				begin
					//指令
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//寄存器堆
					WEgf 			= 1'b0;
					WriteGFadd 	= 5'b0;
					WriteGFdata	= 32'b0;
					readGFadd1 	= 32'b0;
					readGFadd2 	= 32'b0;
					
					//数据存储器
					WEdm			= 1'b0;
					WriteDMadd	= 32'b0;
					WriteDMdata	= 32'b0;
					readDMadd	= 32'b0;
					
					//ALU 
					ALUopcode	= 4'd0;
					ALUinput1	= 32'b0;
					ALUinput2	= 32'b0;
				end
//			`Bsoal: 
//				begin
//					//指令
//					Jumpsign		= (^ReadGF1 == 1'b1) ? 1'b1 : 1'b0;
//					JumpAddr		= PC + 4 + {{14{imm16[15]}}, imm16, 2'b0};
//					
//					//寄存器堆
//					WEgf 			= 1'b1;
//					WriteGFadd 	= 5'd31;
//					WriteGFdata	= PC + 4;
//					readGFadd1 	= rs;
//					readGFadd2 	= 5'b0;
//					
//					//数据存储器 
//					WEdm			= 1'b0;
//					WriteDMadd	= 5'b0;
//					WriteDMdata	= 32'b0;
//					readDMadd	= 5'b0;
//					
//					//ALU 
//					ALUopcode	= 4'd0;
//					ALUinput1	= 32'b0;
//					ALUinput2	= 32'b0;
//				end
//			`Xor: 
//				begin
//					//指令
//					Jumpsign		= 1'b0;
//					JumpAddr		= 32'b0;
//					
//					//寄存器堆
//					WEgf 			= 1'b1;
//					WriteGFadd 	= rd;
//					WriteGFdata	= ALUresult;
//					readGFadd1 	= rs;
//					readGFadd2 	= rt;
//					
//					//数据存储器
//					WEdm			= 1'b0;
//					WriteDMadd	= 32'b0;
//					WriteDMdata	= 32'b0;
//					readDMadd	= 32'b0;
//					
//					//ALU
//					ALUopcode	= 4'd4;
//					ALUinput1	= ReadGF1;
//					ALUinput2	= ReadGF2;
//				end
//			`Swrr: 
//				begin
//					//指令
//					Jumpsign		= 1'b0;
//					JumpAddr		= 32'b0;
//					
//					//寄存器堆
//					WEgf 			= 1'b0;
//					WriteGFadd 	= 5'b0;
//					WriteGFdata	= 32'b0;
//					readGFadd1 	= base;
//					readGFadd2 	= rt;
//					
//					//数据存储器
//					WEdm			= 1'b1;
//					WriteDMadd	= temp[11:2];
//					WriteDMdata	= 	(temp[1:0] == 2'd0) ? ReadGF2 :
//										(temp[1:0] == 2'd1) ? {ReadGF2[7	:0],ReadGF2[31:8 ]} :
//										(temp[1:0] == 2'd2) ? {ReadGF2[15:0],ReadGF2[31:16]} :
//										(temp[1:0] == 2'd3) ? {ReadGF2[23:0],ReadGF2[31:24]} :32'b0;
//					readDMadd	= 32'b0;
//					
//					//ALU 
//					ALUopcode	= 4'd0;
//					ALUinput1	= 32'b0;
//					ALUinput2	= 32'b0;
//				end
//			`Bszeal: 
//				begin
//					//指令
//					Jumpsign		= (equalzero == 1'b1) ? 1'b1 : 1'b0;
//					JumpAddr		= PC + 4 + {{14{imm16[15]}}, imm16, 2'b0};
//					
//					//寄存器堆
//					WEgf 			= 1'b1;
//					WriteGFadd 	= 5'd31;
//					WriteGFdata	= PC + 4;
//					readGFadd1 	= rs;
//					readGFadd2 	= rt;
//					
//					//数据存储器 
//					WEdm			= 1'b0;
//					WriteDMadd	= 5'b0;
//					WriteDMdata	= 32'b0;
//					readDMadd	= 5'b0;
//					
//					//ALU 
//					ALUopcode	= 4'd0;
//					ALUinput1	= 32'b0;
//					ALUinput2	= 32'b0;
//				end		
		
        default:
				begin
					//donothing
				end
    endcase
end


endmodule