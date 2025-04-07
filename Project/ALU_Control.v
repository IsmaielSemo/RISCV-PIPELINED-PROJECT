`timescale 1ns / 1ps


module ALUControlUnit (
    input [1:0] ALUOp,      
    input [2:0] function3,  
    input function1,           
    output reg [3:0] ALU_sel 
);

always @(*) begin

    ALU_sel  = 4'b0000;
    
    case (ALUOp)
        2'b00: ALU_sel  = 4'b0010;  // ADD
        2'b01: ALU_sel  = 4'b0110;  // SUB
        2'b10: begin
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
                ALU_sel = 4'b0111; //SLLI
            else if({function3,function1} == 4'b1010)
                ALU_sel = 4'b1000; //SRLI
            else if({function3,function1} == 4'b1011)
                ALU_sel = 4'b1001;   //SRAI
            else if({function3,function1} == 4'b0100)
                ALU_sel = 4'b1010;   //SLTI 
            else if({function3,function1} == 4'b0110)
                ALU_sel = 4'b1011;   //SLTIU
        end
        2'b11: begin //I type instructions
            if(function3 == 3'b000)
                ALU_sel = 4'b0010;// AddI
            else if(function3 == 3'b111)
                ALU_sel = 4'b0000; //ANDI
            else if(function3 == 3'b111)
                ALU_sel = 4'b0000; //ANDI 
            else if(function3 == 3'b111)
                ALU_sel = 4'b0000; //ANDI 
            else if(function3 == 3'b111)
                ALU_sel = 4'b0000; //ANDI
            else if(function3 == 3'b111)
                ALU_sel = 4'b0000; //ANDI 
            else if(function3 == 3'b111)
                ALU_sel = 4'b0000; //ANDI 
            else if(function3 == 3'b111)
                ALU_sel = 4'b0000; //ANDI
            else if(function3 == 3'b111)
                ALU_sel = 4'b0000; //ANDI
        
        end
            endcase
        end             
    endcase
end

endmodule
