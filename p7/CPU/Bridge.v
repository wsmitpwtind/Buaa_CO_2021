`timescale 1ns / 1ps
module Bridge(
    input [31:0] PrAddr,
	 output [31:0] PrRD,
    input [31:0] PrWD,
	 input [3:0] Prbyteen,
	 
	 output [31:0] DM_Addr,
	 input [31:0] DM_RD,
    output [31:0] DM_WD,
	 output [3:0] DM_byteen,
	 
	 output [31:2] TM0_Addr,
	 input [31:0] TM0_RD,
    output [31:0] TM0_WD,
	 output TM0_we,
	 
	 output [31:2] TM1_Addr,
	 input [31:0] TM1_RD,
    output [31:0] TM1_WD,
	 output TM1_we
	 
    );

	 wire HitDm  = (PrAddr >= 32'h0000_0000 && PrAddr <= 32'h0000_2fff) ? 1'b1 : 1'b0;
	 wire HitTm0 = (PrAddr >= 32'h0000_7f00 && PrAddr <= 32'h0000_7f0b) ? 1'b1 : 1'b0;
	 wire HitTm1 = (PrAddr >= 32'h0000_7f10 && PrAddr <= 32'h0000_7f1b) ? 1'b1 : 1'b0;
	 
	 assign DM_Addr = PrAddr;
	 assign DM_WD = PrWD;
	 assign DM_byteen = (HitDm == 1'b1) ? Prbyteen : 4'b0;
	 
	 assign TM0_Addr = PrAddr[31:2];
	 assign TM0_WD = PrWD;
	 assign TM0_we = ((Prbyteen == 4'b1111) && HitTm0) ? 1'b1 : 1'b0;
	 
	 assign TM1_Addr = PrAddr[31:2];
	 assign TM1_WD = PrWD;
	 assign TM1_we = ((Prbyteen == 4'b1111) && HitTm1) ? 1'b1 : 1'b0;
	
	 assign PrRD = HitDm  ? DM_RD  :
						HitTm0 ? TM0_RD :
						HitTm1 ? TM1_RD : 32'b0;
		
endmodule