module ProgramCounter (
    input CLK, PL, JB, BC,
    input [2-1:0] LADDR, RADDR,
    input [4-1:0] ADDR,
    output reg [4-1:0] PC
    );
    initial begin
        PC <= 4'b0101;
    end
    
    always @ (posedge CLK) begin
        if (~PL) PC <= PC + 4'b0001;
        else if (JB) PC <= ADDR; // JUMP and Branch
        else if (BC) begin
            if (ADDR < 4'b0000) PC <= PC + {LADDR, RADDR};
            else PC<=PC+4'b0001;
        end
        else if (~BC) begin // Branch on negative
            if (ADDR == 4'b0000) PC <= PC + {LADDR, RADDR};
            else PC<=PC+4'b0001;
        end
    end
endmodule 

