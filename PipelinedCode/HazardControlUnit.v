`timescale 1ns / 1ps


module HazardControlUnit(
    input [4:0] IF_ID_RegisterRs1, IF_ID_RegisterRs2, ID_EX_RegisterRd,
    input ID_EX_MemRead, //Ctrl[6]
    output reg stall
);
 
always @(*) begin
    stall = 1'b0;  

    if ( ((IF_ID_RegisterRs1 == ID_EX_RegisterRd) || (IF_ID_RegisterRs2 == ID_EX_RegisterRd)) && (ID_EX_MemRead==1 && ID_EX_RegisterRd != 5'b00000)) begin
        stall = 1'b1;  
    end
end
 
endmodule