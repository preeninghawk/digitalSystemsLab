`timescale 1ns / 1ps


module ControlModule(
    input CLK,
    input WR_EN,
    input RD_EN,
    input selectAB,
    input [7:0] keyIn,
    input START_COMP,
    output [15:0] dot_result,
    output comp_done,
    output doneA,
    output doneB
);

    wire [7:0] readDataA;
    wire [7:0] readDataB;
    
    // Single InputModule instance handles both vectors
    InputModule inputMod(
        .CLK(CLK),
        .WR_EN(WR_EN),
        .RD_EN(RD_EN),
        .selectAB(selectAB),
        .keyIn(keyIn),
        .readDataA(readDataA),
        .readDataB(readDataB),
        .doneA(doneA),
        .doneB(doneB)
    );
    
    // ComputeModule
    ComputeModule compute(
        .CLK(CLK),
        .START(START_COMP),
        .dataA(readDataA),
        .dataB(readDataB),
        .result(dot_result),
        .DONE(comp_done)
    );

endmodule
