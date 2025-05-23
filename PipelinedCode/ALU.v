`timescale 1ns / 1ps

module NBitALU #(parameter N = 32)(
input clk,
input [N-1:0] A,
input [N-1:0] B,
input  [3:0] sel,
output reg [N-1:0] result ,
output  zero_flag, overflow_flag , sign_flag, carry_flag
);

wire cout;
wire [N-1:0] Bf;
Nbit_2x1mux #(32) mux(B,~B+1,sel[2],Bf);
wire [N-1:0] ADD_SUB ;
wire [4:0] shift_amount; 
assign shift_amount = B[4:0];

N_bit_adder #(32) adder( A, Bf, ADD_SUB,cout);

wire [N-1:0] AND;
assign AND = A&B; //ANDI
wire [N-1:0] OR;
assign OR = A | B; //ORI
wire [N-1:0] XOR;
assign XOR = A ^ B; //XORI
wire [N-1:0] SLLI;
assign SLLI = A << shift_amount; //SLLI
wire [N-1:0] SRLI;
assign SRLI = A >> shift_amount; //SRLI
wire [N-1:0] SRAI;
wire sign_bit = A[N-1]; 
assign SRAI =  $signed(A) >>> shift_amount; //SRAI

wire [N-1:0] SLTI;
assign  SLTI = (A<B)?1:0 ; //SLTI

wire [N-1:0] SLTIU;
assign  SLTIU = ({1'b0, A}<{1'b0, B})?1:0 ; //SLTIU



always @(*) begin
    case(sel)
        4'b0000: result = AND;
        4'b0001: result = OR;
        4'b0010: result = ADD_SUB;
        4'b0110: result = ADD_SUB;
        4'b0100: result = XOR;
        4'b0111: result = SLLI;
        4'b1000: result = SRLI;
        4'b1001: result = SRAI;
        4'b1010: result = SLTI;
        4'b1011: result = SLTIU;    
        default: result = N-1'b0;  // Default case
    endcase
   end

assign zero_flag = (result == 0)?1'b1: 1'b0;
assign sign_flag = (result[N-1] == 1)?1'b1: 1'b0;
assign overflow_flag = (A[N-1] ^ (~B[N-1]) ^ ADD_SUB[N-1] ^ cout);
assign carry_flag = cout;



endmodule
