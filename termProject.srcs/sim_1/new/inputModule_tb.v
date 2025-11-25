`timescale 1ns/1ps

module tb_inputmodule;

    reg CLK;
    reg WR_EN, RD_EN;
    reg selectAB;
    reg [7:0] keyIn;
    wire [7:0] readData;

    // Instantiate module
    InputModule uut(
        .CLK(CLK),
        .WR_EN(WR_EN),
        .RD_EN(RD_EN),
        .selectAB(selectAB),
        .keyIn(keyIn),
        .readData(readData)
    );

    // Clock generation
    always #5 CLK = ~CLK;

    initial begin
        CLK = 0;
        WR_EN = 0;
        RD_EN = 0;
        selectAB = 0;
        keyIn = 0;

        $display("\n===== Writing Vector A =====");
        selectAB = 0; WR_EN = 1;

        keyIn = 3; #10;
        keyIn = 5; #10;
        keyIn = 2; #10;
        keyIn = 9; #10;
        keyIn = 23; #10;
        keyIn = 53; #10;
        keyIn = 22; #10;
        keyIn = 91; #10;

        WR_EN = 0;

        // Dump vector A
        #5 uut.printA();

        $display("\n===== Writing Vector B =====");
        selectAB = 1; WR_EN = 1;

        keyIn = 177; #10;
        keyIn = 44; #10;
        keyIn = 46; #10;
        keyIn = 254; #10;
        keyIn = 1; #10;
        keyIn = 0; #10;
        keyIn = 99; #10;
        keyIn = 100; #10;

        WR_EN = 0;
        #5 uut.printB();

        $display("\n===== Reading Vector A =====");
        RD_EN = 1;
        repeat (8) begin
            #10 $display("Read: %d", readData);
        end
        RD_EN = 0;
        
        selectAB=1; WR_EN=1;
        
        keyIn=2; #10;
        keyIn=0; #10;
        keyIn=9; #10;
        keyIn=4; #10;
        
        WR_EN=0;
        #5 uut.printB();

        $stop;
    end

endmodule
