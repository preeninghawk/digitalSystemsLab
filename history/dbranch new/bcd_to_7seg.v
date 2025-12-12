module bcd_to_7seg (
    input  [3:0] bcd,
    output reg [7:0] seg   // {a,b,c,d,e,f,g,dp} 
);
    always @(*) begin
        case (bcd)
            4'd0: seg = 8'b11111100; // 0
            4'd1: seg = 8'b01100000; // 1
            4'd2: seg = 8'b11011010; // 2
            4'd3: seg = 8'b11110010; // 3
            4'd4: seg = 8'b01100110; // 4
            4'd5: seg = 8'b10110110; // 5
            4'd6: seg = 8'b10111110; // 6
            4'd7: seg = 8'b11100000; // 7
            4'd8: seg = 8'b11111110; // 8
            4'd9: seg = 8'b11110110; // 9
            default: seg = 8'b00000000; // blank
        endcase
    end
endmodule