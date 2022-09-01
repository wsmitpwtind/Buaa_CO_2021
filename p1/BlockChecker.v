`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:24:18 10/23/2021 
// Design Name: 
// Module Name:    BlockChecker 
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
module BlockChecker(
    input clk,
    input reset,
    input [7:0] in,
    output result
    );

reg [3:0] state;
reg [31:0] tb;
reg [31:0] te;
reg error;
reg preerror;

assign result = (error == 1'b1)?1'b0:
					 (tb == te)?1'b1:
											 1'b0;

initial
	begin
		state = 4'b0;
		tb = 32'b0;
		te = 32'b0; 
		error = 1'b0;
		preerror  = 1'b0;
	end

always @(posedge clk)
	begin
		if(reset == 1'b1)
			begin
				state <= 4'b0;
				tb <= 32'b0;
				te = 32'b0;
				error <= 1'b0;
				preerror  = 1'b0;
			end
		else
			begin
				case(state)
					4'd15:
						begin
							if( in == " ")
								begin
									state <= 4'd0;
								end
						end
					4'd0:
						begin
							if( in == "b" || in == "B" )
								begin
									state <= 4'd1;

								end
							else if( in == "e" || in == "E" )
								begin
									state <= 4'd6;

								end
							else if( in == " ")
								begin
									state <= 4'd0;
								end
							else
								begin
									state <= 4'd15;

								end
						end
					4'd1:
						begin
							if( in == "e" || in == "E" )
								begin
									state <= 4'd2;
								end
							else if( in == " ")
								begin
									state <= 4'd0;
								end
							else
								begin
									state <= 4'd15;
								end
						end
					4'd2:
						begin
							if( in == "g" || in == "G" )
								begin
									state <= 4'd3;
								end
							else if( in == " ")
								begin
									state <= 4'd0;
								end
							else
								begin
									state <= 4'd15;
								end
						end
					4'd3:
						begin
							if( in == "i" || in == "I" )
								begin
									state <= 4'd4;
								end
							else if( in == " ")
								begin
									state <= 4'd0;
								end
							else
								begin
									state <= 4'd15;
								end
						end
					4'd4:
						begin
							if( in == "n" || in == "N" )
								begin
									state <= 4'd5;
									tb <= tb + 32'b1;
								end
							else if( in == " ")
								begin
									state <= 4'd0;
								end
							else
								begin
									state <= 4'd15;
								end
						end
					4'd5:
						begin
							if( in == " ")
								begin
									state <= 4'd0;
									
								end
							else
								begin
									state <= 4'd15;
									tb <= tb - 32'b1;
								end
						end
					4'd6:
						begin
							if( in == "n" || in == "N" )
								begin
									state <= 4'd7;
								end
							else if( in == " ")
								begin
									state <= 4'd0;
								end
							else
								begin
									state <= 4'd15;
								end
						end
					4'd7:
						begin
							if( in == "d" || in == "D" )
								begin
									state <= 4'd8;
									te <= te + 32'b1;
									if (te + 32'b1 > tb)
										begin
											error <= 1'b1;
										end
								end
							else if( in == " ")
								begin
									state <= 4'd0;
								end
							else
								begin
									state <= 4'd15;
								end
						end
					4'd8:
						begin
							if( in == " ")
								begin
									preerror <= error;
									state <= 4'd0;
								end
							else
								begin
									te <= te - 32'b1;
									if (te - 32'b1 <= tb)
										begin
											error <= preerror;
										end
									state <= 4'd15;
								end
						end
					endcase
			end
	end
endmodule
