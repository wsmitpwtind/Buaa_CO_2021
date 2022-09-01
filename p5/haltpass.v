`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:40:04 11/22/2021 
// Design Name: 
// Module Name:    haltpass 
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
module haltpass(
	input clk,
	input reset,
	
	input [31:0] D_Instr,
	input [31:0] E_Instr,
	input [31:0] M_Instr,
	input [31:0] W_Instr,
	
	//��ͼд��ĵ�ַ
	input [4:0]	 E_add_write,
	input [4:0]	 M_add_write,
	input [4:0]	 W_add_write,
	//���ܵĵ�ַ
	input [4:0]  E_add_write_plus,
	input [4:0]  M_add_write_plus,
	
	//��Щ��ַ��дʹ��
	input E_write_we,
	input M_write_we,
	input W_write_we,
	
	//��ͼд������ͣ�1Ϊ��DM��0Ϊ��alu
	input E_type_write,
	input M_type_write,
	input W_type_write,
	
	//���ܵ���·
	input [31:0] M_ALUresult,
	input [31:0] W_ALUresult,
	input [31:0] W_DMread,
	
	//���ĵĵ�ַ,������ת��������
	input [4:0]	Careadd1_D,
	input [4:0]	Careadd2_D,
	input	[31:0] askdata1_D,
	input	[31:0] askdata2_D,
	
	input [4:0]	Careadd1_E,
	input [4:0]	Careadd2_E,
	input	[31:0] askdata1_E,
	input	[31:0] askdata2_E,
	
	input [4:0]	Careadd1_M,
	input [4:0]	Careadd2_M,
	input	[31:0] askdata1_M,
	input	[31:0] askdata2_M,
	
	//��Щ��ַ��ʵֵ
	output reg [31:0] GFadd1_D,
	output reg [31:0] GFadd2_D,
	
	output reg [31:0] GFadd1_E,
	output reg [31:0] GFadd2_E,
	
	output reg [31:0] GFadd1_M,
	output reg [31:0] GFadd2_M,
	
	//�Ƿ񶳽�
	output freeze
	
	
    );
	 
	//�����붨��
	//ͬ���޸�control
	wire [5:0]D_op, D_func, E_op, E_func, M_op, M_func, W_op, W_func;
	wire [4:0]D_rs, E_rs, M_rs, W_rs, D_rt, E_rt, M_rt, W_rt, D_rd, E_rd, M_rd, W_rd;
	
	
	assign D_op 	= D_Instr[31:26];
	assign D_func 	= D_Instr[5:0];
	assign D_rs		= D_Instr[25:21];
	assign D_rt		= D_Instr[20:16];
	assign D_rd		= D_Instr[15:11];
	
	assign E_op 	= E_Instr[31:26];
	assign E_func 	= E_Instr[5:0];
	assign E_rs		= E_Instr[25:21];
	assign E_rt		= E_Instr[20:16];
	assign E_rd		= E_Instr[15:11];
	
	assign M_op 	= M_Instr[31:26];
	assign M_func 	= M_Instr[5:0];
	assign M_rs		= M_Instr[25:21];
	assign M_rt		= M_Instr[20:16];
	assign M_rd		= M_Instr[15:11];
	
	assign W_op 	= W_Instr[31:26];
	assign W_func 	= W_Instr[5:0];
	assign W_rs		= W_Instr[25:21];
	assign W_rt		= W_Instr[20:16];
	assign W_rd		= W_Instr[15:11];
	
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
	
	 //����
	assign D_bal	= (D_op == 6'b000001);
	assign E_bal	= (E_op == 6'b000001);
	assign M_bal	= (M_op == 6'b000001);
	assign W_bal	= (W_op == 6'b000001);
	
	 //��xorΪ��
	assign D_cal 	= (D_op == 6'b000000)&(D_func == 6'b100110);
	assign E_cal 	= (E_op == 6'b000000)&(E_func == 6'b100110);
	assign M_cal 	= (M_op == 6'b000000)&(M_func == 6'b100110);
	assign W_cal 	= (W_op == 6'b000000)&(W_func == 6'b100110);
									//��xoriΪ��
	assign D_cai 	= (D_op == 6'b001110);
	assign E_cai 	= (E_op == 6'b001110);
	assign M_cai 	= (M_op == 6'b001110);
	assign W_cai 	= (W_op == 6'b001110);
									//opcodeϹ���
	assign D_lr 	= (D_op == 6'b111111);
	assign E_lr 	= (E_op == 6'b111111);
	assign M_lr 	= (M_op == 6'b111111);
	assign W_lr 	= (W_op == 6'b111111);
	
							//opcodeϹ���
	assign D_lr1 	= (D_op == 6'b011111);
	assign E_lr1 	= (E_op == 6'b011111);
	assign M_lr1 	= (M_op == 6'b011111);
	assign W_lr1 	= (W_op == 6'b011111);
	
								//opcodeϹ���
	assign D_lr2 	= (D_op == 6'b101111);
	assign E_lr2 	= (E_op == 6'b101111);
	assign M_lr2 	= (M_op == 6'b101111);
	assign W_lr2 	= (W_op == 6'b101111);
	
								//opcodeϹ���
	assign D_lr3 	= (D_op == 6'b001100);
	assign E_lr3 	= (E_op == 6'b001100);
	assign M_lr3 	= (M_op == 6'b001100);
	assign W_lr3 	= (W_op == 6'b001100);
	
	assign D_addi 	= (D_op == 6'b001000);
	assign E_addi 	= (E_op == 6'b001000);
	assign M_addi 	= (M_op == 6'b001000);
	assign W_addi 	= (W_op == 6'b001000);
	
	assign D_jalr 	= (D_op == 6'b000000)&(D_func == 6'b001001);
	assign E_jalr 	= (E_op == 6'b000000)&(E_func == 6'b001001);
	assign M_jalr 	= (M_op == 6'b000000)&(M_func == 6'b001001);
	assign W_jalr 	= (W_op == 6'b000000)&(W_func == 6'b001001);
	
	//D������
	assign D_care1 = (D_beq | D_jr | D_bal | D_jalr);
	assign D_care2 = (D_beq | D_bal);
	
	//E������
	assign E_care1 = (D_addu | D_subu | D_cal | D_cai | D_ori | D_lw | D_sw | D_lr | D_lr1 | D_lr2 | D_addi);
	assign E_care2 = (D_addu | D_subu | D_cal);
	
	//M������
	assign M_care1 = 1'b0;
	assign M_care2 = (D_sw | D_lr);
	
	
	//����д�Ķ��ᶨ�����£�
	//1.ȷ����д���ַ������ȷ��д��ʱ we��0-1��������ʹ�øüĴ�������������lr1��
	//2.��ȷ��д���ַ����֪Ϊrt��rs����ȷ�ϵ�ַʱ��we��0-1����add_writeΪ��ʵ��add_write_plusΪ0 ������lr2��
	//3.��ȷ��д���ַ����֪����ALU�����޸�ALU���ɣ�ͬ�ϣ���������һ�� (needgrf_D & (E_XXX)) | ������lr3��
	//4.��ȷ��д���ַ����֪����DM�����޸�ALU���ɣ�ͬ�ϣ������������� ������lr��
	//ע��1��2��3��4 ����Ϊ��δ֪ д���ַ/�Ƿ�д�� ʱweΪ0
	
	
	//������Ҫ�Ĵ���
	assign needgrf_D = (D_beq | D_jr | D_bal | D_jalr | D_addu | D_subu | D_cal | D_cai | D_ori | D_lw | D_sw | D_lr | D_lr1 | D_lr2 | D_addi);
	assign needgrf_E = (E_beq | E_jr | E_bal | E_jalr | E_addu | E_subu | E_cal | E_cai | E_ori | E_lw | E_sw | E_lr | E_lr1 | E_lr2 | E_addi);
	assign needgrf_M = (M_beq | M_jr | M_bal | M_jalr | M_addu | M_subu | M_cal | M_cai | M_ori | M_lw | M_sw | M_lr | M_lr1 | M_lr2 | M_addi);
	
	assign freeze = (needgrf_D & (E_lr | M_lr)) |
						 (needgrf_E & (	    M_lr)) |
						 (D_care1 & ((E_add_write == Careadd1_D) | (E_add_write_plus == Careadd1_D)) & (Careadd1_D != 0)) |
						 (D_care2 & ((E_add_write == Careadd2_D) | (E_add_write_plus == Careadd2_D)) & (Careadd2_D != 0)) |
						 (D_care1 & ((M_add_write == Careadd1_D) | (M_add_write_plus == Careadd1_D)) & (Careadd1_D != 0) & M_type_write) |
						 (D_care2 & ((M_add_write == Careadd2_D) | (M_add_write_plus == Careadd2_D)) & (Careadd2_D != 0) & M_type_write) |
						 (E_care1 & ((E_add_write == Careadd1_D) | (E_add_write_plus == Careadd1_D)) & (Careadd1_D != 0) & E_type_write) |
						 (E_care2 & ((E_add_write == Careadd2_D) | (E_add_write_plus == Careadd2_D)) & (Careadd2_D != 0) & E_type_write);
						 
	always @(*)
		begin
			GFadd1_M = (((W_add_write == Careadd1_M)) &  (W_type_write) & (Careadd1_M != 0) & W_write_we) ?  W_DMread	  	: askdata1_M;
			GFadd2_M = (((W_add_write == Careadd2_M)) &  (W_type_write) & (Careadd2_M != 0) & W_write_we) ?  W_DMread	  	: askdata2_M;
			GFadd1_E = (((M_add_write == Careadd1_E) | (M_add_write_plus == Careadd1_E)) & (!M_type_write) & (Careadd1_E != 0) & M_write_we) ?  M_ALUresult  :
						  (((W_add_write == Careadd1_E)) &  (W_type_write) & (Careadd1_E != 0) & W_write_we) ?  W_DMread	  	: askdata1_E;
			GFadd2_E = (((M_add_write == Careadd2_E) | (M_add_write_plus == Careadd2_E)) & (!M_type_write) & (Careadd2_E != 0) & M_write_we) ?  M_ALUresult  :
						  (((W_add_write == Careadd2_E)) &  (W_type_write) & (Careadd2_E != 0) & W_write_we) ?  W_DMread	  	: askdata2_E;
			GFadd1_D = (((M_add_write == Careadd1_D) | (M_add_write_plus == Careadd1_D)) & (!M_type_write) & (Careadd1_D != 0) & M_write_we) ?  M_ALUresult  :
						  (((W_add_write == Careadd1_D)) & (!W_type_write) & (Careadd1_D != 0) & W_write_we) ?  W_ALUresult  :
						  (((W_add_write == Careadd1_D)) &  (W_type_write) & (Careadd1_D != 0) & W_write_we) ?  W_DMread	  	: askdata1_D;
			GFadd2_D = (((M_add_write == Careadd2_D) | (M_add_write_plus == Careadd2_D)) & (!M_type_write) & (Careadd2_D != 0) & M_write_we) ?  M_ALUresult  :
						  (((W_add_write == Careadd2_D)) & (!W_type_write) & (Careadd2_D != 0) & W_write_we) ?  W_ALUresult  :
						  (((W_add_write == Careadd2_D)) &  (W_type_write) & (Careadd2_D != 0) & W_write_we) ?  W_DMread	  	: askdata2_D;
		end
		
endmodule
