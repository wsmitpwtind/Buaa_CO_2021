`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:59:21 10/23/2021 
// Design Name: 
// Module Name:    gray 
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
module gray(
    input Clk,
    input Reset,
    input En,
    output [2:0] Output,
    output Overflow
    );

reg [2:0] counter;
reg overflow;

assign Output = (counter == 3'b000)? 3'b000:
					 (counter == 3'b001)? 3'b001:
					 (counter == 3'b010)? 3'b011:
					 (counter == 3'b011)? 3'b010:
					 (counter == 3'b100)? 3'b110:
					 (counter == 3'b101)? 3'b111:
					 (counter == 3'b110)? 3'b101:
					 (counter == 3'b111)? 3'b100: 3'b000;

assign Overflow = overflow;

initial 
	begin
		counter = 3'b000;
		overflow = 1'b0;
	end

always @(posedge Clk)
	begin
		if(Reset == 1'b1)
			begin
				counter <= 3'b000;
				overflow <= 1'b0;
			end
		else
			if(En == 1'b1)
				begin
					if (counter == 3'b111)
						begin
							overflow <= 1'b1;
						end
					counter <= counter + 3'b1;
				end
	end

endmodule
