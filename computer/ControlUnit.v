module ControlUnit(
    input  CLK,
    input  [4-1:0] ADDR,
    output [2-1:0] DA, AA, BA,
    output MB, MD, RW, MW,
    output [4-1:0] FS,
    output [4-1:0] Constant,
    output [4-1:0] PC
    );
    wire [13-1:0] INST;
    wire PL, JB, BC;
    supply0 gnd;
       
    ProgramCounter     PC1(CLK, PL, JB, BC, DA, BA, ADDR, PC);
    InstructionMemory  IM1(CLK, gnd, PC, gnd, INST);
    InstructionDecoder ID1(INST, DA, AA, BA, MB, FS, MD, RW, MW, PL, JB, BC);
    
    assign Constant={1'b0, 1'b0, INST[1], INST[0]};
endmodule
