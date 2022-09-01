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
	
	//试图写入的地址
	input [4:0]	 E_add_write,
	input [4:0]	 M_add_write,
	input [4:0]	 W_add_write,
	//可能的地址
	input [4:0]  E_add_write_plus,
	input [4:0]  M_add_write_plus,
	
	//这些地址的写使能
	input E_write_we,
	input M_write_we,
	input W_write_we,
	
	//试图写入的类型，1为从DM，0为从alu
	input E_type_write,
	input M_type_write,
	input W_type_write,
	
	//可能的旁路
	input [31:0] M_ALUresult,
	input [31:0] W_ALUresult,
	input [31:0] W_DMread,
	
	//关心的地址,和若非转发的数据
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
	
	//这些地址真实值
	output reg [31:0] GFadd1_D,
	output reg [31:0] GFadd2_D,
	
	output reg [31:0] GFadd1_E,
	output reg [31:0] GFadd2_E,
	
	output reg [31:0] GFadd1_M,
	output reg [31:0] GFadd2_M,
	
	//是否冻结
	input MDU_busy,
	
	output freeze
	
	
    );
	 
	//以下内容复制4份！！！！！！
	//支持指令
	//三目ALU
	wire D_addu, D_subu, D_add, D_sub, D_and, D_or, D_xor, D_nor, D_slt, D_sltu, D_sll, D_srl, D_sra, D_sllv, D_srlv, D_srav, D_cal;
	wire E_addu, E_subu, E_add, E_sub, E_and, E_or, E_xor, E_nor, E_slt, E_sltu, E_sll, E_srl, E_sra, E_sllv, E_srlv, E_srav, E_cal;
	wire M_addu, M_subu, M_add, M_sub, M_and, M_or, M_xor, M_nor, M_slt, M_sltu, M_sll, M_srl, M_sra, M_sllv, M_srlv, M_srav, M_cal;
	wire W_addu, W_subu, W_add, W_sub, W_and, W_or, W_xor, W_nor, W_slt, W_sltu, W_sll, W_srl, W_sra, W_sllv, W_srlv, W_srav, W_cal;
	//立即数ALU
	wire D_lui, D_addi, D_addiu, D_andi, D_ori, D_xori, D_slti, D_sltiu, D_cai;
	wire E_lui, E_addi, E_addiu, E_andi, E_ori, E_xori, E_slti, E_sltiu, E_cai;
	wire M_lui, M_addi, M_addiu, M_andi, M_ori, M_xori, M_slti, M_sltiu, M_cai;
	wire W_lui, W_addi, W_addiu, W_andi, W_ori, W_xori, W_slti, W_sltiu, W_cai;
	//跳转
	wire D_beq, D_bne, D_blez, D_bgtz, D_bltz, D_bgez, D_jal, D_jr, D_j, D_jalr;
	wire E_beq, E_bne, E_blez, E_bgtz, E_bltz, E_bgez, E_jal, E_jr, E_j, E_jalr;
	wire M_beq, M_bne, M_blez, M_bgtz, M_bltz, M_bgez, M_jal, M_jr, M_j, M_jalr;
	wire W_beq, W_bne, W_blez, W_bgtz, W_bltz, W_bgez, W_jal, W_jr, W_j, W_jalr;
	//Load
	wire D_lw, D_lb, D_lbu, D_lh, D_lhu, D_lr, D_lr1;
	wire E_lw, E_lb, E_lbu, E_lh, E_lhu, E_lr, E_lr1;
	wire M_lw, M_lb, M_lbu, M_lh, M_lhu, M_lr, M_lr1;
	wire W_lw, W_lb, W_lbu, W_lh, W_lhu, W_lr, W_lr1;
	//Store
	wire D_sw, D_sb, D_sh, D_sr;
	wire E_sw, E_sb, E_sh, E_sr;
	wire M_sw, M_sb, M_sh, M_sr;
	wire W_sw, W_sb, W_sh, W_sr;
	//MDU乘除
	wire D_MULT, D_MULTU, D_DIV, D_DIVU, D_MFHI, D_MFLO, D_MTHI, D_MTLO, D_Mr;
	wire E_MULT, E_MULTU, E_DIV, E_DIVU, E_MFHI, E_MFLO, E_MTHI, E_MTLO, E_Mr;
	wire M_MULT, M_MULTU, M_DIV, M_DIVU, M_MFHI, M_MFLO, M_MTHI, M_MTLO, M_Mr;
	wire W_MULT, W_MULTU, W_DIV, W_DIVU, W_MFHI, W_MFLO, W_MTHI, W_MTLO, W_Mr;
	//其余
	wire D_nop;
	wire E_nop;
	wire M_nop;
	wire W_nop;
	
	
	//走线与定义
	//同步修改control
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
	
	//以下内容复制5份！！！！！！
	//指令描述
	//三目ALU
	assign D_addu 	= (D_op == 6'b000000)&(D_func == 6'b100001);
	assign D_subu 	= (D_op == 6'b000000)&(D_func == 6'b100011);
	assign D_add 	= (D_op == 6'b000000)&(D_func == 6'b100000);
	assign D_sub 	= (D_op == 6'b000000)&(D_func == 6'b100010);
	assign D_and 	= (D_op == 6'b000000)&(D_func == 6'b100100);
	assign D_or 	= (D_op == 6'b000000)&(D_func == 6'b100101);
	assign D_xor 	= (D_op == 6'b000000)&(D_func == 6'b100110);
	assign D_nor 	= (D_op == 6'b000000)&(D_func == 6'b100111);
	assign D_slt 	= (D_op == 6'b000000)&(D_func == 6'b101010);
	assign D_sltu 	= (D_op == 6'b000000)&(D_func == 6'b101011);
	assign D_sll	= (D_op == 6'b000000)&(D_func == 6'b000000);
	assign D_srl	= (D_op == 6'b000000)&(D_func == 6'b000010);
	assign D_sra	= (D_op == 6'b000000)&(D_func == 6'b000011);
	assign D_sllv	= (D_op == 6'b000000)&(D_func == 6'b000100);
	assign D_srlv	= (D_op == 6'b000000)&(D_func == 6'b000110);
	assign D_srav	= (D_op == 6'b000000)&(D_func == 6'b000111);
	
	assign E_addu 	= (E_op == 6'b000000)&(E_func == 6'b100001);
	assign E_subu 	= (E_op == 6'b000000)&(E_func == 6'b100011);
	assign E_add 	= (E_op == 6'b000000)&(E_func == 6'b100000);
	assign E_sub 	= (E_op == 6'b000000)&(E_func == 6'b100010);
	assign E_and 	= (E_op == 6'b000000)&(E_func == 6'b100100);
	assign E_or 	= (E_op == 6'b000000)&(E_func == 6'b100101);
	assign E_xor 	= (E_op == 6'b000000)&(E_func == 6'b100110);
	assign E_nor 	= (E_op == 6'b000000)&(E_func == 6'b100111);
	assign E_slt 	= (E_op == 6'b000000)&(E_func == 6'b101010);
	assign E_sltu 	= (E_op == 6'b000000)&(E_func == 6'b101011);
	assign E_sll	= (E_op == 6'b000000)&(E_func == 6'b000000);
	assign E_srl	= (E_op == 6'b000000)&(E_func == 6'b000010);
	assign E_sra	= (E_op == 6'b000000)&(E_func == 6'b000011);
	assign E_sllv	= (E_op == 6'b000000)&(E_func == 6'b000100);
	assign E_srlv	= (E_op == 6'b000000)&(E_func == 6'b000110);
	assign E_srav	= (E_op == 6'b000000)&(E_func == 6'b000111);
	
	assign M_addu 	= (M_op == 6'b000000)&(M_func == 6'b100001);
	assign M_subu 	= (M_op == 6'b000000)&(M_func == 6'b100011);
	assign M_add 	= (M_op == 6'b000000)&(M_func == 6'b100000);
	assign M_sub 	= (M_op == 6'b000000)&(M_func == 6'b100010);
	assign M_and 	= (M_op == 6'b000000)&(M_func == 6'b100100);
	assign M_or 	= (M_op == 6'b000000)&(M_func == 6'b100101);
	assign M_xor 	= (M_op == 6'b000000)&(M_func == 6'b100110);
	assign M_nor 	= (M_op == 6'b000000)&(M_func == 6'b100111);
	assign M_slt 	= (M_op == 6'b000000)&(M_func == 6'b101010);
	assign M_sltu 	= (M_op == 6'b000000)&(M_func == 6'b101011);
	assign M_sll	= (M_op == 6'b000000)&(M_func == 6'b000000);
	assign M_srl	= (M_op == 6'b000000)&(M_func == 6'b000010);
	assign M_sra	= (M_op == 6'b000000)&(M_func == 6'b000011);
	assign M_sllv	= (M_op == 6'b000000)&(M_func == 6'b000100);
	assign M_srlv	= (M_op == 6'b000000)&(M_func == 6'b000110);
	assign M_srav	= (M_op == 6'b000000)&(M_func == 6'b000111);
	
	assign W_addu 	= (W_op == 6'b000000)&(W_func == 6'b100001);
	assign W_subu 	= (W_op == 6'b000000)&(W_func == 6'b100011);
	assign W_add 	= (W_op == 6'b000000)&(W_func == 6'b100000);
	assign W_sub 	= (W_op == 6'b000000)&(W_func == 6'b100010);
	assign W_and 	= (W_op == 6'b000000)&(W_func == 6'b100100);
	assign W_or 	= (W_op == 6'b000000)&(W_func == 6'b100101);
	assign W_xor 	= (W_op == 6'b000000)&(W_func == 6'b100110);
	assign W_nor 	= (W_op == 6'b000000)&(W_func == 6'b100111);
	assign W_slt 	= (W_op == 6'b000000)&(W_func == 6'b101010);
	assign W_sltu 	= (W_op == 6'b000000)&(W_func == 6'b101011);
	assign W_sll	= (W_op == 6'b000000)&(W_func == 6'b000000);
	assign W_srl	= (W_op == 6'b000000)&(W_func == 6'b000010);
	assign W_sra	= (W_op == 6'b000000)&(W_func == 6'b000011);
	assign W_sllv	= (W_op == 6'b000000)&(W_func == 6'b000100);
	assign W_srlv	= (W_op == 6'b000000)&(W_func == 6'b000110);
	assign W_srav	= (W_op == 6'b000000)&(W_func == 6'b000111);
	
	//立即数ALU
	assign D_lui 	= (D_op == 6'b001111);
	assign D_addi	= (D_op == 6'b001000);
	assign D_addiu	= (D_op == 6'b001001);
	assign D_andi	= (D_op == 6'b001100);
	assign D_ori 	= (D_op == 6'b001101);
	assign D_xori 	= (D_op == 6'b001110);
	assign D_slti 	= (D_op == 6'b001010);
	assign D_sltiu = (D_op == 6'b001011);
	
	assign E_lui 	= (E_op == 6'b001111);
	assign E_addi	= (E_op == 6'b001000);
	assign E_addiu	= (E_op == 6'b001001);
	assign E_andi	= (E_op == 6'b001100);
	assign E_ori 	= (E_op == 6'b001101);
	assign E_xori 	= (E_op == 6'b001110);
	assign E_slti 	= (E_op == 6'b001010);
	assign E_sltiu = (E_op == 6'b001011);
	
	assign M_lui 	= (M_op == 6'b001111);
	assign M_addi	= (M_op == 6'b001000);
	assign M_addiu	= (M_op == 6'b001001);
	assign M_andi	= (M_op == 6'b001100);
	assign M_ori 	= (M_op == 6'b001101);
	assign M_xori 	= (M_op == 6'b001110);
	assign M_slti 	= (M_op == 6'b001010);
	assign M_sltiu = (M_op == 6'b001011);
	
	assign W_lui 	= (W_op == 6'b001111);
	assign W_Addi	= (W_op == 6'b001000);
	assign W_Addiu	= (W_op == 6'b001001);
	assign W_Andi	= (W_op == 6'b001100);
	assign W_ori 	= (W_op == 6'b001101);
	assign W_xori 	= (W_op == 6'b001110);
	assign W_slti 	= (W_op == 6'b001010);
	assign W_sltiu = (W_op == 6'b001011);
	//跳转
	assign D_beq 	= (D_op == 6'b000100);
	assign D_bne 	= (D_op == 6'b000101);
	assign D_blez 	= (D_op == 6'b000110);
	assign D_bgtz 	= (D_op == 6'b000111);
	assign D_bltz 	= (D_op == 6'b000001)&(D_rt	== 5'b00000);
	assign D_bgez 	= (D_op == 6'b000001)&(D_rt	== 5'b00001);
	assign D_jal 	= (D_op == 6'b000011);
	assign D_jr 	= (D_op == 6'b000000)&(D_func == 6'b001000);
	assign D_j 		= (D_op == 6'b000010);
	assign D_jalr 	= (D_op == 6'b000000)&(D_func == 6'b001001);
	
	assign E_beq 	= (E_op == 6'b000100);
	assign E_bne 	= (E_op == 6'b000101);
	assign E_blez 	= (E_op == 6'b000110);
	assign E_bgtz 	= (E_op == 6'b000111);
	assign E_bltz 	= (E_op == 6'b000001)&(E_rt	== 5'b00000);
	assign E_bgez 	= (E_op == 6'b000001)&(E_rt	== 5'b00001);
	assign E_jal 	= (E_op == 6'b000011);
	assign E_jr 	= (E_op == 6'b000000)&(E_func == 6'b001000);
	assign E_j 		= (E_op == 6'b000010);
	assign E_jalr 	= (E_op == 6'b000000)&(E_func == 6'b001001);
	
	assign M_beq 	= (M_op == 6'b000100);
	assign M_bne 	= (M_op == 6'b000101);
	assign M_blez 	= (M_op == 6'b000110);
	assign M_bgtz 	= (M_op == 6'b000111);
	assign M_bltz 	= (M_op == 6'b000001)&(M_rt	== 5'b00000);
	assign M_bgez 	= (M_op == 6'b000001)&(M_rt	== 5'b00001);
	assign M_jal 	= (M_op == 6'b000011);
	assign M_jr 	= (M_op == 6'b000000)&(M_func == 6'b001000);
	assign M_j 		= (M_op == 6'b000010);
	assign M_jalr 	= (M_op == 6'b000000)&(M_func == 6'b001001);
	
	assign W_beq 	= (W_op == 6'b000100);
	assign W_bne 	= (W_op == 6'b000101);
	assign W_blez 	= (W_op == 6'b000110);
	assign W_bgtz 	= (W_op == 6'b000111);
	assign W_bltz 	= (W_op == 6'b000001)&(W_rt	== 5'b00000);
	assign W_bgez 	= (W_op == 6'b000001)&(W_rt	== 5'b00001);
	assign W_jal 	= (W_op == 6'b000011);
	assign W_jr 	= (W_op == 6'b000000)&(W_func == 6'b001000);
	assign W_j 		= (W_op == 6'b000010);
	assign W_jalr 	= (W_op == 6'b000000)&(W_func == 6'b001001);
	//Load
	assign D_lw 	= (D_op == 6'b100011);
	assign D_lb 	= (D_op == 6'b100000);
	assign D_lbu 	= (D_op == 6'b100100);
	assign D_lh 	= (D_op == 6'b100001);
	assign D_lhu 	= (D_op == 6'b100101);
	
	assign E_lw 	= (E_op == 6'b100011);
	assign E_lb 	= (E_op == 6'b100000);
	assign E_lbu 	= (E_op == 6'b100100);
	assign E_lh 	= (E_op == 6'b100001);
	assign E_lhu 	= (E_op == 6'b100101);
	
	assign M_lw 	= (M_op == 6'b100011);
	assign M_lb 	= (M_op == 6'b100000);
	assign M_lbu 	= (M_op == 6'b100100);
	assign M_lh 	= (M_op == 6'b100001);
	assign M_lhu 	= (M_op == 6'b100101);
	
	assign W_lw 	= (W_op == 6'b100011);
	assign W_lb 	= (W_op == 6'b100000);
	assign W_lbu 	= (W_op == 6'b100100);
	assign W_lh 	= (W_op == 6'b100001);
	assign W_lhu 	= (W_op == 6'b100101);
	
	//Store
	assign D_sw 	= (D_op == 6'b101011);
	assign D_sb 	= (D_op == 6'b101000);
	assign D_sh 	= (D_op == 6'b101001);
	
	assign E_sw 	= (E_op == 6'b101011);
	assign E_sb 	= (E_op == 6'b101000);
	assign E_sh 	= (E_op == 6'b101001);
	
	assign M_sw 	= (M_op == 6'b101011);
	assign M_sb 	= (M_op == 6'b101000);
	assign M_sh 	= (M_op == 6'b101001);
	
	assign W_sw 	= (W_op == 6'b101011);
	assign W_sb 	= (W_op == 6'b101000);
	assign W_sh 	= (W_op == 6'b101001);
	
	//MDU乘除
	assign D_MULT	= (D_op == 6'b000000)&(D_func == 6'b011000);
	assign D_MULTU	= (D_op == 6'b000000)&(D_func == 6'b011001);
	assign D_DIV	= (D_op == 6'b000000)&(D_func == 6'b011010);
	assign D_DIVU	= (D_op == 6'b000000)&(D_func == 6'b011011);
	assign D_MFHI	= (D_op == 6'b000000)&(D_func == 6'b010000);
	assign D_MFLO	= (D_op == 6'b000000)&(D_func == 6'b010010);
	assign D_MTHI	= (D_op == 6'b000000)&(D_func == 6'b010001);
	assign D_MTLO	= (D_op == 6'b000000)&(D_func == 6'b010011);
	assign E_MULT	= (E_op == 6'b000000)&(E_func == 6'b011000);
	assign E_MULTU	= (E_op == 6'b000000)&(E_func == 6'b011001);
	assign E_DIV	= (E_op == 6'b000000)&(E_func == 6'b011010);
	assign E_DIVU	= (E_op == 6'b000000)&(E_func == 6'b011011);
	assign E_MFHI	= (E_op == 6'b000000)&(E_func == 6'b010000);
	assign E_MFLO	= (E_op == 6'b000000)&(E_func == 6'b010010);
	assign E_MTHI	= (E_op == 6'b000000)&(E_func == 6'b010001);
	assign E_MTLO	= (E_op == 6'b000000)&(E_func == 6'b010011);
	assign M_MULT	= (M_op == 6'b000000)&(M_func == 6'b011000);
	assign M_MULTU	= (M_op == 6'b000000)&(M_func == 6'b011001);
	assign M_DIV	= (M_op == 6'b000000)&(M_func == 6'b011010);
	assign M_DIVU	= (M_op == 6'b000000)&(M_func == 6'b011011);
	assign M_MFHI	= (M_op == 6'b000000)&(M_func == 6'b010000);
	assign M_MFLO	= (M_op == 6'b000000)&(M_func == 6'b010010);
	assign M_MTHI	= (M_op == 6'b000000)&(M_func == 6'b010001);
	assign M_MTLO	= (M_op == 6'b000000)&(M_func == 6'b010011);
	assign W_MULT	= (W_op == 6'b000000)&(W_func == 6'b011000);
	assign W_MULTU	= (W_op == 6'b000000)&(W_func == 6'b011001);
	assign W_DIV	= (W_op == 6'b000000)&(W_func == 6'b011010);
	assign W_DIVU	= (W_op == 6'b000000)&(W_func == 6'b011011);
	assign W_MFHI	= (W_op == 6'b000000)&(W_func == 6'b010000);
	assign W_MFLO	= (W_op == 6'b000000)&(W_func == 6'b010010);
	assign W_MTHI	= (W_op == 6'b000000)&(W_func == 6'b010001);
	assign W_MTLO	= (W_op == 6'b000000)&(W_func == 6'b010011);
	//其他
	assign D_nop	= (D_op == 6'b000000)&(D_func == 6'b000000);
	assign E_nop	= (E_op == 6'b000000)&(E_func == 6'b000000);
	assign M_nop	= (M_op == 6'b000000)&(M_func == 6'b000000);
	assign W_nop	= (W_op == 6'b000000)&(W_func == 6'b000000);


	 //待定指令及其opcode如下
	assign D_cal 	= (D_op == 6'b000000)&(D_func == 6'b101100);
	assign E_cal 	= (E_op == 6'b000000)&(E_func == 6'b101100);
	assign M_cal 	= (M_op == 6'b000000)&(M_func == 6'b101100);
	assign W_cal 	= (W_op == 6'b000000)&(W_func == 6'b101100);
	
	assign D_cai 	= (D_op == 6'b110101);
	assign E_cai 	= (E_op == 6'b110101);
	assign M_cai 	= (M_op == 6'b110101);
	assign W_cai 	= (W_op == 6'b110101);
	
	assign D_bal	= (D_op == 6'b100110);
	assign E_bal	= (E_op == 6'b100110);
	assign M_bal	= (M_op == 6'b100110);
	assign W_bal	= (W_op == 6'b100110);
	
	assign D_lr 	= (D_op == 6'b101101);
	assign E_lr 	= (E_op == 6'b101101);
	assign M_lr 	= (M_op == 6'b101101);
	assign W_lr 	= (W_op == 6'b101101);

	assign D_lr1 	= (D_op == 6'b010101);
	assign E_lr1 	= (E_op == 6'b010101);
	assign M_lr1 	= (M_op == 6'b010101);
	assign W_lr1 	= (W_op == 6'b010101);

	assign D_sr 	= (D_op == 6'b111101);
	assign E_sr 	= (E_op == 6'b111101);
	assign M_sr 	= (M_op == 6'b111101);
	assign W_sr 	= (W_op == 6'b111101);

	assign D_Mr 	= (D_op == 6'b000000)&(D_func == 6'b101101);
	assign E_Mr 	= (E_op == 6'b000000)&(E_func == 6'b101101);
	assign M_Mr 	= (M_op == 6'b000000)&(M_func == 6'b101101);
	assign W_Mr 	= (W_op == 6'b000000)&(W_func == 6'b101101);
	
	

	//D级需求
	assign D_care1 = (D_beq | D_bne | D_blez| D_bgtz | D_bltz | D_bgez | D_jr | D_jalr );
	assign D_care2 = (D_beq | D_bne );
	
	//E级需求
	assign E_care1 = (D_addu | D_subu | D_add | D_sub | D_and | D_or | D_xor | D_nor | D_slt | D_sltu | D_sllv | D_srlv | D_srav | D_cal | 
							D_addi | D_addiu | D_andi | D_ori | D_xori | D_slti | D_sltiu | D_cai |
							D_lw | D_lb | D_lbu | D_lh | D_lhu | D_lr | D_lr1 | 
							D_sw | D_sb | D_sh | D_sr |
							D_MULT | D_MULTU | D_DIV | D_DIVU | D_MTHI | D_MTLO | D_bal
							);
	assign E_care2 = (D_addu | D_subu | D_add | D_sub | D_and | D_or | D_xor | D_nor | D_slt | D_sltu | D_sll | D_srl | D_sra | D_sllv | D_srlv | D_srav | D_cal | 
							D_MULT | D_MULTU | D_DIV | D_DIVU 
							);
	
	//M级需求
	assign M_care1 = 1'b0;
	assign M_care2 = (D_sw | D_sb | D_sh | D_lr | D_sr );

	//条件写的冻结定义如下：
	//1.确定将写入地址，则在确定写入时 we从0-1，后续若使用该寄存器则阻塞（见lr1）
	//2.不确定写入地址，但知为rt或rs，则确认地址时，we从0-1，且add_write为真实，add_write_plus为0
	//3.不确定写入地址，但知来自ALU级，修改ALU即可，同上，无脑阻塞一级 (needgrf_D & (E_XXX)) |
	//4.不确定写入地址，但知来自DM级，修改ALU即可，同上，无脑阻塞二级 （见下lr）
	//注：1，2，3，4 均视为在未知 写入地址/是否写入 时we为0
	
	
	//各级需要寄存器
	assign needgrf_D = (D_beq | D_bne | D_blez| D_bgtz | D_bltz | D_bgez | D_jr | D_jalr | D_bal |
							  D_addu | D_subu | D_add | D_sub | D_and | D_or | D_xor | D_nor | D_slt | D_sltu | D_sll | D_srl | D_sra | D_sllv | D_srlv | D_srav | D_cal |
							  D_addi | D_addiu | D_andi | D_ori | D_xori | D_slti | D_sltiu | D_cai |
							  D_lw | D_lb | D_lbu | D_lh | D_lhu | D_lr | D_lr1 |
							  D_sw | D_sb | D_sh | D_sr |
							  D_MULT | D_MULTU | D_DIV | D_DIVU | D_MTHI | D_MTLO | D_Mr 
							  );
	assign needgrf_E = (E_beq | E_bne | E_blez| E_bgtz | E_bltz | E_bgez | E_jr | E_jalr | E_bal |
							  E_addu | E_subu | E_add | E_sub | E_and | E_or | E_xor | E_nor | E_slt | E_sltu | E_sll | E_srl | E_sra | E_sllv | E_srlv | E_srav | E_cal |
							  E_addi | E_addiu | E_andi | E_ori | E_xori | E_slti | E_sltiu | E_cai |
							  E_lw | E_lb | E_lbu | E_lh | E_lhu | E_lr | E_lr1 |
							  E_sw | E_sb | E_sh | E_sr |
							  E_MULT | E_MULTU | E_DIV | E_DIVU | E_MTHI | E_MTLO | E_Mr
							  );
	assign needgrf_M = (M_beq | M_bne | M_blez| M_bgtz | M_bltz | M_bgez | M_jr | M_jalr | M_bal |
							  M_addu | M_subu | M_add | M_sub | M_and | M_or | M_xor | M_nor | M_slt | M_sltu | M_sll | M_srl | M_sra | M_sllv | M_srlv | M_srav | M_cal |
							  M_addi | M_addiu | M_andi | M_ori | M_xori | M_slti | M_sltiu | M_cai |
							  M_lw | M_lb | M_lbu | M_lh | M_lhu | M_lr | M_lr1 |
							  M_sw | M_sb | M_sh | M_sr | 
							  M_MULT | M_MULTU | M_DIV | M_DIVU | M_MTHI | M_MTLO | M_Mr
							  );
	
	//需要MDU
	assign MDU_use	  = D_MULT | D_MULTU | D_DIV | D_DIVU | D_MFHI | D_MFLO | D_MTHI | D_MTLO | D_Mr;
	
	assign MDU_will_busy = E_MULT | E_MULTU | E_DIV | E_DIVU | E_Mr;
	
	assign freeze = ((MDU_busy | MDU_will_busy )& MDU_use) |
						 (needgrf_D & (E_lr | M_lr)) |
						 (needgrf_E & (	    M_lr)) |
						 (needgrf_D & E_lr1) |
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
