module Mux_4to1(
    input [4-1:0] D3, D2, D1, D0,
    input [2-1:0] Sel,
    output reg [4-1:0] OUT
    );
    always @ (*) begin
        case (Sel)
            // Design your code here
            2'b11:OUT=D3;
            2'b10:OUT=D2;
            2'b01:OUT=D1;
            2'b00:OUT=D0;
        endcase 
    end
endmodule
