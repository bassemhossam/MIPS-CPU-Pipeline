module PipelineCPU(clk);
input clk;
reg [31:0] pc=0; //assume
wire [3:0] OpCode;
integer counter=0;
wire [31:0] Result;
//hazard
wire [4:0] IDEXrs, IDEXrt, EXMEMrd, MEMWBrd, MEMWBrt; 
wire [5:0] EXMEMop, MEMWBop, IDEXop;
wire [31:0] Ain, Bin;
wire takebranch, stall, forwardAfromMEM, forwardAfromALUinWB,forwardBfromMEM, forwardBfromALUinWB,
forwardAfromLWinWB, forwardBfromLWinWB;
//hazard


wire [4:0] writeregister;//address of register to write 
wire[31:0] writedata;
reg[31:0]readdata1,readdata2;

wire RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;// control unit outputs
wire [1:0] ALUOp;

wire[31:0] mux3in; //output from Data memory
wire[31:0] mux2out;
wire[31:0] branchequal;
//1st pipeline reg --> 32 bits represent the instruction, the other represent the PC
reg [31:0] IFIDIR=32'b000000_00000_00000_11100_00000000000;

//2nd pipeline reg
reg [31:0] IDEXSE, IDEXIR=32'b000000_00000_00000_00000_00000000000; 
reg IDEXRegDst, IDEXBranch, IDEXMemRead, IDEXMemtoReg, IDEXMemWrite, IDEXALUSrc, IDEXRegWrite;
reg [1:0] IDEXALUOp;
//2nd pipeline reg


//3rd pipeline reg
reg [31:0] EXMEMIR=32'b0000000_0000000_0000000_0000000, EXMEMB, EXMEM_ALURESULT;
reg EXMEMRegWrite,EXMEMMemtoReg,EXMEMBranch,EXMEMMemRead,EXMEMMemWrite;
reg [4:0]EXMEMMUX1OUT;
//3rd pipeline reg

wire stall_1,stall_2;
//4th pipeline reg
reg [31:0] MEMWB_ReadData, MEMWBIR=32'b0000000_0000000_0000000_0000000, MEMWB_ALURESULT,  MEMWBReadDataToMux3;
reg[4:0] MEMWBMUX1OUT;
reg MEMWBRegWrite, MEMWBMemtoReg;
//4th pipeline reg
reg[4:0]MEMWBwriteregister;
reg stage5regwrite;
reg [31:0] IMemory[0:1023];
reg[31:0] regfile[0:31];
initial 
begin
$readmemb("input.txt",IMemory);
end
/*1st stage*/
assign IDEXrs = IDEXIR[25:21]; 
assign IDEXrt = IDEXIR[20:16]; 
//assign EXMEMrd = EXMEMIR[15:11];
assign MEMWBrd = MEMWBMUX1OUT; 
assign EXMEMop = EXMEMIR[31:26];
//assign MEMWBrt = MEMWBIR[25:20];
assign MEMWBop = MEMWBIR[31:26]; 
assign IDEXop = IDEXIR[31:26];
// The forward to input A from the MEM stage for an ALU operation
assign forwardAfromMEM = (IDEXrs == EXMEMMUX1OUT) & (IDEXrs!=0) & ((EXMEMop==6'b0)||(EXMEMop==6'b001000)||(EXMEMop==6'b101011)); // yes, forward
// The forward to input B from the MEM stage for an ALU operation
assign forwardBfromMEM = (IDEXrt== EXMEMMUX1OUT)&(IDEXrt!=0) & ((EXMEMop==6'b0)||(EXMEMop==6'b001000)||(EXMEMop==6'b101011));// yes, forward
// The forward to input A from the WB stage for an ALU operation
assign forwardAfromALUinWB = (IDEXrs == MEMWBrd) & (IDEXrs!=0) & ((MEMWBop==6'b0)||(MEMWBop==6'b001000)||(MEMWBop==6'b101011));
// The forward to input B from the WB stage for an ALU operation
assign forwardBfromALUinWB = (IDEXrt==MEMWBrd) & (IDEXrt!=0) & ((MEMWBop==6'b0)||(MEMWBop==6'b001000)||(MEMWBop==6'b101011));
// The forward to input A from the WB stage for an LW operation
assign forwardAfromLWinWB = (IDEXrs ==MEMWBrd) & (IDEXrs!=0) & (MEMWBop==6'b100011);
// The forward to input B from the WB stage for an LW operation
assign forwardBfromLWinWB = (IDEXrt==MEMWBrd) & (IDEXrt!=0) & (MEMWBop==6'b100011);

// The A input to the ALU is forwarded from MEM if there is a forward there,
// Otherwise from WB if there is a forward there, and otherwise comes from the IDEX register
assign Ain = forwardAfromMEM? EXMEM_ALURESULT :
forwardAfromALUinWB ? MEMWB_ALURESULT :
forwardAfromLWinWB ? MEMWB_ReadData : readdata1;
// The B input to the ALU is forwarded from MEM if there is a forward there,
// Otherwise from WB if there is a forward there, and otherwise comes from the IDEX register
assign Bin = forwardBfromMEM? EXMEM_ALURESULT :
forwardBfromALUinWB ? MEMWB_ALURESULT :
forwardBfromLWinWB ? MEMWB_ReadData : readdata2;
// The signal for detecting a stall based on the use of a result from LW
assign stall = (EXMEMIR[31:26]==6'b100011) && // source instruction is a load
((((IDEXop==6'b100011)|(IDEXop==6'b101011)) && (IDEXrs==EXMEMIR[20:16])) | // stall for address calc
((IDEXop==6'b0) && ((IDEXrs==EXMEMIR[20:16])|(IDEXrt==EXMEMIR[20:16])))); // ALU use

// Signal for a taken branch: instruction is BEQ and registers are equal
assign branchequal=stall_1?0:
stall_2?0:
(((IFIDIR[31:26]==6'b000100)&&(MEMWBIR[31:26]==6'b100011))&&((regfile[IFIDIR[25:21]]==MEMWB_ReadData)&&(regfile[IFIDIR[20:16]]==MEMWB_ReadData)))?1:
(((stall_1==0)||(stall_2==0))&&(MEMWBIR[31:26]!=6'b100011))?regfile[IFIDIR[25:21]]== regfile[IFIDIR[20:16]]:0;
assign takebranch = (IFIDIR[31:26]==6'b000100) &&branchequal ;
assign stall_1=(IFIDIR[31:26]==6'b000100)&&(IDEXIR[31:26]==6'b100011)&&((IFIDIR[25:21]==IDEXrt)||(IFIDIR[20:16]==IDEXrt));///beq in IFIDIR and LW in IDEXIR
assign stall_2=(IFIDIR[31:26]==6'b000100)&&(EXMEMIR[31:26]==6'b100011)&&((IFIDIR[25:21]==EXMEMIR[20:16])||(IFIDIR[20:16]==EXMEMIR[20:16]));//beq is still in IFIDIR and LW in EXMEMIR
/*2nd stage*/
//regfile R1(IFIDIR[25:221], IFIDIR[20:16], clk, MEMWBMUX1OUT, writedata,readdata1 , readdata2,MEMWBRegWrite );
ControlUnit ControlUnit(clk, IFIDIR[31:26], RegDst, Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite);

/*3rd stage*/
MUX_2_to_1 M1(IDEXIR[20:16], IDEXIR[15:11], IDEXRegDst, writeregister);
MUX_2_to_1 M2(Bin, IDEXSE, IDEXALUSrc, mux2out);
MUX_2_to_1 M3(MEMWB_ALURESULT,MEMWB_ReadData,MEMWBMemtoReg,writedata);
ALUcontrol ALUcontrol(IDEXIR[5:0], IDEXALUOp, OpCode);
ALU A1(Ain, mux2out, OpCode, Result, IDEXIR[10:6]);

/*4th stage*/
DataMem Datamemory(clk,EXMEM_ALURESULT,EXMEMB,EXMEMMemWrite,EXMEMMemRead,mux3in);

/*5th stage*/
//MUX_2_to_1 M3(MEMWB_ALURESULT,MEMWBReadDataToMux3, MEMWBMemtoReg, writedata);

always@(negedge clk)
begin
if (MEMWBRegWrite) //selecting whether to read or write using if else and "writeenable" 
begin
regfile[MEMWBMUX1OUT]<=writedata;  //storing data given into the register file (memory array) and selecting the register number using the "writereg" which contains the address to write in 
end
end

always@(posedge clk) 
begin
	regfile[0]<=0;
if ((!stall)&&(!stall_1)&&(!stall_2)) 
begin // the first three pipeline stages stall if there is a load hazard
 if (!takebranch)
	begin  // first instruction in the pipeline is being fetched normally
	if(counter!=0)
	begin
	pc <= pc + 4;
	IFIDIR<=IMemory[pc>>2];
	end
	counter=counter+1;
	
	end 
 else if(takebranch==1)
	begin // a taken branch is in ID; instruction in IF is wrong; insert a no-op and reset the pc
	IFIDIR <= 32'b000000_00000_00000_11100_00000000000;
	pc <= pc +({{16{IFIDIR[15]}}, IFIDIR[15:0]}<<2);
	end
readdata1<=regfile[IFIDIR[25:21]];
readdata2<=regfile[IFIDIR[20:16]];
IDEXIR<=IFIDIR;
EXMEMB<=readdata2;
EXMEMIR<=IDEXIR;
IDEXSE<={{16{IFIDIR[15]}} /*sign extend*/, IFIDIR[15:0] /*16 bit address*/}; //sign extend
IDEXRegDst<=RegDst;
IDEXBranch<=Branch;
IDEXMemRead<=MemRead;
IDEXMemtoReg<=MemtoReg;
IDEXMemWrite<=MemWrite;
IDEXALUSrc<=ALUSrc;
IDEXRegWrite<=RegWrite;
IDEXALUOp<=ALUOp;

end

else if(stall)
EXMEMIR <=32'b000000_00000_00000_11100_00000000000; //Freeze first three stages of pipeline; inject a nop into the EX output
else if(stall_1)
begin
IDEXIR<=32'b000000_00000_00000_11100_00000000000;
EXMEMIR<=IDEXIR;
end
else if(stall_2)
begin
EXMEMIR <=32'b000000_00000_00000_11100_00000000000;
end
/*control signals*/
EXMEMRegWrite<=IDEXRegWrite;
EXMEMMemRead<=IDEXMemRead;
EXMEMMemWrite<=IDEXMemWrite;
EXMEMMemtoReg<=IDEXMemtoReg;
EXMEMBranch<=IDEXBranch;


MEMWBMemtoReg<=EXMEMMemtoReg;
MEMWBRegWrite<=EXMEMRegWrite;
/*control signals*/

EXMEM_ALURESULT<=Result;

EXMEMMUX1OUT<=writeregister;

MEMWBIR<=EXMEMIR;
MEMWB_ReadData<=mux3in;
MEMWB_ALURESULT<=EXMEM_ALURESULT;
MEMWBMUX1OUT<=EXMEMMUX1OUT;


/*if(MEMWBMemtoReg==1)
begin
writedata<=MEMWB_ReadData;
end
if(MEMWBMemtoReg==0)
begin
writedata<=MEMWB_ALURESULT;
end*/
//MEMWBwriteregister<=MEMWBMUX1OUT;
//stage5regwrite<=MEMWBRegWrite;

end

endmodule
