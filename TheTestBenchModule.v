module Final_TestBench();
wire myclk;
clk clock(myclk);
PipelineCPU cpu(myclk);
endmodule 