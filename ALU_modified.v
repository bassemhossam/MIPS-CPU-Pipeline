//ALU Operations (4 bits):

/*first project*/
//0000 Add
//0001 Sub	
//0010 And
//0011 OR
//0100 SLL
//0101 SRL
//0110 SRA
//0111 GreaterThan
//1000 LessThan


//0000 and
//0001 or
//0010 add
//0110 sub
//0111 slt
//1100 nor
//3 jr
//4 sll
//5 srl

// ALU inputs --> A(32 bits),B(32 bits),Mode(1 bit), OpCode(4 bits),Shift amount (no specified number of bits, not necessary)

//Mode=1 -->Signed
//Mode=0 -->Unsigned

//ALU outputs --> Result(32 bits) & Overflow (1 bit --> same as a flag ) 

module ALU(A,B,OpCode,Result,Shift_amt);

input wire [31:0] A,B;
//input wire [1:0] Mode;
input wire [3:0] OpCode; //coming from the ALU control unit
input wire [4:0] Shift_amt; //Instruction[10:6]
output wire [31:0] Result;
//output wire [1:0] Overflow;
wire [31:0] B_negated;
reg signed [31:0] A_signed;
reg signed [31:0] B_signed;

/*assign B_negated=-B; //used for overflow in case of subtraction
always@(Mode==1)
begin
A_signed<=A;
B_signed<=B;
end*/

/*inline cdns for all inputs and what they should result*/
assign Result =(OpCode==4'b0010)?(A+B):
//(OpCode==4'b0010)?(A_signed+B_signed):
(OpCode==4'b0110)?(A-B):
//(OpCode==4'b0110)?(A_signed-B_signed):
(OpCode==4'b0000)?(A&B):
(OpCode==4'b0001)?(A|B):
//(OpCode==4'b0001)?(A~|B): //not working

//((OpCode==4'd3))? (): //for jump reg
((OpCode==4'd4))? (B<<Shift_amt): //sll
((OpCode==4'd5))? (B>>Shift_amt): //srl
(OpCode==4'b0111)?((A<B)?32'd1:32'd0): //slt
(32'd0);

//assign zero_flag = (OpCode==4'b0110)&&(A-B==0)? 1:0;


endmodule 