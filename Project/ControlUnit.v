`timescale 1ns / 1ps



module ControlUnit ( //Inst was originally from 4:0
    input [4:0] Inst,                  
    output reg MemRead,       
    output reg MemtoReg,      
    output reg [1:0] ALUOp,   
    output reg MemWrite,      
    output reg ALUSrc,        
    output reg RegWrite,
    output reg Branch, jal, jalr, auipc, halt       
);

always @(*) begin

    Branch = 0;
    MemRead = 0;
    MemtoReg = 0;
    ALUOp = 2'b00;            
    MemWrite = 0;
    ALUSrc = 0;
    RegWrite = 0;
    auipc = 0;
    halt=0;
    jal=0;
    jalr=0;
    case (Inst)
        5'b01_100: begin  //originally 5'b01100 R
            Branch = 0;
            MemRead = 0;
            MemtoReg = 0;
            ALUOp = 2'b10;   
            MemWrite = 0;
            ALUSrc = 0;
            RegWrite = 1;    
            jal=0; jalr=0; auipc=0; halt=0;
        end

        5'b00_000: begin  //originally 5'b00000 Load
            Branch = 0;
            MemRead = 1;
            MemtoReg = 1;    
            ALUOp = 2'b00;   
            MemWrite = 0;
            ALUSrc = 1;     
            RegWrite = 1;    
            jal=0; jalr=0; auipc=0; halt=0;
        end

        5'b01_000: begin  //originally 5'b01000
            Branch = 0;
            MemRead = 0;
            MemtoReg = 1'bx;   
            ALUOp = 2'b00;  
            MemWrite = 1;    
            ALUSrc = 1;     
            RegWrite = 0;
            jal=0; jalr=0; auipc=0; halt=0; 
               
        end

        5'b11_000: begin  //originally 11000
            Branch = 1;  
            MemRead = 0;
            MemtoReg = 1'bx;    
            ALUOp = 2'b01;   
            MemWrite = 0;
            ALUSrc = 0;      
            RegWrite = 0; 
            jal=0; jalr=0; auipc=0; halt=0;  
        end
        5'b00_101: begin  
            Branch = 1;  
            MemRead = 0;
            MemtoReg = 0'bx;    
            ALUOp = 2'b00;   
            MemWrite = 0;
            ALUSrc = 0;      
            RegWrite = 1;
             jal=0; jalr=0; auipc=1; halt=0;   
        end
        5'b01_101: begin  
            Branch = 0;  
            MemRead = 0;
            MemtoReg =0'bx;    
            ALUOp = 2'b11;   
            MemWrite = 0;
            ALUSrc = 1;      
            RegWrite = 1;  
            jal=0; jalr=0; auipc=0; halt=0;
         end
         5'b11_011: begin  
            Branch = 0;  
            MemRead = 0;
            MemtoReg = 0'bx;    
            ALUOp = 2'b00;   
            MemWrite = 0;
            ALUSrc = 0;      
            RegWrite = 1; 
            jal=1; jalr=0; auipc=0; halt=0;
        end
        5'b11_011: begin  
            Branch = 0;  
            MemRead = 0;
            MemtoReg = 0'bx;    
            ALUOp = 2'b00;   
            MemWrite = 0;
            ALUSrc = 1;      
            RegWrite = 1;
            jal=0; jalr=1; auipc=0; halt=0;
        end        
        5'b11_001: begin  
            Branch = 0;  
            MemRead = 0;
            MemtoReg = 0'bx;    
            ALUOp = 2'b00;   
            MemWrite = 0;
            ALUSrc = 1;      
            RegWrite = 1;
            jal=0; jalr=1; auipc=0; halt=0;
        end  
        5'b11_100: begin 
            MemRead=0; 
            MemtoReg=0; 
            MemWrite=0; 
            ALUSrc=0; 
            RegWrite=0;
            Branch = 0;
            jal=0;
            jalr=0;
            auipc=0; 
            halt=1;
            ALUOp = 2'b00;
        end
        5'b000_11: begin 
            MemRead = 0;
            MemtoReg = 0;
            MemWrite = 0;
            ALUSrc = 0;
            RegWrite = 0;
            Branch = 0;
            jal = 0; 
            jalr = 0;
            auipc = 0;
            halt = 1;
            ALUOp = 2'b00;
         end
    endcase
end

endmodule
