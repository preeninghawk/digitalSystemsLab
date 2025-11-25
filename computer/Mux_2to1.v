module Mux_2to1(
    input [4-1:0] D1, D0,
    input Sel,
    output reg [4-1:0] OUT
    );
    always @ (*) begin
        case (Sel)
            // Design your code here
            1'b1:OUT=D1;
            1'b0:OUT=D0;
        endcase  
    end
endmodule
