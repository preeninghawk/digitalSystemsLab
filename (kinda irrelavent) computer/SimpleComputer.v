module SimpleComputer(
    input CLK,
    output [4-1:0] DATA_OUT,
    output [4-1:0] Reg0, Reg1, Reg2, Reg3,
    output [13-1:0] CW, // Control Word
    output [4-1:0] Adata, Bdata, Constant, DATA_IN, PC
    );
    
    wire [4-1:0] FS;
    wire [2-1:0] DA, AA, BA;
    wire MB, MD, RW, PL, MW;
    
    assign CW[0] = RW;
    assign CW[1] = MD;
    assign CW[5:2] = FS;
    assign CW[6] = MB;
    assign CW[8:7] = BA;
    assign CW[10:9] = AA;
    assign CW[12:11] = DA;
    
    ControlUnit CU1(
        .CLK(CLK), .ADDR(Adata),
        .DA(DA), .AA(AA), .BA(BA), .MB(MB), .MD(MD), .RW(RW), .MW(MW), .FS(FS), .Constant(Constant), .PC(PC)
    );
    Datapatch DP1(
        .CLK(CLK), .CW(CW), .CN(Constant), .DATA_IN(DATA_IN),
        .Reg0(Reg0), .Reg1(Reg1), .Reg2(Reg2), .Reg3(Reg3), .ADDR_OUT(Adata), .DATA_OUT(Bdata)
    );
    DataMemory DM1(
        .CLK(CLK), .WR(MW), .ADDR(Adata), .DATA_IN(Bdata),
        .DATA_OUT(DATA_IN)
    );
   assign DATA_OUT = DATA_IN; 
endmodule
