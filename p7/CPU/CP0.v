`timescale 1ns / 1ps
`define IM SR[15:10]    // allow 6 hardware ints
`define EXL SR[1]       // in int (cannot int/exc)
`define IE SR[0]        // allow int
`define BD Cause[31]
`define hwint_pend Cause[15:10]
`define ExcCode Cause[6:2]

module CP0(
    input clk,
    input reset,
	 
	 input WE,
	 input [4:0] Read_addr,
	 input [4:0] Write_addr,
	 input [31:0] Write_data,
	
	 input [31:0] PC,
	 input BD,
	 input [6:2] ExcCode,
	 input [5:0] HWInt,
	 input EXLClr,
	 
    output Req,
    output [31:0] EPCout,	
    output [31:0] Read_data,
	 
	 output TestIntResponse
	 
    );

    //////////// Reg
    reg [31:0] SR;
    reg [31:0] Cause;
    reg [31:0] EPCreg;
    reg [31:0] PrID;
    //////////// EndReg

    wire IntReq = (|(HWInt & `IM)) & !`EXL & `IE;
    wire ExcReq = (|ExcCode) & !`EXL;
    assign Req  = IntReq | ExcReq;

    wire [31:0] tempEPC = (Req) ? (BD ? {PC[31:2]-1,PC[1:0]} : {PC[31:2],PC[1:0]})
                                : EPCreg;

    assign EPCout = {tempEPC[31:0]};
	 
	 assign TestIntResponse = IntReq;
	
    initial begin
        SR      <= 0;
        Cause   <= 0;
        EPCreg  <= 0;
        PrID    <= 32'h1937_6075;
    end

    assign Read_data =   (Read_addr == 12) ? SR:
                    (Read_addr == 13) ? Cause:
                    (Read_addr == 14) ? EPCout:
                    (Read_addr == 15) ? PrID:
                    0;

    always@(posedge clk or posedge reset)begin
        if(reset)begin
            SR      <= 0;
            Cause   <= 0;
            EPCreg  <= 0;
            PrID    <= 32'h1937_6075;
        end else begin
            if (EXLClr) `EXL <= 1'b0;

            if (Req) begin // int|exc
                `ExcCode <= IntReq ? 5'b0 : ExcCode;
                `EXL <= 1'b1;
                EPCreg <= tempEPC;
                `BD <= BD;
            end else if (WE) begin // mtc0 & !(int|exc)
                if (Write_addr == 12) SR <= Write_data;
                else if (Write_addr == 14) EPCreg <= Write_data[31:0];
            end
            `hwint_pend <= HWInt;
      end
   end

endmodule
