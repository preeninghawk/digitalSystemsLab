module Decoder_2to4(
    input [2-1:0] DATA_IN,
    output reg  [4-1:0] DATA_OUT
    );
    always @ (*) begin
        case (DATA_IN)
            // Design your code here
            2'b11:DATA_OUT=4'b1000;
            2'b10:DATA_OUT=4'b0100;
            2'b01:DATA_OUT=4'b0010;
            2'b00:DATA_OUT=4'b0001;
        endcase
    end
endmodule
