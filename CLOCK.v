module clk( myclk);
output reg myclk=1;
always
begin
#1 myclk=~myclk;
end
endmodule
