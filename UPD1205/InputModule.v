`timescale 1ns / 1ps

module InputModule(
    input CLK,
    input WR_EN,
    input RD_EN,
    input selectAB,
    input [7:0] keyIn,
    output reg [7:0] readDataA,
    output reg [7:0] readDataB,
    output reg doneA,
    output reg doneB
);

    reg [7:0] vectorA [0:7];
    reg [7:0] vectorB [0:7];

    integer indexA;
    integer indexB;
    integer readIndex;
    integer i;

    initial begin
        indexA = 0;
        indexB = 0;
        readIndex = 0;
        doneA = 0;
        doneB = 0;
        readDataA = 0;
        readDataB = 0;
        // Initialize arrays to avoid X
        for (i = 0; i < 8; i = i + 1) begin
            vectorA[i] = 0;
            vectorB[i] = 0;
        end
    end

    always @(posedge CLK) begin
        if (WR_EN) begin
            if (selectAB == 0) begin
                vectorA[indexA] <= keyIn;
                indexA <= indexA + 1;
                if (indexA == 7) begin  // FIXED: Set done after writing last element
                    doneA <= 1;
                end
            end else begin
                vectorB[indexB] <= keyIn;
                indexB <= indexB + 1;
                if (indexB == 7) begin  // FIXED: Set done after writing last element
                    doneB <= 1;
                end
            end
        end
        else if (RD_EN) begin
            readDataA <= vectorA[readIndex];
            readDataB <= vectorB[readIndex];
            readIndex <= readIndex + 1;
            if (readIndex == 7) begin
                readIndex <= 0;  // Reset for next read
            end
        end
    end

    // Debug tasks
    task printA;
        integer j;
        begin
            $display("---- DUMP VECTOR A ----");
            for (j = 0; j < 8; j = j + 1)
                $display("A[%0d] = %d", j, vectorA[j]);
        end
    endtask

    task printB;
        integer j;
        begin
            $display("---- DUMP VECTOR B ----");
            for (j = 0; j < 8; j = j + 1)
                $display("B[%0d] = %d", j, vectorB[j]);
        end
    endtask

endmodule