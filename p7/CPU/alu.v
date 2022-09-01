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

`define ADD		4'b1100
`define SUB		4'b1101

`define A		4'b1111

`define CAL		4'b1110	//未定义类型

module ALU(
    input [31:0] A,
    input [31:0] B,
    input [3:0] AluOp,
    output reg [31:0] res,
	 output reg overflow
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
 
reg msb;

always@(*) begin
		case(AluOp)
			`ADDU :
				begin
					res = A + B;
					overflow = 1'b0;
				end
			`SUBU :
				begin
					res = A - B;
					overflow = 1'b0;
				end
			`AND :
				begin
					res = A & B;
					overflow = 1'b0;
				end
			`OR :
				begin
					res = A | B;
					overflow = 1'b0;
				end
			`LUI:
				begin
					res = {B[15:0], 16'h0};
					overflow = 1'b0;
				end
			`NOR:
				begin
					res = ~(A | B);
					overflow = 1'b0;
				end
			`XOR:
				begin
					res = A ^ B;
					overflow = 1'b0;
				end
			`SLL:
				begin
					res = B << A[4:0];
					overflow = 1'b0;
				end
			`SRL:
				begin
					res = B >> A[4:0];
					overflow = 1'b0;
				end
			`SRA:
				begin
					res = $signed(B) >>> A[4:0];
					overflow = 1'b0;
				end
			`SLT:
				begin
					res = ($signed(A) < $signed(B));
					overflow = 1'b0;
				end
			`SLTU:
				begin
					res = (A < B);
					overflow = 1'b0;
				end
			`CAL:
				begin
					res = A + B;
					overflow = 1'b0;
				end
			`ADD :
				begin
					{msb, res} = {A[31], A} + {B[31], B}; // use "=" not "<="
					overflow = (msb != res[31]);
				end
			`SUB :
				begin
					{msb, res} = {A[31], A} - {B[31], B};
					overflow = (msb != res[31]);
				end
			`A:
				begin
					res = A;
					overflow = 1'b0;
				end
			default:
				begin
					res = 0;
					overflow = 1'b0;
				end
		endcase
	end
endmodule
	

