`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:13:43 10/26/2021 
// Design Name: 
// Module Name:    day 
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
module day(
    input [7:0] Input,
    input clk,
    input reset,
    output Output
    );

reg [4:0] state;

assign Output = (((state == 5'd7) || (state == 5'd8)) || (state == 5'd9))? 1'd1:
					 (((state == 5'd17) || (state == 5'd18)) || (state == 5'd19))? 1'd1:
					 (((state == 5'd27) || (state == 5'd28)) || (state == 5'd29))? 1'd1:1'd0;

initial
	begin
		state = 5'b0;
	end

always @(posedge clk)
	begin
		if(reset == 1'b1)
			begin
				state <= 5'b0;
			end
		else
			begin
				case(state)
					5'd0:
						begin
							if(Input >= "1" && Input <= "9")
								begin
									state <= 5'd1;
								end
						end
					5'd1:
						begin
							if(Input >= "0" && Input <= "9")
								begin
									state <= 5'd1;
								end
							else if(Input == ".")
								begin
									state <= 5'd2;
								end
							else if(Input == "-")
								begin
									state <= 5'd12;
								end
							else if(Input == "/")
								begin
									state <= 5'd22;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					5'd2:
						begin
							if(Input == "1")
								begin
									state <= 5'd3;
								end
							else if(Input >= "2" && Input <= "9")
								begin
									state <= 5'd5;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					5'd3:
						begin
							if(Input == ".")
								begin
									state <= 5'd6;
								end
							else if(Input >= "0" && Input <= "2")
								begin
									state <= 5'd4;
								end
							else if(Input >= "3" && Input <= "9")
								begin
									state <= 5'd1;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					5'd4:
						begin
							if(Input == ".")
								begin
									state <= 5'd6;
								end
							else if(Input >= "0" && Input <= "9")
								begin
									state <= 5'd1;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					5'd5:
						begin
							if(Input == ".")
								begin
									state <= 5'd6;
								end
							else if(Input >= "0" && Input <= "9")
								begin
									state <= 5'd1;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					5'd6:
						begin
							if(Input >= "1" && Input <= "3")
								begin
									state <= 5'd7;
								end
							else if(Input >= "4" && Input <= "9")
								begin
									state <= 5'd9;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					5'd7:
						begin
							if(Input >= "0" && Input <= "9")
								begin
									state <= 5'd8;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					5'd8:
						begin
							if(Input >= "0" && Input <= "9")
								begin
									state <= 5'd1;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					5'd9:
						begin
							if(Input >= "0" && Input <= "9")
								begin
									state <= 5'd1;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					
					
					5'd12:
						begin
							if(Input == "1")
								begin
									state <= 5'd13;
								end
							else if(Input >= "2" && Input <= "9")
								begin
									state <= 5'd15;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					5'd13:
						begin
							if(Input == ".")
								begin
									state <= 5'd16;
								end
							else if(Input >= "0" && Input <= "2")
								begin
									state <= 5'd14;
								end
							else if(Input >= "3" && Input <= "9")
								begin
									state <= 5'd1;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					5'd14:
						begin
							if(Input == "-")
								begin
									state <= 5'd16;
								end
							else if(Input >= "0" && Input <= "9")
								begin
									state <= 5'd1;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					5'd15:
						begin
							if(Input == "-")
								begin
									state <= 5'd16;
								end
							else if(Input >= "0" && Input <= "9")
								begin
									state <= 5'd1;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					5'd16:
						begin
							if(Input >= "1" && Input <= "3")
								begin
									state <= 5'd17;
								end
							else if(Input >= "4" && Input <= "9")
								begin
									state <= 5'd19;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					5'd17:
						begin
							if(Input >= "0" && Input <= "9")
								begin
									state <= 5'd18;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					5'd18:
						begin
							if(Input >= "0" && Input <= "9")
								begin
									state <= 5'd1;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					5'd19:
						begin
							if(Input >= "0" && Input <= "9")
								begin
									state <= 5'd1;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					
					
					5'd22:
						begin
							if(Input == "1")
								begin
									state <= 5'd23;
								end
							else if(Input >= "2" && Input <= "9")
								begin
									state <= 5'd25;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					5'd23:
						begin
							if(Input == "/")
								begin
									state <= 5'd26;
								end
							else if(Input >= "0" && Input <= "2")
								begin
									state <= 5'd24;
								end
							else if(Input >= "3" && Input <= "9")
								begin
									state <= 5'd1;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					5'd24:
						begin
							if(Input == "/")
								begin
									state <= 5'd26;
								end
							else if(Input >= "0" && Input <= "9")
								begin
									state <= 5'd1;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					5'd25:
						begin
							if(Input == "/")
								begin
									state <= 5'd26;
								end
							else if(Input >= "0" && Input <= "9")
								begin
									state <= 5'd1;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					5'd26:
						begin
							if(Input >= "1" && Input <= "3")
								begin
									state <= 5'd27;
								end
							else if(Input >= "4" && Input <= "9")
								begin
									state <= 5'd29;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					5'd27:
						begin
							if(Input >= "0" && Input <= "9")
								begin
									state <= 5'd28;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					5'd28:
						begin
							if(Input >= "0" && Input <= "9")
								begin
									state <= 5'd1;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					5'd29:
						begin
							if(Input >= "0" && Input <= "9")
								begin
									state <= 5'd1;
								end
							else
								begin
									state <= 5'd0;
								end
						end
					
					
					
				endcase
			end
	end

endmodule
