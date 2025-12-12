
// =====================================
// 16 x 8-bit Memory (Synchronous Write)
// =====================================
// =====================================
// 16 x 8-bit Memory (Synchronous Write, Asynchronous Read)
// =====================================

module MEM16x8(
    input        CLK,
    input        WR,
    input  [3:0] ADDR,
    input  [7:0] DATA_IN,
    output [7:0] DATA_OUT
);

    reg [7:0] mem [15:0];

    // Synchronous write
    always @(posedge CLK) begin
        if (WR) begin
            mem[ADDR] <= DATA_IN;
        end
    end
    
    // Asynchronous read (combinational)
    assign DATA_OUT = mem[ADDR];

endmodule