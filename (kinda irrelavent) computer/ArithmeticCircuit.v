module ArithmeticCircuit(
    input [4-1:0] Adata, Bdata,
    input [2-1:0] Sel,
    input Cin,
    output reg [4-1:0] Gout
    );
    always @ (*) begin
        case (Sel)
            // Design your code here
            2'b00: begin
            if (Cin==1'b0) begin
                Gout=Adata;
            end else begin
                Gout=Adata+1;
            end
            end
            2'b01: begin
            if (Cin==1'b0) begin
                Gout=Adata+Bdata;
            end else begin
                Gout=Adata+Bdata+1;
                end
                end
            2'b10: begin
            if (Cin==1'b0) begin
                Gout=Adata+~Bdata;
            end else begin
                Gout=Adata+~Bdata+1;
                end
                end
            2'b11: begin
            if (Cin==1'b0) begin
               Gout=Adata-1;
            end else begin
               Gout=Adata;
               end
               end
        endcase
    end
endmodule 
