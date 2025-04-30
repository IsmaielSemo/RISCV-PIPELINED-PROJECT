`timescale 1ns / 1ps

module pipeline(input clk,reset,  input [1:0] ledSel,
    input [3:0] ssdSel,
    output reg [15:0] leds, output reg [12:0] ssd );

wire [31:0] instruction; // WE WILL HAVE TO GET IT FROM THE DATA MEM BECAUSE ONE MEMORY
wire Branch; //M
wire Mem; //M
wire MemtoReg; //WB
wire [1:0] ALUOp; //EX
wire MemWrite; //M
wire ALUSrc; //EX
wire RegWrite; //WB
wire jal, jalr, auipc, halt; 
wire lui; 
wire [31:0] imm_out;
wire [31:0] data_in1;
wire [31:0] data_in2;
wire zero_flag, branch_out;
wire carry_flag, overflow_flag, sign_flag;
wire [31:0] ALU_Result;
wire  [3:0] ALU_sel;
wire [31:0] B;
wire [31:0] data_final;
wire [31:0] WriteData;
wire [31:0] PC_in;
wire cout;
wire [31:0] Sum, add4;
wire last_sel;
wire [31:0] PC_out;
wire [15:0] signals;
wire stall;
wire forwardA;
wire forwardB;

//IF/ID
wire [31:0] IF_ID_PC;
wire [31:0] IF_ID_PCadd4;
wire [31:0] IF_ID_Inst;

//ID/EX
wire [31:0] ID_EX_PC, ID_EX_RegR1, ID_EX_RegR2, ID_EX_Imm, ID_EX_PCadd4;
wire [7:0] ID_EX_Ctrl;
wire [3:0] ID_EX_Func;
wire [4:0] ID_EX_Rs1, ID_EX_Rs2, ID_EX_Rd;
    
//EX/MEM
wire [31:0] EX_MEM_BranchAddOut, EX_MEM_ALU_out, EX_MEM_RegR2; 
wire [4:0] EX_MEM_Ctrl;
wire [4:0] EX_MEM_Rd;
wire EX_MEM_Zero;
    
//MEM/WB    
wire [31:0] MEM_WB_Mem_out, MEM_WB_ALU_out;
wire [1:0] MEM_WB_Ctrl;
wire [4:0] MEM_WB_Rd;


//IF stage

N_Bit_ResetLoad_Register #(32) PC(PC_in , reset, stall, clk, PC_out);
N_bit_adder #(32) add1( 32'd4 , PC_out, add4 );
//
//We will need to flush here
//
NbitRegister #(96) IF_ID (
        .D({PC_out, add4, instruction}),
        .rst(reset),
        .load(1'b1),
        .clk(clk),
        .Q({IF_ID_PC, IF_ID_PCadd4, IF_ID_Inst})
    ); //should we update clk to be some other value (maybe even ~clk)
    
    
//ID stage

ControlUnit CU(IF_ID_Inst[6:2],  MemRead,  MemtoReg,   ALUOp,    MemWrite, ALUSrc,  RegWrite, Branch, jal,jalr,auipc,halt,lui);
ImmGen imm (imm_out, IF_ID_Inst);
        
Register_Reset RF(clk,reset,RegWrite,IF_ID_Inst [19:15], IF_ID_Inst [24:20], IF_ID_Inst [11:7], WriteData, data_in1, data_in2); //We will change regwrite and maybe [11:7] to be from MEM/WB
//
//Add flush control here (with the control signals being 0 and whatnot)
//

NbitRegister #(192) ID_EX (
        .D({IF_ID_PC,IF_ID_PCadd4, data_in1, data_in2, imm_out, IF_ID_Inst[30], IF_ID_Inst[14:12], IF_ID_Inst[19:15], IF_ID_Inst[24:20], IF_ID_Inst[11:7],jal,jalr,auipc,halt,lui, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite}),
        .rst(reset),
        .load(1'b1),
        .clk(clk),
        .Q({ID_EX_PC,ID_EX_PCadd4, ID_EX_RegR1, ID_EX_RegR2, ID_EX_Imm, ID_EX_Func, ID_EX_Rs1, ID_EX_Rs2, ID_EX_Rd, ID_EX_Ctrl})
    ); //How will we handle the control signals (we could leave them like this or do them like a variable) + 192 is the real value (200 for safekeeping)


//EX stage


//ForwardingUnit FU(ID_EX_Rs1,ID_EX_Rs2,EX_MEM_Rd,MEM_WB_Rd,EX_MEM_Ctrl[3], MEM_WB_Ctrl[0],forwardA, forwardB );
mux4x2 #(32) F1 (ID_EX_RegR1,WriteData,EX_MEM_ALU_out,32'b0, forwardA,ALU_in1);  //EX_MEM_ALU_out might be 32'b0
mux4x2 #(32) F2 (ID_EX_RegR2,WriteData,EX_MEM_ALU_out,32'b0, forwardB,ALU_in2); ////EX_MEM_ALU_out might be 32'b0

     Nbit_2x1mux #(32) ALU_2ndInput (
        ALU_in2, 
        ID_EX_Imm,
        ID_EX_Ctrl[1],
        B
    );

//Stopped Here



Nbit_2x1mux #(32) MUX(data_in2,imm_out,ALUSrc,B);
ALUControlUnit ALUcontrol(ALUOp,instruction[14:12],instruction[30],ALU_sel); 
NBitALU #(32) ALU(clk,data_in1,B, ALU_sel,ALU_Result,zero_flag,  overflow_flag , sign_flag, carry_flag );
//Nbit_2x1mux #(32) mux1(ALU_Result,data_in2,MemtoReg,B);



NbitRegister #(107) EX_MEM (
        .D({Sum, ALU_Result, zero_flag, ID_EX_RegR2, ID_EX_Rd, ID_EX_Ctrl[5]/*Memtoreg*/, ID_EX_Ctrl[0]/*Regwrite*/, ID_EX_Ctrl[7]/*Branch*/, ID_EX_Ctrl[6]/*MemRead*/, ID_EX_Ctrl[2]/*Memwrite*/}),
        .rst(reset),
        .load(1'b1),
        .clk(clk),
        .Q({EX_MEM_BranchAddOut, EX_MEM_ALU_out, EX_MEM_Zero, EX_MEM_RegR2, EX_MEM_Rd, EX_MEM_Ctrl})
    );
    
 //MEM stage   

DataMem data_mem(clk,MemRead,MemWrite,ALU_Result[7:2], instruction[14:12] ,data_in2 ,data_final);

    
wire [31:0] DataOut;
Nbit_2x1mux #(32) mux2(ALU_Result,data_final,MemtoReg, DataOut);

assign WriteData =
                      auipc    ? AUIPC :
                      (jalr||jal)? JALR :
                      lui      ? LUI :
                                 DataOut;

                 
BranchControl branchCntl( Branch, zero_flag, sign_flag, overflow_flag, carry_flag, instruction[6:2] , instruction[14:12] , branch_out);

wire [31:0] shifted_imm_out; //since it is not used anymore we might need to remove it (because it causes immediate = 2 * immediate so instead of branch by 3 we branch by 6)
Nbit_shift_left #(32) shift(imm_out,shifted_imm_out); //might need to be removed

wire [31:0] LUI;
Nbit_shift_left_12 #(32) shift12(imm_out,LUI);

wire [31:0] shifted;
//Nbit_2x1mux #(32) mux_shift(shifted_imm_out,LUI,auipc, shifted); 
Nbit_2x1mux #(32) mux_shift(imm_out,LUI,auipc, shifted);
N_bit_adder #(32) add2( shifted, PC_out, Sum);


wire [31:0] AUIPC,JAL,JALR;
assign AUIPC = PC_out + LUI;
assign JAL = add4;
assign JALR = add4;


//assign last_sel = zero_flag & Branch; not needed for branch detection
assign PC_in = (auipc==1)? AUIPC:
                (jalr==1)? JALR: 
                (Branch && branch_out)? Sum:
                 add4;
//Nbit_2x1mux #(32) mux3(add4,Sum, last_sel,PC_in);








assign signals ={2'b00,ALUOp,ALU_Result,zero_flag,last_sel,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite};
always@(*)begin
case(ledSel)
2'b00:leds =instruction[15:0];
2'b01:leds =instruction[31:16];
2'b10:leds =signals;
2'b11:leds =15'd0;
endcase 
end 

 always @(*) begin
        case(ssdSel)
            4'b0000: ssd = PC_out;               
            4'b0001: ssd = add4;       
            4'b0010: ssd = Sum;    
            4'b0011: ssd = PC_in;            
            4'b0100: ssd = data_in1;     
            4'b0101: ssd = data_in1;     
            4'b0110: ssd = WriteData;           
            4'b0111: ssd = imm_out;     
            4'b1000: ssd = shifted_imm_out; //potentially just imm_out  
            4'b1001: ssd = B;     
            4'b1010: ssd = ALU_Result;      
            4'b1011: ssd = data_final;          
            default: ssd = 13'd0;                  
        endcase
    end

//    always @(*) begin
//        leds = {ledSel, 14'b0};  
//    end
    
    
endmodule