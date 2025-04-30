`timescale 1ns / 1ps


module ALUControlUnit (
    input [1:0] ALUOp,      
    input [2:0] function3,  
    input function1,           
    output reg [3:0] ALU_sel 
);

always @(*) begin

    //ALU_sel  = 4'b0000;
    
    case (ALUOp)
        2'b00: ALU_sel  = 4'b0010;  // LW, SW
        2'b01: ALU_sel  = 4'b0110;  // Branch
        2'b10: begin //R Type
            if({function3,function1} == 4'b0000) 
                ALU_sel = 4'b0010; //ADD
            else if({function3,function1} == 4'b0001)
                ALU_sel = 4'b0110; //SUB
            else if({function3,function1} == 4'b1110)
                ALU_sel = 4'b0000; //AND
            else if({function3,function1} == 4'b1100)
                ALU_sel = 4'b0001; //OR
            else if({function3,function1} == 4'b1000)
                ALU_sel = 4'b0100; //XOR
            else if({function3,function1} == 4'b0010)
                ALU_sel = 4'b0111; //SLL
            else if({function3,function1} == 4'b1010)
                ALU_sel = 4'b1000; //SRL
            else if({function3,function1} == 4'b1011)
                ALU_sel = 4'b1001;   //SRA
            else if({function3,function1} == 4'b0100)
                ALU_sel = 4'b1010;   //SLT 
            else if({function3,function1} == 4'b0110)
                ALU_sel = 4'b1011;   //SLTU
        end
        2'b11: begin //I type instructions
            if(function3 == 3'b000)
                ALU_sel = 4'b0010;// ADDI
            else if(function3 == 3'b111)
                ALU_sel = 4'b0000; //ANDI
            else if(function3 == 3'b110)
                ALU_sel = 4'b0001; //ORI 
            else if(function3 == 3'b100)
                ALU_sel = 4'b0100; //XORI 
            else if(function3 == 3'b001)
                ALU_sel = 4'b0111; //SLLI
            else if(function3 == 3'b101) begin
                if(function1 == 1'b0)
                    ALU_sel = 4'b1000; //SRLI
                else
                    ALU_sel = 4'b1001; //SRAI
                end
            else if(function3 == 3'b010)
                ALU_sel = 4'b1010; //SLTI
            else if(function3 == 3'b011)
                ALU_sel = 4'b1011; //SLTIU
//            else if(function3 == 3'b101)
//                ALU_sel = 4'b1001; //SRAI
        end
    default: ALU_sel  = 4'bXXXX;
    endcase
end             

endmodule

