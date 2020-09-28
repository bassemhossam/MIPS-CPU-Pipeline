module ALUcontrol(Instruction, ALUOp, OpCode);

input wire [5:0] Instruction; //The part of the instruction where the function of the R-format exists
input wire [1:0] ALUOp; //coming from the Control unit
output wire [3:0] OpCode; //4 bits input (wire) to the ALU 
/*Note for the output OpCode if you wish to add addi for example,
 it'll have to be 5 bits instead of 5*/

//add ---> loads and stores (lw & sw)
//because the add opcode is 0000
//sub ---> beq
//funct ---> R-format

assign OpCode= (ALUOp==2'b00)?4'b0010: 
(ALUOp==2'b01)?4'b0110:
(ALUOp==2'b10)&&(Instruction==6'b100000)?4'b0010: 
(ALUOp==2'b10)&&(Instruction==6'b100010)?4'b0110:
(ALUOp==2'b10)&&(Instruction==6'b100100)?4'b0000:
(ALUOp==2'b10)&&(Instruction==6'b100101)?4'b0001:
(ALUOp==2'b10)&&(Instruction==6'b101010)?4'b0111:
(ALUOp==2'b10)&&(Instruction==6'd8)?4'd3: //jr
(ALUOp==2'b10)&&(Instruction==6'd0)?4'd4: //sll
(ALUOp==2'b10)&&(Instruction==6'd2)?4'd5: //srl
4'b00; //to be edited


endmodule 