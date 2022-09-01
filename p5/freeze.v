`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:31:31 11/21/2021 
// Design Name: 
// Module Name:    freeze 
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
module freeze(
	input [31:0] D_Instr,
	input [31:0] E_Instr,
	input [31:0] M_Instr,
	input [31:0] W_Instr,
	
	//可能的旁路
	input [31:0] M_ALUresult,
	input [31:0] W_ALUresult,
	input [31:0] W_DMread,
	input [31:0] After_W_data,
	input [4:0] After_W_add,
	input WEgf,
	
	//非转发时理应的数据
	input [31:0] D_rs_nor,
	input [31:0] D_rt_nor,
	input [31:0] E_rs_nor,
	input [31:0] E_rt_nor,
	input [31:0] M_rs_nor,
	input [31:0] M_rt_nor,
	
	//考虑转发后的结果
	output [31:0] D_rs_true,
	output [31:0] D_rt_true,
	output [31:0] E_rs_true,
	output [31:0] E_rt_true,
	output [31:0] M_rs_true,
	output [31:0] M_rt_true,
	
	//是否冻结
	output freeze
    );
	 
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
	
	//D级需求
	assign rs_need_D = D_beq | D_jr;
	assign rt_need_D = D_beq;
	
	assign rs_need_E = D_addu | D_subu | D_ori | D_lw | D_sw;
	assign rt_need_E = D_addu | D_subu;
	
	assign rs_need_M = 0;
	assign rt_need_M = D_sw;
	
	
	
	//对D级
	assign E_rs_write_D_ALU = ((E_addu | E_subu)&(D_rs == E_rd)) | ((E_ori | E_lui )&(D_rs == E_rt)) | ((E_jal)&(D_rs == 5'd31));
	assign E_rs_write_D_DM  = (E_lw &(D_rs == E_rt));
	assign M_rs_write_D_ALU = ((M_addu | M_subu)&(D_rs == M_rd)) | ((M_ori | M_lui )&(D_rs == M_rt)) | ((M_jal)&(D_rs == 5'd31));
	assign M_rs_write_D_DM  = (M_lw &(D_rs == M_rt));	
	assign W_rs_write_D_ALU = ((W_addu | W_subu)&(D_rs == W_rd)) | ((W_ori | W_lui )&(D_rs == W_rt)) | ((W_jal)&(D_rs == 5'd31));
	assign W_rs_write_D_DM  = (W_lw &(D_rs == W_rt));
	
	assign E_rt_write_D_ALU = ((E_addu | E_subu)&(D_rt == E_rd)) | ((E_ori | E_lui )&(D_rt == E_rt)) | ((E_jal)&(D_rt == 5'd31));
	assign E_rt_write_D_DM  = (E_lw &(D_rt == E_rt));
	assign M_rt_write_D_ALU = ((M_addu | M_subu)&(D_rt == M_rd)) | ((M_ori | M_lui )&(D_rt == M_rt)) | ((M_jal)&(D_rt == 5'd31));
	assign M_rt_write_D_DM  = (M_lw &(D_rt == M_rt));
	assign W_rt_write_D_ALU = ((W_addu | W_subu)&(D_rt == W_rd)) | ((W_ori | W_lui )&(D_rt == W_rt)) | ((W_jal)&(D_rt == 5'd31));
	assign W_rt_write_D_DM  = (W_lw &(D_rt == W_rt));
	
	//对E级
	assign M_rs_write_E_ALU = ((M_addu | M_subu)&(E_rs == M_rd)) | ((M_ori | M_lui )&(E_rs == M_rt)) | ((M_jal)&(E_rs == 5'd31));
	assign M_rs_write_E_DM  = (M_lw &(E_rs == M_rt));	
	assign W_rs_write_E_ALU = ((W_addu | W_subu)&(E_rs == W_rd)) | ((W_ori | W_lui )&(E_rs == W_rt)) | ((W_jal)&(E_rs == 5'd31));
	assign W_rs_write_E_DM  = (W_lw &(E_rs == W_rt));
	
	assign M_rt_write_E_ALU = ((M_addu | M_subu)&(E_rt == M_rd)) | ((M_ori | M_lui )&(E_rt == M_rt)) | ((M_jal)&(E_rt == 5'd31));
	assign M_rt_write_E_DM  = (M_lw &(E_rt == M_rt));
	assign W_rt_write_E_ALU = ((W_addu | W_subu)&(E_rt == W_rd)) | ((W_ori | W_lui )&(E_rt == W_rt)) | ((W_jal)&(E_rt == 5'd31));
	assign W_rt_write_E_DM  = (W_lw &(E_rt == W_rt));
	
	
	//对M级
	assign W_rs_write_M_ALU = ((W_addu | W_subu)&(M_rs == W_rd)) | ((W_ori | W_lui )&(M_rs == W_rt)) | ((W_jal)&(M_rs == 5'd31));
	assign W_rs_write_M_DM  = (W_lw &(M_rs == W_rt));
	
	assign W_rt_write_M_ALU = ((W_addu | W_subu)&(M_rt == W_rd)) | ((W_ori | W_lui )&(M_rt == W_rt)) | ((W_jal)&(M_rt == 5'd31));
	assign W_rt_write_M_DM  = (W_lw &(M_rt == W_rt));
	
	
	
	assign freeze	  = (rs_need_D & (E_rs_write_D_ALU | E_rs_write_D_DM | M_rs_write_D_DM)) |
							 (rt_need_D & (E_rt_write_D_ALU | E_rt_write_D_DM | M_rt_write_D_DM)) |
							 (rs_need_E & M_rs_write_D_DM) |
							 (rt_need_E & M_rt_write_D_DM);
	
	assign D_rs_true = (!(D_beq | D_jr))		  						? D_rs_nor	  :
							 (M_rs_write_D_ALU) 								? M_ALUresult :
							 (W_rs_write_D_ALU) 								? W_ALUresult :
							 (W_rs_write_D_DM)  								? W_DMread	  :
							 (WEgf & (After_W_add == D_rs))				? After_W_data: D_rs_nor;
							 
	assign D_rt_true = (!(D_beq)) 										? D_rt_nor 	  :
							 (M_rt_write_D_ALU) 								? M_ALUresult :
							 (W_rt_write_D_ALU) 								? W_ALUresult :
							 (W_rt_write_D_DM)  								? W_DMread	  :
							 (WEgf & (After_W_add == D_rt))				? After_W_data: D_rt_nor;
							 
	assign E_rs_true = (!(E_addu | E_subu | E_ori | E_lw | E_sw)) ? E_rs_nor 	  :
							 (M_rs_write_E_ALU) 								? M_ALUresult :
							 (W_rs_write_E_ALU) 								? W_ALUresult :
							 (W_rs_write_E_DM)  								? W_DMread	  : 
							 (WEgf & (After_W_add == E_rs))				? After_W_data: E_rs_nor;
							 
	assign E_rt_true = (!(E_addu | E_subu)) 							? E_rt_nor    :
							 (M_rt_write_E_ALU) 								? M_ALUresult :
							 (W_rt_write_E_ALU) 								? W_ALUresult :
							 (W_rt_write_E_DM)  								? W_DMread	  : 
							 (WEgf & (After_W_add == E_rt))				? After_W_data: E_rt_nor;	

	assign M_rs_true = (!0)			 		  								? M_rs_nor 	  :
							 (W_rs_write_M_ALU) 								? W_ALUresult :
							 (W_rs_write_M_DM)  								? W_DMread	  : 
							 (WEgf & (After_W_add == M_rs))				? After_W_data: M_rs_nor;			
							 
	assign M_rt_true = (!(M_sw))		 		  							? M_rt_nor 	  :
							 (W_rt_write_M_ALU) 								? W_ALUresult :
							 (W_rt_write_M_DM)  								? W_DMread	  : 
							 (WEgf & (After_W_add == M_rt))				? After_W_data: M_rt_nor;	

endmodule
