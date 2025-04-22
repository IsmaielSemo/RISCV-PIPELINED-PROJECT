`timescale 1ns / 1ps



module ControlUnit ( 
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
        5'b01_100: begin  //R type
            Branch = 0;
            MemRead = 0;
            MemtoReg = 0;
            ALUOp = 2'b10;   
            MemWrite = 0;
            ALUSrc = 0;
            RegWrite = 1;    
            jal=0; jalr=0; auipc=0; halt=0;
        end

        5'b00_000: begin  //Load
            Branch = 0;
            MemRead = 1;
            MemtoReg = 1;    
            ALUOp = 2'b00;   
            MemWrite = 0;
            ALUSrc = 1;     
            RegWrite = 1;    
            jal=0; jalr=0; auipc=0; halt=0;
        end

        5'b01_000: begin  // Store
            Branch = 0;
            MemRead = 0;
            MemtoReg = 1'bx;   
            ALUOp = 2'b00;  
            MemWrite = 1;    
            ALUSrc = 1;     
            RegWrite = 0;
            jal=0; jalr=0; auipc=0; halt=0; 
               
        end

        5'b11_000: begin  //Branch
            Branch = 1;  
            MemRead = 0;
            MemtoReg = 1'bx;    
            ALUOp = 2'b01;   
            MemWrite = 0;
            ALUSrc = 0;      
            RegWrite = 0; 
            jal=0; jalr=0; auipc=0; halt=0;  
        end
        5'b00_101: begin  //AUIPC
            Branch = 1;
            MemRead = 0;
            MemtoReg = 0'bx;    
            ALUOp = 2'b00;   
            MemWrite = 0; 
            ALUSrc = 0;      
            RegWrite = 1;
             jal=0; jalr=0; auipc=1; halt=0;   
     
        end
        5'b01_101: begin  //LUI
            Branch = 0;  
            MemRead = 0;
            MemtoReg =0'bx;    
            ALUOp = 2'b11;   
            MemWrite = 0;
            ALUSrc = 1;      
            RegWrite = 1;  
            jal=0; jalr=0; auipc=0; halt=0;
         end
         5'b11_011: begin  //JAL
            Branch = 0;  
            MemRead = 0;
            MemtoReg = 0'bx;    
            ALUOp = 2'b00;   
            MemWrite = 0;
            ALUSrc = 0;      
            RegWrite = 1; 
            jal=1; jalr=0; auipc=0; halt=0;
        end
        5'b11_001: begin  //JALR
            Branch = 0;  
            MemRead = 0;
            MemtoReg = 0'bx;    
            ALUOp = 2'b00;   
            MemWrite = 0;
            ALUSrc = 1;      
            RegWrite = 1;
            jal=0; jalr=1; auipc=0; halt=0;
        end  
        5'b11_100: begin //ECALL and EBREAK
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
        5'b00_011: begin //FENCE and FENCE.TSO
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
        5'b00_100: begin //I type
            MemRead = 0;
            MemtoReg = 0;
            MemWrite = 0;
            ALUSrc = 1;
            RegWrite = 1;
            Branch = 0;
            jal = 0; 
            jalr = 0;
            auipc = 0;
            halt = 0;
            ALUOp = 2'b11;
        end
    endcase
end

endmodule
