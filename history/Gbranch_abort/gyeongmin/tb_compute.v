// ========================================
// TESTBENCH
// ========================================
`timescale 1ns/1ps

module tb_compute;

    reg CLK;
    reg WR_EN, RD_EN, selectAB;
    reg [7:0] keyIn;
    reg START_COMP;
    wire [15:0] dot_result;
    wire comp_done;
    wire doneA, doneB;

    ControlModule uut(
        .CLK(CLK),
        .WR_EN(WR_EN),
        .RD_EN(RD_EN),
        .selectAB(selectAB),
        .keyIn(keyIn),
        .START_COMP(START_COMP),
        .dot_result(dot_result),
        .comp_done(comp_done),
        .doneA(doneA),
        .doneB(doneB)
    );

    // Clock generation
    initial CLK = 0;
    always #5 CLK = ~CLK;

    integer i;

    initial begin
        $display("========================================");
        $display("DOT PRODUCT COMPUTATION TEST");
        $display("========================================");
        
        WR_EN = 0;
        RD_EN = 0;
        selectAB = 0;
        keyIn = 0;
        START_COMP = 0;
        #20;

        // Write Vector A: [1, 2, 3, 4, 5, 6, 7, 8]
        $display("\n[%0t] Writing Vector A...", $time);
        selectAB = 0;
        WR_EN = 1;
        for (i = 1; i <= 8; i = i + 1) begin
            keyIn = i;
            #10;
        end
        WR_EN = 0;
        #10;
        uut.inputMod.printA();

        // Write Vector B: [8 7 6 5 4 3 2 1]
        $display("\n[%0t] Writing Vector B...", $time);
        selectAB = 1;
        WR_EN = 1;
        for (i = 1; i <= 8; i = i + 1) begin
            keyIn = 9-i;
            #10;
        end
        WR_EN = 0;
        #10;
        uut.inputMod.printB();

        // Enable read and start computation
        $display("\n[%0t] Starting dot product computation...", $time);
        RD_EN = 1;
        START_COMP = 1;
        #10;
        START_COMP = 0;

        // Wait for computation
        wait(comp_done);
        #20;
        RD_EN = 0;
        
        $display("\n========================================");
        $display("RESULT: Dot Product = %0d", dot_result);
        $display("Expected: 1*2 + 2*2 + 3*2 + 4*2 + 5*2 + 6*2 + 7*2 + 8*2 = 72");
        if (dot_result == 120)
            $display("PASS");
        else
            $display("FAIL");
        $display("========================================");
        
        #50;
        $finish;
    end

    initial begin
        $monitor("[%0t] WR=%b SEL=%b keyIn=%3d | RD=%b COMP=%b DONE=%b | dataA=%3d dataB=%3d | RESULT=%5d", 
                 $time, WR_EN, selectAB, keyIn, RD_EN, START_COMP, comp_done, 
                 uut.readDataA, uut.readDataB, dot_result);
    end

endmodule