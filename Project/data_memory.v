`timescale 1ns / 1ps

module DataMem(
    input clk,
    input MemRead,
    input MemWrite,
    input [5:0] addr,
    input [2:0] func3,   // Assuming we are still using a 6-bit address space for simplicity
    input [31:0] data_in,
    output reg [31:0] data_out  // 00 = Word, 01 = Halfword, 10 = Byte , 11 = 
); //addr was og [5:0]

    reg [7:0] mem [0:255]; // Memory is byte addressable, each entry is 1 byte , it was 64 bits originally

    initial begin   
        mem[0] = 8'd20;
        mem[1] = 8'd9;
        mem[2] = 8'd4;
        mem[3] = 8'd0;
        //mem[4] = 8'd0;
        //mem[5] = 8'd0;
        
    end

    // Read operation
    always @(*) begin
        if (MemRead) begin
            case(func3)
                3'b010: // Word load (4 bytes)
                    data_out = {mem[addr+3], mem[addr+2],mem[addr+1], mem[addr]}; // LW
                3'b001: // Halfword load (2 bytes)
                    data_out = {{16{mem[addr+1][7]}}, mem[addr+1], mem[addr]}; // LH
                3'b000: // Byte load (1 byte)
                    data_out = {{24{mem[addr][7]}}, mem[addr]}; // LB
                3'b100: //LBU
                    data_out = {24'b0, mem[addr]}; // LBU
                3'b101: //LHWU
                    data_out = {16'b0, mem[addr+1], mem[addr]};
                default:
                    ; 
                    //data_out = 32'b0;
                endcase
            end
       else
                data_out = data_out;
    end

    // Write operation
    always @(posedge clk) begin  
        if (MemWrite) begin
            case(func3)
                3'b010: // SW
                    {mem[addr+3], mem[addr+2],mem[addr+1], mem[addr]} = data_in; 
                3'b001: // SH
                    {mem[addr+1], mem[addr]} = data_in[15:0]; 
                3'b000: // SB
                    mem[addr] = data_in[7:0]; 
                default:
                    ;
            endcase
        end
    end

endmodule

