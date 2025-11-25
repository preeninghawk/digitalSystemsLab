module MEM16x8(
    input CLK, WR,
    input [3:0] ADDR,
    input [7:0] DATA_IN,
    output reg [7:0] DATA_OUT
);
reg[7:0] mem[15:0];
always @ (posedge CLK) begin
    if (WR) begin
        mem[ADDR]<=DATA_IN;
    end else begin
        DATA_OUT<=mem[ADDR];
        end
    end

endmodule