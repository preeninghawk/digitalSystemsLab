module DataMemory(
    input           CLK, WR,
    input   [4-1:0] ADDR,
    input   [4-1:0] DATA_IN,
    output  [4-1:0] DATA_OUT
    );
    
    reg [4-1:0] SRAM [16-1:0];
    initial begin // ÎØ∏Î¶¨ ?ç∞?ù¥?Ñ∞Î•? ???û•.
        SRAM[0] = 4'b0010;
        SRAM[1] = 4'b0011;
        SRAM[2] = 4'b0000;
        SRAM[3] = 4'b0000;
    end
    
    always @ (posedge CLK) begin
    if (WR)
        SRAM[ADDR] <= DATA_IN;       
    end
    assign DATA_OUT = SRAM[ADDR];
endmodule
