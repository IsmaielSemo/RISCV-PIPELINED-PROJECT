`timescale 1ns / 1ps


module pipeline_TB();
localparam clk_period = 10;



reg clk = 1'b0;
reg reset;

    
 pipeline Process(clk,reset);
 
initial 
    begin
      forever
         #(clk_period /2) clk = ~clk;
    end 
 
initial begin
       
        reset = 1;
        #5
        reset = 0;

       

    end 
 

endmodule
