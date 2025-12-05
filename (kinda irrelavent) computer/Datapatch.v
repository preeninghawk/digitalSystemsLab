module Datapatch(
    input  CLK,
    input  [13-1:0] CW, // Control Word
    input  [4-1:0] CN,  // Constant In
    input  [4-1:0] DATA_IN,
    output [4-1:0] Reg0, Reg1, Reg2, Reg3,
    output [4-1:0] ADDR_OUT,
    output [4-1:0] DATA_OUT
    );
    
    wire [3:0] MuxB, MuxD, Adata, Bdata, Fout;

    assign MuxB = (CW[6])? CN : Bdata;
    assign MuxD = (CW[1])? DATA_IN : Fout;

    RegisterFile RF1(
        .CLK(CLK), .WR(CW[0]),
        .Ddata(MuxD), .Daddr(CW[12:11]), .Aaddr(CW[10:9]), .Baddr(CW[8:7]),
        .Adata(Adata), .Bdata(Bdata),
        .Reg0(Reg0), .Reg1(Reg1), .Reg2(Reg2), .Reg3(Reg3)
    );
    FunctionUnit FU1(
        .Adata(Adata), .Bdata(MuxB), .FS(CW[5:2]),
        .Fout(Fout)
    );
	
    assign ADDR_OUT = Adata;
    assign DATA_OUT = MuxB;
endmodule 
