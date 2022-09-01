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

`define	Bal		5'd10 //bunch and link �ж�����������bunchʱlink
`define	Cal		5'd11 //δ��������ָ��
`define	Cai		5'd12 //δ��������������ָ��
	
`define	Lr			5'd13 //δ���������洢ָ�ʵ�ֹ�������
//1. ����GRF[rs]��offset�õ�MemAddr
//2. Mem[MemAddr]��5λ��ΪGRF��д���ַ
//3. д������ΪGRF[rt]
//��w���ж��Ƿ�д���ַ
`define	Lr1		5'd14
//���ڴ�������ݣ������ݴ���0��������д��rt�Ĵ���������д������lw
`define	Lr2		5'd15
//���ڴ�������ݣ������ݴ���0��������д��rt�Ĵ���������д��rs�Ĵ���
`define	Lr3		5'd16
//���ڴ�������ݣ�������д��rs+rt�Ĵ���

`define	Addi		5'd17
`define	Jalr		5'd18


module control(

//���� ��		 -> ָ��
	
	//�� -> datapath�ͳ�
	input [31:0] I_Instr_in,				//����ָ��洢��ָ��
	input [31:0] I_PC_in,					//��ǰPC
	
	//�� -> IF/ID����
	output reg [31:0] I_Instr_out,
	output reg [31:0] I_PC_out,
	
//���� ��	ָ�� -> ���Ĵ���

	//�� -> IF/ID�ͳ�
	input [31:0] D_Instr_in,
	input [31:0] D_PC_in,
	
	//���ĵļĴ�����ֵ
	output reg [4:0] CareGFadd1_D,	//���ĵļĴ���1��ַ
	output reg [4:0] CareGFadd2_D,	//���ĵļĴ���2��ַ

	//���ĵļĴ����Ľ��
	input [31:0] CareGF1_D,			//���ĵļĴ���1����
	input [31:0] CareGF2_D,			//���ĵļĴ���2����
	
	//��ʱ��Ϊ���ļĴ����Ľ��
	output reg [31:0] askdata1_E,
	output reg [31:0] askdata2_E,

	//�� -> datapath����
	output reg Jumpsign,				//���з�PC+4��ת
	output reg [31:0] JumpAddr,	//��ת������
	
	
	//�� -> ID/EX����
	output reg [31:0] D_Instr_out,
	output reg [31:0] D_PC_out,
	output reg [31:0] D_Num1_out, //GPR[base],GPR[rs]
	output reg [31:0] D_Num2_out, //GPR[rt],unsign_ext(imm16)
	output reg [3:0]  D_ALUopcode_out,
	output reg D_WEGF_out,
	output reg [3:0]  D_WEDM_out,
	 
//���� ��	���Ĵ��� -> ALU

	//�� -> ID/EX�ͳ�
	input [31:0] E_Instr_in,
	input [31:0] E_PC_in,
	input [31:0] E_Num1_in, 		//GPR[base],GPR[rs]
	input [31:0] E_Num2_in, 		//GPR[rt],unsign_ext(imm16)
	input [3:0]	 E_ALUopcode_in,
	input E_WEGF_in,
	input [3:0]  E_WEDM_in,
	
	//���ĵļĴ�����ֵ
	output reg [4:0] CareGFadd1_E,	//���ĵļĴ���1��ַ
	output reg [4:0] CareGFadd2_E,	//���ĵļĴ���2��ַ
	//���ĵļĴ����Ľ��
	input [31:0] CareGF1_E,			//���ĵļĴ���1����
	input [31:0] CareGF2_E,			//���ĵļĴ���2����
	
	output reg [4:0] E_add_write,//��ͼд��ļĴ�����ַ
	output reg [4:0] E_add_write_plus,//��ͼд��ļĴ�����ַ2
	output reg E_type_write,	//��ͼд��ļĴ�����Դ���� 1=dm 0=alu
	//��ʱ��Ϊ���ļĴ����Ľ��
	output reg [31:0] askdata1_M,
	output reg [31:0] askdata2_M,
	
	//�� -> datapath����
	output reg [3:0] ALUopcode,	//Alu�����
	output reg [31:0] ALUinput1,	//Alu��������1
	output reg [31:0] ALUinput2,	//Alu��������2
	 
	//�� -> datapath�ͳ�
	input [31:0] ALUresult,			//Alu������
	
	//�� -> EX/MEM����	
	output reg [31:0] E_Instr_out,
	output reg [31:0] E_PC_out,
	output reg [31:0] E_ALUresult_out,
	output reg E_WEGF_out,
	output reg [3:0]  E_WEDM_out,
	
//���� ��	ALU -> ���ݴ洢��

	//�� -> EX/MEM�ͳ�
	input [31:0] M_Instr_in,
	input [31:0] M_PC_in,
	input [31:0] M_ALUresult_in,
	input M_WEGF_in,
	input [3:0]  M_WEDM_in,
	
	//���ĵļĴ�����ֵ
	output reg [4:0] CareGFadd1_M,	//���ĵļĴ���1��ַ
	output reg [4:0] CareGFadd2_M,	//���ĵļĴ���2��ַ
	//���ĵļĴ����Ľ��
	input [31:0] CareGF1_M,			//���ĵļĴ���1����
	input [31:0] CareGF2_M,			//���ĵļĴ���2����
	
	output reg [4:0] M_add_write,//��ͼд��ļĴ�����ַ
	output reg [4:0] M_add_write_plus,
	output reg M_type_write,	//��ͼд��ļĴ�����Դ���� 1=dm 0=alu

	
	//�� -> datapath����
	output reg [3:0]  WEdm,					//���ݴ洢��дʹ��
	output reg [31:0] WriteDMadd,	//д�����ݴ洢����ַ
	output reg [31:0] WriteDMdata,//д�����ݴ洢������
	output reg [31:0] readDMadd,	//�������ݴ洢����ַ
	
	//�� -> datapath�ͳ�
	input [31:0] ReadDM,				//�������ݴ洢������
	
	//�� -> MEM/WB����
	output reg [31:0] M_Instr_out,
	output reg [31:0] M_PC_out,
	output reg [31:0] M_ALUresult_out,
	output reg [31:0] M_DMdata_out,
	output reg M_WEGF_out,
	
//���� �� ���ݴ洢�� -> д�Ĵ���
	
	//�� -> MEM/WB�ͳ�
	input [31:0] W_Instr_in,
	input [31:0] W_PC_in,
	input [31:0] W_ALUresult_in,
	input [31:0] W_DMdata_in,
	input W_WEGF_in,
	input [4:0] W_add_write_in,
	input [4:0] W_add_write_plus_in,
	
	
	output reg [4:0] W_add_write,//��ͼд��ļĴ�����ַ
	output reg W_type_write,	//��ͼд��ļĴ�����Դ���� 1=dm 0=alu
	
	
	//�� -> datapath����
	output reg WEgf,					//�Ĵ�����дʹ��
	output reg [4:0] WriteGFadd,	//д�ļĴ�����ַ
	output reg [31:0] WriteGFdata,//д�ļĴ�������
	
	input freeze
    );	 
	
	//��ʱ����
	wire [31:0]temp1;
	assign temp1 = CareGF1_E + E_Num2_in; 
	
	reg Nulldelayslot= 1'b0;
	
	//�������ݸ���5�ݣ�����������
	//֧��ָ��
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
	
	
	//ָ����
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
	
	//�������ݸ���5�ݣ�����������
	//ָ������
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
	
	
	assign I_bal	= (I_op == 6'b000001); //����
	assign D_bal	= (D_op == 6'b000001);
	assign E_bal	= (E_op == 6'b000001);
	assign M_bal	= (M_op == 6'b000001);
	assign W_bal	= (W_op == 6'b000001);
	
	assign I_cal 	= (I_op == 6'b000000)&(I_func == 6'b100110); //��xorΪ��
	assign D_cal 	= (D_op == 6'b000000)&(D_func == 6'b100110);
	assign E_cal 	= (E_op == 6'b000000)&(E_func == 6'b100110);
	assign M_cal 	= (M_op == 6'b000000)&(M_func == 6'b100110);
	assign W_cal 	= (W_op == 6'b000000)&(W_func == 6'b100110);
	
	assign I_cai 	= (I_op == 6'b001110);								//��xoriΪ��
	assign D_cai 	= (D_op == 6'b001110);
	assign E_cai 	= (E_op == 6'b001110);
	assign M_cai 	= (M_op == 6'b001110);
	assign W_cai 	= (W_op == 6'b001110);
	
	assign I_lr 	= (I_op == 6'b111111);								//opcodeϹ���
	assign D_lr 	= (D_op == 6'b111111);
	assign E_lr 	= (E_op == 6'b111111);
	assign M_lr 	= (M_op == 6'b111111);
	assign W_lr 	= (W_op == 6'b111111);
	
	assign I_lr1 	= (I_op == 6'b011111);								//opcodeϹ���
	assign D_lr1 	= (D_op == 6'b011111);
	assign E_lr1 	= (E_op == 6'b011111);
	assign M_lr1 	= (M_op == 6'b011111);
	assign W_lr1 	= (W_op == 6'b011111);
	
	assign I_lr2 	= (I_op == 6'b101111);								//opcodeϹ���
	assign D_lr2 	= (D_op == 6'b101111);
	assign E_lr2 	= (E_op == 6'b101111);
	assign M_lr2 	= (M_op == 6'b101111);
	assign W_lr2 	= (W_op == 6'b101111);
	
	assign I_lr3 	= (I_op == 6'b001100);								//opcodeϹ���
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
	
	
	//�������ݸ���5�ݣ�����������
	//ָ���б�
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
	
//���� ��		 -> ָ��
always @(*) begin
	I_Instr_out = (freeze) ? D_Instr_in :
					  (Nulldelayslot) ? 32'b0 : I_Instr_in;
	I_PC_out 	= (freeze) ? D_PC_in 	:
					  (Nulldelayslot) ? 32'b0 : I_PC_in;
end

//���� ��	ָ�� -> ���Ĵ���
always @(*) begin
			
    case(D_Instrlist)
			`Addu:
				begin
					//�� -> datapath����
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//���ĵļĴ�����ֵ
					CareGFadd1_D = D_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_D = D_rt;	//���ĵļĴ���2��ַ
					
					askdata1_E = CareGF1_D;
					askdata2_E = CareGF2_D;
					
					//�� -> ID/EX����
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
					//�� -> datapath����
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//���ĵļĴ�����ֵ
					CareGFadd1_D = D_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_D = D_rt;	//���ĵļĴ���2��ַ
					
					askdata1_E = CareGF1_D;
					askdata2_E = CareGF2_D;
					
					//�� -> ID/EX����
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
					//�� -> datapath����
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//���ĵļĴ�����ֵ
					CareGFadd1_D = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_D = 5'b0;	//���ĵļĴ���2��ַ
					
					askdata1_E = 32'b0;
					askdata2_E = 32'b0;
					
					
					//�� -> ID/EX����
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
					//�� -> datapath����
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//���ĵļĴ���
					CareGFadd1_D = D_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_D = 5'b0;	//���ĵļĴ���2��ַ
					
					askdata1_E = CareGF1_D;
					askdata2_E = 32'b0;
					
					//�� -> ID/EX����
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
					//�� -> datapath����
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//���ĵļĴ���
					CareGFadd1_D = D_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_D = 5'b0;	//���ĵļĴ���2��ַ
					
					askdata1_E = CareGF1_D;
					askdata2_E = 32'b0;
					
					//�� -> ID/EX����
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
					//�� -> datapath����
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//���ĵļĴ���
					CareGFadd1_D = D_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_D = D_rt;	//���ĵļĴ���2��ַ
					
					askdata1_E = CareGF1_D;
					askdata2_E = CareGF2_D;
					
					
					//�� -> ID/EX����
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
					//beq����Ҫ��ǰ����
					//���ĵļĴ���
					CareGFadd1_D = D_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_D = D_rt;	//���ĵļĴ���2��ַ
					
					askdata1_E = CareGF1_D;
					askdata2_E = CareGF2_D;
					
					
					//�� -> datapath����
					Jumpsign		= (freeze) ? 1'b0:
									  ((CareGF1_D == CareGF2_D)) ? 1'b1 : 1'b0;
					JumpAddr		= (freeze) ? 32'b0:
									  ((CareGF1_D == CareGF2_D)) ? (D_PC_in + 4 + {{14{D_Instr_in[15]}}, D_Instr_in[15:0], 2'b00}) : 
																																									32'b0;
					
					//�� -> ID/EX����
					D_Instr_out	= (freeze)? 32'b0 : D_Instr_in;
					D_PC_out		= D_PC_in;
					D_Num1_out	= 32'b0;
					D_Num2_out	= 32'b0;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					//����ӳٲ�ʾ��
//					Nulldelayslot = (freeze) ? 1'b0:
//									  ((CareGF1_D == CareGF2_D)) ? 1'b1 : 1'b0;
					Nulldelayslot = 1'b0;
				end
			`Jal: 
				begin
					//�� -> datapath����
					Jumpsign		= 1'b1;
					JumpAddr		= {D_PC_in[31:28], D_Instr_in[25:0], 2'b00};
					
					//���ĵļĴ���
					CareGFadd1_D = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_D = 5'b0;	//���ĵļĴ���2��ַ
					
					askdata1_E = 32'b0;
					askdata2_E = 32'b0;
					
					
					//�� -> ID/EX����
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
				
					//���ĵļĴ���
					CareGFadd1_D = D_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_D = 5'b0;	//���ĵļĴ���2��ַ
					
					askdata1_E = CareGF1_D;
					askdata2_E = 32'b0;
					
					//�� -> datapath����
					Jumpsign		= ~freeze;
					JumpAddr		= CareGF1_D;
					
					//�� -> ID/EX����
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
				
					//���ĵļĴ���
					CareGFadd1_D = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_D = 5'b0;	//���ĵļĴ���2��ַ
					
					askdata1_E = 32'b0;
					askdata2_E = 32'b0;
					
					//�� -> datapath����
					Jumpsign		= 1'b1;
					JumpAddr		= {D_PC_in[31:28], D_Instr_in[25:0], 2'b0};

					//�� -> ID/EX����
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
					//�� -> datapath����
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//���ĵļĴ���
					CareGFadd1_D = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_D = 5'b0;	//���ĵļĴ���2��ַ
					
					askdata1_E = 32'b0;
					askdata2_E = 32'b0;
					
					//�� -> ID/EX����
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
					//beq����Ҫ��ǰ����
					//���ĵļĴ���
					CareGFadd1_D = D_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_D = D_rt;	//���ĵļĴ���2��ַ
					
					askdata1_E = CareGF1_D;
					askdata2_E = CareGF2_D;
					
					
					//�� -> datapath���� //�ж�������������ʱ��beq����
					Jumpsign		= (freeze) ? 1'b0:
									  ((CareGF1_D == CareGF2_D)) ? 1'b1 : 1'b0;
					JumpAddr		= (freeze) ? 32'b0:
									  ((CareGF1_D == CareGF2_D)) ? (D_PC_in + 4 + {{14{D_Instr_in[15]}}, D_Instr_in[15:0], 2'b0}) : 
																																									32'b0;
					
					//�� -> ID/EX����
					D_Instr_out	= (freeze)? 32'b0 : D_Instr_in;;
					D_PC_out		= D_PC_in;
					D_Num1_out	= D_PC_in;
					D_Num2_out	= 32'd8;
					D_ALUopcode_out = 4'b0; //aluresult = pc + 8
					D_WEGF_out	= ((CareGF1_D == CareGF2_D)) ? 1'b1 : 1'b0; //Ĭ�ϵ���תʱд��
					D_WEDM_out	= 4'b0;
									
									
					Nulldelayslot = 1'b0;
				end
			`Cal: 
				begin
					//�� -> datapath����
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//���ĵļĴ�����ֵ
					CareGFadd1_D = D_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_D = D_rt;	//���ĵļĴ���2��ַ
					
					askdata1_E = CareGF1_D;
					askdata2_E = CareGF2_D;
					
					//�� -> ID/EX����
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
					//�� -> datapath����
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//���ĵļĴ���
					CareGFadd1_D = D_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_D = 5'b0;	//���ĵļĴ���2��ַ
					
					askdata1_E = CareGF1_D;
					askdata2_E = 32'b0;
					
					//�� -> ID/EX����
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
					//�� -> datapath����
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//���ĵļĴ���
					CareGFadd1_D = D_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_D = D_rt;	//���ĵļĴ���2��ַ
					
					askdata1_E = CareGF1_D;
					askdata2_E = CareGF2_D;
					
					//�� -> ID/EX����
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
					//�� -> datapath����
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//���ĵļĴ���
					CareGFadd1_D = D_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_D = 5'b0;	//���ĵļĴ���2��ַ
					
					askdata1_E = CareGF1_D;
					askdata2_E = 32'b0;
					
					//�� -> ID/EX����
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
					//�� -> datapath����
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//���ĵļĴ���
					CareGFadd1_D = D_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_D = 5'b0;	//���ĵļĴ���2��ַ
					
					askdata1_E = CareGF1_D;
					askdata2_E = 32'b0;
					
					//�� -> ID/EX����
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
					//�� -> datapath����
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//���ĵļĴ���
					CareGFadd1_D = D_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_D = 5'b0;	//���ĵļĴ���2��ַ
					
					askdata1_E = CareGF1_D;
					askdata2_E = 32'b0;
					
					//�� -> ID/EX����
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
				
					//���ĵļĴ���
					CareGFadd1_D = D_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_D = 5'b0;	//���ĵļĴ���2��ַ
					
					askdata1_E = CareGF1_D;
					askdata2_E = 32'b0;
					
					//�� -> datapath����
					Jumpsign		= ~freeze;
					JumpAddr		= CareGF1_D;
					
					//�� -> ID/EX����
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

//���� ��	���Ĵ��� -> ALU
always @(*) begin
	case(E_Instrlist)
			`Addu:
				begin
					//���ĵļĴ���
					CareGFadd1_E = E_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_E = E_rt;	//���ĵļĴ���2��ַ
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
					//���ĵļĴ���
					CareGFadd1_E = E_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_E = E_rt;	//���ĵļĴ���2��ַ
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
					//���ĵļĴ���
					CareGFadd1_E = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_E = 5'b0;	//���ĵļĴ���2��ַ
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
					//���ĵļĴ���
					CareGFadd1_E = E_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_E = 5'b0;	//���ĵļĴ���2��ַ
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
					//���ĵļĴ���
					CareGFadd1_E = E_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_E = 5'b0;	//���ĵļĴ���2��ַ
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
					//���ĵļĴ���
					CareGFadd1_E = E_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_E = E_rt;	//���ĵļĴ���2��ַ
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
					//���ĵļĴ���
					CareGFadd1_E = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_E = 5'b0;	//���ĵļĴ���2��ַ
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
					//���ĵļĴ���
					CareGFadd1_E = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_E = 5'b0;	//���ĵļĴ���2��ַ
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
					//���ĵļĴ���
					CareGFadd1_E = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_E = 5'b0;	//���ĵļĴ���2��ַ
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
					//���ĵļĴ���
					CareGFadd1_E = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_E = 5'b0;	//���ĵļĴ���2��ַ
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
					//���ĵļĴ���
					CareGFadd1_E = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_E = 5'b0;	//���ĵļĴ���2��ַ
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
					//���ĵļĴ���
					CareGFadd1_E = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_E = 5'b0;	//���ĵļĴ���2��ַ
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
					//���ĵļĴ���
					CareGFadd1_E = E_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_E = E_rt;	//���ĵļĴ���2��ַ
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
					//���ĵļĴ���
					CareGFadd1_E = E_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_E = 5'b0;	//���ĵļĴ���2��ַ
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
					//���ĵļĴ���
					CareGFadd1_E = E_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_E = E_rt;	//���ĵļĴ���2��ַ
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
					//���ĵļĴ���
					CareGFadd1_E = E_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_E = 5'b0;	//���ĵļĴ���2��ַ
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
					//���ĵļĴ���
					CareGFadd1_E = E_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_E = 5'b0;	//���ĵļĴ���2��ַ
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
					//���ĵļĴ���
					CareGFadd1_E = E_rs;	//���ĵļĴ���1��ַ
					CareGFadd2_E = 5'b0;	//���ĵļĴ���2��ַ
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
					//���ĵļĴ���
					CareGFadd1_E = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_E = 5'b0;	//���ĵļĴ���2��ַ
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
	
	//�� -> datapath����
	ALUopcode		= E_ALUopcode_in;

	//�� -> EX/MEM����
	E_Instr_out 	= E_Instr_in;
	E_PC_out 		= E_PC_in;
	E_ALUresult_out= ALUresult;
	
end

//���� ��	ALU -> ���ݴ洢��
always @(*) begin
	//�� -> datapath����
	readDMadd		= M_ALUresult_in;
	case(M_Instrlist)
			`Addu:
				begin
					//���ĵļĴ���
					CareGFadd1_M = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_M = 5'b0;	//���ĵļĴ���2��ַ

					
					
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
					//���ĵļĴ���
					CareGFadd1_M = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_M = 5'b0;	//���ĵļĴ���2��ַ

					
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
					//���ĵļĴ���
					CareGFadd1_M = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_M = 5'b0;	//���ĵļĴ���2��ַ

					
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
					//���ĵļĴ���
					CareGFadd1_M = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_M = 5'b0;	//���ĵļĴ���2��ַ

					
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
					//���ĵļĴ���
					CareGFadd1_M = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_M = 5'b0;	//���ĵļĴ���2��ַ

					
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
					//���ĵļĴ���
					CareGFadd1_M = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_M = M_rt;	//���ĵļĴ���2��ַ

					
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
					//���ĵļĴ���
					CareGFadd1_M = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_M = 5'b0;	//���ĵļĴ���2��ַ

					
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
					//���ĵļĴ���
					CareGFadd1_M = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_M = 5'b0;	//���ĵļĴ���2��ַ

					
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
					//���ĵļĴ���
					CareGFadd1_M = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_M = 5'b0;	//���ĵļĴ���2��ַ

					
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
					//���ĵļĴ���
					CareGFadd1_M = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_M = 5'b0;	//���ĵļĴ���2��ַ

					
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
					//���ĵļĴ���
					CareGFadd1_M = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_M = 5'b0;	//���ĵļĴ���2��ַ

					
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
					//���ĵļĴ���
					CareGFadd1_M = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_M = 5'b0;	//���ĵļĴ���2��ַ

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= M_WEDM_in;
					
					M_add_write  = (M_WEGF_in) ? 5'b11111 : 5'd0; //Ĭ�ϵ���תʱд��
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Cal:
				begin
					//���ĵļĴ���
					CareGFadd1_M = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_M = 5'b0;	//���ĵļĴ���2��ַ

					
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
					//���ĵļĴ���
					CareGFadd1_M = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_M = 5'b0;	//���ĵļĴ���2��ַ

					
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
					//���ĵļĴ���
					CareGFadd1_M = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_M = M_rt;	//���ĵļĴ���2��ַ

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
					//���ĵļĴ���
					CareGFadd1_M = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_M = 5'b0;	//���ĵļĴ���2��ַ

					
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
					//���ĵļĴ���
					CareGFadd1_M = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_M = 5'b0;	//���ĵļĴ���2��ַ

					
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
					//���ĵļĴ���
					CareGFadd1_M = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_M = 5'b0;	//���ĵļĴ���2��ַ

					
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
					//���ĵļĴ���
					CareGFadd1_M = 5'b0;	//���ĵļĴ���1��ַ
					CareGFadd2_M = 5'b0;	//���ĵļĴ���2��ַ

					
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
	//�� -> MEM/WB����
	M_Instr_out		= M_Instr_in;
	M_PC_out			= M_PC_in;
	M_ALUresult_out= M_ALUresult_in;
	
end

//���� �� ���ݴ洢�� -> д�Ĵ���
always @(*) begin

//	output reg [31:0] W_Instr_in,
//	output reg [31:0] W_PC_in,
//	output reg [31:0] W_ALUresult_in,
//	output reg [31:0] W_DMdata_in,
//	output reg W_WEGF_in
	
	//�� -> datapath����
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
					
					W_add_write  = (W_WEGF_in) ? 5'b11111 : 5'd0; //Ĭ�ϵ���תʱд��
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