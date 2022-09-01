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
    input reset,
    input [31:0] i_inst_rdata,
    input [31:0] m_data_rdata,
    output [31:0] i_inst_addr,
    output [31:0] m_data_addr,
    output [31:0] m_data_wdata,
    output [3 :0] m_data_byteen,
    output [31:0] m_inst_addr,
    output w_grf_we,
    output [4:0] w_grf_addr,
    output [31:0] w_grf_wdata,
    output [31:0] w_inst_addr
    );
	
	
   wire[31:0]	Instr, PC, ReadGF1, ReadGF2, ReadDM, ALUresult, JumpAddr, WriteGFdata, WriteDMadd, WriteDMdata, readDMadd, ALUinput1, ALUinput2;
	wire[4:0]	WriteGFadd, readGFadd1, readGFadd2;
	wire[3:0]	ALUopcode;
	wire			Jumpsign, WEgf;
	wire[3:0]   WEdm;

	wire[31:0]	I_Instr_out, I_PC_out, D_Instr_in, D_PC_in;
	
	wire[31:0]	D_Instr_out, D_PC_out, E_Instr_in, E_PC_in, D_Num1_out, D_Num2_out, E_Num1_in, E_Num2_in;
	wire[3:0]	D_ALUopcode_out, E_ALUopcode_in, D_WEDM_out, E_WEDM_in;
	wire			D_WEGF_out, E_WEGF_in;
	
	wire[31:0]	E_Instr_out, E_PC_out, M_Instr_in, M_PC_in, E_ALUresult_out, M_ALUresult_in;
	wire[3:0]	E_WEDM_out, M_WEDM_in;
	wire			E_WEGF_out, M_WEGF_in;
	
	wire[31:0]	M_Instr_out, M_PC_out, W_Instr_in, W_PC_in, M_ALUresult_out, M_DMdata_out, W_ALUresult_in, W_DMdata_in;
	wire[3:0]	M_WEDM_out, W_WEDM_in;
	
	wire[4:0]	Careadd1_D, Careadd2_D, Careadd1_E, Careadd2_E, Careadd1_M, Careadd2_M;
	wire[31:0]	askdata1_D, askdata2_D, askdata1_E, askdata2_E, askdata1_M, askdata2_M, GFadd1_D, GFadd2_D, GFadd1_E, GFadd2_E, GFadd1_M, GFadd2_M;
	
	wire[31:0]	askdata1_E_in, askdata2_E_in, askdata1_M_in, askdata2_M_in;
	
	wire[31:0]  W_DMread_in;
	wire[4:0]	E_add_write, M_add_write, W_add_write, E_add_write_plus, M_add_write_plus, W_add_write_in, W_add_write_plus_in;
	
	wire [31:0] MDU_inputA, MDU_inputB, HIRead, LORead;
   wire MDU_start, HIWrite, LOWrite;
   wire [2:0] MDUOp;
	wire MDU_busy;
	
	
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
	 .freeze(freeze),
	 
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
	 .ALUinput2(ALUinput2),		//Alu读入数据2
	 .GF_PC(W_PC_in),
	 .DM_PC(M_PC_in),
	 
	 //MDU
	 .MDU_inputA(MDU_inputA),
    .MDU_inputB(MDU_inputB),
    .MDU_start(MDU_start),
    .MDUOp(MDUOp),
    .HIWrite(HIWrite),
    .LOWrite(LOWrite),
    .HIRead(HIRead),
    .LORead(LORead),
	 .MDU_busy(MDU_busy),
	 
	 
	 //关心的地址,和若非转发的数据
	 .Careadd1_D(Careadd1_D),
	 .Careadd2_D(Careadd2_D),
	 .askdata1_D(askdata1_D),
	 .askdata2_D(askdata2_D),
	
	 //p6
	 .i_inst_rdata(i_inst_rdata),
    .m_data_rdata(m_data_rdata),
    .i_inst_addr(i_inst_addr),
    .m_data_addr(m_data_addr),
    .m_data_wdata(m_data_wdata),
    .m_data_byteen(m_data_byteen),
    .m_inst_addr(m_inst_addr),
    .w_grf_we(w_grf_we),
    .w_grf_addr(w_grf_addr),
    .w_grf_wdata(w_grf_wdata),
    .w_inst_addr(w_inst_addr)
	 
    );
	
control ctrl (
//gap控制器
//周期 Ⅰ->Ⅱ		IF/ID
	 .I_Instr_out(I_Instr_out),
	 .I_PC_out(I_PC_out),
	
	 .D_Instr_in(D_Instr_in),
	 .D_PC_in(D_PC_in),

//周期 Ⅱ->Ⅲ		ID/EX
	 .D_Instr_out(D_Instr_out),
	 .D_PC_out(D_PC_out),
	 .D_Num1_out(D_Num1_out), //GPR[base],GPR[rs]
	 .D_Num2_out(D_Num2_out), //GPR[rt],unsign_ext(imm16)
	 .D_ALUopcode_out(D_ALUopcode_out),
	 .D_WEGF_out(D_WEGF_out),
	 .D_WEDM_out(D_WEDM_out),
	
	 .E_Instr_in(E_Instr_in),
	 .E_PC_in(E_PC_in),
	 .E_Num1_in(E_Num1_in), //GPR[base],GPR[rs]
	 .E_Num2_in(E_Num2_in), //GPR[rt],unsign_ext(imm16)
	 .E_ALUopcode_in(E_ALUopcode_in),
	 .E_WEGF_in(E_WEGF_in),
	 .E_WEDM_in(E_WEDM_in),
	 
	 .MDU_inputA(MDU_inputA),
    .MDU_inputB(MDU_inputB),
    .MDU_start(MDU_start),
    .MDUOp(MDUOp),
    .HIWrite(HIWrite),
    .LOWrite(LOWrite),
    .HIRead(HIRead),
    .LORead(LORead),
	
	
//周期 Ⅲ->Ⅳ		EX/MEM
	 .E_Instr_out(E_Instr_out),
	 .E_PC_out(E_PC_out),
	 .E_WEGF_out(E_WEGF_out),
	 .E_WEDM_out(E_WEDM_out),
	 .E_ALUresult_out(E_ALUresult_out),
	
	 .M_ALUresult_in(M_ALUresult_in),
	 .M_Instr_in(M_Instr_in),
	 .M_PC_in(M_PC_in),
	 .M_WEGF_in(M_WEGF_in),
	 .M_WEDM_in(M_WEDM_in),
	
//周期 Ⅳ->Ⅴ		MEM/WB
	 .M_Instr_out(M_Instr_out),
	 .M_PC_out(M_PC_out),
	 .M_ALUresult_out(M_ALUresult_out),
	 .M_DMdata_out(M_DMdata_out),
	 .M_WEGF_out(M_WEGF_out),
	
	 .W_add_write_in(W_add_write_in),
	 .W_add_write_plus_in(W_add_write_plus_in),
	 .W_Instr_in(W_Instr_in),
	 .W_PC_in(W_PC_in),
	 .W_ALUresult_in(W_ALUresult_in),
	 .W_DMdata_in(W_DMdata_in),
	 .W_WEGF_in(W_WEGF_in),

//datapath
	 //输出
	 //指令存储器
    .I_Instr_in(Instr),				//读的指令存储器指令
	 .I_PC_in(PC),						//当前PC
	 
	 //ALU
	 .ALUresult(ALUresult),		//Alu计算结果
	 .ReadDM(ReadDM),
	 
//输入
	 //指令存储器
	 .Jumpsign(Jumpsign),		//进行非PC+4跳转
	 .JumpAddr(JumpAddr),		//跳转到的数
	 
	 //寄存器堆
	 .WEgf(WEgf),					//寄存器堆写使能
	 .WriteGFadd(WriteGFadd),	//写的寄存器地址
	 .WriteGFdata(WriteGFdata),//写的寄存器数据

	 
	 //数据存储器
	 .WEdm(WEdm),					//数据存储器写使能
	 .WriteDMadd(WriteDMadd),	//写的数据存储器地址
	 .WriteDMdata(WriteDMdata),//写的数据存储器数据
	 .readDMadd(readDMadd),		//读的数据存储器地址
	 
	 //ALU
	 .ALUopcode(ALUopcode),		//Alu运算符
	 .ALUinput1(ALUinput1),		//Alu读入数据1
	 .ALUinput2(ALUinput2),		//Alu读入数据2
	 
	 
	 .E_add_write(E_add_write),
	 .M_add_write(M_add_write),
	 .W_add_write(W_add_write),
	 
	 
	 //关心的地址,和若非转发的数据
	 
	 .CareGFadd1_D(Careadd1_D),
	 .CareGFadd2_D(Careadd2_D),
	 
	 .CareGFadd1_E(Careadd1_E),
	 .CareGFadd2_E(Careadd2_E),
	 
	 .CareGFadd1_M(Careadd1_M),
	 .CareGFadd2_M(Careadd2_M),
	
	
	 .CareGF1_D(GFadd1_D),
	 .CareGF2_D(GFadd2_D),
	
	 .CareGF1_E(GFadd1_E),
	 .CareGF2_E(GFadd2_E),
	
	 .CareGF1_M(GFadd1_M),
	 .CareGF2_M(GFadd2_M),
	 


	 .askdata1_E(askdata1_E),
	 .askdata2_E(askdata2_E),
	 .askdata1_M(askdata1_M),
	 .askdata2_M(askdata2_M),
	 
	 	//试图写入的类型，1为从DM，0为从alu
	 .E_type_write(E_type_write),
	 .M_type_write(M_type_write),
	 .W_type_write(W_type_write),
	 .E_add_write_plus(E_add_write_plus),
	 .M_add_write_plus(M_add_write_plus),
	 
	 
	 .freeze(freeze)
	 
	 
    );
	
	gapGF gap (
	 .clk(clk),
	 .reset(reset),
	 
//周期 Ⅰ->Ⅱ		IF/ID
	 .I_Instr_out(I_Instr_out),
	 .I_PC_out(I_PC_out),
	
	 .D_Instr_in(D_Instr_in),
	 .D_PC_in(D_PC_in),

//周期 Ⅱ->Ⅲ		ID/EX
	 .D_Instr_out(D_Instr_out),
	 .D_PC_out(D_PC_out),
	 .D_Num1_out(D_Num1_out), //GPR[base],GPR[rs]
	 .D_Num2_out(D_Num2_out), //GPR[rt],unsign_ext(imm16)
	 .D_ALUopcode_out(D_ALUopcode_out),
	 .D_WEGF_out(D_WEGF_out),
	 .D_WEDM_out(D_WEDM_out),
	
	 .E_Instr_in(E_Instr_in),
	 .E_PC_in(E_PC_in),
	 .E_Num1_in(E_Num1_in), //GPR[base],GPR[rs]
	 .E_Num2_in(E_Num2_in), //GPR[rt],unsign_ext(imm16)
	 .E_ALUopcode_in(E_ALUopcode_in),
	 .E_WEGF_in(E_WEGF_in),
	 .E_WEDM_in(E_WEDM_in),
	
//周期 Ⅲ->Ⅳ		EX/MEM
	 .E_Instr_out(E_Instr_out),
	 .E_PC_out(E_PC_out),
	 .E_ALUresult_out(E_ALUresult_out),
	 .E_WEGF_out(E_WEGF_out),
	 .E_WEDM_out(E_WEDM_out),
	
	 .M_Instr_in(M_Instr_in),
	 .M_PC_in(M_PC_in),
	 .M_ALUresult_in(M_ALUresult_in),
	 .M_WEGF_in(M_WEGF_in),
	 .M_WEDM_in(M_WEDM_in),
	
//周期 Ⅳ->Ⅴ		MEM/WB
	 .M_Instr_out(M_Instr_out),
	 .M_PC_out(M_PC_out),
	 .M_ALUresult_out(M_ALUresult_out),
	 .M_DMdata_out(M_DMdata_out),
	 .M_WEGF_out(M_WEGF_out),
	 .M_add_write_out(M_add_write),
	 .M_add_write_plus_out(M_add_write_plus),
	
	 .W_add_write_in(W_add_write_in),
	 .W_add_write_plus_in(W_add_write_plus_in),
	 .W_Instr_in(W_Instr_in),
	 .W_PC_in(W_PC_in),
	 .W_ALUresult_in(W_ALUresult_in),
	 .W_DMdata_in(W_DMdata_in),
	 .W_WEGF_in(W_WEGF_in)

	);

	haltpass halt(
	 .clk(clk),
	 .reset(reset), 
	 
	 .D_Instr(D_Instr_in),
	 .E_Instr(E_Instr_in),
	 .M_Instr(M_Instr_in),
	 .W_Instr(W_Instr_in),
	
	//试图写入的地址
	 .E_add_write(E_add_write),
	 .M_add_write(M_add_write),
	 .W_add_write(W_add_write),
	 .E_add_write_plus(E_add_write_plus),
	 .M_add_write_plus(M_add_write_plus),
	 
	 
	 //地址写使能
	 .E_write_we(E_WEGF_in),
	 .M_write_we(M_WEGF_in),
	 .W_write_we(W_WEGF_in),
	//试图写入的类型，1为从DM，0为从alu
	 .E_type_write(E_type_write),
	 .M_type_write(M_type_write),
	 .W_type_write(W_type_write),
	
	//可能的旁路
	 .M_ALUresult(M_ALUresult_in),
	 .W_ALUresult(W_ALUresult_in),
	 .W_DMread(W_DMdata_in),
	
	//关心的地址,和若非转发的数据
	 .Careadd1_D(Careadd1_D),
	 .Careadd2_D(Careadd2_D),
	 .askdata1_D(askdata1_D),
	 .askdata2_D(askdata2_D),
	
	 .Careadd1_E(Careadd1_E),
	 .Careadd2_E(Careadd2_E),
	 .askdata1_E(askdata1_E_in),
	 .askdata2_E(askdata2_E_in),
	
	 .Careadd1_M(Careadd1_M),
	 .Careadd2_M(Careadd2_M),
	 .askdata1_M(askdata1_M_in),
	 .askdata2_M(askdata2_M_in),
	
	//这些地址真实值
	 .GFadd1_D(GFadd1_D),
	 .GFadd2_D(GFadd2_D),
	
	 .GFadd1_E(GFadd1_E),
	 .GFadd2_E(GFadd2_E),
	
	 .GFadd1_M(GFadd1_M),
	 .GFadd2_M(GFadd2_M),
	
	//是否冻结
	 .freeze(freeze),
	 .MDU_busy(MDU_busy)
	);
	
	
	haltGF haltgf(
	 .clk(clk),
	 .reset(reset),
	 .GFadd1_D(GFadd1_D),
	 .GFadd2_D(GFadd2_D),
	
	 .GFadd1_E(GFadd1_E),
	 .GFadd2_E(GFadd2_E),
	 .askdata1_E(askdata1_E_in),
	 .askdata2_E(askdata2_E_in),
	 .askdata1_M(askdata1_M_in),
	 .askdata2_M(askdata2_M_in)
	);


endmodule
