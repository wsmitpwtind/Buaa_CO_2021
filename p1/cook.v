`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:40:03 10/26/2021 
// Design Name: 
// Module Name:    cook 
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
module cook(
    input temp,
    input flip,
    input clk,
    input reset,
    output reg [1:0] status,
    output need_flip
    );

initial
	begin
		status = 2'b00;
	end
	
assign need_flip = (status ==2'b01)?1'b1:1'b0;

always @(posedge clk or posedge reset)
	begin
		if(reset)
			begin
				status <= 2'b00;
			end
		else
			begin
				case(status)
					2'b00:
						begin
							if( temp == 1'b1 && flip == 1'b0 )
								begin
									status <= 2'b01;
								end
							else if ( temp == 1'b0 && flip == 1'b0 )
								begin
									status <= 2'b00;
								end
							else if ( flip == 1'b1 )
								begin
									status <= 2'b11;
								end
						end
					2'b01:
						begin
							if( temp == 1'b1 )
								begin
									status <= 2'b11;
								end
							else if ( temp == 1'b0 && flip == 1'b0 )
								begin
									status <= 2'b11;
								end
							else if ( temp == 1'b0 && flip == 1'b1 )
								begin
									status <= 2'b10;
								end
						end
						
					2'b10:
						begin
							status <= 2'b11;
						end
						
					2'b11:
						begin
							status <= status;
						end
						
				endcase
			end
	end


endmodule
