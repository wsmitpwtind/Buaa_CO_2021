`timescale 1ns / 1ps

module async_reset(
      input clk,
      input rst_n,
      input data_in,
      output reg data_out
    ); 
      
      always @ (posedge clk or negedge rst_n)
           if (!rst_n)
                 data_out <= 1'b0;
           else
                 data_out <= data_in;

endmodule
