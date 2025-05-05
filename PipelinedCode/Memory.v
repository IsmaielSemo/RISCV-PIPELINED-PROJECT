`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2025 01:11:46 PM
// Design Name: 
// Module Name: Memory
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


module Memory(input [13:0] addr, input [31:0] data_in, input[2:0]func3, input clk, MemRead, MemWrite,output reg [31:0] data_out);
reg [7:0] mem [0:(4*1024-1)]; //This implementation of the memory is different from what's in the project support, but it's just an extended one of our MS2 submission
reg [31:0] temp [0:31]; //for the instructions
initial begin
        $readmemh("C:/Users/ismai/OneDrive/Desktop/TestCases/TestCase1.hex", temp); //create proper folder later
    end
integer i;
initial begin
    for(i=0; i<32; i=i+1)
            begin
                {mem[(i*4)+3], mem[(i*4)+2], mem[(i*4)+1], mem[i*4]} = temp[i];       //instructions copied to temp
            end
     end
initial begin
    {mem[131], mem[130], mem[129], mem[128]}    = 32'd20;    //data at address 0
    {mem[135], mem[134], mem[133], mem[132]}    = 32'd9;    //data at address 1
    {mem[139], mem[138], mem[137], mem[136]}    = 32'd25;   //data at address 2 
end  

always @(*) begin
    if(~clk) begin
        if(MemRead) begin
                case(func3)
                    3'b010: // LW
                        data_out <= {mem[addr[13:7]+3+128], mem[addr[13:7]+2+128],mem[addr[13:7]+1+128], mem[addr[13:7]+128]}; 
                    3'b001: // LH
                        data_out <= {{16{mem[addr[13:7]+1+128][7]}}, mem[addr[13:7]+1+128], mem[addr[13:7]+128]}; 
                    3'b000: // LB
                        data_out <= {{24{mem[addr[13:7]+128][7]}}, mem[addr[13:7]+128]}; 
                    3'b100: //LBU
                        data_out <= {24'b0, mem[addr[13:7]+128]}; 
                    3'b101: //LHWU
                        data_out <= {16'b0, mem[addr[13:7]+1+128], mem[addr[13:7]+128]};
                    default:
                        data_out <= 32'b0;
                    endcase
               end
        end
        else
            data_out <= {mem[addr[6:0]+3], mem[addr[6:0]+2], mem[addr[6:0]+1], mem[addr[6:0]]};
    end

    always @(posedge clk) begin  
        if (MemWrite) begin
            case(func3)
                3'b010: begin // SW 
                    mem[addr[13:7] +128] = data_in[7:0];
                    mem[addr[13:7] +1 +128] = data_in[15:8];
                    mem[addr[13:7] +2 +128] = data_in[23:16];
                    mem[addr[13:7] +3 +128] = data_in[31:24];
                 end
                3'b001 : begin // SH
                    mem[addr[13:7] +128] = data_in[7:0];
                    mem[addr[13:7] +1+128] = data_in[15:8]; 
               end
                3'b000: // SB
                    mem[addr[13:7] +128] = data_in[7:0];
                default:
                    ;
            endcase
        end
    end   
    
endmodule
