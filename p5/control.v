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


`define	Addu		5'd0
`define	Subu		5'd1
`define	Lui		5'd2
`define	Ori		5'd3
`define	Lw			5'd4
`define	Sw			5'd5
`define	Beq		5'd6
`define	Jal		5'd7
`define	Jr			5'd8
`define	J			5'd9
`define	Nop		5'd31

`define	Bal		5'd10 //bunch and link 判断条件待定，bunch时link
`define	Cal		5'd11 //未定义运算指令
`define	Cai		5'd12 //未定义运算立即数指令
	
`define	Lr			5'd13 //未定义条件存储指令，实现功能如下
//1. 利用GRF[rs]和offset得到MemAddr
//2. Mem[MemAddr]后5位作为GRF的写入地址
//3. 写入数据为GRF[rt]
//在w级判断是否写入地址
`define	Lr1		5'd14
//从内存读出数据，若数据大于0，则将数据写入rt寄存器，否则不写，类似lw
`define	Lr2		5'd15
//从内存读出数据，若数据大于0，则将数据写入rt寄存器，否则写入rs寄存器
`define	Lr3		5'd16
//从内存读出数据，则将数据写入rs+rt寄存器

`define	Addi		5'd17
`define	Jalr		5'd18


module control(

//周期 Ⅰ		 -> 指令
	
	//右 -> datapath送出
	input [31:0] I_Instr_in,				//读的指令存储器指令
	input [31:0] I_PC_in,					//当前PC
	
	//右 -> IF/ID接收
	output reg [31:0] I_Instr_out,
	output reg [31:0] I_PC_out,
	
//周期 Ⅱ	指令 -> 读寄存器

	//左 -> IF/ID送出
	input [31:0] D_Instr_in,
	input [31:0] D_PC_in,
	
	//关心的寄存器的值
	output reg [4:0] CareGFadd1_D,	//关心的寄存器1地址
	output reg [4:0] CareGFadd2_D,	//关心的寄存器2地址

	//关心的寄存器的结果
	input [31:0] CareGF1_D,			//关心的寄存器1数据
	input [31:0] CareGF2_D,			//关心的寄存器2数据
	
	//此时认为关心寄存器的结果
	output reg [31:0] askdata1_E,
	output reg [31:0] askdata2_E,

	//左 -> datapath接收
	output reg Jumpsign,				//进行非PC+4跳转
	output reg [31:0] JumpAddr,	//跳转到的数
	
	
	//右 -> ID/EX接收
	output reg [31:0] D_Instr_out,
	output reg [31:0] D_PC_out,
	output reg [31:0] D_Num1_out, //GPR[base],GPR[rs]
	output reg [31:0] D_Num2_out, //GPR[rt],unsign_ext(imm16)
	output reg [3:0]  D_ALUopcode_out,
	output reg D_WEGF_out,
	output reg [3:0]  D_WEDM_out,
	 
//周期 Ⅲ	读寄存器 -> ALU

	//左 -> ID/EX送出
	input [31:0] E_Instr_in,
	input [31:0] E_PC_in,
	input [31:0] E_Num1_in, 		//GPR[base],GPR[rs]
	input [31:0] E_Num2_in, 		//GPR[rt],unsign_ext(imm16)
	input [3:0]	 E_ALUopcode_in,
	input E_WEGF_in,
	input [3:0]  E_WEDM_in,
	
	//关心的寄存器的值
	output reg [4:0] CareGFadd1_E,	//关心的寄存器1地址
	output reg [4:0] CareGFadd2_E,	//关心的寄存器2地址
	//关心的寄存器的结果
	input [31:0] CareGF1_E,			//关心的寄存器1数据
	input [31:0] CareGF2_E,			//关心的寄存器2数据
	
	output reg [4:0] E_add_write,//试图写入的寄存器地址
	output reg [4:0] E_add_write_plus,//试图写入的寄存器地址2
	output reg E_type_write,	//试图写入的寄存器来源类型 1=dm 0=alu
	//此时认为关心寄存器的结果
	output reg [31:0] askdata1_M,
	output reg [31:0] askdata2_M,
	
	//左 -> datapath接收
	output reg [3:0] ALUopcode,	//Alu运算符
	output reg [31:0] ALUinput1,	//Alu读入数据1
	output reg [31:0] ALUinput2,	//Alu读入数据2
	 
	//右 -> datapath送出
	input [31:0] ALUresult,			//Alu计算结果
	
	//右 -> EX/MEM接收	
	output reg [31:0] E_Instr_out,
	output reg [31:0] E_PC_out,
	output reg [31:0] E_ALUresult_out,
	output reg E_WEGF_out,
	output reg [3:0]  E_WEDM_out,
	
//周期 Ⅳ	ALU -> 数据存储器

	//左 -> EX/MEM送出
	input [31:0] M_Instr_in,
	input [31:0] M_PC_in,
	input [31:0] M_ALUresult_in,
	input M_WEGF_in,
	input [3:0]  M_WEDM_in,
	
	//关心的寄存器的值
	output reg [4:0] CareGFadd1_M,	//关心的寄存器1地址
	output reg [4:0] CareGFadd2_M,	//关心的寄存器2地址
	//关心的寄存器的结果
	input [31:0] CareGF1_M,			//关心的寄存器1数据
	input [31:0] CareGF2_M,			//关心的寄存器2数据
	
	output reg [4:0] M_add_write,//试图写入的寄存器地址
	output reg [4:0] M_add_write_plus,
	output reg M_type_write,	//试图写入的寄存器来源类型 1=dm 0=alu

	
	//左 -> datapath接收
	output reg [3:0]  WEdm,					//数据存储器写使能
	output reg [31:0] WriteDMadd,	//写的数据存储器地址
	output reg [31:0] WriteDMdata,//写的数据存储器数据
	output reg [31:0] readDMadd,	//读的数据存储器地址
	
	//右 -> datapath送出
	input [31:0] ReadDM,				//读的数据存储器数据
	
	//右 -> MEM/WB接收
	output reg [31:0] M_Instr_out,
	output reg [31:0] M_PC_out,
	output reg [31:0] M_ALUresult_out,
	output reg [31:0] M_DMdata_out,
	output reg M_WEGF_out,
	
//周期 Ⅴ 数据存储器 -> 写寄存器
	
	//左 -> MEM/WB送出
	input [31:0] W_Instr_in,
	input [31:0] W_PC_in,
	input [31:0] W_ALUresult_in,
	input [31:0] W_DMdata_in,
	input W_WEGF_in,
	input [4:0] W_add_write_in,
	input [4:0] W_add_write_plus_in,
	
	
	output reg [4:0] W_add_write,//试图写入的寄存器地址
	output reg W_type_write,	//试图写入的寄存器来源类型 1=dm 0=alu
	
	
	//左 -> datapath接收
	output reg WEgf,					//寄存器堆写使能
	output reg [4:0] WriteGFadd,	//写的寄存器地址
	output reg [31:0] WriteGFdata,//写的寄存器数据
	
	input freeze
    );	 
	
	//临时变量
	wire [31:0]temp1;
	assign temp1 = CareGF1_E + E_Num2_in; 
	
	reg Nulldelayslot= 1'b0;
	
	//以下内容复制5份！！！！！！
	//支持指令
	wire I_addu, I_subu, I_lui, I_ori, I_lw, I_sw, I_beq, I_jal, I_jr, I_nop, I_j;
	wire D_addu, D_subu, D_lui, D_ori, D_lw, D_sw, D_beq, D_jal, D_jr, D_nop, D_j;
	wire E_addu, E_subu, E_lui, E_ori, E_lw, E_sw, E_beq, E_jal, E_jr, E_nop, E_j;
	wire M_addu, M_subu, M_lui, M_ori, M_lw, M_sw, M_beq, M_jal, M_jr, M_nop, M_j;
	wire W_addu, W_subu, W_lui, W_ori, W_lw, W_sw, W_beq, W_jal, W_jr, W_nop, W_j;
	
	wire I_bal, D_bal, E_bal, M_bal, W_bal;
	wire I_cal, D_cal, E_cal, M_cal, W_cal;
	wire I_cai, D_cai, E_cai, M_cai, W_cai;
	wire I_lr , D_lr , E_lr , M_lr , W_lr ;
	wire I_lr1, D_lr1, E_lr1, M_lr1, W_lr1;
	wire I_lr2, D_lr2, E_lr2, M_lr2, W_lr2;
	wire I_lr3, D_lr3, E_lr3, M_lr3, W_lr3;
	
	wire I_addi, D_addi, E_addi, M_addi, W_addi;
	wire I_jalr, D_jalr, E_jalr, M_jalr, W_jalr;
	
	
	//指令拆解
	wire [5:0]I_op, I_func, D_op, D_func, E_op, E_func, M_op, M_func, W_op, W_func;
	wire [4:0]I_rs, D_rs, E_rs, M_rs, W_rs, I_rt, D_rt, E_rt, M_rt, W_rt, I_rd, D_rd, E_rd, M_rd, W_rd;
	
	assign I_op 	= I_Instr_in[31:26];
	assign I_func 	= I_Instr_in[5:0];
	assign I_rs		= I_Instr_in[25:21];
	assign I_rt		= I_Instr_in[20:16];
	assign I_rd		= I_Instr_in[15:11];
	
	assign D_op 	= D_Instr_in[31:26];
	assign D_func 	= D_Instr_in[5:0];
	assign D_rs		= D_Instr_in[25:21];
	assign D_rt		= D_Instr_in[20:16];
	assign D_rd		= D_Instr_in[15:11];
	
	assign E_op 	= E_Instr_in[31:26];
	assign E_func 	= E_Instr_in[5:0];
	assign E_rs		= E_Instr_in[25:21];
	assign E_rt		= E_Instr_in[20:16];
	assign E_rd		= E_Instr_in[15:11];
	
	assign M_op 	= M_Instr_in[31:26];
	assign M_func 	= M_Instr_in[5:0];
	assign M_rs		= M_Instr_in[25:21];
	assign M_rt		= M_Instr_in[20:16];
	assign M_rd		= M_Instr_in[15:11]; 
	
	assign W_op 	= W_Instr_in[31:26];
	assign W_func 	= W_Instr_in[5:0];
	assign W_rs		= W_Instr_in[25:21];
	assign W_rt		= W_Instr_in[20:16];
	assign W_rd		= W_Instr_in[15:11];
	
	//以下内容复制5份！！！！！！
	//指令描述
	assign I_addu 	= (I_op == 6'b000000)&(I_func == 6'b100001);
	assign I_subu 	= (I_op == 6'b000000)&(I_func == 6'b100011);
	assign I_lui 	= (I_op == 6'b001111);
	assign I_ori 	= (I_op == 6'b001101);
	assign I_lw 	= (I_op == 6'b100011);
	assign I_sw 	= (I_op == 6'b101011);
	assign I_beq 	= (I_op == 6'b000100);
	assign I_jal 	= (I_op == 6'b000011);
	assign I_jr 	= (I_op == 6'b000000)&(I_func == 6'b001000);
	assign I_j 		= (I_op == 6'b000010);
	assign I_nop	= (I_op == 6'b000000)&(I_func == 6'b000000);

	assign D_addu 	= (D_op == 6'b000000)&(D_func == 6'b100001);
	assign D_subu 	= (D_op == 6'b000000)&(D_func == 6'b100011);
	assign D_lui 	= (D_op == 6'b001111);
	assign D_ori 	= (D_op == 6'b001101);
	assign D_lw 	= (D_op == 6'b100011);
	assign D_sw 	= (D_op == 6'b101011);
	assign D_beq 	= (D_op == 6'b000100);
	assign D_jal 	= (D_op == 6'b000011);
	assign D_jr 	= (D_op == 6'b000000)&(D_func == 6'b001000);
	assign D_j 		= (D_op == 6'b000010);
	assign D_nop	= (D_op == 6'b000000)&(D_func == 6'b000000);
	
	assign E_addu 	= (E_op == 6'b000000)&(E_func == 6'b100001);
	assign E_subu 	= (E_op == 6'b000000)&(E_func == 6'b100011);
	assign E_lui 	= (E_op == 6'b001111);
	assign E_ori 	= (E_op == 6'b001101);
	assign E_lw 	= (E_op == 6'b100011);
	assign E_sw 	= (E_op == 6'b101011);
	assign E_beq 	= (E_op == 6'b000100);
	assign E_jal 	= (E_op == 6'b000011);
	assign E_jr 	= (E_op == 6'b000000)&(E_func == 6'b001000);
	assign E_j 		= (E_op == 6'b000010);
	assign E_nop	= (E_op == 6'b000000)&(E_func == 6'b000000);

	assign M_addu 	= (M_op == 6'b000000)&(M_func == 6'b100001);
	assign M_subu 	= (M_op == 6'b000000)&(M_func == 6'b100011);
	assign M_lui 	= (M_op == 6'b001111);
	assign M_ori 	= (M_op == 6'b001101);
	assign M_lw 	= (M_op == 6'b100011);
	assign M_sw 	= (M_op == 6'b101011);
	assign M_beq 	= (M_op == 6'b000100);
	assign M_jal 	= (M_op == 6'b000011);
	assign M_jr 	= (M_op == 6'b000000)&(M_func == 6'b001000);
	assign M_j 		= (M_op == 6'b000010);
	assign M_nop	= (M_op == 6'b000000)&(M_func == 6'b000000);

	assign W_addu 	= (W_op == 6'b000000)&(W_func == 6'b100001);
	assign W_subu 	= (W_op == 6'b000000)&(W_func == 6'b100011);
	assign W_lui 	= (W_op == 6'b001111);
	assign W_ori 	= (W_op == 6'b001101);
	assign W_lw 	= (W_op == 6'b100011);
	assign W_sw 	= (W_op == 6'b101011);
	assign W_beq 	= (W_op == 6'b000100);
	assign W_jal 	= (W_op == 6'b000011);
	assign W_jr 	= (W_op == 6'b000000)&(W_func == 6'b001000);
	assign W_j 		= (W_op == 6'b000010);
	assign W_nop	= (W_op == 6'b000000)&(W_func == 6'b000000);
	
	
	assign I_bal	= (I_op == 6'b000001); //待定
	assign D_bal	= (D_op == 6'b000001);
	assign E_bal	= (E_op == 6'b000001);
	assign M_bal	= (M_op == 6'b000001);
	assign W_bal	= (W_op == 6'b000001);
	
	assign I_cal 	= (I_op == 6'b000000)&(I_func == 6'b100110); //以xor为例
	assign D_cal 	= (D_op == 6'b000000)&(D_func == 6'b100110);
	assign E_cal 	= (E_op == 6'b000000)&(E_func == 6'b100110);
	assign M_cal 	= (M_op == 6'b000000)&(M_func == 6'b100110);
	assign W_cal 	= (W_op == 6'b000000)&(W_func == 6'b100110);
	
	assign I_cai 	= (I_op == 6'b001110);								//以xori为例
	assign D_cai 	= (D_op == 6'b001110);
	assign E_cai 	= (E_op == 6'b001110);
	assign M_cai 	= (M_op == 6'b001110);
	assign W_cai 	= (W_op == 6'b001110);
	
	assign I_lr 	= (I_op == 6'b111111);								//opcode瞎编的
	assign D_lr 	= (D_op == 6'b111111);
	assign E_lr 	= (E_op == 6'b111111);
	assign M_lr 	= (M_op == 6'b111111);
	assign W_lr 	= (W_op == 6'b111111);
	
	assign I_lr1 	= (I_op == 6'b011111);								//opcode瞎编的
	assign D_lr1 	= (D_op == 6'b011111);
	assign E_lr1 	= (E_op == 6'b011111);
	assign M_lr1 	= (M_op == 6'b011111);
	assign W_lr1 	= (W_op == 6'b011111);
	
	assign I_lr2 	= (I_op == 6'b101111);								//opcode瞎编的
	assign D_lr2 	= (D_op == 6'b101111);
	assign E_lr2 	= (E_op == 6'b101111);
	assign M_lr2 	= (M_op == 6'b101111);
	assign W_lr2 	= (W_op == 6'b101111);
	
	assign I_lr3 	= (I_op == 6'b001100);								//opcode瞎编的
	assign D_lr3 	= (D_op == 6'b001100);
	assign E_lr3 	= (E_op == 6'b001100);
	assign M_lr3 	= (M_op == 6'b001100);
	assign W_lr3 	= (W_op == 6'b001100);
	
	assign I_addi 	= (I_op == 6'b001000);								
	assign D_addi 	= (D_op == 6'b001000);
	assign E_addi 	= (E_op == 6'b001000);
	assign M_addi 	= (M_op == 6'b001000);
	assign W_addi 	= (W_op == 6'b001000);
	
	assign I_jalr 	= (I_op == 6'b000000)&(I_func == 6'b001001); 
	assign D_jalr 	= (D_op == 6'b000000)&(D_func == 6'b001001);
	assign E_jalr 	= (E_op == 6'b000000)&(E_func == 6'b001001);
	assign M_jalr 	= (M_op == 6'b000000)&(M_func == 6'b001001);
	assign W_jalr 	= (W_op == 6'b000000)&(W_func == 6'b001001);
	
	
	//以下内容复制5份！！！！！！
	//指令列表
	wire [4:0]I_Instrlist, D_Instrlist, E_Instrlist, M_Instrlist, W_Instrlist;
	assign I_Instrlist	=	(I_addu 	== 1'b1) ? `Addu:
									(I_subu 	== 1'b1) ? `Subu:
									(I_lui 	== 1'b1) ? `Lui:
									(I_ori 	== 1'b1) ? `Ori:
									(I_lw 	== 1'b1) ? `Lw:
									(I_sw 	== 1'b1) ? `Sw:
									(I_beq 	== 1'b1) ? `Beq:
									(I_jal 	== 1'b1) ? `Jal:
									(I_jr 	== 1'b1) ? `Jr:
									(I_j 		== 1'b1) ? `J:
									(I_nop 	== 1'b1) ? `Nop:
									
									(I_bal	== 1'b1) ? `Bal:
									(I_cal	== 1'b1) ? `Cal:
									(I_cai	== 1'b1) ? `Cai:
									(I_lr 	== 1'b1) ? `Lr:
									(I_lr1 	== 1'b1) ? `Lr1:
									(I_lr2 	== 1'b1) ? `Lr2:
									(I_lr3 	== 1'b1) ? `Lr3:
									
									(I_addi	== 1'b1) ? `Addi:
									(I_jalr 	== 1'b1) ? `Jalr:
																	5'd31;
	assign D_Instrlist	=	(D_addu 	== 1'b1) ? `Addu:
									(D_subu 	== 1'b1) ? `Subu:
									(D_lui 	== 1'b1) ? `Lui:
									(D_ori 	== 1'b1) ? `Ori:
									(D_lw 	== 1'b1) ? `Lw:
									(D_sw 	== 1'b1) ? `Sw:
									(D_beq 	== 1'b1) ? `Beq:
									(D_jal 	== 1'b1) ? `Jal:
									(D_jr 	== 1'b1) ? `Jr:
									(D_j 		== 1'b1) ? `J:
									(D_nop 	== 1'b1) ? `Nop:
									
									(D_bal	== 1'b1) ? `Bal:
									(D_cal	== 1'b1) ? `Cal:
									(D_cai	== 1'b1) ? `Cai:
									(D_lr 	== 1'b1) ? `Lr:
									(D_lr1 	== 1'b1) ? `Lr1:
									(D_lr2 	== 1'b1) ? `Lr2:
									(D_lr3 	== 1'b1) ? `Lr3:
									
									(D_addi	== 1'b1) ? `Addi:
									(D_jalr 	== 1'b1) ? `Jalr:
																	5'd31;
																	
	assign E_Instrlist	=	(E_addu 	== 1'b1) ? `Addu:
									(E_subu 	== 1'b1) ? `Subu:
									(E_lui 	== 1'b1) ? `Lui:
									(E_ori 	== 1'b1) ? `Ori:
									(E_lw 	== 1'b1) ? `Lw:
									(E_sw 	== 1'b1) ? `Sw:
									(E_beq 	== 1'b1) ? `Beq:
									(E_jal 	== 1'b1) ? `Jal:
									(E_jr 	== 1'b1) ? `Jr:
									(E_j 		== 1'b1) ? `J:
									(E_nop 	== 1'b1) ? `Nop:
									
									(E_bal	== 1'b1) ? `Bal:
									(E_cal	== 1'b1) ? `Cal:
									(E_cai	== 1'b1) ? `Cai:
									(E_lr 	== 1'b1) ? `Lr:
									(E_lr1 	== 1'b1) ? `Lr1:
									(E_lr2 	== 1'b1) ? `Lr2:
									(E_lr3 	== 1'b1) ? `Lr3:
									
									(E_addi	== 1'b1) ? `Addi:
									(E_jalr 	== 1'b1) ? `Jalr:
																	5'd31;
	assign M_Instrlist	=	(M_addu 	== 1'b1) ? `Addu:
									(M_subu 	== 1'b1) ? `Subu:
									(M_lui 	== 1'b1) ? `Lui:
									(M_ori 	== 1'b1) ? `Ori:
									(M_lw 	== 1'b1) ? `Lw:
									(M_sw 	== 1'b1) ? `Sw:
									(M_beq 	== 1'b1) ? `Beq:
									(M_jal 	== 1'b1) ? `Jal:
									(M_jr 	== 1'b1) ? `Jr:
									(M_j 		== 1'b1) ? `J:
									(M_nop 	== 1'b1) ? `Nop:
									
									(M_bal	== 1'b1) ? `Bal:
									(M_cal	== 1'b1) ? `Cal:
									(M_cai	== 1'b1) ? `Cai:
									(M_lr 	== 1'b1) ? `Lr:
									(M_lr1 	== 1'b1) ? `Lr1:
									(M_lr2 	== 1'b1) ? `Lr2:
									(M_lr3 	== 1'b1) ? `Lr3:
									
									(M_addi	== 1'b1) ? `Addi:
									(M_jalr 	== 1'b1) ? `Jalr:
																	5'd31;
																	
	assign W_Instrlist	=	(W_addu 	== 1'b1) ? `Addu:
									(W_subu 	== 1'b1) ? `Subu:
									(W_lui 	== 1'b1) ? `Lui:
									(W_ori 	== 1'b1) ? `Ori:
									(W_lw 	== 1'b1) ? `Lw:
									(W_sw 	== 1'b1) ? `Sw:
									(W_beq 	== 1'b1) ? `Beq:
									(W_jal 	== 1'b1) ? `Jal:
									(W_jr 	== 1'b1) ? `Jr:
									(W_j 		== 1'b1) ? `J:
									(W_nop 	== 1'b1) ? `Nop:
									
									(W_bal	== 1'b1) ? `Bal:
									(W_cal	== 1'b1) ? `Cal:
									(W_cai	== 1'b1) ? `Cai:
									(W_lr 	== 1'b1) ? `Lr:
									(W_lr1 	== 1'b1) ? `Lr1:
									(W_lr2 	== 1'b1) ? `Lr2:
									(W_lr3 	== 1'b1) ? `Lr3:
									
									(W_addi	== 1'b1) ? `Addi:
									(W_jalr 	== 1'b1) ? `Jalr:
																	5'd31;
	
//周期 Ⅰ		 -> 指令
always @(*) begin
	I_Instr_out = (freeze) ? D_Instr_in :
					  (Nulldelayslot) ? 32'b0 : I_Instr_in;
	I_PC_out 	= (freeze) ? D_PC_in 	:
					  (Nulldelayslot) ? 32'b0 : I_PC_in;
end

//周期 Ⅱ	指令 -> 读寄存器
always @(*) begin
			
    case(D_Instrlist)
			`Addu:
				begin
					//左 -> datapath接收
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//关心的寄存器的值
					CareGFadd1_D = D_rs;	//关心的寄存器1地址
					CareGFadd2_D = D_rt;	//关心的寄存器2地址
					
					askdata1_E = CareGF1_D;
					askdata2_E = CareGF2_D;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze)? 32'b0 : D_Instr_in;
					D_PC_out		= D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'd0;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
				end
			`Subu: 
				begin
					//左 -> datapath接收
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//关心的寄存器的值
					CareGFadd1_D = D_rs;	//关心的寄存器1地址
					CareGFadd2_D = D_rt;	//关心的寄存器2地址
					
					askdata1_E = CareGF1_D;
					askdata2_E = CareGF2_D;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze)? 32'b0 : D_Instr_in;
					D_PC_out		= D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'd1;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
				end
			`Lui: 
				begin
					//左 -> datapath接收
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//关心的寄存器的值
					CareGFadd1_D = 5'b0;	//关心的寄存器1地址
					CareGFadd2_D = 5'b0;	//关心的寄存器2地址
					
					askdata1_E = 32'b0;
					askdata2_E = 32'b0;
					
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze)? 32'b0 : D_Instr_in;;
					D_PC_out		= D_PC_in;
					D_Num1_out	= 32'b0;
					D_Num2_out	= {16'b0,D_Instr_in[15:0]};
					D_ALUopcode_out = 4'd4;
					D_WEGF_out	= 1'b1;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
				end
			`Ori: 
				begin
					//左 -> datapath接收
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//关心的寄存器
					CareGFadd1_D = D_rs;	//关心的寄存器1地址
					CareGFadd2_D = 5'b0;	//关心的寄存器2地址
					
					askdata1_E = CareGF1_D;
					askdata2_E = 32'b0;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze)? 32'b0 : D_Instr_in;
					D_PC_out		= D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {16'b0,D_Instr_in[15:0]};
					D_ALUopcode_out = 4'd3;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
									
					Nulldelayslot = 1'b0;
				end
			`Lw:
				begin
					//左 -> datapath接收
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//关心的寄存器
					CareGFadd1_D = D_rs;	//关心的寄存器1地址
					CareGFadd2_D = 5'b0;	//关心的寄存器2地址
					
					askdata1_E = CareGF1_D;
					askdata2_E = 32'b0;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze)? 32'b0 : D_Instr_in;
					D_PC_out		= D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {{16{D_Instr_in[15]}},D_Instr_in[15:0]};
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
										
				end
			`Sw: 
				begin
					//左 -> datapath接收
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//关心的寄存器
					CareGFadd1_D = D_rs;	//关心的寄存器1地址
					CareGFadd2_D = D_rt;	//关心的寄存器2地址
					
					askdata1_E = CareGF1_D;
					askdata2_E = CareGF2_D;
					
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze)? 32'b0 : D_Instr_in;
					D_PC_out		= D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {{16{D_Instr_in[15]}},D_Instr_in[15:0]};
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= freeze ? 4'b0 : 4'b1111;
					
					Nulldelayslot = 1'b0;
										
				end
			`Beq: 
				begin
					//beq类需要提前关心
					//关心的寄存器
					CareGFadd1_D = D_rs;	//关心的寄存器1地址
					CareGFadd2_D = D_rt;	//关心的寄存器2地址
					
					askdata1_E = CareGF1_D;
					askdata2_E = CareGF2_D;
					
					
					//左 -> datapath接收
					Jumpsign		= (freeze) ? 1'b0:
									  ((CareGF1_D == CareGF2_D)) ? 1'b1 : 1'b0;
					JumpAddr		= (freeze) ? 32'b0:
									  ((CareGF1_D == CareGF2_D)) ? (D_PC_in + 4 + {{14{D_Instr_in[15]}}, D_Instr_in[15:0], 2'b00}) : 
																																									32'b0;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze)? 32'b0 : D_Instr_in;
					D_PC_out		= D_PC_in;
					D_Num1_out	= 32'b0;
					D_Num2_out	= 32'b0;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					//清空延迟槽示例
//					Nulldelayslot = (freeze) ? 1'b0:
//									  ((CareGF1_D == CareGF2_D)) ? 1'b1 : 1'b0;
					Nulldelayslot = 1'b0;
				end
			`Jal: 
				begin
					//左 -> datapath接收
					Jumpsign		= 1'b1;
					JumpAddr		= {D_PC_in[31:28], D_Instr_in[25:0], 2'b00};
					
					//关心的寄存器
					CareGFadd1_D = 5'b0;	//关心的寄存器1地址
					CareGFadd2_D = 5'b0;	//关心的寄存器2地址
					
					askdata1_E = 32'b0;
					askdata2_E = 32'b0;
					
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze)? 32'b0 : D_Instr_in;;
					D_PC_out		= D_PC_in;
					D_Num1_out	= D_PC_in;
					D_Num2_out	= 32'd8;
					D_ALUopcode_out = 4'b0; //aluresult = pc + 8
					D_WEGF_out	= 1'b1;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
			
				end
			`Jr:
				begin
				
					//关心的寄存器
					CareGFadd1_D = D_rs;	//关心的寄存器1地址
					CareGFadd2_D = 5'b0;	//关心的寄存器2地址
					
					askdata1_E = CareGF1_D;
					askdata2_E = 32'b0;
					
					//左 -> datapath接收
					Jumpsign		= ~freeze;
					JumpAddr		= CareGF1_D;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze)? 32'b0 : D_Instr_in;
					D_PC_out		= D_PC_in;
					D_Num1_out	= 32'b0;
					D_Num2_out	= 32'b0;
					D_ALUopcode_out = 4'b0; 
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
		
				end
			`J: 
				begin
				
					//关心的寄存器
					CareGFadd1_D = 5'b0;	//关心的寄存器1地址
					CareGFadd2_D = 5'b0;	//关心的寄存器2地址
					
					askdata1_E = 32'b0;
					askdata2_E = 32'b0;
					
					//左 -> datapath接收
					Jumpsign		= 1'b1;
					JumpAddr		= {D_PC_in[31:28], D_Instr_in[25:0], 2'b0};

					//右 -> ID/EX接收
					D_Instr_out	= (freeze)? 32'b0 : D_Instr_in;;
					D_PC_out		= D_PC_in;
					D_Num1_out	= 32'b0;
					D_Num2_out	= 32'b0;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;

			
				end
			`Nop: 
				begin
					//左 -> datapath接收
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//关心的寄存器
					CareGFadd1_D = 5'b0;	//关心的寄存器1地址
					CareGFadd2_D = 5'b0;	//关心的寄存器2地址
					
					askdata1_E = 32'b0;
					askdata2_E = 32'b0;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze)? 32'b0 : D_Instr_in;;
					D_PC_out		= D_PC_in;
					D_Num1_out	= 32'b0;
					D_Num2_out	= 32'b0;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
						
				end
				
			`Bal: 
				begin
					//beq类需要提前关心
					//关心的寄存器
					CareGFadd1_D = D_rs;	//关心的寄存器1地址
					CareGFadd2_D = D_rt;	//关心的寄存器2地址
					
					askdata1_E = CareGF1_D;
					askdata2_E = CareGF2_D;
					
					
					//左 -> datapath接收 //判断条件待定，暂时用beq代替
					Jumpsign		= (freeze) ? 1'b0:
									  ((CareGF1_D == CareGF2_D)) ? 1'b1 : 1'b0;
					JumpAddr		= (freeze) ? 32'b0:
									  ((CareGF1_D == CareGF2_D)) ? (D_PC_in + 4 + {{14{D_Instr_in[15]}}, D_Instr_in[15:0], 2'b0}) : 
																																									32'b0;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze)? 32'b0 : D_Instr_in;;
					D_PC_out		= D_PC_in;
					D_Num1_out	= D_PC_in;
					D_Num2_out	= 32'd8;
					D_ALUopcode_out = 4'b0; //aluresult = pc + 8
					D_WEGF_out	= ((CareGF1_D == CareGF2_D)) ? 1'b1 : 1'b0; //默认当跳转时写入
					D_WEDM_out	= 4'b0;
									
									
					Nulldelayslot = 1'b0;
				end
			`Cal: 
				begin
					//左 -> datapath接收
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//关心的寄存器的值
					CareGFadd1_D = D_rs;	//关心的寄存器1地址
					CareGFadd2_D = D_rt;	//关心的寄存器2地址
					
					askdata1_E = CareGF1_D;
					askdata2_E = CareGF2_D;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze)? 32'b0 : D_Instr_in;
					D_PC_out		= D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'd5;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
										
					Nulldelayslot = 1'b0;
					
				end
			`Cai: 
				begin
					//左 -> datapath接收
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//关心的寄存器
					CareGFadd1_D = D_rs;	//关心的寄存器1地址
					CareGFadd2_D = 5'b0;	//关心的寄存器2地址
					
					askdata1_E = CareGF1_D;
					askdata2_E = 32'b0;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze)? 32'b0 : D_Instr_in;
					D_PC_out		= D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {{16{D_Instr_in[15]}},D_Instr_in[15:0]};
					D_ALUopcode_out = 4'd5;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
								
					Nulldelayslot = 1'b0;
				end
				
			`Lr:
				begin
					//左 -> datapath接收
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//关心的寄存器
					CareGFadd1_D = D_rs;	//关心的寄存器1地址
					CareGFadd2_D = D_rt;	//关心的寄存器2地址
					
					askdata1_E = CareGF1_D;
					askdata2_E = CareGF2_D;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze)? 32'b0 : D_Instr_in;
					D_PC_out		= D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {{16{D_Instr_in[15]}},D_Instr_in[15:0]};
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
								
					Nulldelayslot = 1'b0;
					
				end
			`Lr1:
				begin
					//左 -> datapath接收
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//关心的寄存器
					CareGFadd1_D = D_rs;	//关心的寄存器1地址
					CareGFadd2_D = 5'b0;	//关心的寄存器2地址
					
					askdata1_E = CareGF1_D;
					askdata2_E = 32'b0;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze)? 32'b0 : D_Instr_in;
					D_PC_out		= D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {{16{D_Instr_in[15]}},D_Instr_in[15:0]};
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
										
				end
			`Lr2:
				begin
					//左 -> datapath接收
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//关心的寄存器
					CareGFadd1_D = D_rs;	//关心的寄存器1地址
					CareGFadd2_D = 5'b0;	//关心的寄存器2地址
					
					askdata1_E = CareGF1_D;
					askdata2_E = 32'b0;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze)? 32'b0 : D_Instr_in;
					D_PC_out		= D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {{16{D_Instr_in[15]}},D_Instr_in[15:0]};
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
				end
			`Addi: 
				begin
					//左 -> datapath接收
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//关心的寄存器
					CareGFadd1_D = D_rs;	//关心的寄存器1地址
					CareGFadd2_D = 5'b0;	//关心的寄存器2地址
					
					askdata1_E = CareGF1_D;
					askdata2_E = 32'b0;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze)? 32'b0 : D_Instr_in;
					D_PC_out		= D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {{16{D_Instr_in[15]}},D_Instr_in[15:0]};
					D_ALUopcode_out = 4'd0;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
									
					Nulldelayslot = 1'b0;
				end
			`Jalr:
				begin
				
					//关心的寄存器
					CareGFadd1_D = D_rs;	//关心的寄存器1地址
					CareGFadd2_D = 5'b0;	//关心的寄存器2地址
					
					askdata1_E = CareGF1_D;
					askdata2_E = 32'b0;
					
					//左 -> datapath接收
					Jumpsign		= ~freeze;
					JumpAddr		= CareGF1_D;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze)? 32'b0 : D_Instr_in;
					D_PC_out		= D_PC_in;
					D_Num1_out	= D_PC_in;
					D_Num2_out	= 32'd8;
					D_ALUopcode_out = 4'b0; //aluresult = pc + 8
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
				end
				
        default:
				begin
					//donothing
				end
				
    endcase
	 
end

//周期 Ⅲ	读寄存器 -> ALU
always @(*) begin
	case(E_Instrlist)
			`Addu:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = CareGF2_E;
					
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
					
					E_WEGF_out		= E_WEGF_in;
					E_WEDM_out		= E_WEDM_in;
				end
			`Subu:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = CareGF2_E;
					
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
					
					E_WEGF_out		= E_WEGF_in;
					E_WEDM_out		= E_WEDM_in;
				end
			`Lui:
				begin
					//关心的寄存器
					CareGFadd1_E = 5'b0;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = 32'b0;
					askdata2_M = 32'b0;
					
					ALUinput1	 = E_Num1_in;							 
					ALUinput2	 = E_Num2_in;
					
					E_add_write  = E_rt;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
					
					E_WEGF_out		= E_WEGF_in;
					E_WEDM_out		= E_WEDM_in;
				end
			`Ori:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = 32'b0;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = E_Num2_in;
					
					E_add_write  = E_rt;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
					
					E_WEGF_out		= E_WEGF_in;
					E_WEDM_out		= E_WEDM_in;
				end
			`Lw:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = 32'b0;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = E_Num2_in;
					
					E_add_write  = E_rt;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b1;
					
					E_WEGF_out		= E_WEGF_in;
					E_WEDM_out		= E_WEDM_in;
				end
			`Sw:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = E_Num2_in;
					
					E_add_write  = 5'b0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
					
					E_WEGF_out		= E_WEGF_in;
					E_WEDM_out		= E_WEDM_in;
				end
			`Beq:
				begin
					//关心的寄存器
					CareGFadd1_E = 5'b0;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = 32'b0;
					askdata2_M = 32'b0;
					
					ALUinput1	 = E_Num1_in;							 
					ALUinput2	 = E_Num2_in;
					
					E_add_write  = 5'b0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
					
					E_WEGF_out		= E_WEGF_in;
					E_WEDM_out		= E_WEDM_in;
				end
			`Jal:
				begin
					//关心的寄存器
					CareGFadd1_E = 5'b0;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = 32'b0;
					askdata2_M = 32'b0;
					
					ALUinput1	 = E_Num1_in;							 
					ALUinput2	 = E_Num2_in;
					
					E_add_write  = 5'b11111;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
					
					E_WEGF_out		= E_WEGF_in;
					E_WEDM_out		= E_WEDM_in;
				end
			`Jr:
				begin
					//关心的寄存器
					CareGFadd1_E = 5'b0;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = 32'b0;
					askdata2_M = 32'b0;
					
					ALUinput1	 = E_Num1_in;							 
					ALUinput2	 = E_Num2_in;
					
					E_add_write  = 5'b0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
					
					E_WEGF_out		= E_WEGF_in;
					E_WEDM_out		= E_WEDM_in;
				end
			`J:
				begin
					//关心的寄存器
					CareGFadd1_E = 5'b0;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = 32'b0;
					askdata2_M = 32'b0;
					
					ALUinput1	 = E_Num1_in;							 
					ALUinput2	 = E_Num2_in;
					
					E_add_write  = 5'b0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
					
					E_WEGF_out		= E_WEGF_in;
					E_WEDM_out		= E_WEDM_in;
				end
			`Nop:
				begin
					//关心的寄存器
					CareGFadd1_E = 5'b0;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = 32'b0;
					askdata2_M = 32'b0;
					
					ALUinput1	 = E_Num1_in;							 
					ALUinput2	 = E_Num2_in;
					
					E_add_write  = 5'b0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
					
					E_WEGF_out		= E_WEGF_in;
					E_WEDM_out		= E_WEDM_in;
				end
			`Bal:
				begin
					//关心的寄存器
					CareGFadd1_E = 5'b0;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = 32'b0;
					askdata2_M = 32'b0;
					
					ALUinput1	 = E_Num1_in;							 
					ALUinput2	 = E_Num2_in;
					
					E_add_write  = 5'b11111;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
					
					E_WEGF_out		= E_WEGF_in;
					E_WEDM_out		= E_WEDM_in;
				end
			`Cal:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = CareGF2_E;
					
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
					
					E_WEGF_out		= E_WEGF_in;
					E_WEDM_out		= E_WEDM_in;
					
				end
			`Cai:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = 32'b0;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = E_Num2_in;
					
					E_add_write  = E_rt;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
					
					E_WEGF_out		= E_WEGF_in;
					E_WEDM_out		= E_WEDM_in;
				end
				
			`Lr:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = E_Num2_in;
					
					E_add_write  = 5'd0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
					
					E_WEGF_out		= E_WEGF_in;
					E_WEDM_out		= E_WEDM_in;
				end
			`Lr1:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = 32'b0;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = E_Num2_in;
					
					E_add_write  = E_rt;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b1;
					
					E_WEGF_out		= E_WEGF_in;
					E_WEDM_out		= E_WEDM_in;
				end
			`Lr2:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = 32'b0;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = E_Num2_in;
					
					E_add_write  = E_rt;
					E_add_write_plus = E_rs;
					E_type_write = 1'b1;
					
					E_WEGF_out		= E_WEGF_in;
					E_WEDM_out		= E_WEDM_in;
				end
			`Addi:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = 32'b0;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = E_Num2_in;
					
					E_add_write  = E_rt;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
					
					E_WEGF_out		= E_WEGF_in;
					E_WEDM_out		= E_WEDM_in;
				end
			`Jalr:
				begin
					//关心的寄存器
					CareGFadd1_E = 5'b0;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = 32'b0;
					askdata2_M = 32'b0;
					
					ALUinput1	 = E_Num1_in;							 
					ALUinput2	 = E_Num2_in;
					
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
					
					E_WEGF_out		= E_WEGF_in;
					E_WEDM_out		= E_WEDM_in;
				end	
			
	endcase
	
	//左 -> datapath接收
	ALUopcode		= E_ALUopcode_in;

	//右 -> EX/MEM接收
	E_Instr_out 	= E_Instr_in;
	E_PC_out 		= E_PC_in;
	E_ALUresult_out= ALUresult;
	
end

//周期 Ⅳ	ALU -> 数据存储器
always @(*) begin
	//左 -> datapath接收
	readDMadd		= M_ALUresult_in;
	case(M_Instrlist)
			`Addu:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= M_WEDM_in;
					
					M_add_write  = M_rd;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
					
				end
			`Subu:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= M_WEDM_in;
					
					M_add_write  = M_rd;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Lui:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= M_WEDM_in;
					
					M_add_write  = M_rt;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Ori:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= M_WEDM_in;
					
					M_add_write  = M_rt;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Lw:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= M_WEDM_in;
					
					M_add_write  = M_rt;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b1;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Sw:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = M_rt;	//关心的寄存器2地址

					
					WriteDMadd		= M_ALUresult_in;
					WriteDMdata		= CareGF2_M;
					WEdm				= 4'b1111;
					
					M_add_write  = 5'b0;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Beq:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= M_WEDM_in;
					
					M_add_write  = 5'b0;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Jal:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= M_WEDM_in;
					
					M_add_write  = 5'b11111;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Jr:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= M_WEDM_in;
					
					M_add_write  = 5'b0;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`J:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= M_WEDM_in;
					
					M_add_write  = 5'b0;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Nop:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= M_WEDM_in;
					
					M_add_write  = 5'b0;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Bal:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= M_WEDM_in;
					
					M_add_write  = (M_WEGF_in) ? 5'b11111 : 5'd0; //默认当跳转时写入
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Cal:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= M_WEDM_in;
					
					M_add_write  = M_rd;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Cai:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= M_WEDM_in;
					
					M_add_write  = M_rt;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;	
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Lr:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = M_rt;	//关心的寄存器2地址

					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= M_WEDM_in;
					
					M_add_write  = ReadDM[4:0];
					M_add_write_plus = 5'd0;
					M_type_write = 1'b1;
					
					M_DMdata_out	= CareGF2_M;
					M_WEGF_out		= M_WEGF_in;
				end
			`Lr1:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= M_WEDM_in;
					
					M_add_write  = M_rt;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b1;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= !ReadDM[31];
				end
			`Lr2:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= M_WEDM_in;
					
					M_add_write  = (ReadDM[31]) ? M_rs : M_rt;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b1;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= 1'b1;
				end
			
				
			`Addi:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= M_WEDM_in;
					
					M_add_write  = M_rt;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Jalr:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= M_WEDM_in;
					
					M_add_write  = M_rd;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
	endcase
	//右 -> MEM/WB接收
	M_Instr_out		= M_Instr_in;
	M_PC_out			= M_PC_in;
	M_ALUresult_out= M_ALUresult_in;
	
end

//周期 Ⅴ 数据存储器 -> 写寄存器
always @(*) begin

//	output reg [31:0] W_Instr_in,
//	output reg [31:0] W_PC_in,
//	output reg [31:0] W_ALUresult_in,
//	output reg [31:0] W_DMdata_in,
//	output reg W_WEGF_in
	
	//左 -> datapath接收
	WEgf				= W_WEGF_in;

	case(W_Instrlist)
			`Addu:
				begin
					WriteGFadd	= W_rd; 
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rd;
					W_type_write = 1'b0;
				end
			`Subu: 
				begin
					WriteGFadd	= W_rd;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rd;
					W_type_write = 1'b0;
				end
			`Lui: 
				begin
					WriteGFadd	= W_rt;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rt;
					W_type_write = 1'b0;
				end
			`Ori: 
				begin
					WriteGFadd	= W_rt;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rt;
					W_type_write = 1'b0;
				end
			`Lw:
				begin
					WriteGFadd	= W_rt;
					WriteGFdata	= W_DMdata_in;
					
					W_add_write  = W_rt;
					W_type_write = 1'b1;
				end
			`Sw: 
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 5'b0;
					W_type_write = 1'b0;
				end
			`Beq: 
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 5'b0;
					W_type_write = 1'b0;
				end
			`Jal: 
				begin
					WriteGFadd	= 5'b11111;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = 5'b11111;
					W_type_write = 1'b0;
				end
			`Jr:
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 5'b0;
					W_type_write = 1'b0;
				end
			`J: 
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 5'b0;
					W_type_write = 1'b0;
				end
			`Nop: 
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 32'b0;
					W_type_write = 1'b0;
				end
			
			`Bal: 
				begin
					WriteGFadd	= 5'b11111;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = (W_WEGF_in) ? 5'b11111 : 5'd0; //默认当跳转时写入
					W_type_write = 1'b0;
				end
			`Cal:
				begin
					WriteGFadd	= W_rd;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rd;
					W_type_write = 1'b0;
				end
			`Cai: 
				begin
					WriteGFadd	= W_rt;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rt;
					W_type_write = 1'b0;
				end
			`Lr: 
				begin
					WriteGFadd	= W_add_write_in;
					WriteGFdata	= W_DMdata_in;
					
					W_add_write  = W_add_write_in;
					W_type_write = 1'b1;
	
				end
			`Lr1:
				begin
					WriteGFadd	= W_rt;
					WriteGFdata	= W_DMdata_in;
					
					W_add_write  = W_rt;
					W_type_write = 1'b1;
				end
			`Lr2:
				begin
					WriteGFadd	= (W_DMdata_in[31]) ? W_rs : W_rt;
					WriteGFdata	= W_DMdata_in;
					
					W_add_write  = (W_DMdata_in[31]) ? W_rs : W_rt;
					W_type_write = 1'b1;
				end
			`Addi: 
				begin
					WriteGFadd	= W_rt;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rt;
					W_type_write = 1'b0;
				end
			`Jalr: 
				begin
					WriteGFadd	= W_rd;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rd;
					W_type_write = 1'b0;
				end
			
        default:
				begin
					//donothing
				end
    endcase
end

endmodule