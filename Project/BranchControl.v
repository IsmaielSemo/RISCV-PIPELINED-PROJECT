`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2025 01:02:46 PM
// Design Name: 
// Module Name: BranchControl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////




module BranchControl(input Branch, Zero, Sign, Overflow, Carry, [4:0] opcode, [2:0] function3, output reg Decision);
always@(*) begin
    case(opcode)
        5'b11000:
        if(Branch) begin
            if(function3 == 3'b000)
                Decision = Zero; //BEQ
            else if(function3 == 3'b001)
                Decision = !Zero; //BNE
            else if(function3 == 3'b100)
                Decision = (Sign != Zero); //BLT
            else if(function3 == 3'b101)
                Decision = (Sign == Zero); //BGE
            else if(function3 == 3'b110)
                Decision = !Carry; //BLTU
            else if(function3 == 3'b111)
                Decision = Carry; //BGEU
            else
                Decision = 0;
        end    
        endcase
end

endmodule
