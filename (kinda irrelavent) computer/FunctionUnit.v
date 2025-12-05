module FunctionUnit(
    input  [4-1:0] Adata, Bdata,
    input  [4-1:0] FS,
    output [4-1:0] Fout
    );
    
    wire [4-1:0] Lout, Aout;
    LogicCircuit  U1(
        .Adata(Adata), .Bdata(Bdata), .Sel(FS[2:1]),
        .Gout(Lout)
    );
    ArithmeticCircuit U2(
        .Adata(Adata), .Bdata(Bdata), .Sel(FS[2:1]), .Cin(FS[0]),
        .Gout(Aout)
    );
    Mux_2to1 mux(.D1(Lout), .D0(Aout), .Sel(FS[3]), .OUT(Fout));
endmodule 