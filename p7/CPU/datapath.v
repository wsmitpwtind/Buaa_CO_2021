`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:03:50 11/12/2021 
// Design Name: 
// Module Name:    datapath 
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
module datapath(
    input clk,
    input reset,

//周期 Ⅰ		 -> 指令

	//左 -> 送出
	input Jumpsign,				//进行非PC+4跳转
	input [31:0] JumpAddr,	//跳转到的数
	input freeze,
	
	//右 -> 接收
	output [31:0] Instr,				//读的指令存储器指令
	output [31:0] PC,					//当前PC
	output [4 :0] I_ExcCode_out,
	output [31:0] I_ExcPC_out,
	
//周期 Ⅱ	指令 -> 读寄存器

	//左 -> 送出
	input [4:0] readGFadd1,	//读的寄存器1地址
	input [4:0] readGFadd2,	//读的寄存器2地址
	input [31:0] D_ExcPC_in,
	
	//右 -> 接收
	output [31:0] ReadGF1,			//读的寄存器1数据
	output [31:0] ReadGF2,			//读的寄存器2数据
	output [31:0] D_ExcPC_out,
	 
//周期 Ⅲ	读寄存器 -> ALU

	//左 -> 送出
	input [3:0] ALUopcode,	//Alu运算符
	input [31:0] ALUinput1,	//Alu读入数据1
	input [31:0] ALUinput2,	//Alu读入数据2
	input [31:0] E_ExcPC_in,
	input [31:0] E_PC_in,
	 
	//右 -> 接收
	output [31:0] ALUresult,			//Alu计算结果
	output reg [31:0] E_ExcPC_out,
	

//周期 Ⅳ	ALU -> 数据存储器

	//左 -> 送出
	input [3:0]  WEdm,					//数据存储器写使能
	input [31:0] WriteDMadd,	//写的数据存储器地址
	input [31:0] WriteDMdata,//写的数据存储器数据
	input [31:0] readDMadd,	//读的数据存储器地址
	input [4 :0] M_ExcCode_in,
	input [31:0] M_ExcPC_in,
	input [31:0] M_PC_in,
	//右 -> 接收
	output [31:0] ReadDM,				//读的数据存储器数据
	
//周期 Ⅴ 数据存储器 -> 写寄存器

	//左 -> 送出
	input WEgf,					//寄存器堆写使能
	input [4:0] WriteGFadd,	//写的寄存器地址
	input [31:0] WriteGFdata,	//写的寄存器数据
	//右 -> 接收
	 
	input [31:0] DM_PC,
	input [31:0] GF_PC,
	 
	 
	 
	 input [4:0] Careadd1_D,
	 input [4:0] Careadd2_D,
	 
	 output [31:0] askdata1_D,
	 output [31:0] askdata2_D,
	 
	 //p6
	 input [31:0] i_inst_rdata,
	 output [31:0] i_inst_addr,
	 
	 input [31:0] m_data_rdata,
	 output [31:0] m_data_addr,
	 output [31:0] m_data_wdata,
	 output [3:0] m_data_byteen,
	 output [31:0] m_inst_addr,
	 
	 output w_grf_we,
	 output [4:0] w_grf_addr,
	 output [31:0] w_grf_wdata,
	 output [31:0] w_inst_addr,
	 
	 //mdu
	input [31:0] MDU_inputA,
   input [31:0] MDU_inputB,
   input MDU_start,
   input [2:0] MDUOp,
   input HIWrite,
   input LOWrite,
   output [31:0] HIRead,
   output [31:0] LORead,
	output MDU_busy,
	 
	input [1:0] M_readenable,
	
	input TM0_IRQ,
	input TM1_IRQ,
	input interrupt,
	
	input CP0_WE,
	input [4:0] CP0_Read_addr,
	input [4:0] CP0_Write_addr,
	input [31:0] CP0_Write_data,
	
	input CP0_BD,
	input [5:0] CP0_HWInt,
	input CP0_EXLClr,
	 
   output CP0_IntReq,
   output [31:0] CP0_EPC,	
   output [31:0] CP0_Read_data,
	
	output TestIntResponse,
	output overflow
	
    );
	 
	//p7
	assign I_ExcCode_out = ((PC >= 32'h0000_3000 && PC <= 32'h0000_6ffc) & (PC[1:0] == 2'b0)) ? 5'd0 : 5'd4;
	assign I_ExcPC_out   = PC;

	assign D_ExcPC_out   = D_ExcPC_in;
	always @(posedge clk)
		begin
			E_ExcPC_out	<= (overflow) ? E_PC_in : E_ExcPC_in;
			
		end
	wire [4 :0] CP0_ExcCode;
	wire [31:0] CP0_PC;
	
	wire HitDm_read   = (readDMadd  >= 32'h0000_0000 && readDMadd  <= 32'h0000_2fff) ? 1'b1 : 1'b0;
	wire HitTm0_read  = (readDMadd  >= 32'h0000_7f00 && readDMadd  <= 32'h0000_7f0b) ? 1'b1 : 1'b0;
	wire HitTm1_read  = (readDMadd  >= 32'h0000_7f10 && readDMadd  <= 32'h0000_7f1b) ? 1'b1 : 1'b0;
	wire HitDm_write  = (WriteDMadd >= 32'h0000_0000 && WriteDMadd <= 32'h0000_2fff) ? 1'b1 : 1'b0;
	wire HitTm0_write = (WriteDMadd >= 32'h0000_7f00 && WriteDMadd <= 32'h0000_7f0b) ? 1'b1 : 1'b0;
	wire HitTm1_write = (WriteDMadd >= 32'h0000_7f10 && WriteDMadd <= 32'h0000_7f1b) ? 1'b1 : 1'b0;
	
	assign CP0_ExcCode = ((M_readenable == 2'b11) & (readDMadd[1:0] != 2'b0)) ? 5'd4 : 
								((M_readenable == 2'b10) & (readDMadd[0]   != 1'b0)) ? 5'd4 :
								(((M_readenable == 2'b10) | (M_readenable == 2'b01)) & (HitTm0_read | HitTm1_read)) ? 5'd4 :
								((M_readenable != 2'b00) & (M_ExcCode_in == 5'd12)) ? 5'd4 :
								((M_readenable != 2'b00) & (~(HitDm_read | HitTm0_read | HitTm1_read))) ? 5'd4 :
								
								((WEdm == 4'b1111) & (WriteDMadd[1:0] != 2'b0)) ? 5'd5 :
								(((WEdm == 4'b0011) | (WEdm == 4'b1100)) & (WriteDMadd[0] != 1'b0)) ? 5'd5 :
								((~((WEdm == 4'b1111) | (WEdm == 4'b0000))) & (HitTm0_write | HitTm1_write)) ? 5'd5 :
								((WEdm != 4'b0000) & (M_ExcCode_in == 5'd12)) ? 5'd5 :
								((WEdm != 4'b0000) & (HitTm0_write | HitTm1_write) & (WriteDMadd[3:2] == 2'b10)) ? 5'd5 :
								((WEdm != 4'b0000) & (~(HitDm_write | HitTm0_write | HitTm1_write))) ? 5'd5 :
								

																																		M_ExcCode_in;
	
	assign CP0_PC	=		M_PC_in;
//								((M_readenable == 2'b11) & (readDMadd[1:0] != 2'b0)) ? M_PC_in : 
//								((M_readenable == 2'b10) & (readDMadd[0]   != 1'b0)) ? M_PC_in :
//								(((M_readenable == 2'b10) | (M_readenable == 2'b01)) & (HitTm0_read | HitTm1_read)) ? M_PC_in :
//								((M_readenable != 2'b00) & (M_ExcCode_in == 5'd12)) ? M_PC_in :
//								((M_readenable != 2'b00) & (~(HitDm_read | HitTm0_read | HitTm1_read))) ? M_PC_in :
//								
//								((WEdm == 4'b1111) & (WriteDMadd[1:0] != 2'b0)) ? M_PC_in :
//								(((WEdm == 4'b0011) | (WEdm == 4'b1100)) & (WriteDMadd[0] != 1'b0)) ? M_PC_in :
//								((~((WEdm == 4'b1111) | (WEdm == 4'b0000))) & (HitTm0_write | HitTm1_write)) ? M_PC_in :
//								((WEdm != 4'b0000) & (M_ExcCode_in == 5'd12)) ? M_PC_in :
//								((WEdm != 4'b0000) & (WriteDMadd >= 32'h0000_7f08 && WriteDMadd < 32'h0000_7f0b)) ? M_PC_in :
//								((WEdm != 4'b0000) & (~(HitDm_write | HitTm0_write | HitTm1_write))) ? M_PC_in :
//																																		M_ExcPC_in;
	
	
	assign Instr = (I_ExcCode_out != 5'd4) ? i_inst_rdata : 32'd0;
	assign i_inst_addr = PC;
	
	assign ReadDM = m_data_rdata;
	assign m_data_addr = (|WEdm) ? WriteDMadd : readDMadd;
	assign m_data_wdata = WriteDMdata;
	assign m_data_byteen = (CP0_IntReq) ? 4'b0000 : WEdm;
	assign m_inst_addr = DM_PC;
	
	assign w_grf_we = WEgf;
	assign w_grf_addr = WriteGFadd;
	assign w_grf_wdata = WriteGFdata;
	assign w_inst_addr = GF_PC;
	
	
	CP0 CP0(
	 .clk(clk), 
    .reset(reset),
	 .WE(CP0_WE),
	 .Read_addr(CP0_Read_addr),
	 .Write_addr(CP0_Write_addr),
	 .Write_data(CP0_Write_data),
	 
	 .PC(CP0_PC),
	 .BD(CP0_BD),
	 .ExcCode(CP0_ExcCode),
	 .HWInt(CP0_HWInt),
	 .EXLClr(CP0_EXLClr),
	 
	 .Req(CP0_IntReq),
	 .EPCout(CP0_EPC),
	 .Read_data(CP0_Read_data),
	 .TestIntResponse(TestIntResponse)
	 
	);
	
	
	IFU ifu (
    .clk(clk), 
    .reset(reset), 
    .Jumpsign(Jumpsign), 
    .JumpAddr(JumpAddr),
	 .PC(PC),
	 .freeze(freeze),
	 .CP0_IntReq(CP0_IntReq),
	 .eret(CP0_EXLClr),
	 .eretadd(CP0_EPC)
    );
	
//	IM im (
//    .PC(PC), 
//    .instr(Instr)
//    );

	GRF grf (
    .clk(clk), 
    .reset(reset), 
    .WE(WEgf), 
    .A1(Careadd1_D), 
    .A2(Careadd2_D), 
    .A3(WriteGFadd), 
    .WD(WriteGFdata), 
    .RD1(askdata1_D), 
    .RD2(askdata2_D),
	 .PC(GF_PC)
    );
	 
	MDU mdu (
	 .clk(clk), 
    .reset(reset),
	 .A(MDU_inputA),
    .B(MDU_inputB),
    .start(MDU_start),
    .MDUOp(MDUOp),
    .HIWrite(HIWrite),
    .LOWrite(LOWrite),
    .HI(HIRead),
    .LO(LORead),
	 .busy(MDU_busy)
	 );
//	DM dm (
//    .clk(clk), 
//    .reset(reset), 
//    .WE(WEdm), 
//	 .MemAddrWrite(WriteDMadd), 
//    .WD(WriteDMdata), 
//	 .MemAddrRead(readDMadd), 
//    .RD(ReadDM),
//	 .PC(DM_PC)
//    );
	 
	ALU alu (
    .A(ALUinput1), 
    .B(ALUinput2), 
    .AluOp(ALUopcode), 
    .res(ALUresult),
	 .overflow(overflow)
    );





endmodule

