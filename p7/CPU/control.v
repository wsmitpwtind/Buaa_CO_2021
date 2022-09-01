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


`define	Addu		7'd0
`define	Subu		7'd1
`define	Add		7'd2
`define	Sub		7'd3
`define	And		7'd4
`define	Or			7'd5
`define	Xor		7'd6
`define	Nor		7'd7
`define	Slt		7'd8
`define	Sltu		7'd9
`define	Sll		7'd10
`define	Srl		7'd11
`define	Sra		7'd12
`define	Sllv		7'd13
`define	Srlv		7'd14
`define	Srav		7'd15
`define	Cal		7'd50  //alu 11号运算

`define	Lui		7'd16
`define	Addi		7'd17
`define	Addiu		7'd18
`define	Andi		7'd19
`define	Ori		7'd20
`define	Xori		7'd21
`define	Slti		7'd22
`define	Sltiu		7'd23
`define	Cai		7'd51	 //alu 11号运算，符号扩展

`define	Beq		7'd24
`define	Bne		7'd25
`define	Blez		7'd26
`define	Bgtz		7'd27
`define	Bltz		7'd28
`define	Bgez		7'd29
`define	Jal		7'd30
`define	Jr			7'd31
`define	J			7'd32
`define	Jalr		7'd33
`define	Bal		7'd52  //rs rt相反数时跳转，跳转时写31寄存器pc+8，否则清空延迟槽

`define	Lw			7'd34
`define	Lb			7'd35
`define	Lbu		7'd36
`define	Lh			7'd37
`define	Lhu		7'd38
`define	Lr			7'd53 //1. 利用GRF[rs]和offset得到MemAddr
								//2. Mem[MemAddr]后5位作为GRF的写入地址
								//3. 写入数据为GRF[rt]
`define	Lr1		7'd54 //1. 利用GRF[rs]和offset得到MemAddr
								//2. Mem[MemAddr]小于0则写31为pc+4，否则写rt为Mem[MemAddr]（同lw）
								

`define	Sw			7'd39
`define	Sb			7'd40
`define	Sh			7'd41
`define	Sr			7'd54
								//1. 利用GRF[rs]和offset得到MemAddr
								//2. 写入dm数据为GRF[rs] + GRF[rt]
								//3. 仅在GRF[rs] + GRF[rt] 大于0时写

`define	MULT		7'd42
`define	MULTU		7'd43
`define	DIV		7'd44
`define	DIVU		7'd45
`define	MFHI		7'd46
`define	MFLO		7'd47
`define	MTHI		7'd48
`define	MTLO		7'd49
`define	Mr			7'd55 //mdu 4号运算 5延迟
								//LO为HI-A
								//HI为LO+B

`define	Nop		7'd127

`define	Mfc0		7'd100
`define	Mtc0		7'd101
`define	Eret		7'd102


module control(

//周期 Ⅰ		 -> 指令
	
	//右 -> datapath送出
	input [31:0] I_Instr_in,				//读的指令存储器指令
	input [31:0] I_PC_in,					//当前PC
	
	//右 -> IF/ID接收
	output reg [31:0] I_Instr_out,
	output reg [31:0] I_PC_out,
	output reg I_BD_out,
	
//周期 Ⅱ	指令 -> 读寄存器

	//左 -> IF/ID送出
	input [31:0] D_Instr_in,
	input [31:0] D_PC_in,
	input D_BD_in,
	input [4 :0] D_ExcCode_in,
	
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
	output reg [4 :0] D_ExcCode_out,
	
	
	//右 -> ID/EX接收
	output reg [31:0] D_Instr_out,
	output reg [31:0] D_PC_out,
	output reg D_BD_out,
	output reg [31:0] D_Num1_out, //GPR[base],GPR[rs]
	output reg [31:0] D_Num2_out, //GPR[rt],unsign_ext(imm16)
	output reg [3:0]  D_ALUopcode_out,
	output reg D_WEGF_out,
	output reg [3:0]  D_WEDM_out,
	 
//周期 Ⅲ	读寄存器 -> ALU/MDU

	//左 -> ID/EX送出
	input [31:0] E_Instr_in,
	input [31:0] E_PC_in,
	input E_BD_in,
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
	output reg [4:0] E_add_write_plus,//试图写入的寄存器地址
	output reg E_type_write,	//试图写入的寄存器来源类型 1=dm 0=alu
	//此时认为关心寄存器的结果
	output reg [31:0] askdata1_M,
	output reg [31:0] askdata2_M,
	
	//左 -> datapath接收
	output reg [3:0] ALUopcode,	//Alu运算符
	output reg [31:0] ALUinput1,	//Alu读入数据1
	output reg [31:0] ALUinput2,	//Alu读入数据2
	output [4 :0] E_ExcCode_out,
	
	//右 -> datapath送出
	input [31:0] ALUresult,			//Alu计算结果
	input [4 :0] E_ExcCode_in,
	
	//MDU
	//左 -> datapath接收
	output reg [31:0] MDU_inputA,
   output reg [31:0] MDU_inputB,
   output reg MDU_start,
   output reg [2:0] MDUOp,
   output reg HIWrite,
   output reg LOWrite,
	
	//右 -> datapath送出
   input [31:0] HIRead,
   input [31:0] LORead,
	 
	
	//右 -> EX/MEM接收	
	output reg [31:0] E_Instr_out,
	output reg [31:0] E_PC_out,
	output reg E_BD_out,
	output reg [31:0] E_ALUresult_out,
	output reg E_WEGF_out,
	output reg [3:0]  E_WEDM_out,
	
//周期 Ⅳ	ALU/MDU -> 数据存储器

	//左 -> EX/MEM送出
	input [31:0] M_Instr_in,
	input [31:0] M_PC_in,
	input M_BD_in,
	input [31:0] M_ALUresult_in,
	input M_WEGF_in,
	input [3:0]  M_WEDM_in,
	input [4 :0] M_ExcCode_in,
	
	//关心的寄存器的值
	output reg [4:0] CareGFadd1_M,	//关心的寄存器1地址
	output reg [4:0] CareGFadd2_M,	//关心的寄存器2地址
	//关心的寄存器的结果
	input [31:0] CareGF1_M,			//关心的寄存器1数据
	input [31:0] CareGF2_M,			//关心的寄存器2数据
	
	output reg [4:0] M_add_write,//试图写入的寄存器地址
	output reg [4:0] M_add_write_plus,//试图写入的寄存器地址
	output reg M_type_write,	//试图写入的寄存器来源类型 1=dm 0=alu

	
	//左 -> datapath接收
	output reg [3:0] WEdm,					//数据存储器写使能
	output reg [31:0] WriteDMadd,	//写的数据存储器地址
	output reg [31:0] WriteDMdata,//写的数据存储器数据
	output reg [31:0] readDMadd,	//读的数据存储器地址
	output reg [1 :0] M_readenable,
	
	output reg WECP0,
	output reg [31:0] Wirte_CP0_data,
	output reg [4 :0] Wirte_CP0_add,
	output reg [4 :0] Read_CP0_add,
	output reg Eret,
	output reg [31:0] EretPC,
	output reg BD,
	
	//右 -> datapath送出
	input [31:0] ReadDM,				//读的数据存储器数据
	
	input [31:0] Read_CP0_data,
	
	//右 -> MEM/WB接收
	output reg [31:0] M_Instr_out,
	output reg [31:0] M_PC_out,
	output reg [31:0] M_ALUresult_out,
	output reg [31:0] M_DMdata_out,
	output reg M_WEGF_out,
	output [4 :0] M_ExcCode_out,
	
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
	
	input freeze,
	
	//p7
	input interrupt,
	
	output reg [31:0] D_ExcPC_out,
	input [31:0]  D_ExcPC_in,
	output [31:0] E_ExcPC_out,
	output [31:0] E_PCc_out,
	input [31:0]  E_ExcPC_in,
	input [31:0]  M_ExcPC_in,
	output [31:0] M_ExcPC_out,
	output [31:0] M_PCc_out,
	
	input overflow
    );	 
	
	//临时变量
	wire [31:0]temp1;
	assign temp1 = CareGF1_E + E_Num2_in; 
	
	reg Nulldelayslot= 1'b0;
	
	//p7
	assign E_ExcCode_out = (overflow) ? 5'd12 : E_ExcCode_in;
	assign E_ExcPC_out = E_ExcPC_in;
	assign E_PCc_out = E_PC_in;
	assign M_ExcCode_out = M_ExcCode_in;
	assign M_ExcPC_out = M_ExcPC_in;
	assign M_PCc_out = M_PC_in;
	
	
	//以下内容复制5份！！！！！！
	//支持指令
	//三目ALU
	wire I_addu, I_subu, I_add, I_sub, I_and, I_or, I_xor, I_nor, I_slt, I_sltu, I_sll, I_srl, I_sra, I_sllv, I_srlv, I_srav, I_cal;
	wire D_addu, D_subu, D_add, D_sub, D_and, D_or, D_xor, D_nor, D_slt, D_sltu, D_sll, D_srl, D_sra, D_sllv, D_srlv, D_srav, D_cal;
	wire E_addu, E_subu, E_add, E_sub, E_and, E_or, E_xor, E_nor, E_slt, E_sltu, E_sll, E_srl, E_sra, E_sllv, E_srlv, E_srav, E_cal;
	wire M_addu, M_subu, M_add, M_sub, M_and, M_or, M_xor, M_nor, M_slt, M_sltu, M_sll, M_srl, M_sra, M_sllv, M_srlv, M_srav, M_cal;
	wire W_addu, W_subu, W_add, W_sub, W_and, W_or, W_xor, W_nor, W_slt, W_sltu, W_sll, W_srl, W_sra, W_sllv, W_srlv, W_srav, W_cal;
	//立即数ALU
	wire I_lui, I_addi, I_addiu, I_andi, I_ori, I_xori, I_slti, I_sltiu, I_cai;
	wire D_lui, D_addi, D_addiu, D_andi, D_ori, D_xori, D_slti, D_sltiu, D_cai;
	wire E_lui, E_addi, E_addiu, E_andi, E_ori, E_xori, E_slti, E_sltiu, E_cai;
	wire M_lui, M_addi, M_addiu, M_andi, M_ori, M_xori, M_slti, M_sltiu, M_cai;
	wire W_lui, W_addi, W_addiu, W_andi, W_ori, W_xori, W_slti, W_sltiu, W_cai;
	//跳转
	wire I_beq, I_bne, I_blez, I_bgtz, I_bltz, I_bgez, I_jal, I_jr, I_j, I_jalr, I_bal;
	wire D_beq, D_bne, D_blez, D_bgtz, D_bltz, D_bgez, D_jal, D_jr, D_j, D_jalr, D_bal;
	wire E_beq, E_bne, E_blez, E_bgtz, E_bltz, E_bgez, E_jal, E_jr, E_j, E_jalr, E_bal;
	wire M_beq, M_bne, M_blez, M_bgtz, M_bltz, M_bgez, M_jal, M_jr, M_j, M_jalr, M_bal;
	wire W_beq, W_bne, W_blez, W_bgtz, W_bltz, W_bgez, W_jal, W_jr, W_j, W_jalr, W_bal;
	//Load
	wire I_lw, I_lb, I_lbu, I_lh, I_lhu, I_lr, I_lr1;
	wire D_lw, D_lb, D_lbu, D_lh, D_lhu, D_lr, D_lr1;
	wire E_lw, E_lb, E_lbu, E_lh, E_lhu, E_lr, E_lr1;
	wire M_lw, M_lb, M_lbu, M_lh, M_lhu, M_lr, M_lr1;
	wire W_lw, W_lb, W_lbu, W_lh, W_lhu, W_lr, W_lr1;
	//Store
	wire I_sw, I_sb, I_sh, I_sr;
	wire D_sw, D_sb, D_sh, D_sr;
	wire E_sw, E_sb, E_sh, E_sr;
	wire M_sw, M_sb, M_sh, M_sr;
	wire W_sw, W_sb, W_sh, W_sr;
	//MDU乘除
	wire I_MULT, I_MULTU, I_DIV, I_DIVU, I_MFHI, I_MFLO, I_MTHI, I_MTLO, I_Mr;
	wire D_MULT, D_MULTU, D_DIV, D_DIVU, D_MFHI, D_MFLO, D_MTHI, D_MTLO, D_Mr;
	wire E_MULT, E_MULTU, E_DIV, E_DIVU, E_MFHI, E_MFLO, E_MTHI, E_MTLO, E_Mr;
	wire M_MULT, M_MULTU, M_DIV, M_DIVU, M_MFHI, M_MFLO, M_MTHI, M_MTLO, M_Mr;
	wire W_MULT, W_MULTU, W_DIV, W_DIVU, W_MFHI, W_MFLO, W_MTHI, W_MTLO, W_Mr;
	//其余
	wire I_nop;
	wire D_nop;
	wire E_nop;
	wire M_nop;
	wire W_nop;
	
	
	
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
	//三目ALU
	assign I_addu 	= (I_op == 6'b000000)&(I_func == 6'b100001);
	assign I_subu 	= (I_op == 6'b000000)&(I_func == 6'b100011);
	assign I_add 	= (I_op == 6'b000000)&(I_func == 6'b100000);
	assign I_sub 	= (I_op == 6'b000000)&(I_func == 6'b100010);
	assign I_and 	= (I_op == 6'b000000)&(I_func == 6'b100100);
	assign I_or 	= (I_op == 6'b000000)&(I_func == 6'b100101);
	assign I_xor 	= (I_op == 6'b000000)&(I_func == 6'b100110);
	assign I_nor 	= (I_op == 6'b000000)&(I_func == 6'b100111);
	assign I_slt 	= (I_op == 6'b000000)&(I_func == 6'b101010);
	assign I_sltu 	= (I_op == 6'b000000)&(I_func == 6'b101011);
	assign I_sll	= (I_op == 6'b000000)&(I_func == 6'b000000)&(I_Instr_in != 32'b0);
	assign I_srl	= (I_op == 6'b000000)&(I_func == 6'b000010);
	assign I_sra	= (I_op == 6'b000000)&(I_func == 6'b000011);
	assign I_sllv	= (I_op == 6'b000000)&(I_func == 6'b000100);
	assign I_srlv	= (I_op == 6'b000000)&(I_func == 6'b000110);
	assign I_srav	= (I_op == 6'b000000)&(I_func == 6'b000111);
	
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
	assign D_sll	= (D_op == 6'b000000)&(D_func == 6'b000000)&(D_Instr_in != 32'b0);
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
	assign E_sll	= (E_op == 6'b000000)&(E_func == 6'b000000)&(E_Instr_in != 32'b0);
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
	assign M_sll	= (M_op == 6'b000000)&(M_func == 6'b000000)&(M_Instr_in != 32'b0);
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
	assign W_sll	= (W_op == 6'b000000)&(W_func == 6'b000000)&(W_Instr_in != 32'b0);
	assign W_srl	= (W_op == 6'b000000)&(W_func == 6'b000010);
	assign W_sra	= (W_op == 6'b000000)&(W_func == 6'b000011);
	assign W_sllv	= (W_op == 6'b000000)&(W_func == 6'b000100);
	assign W_srlv	= (W_op == 6'b000000)&(W_func == 6'b000110);
	assign W_srav	= (W_op == 6'b000000)&(W_func == 6'b000111);
	
	//立即数ALU
	assign I_lui 	= (I_op == 6'b001111);
	assign I_addi	= (I_op == 6'b001000);
	assign I_addiu	= (I_op == 6'b001001);
	assign I_andi	= (I_op == 6'b001100);
	assign I_ori 	= (I_op == 6'b001101);
	assign I_xori 	= (I_op == 6'b001110);
	assign I_slti 	= (I_op == 6'b001010);
	assign I_sltiu = (I_op == 6'b001011);
	
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
	assign W_addi	= (W_op == 6'b001000);
	assign W_addiu	= (W_op == 6'b001001);
	assign W_andi	= (W_op == 6'b001100);
	assign W_ori 	= (W_op == 6'b001101);
	assign W_xori 	= (W_op == 6'b001110);
	assign W_slti 	= (W_op == 6'b001010);
	assign W_sltiu = (W_op == 6'b001011);
	//跳转
	assign I_beq 	= (I_op == 6'b000100);
	assign I_bne 	= (I_op == 6'b000101);
	assign I_blez 	= (I_op == 6'b000110);
	assign I_bgtz 	= (I_op == 6'b000111);
	assign I_bltz 	= (I_op == 6'b000001)&(I_rt	== 5'b00000);
	assign I_bgez 	= (I_op == 6'b000001)&(I_rt	== 5'b00001);
	assign I_jal 	= (I_op == 6'b000011);
	assign I_jr 	= (I_op == 6'b000000)&(I_func == 6'b001000);
	assign I_j 		= (I_op == 6'b000010);
	assign I_jalr 	= (I_op == 6'b000000)&(I_func == 6'b001001);
	
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
	assign I_lw 	= (I_op == 6'b100011);
	assign I_lb 	= (I_op == 6'b100000);
	assign I_lbu 	= (I_op == 6'b100100);
	assign I_lh 	= (I_op == 6'b100001);
	assign I_lhu 	= (I_op == 6'b100101);
	
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
	assign I_sw 	= (I_op == 6'b101011);
	assign I_sb 	= (I_op == 6'b101000);
	assign I_sh 	= (I_op == 6'b101001);
	
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
	assign I_MULT	= (I_op == 6'b000000)&(I_func == 6'b011000);
	assign I_MULTU	= (I_op == 6'b000000)&(I_func == 6'b011001);
	assign I_DIV	= (I_op == 6'b000000)&(I_func == 6'b011010);
	assign I_DIVU	= (I_op == 6'b000000)&(I_func == 6'b011011);
	assign I_MFHI	= (I_op == 6'b000000)&(I_func == 6'b010000);
	assign I_MFLO	= (I_op == 6'b000000)&(I_func == 6'b010010);
	assign I_MTHI	= (I_op == 6'b000000)&(I_func == 6'b010001);
	assign I_MTLO	= (I_op == 6'b000000)&(I_func == 6'b010011);
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
	assign I_nop	= (I_op == 6'b000000)&(I_func == 6'b000000);
	assign D_nop	= (D_op == 6'b000000)&(D_func == 6'b000000);
	assign E_nop	= (E_op == 6'b000000)&(E_func == 6'b000000);
	assign M_nop	= (M_op == 6'b000000)&(M_func == 6'b000000);
	assign W_nop	= (W_op == 6'b000000)&(W_func == 6'b000000);

	assign I_mfc0	= (I_op == 6'b010000)&(I_rs 	== 5'b00000);
	assign D_mfc0	= (D_op == 6'b010000)&(D_rs 	== 5'b00000);
	assign E_mfc0	= (E_op == 6'b010000)&(E_rs 	== 5'b00000);
	assign M_mfc0	= (M_op == 6'b010000)&(M_rs 	== 5'b00000);
	assign W_mfc0	= (W_op == 6'b010000)&(W_rs 	== 5'b00000);
	
	assign I_mtc0	= (I_op == 6'b010000)&(I_rs 	== 5'b00100);
	assign D_mtc0	= (D_op == 6'b010000)&(D_rs 	== 5'b00100);
	assign E_mtc0	= (E_op == 6'b010000)&(E_rs 	== 5'b00100);
	assign M_mtc0	= (M_op == 6'b010000)&(M_rs 	== 5'b00100);
	assign W_mtc0	= (W_op == 6'b010000)&(W_rs 	== 5'b00100);
	
	assign I_eret	= (I_op == 6'b010000)&(I_func == 6'b011000);
	assign D_eret	= (D_op == 6'b010000)&(D_func == 6'b011000);
	assign E_eret	= (E_op == 6'b010000)&(E_func == 6'b011000);
	assign M_eret	= (M_op == 6'b010000)&(M_func == 6'b011000);
	assign W_eret	= (W_op == 6'b010000)&(W_func == 6'b011000);
	

	//待定指令及其opcode如下
	assign I_cal 	= (I_op == 6'b000000)&(I_func == 6'b101100);
	assign D_cal 	= (D_op == 6'b000000)&(D_func == 6'b101100);
	assign E_cal 	= (E_op == 6'b000000)&(E_func == 6'b101100);
	assign M_cal 	= (M_op == 6'b000000)&(M_func == 6'b101100);
	assign W_cal 	= (W_op == 6'b000000)&(W_func == 6'b101100);
	
	assign I_cai 	= (I_op == 6'b110101);	
	assign D_cai 	= (D_op == 6'b110101);
	assign E_cai 	= (E_op == 6'b110101);
	assign M_cai 	= (M_op == 6'b110101);
	assign W_cai 	= (W_op == 6'b110101);
	
	assign I_bal	= (I_op == 6'b100110);
	assign D_bal	= (D_op == 6'b100110);
	assign E_bal	= (E_op == 6'b100110);
	assign M_bal	= (M_op == 6'b100110);
	assign W_bal	= (W_op == 6'b100110);
	
	assign I_lr 	= (I_op == 6'b101101);	
	assign D_lr 	= (D_op == 6'b101101);
	assign E_lr 	= (E_op == 6'b101101);
	assign M_lr 	= (M_op == 6'b101101);
	assign W_lr 	= (W_op == 6'b101101);
	
	assign I_lr1 	= (I_op == 6'b010101);	
	assign D_lr1 	= (D_op == 6'b010101);
	assign E_lr1 	= (E_op == 6'b010101);
	assign M_lr1 	= (M_op == 6'b010101);
	assign W_lr1 	= (W_op == 6'b010101);

	assign I_sr 	= (I_op == 6'b111101);	
	assign D_sr 	= (D_op == 6'b111101);
	assign E_sr 	= (E_op == 6'b111101);
	assign M_sr 	= (M_op == 6'b111101);
	assign W_sr 	= (W_op == 6'b111101);
	
	assign I_Mr 	= (I_op == 6'b101111);	
	assign D_Mr 	= (D_op == 6'b101111);	
	assign E_Mr 	= (E_op == 6'b101111);	
	assign M_Mr 	= (M_op == 6'b101111);
	assign W_Mr 	= (W_op == 6'b101111);

	
	
	
	//以下内容复制5份！！！！！！
	//指令列表
	wire [6:0]I_Instrlist, D_Instrlist, E_Instrlist, M_Instrlist, W_Instrlist;
	assign I_Instrlist	=	//三目ALU
									(I_addu 	== 1'b1) ? `Addu:
									(I_subu 	== 1'b1) ? `Subu:
									(I_add 	== 1'b1) ? `Add:
									(I_sub 	== 1'b1) ? `Sub:
									(I_and 	== 1'b1) ? `And:
									(I_or 	== 1'b1) ? `Or:
									(I_xor 	== 1'b1) ? `Xor:
									(I_nor 	== 1'b1) ? `Nor:
									(I_slt 	== 1'b1) ? `Slt:
									(I_sltu 	== 1'b1) ? `Sltu:
									(I_sll 	== 1'b1) ? `Sll:
									(I_srl 	== 1'b1) ? `Srl:
									(I_sra 	== 1'b1) ? `Sra:
									(I_sllv 	== 1'b1) ? `Sllv:
									(I_srlv 	== 1'b1) ? `Srlv:
									(I_srav 	== 1'b1) ? `Srav:
									(I_cal 	== 1'b1) ? `Cal:

									//立即数ALU
									(I_lui 	== 1'b1) ? `Lui:
									(I_addi 	== 1'b1) ? `Addi:
									(I_addiu == 1'b1) ? `Addiu:
									(I_andi 	== 1'b1) ? `Andi:
									(I_ori 	== 1'b1) ? `Ori:
									(I_xori	== 1'b1) ? `Xori:
									(I_slti 	== 1'b1) ? `Slti:
									(I_sltiu == 1'b1) ? `Sltiu:
									(I_cai 	== 1'b1) ? `Cai:
									
									//跳转
									(I_beq 	== 1'b1) ? `Beq:
									(I_bne 	== 1'b1) ? `Bne:
									(I_blez 	== 1'b1) ? `Blez:
									(I_bgtz 	== 1'b1) ? `Bgtz:
									(I_bltz 	== 1'b1) ? `Bltz:
									(I_bgez 	== 1'b1) ? `Bgez:
									(I_jal 	== 1'b1) ? `Jal:
									(I_jr 	== 1'b1) ? `Jr:
									(I_j 		== 1'b1) ? `J:
									(I_jalr 	== 1'b1) ? `Jalr:
									(I_bal 	== 1'b1) ? `Bal:
									
									//Load
									(I_lw 	== 1'b1) ? `Lw:
									(I_lb 	== 1'b1) ? `Lb:
									(I_lbu 	== 1'b1) ? `Lbu:
									(I_lh 	== 1'b1) ? `Lh:
									(I_lhu 	== 1'b1) ? `Lhu:
									(I_lr 	== 1'b1) ? `Lr:
									(I_lr1 	== 1'b1) ? `Lr1:
									
									//Store
									(I_sw 	== 1'b1) ? `Sw:
									(I_sb 	== 1'b1) ? `Sb:
									(I_sh 	== 1'b1) ? `Sh:
									(I_sr 	== 1'b1) ? `Sr:
									
									//MDU乘除
									(I_MULT	== 1'b1) ? `MULT:
									(I_MULTU	== 1'b1) ? `MULTU:
									(I_DIV	== 1'b1) ? `DIV:
									(I_DIVU	== 1'b1) ? `DIVU:
									(I_MFHI	== 1'b1) ? `MFHI:
									(I_MFLO	== 1'b1) ? `MFLO:
									(I_MTHI	== 1'b1) ? `MTHI:
									(I_MTLO	== 1'b1) ? `MTLO:
									(I_Mr		== 1'b1) ? `Mr:
									
									//其他
									(I_nop 	== 1'b1) ? `Nop:
									(I_mfc0 	== 1'b1) ? `Mfc0:
									(I_mtc0 	== 1'b1) ? `Mtc0:
									(I_eret 	== 1'b1) ? `Eret:

																	7'd126;
	assign D_Instrlist	=	//三目ALU
									//(interrupt == 1'b1) ? `Nop:
									(D_addu 	== 1'b1) ? `Addu:
									(D_subu 	== 1'b1) ? `Subu:
									(D_add 	== 1'b1) ? `Add:
									(D_sub 	== 1'b1) ? `Sub:
									(D_and 	== 1'b1) ? `And:
									(D_or 	== 1'b1) ? `Or:
									(D_xor 	== 1'b1) ? `Xor:
									(D_nor 	== 1'b1) ? `Nor:
									(D_slt 	== 1'b1) ? `Slt:
									(D_sltu 	== 1'b1) ? `Sltu:
									(D_sll 	== 1'b1) ? `Sll:
									(D_srl 	== 1'b1) ? `Srl:
									(D_sra 	== 1'b1) ? `Sra:
									(D_sllv 	== 1'b1) ? `Sllv:
									(D_srlv 	== 1'b1) ? `Srlv:
									(D_srav 	== 1'b1) ? `Srav:
									(D_cal 	== 1'b1) ? `Cal:
									
									//立即数ALU
									(D_lui 	== 1'b1) ? `Lui:
									(D_addi 	== 1'b1) ? `Addi:
									(D_addiu == 1'b1) ? `Addiu:
									(D_andi 	== 1'b1) ? `Andi:
									(D_ori 	== 1'b1) ? `Ori:
									(D_xori	== 1'b1) ? `Xori:
									(D_slti 	== 1'b1) ? `Slti:
									(D_sltiu == 1'b1) ? `Sltiu:
									(D_cai 	== 1'b1) ? `Cai:
									
									//跳转
									(D_beq 	== 1'b1) ? `Beq:
									(D_bne 	== 1'b1) ? `Bne:
									(D_blez 	== 1'b1) ? `Blez:
									(D_bgtz 	== 1'b1) ? `Bgtz:
									(D_bltz 	== 1'b1) ? `Bltz:
									(D_bgez 	== 1'b1) ? `Bgez:
									(D_jal 	== 1'b1) ? `Jal:
									(D_jr 	== 1'b1) ? `Jr:
									(D_j 		== 1'b1) ? `J:
									(D_jalr 	== 1'b1) ? `Jalr:
									(D_bal 	== 1'b1) ? `Bal:
									
									//Load
									(D_lw 	== 1'b1) ? `Lw:
									(D_lb 	== 1'b1) ? `Lb:
									(D_lbu 	== 1'b1) ? `Lbu:
									(D_lh 	== 1'b1) ? `Lh:
									(D_lhu 	== 1'b1) ? `Lhu:
									(D_lr 	== 1'b1) ? `Lr:
									(D_lr1 	== 1'b1) ? `Lr1:
									
									//Store
									(D_sw 	== 1'b1) ? `Sw:
									(D_sb 	== 1'b1) ? `Sb:
									(D_sh 	== 1'b1) ? `Sh:
									(D_sr 	== 1'b1) ? `Sr:
									
									//MDU乘除
									(D_MULT	== 1'b1) ? `MULT:
									(D_MULTU	== 1'b1) ? `MULTU:
									(D_DIV	== 1'b1) ? `DIV:
									(D_DIVU	== 1'b1) ? `DIVU:
									(D_MFHI	== 1'b1) ? `MFHI:
									(D_MFLO	== 1'b1) ? `MFLO:
									(D_MTHI	== 1'b1) ? `MTHI:
									(D_MTLO	== 1'b1) ? `MTLO:
									(D_Mr		== 1'b1) ? `Mr:
									
									//其他
									(D_nop 	== 1'b1) ? `Nop:
									(D_mfc0 	== 1'b1) ? `Mfc0:
									(D_mtc0 	== 1'b1) ? `Mtc0:
									(D_eret 	== 1'b1) ? `Eret:

																	7'd126;
																	
	assign E_Instrlist	=	//三目ALU
									//(interrupt == 1'b1) ? `Nop:
									(E_addu 	== 1'b1) ? `Addu:
									(E_subu 	== 1'b1) ? `Subu:
									(E_add 	== 1'b1) ? `Add:
									(E_sub 	== 1'b1) ? `Sub:
									(E_and 	== 1'b1) ? `And:
									(E_or 	== 1'b1) ? `Or:
									(E_xor 	== 1'b1) ? `Xor:
									(E_nor 	== 1'b1) ? `Nor:
									(E_slt 	== 1'b1) ? `Slt:
									(E_sltu 	== 1'b1) ? `Sltu:
									(E_sll 	== 1'b1) ? `Sll:
									(E_srl 	== 1'b1) ? `Srl:
									(E_sra 	== 1'b1) ? `Sra:
									(E_sllv 	== 1'b1) ? `Sllv:
									(E_srlv 	== 1'b1) ? `Srlv:
									(E_srav 	== 1'b1) ? `Srav:
									(E_cal 	== 1'b1) ? `Cal:
									
									//立即数ALU
									(E_lui 	== 1'b1) ? `Lui:
									(E_addi 	== 1'b1) ? `Addi:
									(E_addiu == 1'b1) ? `Addiu:
									(E_andi 	== 1'b1) ? `Andi:
									(E_ori 	== 1'b1) ? `Ori:
									(E_xori	== 1'b1) ? `Xori:
									(E_slti 	== 1'b1) ? `Slti:
									(E_sltiu == 1'b1) ? `Sltiu:
									(E_cai 	== 1'b1) ? `Cai:
									
									//跳转
									(E_beq 	== 1'b1) ? `Beq:
									(E_bne 	== 1'b1) ? `Bne:
									(E_blez 	== 1'b1) ? `Blez:
									(E_bgtz 	== 1'b1) ? `Bgtz:
									(E_bltz 	== 1'b1) ? `Bltz:
									(E_bgez 	== 1'b1) ? `Bgez:
									(E_jal 	== 1'b1) ? `Jal:
									(E_jr 	== 1'b1) ? `Jr:
									(E_j 		== 1'b1) ? `J:
									(E_jalr 	== 1'b1) ? `Jalr:
									(E_bal 	== 1'b1) ? `Bal:
									
									//Load
									(E_lw 	== 1'b1) ? `Lw:
									(E_lb 	== 1'b1) ? `Lb:
									(E_lbu 	== 1'b1) ? `Lbu:
									(E_lh 	== 1'b1) ? `Lh:
									(E_lhu 	== 1'b1) ? `Lhu:
									(E_lr 	== 1'b1) ? `Lr:
									(E_lr1 	== 1'b1) ? `Lr1:
									
									//Store
									(E_sw 	== 1'b1) ? `Sw:
									(E_sb 	== 1'b1) ? `Sb:
									(E_sh 	== 1'b1) ? `Sh:
									(E_sr 	== 1'b1) ? `Sr:
									
									//MDU乘除
									(E_MULT	== 1'b1) ? `MULT:
									(E_MULTU	== 1'b1) ? `MULTU:
									(E_DIV	== 1'b1) ? `DIV:
									(E_DIVU	== 1'b1) ? `DIVU:
									(E_MFHI	== 1'b1) ? `MFHI:
									(E_MFLO	== 1'b1) ? `MFLO:
									(E_MTHI	== 1'b1) ? `MTHI:
									(E_MTLO	== 1'b1) ? `MTLO:
									(E_Mr		== 1'b1) ? `Mr:
									
									//其他
									(E_nop 	== 1'b1) ? `Nop:
									(E_mfc0 	== 1'b1) ? `Mfc0:
									(E_mtc0 	== 1'b1) ? `Mtc0:
									(E_eret 	== 1'b1) ? `Eret:

																	7'd126;
	assign M_Instrlist	=	//三目ALU
									(M_addu 	== 1'b1) ? `Addu:
									(M_subu 	== 1'b1) ? `Subu:
									(M_add 	== 1'b1) ? `Add:
									(M_sub 	== 1'b1) ? `Sub:
									(M_and 	== 1'b1) ? `And:
									(M_or 	== 1'b1) ? `Or:
									(M_xor 	== 1'b1) ? `Xor:
									(M_nor 	== 1'b1) ? `Nor:
									(M_slt 	== 1'b1) ? `Slt:
									(M_sltu 	== 1'b1) ? `Sltu:
									(M_sll 	== 1'b1) ? `Sll:
									(M_srl 	== 1'b1) ? `Srl:
									(M_sra 	== 1'b1) ? `Sra:
									(M_sllv 	== 1'b1) ? `Sllv:
									(M_srlv 	== 1'b1) ? `Srlv:
									(M_srav 	== 1'b1) ? `Srav:
									(M_cal 	== 1'b1) ? `Cal:
									
									//立即数ALU
									(M_lui 	== 1'b1) ? `Lui:
									(M_addi 	== 1'b1) ? `Addi:
									(M_addiu == 1'b1) ? `Addiu:
									(M_andi 	== 1'b1) ? `Andi:
									(M_ori 	== 1'b1) ? `Ori:
									(M_xori	== 1'b1) ? `Xori:
									(M_slti 	== 1'b1) ? `Slti:
									(M_sltiu == 1'b1) ? `Sltiu:
									(M_cai 	== 1'b1) ? `Cai:
									(M_bal 	== 1'b1) ? `Bal:
									
									//跳转
									(M_beq 	== 1'b1) ? `Beq:
									(M_bne 	== 1'b1) ? `Bne:
									(M_blez 	== 1'b1) ? `Blez:
									(M_bgtz 	== 1'b1) ? `Bgtz:
									(M_bltz 	== 1'b1) ? `Bltz:
									(M_bgez 	== 1'b1) ? `Bgez:
									(M_jal 	== 1'b1) ? `Jal:
									(M_jr 	== 1'b1) ? `Jr:
									(M_j 		== 1'b1) ? `J:
									(M_jalr 	== 1'b1) ? `Jalr:
									
									//Load
									(M_lw 	== 1'b1) ? `Lw:
									(M_lb 	== 1'b1) ? `Lb:
									(M_lbu 	== 1'b1) ? `Lbu:
									(M_lh 	== 1'b1) ? `Lh:
									(M_lhu 	== 1'b1) ? `Lhu:
									(M_lr 	== 1'b1) ? `Lr:
									(M_lr1 	== 1'b1) ? `Lr1:
									
									//Store
									(M_sw 	== 1'b1) ? `Sw:
									(M_sb 	== 1'b1) ? `Sb:
									(M_sh 	== 1'b1) ? `Sh:
									(M_sr 	== 1'b1) ? `Sr:
									
									//MDU乘除
									(M_MULT	== 1'b1) ? `MULT:
									(M_MULTU	== 1'b1) ? `MULTU:
									(M_DIV	== 1'b1) ? `DIV:
									(M_DIVU	== 1'b1) ? `DIVU:
									(M_MFHI	== 1'b1) ? `MFHI:
									(M_MFLO	== 1'b1) ? `MFLO:
									(M_MTHI	== 1'b1) ? `MTHI:
									(M_MTLO	== 1'b1) ? `MTLO:
									(M_Mr		== 1'b1) ? `Mr:
									
									//其他
									(M_nop 	== 1'b1) ? `Nop:
									(M_mfc0 	== 1'b1) ? `Mfc0:
									(M_mtc0 	== 1'b1) ? `Mtc0:
									(M_eret 	== 1'b1) ? `Eret:

																	7'd126;
																	
	assign W_Instrlist	=	//三目ALU
									(W_addu 	== 1'b1) ? `Addu:
									(W_subu 	== 1'b1) ? `Subu:
									(W_add 	== 1'b1) ? `Add:
									(W_sub 	== 1'b1) ? `Sub:
									(W_and 	== 1'b1) ? `And:
									(W_or 	== 1'b1) ? `Or:
									(W_xor 	== 1'b1) ? `Xor:
									(W_nor 	== 1'b1) ? `Nor:
									(W_slt 	== 1'b1) ? `Slt:
									(W_sltu 	== 1'b1) ? `Sltu:
									(W_sll 	== 1'b1) ? `Sll:
									(W_srl 	== 1'b1) ? `Srl:
									(W_sra 	== 1'b1) ? `Sra:
									(W_sllv 	== 1'b1) ? `Sllv:
									(W_srlv 	== 1'b1) ? `Srlv:
									(W_srav 	== 1'b1) ? `Srav:
									(W_cal 	== 1'b1) ? `Cal:
									
									//立即数ALU
									(W_lui 	== 1'b1) ? `Lui:
									(W_addi 	== 1'b1) ? `Addi:
									(W_addiu == 1'b1) ? `Addiu:
									(W_andi 	== 1'b1) ? `Andi:
									(W_ori 	== 1'b1) ? `Ori:
									(W_xori	== 1'b1) ? `Xori:
									(W_slti 	== 1'b1) ? `Slti:
									(W_sltiu == 1'b1) ? `Sltiu:
									(W_cai 	== 1'b1) ? `Cai:
									
									//跳转
									(W_beq 	== 1'b1) ? `Beq:
									(W_bne 	== 1'b1) ? `Bne:
									(W_blez 	== 1'b1) ? `Blez:
									(W_bgtz 	== 1'b1) ? `Bgtz:
									(W_bltz 	== 1'b1) ? `Bltz:
									(W_bgez 	== 1'b1) ? `Bgez:
									(W_jal 	== 1'b1) ? `Jal:
									(W_jr 	== 1'b1) ? `Jr:
									(W_j 		== 1'b1) ? `J:
									(W_jalr 	== 1'b1) ? `Jalr:
									(W_bal 	== 1'b1) ? `Bal:
									
									//Load
									(W_lw 	== 1'b1) ? `Lw:
									(W_lb 	== 1'b1) ? `Lb:
									(W_lbu 	== 1'b1) ? `Lbu:
									(W_lh 	== 1'b1) ? `Lh:
									(W_lhu 	== 1'b1) ? `Lhu:
									(W_lr 	== 1'b1) ? `Lr:
									(W_lr1 	== 1'b1) ? `Lr1:
									
									//Store
									(W_sw 	== 1'b1) ? `Sw:
									(W_sb 	== 1'b1) ? `Sb:
									(W_sh 	== 1'b1) ? `Sh:
									(W_sr 	== 1'b1) ? `Sr:
									
									//MDU乘除
									(W_MULT	== 1'b1) ? `MULT:
									(W_MULTU	== 1'b1) ? `MULTU:
									(W_DIV	== 1'b1) ? `DIV:
									(W_DIVU	== 1'b1) ? `DIVU:
									(W_MFHI	== 1'b1) ? `MFHI:
									(W_MFLO	== 1'b1) ? `MFLO:
									(W_MTHI	== 1'b1) ? `MTHI:
									(W_MTLO	== 1'b1) ? `MTLO:
									(W_Mr		== 1'b1) ? `Mr:
									
									//其他
									(W_nop 	== 1'b1) ? `Nop:
									(W_mfc0 	== 1'b1) ? `Mfc0:
									(W_mtc0 	== 1'b1) ? `Mtc0:
									(W_eret 	== 1'b1) ? `Eret:

																	7'd126;
//周期 Ⅰ		 -> 指令
always @(*) begin
	I_Instr_out = 
					  //(I_Instr_in == 32'bx) ? 32'b0:
					  (interrupt) ? 32'b0 :
					  (freeze) ? D_Instr_in :
					  (Nulldelayslot | D_eret | E_eret | M_eret) ? 32'b0 : I_Instr_in;
	I_PC_out 	= (freeze) ? D_PC_in 	:
					  (Nulldelayslot) ? 32'b0 : I_PC_in;
	I_BD_out			= (freeze) ? D_BD_in : 
						  (D_beq | D_bne | D_blez| D_bgtz | D_bltz | D_bgez | D_jr | D_jalr | D_j | D_jal);
end

//周期 Ⅱ	指令 -> 读寄存器
always @(*) begin
			
    case(D_Instrlist)
			//三目ALU
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'd0;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'd1;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Add:
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'd12;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Sub: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'd13;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`And:
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'd2;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Or: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'd3;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Xor:
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'd6;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Nor: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'd5;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Slt:
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'd10;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Sltu: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'd11;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Sll: 
				begin
					//左 -> datapath接收
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//关心的寄存器的值
					CareGFadd1_D = 5'd0;	//关心的寄存器1地址
					CareGFadd2_D = D_rt;	//关心的寄存器2地址
					
					askdata1_E = 32'd0;
					askdata2_E = CareGF2_D;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= {27'b0,D_Instr_in[10:6]};
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'd7;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Srl: 
				begin
					//左 -> datapath接收
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//关心的寄存器的值
					CareGFadd1_D = 5'd0;	//关心的寄存器1地址
					CareGFadd2_D = D_rt;	//关心的寄存器2地址
					
					askdata1_E = 32'd0;
					askdata2_E = CareGF2_D;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= {27'b0,D_Instr_in[10:6]};
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'd8;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Sra: 
				begin
					//左 -> datapath接收
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//关心的寄存器的值
					CareGFadd1_D = 5'd0;	//关心的寄存器1地址
					CareGFadd2_D = D_rt;	//关心的寄存器2地址
					
					askdata1_E = 32'd0;
					askdata2_E = CareGF2_D;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= {27'b0,D_Instr_in[10:6]};
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'd9;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Sllv: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'd7;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Srlv: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'd8;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Srav: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'd9;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'd12;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= 32'b0;
					D_Num2_out	= {16'b0,D_Instr_in[15:0]};
					D_ALUopcode_out = 4'd4;
					D_WEGF_out	= 1'b1;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {{16{D_Instr_in[15]}},D_Instr_in[15:0]};
					D_ALUopcode_out = 4'd12;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
									
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Addiu: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {{16{D_Instr_in[15]}},D_Instr_in[15:0]};
					D_ALUopcode_out = 4'd0;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
									
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Andi: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {16'b0,D_Instr_in[15:0]};
					D_ALUopcode_out = 4'd2;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
									
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {16'b0,D_Instr_in[15:0]};
					D_ALUopcode_out = 4'd3;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
									
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Xori: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {16'b0,D_Instr_in[15:0]};
					D_ALUopcode_out = 4'd6;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
									
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Slti: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {{16{D_Instr_in[15]}},D_Instr_in[15:0]};
					D_ALUopcode_out = 4'd10;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
									
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Sltiu: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {{16{D_Instr_in[15]}},D_Instr_in[15:0]};
					D_ALUopcode_out = 4'd11;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
									
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {{16{D_Instr_in[15]}},D_Instr_in[15:0]};
					D_ALUopcode_out = 4'd12;
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
									
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= 32'b0;
					D_Num2_out	= 32'b0;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					//清空延迟槽示例
//					Nulldelayslot = (freeze) ? 1'b0:
//									  ((CareGF1_D == CareGF2_D)) ? 1'b1 : 1'b0;
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Bne: 
				begin
					//beq类需要提前关心
					//关心的寄存器
					CareGFadd1_D = D_rs;	//关心的寄存器1地址
					CareGFadd2_D = D_rt;	//关心的寄存器2地址
					
					askdata1_E = CareGF1_D;
					askdata2_E = CareGF2_D;
					
					
					//左 -> datapath接收
					Jumpsign		= (freeze) ? 1'b0:
									  ((CareGF1_D != CareGF2_D)) ? 1'b1 : 1'b0;
					JumpAddr		= (freeze) ? 32'b0:
									  ((CareGF1_D != CareGF2_D)) ? (D_PC_in + 4 + {{14{D_Instr_in[15]}}, D_Instr_in[15:0], 2'b00}) : 
																																									32'b0;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= 32'b0;
					D_Num2_out	= 32'b0;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Blez: 
				begin
					//beq类需要提前关心
					//关心的寄存器
					CareGFadd1_D = D_rs;	//关心的寄存器1地址
					CareGFadd2_D = 5'b0;	//关心的寄存器2地址
					
					askdata1_E = CareGF1_D;
					askdata2_E = 32'b0;
					
					
					//左 -> datapath接收
					Jumpsign		= (freeze) ? 1'b0:
									  (CareGF1_D[31] | (CareGF1_D == 0)) ? 1'b1 : 1'b0;
					JumpAddr		= (freeze) ? 32'b0:
									  (CareGF1_D[31] | (CareGF1_D == 0)) ? (D_PC_in + 4 + {{14{D_Instr_in[15]}}, D_Instr_in[15:0], 2'b00}) : 
																																									32'b0;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= 32'b0;
					D_Num2_out	= 32'b0;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Bgtz: 
				begin
					//beq类需要提前关心
					//关心的寄存器
					CareGFadd1_D = D_rs;	//关心的寄存器1地址
					CareGFadd2_D = 5'b0;	//关心的寄存器2地址
					
					askdata1_E = CareGF1_D;
					askdata2_E = 32'b0;
					
					
					//左 -> datapath接收
					Jumpsign		= (freeze) ? 1'b0:
									  ((!CareGF1_D[31]) & (CareGF1_D != 0)) ? 1'b1 : 1'b0;
					JumpAddr		= (freeze) ? 32'b0:
									  ((!CareGF1_D[31]) & (CareGF1_D != 0)) ? (D_PC_in + 4 + {{14{D_Instr_in[15]}}, D_Instr_in[15:0], 2'b00}) : 
																																									32'b0;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= 32'b0;
					D_Num2_out	= 32'b0;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Bltz: 
				begin
					//beq类需要提前关心
					//关心的寄存器
					CareGFadd1_D = D_rs;	//关心的寄存器1地址
					CareGFadd2_D = 5'b0;	//关心的寄存器2地址
					
					askdata1_E = CareGF1_D;
					askdata2_E = 32'b0;
					
					
					//左 -> datapath接收
					Jumpsign		= (freeze) ? 1'b0:
									  (CareGF1_D[31]) ? 1'b1 : 1'b0;
					JumpAddr		= (freeze) ? 32'b0:
									  (CareGF1_D[31]) ? (D_PC_in + 4 + {{14{D_Instr_in[15]}}, D_Instr_in[15:0], 2'b00}) : 
																																									32'b0;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= 32'b0;
					D_Num2_out	= 32'b0;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Bgez: 
				begin
					//beq类需要提前关心
					//关心的寄存器
					CareGFadd1_D = D_rs;	//关心的寄存器1地址
					CareGFadd2_D = 5'b0;	//关心的寄存器2地址
					
					askdata1_E = CareGF1_D;
					askdata2_E = 32'b0;
					
					
					//左 -> datapath接收
					Jumpsign		= (freeze) ? 1'b0:
									  (!CareGF1_D[31]) ? 1'b1 : 1'b0;
					JumpAddr		= (freeze) ? 32'b0:
									  (!CareGF1_D[31]) ? (D_PC_in + 4 + {{14{D_Instr_in[15]}}, D_Instr_in[15:0], 2'b00}) : 
																																									32'b0;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= 32'b0;
					D_Num2_out	= 32'b0;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= D_PC_in;
					D_Num2_out	= 32'd8;
					D_ALUopcode_out = 4'b0; //aluresult = pc + 8
					D_WEGF_out	= 1'b1;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
			
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= 32'b0;
					D_Num2_out	= 32'b0;
					D_ALUopcode_out = 4'b0; 
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
		
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= 32'b0;
					D_Num2_out	= 32'b0;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;

					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
			
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= D_PC_in;
					D_Num2_out	= 32'd8;
					D_ALUopcode_out = 4'b0; //aluresult = pc + 8
					D_WEGF_out	= ~freeze;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Bal:
				begin
					//beq类需要提前关心
					//关心的寄存器
					CareGFadd1_D = 5'd29;	//关心的寄存器1地址
					CareGFadd2_D = 5'd0;	//关心的寄存器2地址
					
					askdata1_E = CareGF1_D;
					askdata2_E = 32'd0;
					
					
					//左 -> datapath接收
					Jumpsign		= (~freeze) ? 1'b1 : 1'b0;
					JumpAddr		= (~freeze) ?(D_PC_in + 4 + {{14{D_Instr_in[15]}}, D_Instr_in[15:0], 2'b00}) : 
																																									32'b0;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= 32'd4;
					D_ALUopcode_out = 4'b0; //aluresult = pc + 8
					D_WEGF_out	= (freeze) ? 1'b0:1'b1 ;
					D_WEDM_out	= (freeze) ? 4'b0:4'b1111 ;
					
					Nulldelayslot = 1'b0;

					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {{16{D_Instr_in[15]}},D_Instr_in[15:0]};
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= ~(freeze | interrupt);
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;	

					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Lb:
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {{16{D_Instr_in[15]}},D_Instr_in[15:0]};
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= ~(freeze | interrupt);
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;	

					D_ExcCode_out = D_ExcCode_in;	
					D_ExcPC_out = D_ExcPC_in;
				end
			`Lbu:
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {{16{D_Instr_in[15]}},D_Instr_in[15:0]};
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= ~(freeze | interrupt);
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;	

					D_ExcCode_out = D_ExcCode_in;	
					D_ExcPC_out = D_ExcPC_in;
				end
			`Lh:
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {{16{D_Instr_in[15]}},D_Instr_in[15:0]};
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= ~(freeze | interrupt);
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;		

					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;					
				end
			`Lhu:
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {{16{D_Instr_in[15]}},D_Instr_in[15:0]};
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= ~(freeze | interrupt);
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;	

					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;					
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {{16{D_Instr_in[15]}},D_Instr_in[15:0]};
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
								
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Lr1:
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {{16{D_Instr_in[15]}},D_Instr_in[15:0]};
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
								
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {{16{D_Instr_in[15]}},D_Instr_in[15:0]};
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= (~(freeze | interrupt)) ? 4'b1111 : 4'b0;
					
					Nulldelayslot = 1'b0;	

					D_ExcCode_out = D_ExcCode_in;	
					D_ExcPC_out = D_ExcPC_in;					
				end
			`Sb: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {{16{D_Instr_in[15]}},D_Instr_in[15:0]};
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= (~(freeze | interrupt)) ? 4'b1111 : 4'b0;
					
					Nulldelayslot = 1'b0;	

					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Sh: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {{16{D_Instr_in[15]}},D_Instr_in[15:0]};
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= (~(freeze | interrupt)) ? 4'b1111 : 4'b0;
					
					Nulldelayslot = 1'b0;		

					D_ExcCode_out = D_ExcCode_in;		
					D_ExcPC_out = D_ExcPC_in;					
				end
			`Sr: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= {{16{D_Instr_in[15]}},D_Instr_in[15:0]};
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= (~(freeze | interrupt)) ? 4'b1111 : 4'b0;
					
					Nulldelayslot = 1'b0;	

					D_ExcCode_out = D_ExcCode_in;					
					D_ExcPC_out = D_ExcPC_in;
				end
			
			`MULT: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
						
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`MULTU: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
						
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`DIV: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
						
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`DIVU: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
						
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`MFHI: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= 32'b0;
					D_Num2_out	= 32'b0;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b1;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
						
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`MFLO: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= 32'b0;
					D_Num2_out	= 32'b0;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b1;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
						
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`MTHI: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= 32'b0;
					D_Num2_out	= 32'b0;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
						
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`MTLO: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= 32'b0;
					D_Num2_out	= 32'b0;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
						
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Mr: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= CareGF1_D;
					D_Num2_out	= CareGF2_D;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= 32'b0;
					D_Num2_out	= 32'b0;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Mfc0: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= 32'b0;
					D_Num2_out	= 32'b0;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b1;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Mtc0: 
				begin
					//左 -> datapath接收
					Jumpsign		= 1'b0;
					JumpAddr		= 32'b0;
					
					//关心的寄存器
					CareGFadd1_D = D_rt;	//关心的寄存器1地址
					CareGFadd2_D = 5'b0;	//关心的寄存器2地址
					
					askdata1_E = CareGF1_D;
					askdata2_E = 32'b0;
					
					//右 -> ID/EX接收
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= 32'b0;
					D_Num2_out	= 32'b0;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
			`Eret: 
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
					D_Instr_out	= (freeze | interrupt)? 32'b0 : D_Instr_in;
					D_PC_out		= (freeze | interrupt)? 32'b0 : D_PC_in;
					D_Num1_out	= 32'b0;
					D_Num2_out	= 32'b0;
					D_ALUopcode_out = 4'b0;
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					Nulldelayslot = 1'b0;
					
					D_ExcCode_out = D_ExcCode_in;
					D_ExcPC_out = D_ExcPC_in;
				end
				
        default:
				begin
					//donothing
					D_WEGF_out	= 1'b0;
					D_WEDM_out	= 4'b0;
					
					D_ExcCode_out = (D_ExcCode_in != 5'd4 ) ? 5'd10 : 5'd4;
					D_ExcPC_out = (D_ExcCode_in != 5'd4 ) ? D_PC_in : D_ExcPC_in;
				end
				
    endcase
	 D_BD_out			= (freeze) ? E_BD_in : D_BD_in;
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
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
	
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
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
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Add:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = CareGF2_E;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Sub:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = CareGF2_E;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`And:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = CareGF2_E;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Or:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = CareGF2_E;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Xor:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = CareGF2_E;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Nor:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = CareGF2_E;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Slt:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = CareGF2_E;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Sltu:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = CareGF2_E;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Sll:
				begin
					//关心的寄存器
					CareGFadd1_E = 5'd0;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = 32'd0;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = E_Num1_in;							 
					ALUinput2	 = CareGF2_E;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Srl:
				begin
					//关心的寄存器
					CareGFadd1_E = 5'd0;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = 32'd0;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = E_Num1_in;							 
					ALUinput2	 = CareGF2_E;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Sra:
				begin
					//关心的寄存器
					CareGFadd1_E = 5'd0;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = 32'd0;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = E_Num1_in;							 
					ALUinput2	 = CareGF2_E;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Sllv:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = CareGF2_E;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Srlv:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = CareGF2_E;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Srav:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = CareGF2_E;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
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
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			//alu立即数
			`Lui:
				begin
					//关心的寄存器
					CareGFadd1_E = 5'b0;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = 32'b0;
					askdata2_M = 32'b0;
					
					ALUinput1	 = E_Num1_in;							 
					ALUinput2	 = E_Num2_in;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rt;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
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
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rt;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Addiu:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = 32'b0;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = E_Num2_in;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rt;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Andi:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = 32'b0;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = E_Num2_in;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rt;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
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
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rt;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Xori:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = 32'b0;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = E_Num2_in;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rt;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Slti:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = 32'b0;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = E_Num2_in;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rt;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Sltiu:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = 32'b0;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = E_Num2_in;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rt;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
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
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rt;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
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
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = 5'b0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Bne:
				begin
					//关心的寄存器
					CareGFadd1_E = 5'b0;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = 32'b0;
					askdata2_M = 32'b0;
					
					ALUinput1	 = E_Num1_in;							 
					ALUinput2	 = E_Num2_in;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = 5'b0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Blez:
				begin
					//关心的寄存器
					CareGFadd1_E = 5'b0;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = 32'b0;
					askdata2_M = 32'b0;
					
					ALUinput1	 = E_Num1_in;							 
					ALUinput2	 = E_Num2_in;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = 5'b0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Bgtz:
				begin
					//关心的寄存器
					CareGFadd1_E = 5'b0;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = 32'b0;
					askdata2_M = 32'b0;
					
					ALUinput1	 = E_Num1_in;							 
					ALUinput2	 = E_Num2_in;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = 5'b0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Bltz:
				begin
					//关心的寄存器
					CareGFadd1_E = 5'b0;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = 32'b0;
					askdata2_M = 32'b0;
					
					ALUinput1	 = E_Num1_in;							 
					ALUinput2	 = E_Num2_in;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = 5'b0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Bgez:
				begin
					//关心的寄存器
					CareGFadd1_E = 5'b0;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = 32'b0;
					askdata2_M = 32'b0;
					
					ALUinput1	 = E_Num1_in;							 
					ALUinput2	 = E_Num2_in;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = 5'b0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
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
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = 5'b11111;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
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
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = 5'b0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
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
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = 5'b0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
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
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Bal:
				begin
					//关心的寄存器
					CareGFadd1_E = 5'd29;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = 32'b0;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = E_Num2_in;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = 5'd29;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
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
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rt;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b1;
				end
			`Lb:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = 32'b0;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = E_Num2_in;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rt;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b1;
				end
			`Lbu:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = 32'b0;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = E_Num2_in;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rt;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b1;
				end
			`Lh:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = 32'b0;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = E_Num2_in;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rt;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b1;
				end
			`Lhu:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = 32'b0;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = E_Num2_in;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rt;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b1;
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
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
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
					CareGFadd2_E = 5'd0;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = 32'd0;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = E_Num2_in;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rt;
					E_add_write_plus = 5'd31;
					E_type_write = 1'b0;
					
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
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = 5'b0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Sb:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = E_Num2_in;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = 5'b0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Sh:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = E_Num2_in;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = 5'b0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Sr:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = E_Num2_in;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'b0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = 5'b0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`MULT:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = 32'b0;							 
					ALUinput2	 = 32'b0;
					
					MDU_inputA	 = CareGF1_E;
					MDU_inputB	 = CareGF2_E;
					MDU_start	 = 1'b1;
					MDUOp			 = 3'd1;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = 5'b0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`MULTU:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = 32'b0;							 
					ALUinput2	 = 32'b0;
					
					MDU_inputA	 = CareGF1_E;
					MDU_inputB	 = CareGF2_E;
					MDU_start	 = 1'b1;
					MDUOp			 = 3'd0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = 5'b0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`DIV:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = 32'b0;							 
					ALUinput2	 = 32'b0;
					
					MDU_inputA	 = CareGF1_E;
					MDU_inputB	 = CareGF2_E;
					MDU_start	 = 1'b1;
					MDUOp			 = 3'd3;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = 5'b0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`DIVU:
				begin
					begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = 32'b0;							 
					ALUinput2	 = 32'b0;
					
					MDU_inputA	 = CareGF1_E;
					MDU_inputB	 = CareGF2_E;
					MDU_start	 = 1'b1;
					MDUOp			 = 3'd2;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = 5'b0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
				end
			`MFHI:
				begin
					//关心的寄存器
					CareGFadd1_E = 5'b0;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = 32'b0;
					askdata2_M = 32'b0;
					
					ALUinput1	 = 32'b0;							 
					ALUinput2	 = 32'b0;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'd0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`MFLO:
				begin
					//关心的寄存器
					CareGFadd1_E = 5'b0;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = 32'b0;
					askdata2_M = 32'b0;
					
					ALUinput1	 = 32'b0;							 
					ALUinput2	 = 32'b0;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'd0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rd;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`MTHI:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = 32'b0;
					
					ALUinput1	 = 32'b0;							 
					ALUinput2	 = 32'b0;
					
					MDU_inputA	 = CareGF1_E;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'd0;
					HIWrite		 = 1'b1;
					LOWrite		 = 1'b0;
					
					E_add_write  = 5'd0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`MTLO:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = 32'b0;
					
					ALUinput1	 = 32'b0;							 
					ALUinput2	 = 32'b0;
					
					MDU_inputA	 = CareGF1_E;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'd0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b1;
					
					E_add_write  = 5'd0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Mr:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rs;	//关心的寄存器1地址
					CareGFadd2_E = E_rt;	//关心的寄存器2地址
					askdata1_M = CareGF1_E;
					askdata2_M = CareGF2_E;
					
					ALUinput1	 = 32'b0;							 
					ALUinput2	 = 32'b0;
					
					MDU_inputA	 = CareGF1_E;
					MDU_inputB	 = CareGF2_E;
					MDU_start	 = 1'b1;
					MDUOp			 = 3'd4;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = 5'b0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Nop:
				begin
					//关心的寄存器
					CareGFadd1_E = 5'b0;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = 32'b0;
					askdata2_M = 32'b0;
					
					ALUinput1	 = 32'b0;							 
					ALUinput2	 = 32'b0;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'd0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = 5'd0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Mfc0:
				begin
					//关心的寄存器
					CareGFadd1_E = 5'b0;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = 32'b0;
					askdata2_M = 32'b0;
					
					ALUinput1	 = 32'b0;							 
					ALUinput2	 = 32'b0;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'd0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = E_rt;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b1;
				end
			`Mtc0:
				begin
					//关心的寄存器
					CareGFadd1_E = E_rt;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = 32'b0;
					askdata2_M = 32'b0;
					
					ALUinput1	 = CareGF1_E;							 
					ALUinput2	 = 32'b0;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'd0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = 5'd0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			`Eret:
				begin
					//关心的寄存器
					CareGFadd1_E = 5'b0;	//关心的寄存器1地址
					CareGFadd2_E = 5'b0;	//关心的寄存器2地址
					askdata1_M = 32'b0;
					askdata2_M = 32'b0;
					
					ALUinput1	 = 32'b0;							 
					ALUinput2	 = 32'b0;
					
					MDU_inputA	 = 32'b0;
					MDU_inputB	 = 32'b0;
					MDU_start	 = 1'b0;
					MDUOp			 = 3'd0;
					HIWrite		 = 1'b0;
					LOWrite		 = 1'b0;
					
					E_add_write  = 5'd0;
					E_add_write_plus = 5'd0;
					E_type_write = 1'b0;
				end
			
	endcase
	
	//左 -> datapath接收
	ALUopcode		= E_ALUopcode_in;

	//右 -> EX/MEM接收
	E_Instr_out 	= (interrupt) ? 32'b0 : E_Instr_in;
	E_PC_out 		= E_PC_in;
	E_BD_out			= E_BD_in;
	E_ALUresult_out= (E_MFHI) ? HIRead :
						  (E_MFLO) ? LORead :
													ALUresult;
	E_WEGF_out		= E_WEGF_in;
	E_WEDM_out		= E_WEDM_in;
	
end

//周期 Ⅳ	ALU -> 数据存储器
always @(*) begin
	//左 -> datapath接收
	M_readenable 	= (M_lw) ? 2'b11 :
						  (M_lh | M_lhu) ? 2'b10 :
						  (M_lb | M_lbu) ? 2'b01 : 2'b00;
	readDMadd		= (M_lb | M_lbu | M_lh | M_lhu | M_lw) ? M_ALUresult_in : 32'd0;
	
	Read_CP0_add	=  (M_mfc0 == 1'b1) ? M_rd : 5'b0;
	
	case(M_Instrlist)
			`Addu:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
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
					WEdm				= 4'b0;
					
					M_add_write  = M_rd;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Add:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rd;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Sub:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rd;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`And:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rd;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Or:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rd;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Xor:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rd;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Nor:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rd;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Slt:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rd;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Sltu:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rd;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Sll:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rd;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Srl:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rd;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Sra:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rd;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Sllv:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rd;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Srlv:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rd;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Srav:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rd;
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
					WEdm				= 4'b0;
					
					M_add_write  = M_rd;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
				
			//alu立即数
			`Lui:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rt;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Addi:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rt;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Addiu:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rt;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Andi:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
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
					WEdm				= 4'b0;
					
					M_add_write  = M_rt;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Xori:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rt;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Slti:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rt;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Sltiu:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rt;
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
					WEdm				= 4'b0;
					
					M_add_write  = M_rt;
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
					WEdm				= 4'b0;
					
					M_add_write  = 5'b0;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Bne:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = 5'b0;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Blez:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = 5'b0;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Bgtz:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = 5'b0;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Bltz:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = 5'b0;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Bgez:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
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
					WEdm				= 4'b0;
					
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
					WEdm				= 4'b0;
					
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
					WEdm				= 4'b0;
					
					M_add_write  = 5'b0;
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
					WEdm				= 4'b0;
					
					M_add_write  = M_rd;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Bal:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'd29;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= CareGF1_M;
					WriteDMdata		= M_PC_in + 8;
					WEdm				= 4'b0;
					
					M_add_write  = 5'd29;
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
					WEdm				= 4'b0;
					
					M_add_write  = M_rt;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b1;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Lb:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rt;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b1;
					
					M_DMdata_out	= (M_ALUresult_in[1:0] == 2'b00) ? {{24{ReadDM[7]}},ReadDM[7:0]}:
										  (M_ALUresult_in[1:0] == 2'b01) ? {{24{ReadDM[15]}},ReadDM[15:8]}:
										  (M_ALUresult_in[1:0] == 2'b10) ? {{24{ReadDM[23]}},ReadDM[23:16]}:
										  (M_ALUresult_in[1:0] == 2'b11) ? {{24{ReadDM[31]}},ReadDM[31:24]}: 32'b0;
					M_WEGF_out		= M_WEGF_in;
				end
			`Lbu:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rt;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b1;
					
					M_DMdata_out	= (M_ALUresult_in[1:0] == 2'b00) ? {24'b0,ReadDM[7:0]}:
										  (M_ALUresult_in[1:0] == 2'b01) ? {24'b0,ReadDM[15:8]}:
										  (M_ALUresult_in[1:0] == 2'b10) ? {24'b0,ReadDM[23:16]}:
										  (M_ALUresult_in[1:0] == 2'b11) ? {24'b0,ReadDM[31:24]}: 32'b0;
					M_WEGF_out		= M_WEGF_in;
				end
			`Lh:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rt;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b1;
					
					M_DMdata_out	= (M_ALUresult_in[1] == 1'b0) ? {{16{ReadDM[15]}},ReadDM[15:0]}:
										  (M_ALUresult_in[1] == 1'b1) ? {{16{ReadDM[31]}},ReadDM[31:16]}:32'b0;
					M_WEGF_out		= M_WEGF_in;
				end
			`Lhu:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rt;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b1;
					
					M_DMdata_out	= (M_ALUresult_in[1] == 1'b0) ? {16'b0,ReadDM[15:0]}:
										  (M_ALUresult_in[1] == 1'b1) ? {16'b0,ReadDM[31:16]}:32'b0;
					M_WEGF_out		= M_WEGF_in;
				end
			`Lr:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = M_rt;	//关心的寄存器2地址

					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = ReadDM[4:0];
					M_add_write_plus = 5'd0;
					M_type_write = 1'b1;
					
					M_DMdata_out	= CareGF2_M;
					M_WEGF_out		= 1'b1;
				end
			`Lr1:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = (ReadDM[31]) ? 5'd31 : M_rt;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b1;
					
					M_DMdata_out	= (ReadDM[31]) ? M_PC_in + 4 : ReadDM;
					M_WEGF_out		= 1'b1;
				end
			`Sw:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = M_rt;	//关心的寄存器2地址

					
					WriteDMadd		= M_ALUresult_in;
					WriteDMdata		= CareGF2_M;
					WEdm				= M_WEDM_in;
					
					M_add_write  = 5'b0;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
					
				end
			`Sb:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = M_rt;	//关心的寄存器2地址

					
					WriteDMadd		= M_ALUresult_in;
					WriteDMdata		= (M_ALUresult_in[1:0] == 2'b00) ? CareGF2_M :
										  (M_ALUresult_in[1:0] == 2'b01) ? (CareGF2_M << 8) :
										  (M_ALUresult_in[1:0] == 2'b10) ? (CareGF2_M << 16) :
										  (M_ALUresult_in[1:0] == 2'b11) ? (CareGF2_M << 24) : CareGF2_M;
					WEdm				= (M_WEDM_in == 4'b0000) ? 4'b0000 :
										  (M_ALUresult_in[1:0] == 2'b00) ? 4'b0001 :
										  (M_ALUresult_in[1:0] == 2'b01) ? 4'b0010 :
										  (M_ALUresult_in[1:0] == 2'b10) ? 4'b0100 :
										  (M_ALUresult_in[1:0] == 2'b11) ? 4'b1000 : M_WEDM_in;
					
					M_add_write  = 5'b0;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Sh:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = M_rt;	//关心的寄存器2地址

					
					WriteDMadd		= M_ALUresult_in;
					WriteDMdata		= (M_ALUresult_in[1] == 1'b0) ? CareGF2_M :
										  (M_ALUresult_in[1] == 1'b1) ? (CareGF2_M << 16) : CareGF2_M;					
					WEdm				= (M_WEDM_in == 4'b0000) ? 4'b0000 :
										  (M_ALUresult_in[1] == 1'b0) ? 4'b0011 :
										  (M_ALUresult_in[1] == 1'b1) ? 4'b1100 : M_WEDM_in;
										  
					M_add_write  = 5'b0;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Sr:
				begin
					//关心的寄存器
					CareGFadd1_M = M_rs;	//关心的寄存器1地址
					CareGFadd2_M = M_rt;	//关心的寄存器2地址

					
					WriteDMadd		= M_ALUresult_in;
					WriteDMdata		= CareGF1_M + CareGF2_M;
					WEdm				= 4'b1111;
					
					M_add_write  = 5'b0;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
					
				end
			`MULT:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = 5'b0;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`MULTU:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = 5'b0;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`DIV:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = 5'b0;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`DIVU:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = 5'b0;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`MFHI:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rd;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`MFLO:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rd;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`MTHI:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = 5'b0;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`MTLO:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = 5'b0;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Mr:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
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
					WEdm				= 4'b0;
					
					M_add_write  = 5'b0;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= 32'b0;
					M_WEGF_out		= 1'b0;
				end
			`Mfc0:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = M_rt;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b1;
					
					M_DMdata_out	= Read_CP0_data;
					M_WEGF_out		= 1'b1;
				end
			`Mtc0:
				begin
					//关心的寄存器
					CareGFadd1_M = M_rt;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = 5'b0;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			`Eret:
				begin
					//关心的寄存器
					CareGFadd1_M = 5'b0;	//关心的寄存器1地址
					CareGFadd2_M = 5'b0;	//关心的寄存器2地址

					
					WriteDMadd		= 32'b0;
					WriteDMdata		= 5'b0;
					WEdm				= 4'b0;
					
					M_add_write  = 5'b0;
					M_add_write_plus = 5'd0;
					M_type_write = 1'b0;
					
					M_DMdata_out	= ReadDM;
					M_WEGF_out		= M_WEGF_in;
				end
			default:
				begin
					WEdm				= 4'd0;
					M_WEGF_out		= 1'b0;
				end
				

	endcase
	
	WECP0				= (M_mtc0 | interrupt);
	Wirte_CP0_data = (M_mtc0) ? CareGF1_M :
						  (interrupt) ? M_PC_in : 32'b0;
	Wirte_CP0_add	= (M_mtc0) ? M_rd		  :
						  (interrupt) ? 5'd14  : 5'b0;
	Eret				=  M_eret;
	EretPC			=  interrupt ? M_PC_in : 32'b0;
	BD					= M_BD_in;
	
	//右 -> MEM/WB接收
	M_Instr_out		= (interrupt) ? 32'b0 : M_Instr_in;
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
			`Add:
				begin
					WriteGFadd	= W_rd; 
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rd;
					W_type_write = 1'b0;
				end
			`Sub: 
				begin
					WriteGFadd	= W_rd;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rd;
					W_type_write = 1'b0;
				end
			`And:
				begin
					WriteGFadd	= W_rd; 
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rd;
					W_type_write = 1'b0;
				end
			`Or: 
				begin
					WriteGFadd	= W_rd;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rd;
					W_type_write = 1'b0;
				end
			`Xor:
				begin
					WriteGFadd	= W_rd; 
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rd;
					W_type_write = 1'b0;
				end
			`Nor: 
				begin
					WriteGFadd	= W_rd;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rd;
					W_type_write = 1'b0;
				end
			`Slt:
				begin
					WriteGFadd	= W_rd; 
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rd;
					W_type_write = 1'b0;
				end
			`Sltu: 
				begin
					WriteGFadd	= W_rd;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rd;
					W_type_write = 1'b0;
				end
			`Sll:
				begin
					WriteGFadd	= W_rd; 
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rd;
					W_type_write = 1'b0;
				end
			`Srl:
				begin
					WriteGFadd	= W_rd; 
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rd;
					W_type_write = 1'b0;
				end
			`Sra:
				begin
					WriteGFadd	= W_rd; 
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rd;
					W_type_write = 1'b0;
				end
			`Sllv:
				begin
					WriteGFadd	= W_rd; 
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rd;
					W_type_write = 1'b0;
				end
			`Srlv:
				begin
					WriteGFadd	= W_rd; 
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rd;
					W_type_write = 1'b0;
				end
			`Srav:
				begin
					WriteGFadd	= W_rd; 
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rd;
					W_type_write = 1'b0;
				end
			`Cal:
				begin
					WriteGFadd	= W_rd; 
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rd;
					W_type_write = 1'b0;
				end
			//alu立即数
			`Lui: 
				begin
					WriteGFadd	= W_rt;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rt;
					W_type_write = 1'b0;
				end
			`Addi: 
				begin
					WriteGFadd	= W_rt;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rt;
					W_type_write = 1'b0;
				end
			`Addiu: 
				begin
					WriteGFadd	= W_rt;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rt;
					W_type_write = 1'b0;
				end
			`Andi: 
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
			`Xori: 
				begin
					WriteGFadd	= W_rt;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rt;
					W_type_write = 1'b0;
				end
			`Slti: 
				begin
					WriteGFadd	= W_rt;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rt;
					W_type_write = 1'b0;
				end
			`Sltiu: 
				begin
					WriteGFadd	= W_rt;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rt;
					W_type_write = 1'b0;
				end
			`Cai: 
				begin
					WriteGFadd	= W_rt;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rt;
					W_type_write = 1'b0;
				end
			
			`Beq: 
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 5'b0;
					W_type_write = 1'b0;
				end
			`Bne: 
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 5'b0;
					W_type_write = 1'b0;
				end
			`Blez: 
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 5'b0;
					W_type_write = 1'b0;
				end
			`Bgtz: 
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 5'b0;
					W_type_write = 1'b0;
				end
			`Bltz: 
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 5'b0;
					W_type_write = 1'b0;
				end
			`Bgez: 
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
			`Jalr: 
				begin
					WriteGFadd	= W_rd;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rd;
					W_type_write = 1'b0;
				end
			`Bal: 
				begin
					WriteGFadd	= 5'd29;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = 5'd29;
					W_type_write = 1'b0;
				end
			`Lw:
				begin
					WriteGFadd	= W_rt;
					WriteGFdata	= W_DMdata_in;
					
					W_add_write  = W_rt;
					W_type_write = 1'b1;
				end
			`Lb:
				begin
					WriteGFadd	= W_rt;
					WriteGFdata	= W_DMdata_in;
					
					W_add_write  = W_rt;
					W_type_write = 1'b1;
				end
			`Lbu:
				begin
					WriteGFadd	= W_rt;
					WriteGFdata	= W_DMdata_in;
					
					W_add_write  = W_rt;
					W_type_write = 1'b1;
				end
			`Lh:
				begin
					WriteGFadd	= W_rt;
					WriteGFdata	= W_DMdata_in;
					
					W_add_write  = W_rt;
					W_type_write = 1'b1;
				end
			`Lhu:
				begin
					WriteGFadd	= W_rt;
					WriteGFdata	= W_DMdata_in;
					
					W_add_write  = W_rt;
					W_type_write = 1'b1;
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
					WriteGFadd	= W_add_write_in;
					WriteGFdata	= W_DMdata_in;
					
					W_add_write  = W_add_write_in;
					W_type_write = 1'b1;
				end
			`Sw: 
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 5'b0;
					W_type_write = 1'b0;
				end
			`Sb: 
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 5'b0;
					W_type_write = 1'b0;
				end
			`Sh: 
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 5'b0;
					W_type_write = 1'b0;
				end
			`Sr: 
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 5'b0;
					W_type_write = 1'b0;
				end
			`MULT: 
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 32'b0;
					W_type_write = 1'b0;
				end
			`MULTU: 
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 32'b0;
					W_type_write = 1'b0;
				end
			`DIV: 
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 32'b0;
					W_type_write = 1'b0;
				end
			`DIVU: 
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 32'b0;
					W_type_write = 1'b0;
				end
			`MFHI: 
				begin
					WriteGFadd	= W_rd;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rd;
					W_type_write = 1'b0;
				end
			`MFLO: 
				begin
					WriteGFadd	= W_rd;
					WriteGFdata	= W_ALUresult_in;
					
					W_add_write  = W_rd;
					W_type_write = 1'b0;
				end
			`MTHI: 
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 32'b0;
					W_type_write = 1'b0;
				end
			`MTLO: 
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 32'b0;
					W_type_write = 1'b0;
				end
			`Mr: 
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 32'b0;
					W_type_write = 1'b0;
				end
			`Nop: 
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 32'b0;
					W_type_write = 1'b0;
				end
			`Mfc0: 
				begin
					WriteGFadd	= W_add_write_in;
					WriteGFdata	= W_DMdata_in;
					
					W_add_write  = W_add_write_in;
					W_type_write = 1'b1;
				end
			`Mtc0: 
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 32'b0;
					W_type_write = 1'b0;
				end
			`Eret: 
				begin
					WriteGFadd	= 5'b0;
					WriteGFdata	= 32'b0;
					
					W_add_write  = 32'b0;
					W_type_write = 1'b0;
				end
				
        default:
				begin
					//donothing
				end
    endcase
end

endmodule