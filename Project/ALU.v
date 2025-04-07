`timescale 1ns / 1ps

module NBitALU #(parameter N = 32)(
input clk,
input [N-1:0] A,
input [N-1:0] B,
input  [3:0] sel,
output  [N-1:0] result ,
output  zero_flag, overflow_flag , sign_flag, carry_flag
);

wire cout;
wire [N-1:0] Bf;
Nbit_2x1mux #(32) mux(B,~B+1,sel[2],Bf);
wire [N-1:0] ADD_SUB ;


N_bit_adder #(32) adder( A, Bf, ADD_SUB,cout);

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

wire [N-1:0] SLTI;
assign  SLTI = (A<B)?1:0 ; 

wire [N-1:0] SLTIU;
assign  SLTIU = ({1'b0, A}<{1'b0, B})?1:0 ;

//wire [N-1:0] SLT_SLTU_SLTI_SLTIU;
//assign  SLT_SLTU_SLTI_SLTIU = (A<B)?1:0 ; // Also SLTIU



//mux16x1 #(32) mux6(AND,OR,ADD_SUB,ADD_SUB,sel,result);

always @(*) begin
    case(sel)
        4'b0000: result = AND;
        4'b0001: result = OR;
        4'b0010: result = ADD;
        4'b0110: result = SUB;
        4'b0100: result = XOR;
        4'b0111: result = SLLI;
        4'b1000: result = SRLI;
        4'b1001: result = SRAI;
        4'b1010: result = SLTI;
        4'b1011: result = SLTIU;    
        default: out = N-1'b0;  // Default case
    endcase
   end

assign zero_flag = (result == 0)?1'b1: 1'b0;
assign sign_flag = (result[N-1] == 1)?1'b1: 1'b0;
assign overflow_flag = (A[N-1] ^ (~B[N-1]) ^ ADD_SUB[N-1] ^ cout);
assign carry_flag = cout;

//assign overflow_flag = (result == 0)?1'b1: 1'b0;
//assign carry_flag = (result == 0)?1'b1: 1'b0;

endmodule
