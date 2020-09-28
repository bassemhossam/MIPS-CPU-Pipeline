module regfile(readreg1, readreg2, clk, writereg, writedata, readdata1, readdata2, writeenable); 

input [31:0] writedata;	// data to be stored in the register file
input [4:0] readreg1,readreg2,writereg;	//"readreg1"and"readreg2" are the addresses of the reg to read from ,write reg is the address of reg to write in 
input writeenable,clk;	
output reg[31:0] readdata1,readdata2;
reg [31:0] reg1[0:31];	// the register file storage as a 2d memory array consists from 32 register with each register 32 bits wide
always@(negedge clk)
begin
reg1[0]<=0;
if (writeenable) //selecting whether to read or write using if else and "writeenable" 
begin
reg1[writereg]<=writedata;  //storing data given into the register file (memory array) and selecting the register number using the "writereg" which contains the address to write in 
end
end
always@(posedge clk)
begin
readdata1<=reg1[readreg1];  
readdata2<=reg1[readreg2];
end

endmodule

