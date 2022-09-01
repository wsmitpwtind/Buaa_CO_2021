`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:26:03 11/12/2021 
// Design Name: 
// Module Name:    alu 
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


`define ADDU	4'b0000
`define SUBU	4'b0001
`define AND		4'b0010
`define	OR		4'b0011
`define LUI		4'b0100
`define NOR		4'b0101
`define XOR		4'b0110
`define SLL		4'b0111	// shift left logically
`define SRL		4'b1000	// shift right logical
`define SRA		4'b1001	// shift right arithmetic
`define SLT		4'b1010	// set less than
`define SLTU	4'b1011	// set less than unsigned
`define A		4'b1111

`define CAL		4'b1100	//未定义类型

module ALU(
    input [31:0] A,
    input [31:0] B,
    input [3:0] AluOp,
    output reg [31:0] res
    );
	 
	 
	 
//复杂运算示例，temp为计算得A中最长全1串的长度
//	 reg[31:0] cnt, temp;    // cnt计数正在数的1的个数
//	 initial begin           // temp表示已知最长个数
//    cnt = 0;
//    temp = 0;
//	end
//	integer i;
//	always@(*) begin
//		       temp=0;
//    for (i = 0; i < 32; i = i + 1) begin
//        if (A[i] == 1) begin
//            cnt = cnt + 1; 
//            if (cnt > temp) begin
//                temp = cnt;
//            end
//            else begin
//            end
//        end
//        else begin
//            cnt = 0;
//        end
//    end
//	end

//循环示例
 //always @(*) begin
//        c = a;
 //       for(i = 0; i < 5; i = i + 1) begin
//		if(i < b)
//        	c = {c[0], c[4:1]};
//		else
//			i = 32;
//		end
 //   end


always@(*) begin
		case(AluOp)
			`ADDU :
				res = A + B;
			`SUBU :
				res = A - B;
			`AND :
				res = A & B;
			`OR :
				res = A | B;
			`LUI:
				res = {B[15:0], 16'h0};
			`NOR:
				res = ~(A | B);
			`XOR:
				res = A ^ B;
			`SLL:
				res = B << A[4:0];
			`SRL:
				res = B >> A[4:0];
			`SRA:
				res = $signed(B) >>> A[4:0];
			`SLT:
				res = ($signed(A) < $signed(B));
			`SLTU:
				res = (A < B);
			`CAL:
				res = A + B;
			`A:
				res = A;
			default:
				res = 0;
		endcase
	end
endmodule
	

