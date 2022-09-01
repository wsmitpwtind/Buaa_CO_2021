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
	 .freeze(freeze),
	 
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
	 .ALUinput2(ALUinput2),		//Alu��������2
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
	 
	 
	 //���ĵĵ�ַ,������ת��������
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
//gap������
//���� ��->��		IF/ID
	 .I_Instr_out(I_Instr_out),
	 .I_PC_out(I_PC_out),
	
	 .D_Instr_in(D_Instr_in),
	 .D_PC_in(D_PC_in),

//���� ��->��		ID/EX
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
	
	
//���� ��->��		EX/MEM
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
	
//���� ��->��		MEM/WB
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
	 //���
	 //ָ��洢��
    .I_Instr_in(Instr),				//����ָ��洢��ָ��
	 .I_PC_in(PC),						//��ǰPC
	 
	 //ALU
	 .ALUresult(ALUresult),		//Alu������
	 .ReadDM(ReadDM),
	 
//����
	 //ָ��洢��
	 .Jumpsign(Jumpsign),		//���з�PC+4��ת
	 .JumpAddr(JumpAddr),		//��ת������
	 
	 //�Ĵ�����
	 .WEgf(WEgf),					//�Ĵ�����дʹ��
	 .WriteGFadd(WriteGFadd),	//д�ļĴ�����ַ
	 .WriteGFdata(WriteGFdata),//д�ļĴ�������

	 
	 //���ݴ洢��
	 .WEdm(WEdm),					//���ݴ洢��дʹ��
	 .WriteDMadd(WriteDMadd),	//д�����ݴ洢����ַ
	 .WriteDMdata(WriteDMdata),//д�����ݴ洢������
	 .readDMadd(readDMadd),		//�������ݴ洢����ַ
	 
	 //ALU
	 .ALUopcode(ALUopcode),		//Alu�����
	 .ALUinput1(ALUinput1),		//Alu��������1
	 .ALUinput2(ALUinput2),		//Alu��������2
	 
	 
	 .E_add_write(E_add_write),
	 .M_add_write(M_add_write),
	 .W_add_write(W_add_write),
	 
	 
	 //���ĵĵ�ַ,������ת��������
	 
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
	 
	 	//��ͼд������ͣ�1Ϊ��DM��0Ϊ��alu
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
	 
//���� ��->��		IF/ID
	 .I_Instr_out(I_Instr_out),
	 .I_PC_out(I_PC_out),
	
	 .D_Instr_in(D_Instr_in),
	 .D_PC_in(D_PC_in),

//���� ��->��		ID/EX
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
	
//���� ��->��		EX/MEM
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
	
//���� ��->��		MEM/WB
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
	
	//��ͼд��ĵ�ַ
	 .E_add_write(E_add_write),
	 .M_add_write(M_add_write),
	 .W_add_write(W_add_write),
	 .E_add_write_plus(E_add_write_plus),
	 .M_add_write_plus(M_add_write_plus),
	 
	 
	 //��ַдʹ��
	 .E_write_we(E_WEGF_in),
	 .M_write_we(M_WEGF_in),
	 .W_write_we(W_WEGF_in),
	//��ͼд������ͣ�1Ϊ��DM��0Ϊ��alu
	 .E_type_write(E_type_write),
	 .M_type_write(M_type_write),
	 .W_type_write(W_type_write),
	
	//���ܵ���·
	 .M_ALUresult(M_ALUresult_in),
	 .W_ALUresult(W_ALUresult_in),
	 .W_DMread(W_DMdata_in),
	
	//���ĵĵ�ַ,������ת��������
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
	
	//��Щ��ַ��ʵֵ
	 .GFadd1_D(GFadd1_D),
	 .GFadd2_D(GFadd2_D),
	
	 .GFadd1_E(GFadd1_E),
	 .GFadd2_E(GFadd2_E),
	
	 .GFadd1_M(GFadd1_M),
	 .GFadd2_M(GFadd2_M),
	
	//�Ƿ񶳽�
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
