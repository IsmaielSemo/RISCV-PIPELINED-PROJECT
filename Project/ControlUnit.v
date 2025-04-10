`timescale 1ns / 1ps


module ControlUnit ( //Inst was originally from 4:0
    input [4:0] Inst,                  
    output reg MemRead,       
    output reg MemtoReg,      
    output reg [1:0] ALUOp,   
    output reg MemWrite,      
    output reg ALUSrc,        
    output reg RegWrite,
    output reg branch, jal, jalr, auipc, halt       
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
        OPCODE_Arith_R: begin  //originally 5'b01100 R
            Branch = 0;
            MemRead = 0;
            MemtoReg = 0;
            ALUOp = 2'b10;   
            MemWrite = 0;
            ALUSrc = 0;
            RegWrite = 1;    
            jal=0; jalr=0; auipc=0; halt=0;
        end

        OPCODE_Load: begin  //originally 5'b00000 Load
            Branch = 0;
            MemRead = 1;
            MemtoReg = 1;    
            ALUOp = 2'b00;   
            MemWrite = 0;
            ALUSrc = 1;     
            RegWrite = 1;    
            jal=0; jalr=0; auipc=0; halt=0;
        end

        OPCODE_Store: begin  //originally 5'b01000
            Branch = 0;
            MemRead = 0;
            MemtoReg = 1'bx;   
            ALUOp = 2'b00;  
            MemWrite = 1;    
            ALUSrc = 1;     
            RegWrite = 0;
            jal=0; jalr=0; auipc=0; halt=0; 
               
        end

        OPCODE_Branch: begin  //originally 11000
            Branch = 1;  
            MemRead = 0;
            MemtoReg = 1'bx;    
            ALUOp = 2'b01;   
            MemWrite = 0;
            ALUSrc = 0;      
            RegWrite = 0; 
            jal=0; jalr=0; auipc=0; halt=0;  
        end
        OPCODE_AUIPC: begin  
            Branch = 1;  
            MemRead = 0;
            MemtoReg = 0'bx;    
            ALUOp = 2'b00;   
            MemWrite = 0;
            ALUSrc = 0;      
            RegWrite = 1;
            branch=0; jal=0; jalr=0; auipc=1; halt=0;   
        end
        OPCODE_LUI: begin  
            Branch = 0;  
            MemRead = 0;
            MemtoReg =0'bx;    
            ALUOp = 2'b11;   
            MemWrite = 0;
            ALUSrc = 1;      
            RegWrite = 1;  
            jal=0; jalr=0; auipc=0; halt=0;
         end
         OPCODE_JAL: begin  
            Branch = 0;  
            MemRead = 0;
            MemtoReg = 0'bx;    
            ALUOp = 2'b00;   
            MemWrite = 0;
            ALUSrc = 0;      
            RegWrite = 1; 
            jal=1; jalr=0; auipc=0; halt=0;
        end
        OPCODE_JALR: begin  
            Branch = 0;  
            MemRead = 0;
            MemtoReg = 0'bx;    
            ALUOp = 2'b00;   
            MemWrite = 0;
            ALUSrc = 1;      
            RegWrite = 1;
            jal=0; jalr=1; auipc=0; halt=0;
        end        
        OPCODE_JALR: begin  
            Branch = 0;  
            MemRead = 0;
            MemtoReg = 0'bx;    
            ALUOp = 2'b00;   
            MemWrite = 0;
            ALUSrc = 1;      
            RegWrite = 1;
            jal=0; jalr=1; auipc=0; halt=0;
        end  
        OPCODE_SYSTEM: begin 
            MemRead=0; MemtoReg=0; MemWrite=0; ALU_src=0; RegWrite=0;
            //{Branch, jal, jalr, auipc, halt, zero_pc} = inst20 ? 6'b000010 : 6'b000001;
             ALUOp = 2'b00;
            end
         OPCODE_FENCE: begin 
             MemRead=0; MemtoReg=0; MemWrite=0; ALU_src=0; RegWrite=0;
            {Branch, jal, jalr, auipc, halt, zero_pc} = 6'b000001;
             ALUOp = 2'b00;
             end
    endcase
end

endmodule
