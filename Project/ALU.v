`timescale 1ns / 1ps

module NBitALU #(parameter N = 32)(
input clk,
input [N-1:0] A,
input [N-1:0] B,
input  [3:0] sel,
output  [N-1:0] result ,
output  zero_flag, overflow_flag , sign_flag, carry_flag
);

wire [N-1:0] Bf;
Nbit_2x1mux #(32) mux(B,~B+1,sel[2],Bf);
wire [N-1:0] ADD_SUB ;
//wire cout;

N_bit_adder #(32) adder( A, Bf, ADD_SUB);

wire [N-1:0] AND;
assign AND = A&B; //ANDI
wire [N-1:0] OR;
assign OR = A | B; //ORI
wire [N-1:0] XOR;
assign XOR = A ^ B; //XORI
wire [N-1:0] SLLI;
assign SLTI = A << B;
wire [N-1:0] SRLI;
assign SRLI = A >> B;
wire [N-1:0] SRAI;
wire sign_bit = A[N-1]; 
assign SRAI = { {B{sign_bit}}, A >> B };
wire [N-1:0] SLT_SLTU_SLTI_SLTIU;
assign  SLT_SLTU_SLTI_SLTIU = (A<B)?1:0 ; // Also SLTIU



mux16x1 #(32) mux6(AND,OR,ADD_SUB,ADD_SUB,sel,result);
assign zero_flag = (result == 0)?1'b1: 1'b0;
assign sign_flag = (result[N-1] == 1)?1'b1: 1'b0;
assign overflow_flag = (result == 0)?1'b1: 1'b0;
assign carry_flag = (result == 0)?1'b1: 1'b0;

endmodule