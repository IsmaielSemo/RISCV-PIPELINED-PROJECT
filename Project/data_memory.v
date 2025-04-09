`timescale 1ns / 1ps

module DataMem(
    input clk,
    input MemRead,
    input MemWrite,
    input [5:0] addr,   // Assuming we are still using a 6-bit address space for simplicity
    input [31:0] data_in,
    output reg [31:0] data_out,
    input [1:0] mem_op  // 00 = Word, 01 = Halfword, 10 = Byte
);

    reg [7:0] mem [0:63]; // Memory is byte addressable, each entry is 1 byte

    initial begin   
        mem[0] = 8'd17;
        mem[1] = 8'd9;
        mem[2] = 8'd25;
    end

    // Read operation
    always @(*) begin
        if (MemRead) begin
            case(mem_op)
                2'b00: // Word load (4 bytes)
                    data_out = {mem[addr], mem[addr+1], mem[addr+2], mem[addr+3]}; // Concatenate 4 bytes
                2'b01: // Halfword load (2 bytes)
                    data_out = {{16{mem[addr+1][7]}}, mem[addr+1], mem[addr]}; // Sign-extend to 32 bits
                2'b10: // Byte load (1 byte)
                    data_out = {{24{mem[addr][7]}}, mem[addr]}; // Sign-extend to 32 bits
                default: 
                    data_out = 32'b0;
            endcase
        end
    end

    // Write operation
    always @(posedge clk) begin  
        if (MemWrite) begin
            case(mem_op)
                2'b00: // Word store (4 bytes)
                    {mem[addr], mem[addr+1], mem[addr+2], mem[addr+3]} <= data_in; 
                2'b01: // Halfword store (2 bytes)
                    {mem[addr+1], mem[addr]} <= data_in[15:0]; 
                2'b10: // Byte store (1 byte)
                    mem[addr] <= data_in[7:0]; 
                default:
                    ;
            endcase
        end
    end

endmodule
