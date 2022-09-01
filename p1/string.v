`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:41:10 10/23/2021 
// Design Name: 
// Module Name:    string 
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
module string(
    input clk,
    input clr,
    input [7:0] in,
    output reg out
    );
reg[1:0] state;

initial begin
	state <= 0;
end

always @(posedge clr)
	begin
		state <= 0;
		out <= 1'b0;
	end

always @(posedge clk)
	begin
		case(state)
				2'b00:
					begin
						if((in >= "0")&&(in <= "9"))
							begin
								out <= 1'b1;
								state <= 2'b01;
							end
						if((in == "+")||(in <= "*"))
							begin
								out <= 1'b0;
								state <= 2'b11;
							end
					end
				2'b01:
					begin
						if((in >= "0")&&(in <= "9"))
							begin
								out <= 1'b0;
								state <= 2'b11;
							end
						if((in == "+")||(in <= "*"))
							begin
								out <= 1'b0;
								state <= 2'b10;
							end
					end
				2'b10:
					begin
						if((in >= "0")&&(in <= "9"))
							begin
								out <= 1'b1;
								state <= 2'b01;
							end
						if((in == "+")||(in <= "*"))
							begin
								out <= 1'b0;
								state <= 2'b11;
							end
					end
				2'b11:
					begin
						out <= 1'b0;
					end
			endcase
	end

endmodule
