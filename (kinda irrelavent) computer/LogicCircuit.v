module LogicCircuit(
    input [4-1:0] Adata, Bdata,
    input [2-1:0] Sel,
    output reg [4-1:0] Gout
    );
    always @ (*) begin
        case (Sel)
            // Design your code here
            2'b00: Gout=Adata&Bdata;
            2'b01: Gout=Adata|Bdata;
            2'b10: Gout=Adata^Bdata;
            2'b11: Gout=~Adata;
        endcase 
    end
endmodule
