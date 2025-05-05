`timescale 1ns / 1ps

module pipeline(input clk,reset);


wire Branch; //M
wire Mem; //M
wire MemtoReg; //WB
wire [1:0] ALUOp; //EX
wire MemWrite; //M
wire ALUSrc; //EX
wire RegWrite; //WB
wire jal, jalr, auipc, halt; 
wire lui; //control signal
wire [31:0] LUI; 
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
//wire [31:0] PC_in;
reg [31:0] PC_in;
wire cout;
wire [31:0] branchAdder, add4;
wire last_sel;
wire [31:0] PC_out;
wire stall;
wire forwardA;
wire forwardB;
wire [31:0] AUIPC,JAL,JALR;



//IF/ID
wire [31:0] IF_ID_PC;
wire [31:0] IF_ID_PCadd4;
wire [31:0] IF_ID_Inst;
wire [31:0] flush_IF_ID;

//ID/EX
wire [31:0] ID_EX_PC, ID_EX_RegR1, ID_EX_RegR2, ID_EX_Imm, ID_EX_PCadd4;
wire [12:0] ID_EX_Ctrl;
wire [3:0] ID_EX_Func;
wire [4:0] ID_EX_Rs1, ID_EX_Rs2, ID_EX_Rd;
wire [4:0] ID_EX_Opcode;
 wire [11:0] flush_ID_EX;  
    
//EX/MEM
wire [31:0] EX_MEM_BranchAddOut, EX_MEM_ALU_out, EX_MEM_RegR2; 
wire [9:0] EX_MEM_Ctrl;
wire [4:0] EX_MEM_Rd;
wire EX_MEM_Zero;
wire EX_MEM_Carry;
wire EX_MEM_Sign;
wire EX_MEM_Overflow;
wire EX_MEM_Imm;
wire EX_MEM_PCadd4;
wire [3:0] EX_MEM_funct;
wire [4:0] EX_MEM_Opcode;
wire [31:0] EX_MEM_PC;
wire [9:0] flush_EX_MEM; 
    
//MEM/WB    
wire [31:0] MEM_WB_Mem_out, MEM_WB_ALU_out;
wire [6:0] MEM_WB_Ctrl;
wire [4:0] MEM_WB_Rd;
wire [31:0] MEM_WB_Imm;
wire [31:0] MEM_WB_Branch;
wire [31:0] MEM_WB_PCadd4;
wire [31:0] DataOut;
wire [31:0] MEM_WB_AUIPC; 
wire [31:0] MEM_WB_JALR;


//IF stage



NbitRegister #(32) PC(PC_in , reset, halt , clk, PC_out);

N_bit_adder #(32) add1( 32'd4 , PC_out, add4 );

assign flush_IF_ID = (branch_out | reset)? (32'd0) : data_final; 

NbitRegister #(96) IF_ID (
        .D({PC_out, add4, flush_IF_ID}),
        .rst(reset),
        .load(1'b1),
        .clk(~clk),
        .Q({IF_ID_PC, IF_ID_PCadd4, IF_ID_Inst})
    ); 




    
    
//ID stage

ControlUnit CU(IF_ID_Inst[6:2],  MemRead,  MemtoReg,   ALUOp,    MemWrite, ALUSrc,  RegWrite, Branch, jal,jalr,auipc,halt,lui);
ImmGen imm (imm_out, IF_ID_Inst);
        
Register_Reset RF(clk,reset,MEM_WB_Ctrl[0],IF_ID_Inst [19:15], IF_ID_Inst [24:20], MEM_WB_Rd, WriteData, data_in1, data_in2); //MEM_WB_Rd is IF_ID_INST[11:7]

//HazardControlUnit HazardUnit( IF_ID_Inst[19:15], IF_ID_Inst[24:20], ID_EX_Rd,ID_EX_Ctrl[6] /*Memread*/, stall);
assign flush_ID_EX = (branch_out | reset) ? 12'd0: {jal,jalr,auipc,halt,lui,Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite} ;


NbitRegister #(300) ID_EX (
        .D({IF_ID_PC,IF_ID_PCadd4, data_in1, data_in2, imm_out, IF_ID_Inst[6:2], IF_ID_Inst[30], IF_ID_Inst[14:12], IF_ID_Inst[19:15], IF_ID_Inst[24:20], IF_ID_Inst[11:7],flush_ID_EX}),
        .rst(reset),
        .load(1'b1),
        .clk(clk),
        .Q({ID_EX_PC,ID_EX_PCadd4, ID_EX_RegR1, ID_EX_RegR2, ID_EX_Imm, ID_EX_Opcode, ID_EX_Func, ID_EX_Rs1, ID_EX_Rs2, ID_EX_Rd, ID_EX_Ctrl})
    ); 





//EX stage

mux4x2 #(32) F1 (ID_EX_RegR1,DataOut,32'b0,32'b0, forwardA,ALU_in1);  //32'b0 replaced EX_MEM_ALU_out as we do not need to worry about this hazard since we now have a single memory 
mux4x2 #(32) F2 (ID_EX_RegR2,DataOut,32'b0,32'b0, forwardB,ALU_in2); //32'b0 replaced EX_MEM_ALU_out as we do not need to worry about this hazard since we now have a single memory

     Nbit_2x1mux #(32) ALU_2ndInput (
        ALU_in2, 
        ID_EX_Imm,
        ID_EX_Ctrl[1],
        B
    );


ALUControlUnit ALUcontrol(ID_EX_Ctrl[4:3],ID_EX_Func[2:0],ID_EX_Func[3],ALU_sel);  //first parameter not really needed
NBitALU #(32) ALU(clk,ALU_in1,B, ALU_sel,ALU_Result,zero_flag,  overflow_flag , sign_flag, carry_flag );
N_bit_adder #(32) add2(ID_EX_Imm,ID_EX_PC, branchAdder); //We don't need other conditions like before as imm_generator already does the shifting for us
assign flush_EX_MEM = (branch_out)? 10'd0: {ID_EX_Ctrl[12]/*jal*/,ID_EX_Ctrl[11] /*jalr*/,ID_EX_Ctrl[10] /*auipc*/,ID_EX_Ctrl[9] /*halt*/,ID_EX_Ctrl[8] /*lui*/ ,ID_EX_Ctrl[5]/*Memtoreg*/, ID_EX_Ctrl[0]/*Regwrite*/, ID_EX_Ctrl[7]/*Branch*/, ID_EX_Ctrl[6]/*MemRead*/, ID_EX_Ctrl[2]/*Memwrite*/} ;

NbitRegister #(300) EX_MEM (
        .D({branchAdder, ALU_Result, zero_flag, overflow_flag, sign_flag, carry_flag,ID_EX_Imm,ID_EX_PCadd4,ID_EX_Func,ID_EX_Opcode, ID_EX_PC, ALU_in2, ID_EX_Rd,flush_EX_MEM}),
        .rst(reset),
        .load(1'b1),
        .clk(~clk),
        .Q({EX_MEM_BranchAddOut, EX_MEM_ALU_out, EX_MEM_Zero, EX_MEM_Overflow,EX_MEM_Sign, EX_MEM_Carry,EX_MEM_Imm,EX_MEM_PCadd4,EX_MEM_funct, EX_MEM_Opcode, EX_MEM_PC, EX_MEM_RegR2, EX_MEM_Rd, EX_MEM_Ctrl})
    ); 




    
//MEM stage   


Memory mem (.addr({EX_MEM_ALU_out[6:0], EX_MEM_PC[6:0]}),.data_in(EX_MEM_RegR2),.func3(EX_MEM_funct[2:0]),.clk(clk),.MemRead(EX_MEM_Ctrl[1]),.MemWrite(EX_MEM_Ctrl[0]),.data_out(data_final)); //EX_MEM_PC is PC_out


BranchControl branchCntl( EX_MEM_Ctrl[2] /*branch*/, EX_MEM_Zero, EX_MEM_Sign, EX_MEM_Overflow, EX_MEM_Carry, EX_MEM_Opcode, EX_MEM_funct [2:0] , branch_out);
assign AUIPC = EX_MEM_PC + EX_MEM_Imm; //PC_out + LUI
assign JAL = EX_MEM_PCadd4; //add4
assign JALR = EX_MEM_PCadd4; //add4

//N_bit_adder #(32) branchJump( EX_MEM_Imm, EX_MEM_PC, branchAdder); //PC_out + shifted_imm
//assign PC_in = (EX_MEM_Ctrl[7]==1)? AUIPC:
//                (EX_MEM_Ctrl[8]==1)? JALR: 
//                (EX_MEM_Ctrl[2] /*Branch*/ && branch_out)? EX_MEM_BranchAddOut:
//                 add4; //EX_MEM_PCADD4 (PC+4)


always @(*) begin
    if (EX_MEM_Ctrl[7] == 1'b1)
        PC_in = AUIPC;  // auipc
    else if (EX_MEM_Ctrl[8] == 1'b1)
        PC_in = JALR;  
    else if (EX_MEM_Ctrl[2] && branch_out)
        PC_in = EX_MEM_BranchAddOut;  // taken branch
    else
        PC_in = add4;  // (/EX_MEM_PCADD4) PC+4 (sequential execution)
end



//always @(posedge clk or posedge reset) begin
//    if (reset) begin
//        PC_in <= 32'd0;  // Reset PC to 0
//    end else begin
//        // PC selection logic
//        if (EX_MEM_Ctrl[7] == 1'b1)
//            PC_in <= AUIPC;  // auipc
//        else if (EX_MEM_Ctrl[8] == 1'b1)
//            PC_in <= JALR;   // jalr
//        else if (EX_MEM_Ctrl[2] && branch_out)
//            PC_in <= EX_MEM_BranchAddOut;  // taken branch
//        else
//            PC_in <= EX_MEM_PCadd4;  // PC+4 (sequential execution)
//    end
//end

NbitRegister #(300) MEM_WB (
        .D({data_final, EX_MEM_ALU_out,EX_MEM_Imm,EX_MEM_BranchAddOut,EX_MEM_PCadd4, AUIPC, JALR, EX_MEM_Rd, EX_MEM_Ctrl[9], EX_MEM_Ctrl[8],EX_MEM_Ctrl[7],EX_MEM_Ctrl[6],EX_MEM_Ctrl[5],EX_MEM_Ctrl[4], EX_MEM_Ctrl[3]}),
        .rst(reset),
        .load(1'b1),
        .clk(clk),
        .Q({MEM_WB_Mem_out, MEM_WB_ALU_out, MEM_WB_Imm, MEM_WB_Branch,MEM_WB_PCadd4, MEM_WB_AUIPC, MEM_WB_JALR, MEM_WB_Rd, MEM_WB_Ctrl})
    ); 


//ID_EX_CTRL:           jal jalr auipc halt lui Branch MemRead MemtoReg ALUOp MemWrite ALUSrc RegWrite                                                                     
//EX_MEM_Ctrl:          jal jalr auipc halt lui  Memtoreg  Regwrite  Branch  MemRead   MemWrite
//MEM_WB_Ctrl:          jal jalr auipc halt lui Memtoreg  Regwrite


//WB stage

Nbit_2x1mux #(32) mux2(MEM_WB_ALU_out,MEM_WB_Mem_out,MEM_WB_Ctrl[1], DataOut); //Memtoreg is CU

assign WriteData =
                      MEM_WB_Ctrl[4]    ? MEM_WB_AUIPC:
                      (MEM_WB_Ctrl[5] || MEM_WB_Ctrl[6])? MEM_WB_JALR:
                      MEM_WB_Ctrl[2]      ? MEM_WB_Imm :
                                 DataOut;
                                 
ForwardingUnit FU(ID_EX_Rs1,ID_EX_Rs2,EX_MEM_Rd,MEM_WB_Rd,EX_MEM_Ctrl[3], MEM_WB_Ctrl[0],forwardA, forwardB );                               


    
endmodule
