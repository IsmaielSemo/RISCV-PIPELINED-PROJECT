`timescale 1ns / 1ps


module Nbit_shift_left #(parameter N=8)(
input [N-1:0] a,
output [N-1:0] out
    );
    
    assign out = {a[N-2:0], 1'b0};
    
endmodule

module Nbit_shifter_left_12 #(parameter N=8)(
input [N-1:0] a,
output [N-1:0] out
    );
    
    assign out = a<<12;
    
endmodule
 
 module Nbit_shifter_right #(parameter N=8, parameter R = 1)(
input [N-1:0] a,
output [N-1:0] out
    );
    
    assign out = a>>R;
    
endmodule
