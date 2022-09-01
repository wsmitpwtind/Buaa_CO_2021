`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:12:40 10/25/2021 
// Design Name: 
// Module Name:    vote 
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
module vote(
    input [31:0] np,
    input [7:0] vip,
    input vvip,
    output res
    );
	 
reg [31:0] add_np;
reg [31:0] add_vip;

integer i;

always @(*)
	begin
		add_np = 32'd0;
		for(i=0; i<32; i=i+1)
			begin
				add_np = add_np + np[i];
			end
	end


always @(*)
	begin
		add_vip = 32'd0;
		for(i=0; i<8; i=i+1)
			begin
				add_vip = add_vip + vip[i];
			end
	end

wire [31:0] add;

assign add = add_np + (add_vip << 2) + (vvip << 4);
assign res = (add >= 32'd32)? 1'b1 : 1'b0;


endmodule
