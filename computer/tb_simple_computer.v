`timescale 10ns / 1ps
module tb_simple_computer;
    reg CLK;
    wire [4-1:0] DATA_OUT;
    wire [4-1:0] Reg [0:4-1];
    wire [13-1:0] CW;
    wire [4-1:0] Adata, Bdata, Constant, DATA_IN, PC;
    
    SimpleComputer SC1(
        .CLK(CLK),
        .DATA_OUT(DATA_OUT),
        .Reg0(Reg[0]), .Reg1(Reg[1]), .Reg2(Reg[2]), .Reg3(Reg[3]),
        .CW(CW), .Adata(Adata), .Bdata(Bdata), .Constant(Constant), .DATA_IN(DATA_IN), .PC(PC)
    ); 
    
    initial begin
        CLK <= 1'b0;
    end
    always #10 CLK <= ~CLK;
endmodule
