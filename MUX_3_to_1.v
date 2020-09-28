module MUX_3_to_1(In1,In2,In3,out,mux_ctrl);

input [31:0] In1;
input [31:0]In2;
input [31:0]In3; 
input [1:0] mux_ctrl; 
output reg[31:0] out;  

always@(In1 or In2 or mux_ctrl) 

begin
//
if(mux_ctrl==0)
begin
out<=In1;
end

else if(mux_ctrl==1)
begin
out<=In2;
end

else if(mux_ctrl==2)
begin
out<=In3;
end

else
begin
out=32'bx;
end

end
endmodule





