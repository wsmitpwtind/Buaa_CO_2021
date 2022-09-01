`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:04:35 10/27/2021 
// Design Name: 
// Module Name:    username 
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
module username(
    input [7:0] name,
    input clk,
    input reset,
    output out
    );

reg [1:0] status = 2'b00; 

assign out = (status ==2'b11)? 1'b1:1'b0;

always @(posedge clk or posedge reset)
	begin
		if(reset == 1'b1)
			begin
				status <= 2'b00;
			end
		else
			begin
				case(status)
					2'b00:
						begin
							if(((name >= "a") && (name <= "z")) || ((name >= "A") && (name <= "Z")))
								begin
									status <= 2'b01;
								end
							else
								begin
									status <= 2'b00;
								end
						end
					2'b01:
						begin
							if(name == ".")
								begin
									status <= 2'b10;
								end
							else if(((name >= "a") && (name <= "z")) || ((name >= "A") && (name <= "Z")))
								begin
									status <= 2'b01;
								end
							else
								begin
									status <= 2'b00;
								end
						end
					2'b10:
						begin
							if((name >= "0") && (name <= "9"))
								begin
									status <= 2'b11;
								end
							else if(((name >= "a") && (name <= "z")) || ((name >= "A") && (name <= "Z")))
								begin
									status <= 2'b01;
								end
							else
								begin
									status <= 2'b00;
								end
						end
					2'b11:
						begin
							if((name >= "0") && (name <= "9"))
								begin
									status <= 2'b11;
								end
							else if(((name >= "a") && (name <= "z")) || ((name >= "A") && (name <= "Z")))
								begin
									status <= 2'b01;
								end
							else
								begin
									status <= 2'b00;
								end
						end
				endcase
			end
	end


endmodule
