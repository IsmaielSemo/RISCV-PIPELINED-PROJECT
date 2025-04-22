`timescale 1ns / 1ps



//module ImmGen (output [31:0] gen_out, input [31:0] inst);

//reg [11:0] imm;
//wire sign_bit;
//always @(*)begin
//    if(inst[6:5] == 2'b00) begin //Load instruction
//        if(inst[14:12] == 3'b010)begin  //LW    
//            imm = inst[31:20]; 
//        end     
//        if(inst[14:12] == 3'b000)begin //LB
//           imm = inst[31:20];    
//        end
//        if(inst[14:12] == 3'b001)begin //LH
//           imm = inst[31:20]; 
//        end   
//    end
//    else if(inst[6:5] == 2'b01) begin //SW
//    imm = {inst[31:25], inst[11:7]}; //7+5=12
//    end 
//    else if(inst[5] == 1'b1) begin //BEQ
//    imm = {inst[31], inst[7], inst[30:25],inst[11:8]}; //1+1+6+4=12
//    end
//end

//    assign sign_bit = inst[31];
//    assign gen_out = (sign_bit == 0)? {20'b0, imm}:
//    {20'b11111111111111111111 , imm};
    

//endmodule

module ImmGen (
    output reg  [31:0]  gen_out,
    input  [31:0]  inst   
);

wire [4:0] opcode;
assign opcode = inst[6:2];
always @(*) begin
	case (opcode)
		5'b00_100: begin 	//I type
		  gen_out = { {21{inst[31]}}, inst[30:25], inst[24:21], inst[20] };
		  end
		5'b01_000: begin //Store
		  gen_out = { {21{inst[31]}}, inst[30:25], inst[11:8], inst[7] };
		  end
		5'b01_101: begin //LUI
		  gen_out = { inst[31], inst[30:20], inst[19:12], 12'b0 };
		  end
		5'b00_101: begin //AUIPC
		  gen_out = { inst[31], inst[30:20], inst[19:12], 12'b0 };
		  end
		5'b11_011: begin //JAL
		  gen_out = { {12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0 };
		  end
		 5'b11_001 : begin //JALR
		  gen_out = { {21{inst[31]}}, inst[30:25], inst[24:21], inst[20] };
		  end
		5'b11_000: begin //BRANCH
		  gen_out = { {20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
		  end
		default: 	gen_out = { {21{inst[31]}}, inst[30:25], inst[24:21], inst[20] }; // I type set as default
	endcase 
end

endmodule