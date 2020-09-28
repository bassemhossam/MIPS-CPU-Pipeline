module ControlUnit (clk,OpCode, RegDst, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite);

input wire [5:0] OpCode;
input clk;
output wire RegDst;
output wire Branch;
output wire MemRead;
output wire MemtoReg;
output wire [1:0] ALUOp;
output wire MemWrite;
output wire ALUSrc;
output wire RegWrite;

assign RegDst= (OpCode==6'b000000)? 1'b1: //R instruction
               (OpCode==6'b100011)? 1'b0: //lw intruction
               (OpCode==6'b101011)? 1'b0: //sw instruction
               (OpCode==6'b000100)? 1'b0: //beq instruction
               (OpCode==6'b001000)? 1'b0: //addi instruction
               1'b0;
assign Branch= (OpCode==6'b000000)? 1'b0: //R instruction
               (OpCode==6'b100011)? 1'b0: //lw intruction
               (OpCode==6'b101011)? 1'b0: //sw instruction
               (OpCode==6'b000100)? 1'b1: //beq instruction
               (OpCode==6'b001000)? 1'b0: //addi instruction
               1'b0;
assign MemRead= (OpCode==6'b000000)? 1'b0: //R instruction
               (OpCode==6'b100011)? 1'b1: //lw intruction
               (OpCode==6'b101011)? 1'b0: //sw instruction
               (OpCode==6'b000100)? 1'b0: //beq instruction
               (OpCode==6'b001000)? 1'b0: //addi instruction
               1'b0;
assign MemtoReg= (OpCode==6'b000000)? 1'b0: //R instruction
               (OpCode==6'b100011)? 1'b1: //lw intruction
               (OpCode==6'b101011)? 1'b0: //sw instruction
               (OpCode==6'b000100)? 1'b0: //beq instruction
               (OpCode==6'b001000)? 1'b0: //addi instruction
               1'b0;
assign ALUOp= (OpCode==6'b000000)? 2'b10: //R instruction
               (OpCode==6'b100011)? 2'b00: //lw intruction
               (OpCode==6'b101011)? 2'b00: //sw instruction
               (OpCode==6'b000100)? 2'b01: //beq instruction
               (OpCode==6'b001000)? 2'b00: //addi instruction
               2'b00;
assign MemWrite= (OpCode==6'b000000)? 1'b0: //R instruction
               (OpCode==6'b100011)? 1'b0: //lw intruction
               (OpCode==6'b101011)? 1'b1: //sw instruction
               (OpCode==6'b000100)? 1'b0: //beq instruction
               (OpCode==6'b001000)? 1'b0: //addi instruction
               1'b0;
assign ALUSrc= (OpCode==6'b000000)? 1'b0: //R instruction
               (OpCode==6'b100011)? 1'b1: //lw intruction
               (OpCode==6'b101011)? 1'b1: //sw instruction
               (OpCode==6'b000100)? 1'b0: //beq instruction
               (OpCode==6'b001000)? 1'b1: //addi instruction
               1'b0;
assign RegWrite= (OpCode==6'b000000)? 1'b1: //R instruction
               (OpCode==6'b100011)? 1'b1: //lw intruction
               (OpCode==6'b101011)? 1'b0: //sw instruction
               (OpCode==6'b000100)? 1'b0: //beq instruction
               (OpCode==6'b001000)? 1'b1: //addi instruction
               1'b0;

endmodule
