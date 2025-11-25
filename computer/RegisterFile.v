module RegisterFile(
    input CLK, WR,
    input [4-1:0] Ddata,
    input [2-1:0] Daddr, Aaddr, Baddr,
    output [4-1:0] Adata, Bdata,
    output reg [4-1:0] Reg0, Reg1, Reg2, Reg3
    ); 
    wire [4-1:0] deco;
    Decoder_2to4 dec1( .DATA_IN(Daddr), .DATA_OUT(deco) );
    Mux_4to1 mux1(
        .D3(Reg3), .D2(Reg2), .D1(Reg1), .D0(Reg0),
        .Sel(Aaddr),
        .OUT(Adata)
    );
    Mux_4to1 mux2(
        .D3(Reg3), .D2(Reg2), .D1(Reg1), .D0(Reg0),
        .Sel(Baddr),
        .OUT(Bdata)
    );
    
    initial begin // ÎØ∏Î¶¨ ?ç∞?ù¥?Ñ∞Î•? ???û•.
        Reg0 <= 4'b0000;
        Reg1 <= 4'b0000;
        Reg2 <= 4'b0000;
        Reg3 <= 4'b0000;
    end
    
    always @ (posedge CLK) begin
        if (WR) begin
            case (deco)
                // Design your code here
                4'b0001:Reg0<=Ddata;
                4'b0010:Reg1<=Ddata;
                4'b0100:Reg2<=Ddata;
                4'b1000:Reg3<=Ddata;
                
            endcase
        end
    end
endmodule
