`timescale 1ns / 1ps

module N_bit_adder #(parameter N=32)(input1,input2,answer,overflow);

input [N-1:0] input1,input2;
   output [N-1:0] answer;
   output [1:0] overflow;
  wire  carry_out;
  wire [N-1:0] carry;
   genvar i;
   generate 
   for(i=0;i<N;i=i+1)
     begin: generate_N_bit_Adder
   if(i==0) 
  half_adder f(input1[0],input2[0],answer[0],carry[0]);
   else
  full_adder f(input1[i],input2[i],carry[i-1],answer[i],carry[i]);
     end
  assign carry_out = carry[N-1];
  assign overflow[0] = (carry_out == 1)?1:0; //overflow for unsigned
  assign overflow[1] = ( (A[N-1] == B[N-1]) && (sum[N-1] != A[N-1]) )?1:0; //overflow for signed
  
   endgenerate
endmodule 


module half_adder(x,y,s,c);
   input x,y;
   output s,c;
   assign s=x^y;
   assign c=x&y;
endmodule // half adder


module full_adder(x,y,c_in,s,c_out);
   input x,y,c_in;
   output s,c_out;
 assign s = (x^y) ^ c_in;
 assign c_out = (y&c_in)| (x&y) | (x&c_in);
endmodule // full_adder

module mux16x1 #(parameter N=32)(
    input [N-1:0] AND,OR,ADD,SUB, // 16-bit input data
    input [3:0] sel,       // 4-bit select signal
    output reg [N-1:0]  out         // Output
);

always @(*) begin
    case(sel)
        4'b0000: out = AND;
        4'b0001: out = OR;
        4'b0010: out = ADD;//
        4'b0110: out = SUB;//   
        default: out = N-1'b0;  // Default case
    endcase
end
endmodule



